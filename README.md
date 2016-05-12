# ZyXEL Personal Cloud Chef Cookbooks on AWS OpsWorks

依照本文件操作時如果遭遇任何不確定的問題、疑難、錯誤，請即刻向 OpsWorks 部署工作負責人反映，以便即時排除並將文件敘述改寫更精確。

請同時參閱 *Personal Cloud AWS Settings* 文件設定 AWS 基礎設施（主要是 VPC），Personal Cloud 於 OpsWorks 上，需將這些基礎設施設定妥善方能順利配置。

# A. 各項子目錄作用

* `/deploy`:
    * `/attributes/customize.rb`: Customized attributes for Personal Cloud
    * `/definitions`: Customized definitions for Personal Cloud
    * `/recipes`: Customized deploy recipes for Personal Cloud
    * `/templates`: Customized templates for Personal Cloud
* `/ejabberd`: ejabberd servers
* `/mongooseim`: MongooseIM servers
* `/nginx`: nginx Web servers
* `/opsworks_stack_state_sync`: OpsWorks Stack state sync
* `/portalapp`: Personal Cloud Portal Rails application
* `/rest-api`: Personal Cloud Portal Rails application (RESTful API operation mode)
* `/rails`: Rails
* `/server`: Ubuntu 14.04 server
* `/unicorn`: Unicorn application server

# B. Main Concepts, Hints

* Recipes 會照列表順序跑。
* 遇到同名的 recipe，OpsWorks 會以我們自訂的版本取代預設的，所以請注意 cookbook 與 recipe 的命名。
* 請避免使用「直接覆蓋」AWS 預設版本的暴力法：
    * 因為 AWS 官方也會修正他們的 cookbooks，如果直接覆蓋，會無法受惠於他們的修正。
    * 目前覆蓋自 AWS 預設版本的修改，都是情非得已，優先為了 Personal Cloud 各種專屬配置而改。
    * 任何需要覆蓋 AWS 預設版本的修改，請先徵得 OpsWorks 部屬工作負責人同意與 code review 過再行修改。

# C. OpsWorks Configurations

## C.1 Environments

Personal Cloud 依據不同任務需求，分為三種環境：

1. Production
2. Beta
3. Alpha

對應到 AWS OpsWorks，則規劃了下列 Stacks：

1. Production
    * Personal Cloud Portal Production
    * Personal Cloud REST API Server Production
2. Beta
    * Personas Cloud Portal Beta
    * Personal Cloud REST API Server Beta
3. Alpha
    * Personal Cloud Portal Alpha
    * Personal Cloud REST API Server Alpha 

## C.2 Stacks

* 實務上，可以 clone 已經規劃的 Stack，配上適合的修改（如 Security Groups 一定要改、Git repo. 等則視需求而定），就可以快速複製一樣的環境，所以若要作 A/B Test 則請 clone 一系列 Stacks 來做實驗組，而不要直接修改目前已經在運作的 Stack
* Default operating system => Ubuntu 14.04 LTS
* Default root device type => EBS backed
* Hostname theme => 請務必使用 Layer Dependent，因為部署流程中至少包括 Bots, MongooseIM 都依賴辨識 hostname 來運作
* Chef 版本使用 11.10
* **Use custom Chef cookbooks** => Yes
    * **Repository type** => Git
    * **Repository URL** => 指向自訂 cookbooks 的公司 GitLab repository，例如 `git@gitlab.ecoworkinc.com:zyxel/personal-cloud-cookbooks.git`，並建議為了安全起見，不要直接使用開發版本，而是為部署獨立出一份專用 repository 
    * **Repository SSH key** => 同上，建議請獨立產生一把 SSH key 供此 repository 使用
    * **Branch/Revision** => 請指向部署專用的 branch/revision
        * Production 會指向特定版號 tag，如 1.0.0
        * Beta 指向 master branch
        * Alpha 指向 develop branch
* Custom JSON
    * 為了我們的部署需求，每個 stack 都有一份專屬的 custom JSON，記載所需配置的設定值，請勿任意修改
    * 請參閱 *ZyXEL Personal Cloud Custom JSON Configuration* 瞭解 Custom JSON 當中的設定值意義
* Use OpsWorks security groups => Yes
    
## C.3 Layers

請注意！因系統安全緣故，除 XMPP Server (MongooseIM) 需要 Public IP Addr. 以外，其餘 layers 都不該配予 Public IP Addr.

