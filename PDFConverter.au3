#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <GuiButton.au3>
#include <GuiEdit.au3>
#include <GuiListView.au3>
#include <GuiProgressBar.au3>
#include <Array.au3>

Opt("GUIOnEventMode", 1)
Opt("TrayIconDebug", 1)

Global $hGUI, $inputFile, $outputPath, $compressionLevel
Global $statusLabel, $progressBar, $listView
Global $convertBtn, $browseBtn, $browseDirBtn, $clearBtn
Global $hCompressionSlider, $compressionLabel
Global $fileQueue[0], $isProcessing = False
Global $convertedCount = 0, $failedCount = 0

_InitializeGUI()

While 1
	Sleep(100)
WEnd

Func _InitializeGUI()
	$hGUI = GUICreate("PDF Converter & Compressor", 900, 700, -1, -1)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_ExitApp")
	
	; ===== HEADER =====
	GUICtrlCreateLabel("Convertisseur PDF Multiformat", 10, 10, 880, 25)
	GUICtrlSetFont(-1, 14, 800)
	
	GUICtrlCreateLabel("Convertissez et compressez tous vos documents en PDF", 10, 35, 880, 20)
	GUICtrlSetFont(-1, 10)
	GUICtrlSetColor(-1, 0x666666)
	
	; ===== INPUT SECTION =====
	GUICtrlCreateGroup("Sélection du fichier", 10, 60, 880, 70)
	
	GUICtrlCreateLabel("Fichier à convertir :", 20, 75, 120, 20)
	$inputFile = GUICtrlCreateInput("", 140, 75, 700, 22)
	GUICtrlSetState(-1, $GUI_DISABLE)
	
	$browseBtn = GUICtrlCreateButton("Parcourir", 850, 75, 30, 22)
	GUICtrlSetOnEvent($browseBtn, "_BrowseFile")
	
	GUICtrlCreateLabel("Dossier de sortie :", 20, 105, 120, 20)
	$outputPath = GUICtrlCreateInput(@DocumentsDir, 140, 105, 700, 22)
	
	$browseDirBtn = GUICtrlCreateButton("Parcourir", 850, 105, 30, 22)
	GUICtrlSetOnEvent($browseDirBtn, "_BrowseDir")
	
	GUICtrlCreateGroupEnd()
	
	; ===== COMPRESSION SECTION =====
	GUICtrlCreateGroup("Paramètres de compression", 10, 140, 880, 80)
	
	GUICtrlCreateLabel("Niveau de compression :", 20, 160, 150, 20)
	
	; Compression slider
	$hCompressionSlider = GUICtrlCreateSlider(170, 160, 300, 20)
	GUICtrlSetLimit($hCompressionSlider, 9, 0)
	GUICtrlSetData($hCompressionSlider, 5)
	
	$compressionLabel = GUICtrlCreateLabel("Niveau: 5 (Moyen)", 480, 160, 150, 20)
	GUICtrlSetFont($compressionLabel, 10, 800)
	
	GUICtrlCreateLabel("Qualité image :", 20, 190, 150, 20)
	
	Local $dpiCombo = GUICtrlCreateCombo("", 170, 190, 300, 120)
	GUICtrlSetData($dpiCombo, "72 DPI (Web)|150 DPI (Brouillon)|300 DPI (Standard)|600 DPI (Haute qualité)", "300 DPI (Standard)")
	
	GUICtrlCreateGroupEnd()
	
	; ===== ACTION BUTTONS =====
	GUICtrlCreateGroup("Actions", 10, 230, 880, 50)
	
	$convertBtn = GUICtrlCreateButton("Convertir en PDF", 20, 250, 120, 30)
	GUICtrlSetOnEvent($convertBtn, "_ConvertToPDF")
	
	$clearBtn = GUICtrlCreateButton("Effacer la file", 150, 250, 120, 30)
	GUICtrlSetOnEvent($clearBtn, "_ClearQueue")
	
	GUICtrlCreateLabel("", 280, 250, 600, 30)
	
	GUICtrlCreateGroupEnd()
	
	; ===== FILE QUEUE =====
	GUICtrlCreateGroup("File d'attente", 10, 290, 880, 130)
	
	$listView = GUICtrlCreateListView("Fichier|Format|Statut", 20, 310, 860, 100, BitOR($LVS_REPORT, $LVS_SINGLESEL))
	_GUICtrlListView_SetColumnWidth($listView, 0, 400)
	_GUICtrlListView_SetColumnWidth($listView, 1, 120)
	_GUICtrlListView_SetColumnWidth($listView, 2, 300)
	
	GUICtrlCreateGroupEnd()
	
	; ===== PROGRESS SECTION =====
	GUICtrlCreateGroup("Progression", 10, 430, 880, 100)
	
	GUICtrlCreateLabel("Fichiers convertis :", 20, 450, 120, 20)
	GUICtrlCreateLabel("0 / 0", 140, 450, 80, 20)
	
	$progressBar = GUICtrlCreateProgress(20, 480, 860, 20)
	
	$statusLabel = GUICtrlCreateLabel("Prêt", 20, 510, 860, 35)
	GUICtrlSetFont($statusLabel, 9)
	GUICtrlSetColor($statusLabel, 0x008000)
	
	GUICtrlCreateGroupEnd()
	
	; ===== LOG/INFO SECTION =====
	GUICtrlCreateGroup("Informations", 10, 540, 880, 150)
	
	Local $infoEdit = GUICtrlCreateEdit("", 20, 560, 860, 120, BitOR($ES_READONLY, $ES_MULTILINE, $WS_VSCROLL))
	
	GUICtrlCreateGroupEnd()
	
	GUISetState(@SW_SHOW, $hGUI)
