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
    end
  end
end