<#
Script pour importer des utilisateurs dans une Unité Organisationnelle Active Directory depuis un fichier CSV.
- Exemple Domain Name = test.lab.com
- distinguishedName = OU=UsersLAB,DC=test,DC=lab,DC=com
- Exemple Unité Organisationnelle = UsersLAB

Maxime DES TOUCHES - 2025 | https://github.com/elreviae ------------
#>
$CSVFile = "AD_Utilisateurs.csv"

# Vérification si le chemin vers le fichier CSV est valide
# Si le chemin du fichier n'est pas valide, sortie du script.
if ([System.IO.File]::Exists($CSVFile)) {
    Write-Host "Import du CSV..."
    $CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8
} else {
    Write-Host "Le chemin d'accès au fichier spécifié n'est pas valide." -ForegroundColor Red  
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
    $UtilisateurLogin = ($UtilisateurPrenom + "." + $UtilisateurNom).ToLower()

    # Vérifier la présence de l'utilisateur dans l'AD
    if (Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin})
    {
        Write-Host "L'utilisateur $UtilisateurLogin existe déjà dans l'AD." -ForegroundColor Yellow
    }
    else
    {
        New-ADUser -Name "$UtilisateurNom $UtilisateurPrenom" `
                    -DisplayName "$UtilisateurPrenom $UtilisateurNom" `
                    -GivenName $UtilisateurPrenom `
                    -Surname $UtilisateurNom `
                    -SamAccountName $UtilisateurLogin `
                    -UserPrincipalName "$UtilisateurLogin@test.lab.com" `
                    -EmailAddress $UtilisateurEmail `
                    -OfficePhone $UtilisateurTel `
                    -Title $UtilisateurFonction `
                    -Path $UtilisateurOU `
                    -AccountPassword(ConvertTo-SecureString $UtilisateurMDP -AsPlainText -Force) `
                    -ChangePasswordAtLogon $true `
                    -Enabled $true

        Write-Output "Création de l'utilisateur : $UtilisateurLogin ($UtilisateurNom $UtilisateurPrenom)"
    }
}

Write-Host "Script terminé." -ForegroundColor White -BackgroundColor DarkGreen
Read-Host "Appuyez sur Entrée pour quitter."
                                
