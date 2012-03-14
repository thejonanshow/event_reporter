require 'ostruct'

class Attendee < OpenStruct
  def initialize(attributes)
    super

    attributes.each do |field, value|
      cleaner = "#{field}_cleaner".to_sym
      self.send(cleaner, value) if self.respond_to? cleaner
    end
  end

  def first_name_cleaner(name = '')
    self.first_name = capitalize name
  end

  def last_name_cleaner(name = '')
    self.last_name = capitalize name
  end

  def capitalize(name)
    name.split(' ').map(&:downcase).map(&:capitalize).join(' ')
  end
end