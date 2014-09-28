module RallyEIF
  module WRK
    class ConnectorRunner
      def version_info()
        hub_version    = "#{RallyEIF::WRK::Version.to_s} (with embedded overrides)"
         
        rally_version  = RallyEIF::WRK::RallyConnection.version_message 
        other_version  = ""
        other_version  = get_connection_class(@connector_type).version_message unless @connector_type.nil?

        return [hub_version, rally_version, other_version]
      end
      def send_email(config_name)
        return nil if RallyLogger.warnings_cache.length == 0 && RallyLogger.errors_cache.length == 0
  
        errors   = RallyLogger.errors_cache.length   > 0
        warnings = RallyLogger.warnings_cache.length > 0
  
        problems = []
        problems << "Errors"   if errors
        problems << "Warnings" if warnings
  
        driver_base = File.basename(@driver)
        email_msg  = {:from_address => @email_config[:send_from], :to_address => @email_config[:send_to] }
        email_msg[:subject]         = "#{driver_base} #{problems.join(" & ")} for #{config_name}"
        email_msg[:message_content] = ""
  
        if errors
          email_msg[:message_content] << "\nErrors:\n"
          RallyLogger.errors_cache.each do |error_msg|
            email_msg[:message_content] << "\n#{error_msg[:time]} - #{error_msg[:message]}"
          end
        end
  
        if warnings
          break_line = "\n------------------------------------------------------------------------------------------------------------\n"
          email_msg[:message_content] << break_line
          email_msg[:message_content] << "\nWarnings:\n"
          RallyLogger.warnings_cache.each do |error_msg|
            email_msg[:message_content] << "\n#{error_msg[:time]} - #{error_msg[:message]}"
          end
        end
  
        RallyLogger.debug(self,"Rolling email message: #{email_msg}")
        email_sender = YetiMailer.new(@email_config)
        email_sent = email_sender.send_message(email_msg)
        RallyLogger.info(self, "Email sent to #{@email_config[:send_to]} for #{config_name}.")
        email_sent
      end
    end
  end
end