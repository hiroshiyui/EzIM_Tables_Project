[Files]
Source: ..\..\uimetool\x86\Uimetool.exe; DestDir: {pf32}\Uimetool; DestName: Uimetool.exe; Check: IsWin64; Flags: 64bit
Source: ..\..\uimetool\x64\Uimetool.exe; DestDir: {pf64}\Uimetool; DestName: Uimetool.exe; Check: IsWin64; Flags: 64bit
Source: ..\..\uimetool\x86\miniime.tpl; DestDir: {syswow64}; DestName: miniime.tpl; Check: IsWin64; Flags: 64bit
Source: ..\..\uimetool\x64\miniime.tpl; DestDir: {sys}; Flags: 64bit; DestName: miniime.tpl; Check: IsWin64
Source: ..\..\uimetool\x86\uniime.dll; DestDir: {syswow64}; DestName: uniime.dll; Check: IsWin64; Flags: 64bit
Source: ..\..\uimetool\x64\uniime.dll; DestDir: {sys}; DestName: uniime.dll; Check: IsWin64; Flags: 64bit
Source: ..\..\uimetool\x86\Uimetool.exe; DestDir: {pf32}\Uimetool; DestName: Uimetool.exe; Flags: 32bit
Source: ..\..\uimetool\x86\miniime.tpl; DestDir: {sys}; DestName: miniime.tpl; Flags: 32bit
Source: ..\..\uimetool\x86\uniime.dll; DestDir: {sys}; DestName: uniime.dll; Flags: 32bit
Source: ..\..\uimetool\x86\uimetool.chm; DestDir: {pf32}\Uimetool; Flags: onlyifdoesntexist
Source: ..\..\uimetool\x64\uimetool.chm; DestDir: {pf64}\Uimetool; Flags: onlyifdoesntexist; Check: IsWin64

[Setup]
AppCopyright=Microsoft Corporation
AppName={cm:uimtetool}
AppVerName={cm:uimtetool}
AppVersion=5.2790.3959
MinVersion=0,5.01.2600
InternalCompressLevel=ultra64
SolidCompression=true
Compression=lzma/ultra
ArchitecturesAllowed=x64 x86
ArchitecturesInstallIn64BitMode=x64
AppID={{0D926C3B-F804-4E55-89A4-293CAE3F26B7}
VersionInfoVersion=5.2790.3959
VersionInfoCompany=Microsoft Corporation
VersionInfoCopyright=Microsoft Corporation
VersionInfoProductName=Universal Input Method Editor Tool
VersionInfoProductVersion=5.2790.3959
VersionInfoDescription=Universal Input Method Editor Tool
AppendDefaultGroupName=false
CreateAppDir=true
DefaultDirName={pf32}\Uimetool
DisableProgramGroupPage=true
DisableDirPage=true
OutputDir=.
OutputBaseFilename=uimetool
ShowLanguageDialog=auto
UninstallDisplayName={cm:uimtetool}
UninstallDisplayIcon={pf32}\Uimetool\Uimetool.exe
UsePreviousAppDir=false
UsePreviousGroup=false


[Languages]
Name: en_US; MessagesFile: compiler:Default.isl
Name: zh_TW; MessagesFile: compiler:Languages\ChineseTrad-2-5.1.11.isl

[CustomMessages]
en_US.uimtetool=Universal Input Method Editor Tool
zh_TW.uimtetool=通用輸入法編輯工具
en_US.shortcut=Uimetool
zh_TW.shortcut=通用輸入法編輯工具

[Icons]
Name: {commonprograms}\Accessories\{cm:shortcut}; Filename: {pf32}\Uimetool\Uimetool.exe; IconIndex: 0; WorkingDir: {pf32}\Uimetool; IconFilename: {pf32}\Uimetool\Uimetool.exe
Name: {commonprograms}\Accessories\{cm:shortcut}; Filename: {pf64}\Uimetool\Uimetool.exe; IconIndex: 0; WorkingDir: {pf64}\Uimetool; IconFilename: {pf64}\Uimetool\Uimetool.exe; Check: IsWin64
