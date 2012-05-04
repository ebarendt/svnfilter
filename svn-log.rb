# Filters svn log output for the list of files changed, optionally accepting changes for only some users.

require 'nokogiri'

def filter_changes_by_users(changes, users)
  changes.select do |logentry|
    users.empty? ? true : users.include?(logentry.xpath("author").text)
  end
end

def get_changes(xml_document)
  xml_document.xpath("//logentry")
end  

def get_files_in_revision(revision)
  `svn diff --no-diff-deleted --summarize -r #{revision - 1}:#{revision}`
end

def find_changed_files(changes)
  result = []
  changes.each do |change|
    files = get_files_in_revision(change["revision"].to_i)
    files.each_line { |line| result << line.split(/\s+/)[1] }
  end
  result.sort.uniq
end

first_revision = 1190
users = %w(user1 user2)

xml = Nokogiri::XML.parse(`svn log -r #{first_revision}:HEAD --xml`)
changes = get_changes(xml)
filtered = filter_changes_by_users(changes, users)
puts find_changed_files(filtered)
