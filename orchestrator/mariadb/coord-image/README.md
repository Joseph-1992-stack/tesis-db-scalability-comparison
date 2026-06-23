# Coordinator Image

## Descripción

Esta carpeta contiene la definición de la imagen personalizada utilizada por el coordinador de la arquitectura distribuida basada en MariaDB.

La imagen se construye a partir de MariaDB 11.4 e incorpora el soporte necesario para utilizar Spider Storage Engine.

---

## Estructura

```text
coord-image
│
├── Dockerfile
│
└── conf
    └── 50-spider.cnf
```

---

## Componentes

### Dockerfile

Define la construcción de la imagen personalizada utilizada por el contenedor coordinador.

Durante el proceso de construcción se instala el paquete:

```text
mariadb-plugin-spider
```

permitiendo habilitar el motor Spider dentro de MariaDB.

La imagen resultante es utilizada por Docker Compose como:

```text
mariadb-spider:11.4
```

### 50-spider.cnf

Configura la carga automática del plugin Spider durante el arranque del servidor MariaDB.

```text
plugin_load_add=ha_spider
```

De esta forma, el coordinador puede crear tablas Spider y definir servidores remotos sin requerir configuración manual adicional.

---

## Objetivo

Proporcionar una imagen reproducible del coordinador MariaDB con soporte integrado para Spider Storage Engine, utilizada durante la ejecución de los experimentos de la investigación.
