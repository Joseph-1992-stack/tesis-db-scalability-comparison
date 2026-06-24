# Orchestrator

## Descripción

Esta carpeta contiene la infraestructura utilizada para desplegar las arquitecturas distribuidas evaluadas durante la investigación.

Los entornos se implementan mediante Docker Compose y permiten reproducir los escenarios experimentales utilizados para comparar las técnicas de escalabilidad de PostgreSQL y MariaDB.

Las arquitecturas implementadas son:

* PostgreSQL 17 + Citus + postgres_fdw
* MariaDB 11.4 + Spider Storage Engine

---

## Estructura

```text
orchestrator
│
├── mariadb
│
├── postgres
│
└── README.md
```

Cada subdirectorio contiene todos los recursos necesarios para desplegar la arquitectura correspondiente:

* Definición de contenedores.
* Configuración de bases de datos.
* Scripts de inicialización.
* Definición de nodos distribuidos.
* Configuración de acceso remoto o federado.

---

## Objetivo

Proporcionar entornos distribuidos reproducibles para la ejecución de los experimentos desarrollados durante la investigación.

Las configuraciones definidas en esta carpeta son utilizadas por los scripts de automatización contenidos en:

```text
automation/
```

permitiendo desplegar automáticamente los clústeres, cargar datasets y ejecutar los benchmarks mediante BenchBase.

Esta carpeta constituye la capa de despliegue experimental de la investigación y proporciona los entornos necesarios para la ejecución reproducible de los benchmarks definidos en BenchBase.