EndFunc

Func _BrowseFile()
	Local $file = FileOpenDialog("Sélectionner un fichier", @DocumentsDir, _
		"Tous les fichiers (*.*)|Images (*.jpg;*.png;*.bmp;*.gif;*.tiff)|" & _
		"Documents (*.doc;*.docx;*.txt;*.odt;*.xls;*.xlsx;*.ppt;*.pptx)|" & _
		"Web (*.html;*.htm;*.mhtml)|Archives (*.zip;*.rar;*.7z)", 1)
	
	If Not @error Then
		GUICtrlSetData($inputFile, $file)
		_UpdateFileInfo($file)
	EndIf
EndFunc

Func _BrowseDir()
	Local $folder = FileSelectFolder("Sélectionner le dossier de sortie", @DocumentsDir, 0, -1)
	If Not @error Then
		GUICtrlSetData($outputPath, $folder)
	EndIf
EndFunc

Func _UpdateFileInfo($filePath)
	Local $fileSize = FileGetSize($filePath)
	Local $fileExt = StringRight($filePath, 4)
	Local $fileName = StringRegExpReplace($filePath, "^.*\\", "")
	
	Local $sizeStr = _FormatFileSize($fileSize)
	Local $info = "Fichier: " & $fileName & @CRLF & _
		"Taille: " & $sizeStr & @CRLF & _
		"Format: " & StringUpper($fileExt)
EndFunc

Func _FormatFileSize($iSize)
	Local $aUnits[4] = ["B", "KB", "MB", "GB"]
	Local $index = 0
	Local $size = $iSize
	
	While $size > 1024 And $index < 3
		$size = $size / 1024
		$index += 1
	WEnd
	
	Return StringFormat("%.2f %s", $size, $aUnits[$index])
EndFunc

