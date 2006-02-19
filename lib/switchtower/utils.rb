module SwitchTower
  # A helper method for converting a comma-delimited string into an array of
  # roles.
  def self.str2roles(string)
    list = string.split(/,/).map { |s| s.strip.to_sym }
    list.empty? ? nil : list
  end
end