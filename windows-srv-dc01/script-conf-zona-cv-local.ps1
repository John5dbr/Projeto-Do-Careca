# 1. Criar a zona DNS primária (cv.local) integrada ao Active Directory
Add-DnsServerPrimaryZone -Name "cv.local" -ReplicationScope "Forest"

# 2. Lista de Apelidos (CNAME) a serem registrados
# Defina o Nome (apelido) e o Host de Destino (FQDN completo para onde ele aponta)
$ListaDeCnames = @(
    [PSCustomObject]@{ Nome = "www"; HostDestino = "svrlinux.pesquisa.local" }
    # Você pode descomentar e adicionar mais se precisar:
    # [PSCustomObject]@{ Nome = "webmail"; HostDestino = "svrwindows.3rmcorp.local" }
)

# 3. Algoritmo em Loop para registrar cada CNAME na zona cv.local
foreach ($CnameDns in $ListaDeCnames) {
    Write-Host "Criando CNAME: $($CnameDns.Nome).cv.local -> Apontando para: $($CnameDns.HostDestino)"
    
    # Adiciona o registro do tipo CNAME
    Add-DnsServerResourceRecordCName `
        -ZoneName "cv.local" `
        -Name $CnameDns.Nome `
        -HostNameAlias $CnameDns.HostDestino
}

# 4. Reiniciar o serviço DNS para garantir a aplicação imediata
Write-Host "Reiniciando o serviço DNS..." -ForegroundColor Yellow
Restart-Service -Name DNS -Force

Write-Host "Zona cv.local e registros CNAME criados com sucesso!" -ForegroundColor Green
