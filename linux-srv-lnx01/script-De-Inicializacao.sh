#!/bin/bash

apt install -y curl gpg git wget figlet 

echo "+~~~~~~~~~~~~~~~~~~~~~~~~~~~~+"

echo "Corrigindo Mirror/Reposiórios"

echo "deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware" > /etc/apt/sources.list
echo "deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list
echo "deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list

apt update -y

echo "+~~~~~~~~~~~~~~~~~~~~~~~~~~~~+"

echo "Configurando rede"

cat << 'EOF' | tee /etc/network/interfaces
auto enp0s3
iface enp0s3 inet static
	address 172.16.10.11/24
	gateway 172.16.10.1
EOF

cat << 'EOF' | tee /etc/resolv.conf
nameserver 172.16.10.12
nameserver 8.8.8.8
domain 3rmcorp.local
search pesquisa.local
EOF

chattr +i /etc/resolv.conf

echo "svrLinux" > /etc/hostname

figlet Execucao Concluida
echo "Reinicie o servidor com 'Reboot'"