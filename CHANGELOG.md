# Journal des modifications

## [1.0.0] - 2024-01-10

### ✨ Ajouté
- Interface GUI principale complète
- Support pour 15+ formats de fichiers
  - Images : JPG, JPEG, PNG, BMP, GIF, TIFF
  - Documents : DOC, DOCX, TXT, ODT
  - Tableurs : XLS, XLSX, ODS
  - Présentations : PPT, PPTX, ODP
  - Web : HTML, HTM, MHTML
- Compression PDF avec 10 niveaux
- File d'attente de conversion
- Barre de progression en temps réel
- Détection automatique des applications

### 🎨 Interface
- Design moderne et clair
- Groupes logiques d'éléments
- Statuts visuels (✓ succès, ✗ erreur)
- Indicateurs de progression

### 🔧 Fonctionnalités techniques
- Support LibreOffice (documents, tableurs, présentations)
- Support Microsoft Office (Word, Excel) en fallback
- Support ImageMagick (images)
- Support wkhtmltopdf (HTML)
- Support Ghostscript (compression)
- Recherche récursive des applications
- Gestion des chemins UNC
- Fallback en chaîne

### 📦 Distribution
- Script source PDFConverter.au3
- Helper d'installation des dépendances
- Documentation complète (README.md)
- Ce journal des modifications

## À venir

- [ ] Support batch/ligne de commande
- [ ] Paramètres de compression par format
- [ ] Historique des conversions
- [ ] Thème sombre
- [ ] Support des fichiers ZIP (extraction+conversion)
- [ ] Fractionnement PDF
- [ ] Fusion PDF
- [ ] Rotation/recadrage PDF

---

**Note** : Ce projet est en version stable et prêt pour utilisation en production.
