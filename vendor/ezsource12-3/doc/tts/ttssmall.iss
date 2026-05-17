[Files]
Source: ..\..\Output\tts\TableTextServiceEasySmall.txt; DestDir: {pf32}\Windows NT\TableTextService; MinVersion: 0,6.0.6000
Source: ..\..\artwork\EasySmall.ico; DestDir: {pf32}\Windows NT\TableTextService; MinVersion: 0,6.0.6000
Source: ..\..\Output\tts\TableTextServiceEasySmall.txt; DestDir: {pf64}\Windows NT\TableTextService; Check: IsWin64; MinVersion: 0,6.0.6000
[UninstallDelete]
Name: {pf32}\Windows NT\Windows NT\TableTextService\TableTextServiceEasySmall.txt; Type: files
Name: {pf32}\Windows NT\TableTextService\EasySmall.ico; Type: files
Name: {pf64}\Windows NT\TableTextService\TableTextServiceEasySmall.txt; Type: files; Check: IsWin64
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
UninstallDisplayName={cm:ezsmalltts} 1.2.3 TTS
AppName={cm:ezsmalltts} For Windows Vista/7/08 TTS
AppVerName={cm:ezsmalltts} 1.2.3 TTS
CreateAppDir=false
OutputDir=.
OutputBaseFilename=ezsmall12-3_tts
AppID={{F734DBAD-B801-4865-AFA3-3FD794A6A25E}
UninstallFilesDir={win}
UninstallLogMode=overwrite
UsePreviousGroup=false
AppendDefaultGroupName=false
InternalCompressLevel=ultra64
Compression=lzma/ultra
Minversion=0,6.0.6000
VersionInfoCopyright=GPL
VersionInfoDescription=輕鬆輸入法小型詞庫版 For Windows Vista/7/08 TTS
VersionInfoTextVersion=
AppCopyright=GPL
VersionInfoVersion=1.2.3
LanguageDetectionMethod=uilanguage
ShowLanguageDialog=auto
[Registry]
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{9819D3C9-CE74-4FE1-8C96-E055E0107D66}; ValueType: string; ValueName: Description; ValueData: 中文 (繁體) - 輕鬆小詞庫; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{9819D3C9-CE74-4FE1-8C96-E055E0107D66}; ValueType: string; ValueName: IconFile; ValueData: %ProgramFiles%\Windows NT\TableTextService\EasySmall.ico; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{9819D3C9-CE74-4FE1-8C96-E055E0107D66}; ValueType: dword; ValueName: IconIndex; ValueData: $00000000; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{9819D3C9-CE74-4FE1-8C96-E055E0107D66}; ValueType: dword; ValueName: Enable; ValueData: $00000000; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{9819D3C9-CE74-4FE1-8C96-E055E0107D66}; ValueType: string; ValueName: Display Description; ValueData: 中文 (繁體) - 輕鬆小詞庫; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\TableTextService\0x00000404\{{9819D3C9-CE74-4FE1-8C96-E055E0107D66}; ValueType: string; ValueName: SettingFile; ValueData: %ProgramFiles%\Windows NT\TableTextService\TableTextServiceEasySmall.txt; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Wow6432Node\Microsoft\TableTextService\0x00000404\{{9819D3C9-CE74-4FE1-8C96-E055E0107D66}; ValueType: string; ValueName: SettingFile; ValueData: %ProgramFiles(x86)%\Windows NT\TableTextService\TableTextServiceEasySmall.txt; Flags: uninsdeletekey; Check: IsWin64
[Languages]
Name: en_US; MessagesFile: compiler:Default.isl
Name: zh_TW; MessagesFile: compiler:Languages\ChineseTrad-2-5.1.11.isl
[CustomMessages]
en_US.ezsmalltts=Easy Input Method Small Phrase
zh_TW.ezsmalltts=輕鬆輸入法小型詞庫版
