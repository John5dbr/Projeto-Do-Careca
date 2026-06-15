#!/bin/bash

apt install -y curl gpg git wget figlet 

cat << 'EOF' | tee /etc/network/interfaces
auto nic0
iface nic0 inet manual

iface nic1 inet manual

auto vmbr1
iface vmbr1 inet static
	address 172.16.10.10/24
	gateway 172.16.10.1
    bridge-ports nic0
	bridge-stp off
	bridge-fd 0	
EOF

cat << 'EOF' | tee /etc/resolv.conf
nameserver 172.16.10.12
nameserver 8.8.8.8
domain 3rmcorp.local
search pesquisa.local
EOF

chattr +i /etc/resolv.conf

ifreload -a

figlet Execucao Concluida