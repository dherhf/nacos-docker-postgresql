# Nacos Docker (PostgreSQL)

![Docker Pulls](https://img.shields.io/docker/pulls/dherhf/nacos-postgresql.svg?maxAge=60480)

本项目是 [nacos-docker](https://github.com/nacos-group/nacos-docker) 的 PostgreSQL 定制版，用于构建以 PostgreSQL 作为数据源的 [Nacos](https://github.com/alibaba/nacos) Server Docker 镜像，镜像发布为 `dherhf/nacos-postgresql`。

[**English**](README.md)

## 注意

从Nacos 2.2.1开始为了系统安全考虑**移除**了以下环境变量的默认值,启动时请自行添加,否则会启动报错.

1. ~~NACOS_AUTH_IDENTITY_KEY~~
2. ~~NACOS_AUTH_IDENTITY_VALUE~~
3. ~~NACOS_AUTH_TOKEN~~

从 Nacos 3.3 开始，未设置 `NACOS_AUTH_ENABLE` 时，Client API 鉴权（`nacos.core.auth.enabled`）默认开启。
显式设置 `NACOS_AUTH_ENABLE=true` 或 `NACOS_AUTH_ENABLE=false` 均会覆盖该默认值。应用客户端尚未完成凭据配置时，
可以将显式 `false` 作为有时限的升级兼容选择；旧版本镜像仍遵循各自版本内置的默认值。

Client API 鉴权与 Admin API、Console API 鉴权相互独立。本次默认值调整不会关闭或改变
`NACOS_AUTH_ADMIN_ENABLE` 和 `NACOS_AUTH_CONSOLE_ENABLE`。生产环境必须使用唯一且足够强的 token secret 和
server identity；仓库中提交的凭据仅用于本地示例，不得在生产环境复用。

## 项目目录

* build：nacos 镜像制作的源码
* env: docker compose 环境变量文件
* example: Nacos Server + PostgreSQL 的 docker-compose 编排例子，包含 PostgreSQL 数据库脚本及其初始化脚本

## 运行环境

* [Docker](https://www.docker.com/)

### 注意事项

* 本定制版仅支持 **Nacos 3.x** + **PostgreSQL** 数据源。
* 首次启动 Nacos 前必须初始化 PostgreSQL 数据库脚本：
  * `example/pg-nacos-init.sh` 会根据 `NACOS_VERSION` 下载对应版本的数据库脚本到 `example/pg-init/pg-schema.sql`
  * `example/pg-init/pg-schema.sql` 已提交在仓库中，`standalone-postgresql.yaml` 会直接使用
  * 如果你使用自定义数据库, 第一次启动Nacos前需要手动初始化 [PostgreSQL 数据库脚本](https://github.com/alibaba/nacos/blob/develop/plugin-default-impl/nacos-default-datasource-plugin/nacos-datasource-plugin-postgresql/src/main/resources/META-INF/pg-schema.sql)

## 快速开始

### Nacos v3.x + PostgreSQL

```shell
docker run --name nacos-standalone-postgresql \
    -e MODE=standalone \
    -e POSTGRESQL_SERVICE_HOST=${your_postgresql_host} \
    -e POSTGRESQL_SERVICE_PORT=5432 \
    -e POSTGRESQL_SERVICE_DB_NAME=nacos \
    -e POSTGRESQL_SERVICE_USER=${your_postgresql_user} \
    -e POSTGRESQL_SERVICE_PASSWORD=${your_postgresql_password} \
    -e NACOS_AUTH_TOKEN=${your_nacos_auth_secret_token} \
    -e NACOS_AUTH_IDENTITY_KEY=${your_nacos_server_identity_key} \
    -e NACOS_AUTH_IDENTITY_VALUE=${your_nacos_server_identity_value} \
    -p 8080:8080 \
    -p 8848:8848 \
    -p 9848:9848 \
    -d dherhf/nacos-postgresql:latest
```

启动前需要先初始化 PostgreSQL 数据库脚本，参见 `example/pg-init/pg-schema.sql`。

## 其他使用方式

* 提示: 你需要通过 `example/.env` 中的以下配置来更改 Compose 文件中 [Nacos 镜像版本](https://hub.docker.com/r/dherhf/nacos-postgresql/tags)。

```dotenv
NACOS_VERSION=v3.2.4
```

打开命令窗口执行：

* Clone project

  ```powershell
  git clone --depth 1 https://github.com/dherhf/nacos-docker-postgresql.git
  cd nacos-docker-postgresql
  ```

* Standalone PostgreSQL

  ```powershell
  cd example
  ./pg-nacos-init.sh && docker-compose -f standalone-postgresql.yaml up
  ```

* Standalone Independent PostgreSQL（仅支持 Nacos 3.x 版本）

  ```powershell
  cd example
  ./pg-nacos-init.sh && docker-compose -f standalone-independent-postgresql.yaml up
  ```

* 登录（Nacos 3.3 及以上版本默认要求 Client API 请求携带凭据）

  ```powershell
  curl -X POST 'http://127.0.0.1:8848/nacos/v3/auth/user/login' -d 'username=nacos' -d 'password=${your_password}'
  ```

* 服务注册示例

  ```powershell
  curl -X POST 'http://127.0.0.1:8848/nacos/v3/client/ns/instance?serviceName=quickstart.test.service&ip=127.0.0.1&port=8080' -H "accessToken:${your_access_token}"
  ```

* 服务发现示例

  ```powershell
  curl -X GET 'http://127.0.0.1:8848/nacos/v3/client/ns/instance/list?serviceName=quickstart.test.service' -H "accessToken:${your_access_token}"
  ```

* 推送配置示例

  ```powershell
  curl -X POST 'http://127.0.0.1:8848/nacos/v3/admin/cs/config?dataId=quickstart.test.config&groupName=test&content=HelloWorld' -H "accessToken:${your_access_token}"
  ```

* 获取配置示例

  ```powershell
    curl -X GET 'http://127.0.0.1:8848/nacos/v3/client/cs/config?dataId=quickstart.test.config&groupName=test' -H "accessToken:${your_access_token}"
  ```

* 访问控制台

  浏览器访问：http://127.0.0.1:8080/index.html

## 属性配置列表

| 属性名称                                    | 描述                                        | 选项                                                                                                                                                                                    |
|-----------------------------------------|-------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| MODE                                    | 系统启动方式: 集群/单机                             | cluster/standalone 默认 **cluster**                                                                                                                                                     |
| FUNCTION_MODE                           | 启动功能模式: all或留空 表示全部模块(lite镜像不支持ai功能)      | config/naming/microservice/ai/all 默认 **all**                                                                                                                                          |
| NACOS_SERVERS                           | 集群地址                                      | p1:port1空格ip2:port2 空格ip3:port3                                                                                                                                                       |
| PREFER_HOST_MODE                        | 支持IP还是域名模式                                | hostname/ip 默认**IP**                                                                                                                                                                  |
| NACOS_SERVER_PORT                       | Nacos 运行端口                                | 默认**8848**                                                                                                                                                                            |
| NACOS_SERVER_IP                         | 多网卡模式下可以指定IP                              |                                                                                                                                                                                       |
| SPRING_DATASOURCE_PLATFORM              | 单机模式下支持PostgreSQL数据库                        | postgresql / 空 默认:**postgresql**                                                                                                                                                      |
| POSTGRESQL_SERVICE_HOST                 | 数据库 连接地址                                  |                                                                                                                                                                                       |
| POSTGRESQL_SERVICE_PORT                 | 数据库端口                                     | 默认 : **5432**                                                                                                                                                                         |
| POSTGRESQL_SERVICE_DB_NAME              | 数据库库名                                     | 默认 : **nacos**                                                                                                                                                                        |
| POSTGRESQL_SERVICE_USER                 | 数据库用户名                                    | 默认 : **nacos**                                                                                                                                                                        |
| POSTGRESQL_SERVICE_PASSWORD             | 数据库用户密码                                   | 默认 : **nacos**                                                                                                                                                                        |
| POSTGRESQL_DATABASE_NUM                 | 数据库个数                                     | 默认:**1**                                                                                                                                                                              |
| POSTGRESQL_SERVICE_DB_PARAM             | 数据库连接参数                                   | 默认:**tcpKeepAlive=true&reWriteBatchedInserts=true&ApplicationName=nacos_java**                                                                                                        |
| JVM_XMS                                 | -Xms                                      | 默认 :1g                                                                                                                                                                                |
| JVM_XMX                                 | -Xmx                                      | 默认 :1g                                                                                                                                                                                |
| JVM_XMN                                 | -Xmn                                      | 512m                                                                                                                                                                                  |
| JVM_MS                                  | - XX:MetaspaceSize                        | 默认 :128m                                                                                                                                                                              |
| JVM_MMS                                 | -XX:MaxMetaspaceSize                      | 默认 :320m                                                                                                                                                                              |
| NACOS_DEBUG                             | 是否开启远程DEBUG                               | y/n 默认 :n                                                                                                                                                                             |
| TOMCAT_ACCESSLOG_ENABLED                | server.tomcat.accesslog.enabled           | 默认 :false                                                                                                                                                                             |
| NACOS_AUTH_SYSTEM_TYPE                  | 权限系统类型选择,目前只支持nacos类型                     | 默认 :nacos                                                                                                                                                                             |
| NACOS_AUTH_ENABLE                       | 是否开启 Client API 鉴权；与 Admin、Console API 鉴权相互独立 | 未设置时使用镜像默认值（Nacos 3.3+ 为 `true`；旧镜像保留各自内置默认值）。显式 `true`/`false` 均可覆盖；`false` 仅建议作为有时限的升级兼容选择。                                                                                         |
| NACOS_AUTH_TOKEN_EXPIRE_SECONDS         | token 失效时间                                | 默认 :18000                                                                                                                                                                             |
| NACOS_AUTH_TOKEN                        | Base64 编码的 token secret；生产环境必须使用唯一值         | `注意：其默认值从 Nacos 2.2.1 起移除，必须显式设置。`                                                                                                                                                    |
| NACOS_AUTH_CACHE_ENABLE                 | 权限缓存开关 ,开启后权限缓存的更新默认有15秒的延迟               | 默认 : false                                                                                                                                                                            |
| MEMBER_LIST                             | 通过环境变量的方式设置集群地址                           | 例子:192.168.16.101:8847?raft_port=8807,192.168.16.101?raft_port=8808,192.168.16.101:8849?raft_port=8809                                                                                |
| EMBEDDED_STORAGE                        | 是否开启集群嵌入式存储模式                             | `embedded`  默认 : none                                                                                                                                                                 |
| NACOS_AUTH_CACHE_ENABLE                 | nacos.core.auth.caching.enabled           | default : false                                                                                                                                                                       |
| NACOS_AUTH_USER_AGENT_AUTH_WHITE_ENABLE | nacos.core.auth.enable.userAgentAuthWhite | default : false                                                                                                                                                                       |
| NACOS_AUTH_IDENTITY_KEY                 | nacos.core.auth.server.identity.key；生产环境必须使用唯一值 | `注意：其默认值从 Nacos 2.2.1 起移除，必须显式设置。`                                                                                                                                                    |
| NACOS_AUTH_IDENTITY_VALUE               | nacos.core.auth.server.identity.value；生产环境必须使用唯一值 | `注意：其默认值从 Nacos 2.2.1 起移除，必须显式设置。`                                                                                                                                                    |
| NACOS_SECURITY_IGNORE_URLS              | nacos.security.ignore.urls                | default : `/,/error,/**/*.css,/**/*.js,/**/*.html,/**/*.map,/**/*.svg,/**/*.png,/**/*.ico,/console-fe/public/**,/v1/auth/**,/v1/console/health/**,/actuator/**,/v1/console/server/**` |
| DB_POOL_CONNECTION_TIMEOUT              | 数据库连接池超时时间，单位为毫秒                          | 默认 : **30000**                                                                                                                                                                        |
| NACOS_CONSOLE_UI_ENABLED                | nacos.console.ui.enabled                  | default : `true`                                                                                                                                                                      |
| NACOS_CORE_PARAM_CHECK_ENABLED          | nacos.core.param.check.enabled            | default : `true`                                                                                                                                                                      |
| NACOS_AUTH_ADMIN_ENABLE                 | 独立控制 nacos.core.auth.admin.enabled     | default : `true`                                                                                                                                                                      |
| NACOS_AUTH_CONSOLE_ENABLE               | 独立控制 nacos.core.auth.console.enabled   | default : `true`                                                                                                                                                                      |                                                                                                                                                                                       |
| NACOS_CONSOLE_PORT                      | nacos.console.port                        | default : `8080`                                                                                                                                                                      |
| NACOS_CONSOLE_CONTEXTPATH               | nacos.console.contextPath                 | default : ``                                                                                                                                                                          |
| NACOS_DEPLOYMENT_TYPE                   | nacos.deployment.type                     | default : `merged` 支持配置 `server` `console`                                                                                                                                            |
| NACOS_EXT_PLUGIN_DIRS                   | 追加到 `loader.path` 的外挂插件或依赖目录              | 使用逗号分隔目录，例如 `/home/nacos/ext-plugins,/home/nacos/ext-libs`                                                                                                                            |

## 高级配置

如果你有很多自定义配置的需求,强烈建议在生产环境对application.properties文件进行挂卷定义，例如挂载到 `/home/nacos/conf/application.properties`。

如果你需要在不重建镜像的情况下加载额外的插件 jar 或依赖 jar，可以把这些目录挂载到容器内，
然后通过 `NACOS_EXT_PLUGIN_DIRS` 追加到 `loader.path`。

举个例子:

```docker
docker run --name nacos-standalone \
  -e MODE=standalone \
  -e NACOS_AUTH_TOKEN=${your_nacos_auth_secret_token} \
  -e NACOS_AUTH_IDENTITY_KEY=${your_nacos_server_identity_key} \
  -e NACOS_AUTH_IDENTITY_VALUE=${your_nacos_server_identity_value} \
  -e NACOS_EXT_PLUGIN_DIRS=/home/nacos/ext-plugins,/home/nacos/ext-libs \
  -v /path/to/plugins:/home/nacos/ext-plugins \
  -v /path/to/libs:/home/nacos/ext-libs \
  -p 8080:8080 \
  -p 8848:8848 \
  -p 9848:9848 \
  -d dherhf/nacos-postgresql:latest
```

这个能力适合插件 jar 和运行时依赖 jar 需要分别挂载的场景。例如 LDAP 部署可以把 LDAP
鉴权插件 jar 放在一个目录，把所需的 `spring-ldap-core` 依赖 jar 放在另一个目录。

## Nacos + Grafana + Prometheus

使用参考：[Nacos monitor-guide](https://nacos.io/zh-cn/docs/monitor-guide.html)

**Note**:  当使用Grafana创建数据源的时候地址必须是: **http://prometheus:9090**
