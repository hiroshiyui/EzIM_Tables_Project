require "roo"
require "csv"

XLSX     = "vendor/dict_concised_2014_20260325.xlsx"
SRC_BIG  = "vendor/ezsource12-3/origtable/ezbig.orig-utf8.txt"
SRC_ORIG = "vendor/ezsource12-3/origtable/ez.orig-utf8.txt"
OUT      = "data/dict.csv"

word_codes = Hash.new { |h, k| h[k] = [] }
char_codes = Hash.new { |h, k| h[k] = [] }
[SRC_ORIG, SRC_BIG].each do |src|
  File.foreach(src, encoding: "UTF-8") do |line|
    line = line.chomp
    next if line.start_with?("%") || !line.include?("\t")
    code, word = line.split("\t", 2)
    next if word.nil? || word.empty?
    word_codes[word] << code unless word_codes[word].include?(code)
    if word.length == 1
      char_codes[word] << code unless char_codes[word].include?(code)
    end
  end
end

def all_analyses(word, char_codes)
  chars = word.chars
  relevant = [chars.length, 4].min
  relevant_codes = chars.first(relevant).map { |c| char_codes[c] }
  return [] if relevant_codes.any?(&:empty?)

  combos = relevant_codes.reduce([[]]) do |acc, codes|
    acc.flat_map { |prefix| codes.map { |c| prefix + [c] } }
  end

  analyses = combos.map do |picks|
    case chars.length
    when 1
      picks[0][0] + picks[0][-1]
    when 2
      picks[0][0] + picks[0][-1] + picks[1][0] + picks[1][-1]
    else
      picks.map { |c| c[0] }.join
    end
  end

  analyses.uniq
end

xlsx = Roo::Excelx.new(XLSX)
xlsx.default_sheet = xlsx.sheets.first
raise "Unexpected column A header" unless xlsx.row(1).first == "字詞名"

total = 0
matched = 0
analyzed = 0
CSV.open(OUT, "w", force_quotes: true) do |csv|
  csv << ["字詞名", "輕鬆輸入法編碼", "分析可能的輕鬆輸入法編碼", "查無對映的輕鬆輸入法編碼"]
  (2..xlsx.last_row).each do |i|
    word = xlsx.cell(i, "A").to_s
    total += 1
    codes = word_codes[word]
    if !codes.empty?
      matched += 1
      codes.each { |c| csv << [word, c, "", ""] }
    else
      analyses = all_analyses(word, char_codes)
      if analyses.empty?
        csv << [word, "", "", "!"]
      else
        analyzed += 1
        analyses.each { |a| csv << [word, "", a, ""] }
      end
    end
  end
end

puts "Processed #{total} words: #{matched} matched, #{analyzed} analyzed, #{total - matched - analyzed} unresolved"
