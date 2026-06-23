# MariaDB Distributed Architecture

## Descripción

Esta carpeta contiene todos los recursos necesarios para desplegar la arquitectura distribuida basada en:

* MariaDB 11.4
* Spider Storage Engine

La arquitectura implementada se utiliza para evaluar mecanismos de distribución y acceso remoto mediante Spider.

---

## Estructura

```text
mariadb
│
├── coord-image
│
├── init
│
├── mariadb-conf
│
├── docker-compose.yml
│
└── README.md
```

---

## Componentes

### coord-image

Contiene la definición de la imagen personalizada utilizada por el coordinador.

Incluye:

* Dockerfile
* Configuración de carga automática del plugin Spider

La imagen generada se utiliza para construir:

```text
mariadb-spider:11.4
```

---

### init

Contiene los scripts SQL utilizados para inicializar la arquitectura.

Incluye:

* Creación de la base remota item.
* Creación de tablas físicas en los nodos.
* Instalación de Spider.
* Definición de servidores Spider.
* Creación de tablas lógicas Spider.
* Creación de índices secundarios.

---

### mariadb-conf

Contiene la configuración específica de cada tipo de nodo:

* Coordinador.
* Nodos distribuidos.
* Base remota.

---

### docker-compose.yml

Define el despliegue completo de la arquitectura distribuida.

Incluye:

* mariadb-coord
* mariadb-node1
* mariadb-node2
* mariadb-item

---

## Arquitectura implementada

```text
                    mariadb-coord
                  /      |       \
                 /       |        \
                /        |         \
     mariadb-node1  mariadb-node2  mariadb-item
```

Las tablas distribuidas son accedidas mediante Spider Storage Engine.

La tabla `item` reside físicamente en una base remota independiente y es consultada a través de Spider.

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

Implementar una arquitectura distribuida basada en MariaDB y Spider que permita evaluar el comportamiento de escalabilidad y acceso remoto bajo condiciones experimentales controladas.


