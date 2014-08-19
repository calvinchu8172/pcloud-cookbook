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
* 實務上每個 layer 至少會開兩個 instances，如此輪流開關機可保證跑過一整套部署流程，確保我們的 cookbooks 是正常的

# OpsWorks Configurations

## Stack

* 建議規劃一個專用的 VPC 與之下的 subnet 供此 stack 使用
* SSH key 務必妥善保留
* Chef 版本使用 11.10
* **Use custom Chef cookbooks** => Yes
  * **Repository type** => Git
  * **Repository URL** => 指向自訂 cookbooks 的公司 GitLab repository，例如 `git@gitlab.ecoworkinc.com:hiroshiyui/personal-cloud-cookbooks.git`，並建議為了安全起見不要直接使用開發版本，而是特別為部署獨立出一份專用 repository 
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
          * Setup => `server::install\_packages`
          * Configure => `portalapp::configure`
  * Network
      * Elastic Load Balancer => 新增一個 ELB，若設定正確，則 OpsWorks 會自動將 Rails instances 掛上此 ELB
      * Public IP addresses => Yes
      * Elastic IP addresses => 視是否需要固定 IP addr. 而定
2. RDS
3. (Custom) ejabberd
4. (Custom) Bot
5. (Custom) Docker

## Instances
## Apps
## Deployments
## Monitoring
## Resources
## Permissions
