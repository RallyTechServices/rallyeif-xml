module RallyEIF
  module WRK

    class YetiMailer
      # override to remove leading spaces
      def make_msg_str(message_info)

        today_now = DateTime.now
        subject = message_info[:subject]

        full_message ="From: #{message_info[:from_address]}\nTo: #{message_info[:to_address]}\nSubject: #{subject}\nDate: #{today_now.iso8601}\n"
        full_message = full_message + <<-END_OF_MESSAGE
        #{message_info[:message_content]}
        END_OF_MESSAGE

        RallyLogger.debug(self,"Full: #{full_message}")

        return full_message
      end
    end
  end
end