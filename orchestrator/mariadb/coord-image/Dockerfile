FROM mariadb:10.11

# A) Cambiar repos de Ubuntu a HTTPS (mi red bloquea HTTP/80)
RUN sed -i 's|http://archive.ubuntu.com/ubuntu|https://archive.ubuntu.com/ubuntu|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu|https://security.ubuntu.com/ubuntu|g' /etc/apt/sources.list

# B) Desactivar el repo de MariaDB que viene en HTTP (archive.mariadb.org:80)
#    No lo necesito para instalar mariadb-plugin-spider (está en repos de Ubuntu).
RUN find /etc/apt/sources.list.d -type f -name "*mariadb*" -print -exec sed -i 's|http://archive.mariadb.org|https://archive.mariadb.org|g' {} \; || true

# C) Instalar certificados (primero con verificación TLS desactivada, solo para poder instalar ca-certificates)
RUN apt-get -o Acquire::https::Verify-Peer=false -o Acquire::https::Verify-Host=false update && \
    apt-get -o Acquire::https::Verify-Peer=false -o Acquire::https::Verify-Host=false install -y --no-install-recommends ca-certificates && \
    update-ca-certificates

# D) Ya con certificados, update normal e instalar Spider
RUN apt-get update && \
    apt-get install -y --no-install-recommends mariadb-plugin-spider && \
    rm -rf /var/lib/apt/lists/*

# E) Copiar configuración Spider
COPY conf/50-spider.cnf /etc/mysql/conf.d/50-spider.cnf