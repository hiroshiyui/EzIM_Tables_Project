#!/bin/bash
ver=12
release=-3
rm -rf tmp
mkdir tmp

####################
echo "Making Changelog"
diff -u0Nr origtable/ez.orig-utf8.txt maintable/ez.txt.table > changelog/ez"$ver$release".log
diff -u0Nr origtable/ezsmall.orig-utf8.txt maintable/ezsmall.txt.table > changelog/ezsmall"$ver$release".log
diff -u0Nr origtable/ezmid.orig-utf8.txt maintable/ezmid.txt.table > changelog/ezmid"$ver$release".log
diff -u0Nr origtable/ezbig.orig-utf8.txt maintable/ezbig.txt.table > changelog/ezbig"$ver$release".log
echo "changelog done"

####################
echo "making gcin"

mkdir -p output/gcin
cat header/gcin_ez_header.txt maintable/ez.txt.table footer/gcin_ez_footer.txt > output/gcin/gcin_ez.cin
cat header/gcin_ezsmall_header.txt maintable/ezsmall.txt.table footer/gcin_ez_footer.txt > output/gcin/gcin_ezsmall.cin
cat header/gcin_ezmid_header.txt maintable/ezmid.txt.table footer/gcin_ez_footer.txt > output/gcin/gcin_ezmid.cin
cat header/gcin_ezbig_header.txt maintable/ezbig.txt.table footer/gcin_ez_footer.txt > output/gcin/gcin_ezbig.cin
echo "gcin done"

#################
echo "making ov"

mkdir -p output/ov
cat header/ov_ez_header.txt maintable/ez.txt.table footer/ov_ez_footer.txt > output/ov/ov_ez.cin
cat header/ov_ezsmall_header.txt maintable/ezsmall.txt.table footer/ov_ez_footer.txt > output/ov/ov_ezsmall.cin
cat header/ov_ezmid_header.txt maintable/ezmid.txt.table footer/ov_ez_footer.txt > output/ov/ov_ezmid.cin
cat header/ov_ezbig_header.txt maintable/ezbig.txt.table footer/ov_ez_footer.txt > output/ov/ov_ezbig.cin
echo "ov done"

#################
echo "making Yahoo! KeyKey"

mkdir -p output/ykk
cat header/ykk_ez_header.txt maintable/ez.txt.table footer/ykk_ez_footer.txt > output/ykk/ykk_ez.cin
cat header/ykk_ezsmall_header.txt maintable/ezsmall.txt.table footer/ykk_ez_footer.txt > output/ykk/ykk_ezsmall.cin
cat header/ykk_ezmid_header.txt maintable/ezmid.txt.table footer/ykk_ez_footer.txt > output/ykk/ykk_ezmid.cin
cat header/ykk_ezbig_header.txt maintable/ezbig.txt.table footer/ykk_ez_footer.txt > output/ykk/ykk_ezbig.cin
echo "Yahoo! KeyKey done"


###################
echo "making oxim"

mkdir -p output/oxim
cat header/oxim_ez_header.txt maintable/ez.txt.table footer/oxim_ez_footer.txt > output/oxim/oxim_ez.cin
cat header/oxim_ezsmall_header.txt maintable/ezsmall.txt.table footer/oxim_ez_footer.txt > output/oxim/oxim_ezsmall.cin
cat header/oxim_ezmid_header.txt maintable/ezmid.txt.table footer/oxim_ez_footer.txt > output/oxim/oxim_ezmid.cin
cat header/oxim_ezbig_header.txt maintable/ezbig.txt.table footer/oxim_ez_footer.txt > output/oxim/oxim_ezbig.cin
echo "oxim done"

##################
echo "making scim"

mkdir -p output/scim
cat header/scim_ez_header.txt maintable/ez.txt.table footer/scim_ez_footer.txt > output/scim/EZ.txt.in
cat header/scim_ezsmall_header.txt maintable/ezsmall.txt.table footer/scim_ez_footer.txt > output/scim/EZ-SMALL.txt.in
cat header/scim_ezmid_header.txt maintable/ezmid.txt.table footer/scim_ez_footer.txt > output/scim/EZ-MID.txt.in
cat header/scim_ezbig_header.txt maintable/ezbig.txt.table footer/scim_ez_footer.txt > output/scim/EZ-Big.txt.in
echo "scim done"

##################
echo "making ibus"

mkdir -p output/ibus
cat maintable/ez.txt.table | sed 's/$/\t1000/g' > tmp/ez.ibus.tmp
cat maintable/ezsmall.txt.table | sed 's/$/\t1000/g' > tmp/ezsmall.ibus.tmp
cat maintable/ezmid.txt.table | sed 's/$/\t1000/g' > tmp/ezmid.ibus.tmp
cat maintable/ezbig.txt.table | sed 's/$/\t1000/g' > tmp/ezbig.ibus.tmp
cat header/ibus_ez_header.txt tmp/ez.ibus.tmp footer/scim_ez_footer.txt > output/ibus/ibus_ez.txt
cat header/ibus_ezsmall_header.txt tmp/ezsmall.ibus.tmp footer/ibus_ez_footer.txt > output/ibus/ibus_ezsmall.txt
cat header/ibus_ezmid_header.txt tmp/ezmid.ibus.tmp footer/ibus_ez_footer.txt > output/ibus/ibus_ezmid.txt
cat header/ibus_ezbig_header.txt tmp/ezbig.ibus.tmp footer/ibus_ez_footer.txt > output/ibus/ibus_ezbig.txt

echo "ibus done"

######################
echo "making uimetool"

