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
      
      def connect()
        RallyLogger.debug(self,"Connecting to filesystem to prepare to write XML")
        return
      end
    end
  end
end