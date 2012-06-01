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

  -help                (optional) displays this message and exits
  -r=revision          (optional) revision is the revision from which to start querying
                       SVN fetches the revisions of the last 7 days by default
  -users=user1,user2   (optional) a comma separated list of users to filter for
  -msg="a message"     (optional) a string used to filter commit messages
END
end

def filter_changes_by_users(changes, users)
  return changes unless users && !users.empty?
  changes.select { |logentry| users.include?(logentry.xpath("author").text) }
end

def filter_changes_by_log(changes, message="")
  changes.select { |logentry| logentry.xpath("msg").text =~ /#{Regexp.escape(message)}/i }
end

def get_changes(xml_document)
  xml_document.xpath("//logentry")
end  

def get_files_in_revision(revision)
  cmd_output = `svn diff --no-diff-deleted --summarize -r #{revision - 1}:#{revision}`
  cmd_output.lines.map { |line| line.split[1] }
end

def find_changed_files(changes)
  changes.map { |change| get_files_in_revision(change["revision"].to_i) }.flatten.sort.uniq.
      map { |f| f.gsub /\\/, '/' }
end

first_revision = $r || "{#{(Time.now - 3600 * 24 * 7).strftime('%Y-%m-%d')}}"
users = if $users then $users.split(",") else nil end
message = $msg || ''

if $help
  usage
  exit(1)
end

xml = Nokogiri::XML.parse(`svn log -r #{first_revision}:HEAD --xml`)
changes = get_changes(xml)
filtered = filter_changes_by_users(changes, users)
filtered = filter_changes_by_log(filtered, message)
puts find_changed_files(filtered)