mkdir -p output/uimetool
cat header/uime_ez_header.txt maintable/ez.txt.table | sed -e 's/`/\\/g' -e 's/^\//\/\//g' -e "s/$/`echo \\\r`/"  -e 's/^\/\/S/\/S/g' -e 's/c|/c1/g' -e 's/s|/s1/g' > output/uimetool/ez_win-utf8.txt
iconv -f UTF-8 -t UTF-16LE output/uimetool/ez_win-utf8.txt> output/uimetool/uime_ez.txt
rm -rf output/uimetool/ez_win-utf8.txt

cat header/uime_ez_header.txt maintable/ezsmall.txt.table | sed -e 's/`/\\/g' -e 's/^\//\/\//g' -e "s/$/`echo \\\r`/"  -e 's/^\/\/S/\/S/g' -e 's/c|/c1/g' -e 's/s|/s1/g' > output/uimetool/ezsmall_win-utf8.txt
iconv -f UTF-8 -t UTF-16LE output/uimetool/ezsmall_win-utf8.txt> output/uimetool/uime_ezsmall.txt
rm -rf output/uimetool/ezsmall_win-utf8.txt

cat header/uime_ez_header.txt maintable/ezmid.txt.table | sed -e 's/`/\\/g' -e 's/^\//\/\//g' -e "s/$/`echo \\\r`/"  -e 's/^\/\/S/\/S/g' -e 's/c|/c1/g' -e 's/s|/s1/g' > output/uimetool/ezmid_win-utf8.txt
iconv -f UTF-8 -t UTF-16LE output/uimetool/ezmid_win-utf8.txt> output/uimetool/uime_ezmid.txt
rm -rf output/uimetool/ezmid_win-utf8.txt

cat header/uime_ez_header.txt maintable/ezbig.txt.table | sed -e 's/`/\\/g' -e 's/^\//\/\//g' -e "s/$/`echo \\\r`/"  -e 's/^\/\/S/\/S/g' -e 's/c|/c1/g' -e 's/s|/s1/g' > output/uimetool/ezbig_win-utf8.txt
iconv -f UTF-8 -t UTF-16LE output/uimetool/ezbig_win-utf8.txt> output/uimetool/uime_ezbig.txt
rm -rf output/uimetool/ezbig_win-utf8.txt
echo "uimetool done"

##################
echo "making tts"

mkdir -p output/tts/
cat script/cut_street | sed  -e 's/^/s\//g' -e 's/$/\/\/g/g' > tmp/street.tmp
cat script/cut_symbol |sed  -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/^/s\//g' -e 's/$/\/\/g/g' > tmp/symbol.tmp

cat maintable/ez.txt.table | sed -f tmp/street.tmp | sed -f tmp/symbol.tmp | sed -e 's/^*\t\*//g' -e 's/^*.*\t*.*//g' | sed  '/^$/d' | sed -e 's/^/\"/g' -e 's/\t/\"=\"/g' -e 's/$/\"/g' > tmp/ez_table.tmp
cat header/tts_ez_header.txt tmp/ez_table.tmp footer/tts_ez_footer.txt | sed  -e "s/$/`echo \\\r`/"  -e 's/c|/c1/g' -e 's/s|/s1/g' > tmp/ez_win-utf8..tmp
iconv -f UTF-8 -t UTF-16LE tmp/ez_win-utf8..tmp > output/tts/TableTextServiceEasy.txt

cat maintable/ezsmall.txt.table | sed -f tmp/street.tmp | sed -f tmp/symbol.tmp | sed -e 's/^*\t\*//g' -e 's/^*.*\t*.*//g' | sed  '/^$/d' | sed -e 's/^/\"/g' -e 's/\t/\"=\"/g' -e 's/$/\"/g' > tmp/ezsmall_table.tmp
cat header/tts_ezsmall_header.txt tmp/ezsmall_table.tmp footer/tts_ez_footer.txt | sed  -e "s/$/`echo \\\r`/"  -e 's/c|/c1/g' -e 's/s|/s1/g' > tmp/ezsmall_win-utf8..tmp
iconv -f UTF-8 -t UTF-16LE tmp/ezsmall_win-utf8..tmp > output/tts/TableTextServiceEasySmall.txt

cat maintable/ezmid.txt.table | sed -f tmp/street.tmp | sed -f tmp/symbol.tmp | sed -e 's/^*\t\*//g' -e 's/^*.*\t*.*//g' | sed  '/^$/d' | sed -e 's/^/\"/g' -e 's/\t/\"=\"/g' -e 's/$/\"/g' > tmp/ezmid_table.tmp
cat header/tts_ezmid_header.txt tmp/ezmid_table.tmp footer/tts_ez_footer.txt | sed  -e "s/$/`echo \\\r`/"  -e 's/c|/c1/g' -e 's/s|/s1/g' > tmp/ezmid_win-utf8..tmp
iconv -f UTF-8 -t UTF-16LE tmp/ezmid_win-utf8..tmp > output/tts/TableTextServiceEasyMid.txt

cat maintable/ezbig.txt.table | sed -f tmp/street.tmp | sed -f tmp/symbol.tmp | sed -e 's/^*\t\*//g' -e 's/^*.*\t*.*//g' | sed  '/^$/d' | sed -e 's/^/\"/g' -e 's/\t/\"=\"/g' -e 's/$/\"/g' > tmp/ezbig_table.tmp
cat header/tts_ezbig_header.txt tmp/ezbig_table.tmp footer/tts_ez_footer.txt | sed  -e "s/$/`echo \\\r`/"  -e 's/c|/c1/g' -e 's/s|/s1/g' > tmp/ezbig_win-utf8..tmp
iconv -f UTF-8 -t UTF-16LE tmp/ezbig_win-utf8..tmp > output/tts/TableTextServiceEasyBig.txt
echo "tts done"

rm -rf tmp



