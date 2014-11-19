# ZyXEL Personal Cloud Chef Cookbooks on AWS OpsWorks

依照本文件操作時如果遭遇任何不確定的問題、疑難、錯誤，請即刻向 OpsWorks 部署工作負責人反映，以便即時排除並將文件敘述改寫更精確。

請同時參閱 *Personal Cloud AWS Settings* 文件設定 AWS 基礎設施（主要是 VPC），Personal Cloud 於 OpsWorks 上，需將這些基礎設施設定妥善方能順利配置。

# 各項子目錄作用

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

# Main Concepts, Hints

* Recipes 會照列表順序跑。
* 遇到同名的 recipe，OpsWorks 會以我們自訂的版本取代預設的，所以請注意 cookbook 與 recipe 的命名。
* 請避免使用「直接覆蓋」AWS 預設版本的暴力法：
    * 因為 AWS 官方也會修正他們的 cookbooks，如果直接覆蓋，會無法受惠於他們的修正。
    * 目前覆蓋自 AWS 預設版本的修改，都是情非得已，優先為了 Personal Cloud 各種專屬配置而改。
    * 任何需要覆蓋 AWS 預設版本的修改，請先徵得 OpsWorks 部屬工作負責人同意與 code review 過再行修改。

# OpsWorks Configurations

## Environments

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

## Stacks

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
    
## Layers

* 請注意！因系統安全緣故，除 XMPP Server (MongooseIM) 需要 Public IP Addr. 以外，其餘 layers 都不該配予 Public IP Addr.

### For Portal Stack

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
        * Public IP addresses => No
        * Elastic IP addresses => No
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
3. (Custom) MongooseIM
    * 因為不像 Rails App Server 有預設配套的 layer 可用，故此處需要新增一自訂 layer 為 'MongooseIM'
    * Recipes
        * Custom Chef Recipes
            *  Setup => `mongooseim::setup`
        * OS Packages
            * mysql-client
            * awscli
            * redis-tools

### For REST API Server Stack

## Apps

1. Personal Cloud Portal
    * Name => Personal Cloud Portal（因為 cookbooks 會比對 App 名稱，故請注意不要使用其他命名）
    * Rails environment => ?
    * Enable auto bundle => Yes
    * Document root => public
    * Repository type => Git
    * Repository URL => 如 Stack 一節所述，指向一份部署專用的 repository
    * Repository SSH key => 如 Stack 一節所述，指向一把部屬專用的 key
    * Branch/Revision => ?
    * Data source type => RDS
    * Domain name => ?
    * Enable SSL => ?
2. Personal Cloud Bots
    * Name => Personal Cloud Bots （因為 cookbooks 會比對 App 名稱，故請注意不要使用其他命名）
    * Type => Other
    * Repository type => Git
    * Repository URL => 如 Stack 一節所述，指向一份部署專用的 repository
    * Repository SSH key => 如 Stack 一節所述，指向一把部屬專用的 key
    * Branch/Revision => develop
    * Data source type => None

## Deployments

1. Personal Cloud Bots
    * 目前 Bot Jabber ID 設定值是寫死的，會依照 Bot layer instances 的 hostname 來指定，如 bot1 (server) 則讓 bot1, bot2 上線、bot2 (server) 類推讓 bot3, bp4 上線，對應設定寫在 Stack Custom JSON 
    * 另請參考 *ZyXEL Personal Cloud - Bot Deploy Guide For Create Instance Manually* 文件

## Monitoring
## Resources
## Permissions
## 問題診斷

1. 如果開機出問題，而 Web console 顯示大量 log 又會造成瀏覽器死機，我可以進到機器內去哪邊看 log？

    `/var/lib/aws/opsworks/chef/`
2. 部署的相關程式、設定檔案放在哪邊？

    `/srv/`
3. 如何獲取 Chef Node 的設定值？

    `sudo opsworks-agent-cli get_json`
4. 真正執行的 Chef Cookbooks 放在哪邊？

    `/opt/aws/opsworks/current/merged-cookbooks`
