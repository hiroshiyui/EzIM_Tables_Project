[Files]
Source: ez\x64\ezbig.ime; DestDir: {sys}; DestName: ezbig.ime; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x64\ezbig.tbl; DestDir: {sys}; DestName: ezbig.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x64\ezbigphr.tbl; DestDir: {sys}; DestName: ezbigphr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x64\ezbigptr.tbl; DestDir: {sys}; DestName: ezbigptr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezbig.ime; DestDir: {syswow64}; DestName: ezbig.ime; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezbig.tbl; DestDir: {syswow64}; DestName: ezbig.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezbigphr.tbl; DestDir: {syswow64}; DestName: ezbigphr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezbigptr.tbl; DestDir: {syswow64}; DestName: ezbigptr.tbl; MinVersion: 0,5.01.2600; Check: IsWin64; Flags: 64bit
Source: ez\x86\ezbig.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit
Source: ez\x86\ezbigphr.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit
Source: ez\x86\ezbigptr.tbl; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit
Source: ez\x86\ezbig.ime; DestDir: {sys}; MinVersion: 0,5.0.2195; Flags: 32bit

[Registry]
Root: HKLM; SubKey: SYSTEM\CurrentControlSet\Control\Keyboard Layouts\E0440404; ValueType: string; ValueName: Ime File; ValueData: ezbig.ime; Flags: uninsdeletekey
Root: HKLM; SubKey: SYSTEM\CurrentControlSet\Control\Keyboard Layouts\E0440404; ValueType: string; ValueName: Layout File; ValueData: kbdus.dll; Flags: uninsdeletekey
Root: HKLM; SubKey: SYSTEM\CurrentControlSet\Control\Keyboard Layouts\E0440404; ValueType: string; ValueName: Layout Text; ValueData: 中文 (繁體) - 輕鬆大詞庫; Flags: uninsdeletekey

[Setup]
SolidCompression=true
AppPublisher=Woodman Tuen
AppPublisherURL=http://input.foruto.com/woodman
AppSupportURL=http://input.foruto.com/woodman
AppUpdatesURL=http://input.foruto.com/woodman
AppVersion=1.2.3
AppContact=wmtuen@gmail.com
UninstallDisplayName={cm:ezbig} 1.2.3
AppName={cm:ezbig} For Windows 2K/XP/03/Vista/7/08 (32/64bit)
AppVerName={cm:ezbig} 1.2.3
OutputDir=.
OutputBaseFilename=ezbig12-3_uime
AppID={{93C4C4B9-B808-4EDF-AD1D-7548F0E7B36C}
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
VersionInfoDescription=輕鬆輸入法大型詞庫版 For Windows 2K/XP/03/Vista/7/08 (32/64bit)
CreateAppDir=false
[Languages]
Name: en_US; MessagesFile: compiler:Default.isl
Name: zh_TW; MessagesFile: compiler:Languages\ChineseTrad-2-5.1.11.isl

[CustomMessages]
en_US.ezbig=Easy Input Method Big Phrase
zh_TW.ezbig=輕鬆輸入法大型詞庫版
