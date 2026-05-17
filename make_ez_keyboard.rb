#!/usr/bin/env ruby
# frozen_string_literal: true

# Build ez_keyboard.svg by combining the QWERTY layout from
# qwerty_keyboard_template.svg with the root images generated under
# ez_root_images/.
#
# For each printable key with one or more EZ roots, the alphanumeric
# label is shown small in the top-left corner of the key, and the root
# images are laid out side-by-side in the lower part of the key body.
# Modifier keys (Tab, CapsLock, Enter, Shift, Ctrl, Alt, Space, Backspace)
# keep their original labels unchanged.

require "bundler/setup"
require "tomlrb"

ROOT          = File.expand_path(__dir__)
DEF_FILE      = File.join(ROOT, "roots_image_definition.toml")
OUT_FILE       = File.join(ROOT, "ez_keyboard.svg")
OUT_FILE_PLAIN = File.join(ROOT, "ez_keyboard_plain.svg")
ROOT_IMG_DIR   = "ez_root_images" # path embedded into the SVG, relative to it
KEYS_OUT_DIR   = File.join(ROOT, "ez_root_images", "keys")

# data-keycode values are Android KeyEvent keycode constant names
# (https://developer.android.com/reference/android/view/KeyEvent).
ANDROID_KEYCODE = {
  "`"            => "KEYCODE_GRAVE",
  "1"            => "KEYCODE_1",         "2" => "KEYCODE_2",
  "3"            => "KEYCODE_3",         "4" => "KEYCODE_4",
  "5"            => "KEYCODE_5",         "6" => "KEYCODE_6",
  "7"            => "KEYCODE_7",         "8" => "KEYCODE_8",
  "9"            => "KEYCODE_9",         "0" => "KEYCODE_0",
  "-"            => "KEYCODE_MINUS",     "=" => "KEYCODE_EQUALS",
  "Backspace"    => "KEYCODE_DEL",
  "Tab"          => "KEYCODE_TAB",
  "q" => "KEYCODE_Q", "w" => "KEYCODE_W", "e" => "KEYCODE_E",
  "r" => "KEYCODE_R", "t" => "KEYCODE_T", "y" => "KEYCODE_Y",
  "u" => "KEYCODE_U", "i" => "KEYCODE_I", "o" => "KEYCODE_O",
  "p" => "KEYCODE_P",
  "["            => "KEYCODE_LEFT_BRACKET",
  "]"            => "KEYCODE_RIGHT_BRACKET",
  "\\"           => "KEYCODE_BACKSLASH",
  "CapsLock"     => "KEYCODE_CAPS_LOCK",
  "a" => "KEYCODE_A", "s" => "KEYCODE_S", "d" => "KEYCODE_D",
  "f" => "KEYCODE_F", "g" => "KEYCODE_G", "h" => "KEYCODE_H",
  "j" => "KEYCODE_J", "k" => "KEYCODE_K", "l" => "KEYCODE_L",
  ";"            => "KEYCODE_SEMICOLON",
  "'"            => "KEYCODE_APOSTROPHE",
  "Enter"        => "KEYCODE_ENTER",
  "ShiftLeft"    => "KEYCODE_SHIFT_LEFT",
  "ShiftRight"   => "KEYCODE_SHIFT_RIGHT",
  "z" => "KEYCODE_Z", "x" => "KEYCODE_X", "c" => "KEYCODE_C",
  "v" => "KEYCODE_V", "b" => "KEYCODE_B", "n" => "KEYCODE_N",
  "m" => "KEYCODE_M",
  ","            => "KEYCODE_COMMA",
  "."            => "KEYCODE_PERIOD",
  "/"            => "KEYCODE_SLASH",
  "ControlLeft"  => "KEYCODE_CTRL_LEFT",
  "ControlRight" => "KEYCODE_CTRL_RIGHT",
  "AltLeft"      => "KEYCODE_ALT_LEFT",
  "AltRight"     => "KEYCODE_ALT_RIGHT",
  "Space"        => "KEYCODE_SPACE",
}.freeze

UNIT       = 60      # 1u in pixels
KEY_BODY   = 56      # key body width/height for 1u keys
LABEL_SIZE = 14      # px (~10pt) — minimum readable size on phone renders
# Key body is split into two stacked regions with a 4px gap between them:
#   top region  (height LABEL_REGION_H)  — alphanumeric label, centred
#   bottom region (remainder)            — root glyphs, filled non-uniformly
LABEL_REGION_H = 16
REGION_GAP     = 4
MARGIN         = 10