Func _ConvertToPDF()
	Local $file = GUICtrlRead($inputFile)
	
	If $file = "" Then
		MsgBox($MB_ICONWARNING, "Attention", "Veuillez sélectionner un fichier")
		Return
	EndIf
	
	If Not FileExists($file) Then
		MsgBox($MB_ICONERROR, "Erreur", "Le fichier n'existe pas")
		Return
	EndIf
	
	Local $outputDir = GUICtrlRead($outputPath)
	If Not FileExists($outputDir) Then
		MsgBox($MB_ICONERROR, "Erreur", "Le dossier de sortie n'existe pas")
		Return
	EndIf
	
	Local $fileName = StringRegExpReplace($file, "^.*\\", "")
	Local $baseName = StringRegExpReplace($fileName, "\.[^.]+$", "")
	Local $fileExt = StringRight($file, 3)
	
	Local $outputFile = $outputDir & "\" & $baseName & ".pdf"
	
	; Vérifier si le fichier de sortie existe
	If FileExists($outputFile) Then
		Local $result = MsgBox($MB_YESNOCANCEL, "Fichier existant", _
			"Le fichier PDF existe déjà." & @CRLF & "Voulez-vous le remplacer ?")
		If $result = $IDNO Then
			Return
		ElseIf $result = $IDCANCEL Then
			$outputFile = $outputDir & "\" & $baseName & "_converted.pdf"
		EndIf
	EndIf
	
	_AddToQueue($file, $fileExt, $outputFile)
	_ProcessQueue()
EndFunc

Func _AddToQueue($filePath, $fileExt, $outputFile)
	Local $fileName = StringRegExpReplace($filePath, "^.*\\", "")
	Local $item = _GUICtrlListView_AddItem($listView, $fileName)
	_GUICtrlListView_AddSubItem($item, 1, StringUpper(StringRight($fileExt, 3)))
	_GUICtrlListView_AddSubItem($item, 2, "En attente")
	_GUICtrlListView_SetItemText($listView, $item, 3, $filePath)
	_GUICtrlListView_SetItemText($listView, $item, 4, $outputFile)
EndFunc

Func _ProcessQueue()
	If $isProcessing Then
		MsgBox($MB_ICONINFO, "Info", "Une conversion est déjà en cours")
		Return
	EndIf
	
	$isProcessing = True
	$convertedCount = 0
	$failedCount = 0
	
	Local $itemCount = _GUICtrlListView_GetItemCount($listView)
	
	For $i = 0 To $itemCount - 1
		Local $status = _GUICtrlListView_GetItemText($listView, $i, 2)
		
		If $status = "En attente" Then
			Local $inputFile = _GUICtrlListView_GetItemText($listView, $i, 3)
			Local $outputFile = _GUICtrlListView_GetItemText($listView, $i, 4)
			Local $fileExt = _GUICtrlListView_GetItemText($listView, $i, 1)
			
			_GUICtrlListView_SetItemText($listView, $i, 2, "Conversion en cours...")
			GUICtrlSetData($statusLabel, "Conversion de: " & StringRegExpReplace($inputFile, "^.*\\", ""))
			
			Local $success = _ConvertFile($inputFile, $outputFile, $fileExt)
			
			If $success Then
				_GUICtrlListView_SetItemText($listView, $i, 2, "✓ Converti avec succès")
				$convertedCount += 1
			Else
				_GUICtrlListView_SetItemText($listView, $i, 2, "✗ Échec de conversion")
				$failedCount += 1
			EndIf
			
			Local $progress = Int(($convertedCount + $failedCount) / $itemCount * 100)
			GUICtrlSetData($progressBar, $progress)
		EndIf
	Next
	
	GUICtrlSetData($statusLabel, $convertedCount & " fichier(s) converti(s) avec succès. " & $failedCount & " erreur(s).")
	GUICtrlSetColor($statusLabel, 0x008000)
	
	$isProcessing = False
EndFunc

Func _ConvertFile($inputFile, $outputFile, $fileExt)
	Local $success = False
	
	Select
		Case StringInStr("JPG|JPEG|PNG|BMP|GIF|TIFF", $fileExt)
			$success = _ConvertImage($inputFile, $outputFile)
		
		Case StringInStr("DOC|DOCX|TXT|ODT", $fileExt)
			$success = _ConvertDocument($inputFile, $outputFile)
		
		Case StringInStr("XLS|XLSX|ODS", $fileExt)
			$success = _ConvertSpreadsheet($inputFile, $outputFile)
		
		Case StringInStr("PPT|PPTX|ODP", $fileExt)
			$success = _ConvertPresentation($inputFile, $outputFile)
		
		Case StringInStr("HTML|HTM|MHTML", $fileExt)
			$success = _ConvertHTML($inputFile, $outputFile)
		
		Case Else
			$success = _ConvertGeneric($inputFile, $outputFile)
	EndSelect
	
	If $success Then
		_CompressPDF($outputFile)
	EndIf
	
	Return $success
