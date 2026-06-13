#!/bin/bash

# Criando Diretórios Necessários para persistência do banco
cd
mkdir -p config-zabbix/
cd config-zabbix
touch docker-compose.yml

# Criando o arquivo docker-compose.yml do Zabbix
cat << 'EOF' | tee docker-compose.yml
version: '3.8'

services:
  # 🗄️ BANCO DE DADOS DO ZABBIX
  zabbix-db:
    image: mariadb:10.11
    container_name: srv-lnx01-zabbix-db
    restart: always
    volumes:
      - ./zabbix_db:/var/lib/mysql
    environment:
      - MYSQL_DATABASE=zabbix
      - MYSQL_USER=zabbix
      - MYSQL_PASSWORD=zabbix_password    
      - MYSQL_ROOT_PASSWORD=root_password  
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: '0.50'                     
          memory: 512M                     
        reservations:
          memory: 256M
    networks:
      - rede_corporativa

  # 🧠 ZABBIX SERVER (O Motor que popula o banco de dados)
  zabbix-server:
    image: zabbix/zabbix-server-mysql:alpine-6.4-latest
    container_name: srv-lnx01-zabbix-server
    restart: always
    environment:
      - DB_SERVER_HOST=zabbix-db
      - MYSQL_DATABASE=zabbix
      - MYSQL_USER=zabbix
      - MYSQL_PASSWORD=zabbix_password
      - MYSQL_ROOT_PASSWORD=root_password
    depends_on:
      zabbix-db:
        condition: service_healthy
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
        reservations:
          memory: 256M
    networks:
      - rede_corporativa

  # 💻 INTERFACE WEB (NGINX)
  zabbix-web:
    image: zabbix/zabbix-web-nginx-mysql:alpine-6.4-latest
    container_name: srv-lnx01-zabbix-web
    restart: always
    ports:
      - "8080:8080"                        
    environment:
      - ZBX_SERVER_HOST=zabbix-server    # 🔍 AJUSTE: Aponta para o container do Server
      - DB_SERVER_HOST=zabbix-db           
      - MYSQL_DATABASE=zabbix
      - MYSQL_USER=zabbix
      - MYSQL_PASSWORD=zabbix_password
      - ZBX_SERVER_NAME=3RMCORP_MONITOR
      - PHP_TZ=America/Sao_Paulo           
    depends_on:
      zabbix-db:
        condition: service_healthy
      zabbix-server:
        condition: service_started       # Aguarda o server iniciar
    deploy:
      resources:
        limits:
          cpus: '0.50'                      
          memory: 512M                    
        reservations:
          memory: 256M
    networks:
      - rede_corporativa

networks:
  rede_corporativa:
    external: true
    name: rede-servicos                
EOF

# Limpa o ambiente anterior para evitar conflitos de cache de tabelas corrompidas
docker compose down -v

# Executa os containers do Zabbix de forma limpa
docker compose up -d

cd
echo "Script Finalizado!"