# rows: [[keycode, label, width_units, mod?], ...]
ROWS = [
  [
    ["`", "`", 1, false],
    ["1", "1", 1, false], ["2", "2", 1, false], ["3", "3", 1, false],
    ["4", "4", 1, false], ["5", "5", 1, false], ["6", "6", 1, false],
    ["7", "7", 1, false], ["8", "8", 1, false], ["9", "9", 1, false],
    ["0", "0", 1, false],
    ["-", "-", 1, false], ["=", "=", 1, false],
    ["Backspace", "⌫ Backspace", 2, true],
  ],
  [
    ["Tab", "Tab", 1.5, true],
    ["q", "Q", 1, false], ["w", "W", 1, false], ["e", "E", 1, false],
    ["r", "R", 1, false], ["t", "T", 1, false], ["y", "Y", 1, false],
    ["u", "U", 1, false], ["i", "I", 1, false], ["o", "O", 1, false],
    ["p", "P", 1, false],
    ["[", "[", 1, false], ["]", "]", 1, false],
    ["\\", "\\", 1, false],
  ],
  [
    ["CapsLock", "Caps Lock", 1.75, true],
    ["a", "A", 1, false], ["s", "S", 1, false], ["d", "D", 1, false],
    ["f", "F", 1, false], ["g", "G", 1, false], ["h", "H", 1, false],
    ["j", "J", 1, false], ["k", "K", 1, false], ["l", "L", 1, false],
    [";", ";", 1, false], ["'", "'", 1, false],
    ["Enter", "Enter ↵", 2.25, true],
  ],
  [
    ["ShiftLeft", "⇧ Shift", 2.25, true],
    ["z", "Z", 1, false], ["x", "X", 1, false], ["c", "C", 1, false],
    ["v", "V", 1, false], ["b", "B", 1, false], ["n", "N", 1, false],
    ["m", "M", 1, false],
    [",", ",", 1, false], [".", ".", 1, false], ["/", "/", 1, false],
    ["ShiftRight", "⇧ Shift", 2.75, true],
  ],
  [
    ["ControlLeft", "Ctrl", 1.5, true],
    ["AltLeft", "Alt", 1.5, true],
    ["Space", "空　白", 9, true],
    ["AltRight", "Alt", 1.5, true],
    ["ControlRight", "Ctrl", 1.5, true],
  ],
]

def hex(ch)
  ch.unpack1("U*").to_s(16)
end

def root_filename(keycode, index, root_char)
  format("%s_%d_%s.svg", hex(keycode), index, hex(root_char))
end

def collect_roots(defn)
  map = {}
  Array(defn["keys"]).each do |entry|
    key = entry["key"]
    files = []
    Array(entry["roots"]).each_with_index do |root, idx|
      next if root["status"] == "missing"

      files << root_filename(key, idx, root["char"])
    end
    map[key] = files unless files.empty?
  end
  map
end