EndFunc

Func _ConvertImage($inputFile, $outputFile)
	Local $gmPath = _FindApplication("magick.exe", "ImageMagick")
	
	If $gmPath <> "" Then
		Local $cmd = '"' & $gmPath & '" convert "' & $inputFile & '" "' & $outputFile & '"'
		Local $iPID = Run($cmd)
		ProcessWait($iPID)
		Return FileExists($outputFile)
	EndIf
	
	Return _PrintToPDF($inputFile, $outputFile)
EndFunc

Func _ConvertDocument($inputFile, $outputFile)
	Local $loPath = _FindApplication("soffice.exe", "LibreOffice")
	
	If $loPath <> "" Then
		Local $cmd = '"' & $loPath & '" --headless --convert-to pdf --outdir "' & StringRegExpReplace($outputFile, "[^\\]*$", "") & '" "' & $inputFile & '"'
		Local $iPID = Run($cmd)
		ProcessWait($iPID, 60)
		Return FileExists($outputFile)
	EndIf
	
	If StringInStr("DOC|DOCX", StringUpper(StringRight($inputFile, 5))) Then
		Return _ConvertViaWord($inputFile, $outputFile)
	EndIf
	
	Return False
EndFunc

Func _ConvertSpreadsheet($inputFile, $outputFile)
	Local $loPath = _FindApplication("soffice.exe", "LibreOffice")
	
	If $loPath <> "" Then
		Local $cmd = '"' & $loPath & '" --headless --convert-to pdf --outdir "' & StringRegExpReplace($outputFile, "[^\\]*$", "") & '" "' & $inputFile & '"'
		Local $iPID = Run($cmd)
		ProcessWait($iPID, 60)
		Return FileExists($outputFile)
	EndIf
	
	Return _ConvertViaExcel($inputFile, $outputFile)
EndFunc

Func _ConvertPresentation($inputFile, $outputFile)
	Local $loPath = _FindApplication("soffice.exe", "LibreOffice")
	
	If $loPath <> "" Then
		Local $cmd = '"' & $loPath & '" --headless --convert-to pdf --outdir "' & StringRegExpReplace($outputFile, "[^\\]*$", "") & '" "' & $inputFile & '"'
		Local $iPID = Run($cmd)
		ProcessWait($iPID, 60)
		Return FileExists($outputFile)
	EndIf
	
	Return False
EndFunc

Func _ConvertHTML($inputFile, $outputFile)
	Local $wkhtmlPath = _FindApplication("wkhtmltopdf.exe", "wkhtmltopdf")
	
	If $wkhtmlPath <> "" Then
		Local $cmd = '"' & $wkhtmlPath & '" "' & $inputFile & '" "' & $outputFile & '"'
		Local $iPID = Run($cmd)
		ProcessWait($iPID, 60)
		Return FileExists($outputFile)
	EndIf
	
	Return False
EndFunc

Func _ConvertGeneric($inputFile, $outputFile)
	Local $loPath = _FindApplication("soffice.exe", "LibreOffice")
	
	If $loPath <> "" Then
		Local $cmd = '"' & $loPath & '" --headless --convert-to pdf --outdir "' & StringRegExpReplace($outputFile, "[^\\]*$", "") & '" "' & $inputFile & '"'
		Local $iPID = Run($cmd)
		ProcessWait($iPID, 60)
		Return FileExists($outputFile)
	EndIf
	
	Return False
EndFunc

Func _ConvertViaWord($inputFile, $outputFile)
	Local $oWord = ObjCreate("Word.Application")
	If @error Then Return False
	
	$oWord.Visible = False
	Local $oDoc = $oWord.Documents.Open($inputFile)
	
	If @error Then
		$oWord.Quit
		Return False
	EndIf
	
	$oDoc.SaveAs($outputFile, 17)
	$oDoc.Close
	$oWord.Quit
	
	Return FileExists($outputFile)
