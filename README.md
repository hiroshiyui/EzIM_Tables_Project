# 輕鬆輸入法字詞編碼表整理工程

由教育部《國語辭典簡編本》（`dict_concised_2014_20260325.xlsx`）的「字詞名」欄位，對照輕鬆輸入法原始編碼表（`ezsource12-3/origtable/`），產生一份完整的「字詞 → 輕鬆輸入法編碼」對映表 `dict.csv`。

## 使用方式

教育部辭典與輕鬆輸入法原始編碼表皆以壓縮檔形式收錄，執行前請先解壓縮。注意 `ezsource12-3.zip` 內部並無 `ezsource12-3/` 頂層目錄，需透過 `-d` 指定解壓縮目標目錄：

```sh
unzip dict_concised_2014_20260325.zip
unzip -d ezsource12-3 ezsource12-3.zip
bundle install
bundle exec ruby build_dict.rb
```

產出 `dict.csv`，包含四個欄位：

| 欄位 | 說明 |
| --- | --- |
| 字詞名 | 來自教育部辭典的字或詞 |
| 輕鬆輸入法編碼 | 於原始編碼表中直接查得的編碼（一對多時，一組編碼一列） |
| 分析可能的輕鬆輸入法編碼 | 當「輕鬆輸入法編碼」無直接對映時，依取碼規則列舉所有可能的組合 |
| 查無對映的輕鬆輸入法編碼 | 上兩欄皆無對映時，以 `!` 標記 |

## 資料來源與查詢順序

1. **`ez.orig-utf8.txt`**：單字編碼最完整，優先查詢。
2. **`ezbig.orig-utf8.txt`**：補強單字編碼，主要用於詞組查詢。

## 取碼規則

詳見 [`CLAUDE.md`](CLAUDE.md)。摘要：

- 單字：頭 + 尾
- 二字詞：各字頭 + 尾
- 三字詞：各字頭
- 四字以上：前四字頭（最多 4 碼）
- 字詞有多組編碼時：基於前述規則，取各種可能的編碼組合

## 產出統計

目前自 45,131 筆字詞中：

- 直接對映：**45,131**
- 規則推導：0
- 查無對映：0

> 起初僅 39,580 筆有直接對映、5,532 筆需規則推導、19 筆完全查無對映。經過下列補強後達成 100% 直接對映：
>
> - 補入 11 個原始編碼表缺漏的單字（礴、疱、酶、髴、肽、䠷、擀、焿、彞、吔、〇、浜），推理過程與規則整理於 [`CLAUDE.md`](CLAUDE.md) 之「缺漏字元編碼推理規則」一節。
> - 將原本由 `build_dict.rb` 規則推導出的 5,541 組詞組編碼，透過 `sync_ezbig.rb` 寫回 `ezbig.orig-utf8.txt`。

## 檔案

### 字詞編碼表整理（Ruby）

- `build_dict.rb` — 主要建構腳本：讀取 xlsx 與兩個原始編碼表，產出 `dict.csv`
- `sync_ezbig.rb` — 維護腳本：將 `dict.csv` 中規則推導出的編碼寫回 `ezbig.orig-utf8.txt`
- `sort_tables.rb` — 維護腳本：依編碼穩定排序 `ez.orig-utf8.txt` 與 `ezbig.orig-utf8.txt`（保留同碼字元的原始順序）
- `CLAUDE.md` — 取碼規則與缺漏字元推理規則
- `Gemfile` / `Gemfile.lock` — 依賴（`roo` 讀取 xlsx、`tomlrb` 讀取 toml）
- `.ruby-version` / `.ruby-gemset` — rvm 設定

### 鍵盤與字根圖（Ruby + SVG）

- `make_ez_root_images.rb` — 依 `roots_image_definition.toml` 自 `makemeahanzi/` 子模組擷取／合成字根 SVG，輸出至 `ez_root_images/`
- `make_ez_keyboard.rb` — 將 `ez_root_images/` 套入 `qwerty_keyboard_template.svg`，產生標註字根的 `ez_keyboard.svg` 與 `ez_keyboard_plain.svg`
- `roots_image_definition.toml` — 每鍵字根定義（direct / fallback / descriptive / missing）
- `makemeahanzi/` — git 子模組，提供漢字筆畫 SVG 來源（執行前請 `git submodule update --init`）

### 資料檔

- `dict_concised_2014_20260325.zip` — 教育部《國語辭典簡編本》壓縮檔（需解壓縮出 `dict_concised_2014_20260325.xlsx` 後使用）
- `ezsource12-3.zip` — 輕鬆輸入法原始編碼表壓縮檔（需解壓縮為 `ezsource12-3/` 後使用）
- `85rest01.csv` / `85rest02.csv` — 教育部《八十五年常用語詞調查報告》字頻／詞頻總表，供 `libezim` 建立候選字排序權重
- `ezphrase.txt` / `gpl.txt` — 輕鬆輸入法大詞庫授權文件

### 子專案

- `libezim/` — Rust 實作的輕鬆輸入法引擎（C ABI），**開發中、尚未可用於正式環境**，詳見下節

## libezim — Rust 輕鬆輸入法引擎

> ⚠️ **Work in progress — not production-ready.**
> 目前仍處於早期開發階段：API、`.dat` 檔格式、C ABI 皆可能變動，尚未發佈穩定版本，也尚未整合進任何 iBus／Fcitx 引擎（見 [`libezim/TODOs.md`](libezim/TODOs.md)）。請勿用於正式環境，僅供開發測試與檢視。

