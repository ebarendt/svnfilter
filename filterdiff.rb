START_FILE_REGEX = /^--- (?<filename>[\w+\/\.]*)\s*\(revision \d+\)/

files_to_accept = File.open("files.txt").each_line.map &:strip

File.open("changes.diff", "r") do |file|
  match = false
  file.each do |line|
    result = START_FILE_REGEX.match(line)
    if result
      match = files_to_accept.include?(result[:filename])
    end

    if match
      puts line
    end
  end
end