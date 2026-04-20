[Files]
Source: ..\..\Output\tts\TableTextServiceEasyMid.txt; DestDir: {pf32}\Windows NT\TableTextService; MinVersion: 0,6.0.6000
Source: ..\..\artwork\EasyMid.ico; DestDir: {pf32}\Windows NT\TableTextService; MinVersion: 0,6.0.6000
Source: ..\..\Output\tts\TableTextServiceEasyMid.txt; DestDir: {pf64}\Windows NT\TableTextService; Check: IsWin64; MinVersion: 0,6.0.6000
[UninstallDelete]
Name: {pf32}\Windows NT\Windows NT\TableTextService\TableTextServiceEasyMid.txt; Type: files
Name: {pf32}\Windows NT\TableTextService\EasyMid.ico; Type: files
Name: {pf64}\Windows NT\TableTextService\TableTextServiceEasyMid.txt; Type: files; Check: IsWin64
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
UninstallDisplayName={cm:ezmidtts} 1.2.3 TTS
AppName={cm:ezmidtts} For Windows Vista/7/08 TTS
AppVerName={cm:ezmidtts} 1.2.3 TTS
CreateAppDir=false
OutputDir=.
OutputBaseFilename=ezmid12-3_tts
AppID={{B5EE951F-EBC0-4A4E-BCA6-307CF2C044A9}
UninstallFilesDir={win}
UninstallLogMode=overwrite
UsePreviousGroup=false
AppendDefaultGroupName=false
InternalCompressLevel=ultra64
Compression=lzma/ultra
Minversion=0,6.0.6000
VersionInfoCopyright=GPL
VersionInfoDescription=輕鬆輸入法中型詞庫版 For Windows Vista/7/08 TTS
VersionInfoTextVersion=
AppCopyright=GPL
VersionInfoVersion=1.2.3
LanguageDetectionMethod=uilanguage
ShowLanguageDialog=auto
[Registry]
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{B701BC19-D231-4E14-86D1-46FD6A2CCC5C}; ValueType: string; ValueName: Description; ValueData: 中文 (繁體) - 輕鬆中詞庫; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{B701BC19-D231-4E14-86D1-46FD6A2CCC5C}; ValueType: string; ValueName: IconFile; ValueData: %ProgramFiles%\Windows NT\TableTextService\EasyMid.ico; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{B701BC19-D231-4E14-86D1-46FD6A2CCC5C}; ValueType: dword; ValueName: IconIndex; ValueData: $00000000; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{B701BC19-D231-4E14-86D1-46FD6A2CCC5C}; ValueType: dword; ValueName: Enable; ValueData: $00000000; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{B701BC19-D231-4E14-86D1-46FD6A2CCC5C}; ValueType: string; ValueName: Display Description; ValueData: 中文 (繁體) - 輕鬆中詞庫; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\TableTextService\0x00000404\{{B701BC19-D231-4E14-86D1-46FD6A2CCC5C}; ValueType: string; ValueName: SettingFile; ValueData: %ProgramFiles%\Windows NT\TableTextService\TableTextServiceEasyMid.txt; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Wow6432Node\Microsoft\TableTextService\0x00000404\{{B701BC19-D231-4E14-86D1-46FD6A2CCC5C}; ValueType: string; ValueName: SettingFile; ValueData: %ProgramFiles(x86)%\Windows NT\TableTextService\TableTextServiceEasyMid.txt; Flags: uninsdeletekey; Check: IsWin64
[Languages]
Name: en_US; MessagesFile: compiler:Default.isl
Name: zh_TW; MessagesFile: compiler:Languages\ChineseTrad-2-5.1.11.isl
[CustomMessages]
en_US.ezmidtts=Easy Input Method Middle Phrase
zh_TW.ezmidtts=輕鬆輸入法中型詞庫版
