class EventReporter
  VALID_COMMANDS = {
    'help'  => "Display these commands.",
    'load'  => "Load a file (defaults to 'event_attendees.csv')",
    'find'  => "Find a record.",
    'save to' => "Save the queue to a file.",
    'queue clear' => "Empty the queue.",
    'queue count' => "Count the queue.",
    'queue print' => "Print the queue.",
    'queue sort by' => "Sort the queue by attribute."
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
    regex_cmds = VALID_COMMANDS.keys.map do |cmd|
      Regexp.new "^#{cmd}"
    end

    regex_cmds.index do |regex_cmd|
      input.match regex_cmd
    end
  end

  def help(arguments)
    command = arguments.join(' ')

    if command.empty?
      default_help
    elsif VALID_COMMANDS[command]
      puts "#{command}: #{VALID_COMMANDS[command]}"
    else
      puts "I'm sorry Dave, I can't do that."
      puts "#{command} is not a valid command."
    end
  end

  def default_help
    VALID_COMMANDS.each do |command, description|
      puts "#{command}: #{description}"
    end

    puts "Exit with any of #{Prompt.exit_commands.join(', ')}"
  end

  def find(arguments)
    puts "Load attendees first." and return if @attendees.empty?

    attribute = arguments.first
    criteria = arguments.last if arguments.length > 1

    if valid_find?(attribute, criteria)
      search_by attribute, criteria
    else
      puts "Invalid find."
    end
  end
  
  def queue(type)
    case type.first
    when 'count'
      puts @queue.count
    when 'clear'
      @queue = []
      puts "Cleared queue."
    when 'print'
      queue_print
    when 'sort'
      queue_sort_by(type[2..-1].join)
    end
  end

  def queue_print
    if @queue.first.nil?
      puts "Load a file first."
    else
      padding = calculate_print_padding
      puts @queue.first.headers_with_padding(padding)
    end

    @queue.each do |attendee|
      puts attendee.print_with_padding(padding)
    end
  end

  def queue_sort_by(attribute)
    error_message = "Invalid sort. Try 'queue sort by <attribute>'."
    puts error_message and return false unless attribute.split(' ').length == 1

    @queue = @queue.sort_by {|attendee| attendee.send(attribute.to_sym)}
    queue_print
  end

  def calculate_print_padding
    all_words = @queue.first.headers.split(' ').push @queue.map {|attendee| attendee.values}
    [20, all_words.flatten.compact.map(&:length).max].min
  end

  def valid_find?(attribute, criteria)
    test_attendee = @attendees.first
    responds = test_attendee.respond_to?(attribute.to_sym) if attribute

    attribute && criteria && test_attendee && responds
  end

  def search_by(attribute, criteria)
    @queue = @attendees.select do |attendee|
      attendee.send(attribute.to_sym).downcase == criteria.downcase
    end

    qlength = @queue.length
    puts "#{qlength} attendees found#{qlength > 0 ? ' and added to queue.' : '.'}"
    queue_print
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
    @attendees = []

    file.each do |line|
      @attendees << Attendee.new(line)
    end

    @queue = @attendees
    puts "#{@attendees.length} attendees total."
  end

  private

  def process_command(input)
    command, *arguments = input.split(' ')
    self.send(command.to_sym, arguments)
  end

  def save(arguments)
    errormessage = "Invalid save. Try 'save to <filename>'."
    puts errormessage and return false unless arguments.length == 2 && arguments.first == 'to'

    filename = arguments.last
    CSV.open(filename, 'wb') do |output|
      @queue.each do |line|
        output << line.marshal_dump.keys  if output.lineno == 0
        output << line.marshal_dump.values
      end
    end

    puts "Queue saved to #{filename}."
  end
end
