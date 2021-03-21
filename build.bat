@echo off

if [%1]==[] (
	echo Usage: build.bat app_name app_name_short app_version
	pause
	exit
)

set "APP_NAME=%1"
set "APP_NAME_SHORT=%2"
set "APP_VERSION=%3"

set "BIN_DIRECTORY=%~dp0..\%APP_NAME_SHORT%\bin"
set "OUT_DIRECTORY=%UserProfile%\Desktop"
set "TMP_DIRECTORY=%~dp0TEMP\%APP_NAME_SHORT%"

set "PORTABLE_FILE=%OUT_DIRECTORY%\%APP_NAME_SHORT%-%APP_VERSION%-bin.zip"
set "PDB_PACKAGE_FILE=%OUT_DIRECTORY%\%APP_NAME_SHORT%-%APP_VERSION%-pdb.zip"
set "SETUP_FILE=%OUT_DIRECTORY%\%APP_NAME_SHORT%-%APP_VERSION%-setup.exe"
set "SETUP_FILE_SIGN=%OUT_DIRECTORY%\%APP_NAME_SHORT%-%APP_VERSION%-setup.exe.sig"
set "CHECKSUM_FILE=%OUT_DIRECTORY%\%APP_NAME_SHORT%-%APP_VERSION%.sha256"

rem Create temporary folder with binaries and documentation...

del /s /f /q "%TMP_DIRECTORY%\*"

del /s /f /q "%PORTABLE_FILE%"
del /s /f /q "%PDB_PACKAGE_FILE%"
del /s /f /q "%SETUP_FILE%"
del /s /f /q "%SETUP_FILE_SIGN%"
del /s /f /q "%CHECKSUM_FILE%"

mkdir "%TMP_DIRECTORY%\32"
mkdir "%TMP_DIRECTORY%\64"

rem Made debug symbols package

if exist "%BIN_DIRECTORY%\32\%APP_NAME_SHORT%.pdb" (
	copy /b /y "%BIN_DIRECTORY%\32\%APP_NAME_SHORT%.pdb" "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.pdb"
)

if exist "%BIN_DIRECTORY%\64\%APP_NAME_SHORT%.pdb" (
	copy /b /y "%BIN_DIRECTORY%\64\%APP_NAME_SHORT%.pdb" "%TMP_DIRECTORY%\64\%APP_NAME_SHORT%.pdb"
)

if exist "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.pdb" if exist %TMP_DIRECTORY%\64\%APP_NAME_SHORT%.pdb (
	7z.exe a -mm=Deflate64 -mx=9 -mfb=257 -mpass=15 -mtc=off -slp "%PDB_PACKAGE_FILE%" "%TMP_DIRECTORY%"

	del /s /f /q "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.pdb"
	del /s /f /q "%TMP_DIRECTORY%\64\%APP_NAME_SHORT%.pdb"
)

if exist "%BIN_DIRECTORY%\History.txt" (
	copy /b /y "%BIN_DIRECTORY%\History.txt" "%BIN_DIRECTORY%\..\CHANGELOG.md"
)

rem Prepare for git commits

if exist "%BIN_DIRECTORY%\History.txt" (
	copy /b /y "%BIN_DIRECTORY%\History.txt" "%BIN_DIRECTORY%\..\CHANGELOG.md"
)

if exist "%~dp0\.github\FUNDING.yml" (
	mkdir "%BIN_DIRECTORY%\..\.github"
	copy /b /y "%~dp0\.github\FUNDING.yml" "%BIN_DIRECTORY%\..\.github\FUNDING.yml"
)

if exist "%~dp0\.gitignore" (
	copy /b /y "%~dp0\.gitignore" "%BIN_DIRECTORY%\..\.gitignore"
)

if exist "%~dp0\.gitattributes" (
	copy /b /y "%~dp0\.gitattributes" "%BIN_DIRECTORY%\..\.gitattributes"
)

if exist "%~dp0\.gitmodules" (
	copy /b /y "%~dp0\.gitmodules" "%BIN_DIRECTORY%\..\.gitmodules"
)

if exist "%~dp0\.editorconfig" (
	copy /b /y "%~dp0\.editorconfig" "%BIN_DIRECTORY%\..\.editorconfig"
)

rem Copy documentation

if exist "%BIN_DIRECTORY%\Readme.txt" (
	copy /b /y "%BIN_DIRECTORY%\Readme.txt" "%TMP_DIRECTORY%\32\Readme.txt"
	copy /b /y "%BIN_DIRECTORY%\Readme.txt" "%TMP_DIRECTORY%\64\Readme.txt"
)

