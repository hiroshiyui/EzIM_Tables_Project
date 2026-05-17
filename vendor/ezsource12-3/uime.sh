#!/bin/bash

rm -rf ~/.wine/drive_c/windows/system32/ez*.IME
rm -rf ~/.wine/drive_c/windows/system32/ez*.TBL
cp uimetool/x86/miniime.tpl ~/.wine/drive_c/windows/system32
cp uimetool/x86/uniime.dll ~/.wine/drive_c/windows/system32
wine uimetool/x86/uimetool.exe
wine uimetool/x86/uimetool.exe
wine uimetool/x86/uimetool.exe
wine uimetool/x86/uimetool.exe


mv ~/.wine/drive_c/windows/system32/ez*.IME doc/uimetool
mv ~/.wine/drive_c/windows/system32/ez*.TBL doc/uimetool

pushd doc/uimetool

mv ez.IME ez.ime
mv ez.TBL ez.tbl
mv ezPHR.TBL ezphr.tbl 
mv ezPTR.TBL ezptr.tbl
mv ezmid.IME ezmid.ime
mv ezmid.TBL ezmid.tbl 
mv ezmidPHR.TBL ezmidphr.tbl
mv ezmidPTR.TBL ezmidptr.tbl
mv ezsmall.IME ezsmall.ime
mv ezsma.TBL ezsma.tbl 
mv ezsmaPHR.TBL ezsmaphr.tbl
mv ezsmaPTR.TBL ezsmaptr.tbl
mv ezbig.IME ezbig.ime
mv ezbig.TBL ezbig.tbl
mv ezbigPHR.TBL ezbigphr.tbl
mv ezbigPTR.TBL ezbigptr.tbl

wine ../../bin/inno/iscc.exe xp.iss /O../../output/uimetool
wine ../../bin/inno/iscc.exe xpsmall.iss /O../../output/uimetool
wine ../../bin/inno/iscc.exe xpmid.iss /O../../output/uimetool
wine ../../bin/inno/iscc.exe xpbig.iss /O../../output/uimetool

rm -rf *.tbl
rm -rf *.ime
pushd

