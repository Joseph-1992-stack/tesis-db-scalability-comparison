# Databases

## Descripción

Esta carpeta contiene archivos auxiliares relacionados con la parametrización de los datasets utilizados durante los experimentos.

Actualmente, el archivo principal de esta carpeta es:

```text
databases/postgres/loader/tpcc_params.ps1
```

Aunque actualmente se encuentra dentro de la ruta `postgres`, este archivo es utilizado por los procesos de carga de datos de PostgreSQL y MariaDB.

---

## Estructura

```text
databases
│
├── mariadb
│   └── README.md
│
├── postgres
│   ├── loader
│   │   └── tpcc_params.ps1
│   └── README.md
│
└── README.md
```

---

## Archivo principal

### tpcc_params.ps1

Este script centraliza la definición de las escalas utilizadas durante los experimentos.

Actualmente se encuentran definidas las siguientes escalas:

| Escala | Warehouses | Districts por Warehouse | Customers por District | Items  |
| ------ | ---------- | ----------------------- | ---------------------- | ------ |
| ds100k | 1          | 10                      | 3000                   | 100000 |
| ds500k | 5          | 10                      | 3000                   | 100000 |
| ds1m   | 10         | 10                      | 3000                   | 100000 |

Estas configuraciones son utilizadas por los scripts de carga de PostgreSQL y MariaDB para garantizar equivalencia experimental entre ambas arquitecturas.

---

## Relación con la automatización

Las escalas definidas en `tpcc_params.ps1` son consumidas por:

* `automation/dataset-loader/postgres_load_tpcc.ps1`
* `automation/dataset-loader/mariadb_load_tpcc.ps1`

De esta forma, ambos gestores generan datasets equivalentes para cada escenario experimental.

---

## Observación

La ubicación actual de `tpcc_params.ps1` responde a una decisión histórica del desarrollo del prototipo experimental.

Aunque actualmente se encuentra dentro de la ruta:

```text
databases/postgres/loader
```

su función es compartida por PostgreSQL y MariaDB.

En futuras versiones del repositorio podría migrarse a una carpeta común para ambos gestores, manteniendo la compatibilidad con los scripts de automatización correspondientes.

---

## Objetivo

Centralizar la parametrización de los datasets experimentales utilizados durante la investigación, garantizando consistencia, reproducibilidad y equivalencia metodológica en la generación de datos para ambos gestores.
