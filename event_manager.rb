require 'csv'
require 'sunlight'

class EventManager
  Sunlight::Base.api_key = "e179a6973728c4dd3fb1204283aaccb5"

  def initialize(filename)
    puts "EventManager Initialized"
    @file = CSV.open(filename, {:headers => true, :header_converters => :symbol})
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
    number.gsub!(/\D/,'')

    if number.length == 11 && number[0] == '1'
      number = number[1..-1]
    elsif number.length != 10
      number = "0000000000"
    end
    number
  end

  def print_zipcodes
    @file.each do |line|
      puts clean_zipcode(line[:zipcode])
    end
  end

  def clean_zipcode(original)
    original = original.to_s

    while original.length < 5
      original = '0' + original
    end
    original
  end

  def output_data(filename)
    output = CSV.open(filename, "w")


    @file.each do |line|
      line[:homephone] = clean_number(line[:homephone])
      line[:zipcode] = clean_zipcode(line[:zipcode])

      if @file.lineno == 2
        output << line.headers
      else
        output << line
      end
    end
  end

  def rep_lookup
    20.times do
      line = @file.readline

      representative = "unknown"

      legislators = Sunlight::Legislator.all_in_zipcode(clean_zipcode(line[:zipcode]))

      names = legislators.collect do |leg|
        last_name = leg.lastname
        first_initial + ". " + last_name
        "#{leg.title} #{first_initial}. #{last_name} (#{leg.party})"
      end

      puts "#{line[:last_name]}, #{line[:first_name]}, #{line[:zipcode]}, #{names.join(", ")}"
    end
  end

  def create_form_letters
    letter = File.open('form_letter.html', 'r').read
    20.times do
      line = @file.readline

      custom_letter = letter.gsub("#first_name",line[:first_name])
      custom_letter = custom_letter.gsub("#last_name",line[:last_name])
      custom_letter = custom_letter.gsub("#street",line[:street])
      custom_letter = custom_letter.gsub("#city",line[:city])
      custom_letter = custom_letter.gsub("#state",line[:state])
      custom_letter = custom_letter.gsub("#zipcode",line[:zipcode])

      filename = "output/thanks_#{line[:last_name]}_#{line[:first_name]}.html"
      output = File.new(filename, "w")
      output.write(custom_letter)
    end
  end

  def rank_times
    hours = Array.new(24){0}
    @file.each do |line|
      hour = line[:regdate].split(' ').last.split(':').first.to_i
      hours[hour] += 1
    end
    hours.each_with_index{|counter,hour| puts "#{hour}\t#{counter}"}
  end

  def day_stats
    days = Array.new(7){0}
    @file.each do |line|
      date = Date.strptime(line[:regdate].split(' ').first, "%m/%d/%Y")
      days[date.wday] += 1
    end
    days.each_with_index{|counter,day| puts "#{day}\t#{counter}"}
  end

  def state_stats
    state_data = {}
    @file.each do |line|
      state = line[:state]
      if state_data[state].nil?
        state_data[state] = 1
      else
        state_data[state] = state_data[state] + 1 
      end
    end

    state_data = state_data.sort_by{|state, counter| state.to_s}

    state_data.each do |state, counter|
      puts "#{state}: #{counter}"
    end
  end
end

manager = EventManager.new 'event_attendees.csv'
manager.state_stats
