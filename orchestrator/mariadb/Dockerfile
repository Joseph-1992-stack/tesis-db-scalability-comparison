FROM mariadb:11.4

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends mariadb-plugin-spider \
    && rm -rf /var/lib/apt/lists/*

USER mysql
