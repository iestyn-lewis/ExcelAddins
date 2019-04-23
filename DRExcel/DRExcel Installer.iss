; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
AppName=DRExcel
AppVerName=DRExcel 2007-11-05-1
AppPublisher=Emory University
DefaultDirName=c:\r\DRExcel
DefaultGroupName=DRExcel
AllowNoIcons=yes
OutputDir=C:\R\DRExcel\Installer
OutputBaseFilename=DRExcelSetup
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
;Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
;Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "C:\R\DRExcel\DRExcel.xla"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\R\DRExcel\doseResponseGraph.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\R\DRExcel\DRExcel.R"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\R\DRExcel\DRExcel Examples.xls"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
;Name: "{group}\PubChem Data Miner"; Filename: "{app}\PCDataMiner.exe"
;Name: "{group}\{cm:UninstallProgram,PCDataMiner}"; Filename: "{uninstallexe}"
;Name: "{commondesktop}\PC Data Miner"; Filename: "{app}\PCDataMiner.exe"; Tasks: desktopicon
;Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\SEA"; Filename: "{app}\SEA.exe"; Tasks: quicklaunchicon

[Run]
;Filename: "{app}\PCDataMiner.exe"; Description: "{cm:LaunchProgram,PCDataMiner}"; Flags: nowait postinstall skipifsilent

