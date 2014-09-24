# Copyright 2001-2014 Rally Software Development Corp. All Rights Reserved.

require 'rallyeif-wrk'

RecoverableException   = RallyEIF::WRK::RecoverableException if not defined?(RecoverableException)
UnrecoverableException = RallyEIF::WRK::UnrecoverableException
RallyLogger            = RallyEIF::WRK::RallyLogger
XMLUtils               = RallyEIF::WRK::XMLUtils

#GetClearQuestAPIVersionMajor, GetClearQuestAPIVersionMinor

module RallyEIF
  module WRK
    class XMLConnection < Connection
      attr_accessor :path, :path_to_output_file
      
      def initialize(config=nil)
        @start_in_seconds = Time.new.to_i
        super()
        read_config(config) if !config.nil?
      end
      
      def read_config(config)
        @artifact_type = XMLUtils.get_element_value(config,'XMLConnection',"ArtifactType")
        @path = XMLUtils.get_element_value(config,'XMLConnection',"Path")
        @path = "./#{@path}".gsub(/\/\//,'/').gsub(/\.\/\.\//,'./')
        
        @path_to_output_file = "#{@path}/#{@start_in_seconds}.xml"
      end
      
      def name()
        return "John and JP's XML Connector"
      end
      
      def version()
        return RallyEIF::XML::Version
      end

      def self.version_message()
        version_info = "#{RallyEIF::XML::Version}-#{RallyEIF::XML::Version.detail}"
        return "XMLConnection version #{version_info}"
      end
      
      def get_backend_version()
        return "%s %s" % [name, version]
      end
      
      def field_exists? (field_name)
        return true
      end
      
      def disconnect()
        RallyLogger.info(self,"Would disconnect at this point if we needed to")
      end
      
      def connect()
        RallyLogger.debug(self,"**************************************")
        RallyLogger.debug(self,"Connecting to filesystem to prepare to write XML")
        RallyLogger.debug(self,"Connector Name   : #{name}")
        RallyLogger.debug(self,"Connector Version: #{version}")
        RallyLogger.debug(self,"Artifact Type    : #{artifact_type}")
        RallyLogger.debug(self,"Save Path        : #{path}")
        RallyLogger.debug(self,"**************************************")
        
        validate()
        return
      end
      
      def validate
        valid_artifact_types = ["Defect"]
        if !valid_artifact_types.include?(@artifact_type)
          RallyLogger.error(self,"This ArtifactType is not supported: #{@artifact_type}")
          raise UnrecoverableException.new("Unsupported ArtifactType: #{@artifact_type}",self)
        end
        
        if File.file?(@path) then
          raise UnrecoverableException.new("Path must be a directory, not a file: #{@path}",self)
        end
        
        if !Dir.exists?(@path) then
          FileUtils::mkdir_p(@path)
        end
        
      end
      
      def create_internal(int_work_item)
        item_xml = item_to_xml(int_work_item)
        
        if File.file?(@path_to_output_file) then
          RallyLogger.info(self,"    UPDATING file at #{@path_to_output_file}")
          existing_file_contents = ""
          File.open(@path_to_output_file,"rb").each { |line|
            if ( line != "<items>\n" && line != "</items>\n") then
              existing_file_contents = existing_file_contents + line
            end
          }
          item_xml = existing_file_contents + item_xml
        else
          RallyLogger.info(self,"    CREATING file at #{@path_to_output_file}")
        end
        
        File.open(@path_to_output_file,'w') { |file|
          file.write("<items>\n")
          file.write(item_xml)
          file.write("</items>\n")
        }
      end
      
      # item is an OrderedHash
      def item_to_xml(item)
        item_type = @artifact_type.downcase
        xml = "  <#{item_type}>\n"
        
        item.each_key do |key|
          if key != "_type" && !key.nil? then
            xml = xml + "    <#{key}>#{item[key]}</#{key}>\n"
          end
        end
        xml = xml + "  </#{item_type}>\n"
        return xml
      end
    end
  end
end