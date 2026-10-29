; Inno Setup Kurulum Yapılandırması
; KON Üye Kayıt Defteri (Windows x64)

#define MyAppName "KON Üye Kayıt Defteri"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "KON"
#define MyAppExeName "ortak_defteri.exe"

[Setup]
AppId={{D821C753-41A8-4EF5-893C-72A0C16C97F1}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\..\build\windows\installer
OutputBaseFilename=KON_Uye_Kayit_Defteri_Kurulum_x64
SetupIconFile=..\runner\resources\app_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\..\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "{#MyAppExeName},*.pdb"
Source: "vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: skipifsourcedoesntexist deleteafterinstall

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; WorkingDir: "{app}"

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /passive /norestart"; StatusMsg: "Microsoft Visual C++ çalışma zamanı bileşenleri kuruluyor..."; Check: VCRedistNeedsInstall; Flags: waituntilterminated
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent; WorkingDir: "{app}"

[Code]
function VCRedistNeedsInstall: Boolean;
var
  Installed: Cardinal;
begin
  Result := True;
  if not FileExists(ExpandConstant('{tmp}\vc_redist.x64.exe')) then
  begin
    Result := False;
    Exit;
  end;

  // Visual C++ 2015-2022 x64 sistemde zaten yuklu mu kontrol et
  if RegQueryDWordValue(HKLM, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Installed', Installed) then
  begin
    if Installed = 1 then
      Result := False;
  end;
end;
