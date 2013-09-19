# lib/rulers/file_model.rb
require "multi_json"

module Rulers
  module Model
    class FileModel
      DB_HOME = "db/quotes"

      @@cache = {}
      
      def self.clear_cache
        @@cache = {}  
      end
      
      def FileModel.new(pathname)
        @id = FileModel.get_id_from_pathname(pathname)
        if !@@cache[@id]
          @@cache[@id] = super
        end
        @@cache[@id]
      end
      
      def initialize(pathname)
        @id = FileModel.get_id_from_pathname(pathname)
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
        @hash[name.to_s] = value
      end
      
      def self.find(id)
        begin
          self.new("#{DB_HOME}/#{id}.json")
        rescue Exception => e
          STDERR.puts "WARNING: fetch for Model \##{id} failed. \n" + e.inspect + "\n" + e.backtrace.join("\n  ")
          return nil
        end
      end
      
      def self.find_all
        Dir["#{DB_HOME}/*.json"].map { |file| FileModel.new file }
      end
      
      def self.find_all_by(criteria = {})
        find_all.select { |model|
          criteria.all? { | key, value |
            model[key] == value
          } 
        }
      end
      
      #TODO: implement "responds_to?"
      def self.method_missing(method_sym, *args, &block)
        if method_sym.to_s =~ /find_all_by_(.*)$/
          attribute = $1
          value = args[0]
          find_all_by({attribute => value})
        else
          super
        end
      end
      
      def self.create(attrs)
        id = get_next_id
        persist id, FileModel.generate_record_from(attrs)
        FileModel.find(id)
      end
      
      def save
        FileModel.persist @id, @hash
      end
      
    protected
      
      def self.get_next_id
        max_id = Dir["#{DB_HOME}/*.json"].map { |pathname| FileModel.get_id_from_pathname(pathname) }.max
        id = max_id + 1
      end
      
      def self.get_id_from_pathname(pathname)
        File.basename(File.split(pathname)[-1], '.json').to_i
      end
      
      def self.generate_record_from(attrs)
        record = {}
        record["quote"] = attrs["quote"] || ""
        record["attribution"] = attrs["attribution"] || ""
        record["submitter"] = attrs["submitter"] || ""
        record
      end
      
      def self.persist(id, data)
        File.open("#{DB_HOME}/#{id}.json", "w") do |file|
          file.write MultiJson.dump(data)
        end
      end         
    end
  end
end