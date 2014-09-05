# ZyXEL Personal Cloud Chef Cookbooks on AWS OpsWorks

https://gitlab.ecoworkinc.com/hiroshiyui/personal-cloud-cookbooks

各項子目錄作用：
* `/bot`: Bot servers
* `/deploy`:
  * `/attributes/customize.rb`: Customized attributes for Personal Cloud
* `/ejabberd`: ejabberd servers
* `/portalapp`: Personal Cloud Portal Rails application
* `/server`: Ubuntu 14.04 server

# Main Concepts, Hints

* Recipes 會照列表順序跑
* 遇到同名的 recipe，OpsWorks 會以我們自訂的版本取代預設的，所以請注意 cookbook 與 recipe 的命名
* 亦請避免使用「直接覆蓋」AWS 預設版本的暴力法
* 實務上每個 layer 至少會開兩個 instances，如此輪流開關機可保證跑過一整套部署流程，確保我們的 cookbooks 在 instance 的整個 life cycle 中運作是正常的

# OpsWorks Configurations

## Stack

* 建議規劃一個專用的 VPC 與之下的 subnet 供此 stack 使用
* SSH key 務必妥善保留
* Chef 版本使用 11.10
* **Use custom Chef cookbooks** => Yes
    * **Repository type** => Git
    * **Repository URL** => 指向自訂 cookbooks 的公司 GitLab repository，例如 `git@gitlab.ecoworkinc.com:hiroshiyui/personal-cloud-cookbooks.git`，並建議為了安全起見，**不要**直接使用開發版本，而是特別為部署獨立出一份專用 repository 
    * **Repository SSH key** => 同上，建議請獨立產生一把 SSH key 供此 repository 使用
    * **Branch/Revision** => 請指向部署專用的 branch/revision

## Layers

1. Rails App Server
    * General Settings
        * Ruby version => 2.1
        * Rails stack => nginx and Unicorn
        * RubyGems version => 2.2.1
        * Install and manage Bundler => Yes
        * Bundler version => 1.5.1
        * Auto healing enabled => Yes
    * Recipes
        * Custom Chef Recipes
            * 目前使用的這兩份自訂 recipes 的主要作用是自動安裝必要的軟體套件，以及把專屬設定檔放到該放的地方
                * `server::install\_packages`: 安裝必要的套件
                * `portalapp::configure`: 當前任務是將 `mailer.yml` 生出來，並搭配 `deploy/attributes/customize.rb` 的 `symlink_before_migrate` 自訂值，讓 Chef 幫我們自動做 symbolic link 到當前部署的 portal 版本的 `config/` 裡。
            * Setup => `server::install\_packages`
            * Configure => `portalapp::configure`
    * Network
        * Elastic Load Balancer => 新增一個 ELB，若設定正確，則 OpsWorks 會自動將 Rails instances 掛上此 ELB
        * Public IP addresses => Yes
        * Elastic IP addresses => 視是否需要固定 IP addr. 而定
2. RDS
    * Add Layer 時選擇右邊分頁的 RDS，依據實際需求建立一台
    * 設定完成後，於後述的 Apps 處若設定妥當，則 Rails App 會自動生出一個對應的 `config/database.yml` 配置檔
3. (Custom) Bot
    * 因為不像 Rails App Server 有預設配套的 layer 可用，故此處需要新增一自訂 layer 為 'Bot'
    * Auto healing enabled => yes
    * Recipes
        * Custom Chef Recipes
            * Deploy => `deploy::bots`
    * Network
        * Public IP addresses => yes
4. (Custom) ejabberd
    * 因為不像 Rails App Server 有預設配套的 layer 可用，故此處需要新增一自訂 layer 為 'ejabberd'

## Instances

## Apps

1. Personal Cloud Portal
    * Name => Personal Cloud Portal
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
    * Name => Personal Cloud Bots （因為 `deploy::bots` 會比對 App 名稱，故請注意不要使用其他命名）
    * Type => Other
    * Repository type => Git
    * Repository URL => 如 Stack 一節所述，指向一份部署專用的 repository
    * Repository SSH key => 如 Stack 一節所述，指向一把部屬專用的 key
    * Branch/Revision => develop
    * Data source type => None

## Deployments

1. Personal Cloud Bots
    * 目前 Bot Jabber ID 設定值是寫死的，配予兩組「臨時調撥用帳號」，故 instance 開機完成後，需儘速登入機器手動設定，將 ID 調開，否則 instances 之間會一直搶佔身分。請在 deploy 時，於 Advanced -> Custom Chef JSON 處，輸入如下格式的 Jabber IDs 指派設定：

            {"xmpp_config": [
              {"jid": "botno1@xmpp.pcloud.ecoworkinc.com/robot", "pw": "YOUR_BOTNO1_PASSWORD"},
              {"jid": "botno2@xmpp.pcloud.ecoworkinc.com/robot", "pw": "YOUR_BOTNO2_PASSWORD"}
            ]}
    * 另可參考 *ZyXEL Personal Cloud - Bot Deploy Guide For Create Instance Manually* 文件

## Monitoring
## Resources
## Permissions
