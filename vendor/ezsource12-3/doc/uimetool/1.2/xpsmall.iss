[Files]
Source: ezsma.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195
Source: ezsmaphr.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195
Source: ezsmaptr.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195
Source: ezsmall.ime; DestDir: {sys}; MinVersion: 0,5.0.2195
[Registry]
Root: HKLM; SubKey: SYSTEM\CurrentControlSet\Control\Keyboard Layouts\E0460404; ValueType: string; ValueName: Ime File; ValueData: ezsmall.ime; Flags: uninsdeletekey
Root: HKLM; SubKey: SYSTEM\CurrentControlSet\Control\Keyboard Layouts\E0460404; ValueType: string; ValueName: Layout File; ValueData: kbdus.dll; Flags: uninsdeletekey
Root: HKLM; SubKey: SYSTEM\CurrentControlSet\Control\Keyboard Layouts\E0460404; ValueType: string; ValueName: Layout Text; ValueData: 中文 (繁體) - 輕鬆小詞庫; Flags: uninsdeletekey
[Setup]
SolidCompression=true
AppPublisher=Woodman Tuen
AppPublisherURL=http://input.foruto.com/woodman
AppSupportURL=http://input.foruto.com/woodman
AppUpdatesURL=http://input.foruto.com/woodman
AppVersion=1.2
AppContact=wmtuen@gmail.com
UninstallDisplayName=輕鬆輸入法小型詞庫版 1.2 For Windows XP/2000
AppName=輕鬆輸入法小型詞庫版 For Windows XP/2000
AppVerName=輕鬆輸入法小型詞庫版 1.2
CreateAppDir=false
OutputDir=.
OutputBaseFilename=ezsmall12_uime
AppID={{D7BF17F3-9257-41B9-9F5C-BE4293D4E1DE}
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
VersionInfoDescription=輕鬆輸入法小型詞庫版 For XP/2000
[Languages]
Name: zh_TW; MessagesFile: compiler:Languages\ChineseTrad-2-5.1.11.isl
