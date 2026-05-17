require "set"

EZ    = "vendor/ezsource12-3/origtable/ez.orig-utf8.txt"
EZBIG = "vendor/ezsource12-3/origtable/ezbig.orig-utf8.txt"

def stable_sort_by_code(lines)
  lines.each_with_index.sort_by { |line, i| [line.split("\t", 2).first, i] }.map(&:first)
end

# ez.orig has no header — sort the whole file
ez_lines = File.readlines(EZ, encoding: "UTF-8")
File.write(EZ, stable_sort_by_code(ez_lines).join, encoding: "UTF-8")
puts "Sorted #{EZ} (#{ez_lines.size} lines)"

# ezbig: keep lines 1..61 (through "%sel1st end"), sort the rest
ezbig_lines = File.readlines(EZBIG, encoding: "UTF-8")
header = ezbig_lines[0, 61]
body = ezbig_lines[61..]
raise "Expected line 61 to be '%sel1st end'" unless header.last.chomp == "%sel1st end"
File.write(EZBIG, (header + stable_sort_by_code(body)).join, encoding: "UTF-8")
puts "Sorted #{EZBIG} body (#{body.size} body lines after #{header.size}-line header)"
