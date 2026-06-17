# ==============================================================================
# SCRIPT DE CRIAÇÃO AUTOMÁTICA DE GPOs POR FUNÇÃO (CORRIGIDO)
# Requisitos: Executar como Administrador no Controlador de Domínio (AD DC)
# ==============================================================================

# Garante que o módulo de Group Policy está carregado
Import-Module GroupPolicy

Write-Host "--- Iniciando a criação das GPOs institucionais ---" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 1. Restrição de Sistema: Bloquear Painel de Controle e Configurações
# ------------------------------------------------------------------------------
$GpoName1 = "GPO_Restricao_Sistema_PainelControle"
if (-not (Get-GPO -Name $GpoName1 -ErrorAction SilentlyContinue)) {
    New-GPO -Name $GpoName1 -Comment "Bloqueia o acesso ao Painel de Controle e Configurações para usuários comuns."
    Set-GPRegistryValue -Name $GpoName1 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1
    Write-Host "[OK] GPO criada: $GpoName1" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 2. Prevenção de Vazamento (DLP): Bloquear Armazenamento Removível (USB)
# ------------------------------------------------------------------------------
$GpoName2 = "GPO_DLP_Bloqueio_USB"
if (-not (Get-GPO -Name $GpoName2 -ErrorAction SilentlyContinue)) {
    New-GPO -Name $GpoName2 -Comment "Bloqueia a leitura e escrita em dispositivos de armazenamento removíveis (USB/Pendrives)."
    Set-GPRegistryValue -Name $GpoName2 -Key "HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices" -ValueName "Deny_All" -Type DWord -Value 1
    Write-Host "[OK] GPO criada: $GpoName2" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 3. Padronização Visual: Papel de Parede Institucional Fixo
# ------------------------------------------------------------------------------
$GpoName3 = "GPO_Visual_Wallpaper_Institucional"
if (-not (Get-GPO -Name $GpoName3 -ErrorAction SilentlyContinue)) {
    New-GPO -Name $GpoName3 -Comment "Define o papel de parede padrão da empresa (Ajuste o caminho do JPG conforme necessário)."
    $WallpaperPath = "\\3rmcorp.local\NETLOGON\wallpaper.jpg"
    Set-GPRegistryValue -Name $GpoName3 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "Wallpaper" -Type String -Value $WallpaperPath
    Set-GPRegistryValue -Name $GpoName3 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "WallpaperStyle" -Type String -Value "4"
    Write-Host "[OK] GPO criada: $GpoName3" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 4. Segurança de Execução: Impedir acesso ao Prompt de Comando (CMD)
# ------------------------------------------------------------------------------
$GpoName4 = "GPO_Seguranca_Bloqueio_CMD"
if (-not (Get-GPO -Name $GpoName4 -ErrorAction SilentlyContinue)) {
    New-GPO -Name $GpoName4 -Comment "Desativa o Prompt de Comando (CMD) interativo para o usuário."
    Set-GPRegistryValue -Name $GpoName4 -Key "HKCU\Software\Policies\Microsoft\Windows\System" -ValueName "DisableCMD" -Type DWord -Value 1
    Write-Host "[OK] GPO criada: $GpoName4" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 5. Produtividade: Mapeamento de Unidade de Rede (Z:)
# ------------------------------------------------------------------------------
$GpoName5 = "GPO_Produtividade_Mapeamento_Z"
if (-not (Get-GPO -Name $GpoName5 -ErrorAction SilentlyContinue)) {
    New-GPO -Name $GpoName5 -Comment "Mapeia automaticamente a unidade Z: apontando para o compartilhamento público."
    $NetworkPath = "\\SRV-FILES\Publico"
    Set-GPRegistryValue -Name $GpoName5 -Key "HKCU\Network\Z" -ValueName "RemotePath" -Type String -Value $NetworkPath
    Set-GPRegistryValue -Name $GpoName5 -Key "HKCU\Network\Z" -ValueName "ConnectionType" -Type DWord -Value 1
    Set-GPRegistryValue -Name $GpoName5 -Key "HKCU\Network\Z" -ValueName "ProviderName" -Type String -Value "Microsoft Windows Network"
    Write-Host "[OK] GPO criada: $GpoName5" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 6. Controle de Software: Bloqueio de Execução (.exe) - Base AppLocker
# ------------------------------------------------------------------------------
$GpoName6 = "GPO_Controle_Software_AppLocker"
if (-not (Get-GPO -Name $GpoName6 -ErrorAction SilentlyContinue)) {
    New-GPO -Name $GpoName6 -Comment "Cria a estrutura base para controle de execução de softwares."
    Set-GPRegistryValue -Name $GpoName6 -Key "HKLM\SYSTEM\CurrentControlSet\Services\AppIDSvc" -ValueName "Start" -Type DWord -Value 2
    Write-Host "[OK] GPO criada: $GpoName6" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 7. Segurança Física: Bloqueio de Tela por Inatividade (5 Minutos)
# ------------------------------------------------------------------------------
$GpoName7 = "GPO_Seguranca_Bloqueio_Tela_Inatividade"
if (-not (Get-GPO -Name $GpoName7 -ErrorAction SilentlyContinue)) {
    New-GPO -Name $GpoName7 -Comment "Força a ativação da proteção de tela com senha após 5 minutos (300 segundos) de inatividade."
    $ScreenSaverPath = "C:\Windows\System32\scrnsave.scr"
    Set-GPRegistryValue -Name $GpoName7 -Key "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop" -ValueName "ScreenSaveActive" -Type String -Value "1"
    Set-GPRegistryValue -Name $GpoName7 -Key "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop" -ValueName "ScreenSaverIsSecure" -Type String -Value "1"
    Set-GPRegistryValue -Name $GpoName7 -Key "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop" -ValueName "ScreenSaveTimeOut" -Type String -Value "300"
    Set-GPRegistryValue -Name $GpoName7 -Key "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop" -ValueName "SCRNSAVE.EXE" -Type String -Value $ScreenSaverPath
    Write-Host "[OK] GPO criada: $GpoName7" -ForegroundColor Green
}

Write-Host "--- Processo concluído sem erros! ---" -ForegroundColor Cyan