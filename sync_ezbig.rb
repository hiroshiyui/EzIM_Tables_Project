require "csv"
require "set"

EZBIG = "ezsource12-3/origtable/ezbig.orig-utf8.txt"
DICT  = "dict.csv"

existing = Set.new
File.foreach(EZBIG, encoding: "UTF-8") do |line|
  line = line.chomp
  next if line.start_with?("%") || !line.include?("\t")
  code, word = line.split("\t", 2)
  next if word.nil? || word.empty?
  existing << [code, word]
end

additions = []
seen = Set.new
CSV.foreach(DICT, encoding: "UTF-8", headers: true) do |r|
  word = r["字詞名"].to_s
  code = r["輕鬆輸入法編碼"].to_s
  code = r["分析可能的輕鬆輸入法編碼"].to_s if code.empty?
  next if word.empty? || code.empty?
  pair = [code, word]
  next if existing.include?(pair) || seen.include?(pair)
  seen << pair
  additions << pair
end

content = File.read(EZBIG, encoding: "UTF-8")
content += "\n" unless content.end_with?("\n")
File.open(EZBIG, "a", encoding: "UTF-8") do |f|
  additions.each { |code, word| f.puts "#{code}\t#{word}" }
end

puts "Appended #{additions.size} new (code, word) pairs"
puts "First 5: #{additions.first(5).inspect}"
puts "Last 5:  #{additions.last(5).inspect}"
