# overrides
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
        
        # add additional field handlers if necessary
        set_xml_field_handlers(@rally_connection,@field_mapping)
        
        read_related_object_linkers(root)
        read_post_batch_actions(root)
      end
      
      def set_xml_field_handlers(connection,mapped_fields)
        object_fields =  [:Project, :Workspace, :Subscription, :Release, :Iteration, :Owner, 
        :WorkProduct, :SubmittedBy, :TestCase, :TestCaseResult]
        collection_fields =  [:Tasks,:Duplicates]
                
        mapped_fields.each do |field_map|
          name = field_map.rally_attr
          
          RallyLogger.debug(self,"Checking if field handler should be one of our special ones: #{name}")
          if object_fields.include?(name.to_sym) && "#{connection.class}" ==  "RallyEIF::WRK::RallyConnection"
            RallyLogger.debug(self,"Using RallyObjectXMLFieldHandler ")
            connection.register_field_handler( stub_field_handler("RallyObjectXMLFieldHandler",name,connection) )
          end
          
          if collection_fields.include?(name.to_sym) && "#{connection.class}" ==  "RallyEIF::WRK::RallyConnection"
            RallyLogger.debug(self,"Using RallyObjecstXMLFieldHandler ")
            connection.register_field_handler( stub_field_handler("RallyObjectsXMLFieldHandler",name,connection) )
          end
        end
      end
      
      def stub_field_handler (field_handler_name,field_name,connection)
        begin
          field_handler = RallyEIF::WRK.get_scoped_class("RallyEIF::WRK::FieldHandlers::#{field_handler_name}").new()
          field_handler.field_name = field_name
          field_handler.connection = connection
        rescue => ex
          RallyLogger.error(self, "For #{connection.class.to_s}: Could not find class for #{field_handler_name}")
          raise(ex)
        end
        
        RallyLogger.debug(self, "Found field handler class: #{field_handler.class}")
        return field_handler
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