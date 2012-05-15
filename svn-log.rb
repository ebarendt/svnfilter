#!/usr/bin/env jruby --1.9 -s

# Filters svn log output for the list of files changed, optionally accepting changes for only some users.
# Usage:
#   svn-log.rb -r=revision -users=user1,user2 -msg="some message filter"

require 'nokogiri'

def usage
  puts <<END
Filters svn log output for the list of files changed, optionally accepting
changes for only some users and a log message. Changes are filtered by user
first, then filtered by message.

Usage:
  svn-log.rb -r=revision -users=user1,user2 -msg="some message filter"

  -r=revision          revision is the revision from which to start querying
                       SVN
  -users=user1,user2   (optional) a comma separated list of users to filter for
  -msg="a message"     (optional) a string used to filter commit messages
END
end

def filter_changes_by_users(changes, users)
  return changes unless users && !users.empty?
  changes.select { |logentry| users.include?(logentry.xpath("author").text) }
end

def filter_changes_by_log(changes, message="")
  changes.select { |logentry| logentry.xpath("msg").text =~ /#{message}/i }
end

def get_changes(xml_document)
  xml_document.xpath("//logentry")
end  

def get_files_in_revision(revision)
  cmd_output = `svn diff --no-diff-deleted --summarize -r #{revision - 1}:#{revision}`
  [].tap do |result|
    cmd_output.each_line { |line| result << line.split(/\s+/)[1] }
  end
end

def find_changed_files(changes)
  changes.map { |change| get_files_in_revision(change["revision"].to_i) }.flatten.sort.uniq
end

first_revision = $r
users = if $users then $users.split(",") else nil end
message = $msg

unless first_revision
  usage
  exit(1)
end

xml = Nokogiri::XML.parse(`svn log -r #{first_revision}:HEAD --xml`)
changes = get_changes(xml)
filtered = filter_changes_by_users(changes, users)
filtered = filter_changes_by_log(filtered, message)
puts find_changed_files(filtered)
