$LOAD_PATH.unshift('./').uniq!
require 'ruby-debug'
require 'csv'
require 'prompt'
require 'attendee'
require 'event_reporter'

e = EventReporter.new
p = Prompt.new

command = ''
while command != :exit
  e.new_command(command) unless command == ''
  command = p.get_input
end
puts "Thank you come again!"
