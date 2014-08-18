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
* 亦請避免使用「直接覆蓋」預設版本的暴力法
* 實務上每個 layer 至少會開兩個 instances，如此輪流開關機可保證跑過一整套部署流程，確保我們的 cookbooks 是正常的

# OpsWorks Configurations
## Stack
## Layers
## Instances
## Apps
## Deployments
## Monitoring
## Resources
## Permissions
