require 'csv'
require 'date'

class Normalizer

  def run
    input = read_csv(ARGV[0])

    normalized_data = []
    input.drop(1).each do |row|
      row_to_write = normalize_row(row)

      normalized_data << row_to_write if row_to_write
    end

    write_to_output(ARGV[1], input[0], normalized_data)
  end

  def read_csv(file)
    raise "Error: File #{file} is empty" if File.empty?(file)
    # Note: scrub is addressing UTF-8 replacement.
    # The default behavior of scrub is to replace invalud UTF-8 with
    # the Unicode Replacement Character
    # see first example: https://apidock.com/ruby/v2_5_5/String/scrub
    input = CSV.parse(File.read(ARGV[0]).scrub)

    rescue CSV::MalformedCSVError => e
      raise "#{file} is malformed CSV and cannot be parsed #{e}"
    return input
  end

  def normalize_row(row)
    parsed_row = []
    parsed_date = parse_date(row[0])

    if parsed_date
      parsed_row << parsed_date
    else
      return nil
    end

    parsed_row << row[1]
    parsed_row << format_zipcode(row[2])
    parsed_row << format_name(row[3])

    foo_duration = duration_of_seconds(row[4])
    parsed_row << duration_of_seconds(row[4])

    bar_duration = duration_of_seconds(row[5])
    parsed_row << duration_of_seconds(row[5])

    parsed_row << foo_duration + bar_duration
    parsed_row << row[7]

    return parsed_row
  end

  def write_to_output(destination, header, data)
    CSV.open(destination, "w+") do |csv|
      csv << header
      data.each do |row|
        csv << row
      end
    end
  end

  def parse_date(input)
    # Set default for Pacific Time
    # TODO offset does not account for change in daylight savings time
    input << " -08:00"
    begin
      parsed_pacific_timezone_date = DateTime.strptime(input, '%m/%d/%Y %l:%M:%S %p %:z').to_datetime

      # TODO offset does not account for change in daylight savings time
      eastern_offset = Rational(-5, 24)

      eastern_timezone_date = parsed_pacific_timezone_date.new_offset(eastern_offset).rfc3339

      return eastern_timezone_date
    rescue ArgumentError
      print("Error parsing date #{input} -- omiting this row from the results")
      return nil
    end
  end

  # TODO - confirm it's ok to return this as a string
  # I think zipcodes make more sense as a string than an int anyway
  def format_zipcode(zip)
    return zip.to_s.rjust(5, "0")
  end

  def format_name(name)
    return name.upcase
  end

  def duration_of_seconds(duration)
    time_components = duration.split(":")
    return (time_components[0].to_f * 3600) + (time_components[1].to_f * 60) + time_components[2].to_f
  end

end
