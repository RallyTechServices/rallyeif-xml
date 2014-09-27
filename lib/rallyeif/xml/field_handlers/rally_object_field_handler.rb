# Copyright 2001-2014 Rally Software Development Corp. All Rights Reserved.

# Tag Name
#   RallyObjectXMLFieldHandler

# Description
#   Given a Rally field that references an object, return
#   an XML string

#
# The field handler specification in a config file looks like...
#
#   <RallyObjectXMLFieldHandler>
#      <FieldName>Project</FieldName>
#   </RallyObjectXMLFieldHandler>
#   

module RallyEIF
  module WRK
    module FieldHandlers

      class RallyObjectXMLFieldHandler < RallyFieldHandler
        
        VALID_REFERENCES = [:Project, :Workspace, :Subscription, 
          :Release, :Iteration, :Owner, 
          :WorkProduct, :SubmittedBy, :TestCase, :TestCaseResult]

        #  no need to transform in
        def transform_in(value)
          return value
        end

        # take a value and convert it to an xml string
        def transform_out(rally_artifact)
          RallyLogger.debug(self,"Transforming out #{rally_artifact}/#{rally_artifact.class}/#{@field_name}")
#          reference_value = @connection.get_value(rally_artifact, @field_name)
          # have to read because the helpful addition they made to make projects, iterations and releases render as strings
          rally_artifact.read
          reference_value = rally_artifact[@field_name]
          RallyLogger.debug(self, "Working with #{reference_value}")
          return nil if reference_value.nil? || reference_value.empty?
          
          if reference_value.class == String #wsapi prior to 1.19 gives us a string of username
            return reference_value
          else
            return make_xml_for_object(reference_value)
          end
        end
        
        def make_xml_for_object(object)
          record_type = object['_type']
          ref = object['_ref'].gsub(/\.js/,"")
          name = object['_refObjectName']
          xml = "    <#{@field_name} ref=\"#{ref}\" name=\"#{name}\" />\n"
          if record_type == "User" then
            object.read
            name = object['UserName']
            xml = "    <#{@field_name} ref=\"#{ref}\" user_name=\"#{name}\" />\n"
          end
          return xml
        end

        def read_config(fh_element)

          fh_element.elements.each do |element|
            if (element.name == "FieldName")
              @field_name = get_element_text(element).intern
            else
              raise UnrecoverableException.new("Element #{element.name} not expected in " +
                                                   "RallyObjectXMLFieldHandler config", self)
            end
          end

          if (VALID_REFERENCES.index(@field_name) == nil)
            raise UnrecoverableException.new("Field name for RallyObjectXMLFieldHandler must be from " +
                                                 "the following set #{VALID_REFERENCES}", self)
          end
        end
      end

    end
  end
end
