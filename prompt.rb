class Prompt
  exit_commands = %w(quit exit q x close e die oh god please don't kill me)
  EXIT_COMMANDS = exit_commands

  def initialize
    puts "Enter commands:"
  end

  def self.exit_commands
    EXIT_COMMANDS
  end

  def get_input
    printf "> "
    input = gets.strip

    if exit_command?(input)
      :exit
    else
      input
    end
  end

  def exit_command?(input)
    true if EXIT_COMMANDS.include?(input)
  end
end
