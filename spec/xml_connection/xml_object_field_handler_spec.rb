require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/xml_spec_helper'

include XMLSpecHelper
include YetiTestUtils

describe "When writing out data that has fields with related records" do
  before(:each) do
    @xml_connection = xml_connect(XMLSpecHelper::XML_STATIC_CONFIG)
    @rally_connection = rally_connect(XMLSpecHelper::XML_CONNECTOR_STANDARD_CONFIG)
    @wsapi_version = @rally_connection.rally.wsapi_version
    
    @fh = RallyEIF::WRK::FieldHandlers::RallyObjectXMLFieldHandler.new()
  end
  
  after(:each) do
    # clean up (directory created on each connect()
    # FileUtils.remove_dir('./output_dir')
  end
  
  it "should transform out an owner with ref and user_name" do
    defect, name = YetiTestUtils::create_rally_artifact(@rally_connection, { 
      "Owner" => "#{TestConfig::RALLY_SOURCE_USER}" 
    })

    @fh.connection = @rally_connection
    @fh.field_name = "Owner"
    
    @fh.transform_out(defect).should == "    <Owner ref=\"https://#{TestConfig::RALLY_SOURCE_URL}/slm/webservice/#{@wsapi_version}/user/#{TestConfig::RALLY_SOURCE_USER_OID}\" user_name=\"#{TestConfig::RALLY_SOURCE_USER}\" />\n"
    defect.delete
  end
  
  it "should transform out a submitter with ref and user_name" do
    defect, name = YetiTestUtils::create_rally_artifact(@rally_connection, { 
      "SubmittedBy" => "#{TestConfig::RALLY_SOURCE_USER}" 
    })

    @fh.connection = @rally_connection
    @fh.field_name = "SubmittedBy"
    
    @fh.transform_out(defect).should == "    <SubmittedBy ref=\"https://#{TestConfig::RALLY_SOURCE_URL}/slm/webservice/#{@wsapi_version}/user/#{TestConfig::RALLY_SOURCE_USER_OID}\" user_name=\"#{TestConfig::RALLY_SOURCE_USER}\" />\n"
    defect.delete
  end
  
  it "should transform out a project with ref and name" do
    defect, name = YetiTestUtils::create_rally_artifact(@rally_connection, { 
      "Owner" => "#{TestConfig::RALLY_SOURCE_USER}" 
    })

    @fh.connection = @rally_connection
    @fh.field_name = "Project"
    
    @fh.transform_out(defect).should == "    <Project ref=\"https://#{TestConfig::RALLY_SOURCE_URL}/slm/webservice/#{@wsapi_version}/project/#{TestConfig::RALLY_SOURCE_PROJECT_1_OID}\" name=\"#{TestConfig::RALLY_SOURCE_PROJECT_1}\" />\n"
    defect.delete
  end
  
  it "should not transform out a nil submitter" do
    defect, name = YetiTestUtils::create_rally_artifact(@rally_connection, { 
      "Owner" => "#{TestConfig::RALLY_SOURCE_USER}" 
    })

    @fh.connection = @rally_connection
    @fh.field_name = "SubmittedBy"
    
    @fh.transform_out(defect).should be_nil
    defect.delete
  end
  
end

