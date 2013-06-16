RSpec::Matchers.define :be_a_symlink_to do |expected|
  match do |actual|
    File.identical?(expected, actual)
  end
end
