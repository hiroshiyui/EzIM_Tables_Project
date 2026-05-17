[Files]
Source: ez.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195
Source: ezphr.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195
Source: ezptr.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195
Source: ez.ime; DestDir: {sys}; MinVersion: 0,5.0.2195
[Registry]
Root: HKLM; SubKey: SYSTEM\CurrentControlSet\Control\Keyboard Layouts\E0450404; ValueType: string; ValueName: Ime File; ValueData: ez.ime; Flags: uninsdeletekey
Root: HKLM; SubKey: SYSTEM\CurrentControlSet\Control\Keyboard Layouts\E0450404; ValueType: string; ValueName: Layout File; ValueData: kbdus.dll; Flags: uninsdeletekey
Root: HKLM; SubKey: SYSTEM\CurrentControlSet\Control\Keyboard Layouts\E0450404; ValueType: string; ValueName: Layout Text; ValueData: 中文 (繁體) - 輕鬆; Flags: uninsdeletekey
[Setup]
SolidCompression=true
AppPublisher=Woodman Tuen
AppPublisherURL=http://input.foruto.com/woodman
AppSupportURL=http://input.foruto.com/woodman
AppUpdatesURL=http://input.foruto.com/woodman
AppVersion=1.2
AppContact=wmtuen@gmail.com
UninstallDisplayName=輕鬆輸入法單字版 1.2 For Windows XP/2000
AppName=輕鬆輸入法單字版 For Windows XP/2000
AppVerName=輕鬆輸入法單字版 1.2
CreateAppDir=false
OutputDir=.
OutputBaseFilename=ez12_uime
AppID={{A0118F95-EE0D-4B4C-961B-6BD948C86734}
ShowLanguageDialog=no
LanguageDetectionMethod=locale
UninstallFilesDir={win}
UninstallLogMode=overwrite
UsePreviousGroup=false
AppendDefaultGroupName=false
InternalCompressLevel=ultra64
VersionInfoCopyright=GPL
MinVersion=0,5.0.2195
ArchitecturesAllowed=x86
VersionInfoVersion=1.2
VersionInfoDescription=輕鬆輸入法單字版 For XP/2000
[Languages]
Name: zh_TW; MessagesFile: compiler:Languages\ChineseTrad-2-5.1.11.isl