### C.3.1 For Portal Stack

1. Rails App Server
    * General Settings
        * Ruby version => 2.1
        * Rails stack => nginx and Unicorn
        * RubyGems version => 2.2.2
        * Install and manage Bundler => Yes
        * Bundler version => 1.5.3
        * Auto healing enabled => Yes
    * Recipes
        * Custom Chef Recipes
            * 目前使用的這兩份自訂 recipes 的主要作用是自動安裝必要的軟體套件，以及把專屬設定檔放到該放的地方
                * `server::install\_packages`: 安裝必要的套件
                * `portalapp::configure`: 當前任務是將 `mailer.yml` 生出來，並搭配 `deploy/attributes/customize.rb` 的 `symlink_before_migrate` 自訂值，讓 Chef 幫我們自動做 symbolic link 到當前部署的 portal 版本的 `config/` 裡。
            * Setup => `server::install\_packages`
            * Configure => `portalapp::configure`
        * OS Packages
            * libmysqlclient-dev
            * mysql-client
            * awscli
            * ntp
    * Network
        * Elastic Load Balancer 參照 *Personal Cloud AWS Settings* 指定一個 ELB，若設定正確，則 OpsWorks 會自動將 Rails instances 掛上此 ELB
            * Production => PCloud-Prod-Portal-Web
            * Beta => PCloud-Beta-Portal-Web
            * Alpha => PCloud-Alpha-Portal-Web
        * Public IP addresses => no
    * Security
        * Security Groups
            * Default groups => AWS-OpsWorks-Rails-App-Server
            * Custom groups（參照 *Personal Cloud AWS Settings*）
                * Production => PCloud-Prod-EC2-Instance, PCloud-Prod-Web-Server
                * Beta => PCloud-Beta-EC2-Instance, PCloud-Beta-Web-Server
                * Alpha => PCloud-Alpha-EC2-Instance, PCloud-Alpha-Web-Server
2. (Custom) Bot
    * 因為不像 Rails App Server 有預設配套的 layer 可用，故此處需要新增一自訂 layer 為 'Bot'
    * Auto healing enabled => yes
    * Recipes
        * Custom Chef Recipes
            * Deploy => `deploy::bots`
        * OS Packages
            * libmysqlclient-dev
            * mysql-client
            * awscli
            * redis-tools
    * Network
        * Public IP addresses => no
    * Security
        * Security Groups
            * Default groups => AWS-OpsWorks-Custom-Server
            * Custom groups（參照 *Personal Cloud AWS Settings*）
                * Production => PCloud-Prod-Bot-Server, PCloud-Prod-EC2-Instance
                * Beta => PCloud-Beta-Bot-Server, PCloud-Beta-EC2-Instance
                * Alpha => PCloud-Alpha-Bot-Server, PCloud-Alpha-EC2-Instance
3. (Custom) MongooseIM
    * 因為不像 Rails App Server 有預設配套的 layer 可用，故此處需要新增一自訂 layer 為 'MongooseIM'
    * Recipes
        * Custom Chef Recipes
            *  Setup => `mongooseim::setup`
        * OS Packages
            * mysql-client
            * awscli
            * redis-tools
    * Network
        * **Public IP addresses => yes**
    * Security
        * Security Groups
            * Default groups => AWS-OpsWorks-Custom-Server
            * Custom groups（參照 *Personal Cloud AWS Settings*）
                * Production => PCloud-Prod-EC2-Instance, PCloud-Prod-XMPP-Server
                * Beta => PCloud-Beta-EC2-Instance, PCloud-Beta-XMPP-Server
                * Alpha => PCloud-Alpha-EC2-Instance, PCloud-Alpha-XMPP-Server

### C.3.2 For REST API Server Stack

