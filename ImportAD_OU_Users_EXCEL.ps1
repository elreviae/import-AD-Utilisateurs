<#
Script permettant d'importer des utilisateurs dans une unité organisationnelle Active Directory à partir d'un fichier CSV.
Maxime DES TOUCHES - Update 06/2026 | https://github.com/elreviae ------------
#>

# Activer l'encodage Cyrillic uniquement si le script est exécuté sous PowerShell 7+
if ($PSVersionTable.PSVersion.Major -ge 7) {
    Invoke-Expression "[System.Text.Encoding]::RegisterProvider([System.Text.CodePagesEncodingProvider]::Instance)"
}

# Vérification si lancement du script avec privilèges Administrateur. 
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host "ERREUR : Ce script doit être exécuté en tant qu'Administrateur." -ForegroundColor Red
    Read-Host "Appuyez sur Entrée pour quitter."
    Exit
}

# Vérification module ImportExcel
Write-Host "Vérification du module d'import Excel..." -ForegroundColor DarkYellow
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Host "Le module ImportExcel n'est pas installé sur ce poste." -ForegroundColor Yellow
    Write-Host "Tentative d'installation/activation via Install-Module ImportExcel" -ForegroundColor Gray
    try {
        Install-Module -Name ImportExcel -ErrorAction Stop
        Write-Host "Module ImportExcel installé." -ForegroundColor Green
    }
    catch {
        Write-Host "ERREUR : Impossible de charger le module ImportExcel." -ForegroundColor Red
        Write-Host "Voir documentation en ligne : https://www.powershellgallery.com/packages/ImportExcel/7.8.10." -ForegroundColor Yellow
        Read-Host "Appuyez sur Entrée pour quitter."
        Exit
    }
} else {
    # Si le module est dispo mais pas encore chargé en mémoire
    if (-not (Get-Module -Name ImportExcel)) {
        Import-Module ImportExcel
    }
    Write-Host "Module ImportExcel opérationnel." -ForegroundColor Green
}

# Vérification module Active Directory
Write-Host "Vérification du module Active Directory..." -ForegroundColor White
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "Le module Active Directory n'est pas installé sur ce poste." -ForegroundColor Yellow
    Write-Host "Tentative d'installation/activation via Import-Module AD" -ForegroundColor Gray
    try {
        Import-Module ActiveDirectory -ErrorAction Stop
        Write-Host "Module Active Directory installé." -ForegroundColor Green
    }
    catch {
        Write-Host "ERREUR : Impossible de charger le module Active Directory." -ForegroundColor Red
        Write-Host "Veuillez installer les outils RSAT AD sur votre poste." -ForegroundColor Yellow
        Read-Host "Appuyez sur Entrée pour quitter."
        Exit
    }
} else {
    # Si le module est dispo mais pas encore chargé en mémoire
    if (-not (Get-Module -Name ActiveDirectory)) {
        Import-Module ActiveDirectory
    }
    Write-Host "Module Active Directory opérationnel." -ForegroundColor Green
}

# Récupération dynamique du nom DNS du domaine actuel
try {
    $DomainFQDN = (Get-ADDomain).DNSRoot
    Write-Host "Connecté avec succès au domaine : $DomainFQDN" -ForegroundColor Green
}
catch {
    Write-Host "ERREUR : Impossible de joindre le contrôleur de domaine AD." -ForegroundColor Red
    Write-Host "Vérifiez la connexion au réseau entreprise." -ForegroundColor Yellow
    Read-Host "Appuyez sur Entrée pour quitter."
    Exit
}


# Timestamp pour le nom du fichier log
$timeStamp = $(Get-Date -format dd-MM-yyyy-HHmm)
# Chemin fichier de log. "$PSScriptRoot" pointe vers le répertoire du script
$logFile = "$PSScriptRoot\ImportUserADLog_$timeStamp.txt" 

$EXCELFile = "ImportAD_OU_Users_EXCEL.xlsx"

