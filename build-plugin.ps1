# Ce script compile le plugin Recording Indicator et l'installe dans le dossier des plugins d'Obsidian

# Paramètres
$obsidianPluginsPath = "D:\Notes\.obsidian\plugins\recording-indicator"
$currentDir = (Get-Location).Path
$forceReplace = $true # Toujours remplacer les fichiers existants

# Message de début
Write-Host "Compilation et installation du plugin Recording Indicator" -ForegroundColor Green

# Vérifier que npm est installé
try {
    $npmVersion = npm --version
    Write-Host "npm version: $npmVersion" -ForegroundColor Blue
} catch {
    Write-Host "npm n'est pas installé ou n'est pas dans le PATH. Veuillez installer Node.js et npm." -ForegroundColor Red
    exit 1
}

# Installer les dépendances si nécessaire
if (-not (Test-Path -Path "node_modules")) {
    Write-Host "Installation des dépendances npm..." -ForegroundColor Blue
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Erreur lors de l'installation des dépendances." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Les dépendances npm sont déjà installées." -ForegroundColor Gray
}

# Compiler le plugin
Write-Host "Compilation du plugin..." -ForegroundColor Blue
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors de la compilation du plugin." -ForegroundColor Red
    exit 1
}

# Vérifier que les fichiers compilés existent
$requiredFiles = @("main.js", "manifest.json", "styles.css")
foreach ($file in $requiredFiles) {
    if (-not (Test-Path -Path $file)) {
        Write-Host "Fichier manquant après compilation: $file" -ForegroundColor Red
        exit 1
    }
}

# Vérifier que le dossier des plugins Obsidian existe
if (-not (Test-Path -Path $obsidianPluginsPath)) {
    Write-Host "Création du dossier de plugins Obsidian: $obsidianPluginsPath" -ForegroundColor Blue
    New-Item -ItemType Directory -Path $obsidianPluginsPath -Force | Out-Null
}

# Copier les fichiers du plugin
Write-Host "Installation des fichiers du plugin..." -ForegroundColor Blue

# Copier les fichiers principaux
foreach ($file in $requiredFiles) {
    $sourcePath = Join-Path -Path $currentDir -ChildPath $file
    $destPath = Join-Path -Path $obsidianPluginsPath -ChildPath $file
    
    if (Test-Path -Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "Copié: $file" -ForegroundColor Gray
    } else {
        Write-Host "Fichier source non trouvé: $file" -ForegroundColor Yellow
    }
}

# Vérifier la configuration existante
$dataJsonPath = Join-Path -Path $obsidianPluginsPath -ChildPath "data.json"
$configStatus = "Non configuré"

if (Test-Path -Path $dataJsonPath) {
    try {
        $dataJson = Get-Content -Path $dataJsonPath -Raw | ConvertFrom-Json
        $configStatus = "Configuration existante préservée"
        Write-Host "Configuration existante trouvée et préservée." -ForegroundColor Green
    } catch {
        $configStatus = "Erreur de lecture de la configuration"
        Write-Host "Erreur lors de la lecture de la configuration existante: $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    # Créer une configuration par défaut
    $defaultConfig = @{
        showRecordingTime = $true
        timecodeFormat = "[{time}]"
        autoLinkRecordings = $true
        detectionSensitivity = 5000
        mobileOptimized = $true
    }
    
    try {
        $defaultConfig | ConvertTo-Json | Set-Content -Path $dataJsonPath -Encoding UTF8
        $configStatus = "Configuration par défaut créée"
        Write-Host "Configuration par défaut créée." -ForegroundColor Blue
    } catch {
        $configStatus = "Erreur de création de la configuration"
        Write-Host "Erreur lors de la création de la configuration par défaut: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Vérifier l'installation
$installationSuccess = $true
foreach ($file in $requiredFiles) {
    $destPath = Join-Path -Path $obsidianPluginsPath -ChildPath $file
    if (-not (Test-Path -Path $destPath)) {
        Write-Host "Fichier manquant dans l'installation: $file" -ForegroundColor Red
        $installationSuccess = $false
    }
}

# Afficher les informations sur le plugin
Write-Host "`n=== INFORMATIONS DU PLUGIN ===" -ForegroundColor Cyan
Write-Host "Nom: Recording Indicator" -ForegroundColor White
Write-Host "Version: 1.0.0" -ForegroundColor White
Write-Host "Compatibilité: Windows Desktop, Android, iOS" -ForegroundColor White
Write-Host "Fonctionnalités:" -ForegroundColor White
Write-Host "  • Indicateur d'enregistrement automatique dans la barre de statut" -ForegroundColor Gray
Write-Host "  • Timer en temps réel pendant l'enregistrement" -ForegroundColor Gray
Write-Host "  • Insertion d'horodatages universels (Ctrl+Shift+T)" -ForegroundColor Gray
Write-Host "  • Liens automatiques vers les fichiers d'enregistrement" -ForegroundColor Gray
Write-Host "  • Optimisation mobile pour Android et iOS" -ForegroundColor Gray

# Message de fin
if ($installationSuccess) {
    Write-Host "`n✅ Plugin installé avec succès dans: $obsidianPluginsPath" -ForegroundColor Green
    Write-Host "📁 Fichiers installés: $($requiredFiles -join ', ')" -ForegroundColor Green
    Write-Host "⚙️ Statut de la configuration: $configStatus" -ForegroundColor Cyan
    
    Write-Host "`n🚀 PROCHAINES ÉTAPES:" -ForegroundColor Yellow
    Write-Host "1. Redémarrez Obsidian si nécessaire" -ForegroundColor White
    Write-Host "2. Activez le plugin dans: Paramètres → Plugins communautaires → Recording Indicator" -ForegroundColor White
    Write-Host "3. Configurez le plugin dans: Paramètres → Options du plugin → Recording Indicator" -ForegroundColor White
    Write-Host "`n📝 UTILISATION:" -ForegroundColor Yellow
    Write-Host "• Commencez un enregistrement avec l'icône microphone d'Obsidian" -ForegroundColor White
    Write-Host "• L'indicateur 🔴 REC apparaîtra automatiquement dans la barre de statut" -ForegroundColor White
    Write-Host "• Utilisez Ctrl+Shift+T pour insérer des horodatages pendant vos prises de notes" -ForegroundColor White
    Write-Host "• Cliquez sur l'indicateur pour arrêter l'enregistrement" -ForegroundColor White
} else {
    Write-Host "`n❌ Erreur lors de l'installation du plugin." -ForegroundColor Red
    Write-Host "Vérifiez les erreurs ci-dessus et réessayez." -ForegroundColor Red
    exit 1
} 