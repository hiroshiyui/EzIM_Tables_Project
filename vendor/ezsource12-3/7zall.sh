#!/bin/bash

ver=12
release=3
license="doc/license/ezphrase.txt doc/license/gpl.txt"
zab="7za a -tbzip2 -mx=9 -mpass=7"
zaz="7za a -tzip -mx=9 -mpass=15"
zat="tar cvf"
outpath="output/zip"
gcinout="output/gcin"
oximout="output/oxim"
scimout="output/scim"
ibusout="output/ibus"
ovout="output/ov"
uimeout="output/uimetool"
ykkout="output/ykk"
ttsout="output/tts"
ttsdoc="doc/tts"
ykkdoc="doc/ykk"

rm -rf $outpath
mkdir -p $outpath

$zat $outpath/ez"$ver"-"$release"_gcin.tar $gcinout/gcin_ez.cin $license
$zab $outpath/ez"$ver"-"$release"_gcin.tar.bz2 $outpath/ez"$ver"-"$release"_gcin.tar
rm $outpath/ez"$ver"-"$release"_gcin.tar
$zat $outpath/ezsmall"$ver"-"$release"_gcin.tar $gcinout/gcin_ezsmall.cin $license
$zab $outpath/ezsmall"$ver"-"$release"_gcin.tar.bz2 $outpath/ezsmall"$ver"-"$release"_gcin.tar
rm $outpath/ezsmall"$ver"-"$release"_gcin.tar
$zat $outpath/ezmid"$ver"-"$release"_gcin.tar $gcinout/gcin_ezmid.cin $license
$zab $outpath/ezmid"$ver"-"$release"_gcin.tar.bz2 $outpath/ezmid"$ver"-"$release"_gcin.tar
rm $outpath/ezmid"$ver"-"$release"_gcin.tar
$zat $outpath/ezbig"$ver"-"$release"_gcin.tar $gcinout/gcin_ezbig.cin $license
$zab $outpath/ezbig"$ver"-"$release"_gcin.tar.bz2 $outpath/ezbig"$ver"-"$release"_gcin.tar
rm $outpath/ezbig"$ver"-"$release"_gcin.tar

$zat $outpath/ez"$ver"-"$release"_oxim.tar $oximout/oxim_ez.cin $license
$zab $outpath/ez"$ver"-"$release"_oxim.tar.bz2 $outpath/ez"$ver"-"$release"_oxim.tar
rm $outpath/ez"$ver"-"$release"_oxim.tar
$zat $outpath/ezsmall"$ver"-"$release"_oxim.tar $oximout/oxim_ezsmall.cin $license
$zab $outpath/ezsmall"$ver"-"$release"_oxim.tar.bz2 $outpath/ezsmall"$ver"-"$release"_oxim.tar
rm  $outpath/ezsmall"$ver"-"$release"_oxim.tar
$zat $outpath/ezmid"$ver"-"$release"_oxim.tar $oximout/oxim_ezmid.cin $license
$zab $outpath/ezmid"$ver"-"$release"_oxim.tar.bz2 $outpath/ezmid"$ver"-"$release"_oxim.tar
rm  $outpath/ezmid"$ver"-"$release"_oxim.tar
$zat $outpath/ezbig"$ver"-"$release"_oxim.tar $oximout/oxim_ezbig.cin $license
$zab $outpath/ezbig"$ver"-"$release"_oxim.tar.bz2 $outpath/ezbig"$ver"-"$release"_oxim.tar
rm  $outpath/ezbig"$ver"-"$release"_oxim.tar

$zat $outpath/ez"$ver"-"$release"_scim.tar $scimout/EZ.txt.in $license
$zab $outpath/ez"$ver"-"$release"_scim.tar.bz2 $outpath/ez"$ver"-"$release"_scim.tar
rm $outpath/ez"$ver"-"$release"_scim.tar
$zat $outpath/ezsmall"$ver"-"$release"_scim.tar $scimout/EZ-SMALL.txt.in $license
$zab $outpath/ezsmall"$ver"-"$release"_scim.tar.bz2 $outpath/ezsmall"$ver"-"$release"_scim.tar
rm $outpath/ezsmall"$ver"-"$release"_scim.tar
$zat $outpath/ezmid"$ver"-"$release"_scim.tar $scimout/EZ-MID.txt.in $license
$zab $outpath/ezmid"$ver"-"$release"_scim.tar.bz2 $outpath/ezmid"$ver"-"$release"_scim.tar
rm $outpath/ezmid"$ver"-"$release"_scim.tar
$zat $outpath/ezbig"$ver"-"$release"_scim.tar $scimout/EZ-Big.txt.in $license
$zab $outpath/ezbig"$ver"-"$release"_scim.tar.bz2 $outpath/ezbig"$ver"-"$release"_scim.tar
rm $outpath/ezbig"$ver"-"$release"_scim.tar

