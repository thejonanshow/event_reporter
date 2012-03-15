require 'ostruct'

class Attendee < OpenStruct
  ORDERED_KEYS = [
    'last_name',
    'first_name',
    'email',
    'zipcode',
    'city',
    'state',
    'address'
  ]

  def initialize(attributes)
    super

    attributes.each do |field, value|
      cleaner = "#{field}_cleaner".to_sym
      self.send(cleaner, value) if self.respond_to? cleaner
    end
  end

  def self.default_headers
    ORDERED_KEYS
  end

  def keys
    ORDERED_KEYS
  end

  def headers
    keys.map(&:upcase).join(' ').gsub('_',' ')
  end

  def values
    [
      self.last_name,
      self.first_name,
      self.email_address,
      self.zipcode,
      self.city,
      self.state
    ]
  end

  def headers_with_padding(padding)
    keys.map(&:upcase).map do |header|
      header.ljust(padding)
    end.join(' ').gsub('_',' ')
  end

  def first_name_cleaner(name)
    name ||= 'na'
    self.first_name = capitalize name
  end

  def last_name_cleaner(name)
    name ||= 'na'
    self.last_name = capitalize name
  end

  def email_address_cleaner(email)
    self.email = 'na' if email.nil? || email.split('@').length != 2
  end

  def zipcode_cleaner(zipcode)
    zipcode ||= ''
    self.zipcode = zipcode.rjust(5,'0')
    debugger if self.zipcode.nil?
  end

  def street_cleaner(address)
    self.street ||= 'na'
  end

  def city_cleaner(city)
    self.city ||= 'na'
  end

  def state_cleaner(state)
    self.state ||= 'na'
  end

  def capitalize(name)
    name.split(' ').map(&:downcase).map(&:capitalize).join(' ')
  end

  def print_with_padding(padding)
    output =
     [self.last_name,
      self.first_name,
      attendee_email(self),
      self.zipcode,
      self.city,
      self.state,
      attendee_address(self)]
    output.map {|att| att[0..padding-1].ljust(padding)}
    output.join(' ')
  end

  def attendee_email(attendee)
    (attendee.email ? attendee.email : attendee.email_address)
  end

  def attendee_address(attendee)
    (attendee.address ? attendee.address : attendee.street)
  end
end
