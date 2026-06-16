# 1. Importar o módulo do Active Directory
Import-Module ActiveDirectory

# --- CONFIGURAÇÕES GERAIS ---
$Dominio = "DC=3rmcorp,DC=local"
$OU_Users_Nome = "UsersLocal"
$OU_Groups_Nome = "GroupLocal"

$CaminhoOU_Users = "OU=$OU_Users_Nome,$Dominio"
$CaminhoOU_Groups = "OU=$OU_Groups_Nome,$Dominio"

$SenhaTemporaria = "Mudar@Senai2026!"
$SenhaSegura = ConvertTo-SecureString $SenhaTemporaria -AsPlainText -Force

# --- CRIAÇÃO DAS UOS ---
Write-Host "--- Verificando e criando Unidades Organizacionais ---" -ForegroundColor Cyan

foreach ($OU in @($OU_Users_Nome, $OU_Groups_Nome)) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$OU'")) {
        New-ADOrganizationalUnit -Name $OU -Path $Dominio
        Write-Host "OU '$OU' criada com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "OU '$OU' já existe." -ForegroundColor Yellow
    }
}

# --- CRIAÇÃO DOS GRUPOS ---
Write-Host "`n--- Verificando e criando Grupos ---" -ForegroundColor Cyan
$Grupos = @("Ginfraestrurura", "Gconectividade", "Gservicos", "Grelatorio")

foreach ($Grupo in $Grupos) {
    if (-not (Get-ADGroup -Filter "Name -eq '$Grupo'")) {
        New-ADGroup -Name $Grupo -Path $CaminhoOU_Groups -GroupScope Global -GroupCategory Security
        Write-Host "Grupo '$Grupo' criado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Grupo '$Grupo' já existe." -ForegroundColor Yellow
    }
}

# --- ESTRUTURA DE DADOS DOS USUÁRIOS ---
# Mapeamento exato da lista que você enviou
$UsuariosMapeados = @(
    # Ginfraestrurura
    [PSCustomObject]@{ Nome = "Matheus"; Sobrenome = "Antônio Santos"; Grupo = "Ginfraestrurura" },
    [PSCustomObject]@{ Nome = "Paulo"; Sobrenome = "Henrique Servello"; Grupo = "Ginfraestrurura" },
    [PSCustomObject]@{ Nome = "Vitor"; Sobrenome = "Feitosa da Silva Costa"; Grupo = "Ginfraestrurura" },
    [PSCustomObject]@{ Nome = "Vinicius"; Sobrenome = "de Sales Pereira"; Grupo = "Ginfraestrurura" },
    [PSCustomObject]@{ Nome = "Gabriel"; Sobrenome = "Ferreira Morais"; Grupo = "Ginfraestrurura" },
    
    # Gservicos (ajustado para o nome correto criado acima)
    [PSCustomObject]@{ Nome = "Ryan"; Sobrenome = "Santos de Oliveira"; Grupo = "Gservicos" },
    [PSCustomObject]@{ Nome = "Guilherme"; Sobrenome = "da Hora Pereira"; Grupo = "Gservicos" },
    [PSCustomObject]@{ Nome = "Pedro"; Sobrenome = "de Souza Santos"; Grupo = "Gservicos" },
    [PSCustomObject]@{ Nome = "Felipe"; Sobrenome = "Tavares de Moura"; Grupo = "Gservicos" },
    
    # Gconectividade
    [PSCustomObject]@{ Nome = "Henry"; Sobrenome = "de Araújo Fernandez"; Grupo = "Gconectividade" },
    [PSCustomObject]@{ Nome = "Victor"; Sobrenome = "Gabriel Viera Soares"; Grupo = "Gconectividade" },
    [PSCustomObject]@{ Nome = "Miguel"; Sobrenome = "Costa de Souza"; Grupo = "Gconectividade" },
    
    # Grelatorio
    [PSCustomObject]@{ Nome = "Marcos"; Sobrenome = "Benevenuto Silva"; Grupo = "Grelatorio" },
    [PSCustomObject]@{ Nome = "Gabriel"; Sobrenome = "Castro de Oliveira"; Grupo = "Grelatorio" },
    [PSCustomObject]@{ Nome = "Igor"; Sobrenome = "de Freitas Araujo Costa"; Grupo = "Grelatorio" },
    [PSCustomObject]@{ Nome = "Michael"; Sobrenome = "Vitor Gomes"; Grupo = "Grelatorio" },
    [PSCustomObject]@{ Nome = "Arthur"; Sobrenome = "Feitosa da Silva Costa"; Grupo = "Grelatorio" }
)

# --- CRIAÇÃO E ASSOCIAÇÃO DOS USUÁRIOS ---
Write-Host "`n--- Iniciando a criação de usuários e atribuição de grupos ---" -ForegroundColor Cyan

foreach ($u in $UsuariosMapeados) {
    $PrimeiroNome = $u.Nome
    $SobrenomeCompleto = $u.Sobrenome
    $NomeExibicao = "$PrimeiroNome $SobrenomeCompleto"
    $GrupoAlvo = $u.Grupo

    # Define o login inicial padrão (Apenas o primeiro nome, em letras minúsculas)
    $SamAccountName = $PrimeiroNome.ToLower()

    # LÓGICA DE DUPLICIDADE: Verifica se o login padrão já existe no AD
    if (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'") {
        # Se existir, extrai a primeira letra do sobrenome em maiúscula
        $PrimeiraLetraSobrenome = $SobrenomeCompleto.Substring(0,1).ToUpper()
        # Modifica o login para o formato: Nome + PrimeiraLetraSobrenome (Ex: gabrielC)
        $SamAccountName = "$PrimeiroNome$PrimeiraLetraSobrenome"
        
        Write-Host "-> Login duplicado detectado para '$NomeExibicao'. Ajustado para: $SamAccountName" -ForegroundColor Magenta
    }

    $UPN = "$SamAccountName@3rmcorp.local"

    # Criar o usuário caso ele ainda não exista de forma alguma
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'")) {
        New-ADUser -Name $NomeExibicao `
                   -GivenName $PrimeiroNome `
                   -Surname $SobrenomeCompleto `
                   -SamAccountName $SamAccountName `
                   -UserPrincipalName $UPN `
                   -Path $CaminhoOU_Users `
                   -AccountPassword $SenhaSegura `
                   -ChangePasswordAtLogon $true `
                   -Enabled $true
        
        Write-Host "Usuário '$NomeExibicao' ($SamAccountName) criado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Usuário ($SamAccountName) já existe no AD." -ForegroundColor Yellow
    }

    # Adicionar o usuário ao grupo correspondente
    # (O script faz a validação interna para não gerar erro caso ele já seja membro)
    try {
        Add-ADGroupMember -Identity $GrupoAlvo -Members $SamAccountName -ErrorAction Stop
        Write-Host "   [+] Adicionado ao grupo '$GrupoAlvo'" -ForegroundColor Direct
    } catch {
        Write-Host "   [!] Usuário já pertencia ao grupo '$GrupoAlvo' ou ocorreu um erro." -ForegroundColor Yellow
    }
}

Write-Host "`n--- Processo concluído! ---" -ForegroundColor Green