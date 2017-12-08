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
        collection_fields =  [:Tasks,:Duplicates, :TestCases, :Tags, :ChangeSets]

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

      # override because of field value checking (external id)
      def update_other(params)
        operation    = params[:operation] || :update
        rally_wkitem = params[:artifact]
        rally_wkitem_id   = @rally_connection.get_id_value(rally_wkitem)
        rally_external_id = @rally_connection.get_value(rally_wkitem, @rally_connection.external_id_field())
        rally_item = "Rally #{@rally_connection.artifact_type} #{rally_wkitem.FormattedID}"
        begin
          # THIS IS AN OVERRIDE
          #other_wkitem    = @other_connection.find_by_external_id(rally_wkitem_id)
          other_wkitem    = rally_wkitem
        rescue RallyEIF::WRK::RecoverableException => ex
          situation = "Counterpart item to #{rally_item} not found in #{@other_connection.name}, no update possible; "
          situation << "Exception generated was #{ex.message}"
          RallyLogger.warning(self, situation)
          return nil
        end
        other_wkitem_id = @other_connection.get_id_value(other_wkitem)
        other_item  = "#{@other_connection.name} #{@other_connection.artifact_type} #{other_wkitem_id}"

        if rally_external_id.to_s != other_wkitem_id.to_s
          situation = "#{other_item} matched to #{rally_item} has mismatched external identifier in Rally item"
          RallyLogger.warning(self, situation)
          return nil
        end

        RallyLogger.info(self, "Updating #{other_item} from #{rally_item} ...")

        begin
          update_fields = map_fields_to_other(rally_wkitem, operation, params[:last_run])
        rescue StandardError => ex
          RallyLogger.error(self, "#{rally_item} NOT updated to #{other_item} (#{ex.message})")
          return nil
        end

        begin
          updated_other_wkitem = @other_connection.update(other_wkitem, update_fields)
        rescue Exception => ex
          RallyLogger.error(self, "Unable to update #{other_item}, #{ex.message}")
          return nil
        end

        linkage = 0
        @related_object_linkers.each do |linker|
          linker.link_related_objects_in_other(rally_wkitem, other_wkitem, :update) #linkers are expecting just :update
          #status = linker.link_related_objects_in_other(rally_wkitem, other_wkitem, :update) #linkers are expecting just :update
          #linkage += 1 if status == 'linked'
        end

        RallyLogger.info(self, "#{other_item} updated from #{rally_item}")
        return updated_other_wkitem
      end

      # OVERRIDE SO THAT UPDATE PROVIDES all THE FIELDS, not just changed ones
      def map_fields_to_other(rally_object, operation, reference_time = Time.now.utc)
        int_work_item = OrderedHash.new
        @other_connection.field_defaults.each_pair { |key, val| int_work_item[key] = val } if operation == :create

        changed_rally_fields = []
        if operation == :update
          mapped_rally_fields  = @field_mapping.select {|mf| mf.direction != Direction::TO_RALLY}.collect{|mf| mf.rally_attr.to_s}
          changed_rally_fields = @rally_connection.fields_changed(rally_object, reference_time, mapped_rally_fields)
        end

        @field_mapping.each do |map|
          if operation == :update
            if not changed_rally_fields.include?(map.rally_attr.to_s)
              # OVERRIDE: don't tell the world something didn't change because we aren't going to care
              #RallyLogger.debug(self, "#{map.rally_attr.to_s} value was not changed, not included in update fields")
            end
          end

          # OVERRIDE TO NOT SKIP FIELDS
          #next if operation == :update && !changed_rally_fields.include?(map.rally_attr.to_s)  #skip the field if it wasn't changed in Rally
          next if map.direction == Direction::TO_RALLY

          orig_rally_value = @rally_connection.get_value(rally_object, map.rally_attr) # get the value from Rally
          rally_value = orig_rally_value
          rfh = @rally_connection.find_field_handler(map.rally_attr) # if there is a field_handler registered, transform the rally_value
          rally_value = rfh.transform_out(rally_object) if !rfh.nil?

          ofh = @other_connection.find_field_handler(map.other_attr)
          other_value = rally_value
          if rally_value && rally_value.is_a?(RallyAPI::RallyObject)
            rally_value.refresh
            rally_value = rally_value["UserName"]
          end
          other_value = ofh.transform_in(rally_value) if !ofh.nil?

          # Map the field only if it's not nil and not 'None', except that 'None' is ok if there is a field handler
          # This covers the case where field lists are identical in Rally and other and there is no enumfieldhandler,
          #    so we should not send Rally's 'None' to the other system
          # TODO: what if we wanted to set something to nil or None?

          if @other_connection.user_fields.include?(map.other_attr.to_s)
            # verify rally_value is in the users_cache otherwise assign rally_value is nil
            other_object = @other_connection.user_by_username(other_value)
            if other_object
              other_value = other_object.name
            else
              other_value = nil
            end
            if rally_value && other_value.nil?
              anomaly = "  Mapping #{map.rally_attr}(#{orig_rally_value}) - to - #{map.other_attr}()  [no mapping value found]"
              RallyLogger.debug(self, anomaly)
              user_name = nil
              if orig_rally_value
                orig_rally_value.refresh
                user_name = orig_rally_value["UserName"]
              end
              problem = "Rally #{map.rally_attr} value of |#{user_name}| not mapped to a valid #{@other_connection.name} user field value"
              raise StandardError, problem
            end
          end

          map_action = map_action_text(map.rally_attr, orig_rally_value, map.other_attr, other_value)
          if other_value
            if other_value != 'None' || !ofh.nil?
              int_work_item[map.other_attr] = other_value
            else
              map_action << " (this field skipped as the #{ofh.class.name} transformed #{map.other_attr} to None)"
            end
          else
            map_action << " (this field skipped as #{map.other_attr} is nil)"
          end
          RallyLogger.debug(self, map_action)

        end
        return int_work_item
      end

      # not in older version, need it for override of mapping
      def map_action_text(from_attr, from_value, to_attr, to_value)
        begin
          text = "  Mapping #{from_attr}(#{from_value}) - to - #{to_attr}(#{to_value})"
        rescue => ex
          printable_from_value = from_value.gsub(/[^[:print:]]/) {|x| x.ord < 128 ? x : "<\\%02x>" % [x.ord]}
          printable_to_value     = to_value.gsub(/[^[:print:]]/) {|x| x.ord < 128 ? x : "<\\%02x>" % [x.ord]}
          text = "  Mapping #{from_attr}(#{printable_from_value}) - to - #{to_attr}(#{printable_to_value})"
        end
        return text
      end


    end
  end
end
