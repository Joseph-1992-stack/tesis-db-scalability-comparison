# Comparación de Escalabilidad entre MariaDB Spider y PostgreSQL Citus + FDW

## Descripción

Este repositorio contiene el prototipo experimental desarrollado para la tesis:

Comparación de las técnicas de escalabilidad de las bases de datos entre MariaDB y PostgreSQL.

La investigación evalúa dos arquitecturas distribuidas:

- MariaDB + Spider Storage Engine
- PostgreSQL + Citus + postgres_fdw

## Objetivo

Comparar el comportamiento de ambas arquitecturas distribuidas mediante escenarios controlados utilizando BenchBase.

## Tecnologías utilizadas

- Docker Compose
- MariaDB 11.4
- PostgreSQL 17 + Citus
- Spider Storage Engine
- postgres_fdw
- BenchBase
- PowerShell

## Métricas evaluadas

- TPS (Transactions Per Second)
- Latencia promedio
- Desviación estándar
- Tiempo total de ejecución

## Escenarios experimentales

DS100k:
- T10
- T50
- T100

DS500k:
- T10
- T50
- T100

DS1M:
- T10
- T50
- T100

## Autor

José Luis Quizhpe Paqui
Universidad Técnica Particular de Loja
