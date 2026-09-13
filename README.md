# Nacos Docker (PostgreSQL)

![Docker Pulls](https://img.shields.io/docker/pulls/dherhf/nacos-postgresql.svg?maxAge=60480)

This project is a PostgreSQL customized fork of [nacos-docker](https://github.com/nacos-group/nacos-docker). It contains a Docker image meant to facilitate the deployment of [Nacos](https://github.com/alibaba/nacos) with PostgreSQL as the datasource, published as `dherhf/nacos-postgresql`.

[**中文**](README_ZH.md)

## Note

The following environment variables have been **removed** from the default values in the new version(**Nacos 2.2.1**)
for the sake of **system security**, please add them yourself when starting up, otherwise an error will be reported at
startup.

1. ~~NACOS_AUTH_IDENTITY_KEY~~
2. ~~NACOS_AUTH_IDENTITY_VALUE~~
3. ~~NACOS_AUTH_TOKEN~~

Starting with Nacos 3.3, Client API authentication (`nacos.core.auth.enabled`) is enabled by default when
`NACOS_AUTH_ENABLE` is unset. Set `NACOS_AUTH_ENABLE=true` or `NACOS_AUTH_ENABLE=false` to override it explicitly.
Explicit `false` is available as a temporary upgrade-compatibility option while clients are being configured with
credentials. Earlier versioned images continue to use the defaults built into those image versions.

Client API authentication is independent of Admin API and Console API authentication. This default change does not
disable or otherwise change `NACOS_AUTH_ADMIN_ENABLE` or `NACOS_AUTH_CONSOLE_ENABLE`. Use unique, strong token and
server identity values in production; credentials committed in this repository are for local examples only and must
not be reused.

## Project directory

* build：Nacos makes the source code of the docker image
* env: Environment variable file for compose yaml
* example: Docker compose examples for Nacos server with PostgreSQL, including the PostgreSQL schema and its initialization script

## Precautions

* This fork only supports **Nacos 3.x** with **PostgreSQL** as the datasource.
* The PostgreSQL schema must be initialized before Nacos starts for the first time:
  * `example/pg-nacos-init.sh` downloads the schema matching `NACOS_VERSION` into `example/pg-init/pg-schema.sql`
  * `example/pg-init/pg-schema.sql` is committed in this repository and used directly by `standalone-postgresql.yaml`
  * If you use a custom database, initialize
    the [PostgreSQL schema](https://github.com/alibaba/nacos/blob/develop/plugin-default-impl/nacos-default-datasource-plugin/nacos-datasource-plugin-postgresql/src/main/resources/META-INF/pg-schema.sql)
    yourself for the first time.

## Quick Start

### Nacos v3.x with PostgreSQL

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

The PostgreSQL database must be initialized with the Nacos schema first; see `example/pg-init/pg-schema.sql`.

## Advanced Usage

* Tips: You can change [the version of the Nacos image](https://hub.docker.com/r/dherhf/nacos-postgresql/tags) in the compose file from the following configuration. `example/.env`

```dotenv
NACOS_VERSION=v3.2.4
```

Run the following command：

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

* Standalone Independent PostgreSQL（Only Nacos 3.x is supported）

  ```powershell
  cd example
  ./pg-nacos-init.sh && docker-compose -f standalone-independent-postgresql.yaml up
  ```

* Log in (required for Client API requests by default in Nacos 3.3 and later)

  ```powershell
  curl -X POST 'http://127.0.0.1:8848/nacos/v3/auth/user/login' -d 'username=nacos' -d 'password=${your_password}'
  ```

* Service registration

  ```powershell
  curl -X POST 'http://127.0.0.1:8848/nacos/v3/client/ns/instance?serviceName=quickstart.test.service&ip=127.0.0.1&port=8080' -H "accessToken:${your_access_token}"
  ```

* Service discovery

    ```powershell
    curl -X GET 'http://127.0.0.1:8848/nacos/v3/client/ns/instance/list?serviceName=quickstart.test.service' -H "accessToken:${your_access_token}"
    ```

* Publish config

  ```powershell
  curl -X POST 'http://127.0.0.1:8848/nacos/v3/admin/cs/config?dataId=quickstart.test.config&groupName=test&content=HelloWorld' -H "accessToken:${your_access_token}"
  ```

* Get config

  ```powershell
    curl -X GET 'http://127.0.0.1:8848/nacos/v3/client/cs/config?dataId=quickstart.test.config&groupName=test' -H "accessToken:${your_access_token}"
  ```

* Open the Nacos console in your browser

  link：http://127.0.0.1:8080/index.html

## Common property configuration

| name                                    | description                                                                                                                       | option                                                                                                                                                                                |
|-----------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| MODE                                    | cluster/standalone                                                                                                                | cluster/standalone default **cluster**                                                                                                                                                |
| FUNCTION_MODE                           | set mode that Nacos Server function of split                                                                                      | config/naming/microservice/ai/all default **all**                                                                                                                                     |
| NACOS_SERVERS                           | nacos cluster address                                                                                                             | eg. ip1:port1 ip2:port2 ip3:port3                                                                                                                                                     |
| PREFER_HOST_MODE                        | Whether hostname are supported                                                                                                    | hostname/ip default **ip**                                                                                                                                                            |
| NACOS_APPLICATION_PORT                  | nacos server port                                                                                                                 | default **8848**                                                                                                                                                                      |
| NACOS_SERVER_IP                         | custom nacos server ip when network was mutil-network                                                                             |                                                                                                                                                                                       |
| SPRING_DATASOURCE_PLATFORM              | standalone support postgresql                                                                                                     | postgresql / empty default **postgresql**                                                                                                                                             |
| POSTGRESQL_SERVICE_HOST                 | postgresql host                                                                                                                   |                                                                                                                                                                                       |
| POSTGRESQL_SERVICE_PORT                 | postgresql database port                                                                                                          | default : **5432**                                                                                                                                                                    |
| POSTGRESQL_SERVICE_DB_NAME              | postgresql database name                                                                                                          | default : **nacos**                                                                                                                                                                   |
| POSTGRESQL_SERVICE_USER                 | username of database                                                                                                              | default : **nacos**                                                                                                                                                                   |
| POSTGRESQL_SERVICE_PASSWORD             | password of database                                                                                                              | default : **nacos**                                                                                                                                                                   |
| POSTGRESQL_DATABASE_NUM                 | It indicates the number of database                                                                                               | default :**1**                                                                                                                                                                        |
| POSTGRESQL_SERVICE_DB_PARAM             | Database url parameter                                                                                                            | default :**tcpKeepAlive=true&reWriteBatchedInserts=true&ApplicationName=nacos_java**                                                                                                  |
| JVM_XMS                                 | -Xms                                                                                                                              | default :1g                                                                                                                                                                           |
| JVM_XMX                                 | -Xmx                                                                                                                              | default :1g                                                                                                                                                                           |
| JVM_XMN                                 | -Xmn                                                                                                                              | default :512m                                                                                                                                                                         |
| JVM_MS                                  | -XX:MetaspaceSize                                                                                                                 | default :128m                                                                                                                                                                         |
| JVM_MMS                                 | -XX:MaxMetaspaceSize                                                                                                              | default :320m                                                                                                                                                                         |
| NACOS_DEBUG                             | enable remote debug                                                                                                               | y/n default :n                                                                                                                                                                        |
| TOMCAT_ACCESSLOG_ENABLED                | server.tomcat.accesslog.enabled                                                                                                   | default :false                                                                                                                                                                        |
| NACOS_AUTH_SYSTEM_TYPE                  | The auth system to use, currently only 'nacos' is supported                                                                       | default :nacos                                                                                                                                                                        |
| NACOS_AUTH_ENABLE                       | Enable Client API authentication; independent of Admin and Console API authentication                                             | Unset uses the image default (`true` for Nacos 3.3+; earlier images keep their built-in default). Explicit `true`/`false` overrides it; use `false` only as a temporary upgrade aid.                                                                  |
| NACOS_AUTH_TOKEN_EXPIRE_SECONDS         | The token expiration in seconds                                                                                                   | default :18000                                                                                                                                                                        |
| NACOS_AUTH_TOKEN                        | Base64-encoded token secret; use a unique production value                                                                        | `Note: Its default value was removed in Nacos 2.2.1, so it must be set explicitly.`                                                                                                   |
| NACOS_AUTH_CACHE_ENABLE                 | Turn on/off caching of auth information. By turning on this switch, the update of auth information would have a 15 seconds delay. | default : false                                                                                                                                                                       |
| MEMBER_LIST                             | Set the cluster list with a configuration file or command-line argument                                                           | eg:192.168.16.101:8847?raft_port=8807,192.168.16.101?raft_port=8808,192.168.16.101:8849?raft_port=8809                                                                                |
| EMBEDDED_STORAGE                        | Use embedded storage in cluster mode without external database                                                                    | `embedded` default : none                                                                                                                                                             |
| NACOS_AUTH_CACHE_ENABLE                 | nacos.core.auth.caching.enabled                                                                                                   | default : false                                                                                                                                                                       |
| NACOS_AUTH_USER_AGENT_AUTH_WHITE_ENABLE | nacos.core.auth.enable.userAgentAuthWhite                                                                                         | default : false                                                                                                                                                                       |
| NACOS_AUTH_IDENTITY_KEY                 | nacos.core.auth.server.identity.key; use a unique production value                                                                | `Note: Its default value was removed in Nacos 2.2.1, so it must be set explicitly.`                                                                                                   |
| NACOS_AUTH_IDENTITY_VALUE               | nacos.core.auth.server.identity.value; use a unique production value                                                              | `Note: Its default value was removed in Nacos 2.2.1, so it must be set explicitly.`                                                                                                   |
| NACOS_SECURITY_IGNORE_URLS              | nacos.security.ignore.urls                                                                                                        | default : `/,/error,/**/*.css,/**/*.js,/**/*.html,/**/*.map,/**/*.svg,/**/*.png,/**/*.ico,/console-fe/public/**,/v1/auth/**,/v1/console/health/**,/actuator/**,/v1/console/server/**` |
| NACOS_CONSOLE_UI_ENABLED                | nacos.console.ui.enabled                                                                                                          | default : `true`                                                                                                                                                                      |
| NACOS_CORE_PARAM_CHECK_ENABLED          | nacos.core.param.check.enabled                                                                                                    | default : `true`                                                                                                                                                                      |
| DB_POOL_CONNECTION_TIMEOUT              | Database connection pool timeout in milliseconds                                                                                  | default : **30000**                                                                                                                                                                   |
| NACOS_CONSOLE_UI_ENABLED                | nacos.console.ui.enabled                                                                                                          | default : `true`                                                                                                                                                                      |
| NACOS_CORE_PARAM_CHECK_ENABLED          | nacos.core.param.check.enabled                                                                                                    | default : `true`                                                                                                                                                                      |
| NACOS_AUTH_ADMIN_ENABLE                 | Independently controls nacos.core.auth.admin.enabled                                                                              | default : `true`                                                                                                                                                                      |
| NACOS_AUTH_CONSOLE_ENABLE               | Independently controls nacos.core.auth.console.enabled                                                                            | default : `true`                                                                                                                                                                      |                                                                                                                                                                                       |
| NACOS_CONSOLE_PORT                      | nacos.console.port                                                                                                                | default : `8080`                                                                                                                                                                      |
| NACOS_CONSOLE_CONTEXTPATH               | nacos.console.contextPath                                                                                                         | default : ``                                                                                                                                                                          |
| NACOS_DEPLOYMENT_TYPE                   | nacos.deployment.type                                                                                                             | default : `merged` support config `server` `console`                                                                                                                                  |
| NACOS_EXT_PLUGIN_DIRS                   | Additional mounted plugin or dependency directories appended to `loader.path`                                                     | comma-separated directories, for example `/home/nacos/ext-plugins,/home/nacos/ext-libs`                                                                                               |

## Advanced configuration

If you have a lot of custom configuration needs, It is highly recommended to mount `application.properties` in
production environment, for example mount it to `/home/nacos/conf/application.properties`.

If you need to load extra plugin jars or dependency jars without rebuilding the image, mount those
directories into the container and append them through `NACOS_EXT_PLUGIN_DIRS`.

For example:

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

This is useful when a plugin jar and its runtime dependency jars need to be mounted separately. For
example, an LDAP deployment can mount the LDAP auth plugin jar in one directory and the required
`spring-ldap-core` dependency jars in another.

## Nacos + Grafana + Prometheus

Usage reference：[Nacos monitor-guide](https://nacos.io/zh-cn/docs/monitor-guide.html)

**Note**:  When Grafana creates a new data source, the data source address must be **http://prometheus:9090**
