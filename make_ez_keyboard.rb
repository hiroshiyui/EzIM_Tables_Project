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
OUT_FILE      = File.join(ROOT, "ez_keyboard.svg")
ROOT_IMG_DIR  = "ez_root_images" # path embedded into the SVG, relative to it

UNIT       = 60      # 1u in pixels
KEY_BODY   = 56      # key body width/height for 1u keys
LABEL_X    = 6       # letter label inset from key top-left
LABEL_Y    = 10
LABEL_SIZE = 12
ROOT_TOP   = 18      # roots row starts below the corner label
ROOT_BOTTOM_PAD = 2
MARGIN     = 10

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
    ["\\", "\\", 1.5, false],
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

def render_key(keycode, label, width_units, is_mod, roots, x_off, y_off)
  body_w = (UNIT * width_units).to_i - (UNIT - KEY_BODY)
  body_h = KEY_BODY
  klass  = is_mod ? "key mod" : "key"

  attrs = %(class="#{klass}" data-keycode="#{escape_attr(keycode)}" transform="translate(#{x_off},#{y_off})")
  parts = [%(<g #{attrs}>)]
  parts << %(  <rect width="#{body_w}" height="#{body_h}" rx="6"/>)

  if is_mod
    # centered label only
    parts << %(  <text class="mod-label" x="#{body_w / 2.0}" y="#{body_h / 2.0}">#{escape_text(label)}</text>)
  else
    # corner letter label
    parts << %(  <text class="corner-label" x="#{LABEL_X}" y="#{LABEL_Y}">#{escape_text(label)}</text>)

    # root images, evenly distributed across the key body
    if roots && !roots.empty?
      n = roots.size
      avail_w = body_w - 4
      avail_h = body_h - ROOT_TOP - ROOT_BOTTOM_PAD
      cell_w = avail_w / n.to_f
      img_size = [cell_w - 2, avail_h].min.floor
      roots.each_with_index do |fname, i|
        cx = 2 + cell_w * (i + 0.5)
        cy = ROOT_TOP + avail_h / 2.0
        parts << %(  <image href="#{ROOT_IMG_DIR}/#{fname}" x="#{(cx - img_size / 2.0).round(2)}" y="#{(cy - img_size / 2.0).round(2)}" width="#{img_size}" height="#{img_size}"/>)
      end
    end
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

def build_svg(roots_map)
  total_w = MARGIN * 2 + UNIT * 15
  total_h = MARGIN * 2 + UNIT * ROWS.size

  out = []
  out << %(<?xml version="1.0" encoding="UTF-8"?>)
  out << %(<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 #{total_w} #{total_h}" width="#{total_w}" height="#{total_h}">)
  out << <<~STYLE
      <style>
        @import url('https://fonts.googleapis.com/css2?family=Roboto+Slab:wght@400;700&amp;display=swap');
        .key rect { fill: #ffffff; stroke: #222; stroke-width: 1.5; }
        .key.mod rect { fill: #f0f0f0; }
        .corner-label {
          font-family: "Roboto Slab", "DejaVu Serif", serif;
          font-weight: 700;
          font-size: #{LABEL_SIZE}px;
          fill: #333;
          dominant-baseline: hanging;
        }
        .mod-label {
          font-family: "Roboto Slab", "DejaVu Serif", serif;
          font-weight: 400;
          font-size: 14px;
          fill: #222;
          text-anchor: middle;
          dominant-baseline: central;
        }
      </style>
  STYLE

  ROWS.each_with_index do |row, row_idx|
    y_off = MARGIN + row_idx * UNIT
    x_units = 0
    row.each do |(keycode, label, width_units, is_mod)|
      x_off = MARGIN + (x_units * UNIT).to_i
      roots = roots_map[keycode]
      out << render_key(keycode, label, width_units, is_mod, roots, x_off, y_off)
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

def main
  defn = Tomlrb.load_file(DEF_FILE)
  roots_map = collect_roots(defn)
  svg = build_svg(roots_map)
  File.write(OUT_FILE, svg)
  total_keys = ROWS.flatten(1).size
  total_roots = roots_map.values.sum(&:size)
  puts "wrote #{OUT_FILE}"
  puts "  keys:  #{total_keys}"
  puts "  roots: #{total_roots} across #{roots_map.size} key(s)"
  convert_text_to_path(OUT_FILE)
end

main if $PROGRAM_NAME == __FILE__
