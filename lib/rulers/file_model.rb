# lib/rulers/file_model.rb
require "multi_json"

module Rulers
  module Model
    class FileModel
      DB_HOME = "db/quotes"
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
        # begin
          FileModel.new("#{DB_HOME}/#{id}.json")
        # rescue Exception => e
        #   STDERR.puts e.inspect
        #   return nil
        # end
      end
      
      def self.find_all
        files = Dir["#{DB_HOME}/*.json"]
        files.map { |file| FileModel.new file }
      end
      
      def self.create(attrs)
        record = FileModel.generate_record_from attrs
        id = get_next_id
        
        File.open("#{DB_HOME}/#{id}.json", "w") do |file|
          json = FileModel.generate_json_from record
          file.write json
        end
        FileModel.find(id)
      end
      
      def save
        File.open("#{DB_HOME}/#{@id}.json", "w") do |file|
          json = FileModel.generate_json_from @hash
          file.write json
        end
        
        self
      end
      
    protected
      
      def self.get_next_id
        pathnames = Dir["#{DB_HOME}/*.json"]
        max_id = pathnames.map { |pathname| FileModel.get_id_from_pathname(pathname) }.max
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
      
      def self.generate_json_from(record)
        json = <<TEMPLATE
{
"submitter" : "#{record["submitter"]}",
"quote" : "#{record["quote"]}",
"attribution" : "#{record["attribution"]}"
}
TEMPLATE
        json
      end
         
    end
  end
end