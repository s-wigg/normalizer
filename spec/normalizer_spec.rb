require 'normalizer'
require 'date'
describe Normalizer do

  # TODO - add additioanl tests when time zone conversion changes the date
  it "converts from pacific to east coast time" do
    input_date = "4/1/11 11:00:00 AM"
    normalizer = Normalizer.new
    converted_date = normalizer.parse_date(input_date)
    expect(DateTime.strptime(input_date, '%m/%d/%Y %l:%M:%S %p %:z').hour + 3).to eq(DateTime.strptime(converted_date).hour)
  end

  it "always gives back 5 digit zipcode" do
    normalizer = Normalizer.new
    output_zipcode = normalizer.format_zipcode(1231)
    expect(output_zipcode.length).to eq(5)
    expect(output_zipcode).to eq("01231")
  end

  it "convert H:M:S:MS to duration of seconds works" do
    normalizer = Normalizer.new
    duration_of_seconds = normalizer.duration_of_seconds("1:01:01.1")
    expect(duration_of_seconds).to eq(3661.1)
  end
end
