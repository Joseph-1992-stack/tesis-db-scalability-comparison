CREATE OR REPLACE SERVER node1_srv
FOREIGN DATA WRAPPER mysql
OPTIONS (
  HOST 'mariadb-node1',
  DATABASE 'remotedb',
  USER 'root',
  PASSWORD 'rootpass',
  PORT 3306
);

CREATE OR REPLACE SERVER node2_srv
FOREIGN DATA WRAPPER mysql
OPTIONS (
  HOST 'mariadb-node2',
  DATABASE 'remotedb',
  USER 'root',
  PASSWORD 'rootpass',
  PORT 3306
);

CREATE OR REPLACE SERVER item_srv
FOREIGN DATA WRAPPER mysql
OPTIONS (
  HOST 'mariadb-item',
  DATABASE 'remotedb',
  USER 'root',
  PASSWORD 'rootpass',
  PORT 3306
);