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
      attr_accessor :path
      
      def initialize(config=nil)
        super()
        read_config(config) if !config.nil?
      end
      
      def read_config(config)
        @artifact_type = XMLUtils.get_element_value(config,'XMLConnection',"ArtifactType")
        @path = XMLUtils.get_element_value(config,'XMLConnection',"Path")
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
      end
    end
  end
end