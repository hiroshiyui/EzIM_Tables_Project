[Files]
Source: ez\x64\ezmid.ime; DestDir: {sys}; DestName: ezmid.ime; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x64\ezmid.tbl; DestDir: {sys}; DestName: ezmid.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x64\ezmidphr.tbl; DestDir: {sys}; DestName: ezmidphr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x64\ezmidptr.tbl; DestDir: {sys}; DestName: ezmidptr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezmid.ime; DestDir: {syswow64}; DestName: ezmid.ime; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezmid.tbl; DestDir: {syswow64}; DestName: ezmid.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezmidphr.tbl; DestDir: {syswow64}; DestName: ezmidphr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezmidptr.tbl; DestDir: {syswow64}; DestName: ezmidptr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezmid.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit
Source: ez\x86\ezmidphr.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit
Source: ez\x86\ezmidptr.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit
Source: ez\x86\ezmid.ime; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit

[Registry]
Root: HKLM; SubKey: SYSTEM\CurrentControlSet\Control\Keyboard Layouts\E0470404; ValueType: string; ValueName: Ime File; ValueData: ezmid.ime; Flags: uninsdeletekey
Root: HKLM; SubKey: SYSTEM\CurrentControlSet\Control\Keyboard Layouts\E0470404; ValueType: string; ValueName: Layout File; ValueData: kbdus.dll; Flags: uninsdeletekey
Root: HKLM; SubKey: SYSTEM\CurrentControlSet\Control\Keyboard Layouts\E0470404; ValueType: string; ValueName: Layout Text; ValueData: 中文 (繁體) - 輕鬆中詞庫; Flags: uninsdeletekey
[Setup]
SolidCompression=true
AppPublisher=Woodman Tuen
AppPublisherURL=http://input.foruto.com/woodman
AppSupportURL=http://input.foruto.com/woodman
AppUpdatesURL=http://input.foruto.com/woodman
AppVersion=1.2.3
AppContact=wmtuen@gmail.com
UninstallDisplayName={cm:ezmid} 1.2.3
AppName={cm:ezmid} For Windows 2K/XP/03/Vista/7/08 (32/64bit)
AppVerName={cm:ezmid} 1.2.3
OutputDir=.
OutputBaseFilename=ezmid12-3_uime
AppID={{5CEBCF9C-7F19-4F6F-9505-D26B87F57C07}
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
VersionInfoDescription=輕鬆輸入法中型詞庫版 For Windows 2K/XP/03/Vista/7/08 (32/64bit)
CreateAppDir=false
[Languages]
Name: en_US; MessagesFile: compiler:Default.isl
Name: zh_TW; MessagesFile: compiler:Languages\ChineseTrad-2-5.1.11.isl

[CustomMessages]
en_US.ezmid=Easy Input Method Middle Phrase
zh_TW.ezmid=輕鬆輸入法中型詞庫版
