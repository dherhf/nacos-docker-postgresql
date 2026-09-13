FROM postgres:16
ADD https://raw.githubusercontent.com/alibaba/nacos/develop/plugin-default-impl/nacos-default-datasource-plugin/nacos-datasource-plugin-postgresql/src/main/resources/META-INF/pg-schema.sql /docker-entrypoint-initdb.d/nacos-pg.sql
RUN chown -R postgres:postgres /docker-entrypoint-initdb.d/nacos-pg.sql
EXPOSE 5432
