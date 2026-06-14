# 1. Instalar as funções do AD DS e DNS, incluindo as ferramentas de gerenciamento
Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools

# 2. Promover o servidor a Controlador de Domínio (Cria uma nova floresta)
# Nota: O parâmetro -SafeModeAdministratorPassword exige uma senha forte.
Install-ADDSForest `
    -DomainName "3rmcorp.local" `
    -DomainNetbiosName "3rmcorp" `
    -InstallDns:$true `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -NoRebootOnCompletion:$false `
    -Force
