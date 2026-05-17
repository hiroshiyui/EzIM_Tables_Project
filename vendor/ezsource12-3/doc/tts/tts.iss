[Files]
Source: ..\..\output\tts\TableTextServiceEasy.txt; DestDir: {pf32}\Windows NT\TableTextService; MinVersion: 0,6.0.6000
Source: ..\..\artwork\Easy.ico; DestDir: {pf32}\Windows NT\TableTextService; MinVersion: 0,6.0.6000
Source: ..\..\output\tts\TableTextServiceEasy.txt; DestDir: {pf64}\Windows NT\TableTextService; Check: IsWin64; MinVersion: 0,6.0.6000
[UninstallDelete]
Name: {pf32}\Windows NT\Windows NT\TableTextService\TableTextServiceEasy.txt; Type: files
Name: {pf32}\Windows NT\TableTextService\Easy.ico; Type: files
Name: {pf64}\Windows NT\TableTextService\TableTextServiceEasy.txt; Type: files; Check: IsWin64
[Setup]
ArchitecturesInstallIn64BitMode=x64 ia64
ArchitecturesAllowed=x86 x64 ia64
SolidCompression=true
AppPublisher=Woodman Tuen
AppPublisherURL=http://input.foruto.com/woodman
AppSupportURL=http://input.foruto.com/woodman
AppUpdatesURL=http://input.foruto.com/woodman
AppVersion=1.2.3
AppContact=wmtuen@gmail.com
UninstallDisplayName={cm:eztts} 1.2.3 TTS
AppName={cm:eztts} For Windows Vista/7/08 TTS
AppVerName={cm:eztts} 1.2.3 TTS
CreateAppDir=false
OutputDir=.
OutputBaseFilename=ez12-3_tts
AppID={{CB708D5C-A83A-4640-BCBA-9ADD2101FF18}
UninstallFilesDir={win}
UninstallLogMode=overwrite
UsePreviousGroup=false
AppendDefaultGroupName=false
InternalCompressLevel=ultra64
Compression=lzma/ultra
Minversion=0,6.0.6000
VersionInfoCopyright=GPL
VersionInfoDescription=輕鬆輸入法單字版 For Windows Vista/7/08 TTS
VersionInfoTextVersion=
AppCopyright=GPL
VersionInfoVersion=1.2.3
LanguageDetectionMethod=uilanguage
ShowLanguageDialog=auto
[Registry]
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{E09B245E-CDAA-49DD-8A2B-644565108314}; ValueType: string; ValueName: Description; ValueData: 中文 (繁體) - 輕鬆; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{E09B245E-CDAA-49DD-8A2B-644565108314}; ValueType: string; ValueName: IconFile; ValueData: %ProgramFiles%\Windows NT\TableTextService\Easy.ico; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{E09B245E-CDAA-49DD-8A2B-644565108314}; ValueType: dword; ValueName: IconIndex; ValueData: $00000000; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{E09B245E-CDAA-49DD-8A2B-644565108314}; ValueType: dword; ValueName: Enable; ValueData: $00000000; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{E09B245E-CDAA-49DD-8A2B-644565108314}; ValueType: string; ValueName: Display Description; ValueData: 中文 (繁體) - 輕鬆; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\TableTextService\0x00000404\{{E09B245E-CDAA-49DD-8A2B-644565108314}; ValueType: string; ValueName: SettingFile; ValueData: %ProgramFiles%\Windows NT\TableTextService\TableTextServiceEasy.txt; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Wow6432Node\Microsoft\TableTextService\0x00000404\{{E09B245E-CDAA-49DD-8A2B-644565108314}; ValueType: string; ValueName: SettingFile; ValueData: %ProgramFiles(x86)%\Windows NT\TableTextService\TableTextServiceEasy.txt; Flags: uninsdeletekey; Check: IsWin64
[Languages]
Name: en_US; MessagesFile: compiler:Default.isl
Name: zh_TW; MessagesFile: compiler:Languages\ChineseTrad-2-5.1.11.isl
[CustomMessages]
en_US.eztts=Easy Input Method
zh_TW.eztts=輕鬆輸入法單字版
