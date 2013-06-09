%%
%% %CopyrightBegin%
%%
%% Copyright Michal Slaski 2013. All Rights Reserved.
%%
%% %CopyrightEnd%
%%
-module(epl_static).
-include_lib("epl/include/epl.hrl").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, App) when is_list(App) ->
    {ok, Req, << (list_to_binary(App))/binary, "/priv/htdocs/" >>}.

handle(Req, PathPrefix) ->
    File = case cowboy_req:path_info(Req) of
               {[], _} -> <<"index.html">>;
               {PathInfo, _} -> filename:join(PathInfo)
           end,
    FilePath = << PathPrefix/binary, File/binary >>,
    case epl:lookup(FilePath) of
        [{_, Bin}] ->
            {ok, Req2} = cowboy_req:reply(
                           200, [content_type(FilePath)],
                           Bin, Req),
            {ok, Req2, PathPrefix};
        [] ->
            {ok, Req2} = cowboy_req:reply(
                           404, [{<<"content-type">>, <<"text/html">>}],
                           <<"<html><body>Not Found</body></html>">>, Req),
            {ok, Req2, PathPrefix}
    end.

terminate(_Reason, _Req, _State) ->
    ok.

content_type(FilePath) ->
    case filename:extension(FilePath) of
        <<>> ->
            {<<"content-type">>, <<"text/html">>};
        Extension ->
            {<<"content-type">>, mime(Extension)}
    end.

mime(<<".css">>)   -> <<"text/css">>;
mime(<<".html">>)  -> <<"text/html">>;
mime(<<".htm">>)   -> <<"text/html">>;
mime(<<".js">>)    -> <<"application/javascript">>;
mime(<<".xml">>)   -> <<"application/xml">>;
mime(<<".xsl">>)   -> <<"application/xml">>;
mime(<<".dtd">>)   -> <<"application/xml-dtd">>;
mime(<<".xhtml">>) -> <<"application/xhtml+xml">>;
mime(<<".xht">>)   -> <<"application/xhtml+xml">>;
mime(<<".zip">>)   -> <<"application/zip">>;
mime(<<".ttf">>)   -> <<"application/x-font-ttf">>;
mime(<<".ttc">>)   -> <<"application/x-font-ttf">>;
mime(<<".woff">>)  -> <<"application/x-font-woff">>;
mime(<<".ico">>)   -> <<"image/x-icon">>;
mime(<<".gif">>)   -> <<"image/gif">>;
mime(<<".jpeg">>)  -> <<"image/jpeg">>;
mime(<<".jpg">>)   -> <<"image/jpeg">>;
mime(<<".jpe">>)   -> <<"image/jpeg">>;
mime(<<".png">>)   -> <<"image/png">>;
mime(<<".svg">>)   -> <<"image/svg+xml">>;
mime(<<".svgz">>)  -> <<"image/svg+xml">>;
mime(Ext) ->
    ?ERROR("Unknown extension ~p, will use application/octet-stream~n", [Ext]),
    <<"application/octet-stream">>.
