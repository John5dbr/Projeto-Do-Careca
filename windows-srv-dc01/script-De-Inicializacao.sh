#!/bin/bash

email="";
name="";

 apt install git figlet -y

read -p "Email do usuário no GitHub: " email
git config --global user.email "$email"

read -p "Nome do usuário no GitHub: " name
git config --global user.name "$name"

rm -rf ~/Script-NierControl
git clone https://github.com/John5dbr/NierControl.git ~/Script-NierControl
cd Script-NierControl

echo "Insira seu nome de usuário do GitHub e seu token de acesso registrado"
git push --set-upstream origin main

figlet "Execucao Concluida"

📂 seu-repositorio-infra/
├── 📂 windows-srv-dc01/
│   └── 📜 provisionar-dc.ps1      # Script PowerShell para AD, DHCP, DNS e GPOs
└── 📂 linux-srv-lnx01/
    ├── 📜 integrar-ad.sh          # Script Shell para preparar o Linux e ingressar no AD
    ├── 📜 instalar-docker.sh      # Script Shell que instala o Docker/Compose no Linux físico
    └── 📂 docker-servicos/
        ├── 📜 docker-compose.yml  # Define Nginx, Zabbix e Mail Server
        ├── 📂 nginx-config/       # Arquivos da sua Intranet
        └── 📂 zabbix-config/      # Configurações do monitoramento