$zat $outpath/ez"$ver"-"$release"_ibus.tar $ibusout/ez.txt artwork/ez.svg $license
$zab $outpath/ez"$ver"-"$release"_ibus.tar.bz2 $outpath/ez"$ver"-"$release"_ibus.tar
rm $outpath/ez"$ver"-"$release"_ibus.tar
$zat $outpath/ezsmall"$ver"-"$release"_ibus.tar $ibusout/ez-small.txt artwork/ez.svg $license
$zab $outpath/ezsmall"$ver"-"$release"_ibus.tar.bz2 $outpath/ezsmall"$ver"-"$release"_ibus.tar
rm  $outpath/ezsmall"$ver"-"$release"_ibus.tar
$zat $outpath/ezmid"$ver"-"$release"_ibus.tar $ibusout/ez-mid.txt artwork/ez.svg $license
$zab $outpath/ezmid"$ver"-"$release"_ibus.tar.bz2 $outpath/ezmid"$ver"-"$release"_ibus.tar
rm $outpath/ezmid"$ver"-"$release"_ibus.tar
$zat $outpath/ezbig"$ver"-"$release"_ibus.tar $ibusout/ez-big.txt artwork/ez.svg $license
$zab $outpath/ezbig"$ver"-"$release"_ibus.tar.bz2 $outpath/ezbig"$ver"-"$release"_ibus.tar
rm $outpath/ezbig"$ver"-"$release"_ibus.tar

$zaz $outpath/ez"$ver"-"$release"_ov.zip $ovout/ov_ez.cin $license $ovlist
$zaz $outpath/ezsmall"$ver"-"$release"_ov.zip $ovout/ov_ezsmall.cin $license
$zaz $outpath/ezmid"$ver"-"$release"_ov.zip $ovout/ov_ezmid.cin $license
$zaz $outpath/ezbig"$ver"-"$release"_ov.zip $ovout/ov_ezbig.cin $license

$zaz $outpath/ez"$ver"-"$release"_ykk.zip $ykkout/ykk_ez.cin $license $ykkdoc/install.txt
$zaz $outpath/ezsmall"$ver"-"$release"_ykk.zip $ykkout/ykk_ezsmall.cin $license $ykkdoc/install.txt
$zaz $outpath/ezmid"$ver"-"$release"_ykk.zip $ykkout/ykk_ezmid.cin $license $ykkdoc/install.txt
$zaz $outpath/ezbig"$ver"-"$release"_ykk.zip $ykkout/ykk_ezbig.cin $license $ykkdoc/install.txt
$zaz $outpath/ez"$ver"-"$release"_uime.zip $uimeout/uime_ez.txt $license
$zaz $outpath/ezsmall"$ver"-"$release"_uime.zip $uimeout/uime_ezsmall.txt $license
$zaz $outpath/ezmid"$ver"-"$release"_uime.zip $uimeout/uime_ezmid.txt $license
$zaz $outpath/ezbig"$ver"-"$release"_uime.zip $uimeout/uime_ezbig.txt $license

$zaz $outpath/ez"$ver"-"$release"_tts.zip $ttsout/TableTextServiceEasy.txt $ttsdoc/ez32.reg $ttsdoc/ez64.reg $ttsdoc/install_ez.txt artwork/Easy.ico $license
$zaz $outpath/ezsmall"$ver"-"$release"_tts.zip $ttsout/TableTextServiceEasySmall.txt $ttsdoc/ezsmall32.reg $ttsdoc/install_ezsmall.txt $ttsdoc/ezsmall64.reg artwork/EasySmall.ico $license
$zaz $outpath/ezmid"$ver"-"$release"_tts.zip $ttsout/TableTextServiceEasyMid.txt $ttsdoc/ezmid32.reg $ttsdoc/ezmid64.reg $ttsdoc/install_ezmid.txt artwork/EasyMid.ico $license
$zaz $outpath/ezbig"$ver"-"$release"_tts.zip $ttsout/TableTextServiceEasyBig.txt $ttsdoc/ezbig32.reg $ttsdoc/ezbig64.reg $ttsdoc/install_ezbig.txt artwork/EasyBig.ico $license
$zaz $outpath/ezsource"$ver"-"$release".zip artwork bin changelog doc footer header maintable origtable script 7zall.sh makeall.sh readme.txt zipall.sh inno.sh uimetool.sh uime.sh
$zaz $outpath/uimetool.zip uimetool