# Vérification si le chemin vers le fichier EXCEL est valide
# Si le chemin du fichier n'est pas valide, sortie du script.
if ([System.IO.File]::Exists($EXCELFile)) {
    Write-Host "Import fichier EXCEL..." -ForegroundColor Green 
    $EXCELData = Import-Excel -Path $EXCELFile
} else {
    Write-Host "Chemin vers fichier Excel non valide." -ForegroundColor Red  
    Exit
}

# Utilisation de transcript pour capturer les événements dans le fichier de log
Start-Transcript -Path $logFile

Foreach($Utilisateur in $EXCELData){

    $UtilisateurPrenom = $Utilisateur.Prenom
    $UtilisateurNom = ($Utilisateur.Nom).ToUpper()
    $UtilisateurFonction = $Utilisateur.Fonction
    $UtilisateurTel = $Utilisateur.'Telephone Bureau'
    $UtilisateurEmail = $Utilisateur.Email
    $UtilisateurOU = $Utilisateur.OU

    # VÉRIFICATION DE L'EXISTENCE DE L'OU DANS L'AD
    # On vérifie si la colonne OU du fichier est vide ou remplie d'espaces
    if ([string]::IsNullOrWhiteSpace($UtilisateurOU)) {
        Write-Host "ERREUR : La colonne OU est vide dans le fichier pour l'utilisateur $UtilisateurLogin." -ForegroundColor Red
        Write-Host "Passage à l'utilisateur suivant." -ForegroundColor Yellow
        continue # On arrête là pour cet utilisateur et on passe au suivant
    }

    # Si la colonne OU n'est pas vide, on teste son existence réelle dans l'AD
    $OUCheck = $null
    try {
        $OUCheck = Get-ADOrganizationalUnit -Identity $UtilisateurOU -ErrorAction Stop
    }
    catch {
        Write-Host "ERREUR : L'unité organisationnelle n'existe pas dans l'AD : $UtilisateurOU" -ForegroundColor Red
        Write-Host "Passage à l'utilisateur suivant." -ForegroundColor Yellow
        continue
    }
    # ---------------------------------------------------

    $UtilisateurMDP = $Utilisateur.MDP
    # --- BLOC DE NETTOYAGE DES ACCENTS POUR LE LOGIN ---
    $LoginClean = ($UtilisateurPrenom + "." + $UtilisateurNom).ToLower()
    # On remplace les accents.
    $LoginClean = [System.Text.Encoding]::ASCII.GetString([System.Text.Encoding]::GetEncoding("Cyrillic").GetBytes($LoginClean))
    # On supprime les espaces restants.
    $UtilisateurLogin = $LoginClean -replace " ", ""
    # ---------------------------------------------------
    # Vérifier la présence de l'utilisateur dans l'AD
    if (Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin})
    {
        Write-Host "L'utilisateur $UtilisateurLogin existe dans l'AD." -ForegroundColor Red
    }
    else
    {
        New-ADUser -Name "$UtilisateurNom $UtilisateurPrenom" `
                    -DisplayName "$UtilisateurPrenom $UtilisateurNom" `
                    -GivenName $UtilisateurPrenom `
                    -Surname $UtilisateurNom `
                    -SamAccountName $UtilisateurLogin `
                    -UserPrincipalName "$UtilisateurLogin@$DomainFQDN" `
                    -EmailAddress $UtilisateurEmail `
                    -OfficePhone $UtilisateurTel `
                    -Title $UtilisateurFonction `
                    -Path $UtilisateurOU `
                    -AccountPassword(ConvertTo-SecureString $UtilisateurMDP -AsPlainText -Force) `
                    -ChangePasswordAtLogon $true `
                    -Enabled $true

        Write-Host "Ajout utilisateur : $UtilisateurLogin ($UtilisateurNom $UtilisateurPrenom)" -ForegroundColor Green
    }
}

Stop-Transcript

Write-Host "--> Fin de script <--" -ForegroundColor Black -BackgroundColor DarkYellow
Read-Host "Appuyez sur Entree pour quitter."