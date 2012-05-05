#!/usr/bin/env jruby -n -l -s -rset
# Usage:
#   filterdiff.rb -f=files.txt changes.diff
#   filterdiff.rb < changes.diff -- Assumes files.txt

@files_to_accept = Set.new(File.open($f || "files.txt").each_line.map &:strip) unless @files_to_accept

last_filename = $~[:filename] if /^Index:\s+(?<filename>[\w\/.]*)$/
puts $_ if @files_to_accept.include? last_filename
