require "csv"

class EventManager
  def initialize
    puts "EventManager Initialized."
    @file = CSV.open("event_attendees.csv", {:headers => true, :header_converters => :symbol})
  end

  def print_names
    @file.each do |line|
      puts "#{line[:first_name]} #{line[:last_name]}"
    end
  end

  def print_numbers
    @file.each do |line|
      puts clean_number(line[:homephone])
    end
  end

  def clean_number(number)
    number.gsub(/[^\d]/, '')
  end

end

manager = EventManager.new
manager.print_numbers
