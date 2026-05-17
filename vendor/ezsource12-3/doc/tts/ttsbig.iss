[Files]
Source: ..\..\Output\tts\TableTextServiceEasyBig.txt; DestDir: {pf32}\Windows NT\TableTextService; MinVersion: 0,6.0.6000
Source: ..\..\artwork\EasyBig.ico; DestDir: {pf32}\Windows NT\TableTextService; MinVersion: 0,6.0.6000
Source: ..\..\Output\tts\TableTextServiceEasyBig.txt; DestDir: {pf64}\Windows NT\TableTextService; Check: IsWin64; MinVersion: 0,6.0.6000
[UninstallDelete]
Name: {pf32}\Windows NT\Windows NT\TableTextService\TableTextServiceEasyBig.txt; Type: files
Name: {pf32}\Windows NT\TableTextService\EasyBig.ico; Type: files
Name: {pf64}\Windows NT\TableTextService\TableTextServiceEasyBig.txt; Type: files; Check: IsWin64
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
UninstallDisplayName={cm:ezbigtts} 1.2.3 TTS
AppName={cm:ezbigtts} For Windows Vista/7/08 TTS
AppVerName={cm:ezbigtts} 1.2.3 TTS
CreateAppDir=false
OutputDir=.
OutputBaseFilename=ezbig12-3_tts
AppID={{4BC7B271-D83A-4E87-BC57-610D7103CCEC}
UninstallFilesDir={win}
UninstallLogMode=overwrite
UsePreviousGroup=false
AppendDefaultGroupName=false
InternalCompressLevel=ultra64
Compression=lzma/ultra
Minversion=0,6.0.6000
VersionInfoCopyright=GPL
VersionInfoDescription=輕鬆輸入法大型詞庫版 For Windows Vista/7/08 TTS
VersionInfoTextVersion=
AppCopyright=GPL
VersionInfoVersion=1.2.3
LanguageDetectionMethod=uilanguage
ShowLanguageDialog=auto
[Registry]
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{62230B3C-2309-4C0B-4744-2D5A300B4E59}; ValueType: string; ValueName: Description; ValueData: 中文 (繁體) - 輕鬆大詞庫; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{62230B3C-2309-4C0B-4744-2D5A300B4E59}; ValueType: string; ValueName: IconFile; ValueData: %ProgramFiles%\Windows NT\TableTextService\EasyBig.ico; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{62230B3C-2309-4C0B-4744-2D5A300B4E59}; ValueType: dword; ValueName: IconIndex; ValueData: $00000000; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{62230B3C-2309-4C0B-4744-2D5A300B4E59}; ValueType: dword; ValueName: Enable; ValueData: $00000000; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\CTF\TIP\{{E429B25A-E5D3-4D1F-9BE3-0C608477E3A1}\LanguageProfile\0x00000404\{{62230B3C-2309-4C0B-4744-2D5A300B4E59}; ValueType: string; ValueName: Display Description; ValueData: 中文 (繁體) - 輕鬆大詞庫; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Microsoft\TableTextService\0x00000404\{{62230B3C-2309-4C0B-4744-2D5A300B4E59}; ValueType: string; ValueName: SettingFile; ValueData: %ProgramFiles%\Windows NT\TableTextService\TableTextServiceEasyBig.txt; Flags: uninsdeletekey
Root: HKLM; SubKey: SOFTWARE\Wow6432Node\Microsoft\TableTextService\0x00000404\{{62230B3C-2309-4C0B-4744-2D5A300B4E59}; ValueType: string; ValueName: SettingFile; ValueData: %ProgramFiles(x86)%\Windows NT\TableTextService\TableTextServiceEasyBig.txt; Flags: uninsdeletekey; Check: IsWin64
[Languages]
Name: en_US; MessagesFile: compiler:Default.isl
Name: zh_TW; MessagesFile: compiler:Languages\ChineseTrad-2-5.1.11.isl
[CustomMessages]
en_US.ezbigtts=Easy Input Method Big Phrase
zh_TW.ezbigtts=輕鬆輸入法大型詞庫版
