#!/bin/bash
case $1 in

scim)
mkdir -p output/scim
cat header/scim_ez_header.txt maintable/EZ-Big.txt.table footer/scim_ez_footer.txt > output/scim/EZ-Big.txt.in
mkdir -p changelog
echo "###" >> changelog/ezbig_scim_changelog
echo "### 修改記錄：" >> changelog/ezbig_scim_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_scim_changelog
echo "###" >> changelog/ezbig_scim_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/scim/EZ-Big.txt.in >> changelog/ezbig_scim_changelog
;;

oxim)
mkdir -p output/oxim
cat header/oxim_ezbig_header.txt maintable/EZ-Big.txt.table footer/oxim_ez_footer.txt > output/oxim/oxim_ezbig.cin
mkdir -p changelog
echo "###" >> changelog/ezbig_oxim_changelog
echo "### 修改記錄：" >> changelog/ezbig_oxim_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_oxim_changelog
echo "###" >> changelog/ezbig_oxim_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/oxim/ezbig.cin >> changelog/ezbig_oxim_changelog
;;

gcin)
mkdir -p output/gcin
cat header/gcin_ezbig_header.txt maintable/EZ-Big.txt.table footer/gcin_ez_footer.txt > output/gcin/gcin_ezbig.cin
mkdir -p changelog
echo "###" >> changelog/ezbig_gcin_changelog
echo "### 修改記錄：" >> changelog/ezbig_gcin_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_gcin_changelog
echo "###" >> changelog/ezbig_gcin_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/gcin/ezbig.cin >> changelog/ezbig_gcin_changelog
;;

ov)
mkdir -p output/ov
cat header/ov_ezbig_header.txt maintable/EZ-Big.txt.table footer/ov_ez_footer.txt > output/ov/ov_ezbig.cin
echo "###" >> changelog/ezbig_ov_changelog
echo "### 修改記錄：" >> changelog/ezbig_ov_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_ov_changelog
echo "###" >> changelog/ezbig_ov_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/ov/ezbig.cin >> changelog/ezbig_ov_changelog
;;

ykk)
mkdir -p output/ykk
cat header/ykk_ezbig_header.txt maintable/EZ-Big.txt.table footer/ykk_ez_footer.txt > output/ykk/ykk_ezbig.cin
echo "###" >> changelog/ezbig_ykk_changelog
echo "### 修改記錄：" >> changelog/ezbig_ykk_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_ykk_changelog
echo "###" >> changelog/ezbig_ykk_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/ykk/ezbig.cin >> changelog/ezbig_ykk_changelog
;;

ibus)
mkdir -p output/ibus
cat maintable/ezbig.txt.table | sed  's/$/\t1000/g' > output/ibus/ezbig.ibus.tmp
cat header/ibus_ezbig_header.txt output/ibus/ezbig.ibus.tmp footer/ibus_ez_footer.txt > output/ibus/ez-big.txt
mkdir -p changelog
echo "###" >> changelog/ezbig_ibus_changelog
echo "### 修改記錄：" >> changelog/ezbig_ibus_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_ibus_changelog
echo "###" >> changelog/ezbig_ibus_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/ibus/ez-big.txt >> changelog/ezbig_ibus_changelog
;;

uime)
mkdir -p output/uimetool
cat header/uime_ez_header.txt maintable/EZ-Big.txt.table | sed -e 's/`/\\/g' -e 's/^\//\/\//g' -e "s/$/`echo \\\r`/"  -e 's/^\/\/S/\/S/g'> output/uimetool/ez-big_win-utf8.txt
iconv -f UTF-8 -t UTF-16LE output/uimetool/ez-big_win-utf8.txt > output/uimetool/ez-big_win.txt 
mkdir -p changelog
echo "###" >> changelog/ezbig_uimetool_changelog
echo "### 修改記錄：" >> changelog/ezbig_uimetool_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_uimetool_changelog
echo "###" >> changelog/ezbig_uimetool_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/uimetool/ez-big_win-utf8.txt >> changelog/ezbig_uimetool_changelog
rm -rf output/uimetool/ez-big_win-utf8.txt
;;

tts)
mkdir -p output/tts
sh script/sedtts
cat maintmp_4.txt |sed -e 's/^/\"/g' -e 's/\t/\"=\"/g' -e 's/$/\"/g' > output/tts/EZ_TMP.table
cat header/tts_ez_header.txt output/tts/EZ_TMP.table footer/tts_ez_footer.txt | sed  -e "s/$/`echo \\\r`/"  -e 's/c|/c1/g' -e 's/s|/s1/g' > output/tts/ez-big_win-utf8.txt
iconv -f UTF-8 -t UTF-16LE output/tts/ez-big_win-utf8.txt > output/tts/TableTextServiceEasy.txt
mkdir -p changelog
echo "###" >> changelog/ezbig_tts_changelog
echo "### 修改記錄：" >> changelog/ezbig_tts_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_tts_changelog
echo "###" >> changelog/ezbig_tts_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/tts/ez-big_win-utf8.txt >> changelog/ezbig_tts_changelog
rm -rf maintmp_4.txt
rm -rf output/tts/ez-big_win-utf8.txt
rm -rf output/tts/EZ_TMP.table
;;