def render_key(keycode, label, width_units, is_mod, roots, x_off, y_off, plain: false)
  body_w = (UNIT * width_units).to_i - (UNIT - KEY_BODY)
  body_h = KEY_BODY
  klass  = is_mod ? "key mod" : "key"

  android_code = ANDROID_KEYCODE[keycode] || raise("no Android keycode mapping for #{keycode.inspect}")
  attrs = %(class="#{klass}" data-keycode="#{android_code}" transform="translate(#{x_off},#{y_off})")
  parts = [%(<g #{attrs}>)]
  parts << if plain
             %(  <rect width="#{body_w}" height="#{body_h}"/>)
           else
             %(  <rect width="#{body_w}" height="#{body_h}" rx="6"/>)
           end

  if is_mod
    # centered label only
    parts << %(  <text class="mod-label" x="#{body_w / 2.0}" y="#{body_h / 2.0}">#{escape_text(label)}</text>)
  elsif roots && !roots.empty?
    # Top region: centred alphanumeric label
    parts << %(  <text class="key-label" x="#{body_w / 2.0}" y="#{LABEL_REGION_H / 2.0}">#{escape_text(label)}</text>)

    # Bottom region: roots, each filling its cell non-uniformly.
    # Paths are inlined (not referenced via <image>) so the composite
    # SVG renders standalone in browsers / GitHub raw view, which block
    # cross-file SVG references.
    roots_y = LABEL_REGION_H + REGION_GAP
    roots_h = body_h - roots_y
    n = roots.size
    cell_w = body_w.to_f / n
    sx = cell_w / 1024.0
    sy = roots_h.to_f / 1024.0
    roots.each_with_index do |fname, i|
      x = (cell_w * i).round(3)
      inner = extract_root_inner_paths(File.join(ROOT, ROOT_IMG_DIR, fname))
      unless inner
        warn "[skip] could not extract paths from #{fname}"
        next
      end
      parts << %(  <g transform="translate(#{x},#{roots_y}) scale(#{sx.round(6)},#{sy.round(6)})">)
      parts << %(    <g transform="scale(1, -1) translate(0, -900)">)
      parts << "      #{inner}"
      parts << %(    </g>)
      parts << %(  </g>)
    end
  else
    # No EZ roots defined for this key — show the label centred.
    parts << %(  <text class="mod-label" x="#{body_w / 2.0}" y="#{body_h / 2.0}">#{escape_text(label)}</text>)
  end

  parts << "</g>"
  parts.join("\n")
end

def escape_attr(str)
  str.gsub("&", "&amp;").gsub('"', "&quot;").gsub("<", "&lt;")
end

def escape_text(str)
  str.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
end

LABEL_CSS = <<~CSS
  .key-label {
    font-family: "Roboto Slab", "DejaVu Serif", serif;
    font-weight: 700;
    font-size: #{LABEL_SIZE}px;
    fill: #222;
    text-anchor: middle;
    dominant-baseline: central;
  }
  .mod-label {
    font-family: "Roboto Slab", "DejaVu Serif", serif;
    font-weight: 400;
    font-size: 14px;
    fill: #222;
    text-anchor: middle;
    dominant-baseline: central;
  }
CSS

STYLE_BORDERED = <<~CSS
  @import url('https://fonts.googleapis.com/css2?family=Roboto+Slab:wght@400;700&amp;display=swap');
  .key rect { fill: #ffffff; stroke: #222; stroke-width: 1.5; }
  .key.mod rect { fill: #f0f0f0; }
#{LABEL_CSS}
CSS

STYLE_PLAIN = <<~CSS
  @import url('https://fonts.googleapis.com/css2?family=Roboto+Slab:wght@400;700&amp;display=swap');
  .key rect { fill: none; stroke: none; }
#{LABEL_CSS}
CSS

def build_svg(roots_map, plain: false)
  total_w = MARGIN * 2 + UNIT * 15
  total_h = MARGIN * 2 + UNIT * ROWS.size

  out = []
  out << %(<?xml version="1.0" encoding="UTF-8"?>)
  out << %(<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 #{total_w} #{total_h}" width="#{total_w}" height="#{total_h}">)
  out << "<style>\n#{plain ? STYLE_PLAIN : STYLE_BORDERED}</style>"

  ROWS.each_with_index do |row, row_idx|
    y_off = MARGIN + row_idx * UNIT
    x_units = 0
    row.each do |(keycode, label, width_units, is_mod)|
      x_off = MARGIN + (x_units * UNIT).to_i
      roots = roots_map[keycode]
      out << render_key(keycode, label, width_units, is_mod, roots, x_off, y_off, plain: plain)
      x_units += width_units
    end
  end

  out << "</svg>"
  out.join("\n")
end

def convert_text_to_path(svg_path)
  # Use Inkscape to bake all <text> into <path> so the file renders
  # correctly without depending on the Roboto Slab webfont.
  unless system("which inkscape > /dev/null 2>&1")
    warn "[skip] inkscape not found; leaving text elements as-is"
    return
  end

  ok = system("inkscape", "--export-text-to-path", "--export-plain-svg",
              "--export-filename=#{svg_path}", svg_path,
              out: File::NULL, err: File::NULL)
  if ok
    puts "  text-to-path: converted via Inkscape"
  else
    warn "[warn] inkscape text-to-path conversion failed"
  end
end

# Pull just the silhouette paths out of an already-generated root SVG so
# we can inline them inside a per-key file without an external <image> ref.
def extract_root_inner_paths(svg_path)
  content = File.read(svg_path)
  # everything between the inner makemeahanzi flip <g> open/close
  m = content.match(%r{<g transform="scale\(1, -1\) translate\(0, -900\)">(.*?)</g>\s*</svg>}m)
  m ? m[1].strip : nil
end

def render_per_key_svg(keycode, label, width_units, is_mod, root_files)
  body_w = (UNIT * width_units).to_i - (UNIT - KEY_BODY)
  body_h = KEY_BODY

  body = []
  if is_mod
    body << %(  <text class="mod-label" x="#{body_w / 2.0}" y="#{body_h / 2.0}">#{escape_text(label)}</text>)
  elsif root_files && !root_files.empty?
    # Top region — centred alphanumeric label.
    body << %(  <text class="key-label" x="#{body_w / 2.0}" y="#{LABEL_REGION_H / 2.0}">#{escape_text(label)}</text>)

    # Bottom region — roots filled non-uniformly per cell.  Inlined via
    # <g transform> (Android VectorDrawable doesn't support nested <svg>).
    roots_y = LABEL_REGION_H + REGION_GAP
    roots_h = body_h - roots_y
    n = root_files.size
    cell_w = body_w.to_f / n
    sx = cell_w / 1024.0
    sy = roots_h.to_f / 1024.0

    root_files.each_with_index do |fname, i|
      x = (cell_w * i).round(3)
      inner = extract_root_inner_paths(File.join(ROOT, ROOT_IMG_DIR, fname))
      unless inner
        warn "[skip] could not extract paths from #{fname} for #{keycode}"
        next
      end
      body << %(  <g transform="translate(#{x},#{roots_y}) scale(#{sx.round(6)},#{sy.round(6)})">)
      body << %(    <g transform="scale(1, -1) translate(0, -900)">)
      body << "      #{inner}"
      body << %(    </g>)
      body << %(  </g>)
    end
  else
    body << %(  <text class="mod-label" x="#{body_w / 2.0}" y="#{body_h / 2.0}">#{escape_text(label)}</text>)
  end

  out = []
  out << %(<?xml version="1.0" encoding="UTF-8"?>)
  out << %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{body_w} #{body_h}" width="#{body_w}" height="#{body_h}">)
  out << "<style>\n#{STYLE_PLAIN}</style>"
  out.concat(body)
  out << "</svg>"
  out.join("\n")
end

def export_per_key_svgs(roots_map)
  require "fileutils"
  FileUtils.mkdir_p(KEYS_OUT_DIR)
  count = 0
  paths = []

  ROWS.each do |row|
    row.each do |(keycode, label, width_units, is_mod)|
      const = ANDROID_KEYCODE[keycode]
      out_path = File.join(KEYS_OUT_DIR, "#{const}.svg")
      File.write(out_path, render_per_key_svg(keycode, label, width_units, is_mod, roots_map[keycode]))
      paths << out_path
      count += 1
    end
  end

  paths
end

def batch_text_to_path(svg_paths)
  return if svg_paths.empty?
  unless system("which inkscape > /dev/null 2>&1")
    warn "[skip] inkscape not found; per-key files keep <text> elements"
    return
  end

  svg_paths.each do |p|
    system("inkscape", "--export-text-to-path", "--export-plain-svg",
           "--export-filename=#{p}", p,
           out: File::NULL, err: File::NULL)
  end
  puts "  per-key text-to-path: #{svg_paths.size} file(s) processed"
end

def main
  defn = Tomlrb.load_file(DEF_FILE)
  roots_map = collect_roots(defn)
  total_keys = ROWS.flatten(1).size
  total_roots = roots_map.values.sum(&:size)

  [
    [OUT_FILE,       false, "bordered"],
    [OUT_FILE_PLAIN, true,  "plain (no border, no rounded corners)"],
  ].each do |path, plain, label|
    File.write(path, build_svg(roots_map, plain: plain))
    puts "wrote #{path} (#{label})"
    convert_text_to_path(path)
  end

  per_key_paths = export_per_key_svgs(roots_map)
  puts "wrote #{per_key_paths.size} per-key SVGs to #{KEYS_OUT_DIR}/"
  batch_text_to_path(per_key_paths)

  puts "  keys:  #{total_keys}"
  puts "  roots: #{total_roots} across #{roots_map.size} key(s)"
end

main if $PROGRAM_NAME == __FILE__
