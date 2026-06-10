#include <MsgBoxConstants.au3>

; Script d'installation des dépendances automatiques
; Exécutez ce script pour télécharger et installer les applications requises

Global $downloadDir = @TempDir & "\PDFConverter_Deps"
Global $appDownloads[3][3] = [ _
	["LibreOffice", "https://www.libreoffice.org/download/download/", "LibreOffice_Setup.exe"], _
	["Ghostscript", "https://www.ghostscript.com/download/gsdnld.html", "GS_Setup.exe"], _
	["ImageMagick", "https://imagemagick.org/script/download.php#windows", "ImageMagick_Setup.exe"] _
]

_Main()

Func _Main()
	MsgBox($MB_ICONINFO, "Installation des dépendances", _
		"Ce script vous guidera pour installer les applications requises." & @CRLF & @CRLF & _
		"Cliquez sur OK pour continuer.")
	
	_CheckInstalledApps()
	
	Local $result = MsgBox($MB_YESNO, "Installation", _
		"Voulez-vous installer les applications manquantes ?" & @CRLF & _
		"Les téléchargements seront stockés dans: " & $downloadDir)
	
	If $result = $IDYES Then
		_StartDownload()
	EndIf
EndFunc

Func _CheckInstalledApps()
	Local $msg = "État des applications :" & @CRLF & @CRLF
	
	$msg &= _CheckApp("LibreOffice", "soffice.exe") & @CRLF
	$msg &= _CheckApp("Ghostscript", "gswin64c.exe") & @CRLF
	$msg &= _CheckApp("ImageMagick", "magick.exe") & @CRLF
	$msg &= _CheckApp("wkhtmltopdf", "wkhtmltopdf.exe")
	
	MsgBox($MB_ICONINFO, "Vérification des applications", $msg)
EndFunc

Func _CheckApp($appName, $exeName)
	If _FileExistsInPath($exeName) Then
		Return "✓ " & $appName & " : INSTALLÉ"
	Else
		Return "✗ " & $appName & " : NON INSTALLÉ (recommandé)"
	EndIf
EndFunc

Func _FileExistsInPath($fileName)
	Local $pathEnv = Environ("PATH")
	Local $pathArray = StringSplit($pathEnv, ";")
	
	For $i = 1 To $pathArray[0]
		If FileExists($pathArray[$i] & "\" & $fileName) Then
			Return True
		EndIf
	Next
	
	; Chercher dans Program Files
	If FileExists(@ProgramFilesDir & "\LibreOffice\program\" & $fileName) Then Return True
	If FileExists(@ProgramFilesDir & " (x86)\LibreOffice\program\" & $fileName) Then Return True
	
	Return False
EndFunc

Func _StartDownload()
	If Not FileExists($downloadDir) Then
		DirCreate($downloadDir)
	EndIf
	
	Local $msg = "Cliquez sur les liens pour télécharger les applications :" & @CRLF & @CRLF
	$msg &= "1. LibreOffice (requis pour documents)" & @CRLF
	$msg &= "   https://www.libreoffice.org/download/download/" & @CRLF & @CRLF
	
	$msg &= "2. Ghostscript (requis pour compression)" & @CRLF
	$msg &= "   https://www.ghostscript.com/download/gsdnld.html" & @CRLF & @CRLF
	
	$msg &= "3. ImageMagick (optionnel pour images)" & @CRLF
	$msg &= "   https://imagemagick.org/script/download.php#windows" & @CRLF & @CRLF
	
	$msg &= "Après téléchargement, exécutez les fichiers .exe" & @CRLF
	$msg &= "et suivez les instructions d'installation."
	
	MsgBox($MB_ICONINFO, "Téléchargement des dépendances", $msg)
	
	; Ouvrir les liens dans le navigateur par défaut
	Local $installChoice = MsgBox($MB_YESNO, "Ouvrir les liens", _
		"Voulez-vous ouvrir les pages de téléchargement dans votre navigateur ?")
	
	If $installChoice = $IDYES Then
		ShellExecute("https://www.libreoffice.org/download/download/")
		Sleep(500)
		ShellExecute("https://www.ghostscript.com/download/gsdnld.html")
		Sleep(500)
		ShellExecute("https://imagemagick.org/script/download.php#windows")
	EndIf
	
	MsgBox($MB_ICONINFO, "Prochaines étapes", _
		"Une fois les installations terminées :" & @CRLF & @CRLF & _
		"1. Redémarrez votre ordinateur" & @CRLF & _
		"2. Lancez PDFConverter.exe" & @CRLF & _
		"3. L'application détectera automatiquement les applications installées")
EndFunc