`libezim/` 為一獨立 Cargo workspace，將本專案整理出的編碼表轉成可供 IME 框架（iBus、Fcitx5、TSF 等）嵌入的二進位資料檔與動態函式庫。設計細節見 [`libezim/DESIGN.md`](libezim/DESIGN.md)，待辦事項見 [`libezim/TODOs.md`](libezim/TODOs.md)。

主要 crate：

- `ezim-core` — 取碼規則、二進位 `.dat` 格式讀寫（mmap、zero-copy）
- `ezim-table-builder` — 將 `ez.orig-utf8.txt` 編成 `ez.dat`，並以 `85rest01.csv` / `85rest02.csv` 產生 `char-weights.dat` / `phrase-weights.dat`
- `ezim-session` — 編輯緩衝、候選字管理（已整合字頻／詞頻權重排序）
- `ezim-capi` — 對外公開的 C ABI（標頭檔 `libezim/headers/ezim.h`）
- `ezim-cli` — 互動式查詢／檢視 `.dat` 的命令列工具

典型流程：

```sh
cd libezim
cargo build --release
# 編譯資料檔
target/release/ezim-table-builder build          ../ezsource12-3/origtable/ez.orig-utf8.txt ez.dat
target/release/ezim-table-builder weights        ../85rest01.csv char-weights.dat
target/release/ezim-table-builder phrase-weights ../85rest02.csv phrase-weights.dat
```

## 維護工作流程

當教育部辭典更新或發現新的缺漏字元時，可依下列流程重整資料：

1. 重跑 `bundle exec ruby build_dict.rb`，檢視 `dict.csv` 第三欄（規則推導）與第四欄（查無對映）。
2. 對於查無對映的字元，依 [`CLAUDE.md`](CLAUDE.md) 的推理流程補入 `ezsource12-3/origtable/ez.orig-utf8.txt`。
3. 重跑 `bundle exec ruby build_dict.rb` 確認無未解項。
4. 執行 `bundle exec ruby sync_ezbig.rb` 將推導結果寫回 `ezbig.orig-utf8.txt`。
5. （可選）執行 `bundle exec ruby sort_tables.rb` 重新分組同碼字元。
6. 將更新後的兩個原始編碼表重新打包進 `ezsource12-3.zip`：`(cd ezsource12-3 && zip ../ezsource12-3.zip origtable/ez.orig-utf8.txt origtable/ezbig.orig-utf8.txt)`

## 授權與版權

本專案整合兩項第三方資料，各依其原始授權：

### 輕鬆輸入法大詞庫（`ezsource12-3/`）

版權所有 © 1999 輕鬆資訊企業社（統一編號：70942237，負責人：高衡緒）。

依《輕鬆資訊「輕鬆輸入法大詞庫」公眾授權書》v1.0（1999-10-23 公布）發佈，標的物軟體同時遵照 [GNU General Public License v2](gpl.txt) 或更新版本之條款重製、修改與散布。完整授權條款請見：

- [`ezphrase.txt`](ezphrase.txt) — 輕鬆資訊公眾授權書
- [`gpl.txt`](gpl.txt) — GNU GPL v2

### 教育部《國語辭典簡編本》

版權所有 © 中華民國教育部（Ministry of Education, R.O.C.）。

本辭典採用「[創用 CC－姓名標示－禁止改作 臺灣 3.0 版授權條款](http://creativecommons.org/licenses/by-nd/3.0/tw/legalcode)」（CC BY-ND 3.0 TW）釋出。詳細授權說明請參閱：

<https://language.moe.gov.tw/001/Upload/Files/site_content/M0001/respub/conciseddict_10312.pdf>

依授權條款要求，「姓名標示」請依下列格式標示：

> 中華民國教育部（Ministry of Education, R.O.C.）。《國語辭典簡編本》（版本編號：`2014_20260325`）網址：<http://dict.concised.moe.edu.tw/>

**注意**：CC BY-ND 3.0 TW 授權**禁止改作**。本專案為建立「字詞 → 輕鬆輸入法編碼」對照關係，僅引用原辭典之「字詞名」欄位做為查詢鍵，未改動或重新發布原辭典內容。若您要散布修改後之辭典內容，須另行取得教育部同意。

### 教育部《八十五年常用語詞調查報告》字頻／詞頻總表（`85rest01.csv`、`85rest02.csv`）

版權所有 © 中華民國教育部（Ministry of Education, R.O.C.）。

來源：[政府資料開放平臺 ── 八十五年常用語詞調查報告](https://data.nat.gov.tw/dataset/45518)。

- `85rest01.csv` ── 字頻總表
- `85rest02.csv` ── 詞頻總表

本資料集依政府資料開放平臺之開放資料授權條款公開釋出。引用時請標示：

> 中華民國教育部（Ministry of Education, R.O.C.）。《八十五年常用語詞調查報告——字頻總表／詞頻總表》。資料來源：政府資料開放平臺，<https://data.nat.gov.tw/dataset/45518>。

### 本專案之整理成果

`build_dict.rb`、`sync_ezbig.rb`、`sort_tables.rb` 與衍生之 `dict.csv` 同樣以 GNU GPL v2（或更新版本）授權發佈，以與輕鬆輸入法大詞庫之授權相容。
