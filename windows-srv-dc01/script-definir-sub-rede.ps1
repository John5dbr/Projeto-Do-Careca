# 1. Importar o módulo do Active Directory
Import-Module ActiveDirectory

# --- CONFIGURAÇÕES ---
$SubnetIP = "172.16.10.0/24"
$SiteAlvo = "Default-First-Site-Name" # Nome padrão do primeiro site do AD
$Descricao = "Sub-rede principal da rede 172.16.10.0"

Write-Host "--- Verificando e criando Sub-rede no AD Sites e Serviços ---" -ForegroundColor Cyan

# 2. Verificar se a sub-rede já existe
if (-not (Get-ADReplicationSubnet -Filter "Name -eq '$SubnetIP'")) {
    
    # 3. Criar a sub-rede e vincular ao Site
    New-ADReplicationSubnet -Name $SubnetIP `
                            -Site $SiteAlvo `
                            -Description $Descricao
    
    Write-Host "Sub-rede '$SubnetIP' criada com sucesso e vinculada ao site '$SiteAlvo'!" -ForegroundColor Green
} else {
    Write-Host "A sub-rede '$SubnetIP' já existe no Active Directory." -ForegroundColor Yellow
}