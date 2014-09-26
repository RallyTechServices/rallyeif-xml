# Copyright 2001-2014 Rally Software Development Corp. All Rights Reserved.
require File.dirname(__FILE__) + '/spec_helper'
if !File.exist?(File.dirname(__FILE__) + '/test_configuration_helper.rb')
  puts
  puts " You must create a file with your test values at #{File.dirname(__FILE__)}/test_configuration_helper.rb"
  exit 1
end
require File.dirname(__FILE__) + '/test_configuration_helper'
require 'rallyeif-wrk'
require File.dirname(__FILE__) + '/../../lib/rallyeif-xml'

#  xml_spec_helper.rb
#

include YetiTestUtils

module XMLSpecHelper

  XMLConnection          = RallyEIF::WRK::XMLConnection           if not defined?(XMLConnection)
  RecoverableException   = RallyEIF::WRK::RecoverableException   if not defined?(RecoverableException)
  UnrecoverableException = RallyEIF::WRK::UnrecoverableException if not defined?(UnrecoverableException)
  YetiSelector           = RallyEIF::WRK::YetiSelector           if not defined?(YetiSelector)
  FieldMap               = RallyEIF::WRK::FieldMap               if not defined?(FieldMap)
  Connector              = RallyEIF::WRK::Connector              if not defined?(Connector)

  XML_MISSING_PATH_CONFIG = "
    <config>
        <XMLConnection>
          <User>None</User>
          <Password>None</Password>
          <ArtifactType>Defect</ArtifactType>
          <ExternalIDField>#{TestConfig::RALLY_SOURCE_EXTERNAL_ID_FIELD}</ExternalIDField>
        </XMLConnection>
      </config>"
  
  XML_MISSING_ARTIFACT_CONFIG = "
        <config>
          <XMLConnection>
            <User>None</User>
            <Password>None</Password>
            <ExternalIDField>#{TestConfig::RALLY_SOURCE_EXTERNAL_ID_FIELD}</ExternalIDField>
            <Path>output_dir</Path>
          </XMLConnection>
        </config>"
  
  XML_STATIC_CONFIG = "
      <config>
        <XMLConnection>
          <User>None</User>
          <Password>None</Password>
          <ArtifactType>Defect</ArtifactType>
          <ExternalIDField>#{TestConfig::RALLY_SOURCE_EXTERNAL_ID_FIELD}</ExternalIDField>
          <Path>output_dir</Path>
        </XMLConnection>
      </config>"

  XML_CONNECTOR_STANDARD_CONFIG = "
      <config>
        <RallyConnection>
          <Url>#{TestConfig::RALLY_SOURCE_URL}</Url>
          <WorkspaceName>#{TestConfig::RALLY_SOURCE_WORKSPACE}</WorkspaceName>
          <Projects>
            <Project>#{TestConfig::RALLY_SOURCE_PROJECT_1}</Project>
          </Projects>
          <User>#{TestConfig::RALLY_SOURCE_USER}</User>
          <Password>#{TestConfig::RALLY_SOURCE_PASSWORD}</Password>
          <ArtifactType>Defect</ArtifactType>
          <ExternalIDField>#{TestConfig::RALLY_SOURCE_EXTERNAL_ID_FIELD}</ExternalIDField>
        </RallyConnection>
  
        <XMLConnection>
          <User>None</User>
          <Password>None</Password>
          <ArtifactType>Defect</ArtifactType>
          <ExternalIDField>#{TestConfig::RALLY_SOURCE_EXTERNAL_ID_FIELD}</ExternalIDField>
          <Path>/output_dir/full_cycle</Path>
       </XMLConnection>

       <Connector>
        <FieldMapping>
          <Field><Rally>Name</Rally><Other>Headline</Other></Field>
          <Field><Rally>Project</Rally><Other>Project</Other></Field>
        </FieldMapping>
 
      </Connector>
    </config>"

  XML_CONNECTOR_MAPPING_ALL_CONFIG = "
      <config>
        <RallyConnection>
          <Url>#{TestConfig::RALLY_SOURCE_URL}</Url>
          <WorkspaceName>#{TestConfig::RALLY_SOURCE_WORKSPACE}</WorkspaceName>
          <Projects>
            <Project>#{TestConfig::RALLY_SOURCE_PROJECT_1}</Project>
          </Projects>
          <User>#{TestConfig::RALLY_SOURCE_USER}</User>
          <Password>#{TestConfig::RALLY_SOURCE_PASSWORD}</Password>
          <ArtifactType>Defect</ArtifactType>
          <ExternalIDField>#{TestConfig::RALLY_SOURCE_EXTERNAL_ID_FIELD}</ExternalIDField>
        </RallyConnection>
  
        <XMLConnection>
          <User>None</User>
          <Password>None</Password>
          <ArtifactType>Defect</ArtifactType>
          <ExternalIDField>#{TestConfig::RALLY_SOURCE_EXTERNAL_ID_FIELD}</ExternalIDField>
          <Path>/output_dir/full_cycle</Path>
       </XMLConnection>

       <Connector>
        <FieldMapping all_rally_fields='true'>
        </FieldMapping>
      </Connector>
    </config>"
  
  def xml_connect(config_file)
    root = YetiTestUtils::load_xml(config_file).root
    connection = XMLConnection.new(root)
    connection.connect()
    return connection
  end

  def rally_connect(config_file)
    root = YetiTestUtils::load_xml(config_file).root
    connection = RallyEIF::WRK::RallyConnection.new(root)
    connection.connect()
    return connection
  end
end
