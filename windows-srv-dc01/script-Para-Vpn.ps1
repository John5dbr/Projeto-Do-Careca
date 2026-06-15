# Garante que o script roda com codificação UTF8 para exibir acentos corretamente
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "Baixando e Ativando o SSH"
# No Windows, o SSH é um recurso nativo (Optional Feature). Não precisamos baixar da internet.
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0 -ErrorAction SilentlyContinue
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction SilentlyContinue

# Inicia o serviço do Servidor SSH e define para iniciar automaticamente com o Windows
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
Write-Output "=================="

Write-Output "Baixando Tailscale, Curl e Wget"
# Usando o Winget (Gerenciador de pacotes nativo do Windows) para instalar as ferramentas
# O cURL já vem nativo no Windows moderno. O figlet não existe nativamente, usamos texto grande adaptado.
winget install Tailscale.Tailscale --silent --accept-source-agreements --accept-package-agreements
winget install GNU.Wget --silent --accept-source-agreements --accept-package-agreements

# Aguarda 5 segundos para garantir que o serviço do Tailscale subiu após a instalação
Start-Sleep -Seconds 5
Write-Output "=================="

Write-Output "Atribuindo computador à VPN"
Write-Output "Acessar site do Tailscale com conta da Nier:Control"

# No Windows, o Tailscale não gerencia o SSH da mesma forma que no Linux (--ssh),
# pois o OpenSSH do Windows roda de forma independente. O comando abaixo inicia o login.
& "C:\Program Files\Tailscale\tailscale.exe" up
Write-Output "=================="

# Simulando o efeito do 'figlet' com caracteres de texto normais
Write-Output "######################################"
Write-Output "#         EXECUCAO CONCLUIDA         #"
Write-Output "######################################"
Write-Output ""
Write-Output "Exemplo de comando para acesso remoto: ssh Usuario@Ip-Do-Servidor-Windows"