#!/bin/bash
# Script de instalação do Docker no Debian 13 (Trixie)

# Atualiza os índices de pacotes e instala pré-requisitos essenciais
apt-get update 
apt-get install ca-certificates curl

# Cria o diretório para as chaves do repositório de forma segura
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Configura o repositório oficial do Docker para o Debian (Corrigido para sources.list.d)
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  noble stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Atualiza a lista de pacotes incluindo o novo repositório adicionado
apt update

# Instala o Docker Engine, CLI, Containerd e o PLUGIN do Docker Compose
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Inicia e habilita o serviço do Docker para rodar automaticamente no boot
systemctl enable --now docker

docker network create rede-servicos