1. Rails App Server
    * General Settings
        * Ruby version => 2.1
        * Rails stack => nginx and Unicorn
        * RubyGems version => 2.2.2
        * Install and manage Bundler => Yes
        * Bundler version => 1.5.3
        * Auto healing enabled => Yes
    * Recipes
        * Custom Chef Recipes
            * Setup => `server::install\_packages`
            * Configure => `rest-api::configure`
        * OS Packages
            * libmysqlclient-dev
            * mysql-client
            * awscli
            * ntp
    * Network
        * Elastic Load Balancer 參照 *Personal Cloud AWS Settings* 指定一個 ELB，若設定正確，則 OpsWorks 會自動將 Rails instances 掛上此 ELB
            * Production => PCloud-Prod-RESTful-API
            * Beta => PCloud-Beta-RESTful-API 
            * Alpha => PCloud-Alpha-RESTful-API 
        * Public IP addresses => no
    * Security
        * Security Groups
            * Default groups => AWS-OpsWorks-Rails-App-Server
            * Custom groups（參照 *Personal Cloud AWS Settings*）
                * Production => PCloud-Prod-EC2-Instance, PCloud-Prod-Web-Server
                * Beta => PCloud-Beta-EC2-Instance, PCloud-Beta-Web-Server
                * Alpha => PCloud-Alpha-EC2-Instance, PCloud-Alpha-Web-Server

## C.4 Instances

新增 instance 時，請注意：

* Hostname 請直接採用系統自動給予的 Layer Dependent 名稱，如 rails-app2 即可
* 因 AWS 費用考量，請選擇適當的 Size (instance type)
* 參照 *Personal Cloud AWS Settings* 選擇正確的、對應的 Subnet
* 為求保存 instance 資料，Root device type 請選用 EBS backed

## C.5 Apps

### C.5.1 For Portal Stack

1. Personal Cloud Portal
    * Name => Personal Cloud Portal（因為 cookbooks 會比對 App 名稱，故請注意不要使用其他命名）
    * Rails environment
        * Production => production
        * Beta => production
        * Alpha => staging
    * Enable auto bundle => Yes
    * Document root => public
    * Data source type => None，因為 Personal Cloud 掛載了複數的 RDS (MySQL)，故在此無法選用現成的 RDS 選項，需要透過 recipe 產生資料庫連接設定檔
    * Repository type => Git
    * Repository URL => 如 Stack 一節所述，指向一份部署專用的 repository
    * Repository SSH key => 如 Stack 一節所述，指向一把部屬專用的 key
    * Branch/Revision
        * Production => master
        * Beta => master
        * Alpha => develop
    * Environment Variables
        * RAILS_SECRET_KEY 需配置一個透過 `rake secret` 產生一組 secret key
2. Personal Cloud Bots
    * Name => Personal Cloud Bots （因為 cookbooks 會比對 App 名稱，故請注意不要使用其他命名）
    * Type => Other
    * Data source type => None
    * Repository type => Git
    * Repository URL => 如 Stack 一節所述，指向一份部署專用的 repository
    * Repository SSH key => 如 Stack 一節所述，指向一把部屬專用的 key
    * Branch/Revision
        * Production => master
        * Beta => master
        * Alpha => develop

### C.5.2 For REST API Server Stack

1. Personal Cloud REST API
    * Name => Personal Cloud REST API（因為 cookbooks 會比對 App 名稱，故請注意不要使用其他命名）
    * Rails environment
        * Production => production
        * Beta => production
        * Alpha => staging
    * Enable auto bundle => Yes
    * Document root => public
    * Data source type => None，因為 Personal Cloud 掛載了複數的 RDS (MySQL)，故在此無法選用現成的 RDS 選項，需要透過 recipe 產生資料庫連接設定檔
    * Repository type => Git
    * Repository URL => 如 Stack 一節所述，指向一份部署專用的 repository
    * Repository SSH key => 如 Stack 一節所述，指向一把部屬專用的 key
    * Branch/Revision
        * Production => master
        * Beta => master
        * Alpha => develop
    * Environment Variables
        * RAILS_SECRET_KEY 需與 C.5.1 的 Personal Cloud Portal 使用的 secret key 一致

## C.6 Deployments

### C.6.1 Deploy an App

* 為求部署效率，請務必選對正確的 App 與對應的 Instances，例如在部署 Personal Cloud Bots 時指定 Instances 僅針對 Bot 群

### C.6.2 Run command

* Update Custom Cookbooks 若更新我們自訂的 cookbooks 請跑這個命令，上線中的 instances 並不會自動抓取更新
* Setup 幾乎等同於將整個開機、部署流程跑一遍，並會套用更新的 Custom JSON 與自訂環境變數
* Configure 主要作用是將設定檔依據當下的有效資料（Custom JSON、環境變數、覆寫的 attributes⋯⋯）重建一份新版並套用

