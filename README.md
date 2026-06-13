# 🚀 Importation Automatisée d'Utilisateurs Active Directory via PowerShell

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%20%7C%20%207.x-blue?style=for-the-badge&logo=powershell&logoColor=white)](https://microsoft.com/powershell)
[![Windows Server](https://img.shields.io/badge/Windows%20Server-2019%20%20%7C%20%202022%20%20%7C%20%202025-0078D4?style=for-the-badge&logo=windows&logoColor=white)](https://microsoft.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Ce script PowerShell permet d'automatiser l'importation de masse d'utilisateurs dans un annuaire **Active Directory (AD DS)** à partir d'un fichier d'entrée au format CSV. 

Conçu pour être agile et réutilisable en entreprise ou en environnement de Home Lab (TSSR), le script détecte **dynamiquement** le domaine sur lequel il est exécuté afin de générer correctement les User Principal Names (UPN), sans aucune modification manuelle du code.

---

## ✨ Fonctionnalités

* 📁 **Lecture de fichier structuré :** Importation propre via un fichier CSV délimité par des points-virgules (`;`).
* 🔤 **Gestion des accents français :** Support complet de l'encodage UTF-8 (console et objets AD) pour éviter les corruptions de caractères.
* 🛡️ **Sécurisation des mots de passe :** Conversion transparente du mot de passe en chaîne sécurisée (`SecureString`).
* 🔄 **Changement de mot de passe requis :** Force l'utilisateur à redéfinir son mot de passe lors de sa première ouverture de session (`-ChangePasswordAtLogon $true`).
* 🌐 **Détection dynamique du domaine :** Utilisation de `Get-ADDomain` pour s'adapter automatiquement à n'importe quel environnement de production ou de test.
* 🚦 **Gestion des doublons :** Vérification de l'existence du `SamAccountName` avant toute tentative de création pour éviter les erreurs de conflits.

---

## 📋 Prérequis

Avant d'exécuter le script, assurez-vous de disposer des éléments suivants :

1. **Rôle AD DS :** Un contrôleur de domaine Windows Server fonctionnel.
2. **Module PowerShell :** Le module `ActiveDirectory` doit être installé (inclus par défaut avec les outils RSAT / Contrôleur de domaine).
3. **Droits d'administration :** Exécuter la console PowerShell en tant qu'**Administrateur** du domaine.
4. **Unités Organisationnelles (OU) :** Les structures cibles (`DistinguishedName` ou `Path`) spécifiées dans votre fichier CSV doivent être préalablement créées dans votre arborescence Active Directory.

---

## 📊 Structure du fichier CSV (`ImportAD_OU_Users.csv`)

Le fichier de données doit être encodé impérativement en **CSV UTF-8** et utiliser les entêtes suivantes :

```csv
Prenom;Nom;Fonction;Telephone Bureau;Email;OU;MDP
Raymond;Renaud;Comptable;104;raymond.renaud@company.com;OU=Compta,OU=SERVICES,DC=home,DC=com;P@ssw0rd
Sarah;Guillot;Comptable Clients;122;sarah.guillot@company.com;OU=Compta,OU=SERVICES,DC=home,DC=com;P@ssw0rd
Julien;Barbier;Comptable Unique;111;julien.barbier@company.com;OU=Compta,OU=SERVICES,DC=home,DC=com;P@ssw0rd
Léa;Rousseau;Contrôleur de Gestion;116;lea.rousseau@company.com;OU=Compta,OU=SERVICES,DC=home,DC=com;P@ssw0rd