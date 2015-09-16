# MongooseIM one time password

================

此為ejabberd module,使用者在登入後隨即就會將密碼改成亂碼
example:
```
S6YjOr02LP
```

安裝
-----------

- 在 ubuntu compile erlang 需要安裝下列兩個套件
  * erlang-base
  * erlang-base-hipe

- compile 指令 erlc [source code path]
  example:
  ```
  erlc /home/deploy/mod_onetime_password.erl
  ```

- 複製到 mongooseim 的module path 裡
  example:
  ```
  sudo cp /home/deploy/mod_onetime_password.beam /usr/lib/mongooseim/lib/ejabberd-2.1.8+mim-1.5.0/ebin/
  ```

- 至 mongooseim 的設定檔裡 加上 onetime password 的 module
  example:
  ```
  modules 底下新增
  {mod_onetime_password, []}
  ```

- 再將mongooseim 重啟即可
  ```
  mongooseimctl stop
  mongooseimctl start
  ```

warnning
-----------
因為ejabberd 沒有 login 的event hook
所以是使用 on_presence
也就是不只是登入，只要改變狀態就會觸發此功能

另外需要壓測避免resource leaking的問題
像是隨者使用者登入次數越來越多
會不會造成記憶體越吃越多的 memory leaking
避免造成XMPP Server的不穩定

refers
-----------

http://metajack.im/2008/08/28/writing-ejabberd-modules-presence-storms/
