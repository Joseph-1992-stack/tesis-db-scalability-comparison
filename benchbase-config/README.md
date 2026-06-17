# BenchBase Configuration

## Descripción

Esta carpeta contiene toda la configuración utilizada por BenchBase para ejecutar los experimentos de benchmarking desarrollados en la investigación.

Las configuraciones aquí definidas permiten ejecutar exactamente los mismos workloads sobre las dos arquitecturas evaluadas:

* PostgreSQL 17 + Citus + postgres_fdw
* MariaDB 11.4 + Spider Storage Engine

El objetivo es garantizar que ambos sistemas sean sometidos a condiciones experimentales equivalentes y reproducibles.

---

## Estructura

```text
benchbase-config
│
├── mariadb
│   └── templated
│       ├── queries.xml
│       └── scenarios
│           ├── E1_DS100k_T10
│           ├── E2_DS100k_T50
│           ├── E3_DS100k_T100
│           ├── E4_DS500k_T10
│           ├── E5_DS500k_T50
│           ├── E6_DS500k_T100
│           ├── E7_DS1M_T10
│           ├── E8_DS1M_T50
│           └── E9_DS1M_T100
│
├── postgres
│   └── templated
│       ├── queries.xml
│       └── scenarios
│           ├── E1_DS100k_T10
│           ├── E2_DS100k_T50
│           ├── E3_DS100k_T100
│           ├── E4_DS500k_T10
│           ├── E5_DS500k_T50
│           ├── E6_DS500k_T100
│           ├── E7_DS1M_T10
│           ├── E8_DS1M_T50
│           └── E9_DS1M_T100
│
└── README.md

```
## Workload experimental

La investigación utiliza un workload personalizado basado en BenchBase denominado:

`templated`

Este workload fue diseñado para evaluar simultáneamente:

* Acceso distribuido.
* Acceso federado.
* Operaciones transaccionales concurrentes.

Las transacciones implementadas dentro del workload son:

### ReadJoinItem

Realiza una consulta que involucra:

* customer
* item

En PostgreSQL la tabla item es accedida mediante postgres_fdw.

En MariaDB la tabla item es accedida mediante Spider Storage Engine.

Esta transacción permite evaluar el costo asociado al acceso remoto y federado.

### UpdateStock

Realiza operaciones de actualización sobre:

* stock

Esta transacción permite medir el comportamiento transaccional bajo concurrencia.

## Distribución del workload

La mezcla transaccional utilizada durante todos los experimentos es:

| Transacción | Participación |
|------------|--------------|
| ReadJoinItem | 50 % |
| UpdateStock | 50 % |

## Escenarios experimentales

Los experimentos se organizan en nueve escenarios, obtenidos mediante la combinación de:

* Tres tamaños de dataset.
* Tres niveles de concurrencia.

### Escalas de dataset

| Dataset | Descripción |
|----------|-------------|
| DS100k | Dataset pequeño |
| DS500k | Dataset intermedio |
| DS1M | Dataset grande |

### Niveles de concurrencia

| Nivel de concurrencia | Terminales BenchBase |
|----------------------|---------------------|
| T10 | 10 |
| T50 | 50 |
| T100 | 100 |

La combinación de estas variables produce los nueve escenarios experimentales utilizados durante la investigación.

### Escenarios definidos

| Escenario | Dataset | Terminales |
|-----------|----------|------------|
| E1 | DS100k | T10 |
| E2 | DS100k | T50 |
| E3 | DS100k | T100 |
| E4 | DS500k | T10 |
| E5 | DS500k | T50 |
| E6 | DS500k | T100 |
| E7 | DS1M | T10 |
| E8 | DS1M | T50 |
| E9 | DS1M | T100 |

## Parámetros comunes de ejecución

Todos los escenarios utilizan la misma configuración base:

| Parámetro | Valor |
|------------|--------|
| Warmup | 60 segundos |
| Medición | 300 segundos |
| Batch Size | 128 |
| Isolation Level | SERIALIZABLE |
| Workload Mix | 50 % ReadJoinItem / 50 % UpdateStock |
| Rate Limit | Unlimited |

Esta configuración garantiza comparabilidad entre todos los escenarios experimentales.

## queries.xml

El archivo `queries.xml` define las transacciones ReadJoinItem y UpdateStock utilizadas por el workload `templated`.

Cada arquitectura dispone de su propio archivo `queries.xml` para adaptarse a las diferencias sintácticas entre PostgreSQL y MariaDB, manteniendo la equivalencia funcional de las operaciones ejecutadas.

Contiene la definición de las consultas SQL utilizadas por el workload `templated`. Estas consultas son ejecutadas por BenchBase durante todas las corridas experimentales.

Las consultas son compartidas por todos los escenarios de una misma arquitectura. De esta forma, todos los escenarios ejecutan exactamente el mismo workload, variando únicamente el tamaño del dataset y el nivel de concurrencia definidos experimentalmente.


## config.xml

Cada carpeta de escenario contiene un archivo `config.xml` responsable de definir:

* Tipo de base de datos.
* Driver JDBC.
* Cadena de conexión.
* Número de terminales.
* Parámetros de ejecución.
* Distribución de transacciones.

La configuración base es compartida por todos los escenarios.

Las variables experimentales que cambian entre escenarios son:

* El tamaño del dataset (DS100k, DS500k o DS1M).
* El número de terminales concurrentes (T10, T50 o T100).

Todos los demás parámetros permanecen constantes para garantizar la comparabilidad de los resultados.

## Relación con la automatización

Las configuraciones definidas en esta carpeta son utilizadas directamente por:

* `automation/run_benchbase_templated.ps1`

y son invocadas automáticamente por:

* `automation/postgres/master_postgres.ps1`
* `automation/mariadb/master_mariadb.ps1`

durante la ejecución de los experimentos.

## Equivalencia experimental

Las configuraciones de PostgreSQL y MariaDB fueron diseñadas para mantener equivalencia metodológica entre ambas arquitecturas.

Para cada escenario experimental se conservan constantes:

* El workload ejecutado.
* La mezcla transaccional.
* Los tiempos de warmup y medición.
* El nivel de aislamiento.
* El tamaño del dataset.
* El número de terminales concurrentes.

De esta forma, las diferencias observadas en las métricas obtenidas pueden atribuirse principalmente a las estrategias de escalabilidad implementadas por cada sistema gestor de bases de datos.

## Objetivo

Proporcionar una configuración homogénea, reproducible y controlada para la ejecución de los benchmarks utilizados en la comparación experimental entre PostgreSQL y MariaDB, garantizando la consistencia experimental, la reproducibilidad de las pruebas y la validez metodológica de los resultados obtenidos.
