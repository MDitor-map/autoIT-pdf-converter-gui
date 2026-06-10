# AutoIT PDF Converter GUI

Convertisseur et compresseur PDF multiformat avec interface graphique claire développé en **AutoIT**.

## 🎯 Caractéristiques

- ✅ **Support multiformat** : Images (JPG, PNG, BMP, GIF, TIFF), Documents (DOC, DOCX, TXT, ODT), Tableurs (XLS, XLSX, ODS), Présentations (PPT, PPTX, ODP), Web (HTML, HTM, MHTML)
- ✅ **Compression PDF automatique** avec 10 niveaux ajustables
- ✅ **Interface graphique claire** et intuitive
- ✅ **File d'attente** de conversion avec statut en temps réel
- ✅ **Barre de progression** pour suivi des conversions
- ✅ **Gestion des erreurs robuste** avec fallback
- ✅ **Détection automatique** des applications d'installation

## 📋 Prérequis

### Applications requises :

1. **LibreOffice** (recommandé pour documents, tableurs, présentations)
   - Télécharger : https://www.libreoffice.org/download/download/

2. **Ghostscript** (pour compression PDF)
   - Télécharger : https://www.ghostscript.com/download/gsdnld.html
   - Installer 64-bit ou 32-bit selon votre système

3. **ImageMagick** (optionnel, pour conversion d'images)
   - Télécharger : https://imagemagick.org/script/download.php#windows

4. **wkhtmltopdf** (optionnel, pour conversion HTML)
   - Télécharger : https://wkhtmltopdf.org/downloads.html

### AutoIT v3 :
- Télécharger : https://www.autoitscript.com/site/autoit/downloads/

## 🚀 Installation

1. Clonez le dépôt :
```bash
git clone https://github.com/MDitor-map/autoIT-pdf-converter-gui.git
cd autoIT-pdf-converter-gui
```

2. Installez les applications prérequises (voir section ci-dessus)

3. Compilez le script AutoIT :
   - Ouvrez `PDFConverter.au3` avec **SciTE** (inclus dans AutoIT)
   - Clic-droit → **Compiler**
   - Ou : **Ctrl+F7**

4. Exécutez l'application compilée (`.exe`)

## 💻 Utilisation

### Interface principale

1. **Sélection du fichier**
   - Cliquez sur "Parcourir" pour sélectionner un fichier
   - Formats supportés : tous les formats courants

2. **Dossier de sortie**
   - Par défaut : Documents
   - Modifiez si nécessaire

3. **Paramètres de compression**
   - **Niveau** : 0 (faible compression) à 9 (forte compression)
   - **Qualité** : 72 DPI (web), 150 DPI (brouillon), 300 DPI (standard), 600 DPI (haute)

4. **Actions**
   - **Convertir en PDF** : Démarre la conversion
   - **Effacer la file** : Vide la file d'attente

5. **Suivi**
   - Barre de progression en temps réel
   - Statut des fichiers
   - Compteur de réussite/erreurs

## 🔧 Architecture technique

### Fonctions principales

| Fonction | Description |
|----------|-------------|
| `_InitializeGUI()` | Crée l'interface graphique |
| `_ConvertFile()` | Dispatcher vers le bon convertisseur |
| `_ConvertImage()` | Conversion images (ImageMagick) |
| `_ConvertDocument()` | Conversion documents (LibreOffice/Word) |
| `_ConvertSpreadsheet()` | Conversion tableurs (LibreOffice/Excel) |
| `_ConvertPresentation()` | Conversion présentations (LibreOffice) |
| `_ConvertHTML()` | Conversion web (wkhtmltopdf) |
| `_CompressPDF()` | Compression avec Ghostscript |
| `_FindApplication()` | Détection automatique des app |
| `_ProcessQueue()` | Traitement file d'attente |

### Flux de conversion

```
Fichier source
    ↓
Détection format
    ↓
Conversion appropriée
    ↓
Compression PDF (si Ghostscript installé)
    ↓
Fichier PDF final
```

## 📊 Niveaux de compression

- **0-2** : `/screen` - Compression web (petit fichier, qualité réduite)
- **3-5** : `/ebook` - Compression équilibrée (moyen fichier, bonne qualité)
- **6-9** : `/prepress` - Compression minimale (gros fichier, haute qualité)

## ⚠️ Dépannage

### "Application non trouvée"
- Vérifiez que LibreOffice/Ghostscript est installé
- Redémarrez l'application
- Vérifiez les chemins d'installation

### Conversion échouée
- Vérifiez le format du fichier
- Assurez-vous que le dossier de sortie est accessible
- Consultez les logs pour plus d'infos

### PDF non compressé
- Ghostscript n'est pas installé
- La compression ne s'effectuera pas, mais la conversion fonctionnera

## 📝 Notes importantes

- Le script utilise des chemins UNC pour compatibilité
- Les fichiers existants génèrent une demande de confirmation
- Compression PDF optionnelle (fallback si Ghostscript absent)
- Support COM pour Microsoft Office (Word/Excel) en fallback

## 🤝 Contribution

Les contributions sont bienvenues ! N'hésitez pas à :
- Signaler des bugs
- Proposer des améliorations
- Suggérer de nouveaux formats

## 📄 Licence

Ce projet est libre d'utilisation. Utilisez-le comme bon vous semble.

## 🔗 Ressources

- [Documentation AutoIT](https://www.autoitscript.com/wiki/)
- [Ghostscript Options](https://www.ghostscript.com/doc/current/Use.htm)
- [LibreOffice CLI](https://wiki.documentfoundation.org/macros/Basic/Lesson_1)

---

**Développé avec ❤️ en AutoIT**
