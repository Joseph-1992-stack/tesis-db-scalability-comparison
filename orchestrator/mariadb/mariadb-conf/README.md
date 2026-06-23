# MariaDB Configuration Files

## Descripción

Esta carpeta contiene los archivos de configuración utilizados por los distintos componentes de la arquitectura distribuida basada en MariaDB.

---

## Estructura

```text
mariadb-conf
│
├── mariadb-coordinator.cnf
├── mariadb-node.cnf
└── mariadb-remotedb.cnf
```

---

## Archivos de configuración

### mariadb-coordinator.cnf

Configuración utilizada por el coordinador.

Características principales:

* innodb_buffer_pool_size = 512M
* max_connections = 200
---

### mariadb-node.cnf

Configuración utilizada por los nodos distribuidos.

* innodb_buffer_pool_size = 384M
* max_connections = 200
---

### mariadb-remotedb.cnf

Configuración utilizada por la base remota que almacena la tabla:

* innodb_buffer_pool_size = 256M
* max_connections = 100
---

## Objetivo

Centralizar la configuración de los distintos componentes de la arquitectura MariaDB utilizada durante la investigación.

