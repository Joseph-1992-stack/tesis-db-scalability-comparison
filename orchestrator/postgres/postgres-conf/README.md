# PostgreSQL Configuration Files

## Descripción

Esta carpeta contiene los archivos de configuración utilizados por los distintos componentes de la arquitectura basada en PostgreSQL, Citus y postgres_fdw.

---

## Estructura

```text
postgres-conf
│
├── pg_hba.conf
├── postgresql-coordinator.conf
├── postgresql-worker.conf
└── postgresql-remotedb.conf
```

---

## Archivos de configuración

### pg_hba.conf

Define las reglas de autenticación y acceso utilizadas por los contenedores del entorno experimental.

Permite la comunicación entre los componentes desplegados dentro de la red Docker utilizada por la investigación.

---

### postgresql-coordinator.conf

Configuración utilizada por el coordinador Citus.

Incluye parámetros relacionados con:

* Memoria.
* Conexiones.
* Paralelismo.
* Configuración específica de Citus.

---

### postgresql-worker.conf

Configuración utilizada por los workers Citus.

Optimizada para el procesamiento distribuido y almacenamiento de shards.

---

### postgresql-remotedb.conf

Configuración utilizada por la base de datos remota que almacena físicamente la tabla:

```text
tpcc.item
```

utilizada por postgres_fdw.

---

## Objetivo

Centralizar la configuración de los distintos componentes PostgreSQL utilizados durante los experimentos desarrollados en la investigación.
