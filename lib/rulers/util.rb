# /lib/rulers/util.rb

module Rulers
  def self.to_snakecase(string)
    string.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
      gsub(/([a-z\d])([A-Z])/, '\1_\2').
      tr("-", "_").
      downcase
  end
end