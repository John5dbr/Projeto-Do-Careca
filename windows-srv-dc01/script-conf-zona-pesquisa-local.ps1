# 1. Criar a zona DNS primária (pesquisa.local) integrada ao Active Directory
# Nota: Como seu servidor já é um DC, zonas integradas ao AD são o padrão e mais seguras.
Add-DnsServerPrimaryZone -Name "pesquisa.local" -ReplicationScope "Forest"

# 2. Lista de Hosts a serem registrados (Estrutura de Array de Objetos)
# Adicione ou altere os nomes e IPs dentro deste bloco @( )
$ListaDeHosts = @(
    [PSCustomObject]@{ Nome = "svrwindows"; IP = "192.168.0.3" },
    [PSCustomObject]@{ Nome = "svrlinux"; IP = "192.168.0.2" }
)

# 3. Algoritmo em Loop para registrar cada Host na zona criada
# O 'foreach' funciona de forma idêntica ao 'for host in lista' do Bash
foreach ($HostDns in $ListaDeHosts) {
    
    Write-Host "Registrando: $($HostDns.Nome).pesquisa.local apontando para $($HostDns.IP)"
    
    # Adiciona o registro do tipo A (somente IPv4)
    Add-DnsServerResourceRecordA `
        -ZoneName "pesquisa.local" `
        -Name $HostDns.Nome `
        -IPv4Address $HostDns.IP `
        -CreatePtr:$false  # Define como falso se não tiver uma zona reversa criada ainda
}

# 4. Reiniciar o serviço DNS do Windows Server
Write-Host "Reiniciando o serviço DNS para aplicar as alterações..." -ForegroundColor Yellow
Restart-Service -Name DNS -Force

Write-Host "Todos os registros foram criados e o serviço DNS foi reiniciado com sucesso!" -ForegroundColor Green
