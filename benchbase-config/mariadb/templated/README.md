# Templated Workload Configuration

## Descripción

Esta carpeta contiene la configuración del workload `templated` utilizado durante los experimentos ejecutados con BenchBase.

## Estructura

```text
templated
│
├── queries.xml
└── scenarios
    ├── E1_DS100k_T10
    ├── E2_DS100k_T50
    ├── E3_DS100k_T100
    ├── E4_DS500k_T10 
    ├── E5_DS500k_T50
    ├── E6_DS500k_T100
    ├── E7_DS1M_T10
    ├── E7_DS1M_T50
    └── E9_DS1M_T100
```

## queries.xml

Define las transacciones SQL utilizadas por el workload templated.

Las consultas son compartidas por todos los escenarios experimentales de esta arquitectura.

## scenarios

Contiene los archivos config.xml asociados a cada escenario experimental.

Cada carpeta de escenario define principalmente:

* El número de terminales concurrentes.
* Los parámetros de ejecución de BenchBase.

El tamaño del dataset es establecido previamente mediante los scripts de carga de datos.

## Relación con la automatización

Estas configuraciones son consumidas por: `automation/run_benchbase_templated.ps1`, durante la ejecución automática de los experimentos.

## Referencias

La descripción completa del workload y de los escenarios experimentales se encuentra en:

`benchbase-config/README.md`
