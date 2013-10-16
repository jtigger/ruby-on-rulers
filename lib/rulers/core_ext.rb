class Module
  def remove_possible_method(name)
    if method_defined?(name) || private_method_defined?(name)
      undef_method(name)
    end
  end
end

class Class
  def class_attribute(attr)
    # define the reader
    define_singleton_method(attr) { nil }
    
    # the writer simply redefines the reader
    define_singleton_method("#{attr}=") do |new_value|
      singleton_class.class_eval do
        remove_possible_method(attr)
        define_method(attr) { new_value }
      end
    end
  end
end

class String
  def to_camel_case
    split(/[_ ]/).map { |word| word.capitalize }.join ''
  end
  
  def to_snake_case
    gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
    gsub(/([a-z\d])([A-Z])/, '\1_\2').
    tr("-", "_").
    downcase
  end
end