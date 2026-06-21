# Active Directory Bulk User Import (CSV & Excel)

🤖 **Scripts d'automatisation pour la gestion des utilisateurs Active Directory**

---

🤖 **Automation scripts for managing Active Directory users**

---

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%20%7C%20%207.x-blue?style=for-the-badge&logo=powershell&logoColor=white)](https://microsoft.com/powershell)
[![Windows Server](https://img.shields.io/badge/Windows%20Server-2019%20%20%7C%20%202022%20%20%7C%20%202025-0078D4?style=for-the-badge&logo=windows&logoColor=white)](https://microsoft.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

---

Ce dépôt contient deux scripts PowerShell conçus pour automatiser et sécuriser l'importation massive d'utilisateurs dans des Unités Organisationnelles (OU) spécifiques à partir d'un fichier source **CSV** ou **Excel**.

## 🚀 Fonctionnalités

- **Double Format** : Prise en charge des fichiers `.csv` (délimiteur `;`) et `.xlsx`.
- **Sécurisé** : Vérification obligatoire des privilèges Administrateur avant exécution.
- **Gestion des Modules** : Vérification automatique et tentative d'installation des modules requis (`ActiveDirectory` et `ImportExcel`).
- **Nettoyage des accents** : Génération des SamAccountName (`prenom.nom`) en minuscules avec suppression complète des accents (via encodage Cyrillic) et des espaces.
- **Robustesse** : Vérification de l'existence préalable de l'utilisateur et de la validité de l'Unité Organisationnelle (OU) dans l'AD avec gestion des erreurs via des blocs `Try/Catch`.
- **Journalisation** : Suivi complet de l'exécution exporté automatiquement dans un fichier de log (`Start-Transcript`).

## 📋 Structure du fichier source (CSV ou Excel)

Le fichier doit impérativement contenir les colonnes suivantes (Exemple):

| Prenom | Nom | Fonction | Telephone Bureau | Email | OU | MDP |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Paul | Aupry | Comptable | 102 | paul.aupry@company.com | OU=Compta,OU=SERVICES,DC=home,DC=com | P@ssw0rd |

> ⚠️ **Important** : La colonne `OU` doit contenir le chemin LDAP complet (*Distinguished Name*) de l'Unité Organisationnelle cible.

## 🛠️ Prérequis
- **Modifier les fichiers sources CSV ou XLSX en fonction de la structure de l'A.D cible.**
- Exécuter PowerShell en tant qu'**Administrateur**.
- Être positionné sur un poste membre du domaine (ou avec une connexion VPN active).
- Outils **RSAT Active Directory** installés (le script tentera de charger le module).
  - https://learn.microsoft.com/fr-fr/troubleshoot/windows-server/system-management-components/remote-server-administration-tools?WT.mc_id=AZ-MVP-5004580

## 💻 Utilisation

1. Placez votre fichier source (`ImportAD_OU_Users_CSV.csv` ou `ImportAD_OU_Users_EXCEL.xlsx`) dans le même dossier que les scripts.
2. Ouvrez une console PowerShell en Administrateur.
3. Lancez le script correspondant à votre besoin :

```powershell
# Pour l'import via fichier CSV
.\ImportAD_OU_Users_CSV.ps1

# Pour l'import via fichier Excel
.\ImportAD_OU_Users_EXCEL.ps1