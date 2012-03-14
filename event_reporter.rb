class EventReporter
  VALID_COMMANDS = {
    'load'  => "Load a file (defaults to 'event_attendees.csv')",
    'queue clear' => "Empty the queue.",
    'queue count' => "Count the queue.",
    'queue print' => "Print the queue.",
    'find'  => "Find a record.",
    'help'  => "Display these commands."
  }
  CSV_OPTIONS = {
    :headers => true,
    :header_converters => :symbol
  }

  def initialize
    @attendees = []
    @queue = []
    puts "Welcome to EventReporter"
  end

  def new_command(input)
    invalid_message = "Invalid command. ('help' for a list of commands)"

    if valid_command?(input)
      process_command input
    else
      puts invalid_message
    end
  end

  def valid_command?(input)
    VALID_COMMANDS.include?(input.split(' ').first)
  end

  def help(arguments)
    message = "I'm sorry Dave, I can't do that."

    puts message and return unless valid_help? arguments

    if valid_help? arguments
      if arguments.empty?
        default_help
      else
        specific_help(arguments)
      end
    else
    end
  end

  def default_help
    VALID_COMMANDS.each do |command, description|
      if description.is_a? Hash
        default = description['default']
        puts "#{command}: #{default}"

        base_command = command
        description.each do |command, description|
          next if command == 'default'
          puts "#{base_command} #{command}: #{description}"
        end
      else
        puts "#{command}: #{description}"
      end
    end

    puts "Exit the prompt with any of #{Prompt.exit_commands.join(', ')}"
  end

  def specific_help(arguments)
    if arguments.length == 1
      puts "#{arguments.first}: #{VALID_COMMANDS[arguments.first]}"
    elsif arguments.length == 2
      c1 = arguments.first
      c2 = arguments.last

      puts "#{c1} #{c2}: #{VALID_COMMANDS[c1][c2]}"
    end
  end

  def valid_help?(arguments)
    if arguments.empty?
      true
    elsif arguments.length == 1
      true if valid_command? arguments.first
    elsif arguments.length == 2
      c1 = arguments.first
      c2 = arguments.last

      true if valid_command?(c1) && VALID_COMMANDS[c1][c2]
    end
  end

  def queue(arguments)
    puts "Queueing" + arguments.join(' ')
  end

  def find(arguments)
  end

  def is_valid_filename?(filename)
    filename ||= ''
    if !File.exist?(filename)
      puts "File does not exist."
    elsif filename.split('.').last.downcase != 'csv'
      puts "Extension must be CSV."
    else
      true
    end
  end

  def load(arguments)
    filename = arguments.first
    filename ||= 'event_attendees.csv'

    if is_valid_filename?(filename)
      file = CSV.open(filename, CSV_OPTIONS)
      puts "Loaded #{filename}."
      parse_attendees(file)
    else
      puts "'#{filename}' is not a valid filename."
    end
  end

  def parse_attendees(file)
    file.rewind

    file.each do |line|
      @attendees << Attendee.new(line)
    end
    puts "#{@attendees.length} attendees total."
    @attendees.each do |a|
      puts a
    end
  end

  private

  def process_command(input)
    command, *arguments = input.split(' ')
    self.send(command.to_sym, arguments)
  end
end
