-module(mod_onetime_password).

-author("Travis Liu <travisliu@ecoworkinc.com>").

-behavior(gen_mod).

%% -include("ejabberd.hrl").
%% -include("jlib.hrl").

-export([start/2, stop/1, on_presence/4]).

start(_Host, _Opts) ->
    ejabberd_hooks:add(set_presence_hook, _Host, ?MODULE, on_presence, 50),
    ok.

stop(_Host) ->
    ejabberd_hooks:delete(set_presence_hook, _Host, ?MODULE, on_presence, 50),
    ok.

on_presence(User, Server, Resource, Packet) ->
    Date = jlib:timestamp_to_iso(calendar:universal_time()),
    RandomString = randoms:get_string(),
    NewPass = "RESET_PASSWORD--" ++ Date ++ "--" ++ RandomString,
    ejabberd_auth:set_password(User, Server, NewPass),
    none.