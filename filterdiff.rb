files_to_accept = [].tap do |files|
  File.open("files.txt").each do |line|
    files << line.strip
  end
end

File.open("changes.diff", "r") do |file|
  match = false
  file.each do |line|
    if line =~ /^--- [\w+\/\.]*\s*\(revision \d+\)/
      match = false
      filename = line.split(/\s+/)[1]
      if files_to_accept.include?(filename)
        match = true
      end
    end

    if match
      puts line
    end
  end
end