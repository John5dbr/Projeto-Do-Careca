#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# ======= Instalando Serviços =======

apt install -y samba smbclient winbind libpam-winbind libnss-winbind krb5-user chrony

# ======= Configurando Chrony =======

echo "server 172.16.10.12 iburst" >> /etc/chrony/chrony.conf
systemctl restart chrony
systemctl enable chrony
timedatectl

# ======== Configurando Krb ========

cat << EOF | tee /etc/krb5.conf
[libdefaults]
    default_realm = 3RMCORP.LOCAL
    dns_lookup_realm = false
    dns_lookup_kdc = false

[realms]
    3RMCORP.LOCAL = {
        kdc = 172.16.10.12
        admin_server = 172.16.10.12
    }

[domain_realm]
    .3rmcorp.local = 3RMCORP.LOCAL
    3rmcorp.local = 3RMCORP.LOCAL
EOF

# ======= Criação de Pastas =======

mkdir -p /srv
mkdir -p /srv/samba
mkdir -p /srv/samba/relatorio
mkdir -p /srv/samba/infraestrutura
mkdir -p /srv/samba/servicos
mkdir -p /srv/samba/conectividade

chmod -R 777 /srv/samba/

# ======= Configurando Samba =======

cat << EOF > /etc/samba/smb.conf
[global]
   workgroup = 3RMCORP
   realm = 3RMCORP.LOCAL
   security = ADS
   idmap config * : backend = tdb
   idmap config * : range = 3000-7999
   idmap config 3RMCORP : backend = rid
   idmap config 3RMCORP : range = 10000-999999
   winbind refresh tickets = yes

[Infraestrutura]
   path = /srv/samba/infraestrutura
   valid users = "3RMCORP\Ginfraestrurura"
   writable = yes
   browseable = yes
   max disk size = 51200
   veto files = /*.bat/*.exe/*.mp3/*.zip/*.iso/*.rar/*.msi/*.vbs/
   delete veto files = yes

[Servicos]
   path = /srv/samba/servicos
   valid users = "3RMCORP\Gservicos"
   writable = yes
   browseable = yes
   max disk size = 51200
   veto files = /*.bat/*.exe/*.mp3/*.zip/*.iso/*.rar/*.msi/*.vbs/
   delete veto files = yes

[Conectividade]
   path = /srv/samba/conectividade
   valid users = "3RMCORP\Gconectividade"
   writable = yes
   browseable = yes
   max disk size = 51200
   veto files = /*.bat/*.exe/*.mp3/*.zip/*.iso/*.rar/*.msi/*.vbs/
   delete veto files = yes

[Relatorio]
   path = /srv/samba/relatorio
   valid users = "3RMCORP\Grelatorio"
   writable = yes
   browseable = yes
   max disk size = 51200
   veto files = /*.bat/*.exe/*.mp3/*.zip/*.iso/*.rar/*.msi/*.vbs/
   delete veto files = yes
EOF

# 5. Reiniciar servicos
systemctl restart smbd nmbd winbind
systemctl enable smbd nmbd winbind

# Adicionando svrLinux ao domínio
net ads join -U chefe

figlet "--- Script Concluído! ---"
echo "--- Finalizado ---"