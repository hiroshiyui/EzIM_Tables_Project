[Files]
Source: ez\x64\ez.ime; DestDir: {sys}; DestName: ez.ime; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x64\ez.tbl; DestDir: {sys}; DestName: ez.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x64\ezphr.tbl; DestDir: {sys}; DestName: ezphr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x64\ezptr.tbl; DestDir: {sys}; DestName: ezptr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ez.ime; DestDir: {syswow64}; DestName: ez.ime; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ez.tbl; DestDir: {syswow64}; DestName: ez.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezphr.tbl; DestDir: {syswow64}; DestName: ezphr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezptr.tbl; DestDir: {syswow64}; DestName: ezptr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ez.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit
Source: ez\x86\ezphr.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit
Source: ez\x86\ezptr.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit
Source: ez\x86\ez.ime; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit

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
AppContact=wmtuen@gmail.com
OutputDir=.
UsePreviousGroup=false
AppendDefaultGroupName=false
InternalCompressLevel=ultra64
VersionInfoCopyright=GPL
AppID={{A0118F95-EE0D-4B4C-961B-6BD948C86734}
AppVersion=1.2.3
UninstallDisplayName={cm:ez} 1.2.3
AppName={cm:ez} For Windows 2K/XP/03/Vista/7/08 (32/64bit)
AppVerName={cm:ez} 1.2.3
OutputBaseFilename=ez12-3_uime
ShowLanguageDialog=auto
LanguageDetectionMethod=uilanguage
UninstallFilesDir={win}
UninstallLogMode=overwrite
MinVersion=0,5.0.2195
ArchitecturesAllowed=x64 x86
ArchitecturesInstallIn64BitMode=x64
VersionInfoVersion=1.2.3
VersionInfoDescription=輕鬆輸入法單字版 For Windows 2K/XP/03/Vista/7/08 (32/64bit)
CreateAppDir=false
[Languages]
Name: en_US; MessagesFile: compiler:Default.isl
Name: zh_TW; MessagesFile: compiler:Languages\ChineseTrad-2-5.1.11.isl

[CustomMessages]
en_US.ez=Easy Input Method
zh_TW.ez=輕鬆輸入法單字版