*)
mkdir -p output/scim
cat header/scim_ezbig_header.txt maintable/EZ-Big.txt.table footer/scim_ez_footer.txt > output/scim/EZ-Big.txt.in
mkdir -p changelog
echo "###" >> changelog/ezbig_scim_changelog
echo "### 修改記錄：" >> changelog/ezbig_scim_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_scim_changelog
echo "###" >> changelog/ezbig_scim_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/scim/EZ-Big.txt.in >> changelog/ezbig_scim_changelog

mkdir -p output/oxim
cat header/oxim_ezbig_header.txt maintable/EZ-Big.txt.table footer/oxim_ez_footer.txt > output/oxim/oxim_ezbig.cin
echo "###" >> changelog/ezbig_oxim_changelog
echo "### 修改記錄：" >> changelog/ezbig_oxim_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_oxim_changelog
echo "###" >> changelog/ezbig_oxim_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/oxim/ezbig.cin >> changelog/ezbig_oxim_changelog

mkdir -p output/gcin
cat header/gcin_ezbig_header.txt maintable/EZ-Big.txt.table footer/gcin_ez_footer.txt > output/gcin/gcin_ezbig.cin
mkdir -p changelog
echo "###" >> changelog/ezbig_gcin_changelog
echo "### 修改記錄：" >> changelog/ezbig_gcin_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_gcin_changelog
echo "###" >> changelog/ezbig_gcin_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/gcin/ezbig.cin >> changelog/ezbig_gcin_changelog

mkdir -p output/ov
cat header/ov_ezbig_header.txt maintable/EZ-Big.txt.table footer/ov_ez_footer.txt > output/ov/ov_ezbig.cin
echo "###" >> changelog/ezbig_ov_changelog
echo "### 修改記錄：" >> changelog/ezbig_ov_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_ov_changelog
echo "###" >> changelog/ezbig_ov_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/ov/ezbig.cin >> changelog/ezbig_ov_changelog

mkdir -p output/ykk
cat header/ykk_ezbig_header.txt maintable/EZ-Big.txt.table footer/ykk_ez_footer.txt > output/ykk/ykk_ezbig.cin
echo "###" >> changelog/ezbig_ykk_changelog
echo "### 修改記錄：" >> changelog/ezbig_ykk_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_ykk_changelog
echo "###" >> changelog/ezbig_ykk_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/ykk/ezbig.cin >> changelog/ezbig_ykk_changelog

mkdir -p output/ibus
cat maintable/ezbig.txt.table | sed  's/$/\t1000/g' > output/ibus/ezbig.ibus.tmp
cat header/ibus_ezbig_header.txt output/ibus/ezbig.ibus.tmp footer/ibus_ez_footer.txt > output/ibus/ez-big.txt
mkdir -p changelog
echo "###" >> changelog/ezbig_ibus_changelog
echo "### 修改記錄：" >> changelog/ezbig_ibus_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_ibus_changelog
echo "###" >> changelog/ezbig_ibus_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/ibus/ez-big.txt >> changelog/ezbig_ibus_changelog

mkdir -p output/uimetool
cat header/uime_ez_header.txt maintable/EZ-Big.txt.table | sed -e 's/`/\\/g' -e 's/^\//\/\//g' -e "s/$/`echo \\\r`/"  -e 's/^\/\/S/\/S/g' -e 's/c|/c1/g' -e 's/s|/s1/g' > output/uimetool/ez-big_win-utf8.txt
iconv -f UTF-8 -t UTF-16LE output/uimetool/ez-big_win-utf8.txt> output/uimetool/ez-big_win.txt
mkdir -p changelog
echo "###" >> changelog/ezbig_uimetool_changelog
echo "### 修改記錄：" >> changelog/ezbig_uimetool_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_uimetool_changelog
echo "###" >> changelog/ezbig_uimetool_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/uimetool/ez-big_win-utf8.txt >> changelog/ezbig_uimetool_changelog
rm -rf output/uimetool/ez-big_win-utf8.txt

mkdir -p output/tts
sh script/sedtts
cat maintmp_4.txt |sed -e 's/^/\"/g' -e 's/\t/\"=\"/g' -e 's/$/\"/g' > output/tts/EZ_TMP.table
cat header/tts_ez_header.txt output/tts/EZ_TMP.table footer/tts_ez_footer.txt | sed  -e "s/$/`echo \\\r`/"  -e 's/c|/c1/g' -e 's/s|/s1/g' > output/tts/ez-big_win-utf8.txt
iconv -f UTF-8 -t UTF-16LE output/tts/ez-big_win-utf8.txt > output/tts/TableTextServiceEasy.txt
mkdir -p changelog
echo "###" >> changelog/ezbig_tts_changelog
echo "### 修改記錄：" >> changelog/ezbig_tts_changelog
echo "###" `date --rfc-3339=date` >> changelog/ezbig_tts_changelog
echo "###" >> changelog/ezbig_tts_changelog
diff -U 0 -Nr origtable/ezbig.orig-utf-8.txt output/tts/ez-big_win-utf8.txt >> changelog/ezbig_tts_changelog
rm -rf maintmp_4.txt
rm -rf output/tts/ez-big_win-utf8.txt
rm -rf output/tts/EZ_TMP.table

exit 1
;;
esac
