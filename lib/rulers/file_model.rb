# lib/rulers/file_model.rb
require "multi_json"

module Rulers
  module Model
    class FileModel
      def initialize(pathname)
        filename = File.split(pathname)[-1]

        @id = File.basename(filename, ".json").to_i
        @pathname = pathname  
        @hash = MultiJson.load fetch_data(pathname)
      end
      
      def fetch_data(pathname)
         File.read(pathname)
      end

      def [](name)
        @hash[name.to_s]
      end
      
      def []=(name, value)
      end
    end
  end
end