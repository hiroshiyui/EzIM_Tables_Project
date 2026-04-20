#!/usr/bin/env ruby
# frozen_string_literal: true

# Read roots_image_definition.toml and generate one SVG per root under
# ez_root_images/.
#
# Each root is rendered on the makemeahanzi 1024×1024 canvas with its
# coordinate transform (scale(1,-1) translate(0,-900)) preserved, so the
# output can be used interchangeably with makemeahanzi glyphs.
#
# Statuses handled:
#   direct / fallback — copy the silhouette path(s) from
#                       makemeahanzi/svgs/<svg_file>
#   descriptive       — inline the paths from the `strokes` array
#   missing           — skipped with a warning
#
# Output filename: ez_root_images/<keyhex>_<index>_<charhex>.svg
#   keyhex  = lowercase hex of the key's Unicode codepoint (e.g. "60" for `)
#   index   = 0-based position within the key's `roots` array
#   charhex = lowercase hex of the root character's codepoint

require "bundler/setup"
require "tomlrb"
require "fileutils"

ROOT        = File.expand_path(__dir__)
DEF_FILE    = File.join(ROOT, "roots_image_definition.toml")
SVG_SRC_DIR = File.join(ROOT, "makemeahanzi", "svgs")
OUT_DIR     = File.join(ROOT, "ez_root_images")

SVG_HEADER = <<~HEAD
  <svg version="1.1" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
    <g transform="scale(1, -1) translate(0, -900)">
HEAD

SVG_FOOTER = <<~FOOT
    </g>
  </svg>
FOOT

# Extract silhouette path `d` values from a makemeahanzi SVG.
# The silhouette paths carry a non-"none" fill (usually "lightgray");
# animation paths carry fill="none" and are ignored.
def extract_fill_paths(svg_path)
  content = File.read(svg_path)
  paths = []
  content.scan(/<path\b[^>]*>/).each do |tag|
    fill_match = tag.match(/\bfill\s*=\s*"([^"]+)"/)
    next unless fill_match && fill_match[1] != "none"

    d_match = tag.match(/\bd\s*=\s*"([^"]+)"/)
    next unless d_match

    paths << d_match[1]
  end
  paths
end

def render_svg(paths)
  body = paths.map { |d| %(      <path d="#{d}" fill="black"/>) }.join("\n")
  SVG_HEADER + body + "\n" + SVG_FOOTER
end

def hex(codepoint_char)
  return "na" if codepoint_char.nil? || codepoint_char.empty?

  codepoint_char.unpack1("U*").to_s(16)
end

def out_path(key, index, root_char)
  name = format("%s_%d_%s.svg", hex(key), index, hex(root_char))
  File.join(OUT_DIR, name)
end

def process_root(key, index, root)
  status    = root["status"]
  root_char = root["char"]
  dest      = out_path(key, index, root_char)

  case status
  when "direct", "fallback"
    src = File.join(SVG_SRC_DIR, root["svg_file"].to_s)
    unless File.exist?(src)
      warn "[skip] key=#{key.inspect} root=#{root_char}: source not found (#{src})"
      return
    end

    paths = extract_fill_paths(src)
    if paths.empty?
      warn "[skip] key=#{key.inspect} root=#{root_char}: no fill paths in #{src}"
      return
    end

    File.write(dest, render_svg(paths))
    puts "[#{status}] #{key.inspect} [#{index}] #{root_char} -> #{File.basename(dest)}"

  when "descriptive"
    paths = Array(root["strokes"])
    if paths.empty?
      warn "[skip] key=#{key.inspect} root=#{root_char}: descriptive entry has empty strokes"
      return
    end

    File.write(dest, render_svg(paths))
    puts "[descriptive] #{key.inspect} [#{index}] #{root_char} (via #{root["source_char"]}) -> #{File.basename(dest)}"

  when "composite"
    components = Array(root["components"])
    if components.empty?
      warn "[skip] key=#{key.inspect} root=#{root_char}: composite entry has no components"
      return
    end

    body_parts = []
    component_labels = []
    components.each do |comp|
      paths =
        if comp["strokes"]
          Array(comp["strokes"])
        elsif comp["svg_file"]
          src = File.join(SVG_SRC_DIR, comp["svg_file"].to_s)
          unless File.exist?(src)
            warn "[skip] key=#{key.inspect} root=#{root_char}: component source not found (#{src})"
            return
          end
          extract_fill_paths(src)
        else
          warn "[skip] key=#{key.inspect} root=#{root_char}: component has neither svg_file nor strokes"
          return
        end

      if paths.empty?
        warn "[skip] key=#{key.inspect} root=#{root_char}: component yielded no paths"
        return
      end

      paths_xml = paths.map { |d| %(        <path d="#{d}" fill="black"/>) }.join("\n")
      transform = comp["transform"].to_s
      body_parts << if transform.empty?
                      paths_xml
                    else
                      %(      <g transform="#{transform}">\n#{paths_xml}\n      </g>)
                    end
      component_labels << (comp["char"] || comp["source_char"]).to_s
    end

    svg = SVG_HEADER + body_parts.join("\n") + "\n" + SVG_FOOTER
    File.write(dest, svg)
    puts "[composite] #{key.inspect} [#{index}] #{root_char} (#{component_labels.join("+")}) -> #{File.basename(dest)}"

  when "missing"
    warn "[missing] key=#{key.inspect} root=#{root_char}: manual artwork required"

  else
    warn "[unknown-status=#{status.inspect}] key=#{key.inspect} root=#{root_char}"
  end
end

def main
  unless File.exist?(DEF_FILE)
    abort "definition file not found: #{DEF_FILE}"
  end

  FileUtils.mkdir_p(OUT_DIR)
  defn = Tomlrb.load_file(DEF_FILE)

  keys = defn["keys"] || []
  total = 0
  keys.each do |entry|
    key = entry["key"]
    Array(entry["roots"]).each_with_index do |root, idx|
      process_root(key, idx, root)
      total += 1
    end
  end

  puts "---"
  puts "processed #{total} root entr#{total == 1 ? "y" : "ies"}"
  puts "output:    #{OUT_DIR}"
end

main if $PROGRAM_NAME == __FILE__
