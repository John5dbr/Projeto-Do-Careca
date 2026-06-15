# 1. Definir o Nome do Servidor (Hostname)
Write-Output "Alterando o hostname para SvrWindows..."
Rename-Computer -NewName "SvrWindows" -Force

# 2. Identificar a interface de rede ativa conectada
# (Filtra interfaces IPv4 físicas/virtuais ativas para evitar alterar interfaces falsas)
$Interface = Get-NetAdapter | Where-Status -Eq "Up" | Select-Object -First 1

if ($Interface) {
    $Alias = $Interface.Name
    Write-Output "Configurando a interface de rede: $Alias"

    # Remover IP estático anterior ou DHCP se houver
    Remove-NetIPAddress -InterfaceAlias $Alias -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetRoute -InterfaceAlias $Alias -Confirm:$false -ErrorAction SilentlyContinue

    # Configurar Novo IP e Gateway
    New-NetIPAddress -InterfaceAlias $Alias -IPAddress "172.16.10.12" -PrefixLength 24 -DefaultGateway "172.16.10.1"

    # Configurar Servidores DNS (NameServers)
    Set-DnsClientServerAddress -InterfaceAlias $Alias -ServerAddresses ("172.16.10.12", "8.8.8.8")

    # Configurar o Sufixo DNS Primário (Domínio)
    Set-DnsClient -InterfaceAlias $Alias -ConnectionSpecificSuffix "3rmcorp.local"
} else {
    Write-Warning "Nenhuma interface de rede ativa foi encontrada!"
}

# 3. Configurar a Lista de Pesquisa de Sufixos DNS (Search List) no Registro
Write-Output "Configurando a lista de pesquisa DNS (search)..."
$RegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\TCPIP\Parameters"
Set-ItemProperty -Path $RegistryPath -Name "SearchList" -Value "pesquisa.local,3rmcorp.local"

# 4. Reiniciar o Servidor
Write-Output "Configuracao concluida. Reiniciando o servidor em 5 segundos..."
Start-Sleep -Seconds 5
Restart-Computer -Force