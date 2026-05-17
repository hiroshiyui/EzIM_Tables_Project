README

-----------
一) 簡介
-----------

本套件是一個製作簡陋的輸入法表格生成套件，主要是自動產生輕鬆輸入法的輸入法表格。
本套件會產生的表格有：

1. SCIM
2. Open Vanilla
3. gcin
4. oxim
5. uime(在 Windows XP/2000/2003 繁體中文版使用的輸入法引擎）
6. Table Driven Text Service (在 Windows Vista/7 中使用的輸入法引擎)
7. Yahoo! KeyKey 奇摩輸入法
8. IBus


-------------
二) 版權
-------------

本套件中的檔案，皆受其自身所附帶的版權合約所規範：
1. innosetup，以其 http://www.innosetup.com/files/is/license.txt 的條約作規限
2. 輕鬆輸入法，則受 GPL V2或更新的版本及《輕鬆資訊「輕鬆輸入法大詞庫」公眾授權書》的保護
3. 其餘所有在本套件中本人編寫的檔案，皆以GPL V2或更新的版本發佈

-------------
三）基本要求
-------------

本套件只為簡單的幾個 script，
但要在 Unix/Linux 或 cygwin, Msys 等 bash shell 環境下執行。

-------------
四)目錄說明
-------------

1. artwork

圖示與圖片


2. changlog
記錄修改記錄的地方，但由於 changelog 太大
已將 changelog移除

3. doc
存放一些已製作好的檔案，innosetup iss，授權書等的地方

4. footer
輸入法表格底部

5. header
輸入法表格底部的上部，通常用作鍵盤定義等。

6. origtable
原輕鬆輸入法表格的 utf-8版

7. output
存放輸出檔案的地方

8. script
一些 script



---------------
五) 使用方法
---------------

1. 執行 makall.sh 後，便會在 output 中，產生各平台的輕鬆輸入法表格。
2. 執行 zipall.sh 則會將所有 output 中的檔案壓縮
