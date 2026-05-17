[Files]
Source: ez\x64\ezsmall.ime; DestDir: {sys}; DestName: ezsma.ime; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x64\ezsma.tbl; DestDir: {sys}; DestName: ezsma.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x64\ezsmaphr.tbl; DestDir: {sys}; DestName: ezsmaphr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x64\ezsmaptr.tbl; DestDir: {sys}; DestName: ezsmaptr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezsmall.ime; DestDir: {syswow64}; DestName: ezsma.ime; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezsma.tbl; DestDir: {syswow64}; DestName: ezsma.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezsmaphr.tbl; DestDir: {syswow64}; DestName: ezsmaphr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezsmaptr.tbl; DestDir: {syswow64}; DestName: ezsmaptr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezsma.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit
Source: ez\x86\ezsmaphr.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit
Source: ez\x86\ezsmaptr.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit
Source: ez\x86\ezsmall.ime; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit

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
AppVersion=1.2.3
AppContact=wmtuen@gmail.com
UninstallDisplayName={cm:ezsma} 1.2.3
AppName={cm:ezsma} For Windows 2K/XP/03/Vista/7/08 (32/64bit)
AppVerName={cm:ezsma} 1.2.3
OutputDir=.
OutputBaseFilename=ezsmall12-3_uime
AppID={{D7BF17F3-9257-41B9-9F5C-BE4293D4E1DE}
ShowLanguageDialog=auto
LanguageDetectionMethod=uilanguage
UninstallFilesDir={win}
UninstallLogMode=overwrite
UsePreviousGroup=false
AppendDefaultGroupName=false
InternalCompressLevel=ultra64
VersionInfoCopyright=GPL
MinVersion=0,5.0.2195
ArchitecturesAllowed=x64 x86
ArchitecturesInstallIn64BitMode=x64
VersionInfoVersion=1.2.3
VersionInfoDescription=輕鬆輸入法小型詞庫版 For Windows 2K/XP/03/Vista/7/08 (32/64bit)
CreateAppDir=false
[Languages]
Name: en_US; MessagesFile: compiler:Default.isl
Name: zh_TW; MessagesFile: compiler:Languages\ChineseTrad-2-5.1.11.isl

[CustomMessages]
en_US.ezsma=Easy Input Method Small Phrase
zh_TW.ezsma=輕鬆輸入法小型詞庫版
