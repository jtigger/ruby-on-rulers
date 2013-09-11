# /lib/rulers/dependencies.rb
class Object
  def self.const_missing(c)
    # if the last line of this method fails to get the class definition, this method is invoked again.
    penultimate_caller = caller[1][/`([^']*)'/,1]
    if penultimate_caller == "const_missing"
      raise "Found file #{Rulers.to_underscore(c.to_s)}.rb, but failed to find #{c.to_s} in it (is either the filename or classname misspelled?)."
    end

    require Rulers.to_underscore(c.to_s)
    Object.const_get(c)
  end
end