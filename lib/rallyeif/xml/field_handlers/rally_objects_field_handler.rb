# Copyright 2001-2014 Rally Software Development Corp. All Rights Reserved.

# Tag Name
#   RallyObjectsXMLFieldHandler

# Description
#   Given a Rally field that references a collection of objects, 
#   return an XML string
#
# The field handler specification in a config file looks like...
#
#   <RallyObjectsXMLFieldHandler>
#      <FieldName>Tasks</FieldName>
#   </RallyObjectsXMLFieldHandler>
#   

module RallyEIF
  module WRK
    module FieldHandlers

      class RallyObjectsXMLFieldHandler < RallyFieldHandler

        VALID_REFERENCES = [:Tasks,:Duplicates, :TestCases, :Tags, :ChangeSets]

        #  no need to transform in
        def transform_in(value)
          return value
        end

        # take a value and convert it to an xml string
        def transform_out(rally_artifact)
          RallyLogger.debug(self,"Transforming out #{rally_artifact}/#{rally_artifact.class}/#{@field_name}")

          # have to read because the helpful addition they made to make projects, iterations and releases render as strings
          rally_artifact.read
          reference_value = rally_artifact[@field_name]
          return nil if reference_value.nil?
          
          if reference_value.class == String #wsapi prior to 1.19 gives us a string of username
            return reference_value
          else
            return make_xml_for_objects(reference_value)
          end
        end
        
        def make_xml_for_objects(objects)
          RallyLogger.debug(self,"Making XML")
          xml = "    <#{@field_name}>\n"
          objects.each do |object|
            record_type = object['_type']
            ref = object['_ref'].gsub(/\.js/,"")
            name = object['_refObjectName']
            object.read
            fid = object['FormattedID']
              
            xml = xml + "      <#{record_type} ref=\"#{ref}\" name=\"#{name}\" formatted_i_d=\"#{fid}\" />\n"
          end
          xml = xml + "    </#{@field_name}>\n"
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
