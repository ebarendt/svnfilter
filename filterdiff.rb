START_FILE_REGEX = /^--- (?<filename>[\w+\/\.]*)\s*\(revision \d+\)/

files_to_accept = [].tap do |files|
  File.open("files.txt").each do |line|
    files << line.strip
  end
end

File.open("changes.diff", "r") do |file|
  match = false
  file.each do |line|
    result = START_FILE_REGEX.match(line)
    if result
      match = false
      if files_to_accept.include?(result[:filename])
        match = true
      end
    end

    if match
      puts line
    end
  end
end