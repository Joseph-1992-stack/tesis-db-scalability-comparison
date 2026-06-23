# PostgreSQL Distributed Architecture

## Descripción

Esta carpeta contiene todos los recursos necesarios para desplegar la arquitectura distribuida basada en:

* PostgreSQL 17
* Citus
* postgres_fdw

La arquitectura implementada permite evaluar simultáneamente mecanismos de distribución horizontal y acceso federado.

---

## Estructura

```text
postgres
│
├── init
│
├── postgres-conf
│
├── docker-compose.yml
│
└── README.md
```

---

## Componentes

### init

Contiene los scripts SQL utilizados para inicializar la arquitectura.

Incluye:

* Creación de la base remota item.
* Creación del esquema TPCC reducido.
* Registro de nodos Citus.
* Configuración de postgres_fdw.
* Distribución de tablas mediante Citus.
* Creación de índices secundarios.

---

### postgres-conf

Contiene la configuración específica de:

* Coordinator.
* Workers.
* Base remota.
* Reglas de acceso mediante pg_hba.conf.

---

### docker-compose.yml

Define el despliegue completo de la arquitectura distribuida.

Incluye:

* postgresql-coord
* postgresql-worker1
* postgresql-worker2
* postgresql-item

---

## Arquitectura implementada

```text
                 postgresql-coord
                /       |         \
               /        |          \
              /         |           \
postgresql-worker1 postgresql-worker2 postgresql-item
```

Las tablas TPCC son distribuidas mediante Citus.

La tabla `item` reside físicamente en una base PostgreSQL independiente y es accedida desde el coordinador mediante `postgres_fdw`.

---

## Equivalencia experimental

La arquitectura fue diseñada para mantener equivalencia metodológica con la arquitectura evaluada en el otro sistema gestor.

Ambas implementaciones utilizan:

* Un nodo coordinador.
* Dos nodos de almacenamiento distribuido.
* Una base de datos remota para acceso federado.
* El mismo esquema TPCC reducido.
* El mismo workload BenchBase.
* Los mismos tamaños de dataset.
* Los mismos niveles de concurrencia.

De esta forma, las diferencias observadas en los resultados pueden atribuirse principalmente a las tecnologías de distribución y federación implementadas por cada sistema gestor.

## Objetivo

Implementar una arquitectura distribuida basada en PostgreSQL, Citus y postgres_fdw que permita evaluar el impacto de la distribución horizontal y del acceso federado bajo condiciones experimentales controladas.
