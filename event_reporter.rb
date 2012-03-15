class EventReporter
  VALID_COMMANDS = {
    'help'  => "Display these commands.",
    'load'  => "Load a file (defaults to 'event_attendees.csv')",
    'find'  => "Find a record.",
    'queue save to' => "Save the queue to a file.",
    'queue clear' => "Empty the queue.",
    'queue count' => "Count the queue.",
    'queue print' => "Print the queue.",
    'queue print by' => "Sort the queue by attribute."
  }
  CSV_OPTIONS = {
    :headers => true,
    :header_converters => :symbol
  }
  USE_ORIGINAL_HEADERS = false

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
    criteria = arguments[1..-1] if arguments.length > 1

    if valid_find?(attribute, criteria)
      search_by attribute, criteria
    else
      puts "Invalid find."
    end
  end

  def valid_find?(attribute, criteria)
    test_attendee = @attendees.first
    responds = test_attendee.respond_to?(attribute.to_sym) if attribute

    attribute && criteria && test_attendee && responds
  end

  def search_by(attribute, criteria)
    @queue = @attendees.select do |attendee|
      attendee.send(attribute.to_sym).downcase == criteria.join(' ').downcase
    end

    qlength = @queue.length
    puts "#{qlength} attendees found#{qlength > 0 ? ' and added to queue.' : '.'}"
    queue_print
  end

  def queue(type)
    case type.join(' ')
    when 'count'
      puts @queue.count
    when 'clear'
      @queue = []
      puts "Cleared queue."
    when 'print'
      queue_print
    when /^print by/
      queue_sort_by(type[2..-1].join)
    when /^save to/
      save(type[1..-1])
    end
  end

  def queue_print(queue = @queue)
    if queue.first.nil?
      puts "Queue is empty. There is nothing to print."
    else
      padding = calculate_print_padding
      puts queue.first.headers_with_padding(padding)
    end

    queue.each do |attendee|
      puts attendee.print_with_padding(padding)
    end
  end

  def queue_sort_by(attribute)
    error_message = "Invalid sort. Try 'queue sort by <attribute>'."
    puts error_message and return false unless attribute.split(' ').length == 1

    sorted_queue = @queue.sort_by {|attendee| attendee.send(attribute.to_sym)}
    queue_print(sorted_queue)
  end

  def calculate_print_padding
    all_words = @queue.first.headers.split(' ').push @queue.map {|attendee| attendee.values}
    [20, all_words.flatten.compact.map(&:length).max].min
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
    @queue = []

    file.each do |line|
      @attendees << Attendee.new(line)
    end

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

    headers = setup_headers
    filename = arguments.last
    CSV.open(filename, 'wb') do |output|
      output << headers

      @queue.each do |line|
        output << setup_values(headers, line)
      end
    end

    puts "Queue saved to #{filename}."
  end

  def setup_headers
    if USE_ORIGINAL_HEADERS
      @attendees.first.marshal_dump.keys
    else
      Attendee.default_headers
    end
  end

  def setup_values(headers, attendee)
    values = []

    if headers == Attendee.default_headers 
      values = default_values(headers, attendee)
    else
      #get values from marshal_dump
    end
    values
  end

  def default_values(headers, attendee)
    values = []
    headers.each do |attribute|
      if attendee.respond_to?(attribute.to_sym)
        values.push attendee.send(attribute.to_sym)
      elsif attribute == 'address'
        values.push attendee.street
      elsif attribute == 'email'
        values.push attendee.email_address
      end
    end
    values
  end
end
