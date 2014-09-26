module RallyEIF
  module WRK
    class Connector
      def read_config(root)
        #fields = root.elements["*/FieldMapping"]
        fields = XMLUtils.elements_at(root,"*/FieldMapping")
        
        # here is where the override is
        @field_mapping = get_modified_field_mappings(fields)
      
        read_field_handlers(root, @rally_connection, "RallyFieldHandlers")
        read_field_handlers(root, @other_connection, "OtherFieldHandlers")
        read_related_object_linkers(root)
        read_post_batch_actions(root)
      end
      
      def mapped_fields_contains(mapped_fields,mapped_field)
        field_name = mapped_field.rally_attr
        is_in_array = false
        mapped_fields.each do |field|
          if field_name == field.rally_attr
            is_in_array = true
          end
        end
        is_in_array
      end
          
      def get_modified_field_mappings(fields)
        # does FieldMapping node have an attribute of all_rally_fields="true"?
        # if so, get all the fields from Rally and construct new mappings
        use_all_fields = false
        if !fields.attribute('all_rally_fields').nil? && "#{fields.attribute('all_rally_fields')}".downcase == "true"
          use_all_fields = true
        end
        
        all_mapped_fields = []
        if use_all_fields then
          RallyLogger.info(self," Using all Rally Fields")
          if @rally_connection.rally.nil?
            @rally_connection.connect()
          end
          forbidden_fields = ['Attachments','Tasks','RevisionHistory','Discussion','TestCase']
          rally_fields = @rally_connection.rally.get_fields_for(@rally_connection.artifact_type)
          rally_fields.each_key do |field|
            if !forbidden_fields.include?(field) && rally_fields[field].AttributeType != "WEB_LINK"
              all_mapped_fields.push(FieldMap.new(field, field, nil))
            end
          end
        end
        
        # then, if there are also traditional field_mappings, merge them together.
        mapped_fields = XMLUtils.read_field_mapping(fields)
        
        all_mapped_fields.each do |mapped_field|
          if !mapped_fields_contains(mapped_fields,mapped_field)
            mapped_fields.push(mapped_field)
          end
        end
        
        mapped_fields
      end
    end
   
  end
end