if exist "%BIN_DIRECTORY%\History.txt" (
	copy /b /y "%BIN_DIRECTORY%\History.txt" "%TMP_DIRECTORY%\32\History.txt"
	copy /b /y "%BIN_DIRECTORY%\History.txt" "%TMP_DIRECTORY%\64\History.txt"
)

if exist "%BIN_DIRECTORY%\License.txt" (
	copy /b /y "%BIN_DIRECTORY%\License.txt" "%TMP_DIRECTORY%\32\License.txt"
	copy /b /y "%BIN_DIRECTORY%\License.txt" "%TMP_DIRECTORY%\64\License.txt"
)

if exist "%BIN_DIRECTORY%\FAQ.txt" (
	copy /b /y "%BIN_DIRECTORY%\FAQ.txt" "%TMP_DIRECTORY%\32\FAQ.txt"
	copy /b /y "%BIN_DIRECTORY%\FAQ.txt" "%TMP_DIRECTORY%\64\FAQ.txt"
)

copy "%BIN_DIRECTORY%\*.txt" "%TMP_DIRECTORY%\32\*.txt"
copy "%BIN_DIRECTORY%\*.txt" "%TMP_DIRECTORY%\64\*.txt"

rem Copy configuration

if exist "%BIN_DIRECTORY%\%APP_NAME_SHORT%.ini" (
	copy /b /y "%BIN_DIRECTORY%\%APP_NAME_SHORT%.ini" "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.ini"
	copy /b /y "%BIN_DIRECTORY%\%APP_NAME_SHORT%.ini" "%TMP_DIRECTORY%\64\%APP_NAME_SHORT%.ini"
)

echo|set /p="#PORTABLE#">"%TMP_DIRECTORY%\32\portable.dat"
echo|set /p="#PORTABLE#">"%TMP_DIRECTORY%\64\portable.dat"

copy /b /y "%BIN_DIRECTORY%\*.bat" "%TMP_DIRECTORY%\32\*.bat"
copy /b /y "%BIN_DIRECTORY%\*.reg" "%TMP_DIRECTORY%\32\*.reg"

copy /b /y "%BIN_DIRECTORY%\*.bat" "%TMP_DIRECTORY%\64\*.bat"
copy /b /y "%BIN_DIRECTORY%\*.reg" "%TMP_DIRECTORY%\64\*.reg"

rem Copy localization

if exist "%BIN_DIRECTORY%\%APP_NAME_SHORT%.lng" (
	copy /b /y "%BIN_DIRECTORY%\%APP_NAME_SHORT%.lng" "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.lng"
	copy /b /y "%BIN_DIRECTORY%\%APP_NAME_SHORT%.lng" "%TMP_DIRECTORY%\64\%APP_NAME_SHORT%.lng"
)

rem Copy plugins

if exist "%BIN_DIRECTORY%\32\plugins" (
	mkdir "%TMP_DIRECTORY%\32\plugins"

	copy /b /y "%BIN_DIRECTORY%\32\plugins" "%TMP_DIRECTORY%\32\plugins"
)

if exist "%BIN_DIRECTORY%\64\plugins" (
	mkdir "%TMP_DIRECTORY%\64\plugins"

	copy /b /y "%BIN_DIRECTORY%\64\plugins" "%TMP_DIRECTORY%\64\plugins"
)

rem Copy binaries

copy /b /y "%BIN_DIRECTORY%\32\*.exe" "%TMP_DIRECTORY%\32\*.exe"
copy /b /y "%BIN_DIRECTORY%\32\*.scr" "%TMP_DIRECTORY%\32\*.scr"
copy /b /y "%BIN_DIRECTORY%\32\*.dll" "%TMP_DIRECTORY%\32\*.dll"
copy /b /y "%BIN_DIRECTORY%\64\*.exe" "%TMP_DIRECTORY%\64\*.exe"
copy /b /y "%BIN_DIRECTORY%\64\*.scr" "%TMP_DIRECTORY%\64\*.scr"
copy /b /y "%BIN_DIRECTORY%\64\*.dll" "%TMP_DIRECTORY%\64\*.dll"

rem Sign binaries

