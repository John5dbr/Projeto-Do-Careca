#!/bin/bash

# Instalando Git
apt install git -y

# Criando Diretórios Necessários
cd
mkdir -p config-apache
mkdir /etc/apache2/
mkdir /etc/apache2/html/

# Criando e Definindo Site
cd /etc/apache2/html/
touch index.html

git clone https://github.com/john5dbr/blasphem-fortze.git

# Criando e Definindo Conteiner Apache2
cd
cd config-apache
touch docker-compose.yml

cat << 'EOF' | tee docker-compose.yml
version: '3.8'

services:
  intranet-app:
    image: httpd:2.4-alpine
    container_name: srv-lnx01-intranet
    restart: always
    ports:
      - "80:80"
    volumes:
      - /etc/apache2/html/blasphem-fortze/:/usr/local/apache2/htdocs/
    
    # 🔐 LIMITAÇÃO DE RECURSOS (Baseado no seu Proxmox de 3 Cores / 6GB RAM)
    deploy:
      resources:
        limits:
          cpus: '1.0'        # Usa no máximo 1 dos seus 3 núcleos de CPU
          memory: 512M       # Limite máximo de RAM para proteger o Proxmox
        reservations:
          memory: 128M       # Garante 128MB dedicados logo na inicialização

    # 🌐 CONEXÃO COM A REDE EXTERNA
    networks:
      - rede_corporativa

networks:
  rede_corporativa:
    external: true
    name: rede-servicos      # Vincula o container à rede unificada do seu checklist
EOF

docker compose up -d

cd

echo "Script Finalizado!"