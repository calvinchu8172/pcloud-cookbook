# 關於 OpsWorks

http://docs.aws.amazon.com/opsworks/latest/APIReference/Welcome.html
> AWS OpsWorks is an application management service that provides an integrated experience for overseeing the complete application lifecycle.

http://aws.amazon.com/documentation/opsworks/
> AWS OpsWorks provides a simple and flexible way to create and manage stacks and applications. With AWS OpsWorks, you can provision AWS resources, manage their configuration, deploy applications to those resources, and monitor their health.

## Why OpsWorks

* 套用框架，有規則可循，避免專案部署時的各種資源發散
* 盡可能自動化處理，節省人力資源

## 層級

* Stack
    * 一群 AWS 資源的集合
* Layers
    * 定義如何建立、配置一群相同用途的 instances
    * 除了預設提供的 layers，也可透過自訂 layer、覆寫預設設定值、配置自訂 Chef recipes 來設計專用 layer
* Apps

## Chef

### Overview

### In OpsWorks

* https://github.com/aws/opsworks-cookbooks
* 在 instance 生命週期的各個關鍵階段，可配置對應的 recipes 來自訂它

## API & SDK

* [AWS OpsWorks API Reference](http://docs.aws.amazon.com/opsworks/latest/APIReference/Welcome.html)
    * Actions
    * Data Types
* [Class: AWS::OpsWorks::Client — AWS SDK for Ruby](http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/OpsWorks/Client.html)