if exist "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.exe" (
	gpg --output "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.exe.sig" --detach-sign "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.exe"
	gpg --output "%TMP_DIRECTORY%\64\%APP_NAME_SHORT%.exe.sig" --detach-sign "%TMP_DIRECTORY%\64\%APP_NAME_SHORT%.exe"
)

if exist "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.scr" (
	gpg --output "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.scr.sig" --detach-sign "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.scr"
	gpg --output "%TMP_DIRECTORY%\64\%APP_NAME_SHORT%.scr.sig" --detach-sign "%TMP_DIRECTORY%\64\%APP_NAME_SHORT%.scr"
)

rem Set attributes

attrib -r -s -h "%TMP_DIRECTORY%" /d
attrib -r -s -h "%TMP_DIRECTORY%\*.*" /s

if exist "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.lng" (
	attrib +r "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.lng"
)

if exist "%TMP_DIRECTORY%\64\%APP_NAME_SHORT%.lng" (
	attrib +r "%TMP_DIRECTORY%\64\%APP_NAME_SHORT%.lng"
)

rem Create portable version

7z.exe a -mm=Deflate64 -mx=9 -mfb=257 -mpass=15 -mtc=off -slp "%PORTABLE_FILE%" "%TMP_DIRECTORY%"

rem Create setup version

if not %APP_NAME%=="" (
	copy /b /y "%TMP_DIRECTORY%\32\*.txt" "%TMP_DIRECTORY%\*.txt"
	copy /b /y "%TMP_DIRECTORY%\32\*.lng" "%TMP_DIRECTORY%\*.lng"

	del /s /f /q "%TMP_DIRECTORY%\32\*.txt"
	del /s /f /q "%TMP_DIRECTORY%\64\*.txt"

	del /s /f /q "%TMP_DIRECTORY%\32\*.lng"
	del /s /f /q "%TMP_DIRECTORY%\64\*.lng"

	if exist "%BIN_DIRECTORY%\i18n" (
		mkdir "%TMP_DIRECTORY%\i18n"
		copy /y "%BIN_DIRECTORY%\i18n" "%TMP_DIRECTORY%\i18n"
	)

	copy /b /y "%BIN_DIRECTORY%\..\src\res\100.ico" "logo.ico"
	
	makensis.exe /DAPP_FILES_DIR=%TMP_DIRECTORY% /DAPP_NAME=%APP_NAME% /DAPP_NAME_SHORT=%APP_NAME_SHORT% /DAPP_VERSION=%APP_VERSION% /X"OutFile %SETUP_FILE%" installer.nsi
	
	del /s /f /q "%SETUP_FILE_SIGN%"
	gpg --output "%SETUP_FILE_SIGN%" --detach-sign "%SETUP_FILE%"
)

rem Calculate sha256 checksum

if exist "%PORTABLE_FILE%" (
	sha256deep64 -s -b -k "%PORTABLE_FILE%">>"%CHECKSUM_FILE%"
)

if exist "%PDB_PACKAGE_FILE%" (
	sha256deep64 -s -b -k "%PDB_PACKAGE_FILE%">>"%CHECKSUM_FILE%"
)

if exist "%SETUP_FILE%" (
	sha256deep64 -s -b -k "%SETUP_FILE%">>"%CHECKSUM_FILE%"
)

if exist "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.exe" (
	echo #32-bit:>>"%CHECKSUM_FILE%"
	sha256deep64 -s -b -k "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.exe">>"%CHECKSUM_FILE%"
	echo #64-bit:>>"%CHECKSUM_FILE%"
	sha256deep64 -s -b -k "%TMP_DIRECTORY%\64\%APP_NAME_SHORT%.exe">>"%CHECKSUM_FILE%"
) else if exist "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.scr" (
	echo #32-bit:>>"%CHECKSUM_FILE%"
	sha256deep64 -s -b -k "%TMP_DIRECTORY%\32\%APP_NAME_SHORT%.scr">>"%CHECKSUM_FILE%"
	echo #64-bit:>>"%CHECKSUM_FILE%"
	sha256deep64 -s -b -k "%TMP_DIRECTORY%\64\%APP_NAME_SHORT%.scr">>"%CHECKSUM_FILE%"
)

rem Cleanup

rmdir /s /q "%TMP_DIRECTORY%\32"
rmdir /s /q "%TMP_DIRECTORY%\64"
rmdir /s /q "%TMP_DIRECTORY%\i18n"

del /s /f /q "%TMP_DIRECTORY%\*"

del /s /f /q "logo.ico"

rmdir /q "%TMP_DIRECTORY%"

pause
