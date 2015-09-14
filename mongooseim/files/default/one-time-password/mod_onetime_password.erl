-module(mod_onetime_password).

-author("Travis Liu <travisliu@ecoworkinc.com>").

-behavior(gen_mod).

%% -include("ejabberd.hrl").
%% -include("jlib.hrl").

%% gen_mod callbacks
-export([start/2, stop/1, on_presence/4]).

%% -export([on_presence/4, do_offline]).

start(_Host, _Opts) ->
    ejabberd_hooks:add(set_presence_hook, _Host, ?MODULE, on_presence, 50),
%    ejabberd_hooks:add(unset_presence_hook, _Host, ?MODULE, catch_offline, 50),
    ok.

stop(_Host) ->
    ejabberd_hooks:delete(set_presence_hook, _Host, ?MODULE, on_presence, 50),
%    ejabberd_hooks:delete(unset_presence_hook, _Host, ?MODULE, catch_offline, 50),
    ok.

on_presence(User, Server, Resource, Packet) ->
%   Date = jlib:timestamp_to_iso(calendar:universal_time()),
    NewPass = random_string(10),
    ejabberd_auth:set_password(User, Server, NewPass),
    none.

%catch_offline(User, Server, Resource, Packet) ->
%    ejabberd_auth:set_password(User, Server, "This_data_setted_by_catch_offline_hanlder"),
%    none.


% 關於 random:seed(erlang:now()):
% random:uniform() 每次呼叫都會更新 process 的 dictionary 裡的 random_seed 變數，
% 但如果是不同的 process ，由於 seed 更新的算法在各 process 中皆一樣，以至於在各 process 所生成
% 的隨機數也會一樣，要想讓不同的 process 生成的 random number 不同，需手動設置不同的 random_seed，
% 因此可用 random:seed(erlang.now()), random:uniform().
random_string(Len) ->
    Chrs = list_to_tuple("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"),
    ChrsSize = size(Chrs),
    random:seed(erlang:now()),
    F = fun(_, R) -> [element(random:uniform(ChrsSize), Chrs) | R] end,
    lists:foldl(F, "", lists:seq(1, Len)).