### C.6.3 For Portal Stack

1. Personal Cloud Portal
    * 請注意因為資料庫連結方式大幅自訂的緣故，OpsWorks 提供的 Migrate database 會失敗，故若要需要跑 Rails migration 請至任一 Personal Cloud Portal instance 底下手動執行，使 RDS 能套用 migration(s)
2. Personal Cloud Bots
    * 目前 Bot Jabber ID 設定值是寫死的，會依照 Bot layer instances 的 hostname 來指定，如 bot1 (server) 則讓 bot1, bot2 上線、bot2 (server) 類推讓 bot3, bp4 上線，對應設定寫在 Stack Custom JSON 
    * 另請參考 *ZyXEL Personal Cloud - Bot Deploy Guide For Create Instance Manually* 文件

## C.7 Permissions

* 列在此項的帳號，若提供 Public SSH key，系統會透過 recipe 自動建立一個對應的 SSH 帳號，可透過 VPN 走 SSH 協定登入主機
* 請注意權限的管控，勿浮濫開放

## C.8 monit

1. opsworks 有內建 monit ,主要是用來監控 instance 內的 opsworks agent 是否有正成運行
2. 為了保證 unicorn process 不會因為 unicorn master process 死亡就停止,所以額外 monit 設定檔來監控 unicorn master　( 不可以蓋掉原本就在跑的 monit 設定檔,不然 opsworks agent 可能會出問題 )
3. 系統內每一個 unicorn master ,會有一個對應的 monit 設定檔( 所以 portal instance 會有兩個設定檔 : portal + findme ,　restful-api 會有一個設定檔 : restful api ) 
4. monit 設定檔( *.monitrc )放置位置 `/etc/monit/conf.d/`
	* portal `/etc/monit/conf.d/personal_cloud_portal_unicorn_master.monitrc`
	* findme `/etc/monit/conf.d/personal_cloud_findme.monitrc`
	* restful api `/etc/monit/conf.d/personal_cloud_rest_api_unicorn_master.monitrc`
5. *.monitrc 設定檔的結構可以參考 `https://mmonit.com/monit/` 此專案內主要是用到 pid file 和 start 兩個部份.
6.  此專案中主要是靠 unicorn master的 pid file 來取得該監控的 process id ,pid 位置:
	* portal `/srv/www/personal_cloud_portal/shared/pids/unicorn.pid` 
	* findme `/srv/www/personal_cloud_findme/shared/pids/unicorn.pid`
	* restful api `/srv/www/personal_cloud_rest_api/shared/pids/unicorn.pid`
7. monit 碰到 unicorn master 死掉時執行的指令
	* portal `/bin/su -c '/srv/www/personal_cloud_portal/shared/scripts/unicorn start'` 
	* findme `/bin/su -c '/srv/www/personal_cloud_findme/shared/scripts/unicorn start`
	* restful api `/bin/su -c '/srv/www/personal_cloud_rest_api/shared/scripts/unicorn start`
8. cookbook　只要作好把 app 設定檔放到對應位置這個動作,即可確保 service 有被 monit監控
	* portal : `portalapp/recipes/configure.rb`
	* restful-api : `rest-api/recipe/configure.rb`
	* findme : `findme/recipes/configure.rb`
9. 開機完後可以登入 instance 內,輸入 `monit status` 驗證 服務是否有被監控


# D. 問題診斷

1. 如果開機出問題，而 Web console 顯示大量 log 又會造成瀏覽器死機，我可以進到機器內去哪邊看 log？

    `/var/lib/aws/opsworks/chef/`
2. 部署的相關程式、設定檔案放在哪邊？

    `/srv/`
3. 如何獲取 Chef Node 的設定值？

    `sudo opsworks-agent-cli get_json`
4. 真正執行的 Chef Cookbooks 放在哪邊？

    `/opt/aws/opsworks/current/merged-cookbooks`
5. 如果需要將 instance 升降級，但是發現沒有想要的 instance type 可選，該怎麼辦？

    這是因為 instance 選定的 Virtualization type 不同所導致，只能將該 instance 移除重建。請注意如果需要重建 MongooseIM，務必在移除原有 instance 時保留已經取得的 Elastic IP，再將新開的 instance 掛上原來的 Elastic IP，否則後續得修改 VPC 與相關文件等一系列資料，非常麻煩，敬請注意這點。
