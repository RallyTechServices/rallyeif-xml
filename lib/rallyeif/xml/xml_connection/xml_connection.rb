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
        @external_id_field = XMLUtils.get_element_value(config,'XMLConnection',"ExternalIDField")
        @path = XMLUtils.get_element_value(config,'XMLConnection',"Path")
        @path = "./#{@path}".gsub(/\/\//,'/').gsub(/\.\/\.\//,'./')
        @host = "No host"

        @path_to_output_file = "#{@path}/#{@start_in_seconds}.xml"

      end

      def name()
        return "XML Connector"
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

      # find_by_external_id is forced from inheritance
      def find_by_external_id(external_id)
        {}
      end

      def get_object_link(artifact)
        return nil
      end

      def pre_create(int_work_item)
        return int_work_item
      end

      def create_internal(int_work_item)
        RallyLogger.debug(self,"  Preparing to save XML")
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

        RallyLogger.info( self, " Created #{@artifact_type} at #{@path_to_output_file}")
        return int_work_item
      end

      # This method will hide the actual call of how to get the id field's value
      def get_id_value(artifact)
        if artifact[@external_id_field].nil?
          return "waiting XML"
        else
          return artifact[@external_id_field]
        end
        #return "waiting XML"
      end

      # we don't really have anything to "update". Just write it out.
      def update_internal(artifact, int_work_item)
        # assume the external id field is the same name as the other system
        # if the only changed field is the external id field, don't do anything
        RallyLogger.debug(self,"Keys: |#{int_work_item.keys.join(',')}|, compare to |#{@external_id_field}|")
        if int_work_item.keys.length == 1 && int_work_item.keys[0] == @external_id_field
          RallyLogger.info(self, "Skipping because the only field that changed is #{@external_id_field}")
          return nil
        else
          if ( !artifact.nil? && !int_work_item.nil? && int_work_item[@external_id_field].nil? )
            int_work_item[@external_id_field] = artifact[@external_id_field]
          end
          return create_internal(int_work_item)
        end
      end

      # item is an OrderedHash
      def item_to_xml(item)
        item_type = @artifact_type.downcase
        xml = "  <#{item_type}>\n"

        item.each_key do |key|
          if key != "_type" && !key.nil? then
            if /\<#{key}/ =~ "#{item[key]}" then
              xml = xml + "#{item[key]}"
            else
              xml = xml + "    <#{key}>#{item[key]}</#{key}>\n"
            end
          end
        end
        xml = xml + "  </#{item_type}>\n"
        return xml
      end
    end
  end
end
