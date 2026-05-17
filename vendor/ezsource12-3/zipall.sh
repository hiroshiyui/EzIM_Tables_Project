#!/bin/bash

ver=12
license="doc/license/ezphrase.txt doc/license/gpl.txt"
gcinlist=
ovlist=
scimlist=
oximlist=
uimelist=
ttslist=
ykklist=
ibuslist=

rm -rf output/zip
mkdir -p output/zip

tar cvf - output/gcin/gcin_ez.cin $license $gcinlist| bzip2 -9 -f > output/zip/ez"$ver"_gcin.tar.bz2
tar cvf - output/gcin/gcin_ezsmall.cin $license $gcinlist | bzip2 -9 -f > output/zip/ezsmall"$ver"_gcin.tar.bz2
tar cvf - output/gcin/gcin_ezmid.cin $license $gcinlist | bzip2 -9 -f > output/zip/ezmid"$ver"_gcin.tar.bz2
tar cvf - output/gcin/gcin_ezbig.cin $license $gcinlist | bzip2 -9 > output/zip/ezbig"$ver"_gcin.tar.bz2

zip -9 -j output/zip/ez"$ver"_ov.zip output/ov/ov_ez.cin $license $ovlist
zip -9 -j output/zip/ezsmall"$ver"_ov.zip output/ov/ov_ezsmall.cin $license $ovlist
zip -9 -j output/zip/ezmid"$ver"_ov.zip output/ov/ov_ezmid.cin $license $ovlist
zip -9 -j output/zip/ezbig"$ver"_ov.zip output/ov/ov_ezbig.cin $license $ovlist

zip -9 -j output/zip/ez"$ver"_ykk.zip output/ykk/ykk_ez.cin $license $ykklist
zip -9 -j output/zip/ezsmall"$ver"_ykk.zip output/ykk/ykk_ezsmall.cin $license $ykklist
zip -9 -j output/zip/ezmid"$ver"_ykk.zip output/ykk/ykk_ezmid.cin $license $ykklist
zip -9 -j output/zip/ezbig"$ver"_ykk.zip output/ykk/ykk_ezbig.cin $license $ykklist

tar cvf - output/oxim/oxim_ez.cin $license $oximlist | bzip2 -9 -f > output/zip/ez"$ver"_oxim.tar.bz2
tar cvf - output/oxim/oxim_ezsmall.cin $license $oximlist | bzip2 -9 -f > output/zip/ezsmall"$ver"_oxim.tar.bz2
tar cvf - output/oxim/oxim_ezmid.cin $license $oximlist | bzip2 -9 -f > output/zip/ezmid"$ver"_oxim.tar.bz2
tar cvf - output/oxim/oxim_ezbig.cin $license $oximlist | bzip2 -9 > output/zip/ezbig"$ver"_oxim.tar.bz2

tar cvf - output/scim/EZ.txt.in $license $scimlist | bzip2 -9 -f > output/zip/ez"$ver"_scim.tar.bz2
tar cvf - output/scim/EZ-SMALL.txt.in $license $scimlist | bzip2 -9 -f > output/zip/ezsmall"$ver"_scim.tar.bz2
tar cvf - output/scim/EZ-MID.txt.in $license $scimlist | bzip2 -9 -f > output/zip/ezmid"$ver"_scim.tar.bz2
tar cvf - output/scim/EZ-Big.txt.in $license $scimlist | bzip2 -9 > output/zip/ezbig"$ver"_scim.tar.bz2

tar cvf - output/ibus/ez.txt artwork/ez.svg $license $ibuslist | bzip2 -9 -f > output/zip/ez"$ver"_ibus.tar.bz2
tar cvf - output/ibus/ez-small.txt artwork/ez.svg $license $ibuslist | bzip2 -9 -f > output/zip/ezsmall"$ver"_ibus.tar.bz2
tar cvf - output/ibus/ez-mid.txt artwork/ez.svg $license $ibuslist | bzip2 -9 -f > output/zip/ezmid"$ver"_ibus.tar.bz2
tar cvf - output/ibus/ez-big.txt artwork/ez.svg $license $ibuslist | bzip2 -9 > output/zip/ezbig"$ver"_ibus.tar.bz2

zip -9 -j output/zip/ez"$ver"_uime.zip output/uimetool/uime_ez.txt $license $uimelist 
zip -9 -j output/zip/ezsmall"$ver"_uime.zip output/uimetool/uime_ezsmall.txt $license $uimelist 
zip -9 -j output/zip/ezmid"$ver"_uime.zip output/uimetool/uime_ezmid.txt $license $uimelist 
zip -9 -j output/zip/ezbig"$ver"_uime.zip output/uimetool/uime_ezbig.txt $license $uimelist

zip -9 -j output/zip/ez"$ver"_tts.zip output/tts/TableTextServiceEasy.txt doc/tts/ez32.reg doc/tts/ez64.reg doc/tts/install_ez.txt artwork/Easy.ico $license $ttslist
zip -9 -j output/zip/ezsmall"$ver"_tts.zip output/tts/TableTextServiceEasySmall.txt doc/tts/ezsmall32.reg doc/tts/install_ezsmall.txt doc/tts/ezsmall64.reg artwork/EasySmall.ico $license $ttslist
zip -9 -j output/zip/ezmid"$ver"_tts.zip output/tts/TableTextServiceEasyMid.txt doc/tts/ezmid32.reg doc/tts/ezmid64.reg doc/tts/install_ezmid.txt artwork/EasyMid.ico $license $ttslist
zip -9 -j output/zip/ezbig"$ver"_tts.zip output/tts/TableTextServiceEasyBig.txt doc/tts/ezbig32.reg doc/tts/ezbig64.reg doc/tts/install_ezbig.txt artwork/EasyBig.ico $license $ttslist
zip -9 -j output/zip/ez"$ver"source.zip artwork/* changelog/* doc/* footer/* header/* maintable/* origtable/* script/* 7zall.sh makeall.sh readme.txt zipall.sh


