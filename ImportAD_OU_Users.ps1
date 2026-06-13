<#
Script permettant d'importer des utilisateurs dans une unité organisationnelle Active Directory à partir d'un fichier CSV.
Maxime DES TOUCHES - Update 06/2026 | https://github.com/elreviae ------------
#>
$CSVFile = "ImportAD_OU_Users.csv"

# Récupération dynamique du nom DNS du domaine actuel
$DomainFQDN = (Get-ADDomain).DNSRoot

# Vérification si le chemin vers le fichier CSV est valide
# Si le chemin du fichier n'est pas valide, sortie du script.
if ([System.IO.File]::Exists($CSVFile)) {
    Write-Host "Import fichier CSV..." -ForegroundColor Green 
    $CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8
} else {
    Write-Host "Chemin vers fichier CSV non valide." -ForegroundColor Red  
    Exit
}

Foreach($Utilisateur in $CSVData){

    $UtilisateurPrenom = $Utilisateur.Prenom
    $UtilisateurNom = ($Utilisateur.Nom).ToUpper()
    $UtilisateurFonction = $Utilisateur.Fonction
    $UtilisateurTel = $Utilisateur.'Telephone Bureau'
    $UtilisateurEmail = $Utilisateur.Email
    $UtilisateurOU = $Utilisateur.OU
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

Write-Host "--> Fin de script <--" -ForegroundColor White -BackgroundColor DarkGray
Read-Host "Appuyez sur Entree pour quitter."