EndFunc

Func _ConvertViaExcel($inputFile, $outputFile)
	Local $oExcel = ObjCreate("Excel.Application")
	If @error Then Return False
	
	$oExcel.Visible = False
	Local $oWorkbook = $oExcel.Workbooks.Open($inputFile)
	
	If @error Then
		$oExcel.Quit
		Return False
	EndIf
	
	$oWorkbook.ExportAsFixedFormat(0, $outputFile)
	$oWorkbook.Close
	$oExcel.Quit
	
	Return FileExists($outputFile)
EndFunc

Func _PrintToPDF($inputFile, $outputFile)
	ShellExecute($inputFile, "", "", "print")
	Sleep(2000)
	Return False
EndFunc

Func _CompressPDF($pdfFile)
	Local $gsPath = _FindApplication("gswin64c.exe", "Ghostscript")
	
	If $gsPath = "" Then
		$gsPath = _FindApplication("gswin32c.exe", "Ghostscript")
	EndIf
	
	If $gsPath = "" Then
		Return False
	EndIf
	
	Local $compressionLevel = GUICtrlRead($hCompressionSlider)
	Local $quality = ""
	
	Select
		Case $compressionLevel <= 2
			$quality = "/screen"
		Case $compressionLevel <= 5
			$quality = "/ebook"
		Case Else
			$quality = "/prepress"
	EndSelect
	
	Local $tempFile = StringRegExpReplace($pdfFile, "\.pdf$", "_compressed.pdf")
	
	Local $cmd = '"' & $gsPath & '" -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 ' & _
		'-dPDFSETTINGS=' & $quality & ' -dNOPAUSE -dQUIET -dBATCH ' & _
		'-sOutputFile="' & $tempFile & '" "' & $pdfFile & '"'
	
	Local $iPID = Run($cmd)
	ProcessWait($iPID)
	
	If FileExists($tempFile) Then
		FileDelete($pdfFile)
		FileMove($tempFile, $pdfFile)
		Return True
	EndIf
	
	Return False
EndFunc

Func _FindApplication($exeName, $appName)
	Local $paths[4] = [@ProgramFilesDir, @ProgramFilesDir & " (x86)", _
		@LocalAppDataDir, "C:\Tools"]
	
	For $i = 0 To 3
		Local $file = _RecursiveSearch($paths[$i], $exeName, 2)
		If $file <> "" Then Return $file
	Next
	
	Local $pathEnv = Environ("PATH")
	Local $pathArray = StringSplit($pathEnv, ";")
	
	For $i = 1 To $pathArray[0]
		If FileExists($pathArray[$i] & "\" & $exeName) Then
			Return $pathArray[$i] & "\" & $exeName
		EndIf
	Next
	
	Return ""
EndFunc

Func _RecursiveSearch($directory, $fileName, $depth)
	If $depth <= 0 Then Return ""
	
	If Not FileExists($directory) Then Return ""
	
	Local $search = FileFindFirstFile($directory & "\*")
	If $search = -1 Then Return ""
	
	Local $file
	While 1
		$file = FileFindNextFile($search)
		If @error Then ExitLoop
		
		If $file = "." Or $file = ".." Then ContinueLoop
		
		Local $fullPath = $directory & "\" & $file
		
		If @extended = 0 Then
			If StringUpper($file) = StringUpper($fileName) Then
				FileClose($search)
				Return $fullPath
			EndIf
		Else
			Local $result = _RecursiveSearch($fullPath, $fileName, $depth - 1)
			If $result <> "" Then
				FileClose($search)
				Return $result
			EndIf
		EndIf
	WEnd
	
	FileClose($search)
	Return ""
EndFunc

Func _ClearQueue()
	_GUICtrlListView_DeleteAllItems($listView)
	GUICtrlSetData($progressBar, 0)
	GUICtrlSetData($statusLabel, "File effacée")
	$convertedCount = 0
	$failedCount = 0
EndFunc

Func _ExitApp()
	Exit
EndFunc
