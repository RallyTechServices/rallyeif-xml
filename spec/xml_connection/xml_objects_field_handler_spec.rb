require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/xml_spec_helper'

include XMLSpecHelper
include YetiTestUtils

describe "When writing out data that has fields with multiple related records" do
  before(:each) do
    @xml_connection = xml_connect(XMLSpecHelper::XML_STATIC_CONFIG)
    @rally_connection = rally_connect(XMLSpecHelper::XML_CONNECTOR_STANDARD_CONFIG)
    @wsapi_version = @rally_connection.rally.wsapi_version
    
    @fh = RallyEIF::WRK::FieldHandlers::RallyObjectsXMLFieldHandler.new()
  end
  
  after(:each) do
    # clean up (directory created on each connect()
    # FileUtils.remove_dir('./output_dir')
  end
  
  it "should transform out tasks to xml" do
    defect, name = YetiTestUtils::create_rally_artifact(@rally_connection, { 
      "Owner" => "#{TestConfig::RALLY_SOURCE_USER}" 
    })
    
    task_1,name_1 = YetiTestUtils::create_arbitrary_rally_artifact("Task", @rally_connection, { 
      "WorkProduct" => defect
    })

    task_2,name_2 = YetiTestUtils::create_arbitrary_rally_artifact("Task", @rally_connection, { 
      "WorkProduct" => defect
    })
    
    @fh.connection = @rally_connection
    @fh.field_name = "Tasks"
    
    good_xml = "    <Tasks>\n"
    good_xml = good_xml + "      <Task ref=\"https://#{TestConfig::RALLY_SOURCE_URL}/slm/webservice/#{@wsapi_version}/task/#{task_1['ObjectID']}\" name=\"#{name_1}\" formatted_i_d=\"#{task_1['FormattedID']}\" />\n"
    good_xml = good_xml + "      <Task ref=\"https://#{TestConfig::RALLY_SOURCE_URL}/slm/webservice/#{@wsapi_version}/task/#{task_2['ObjectID']}\" name=\"#{name_2}\" formatted_i_d=\"#{task_2['FormattedID']}\" />\n"
    good_xml = good_xml + "    </Tasks>\n"
    @fh.transform_out(defect).should == good_xml
    #defect.delete
  end
  
  
  it "should transform out duplicates to xml" do
    defect_duplicate_1, name_1 = YetiTestUtils::create_rally_artifact(@rally_connection, {     })

    defect_duplicate_2,name_2 = YetiTestUtils::create_rally_artifact(@rally_connection, {     })
        
    defect, name = YetiTestUtils::create_rally_artifact(@rally_connection, { 
      "Owner" => "#{TestConfig::RALLY_SOURCE_USER}",
      "Duplicates" => [ defect_duplicate_1, defect_duplicate_2 ]
    })
    
    @fh.connection = @rally_connection
    @fh.field_name = "Duplicates"
    
    good_xml = "    <Duplicates>\n"
    good_xml = good_xml + "      <Defect ref=\"https://#{TestConfig::RALLY_SOURCE_URL}/slm/webservice/#{@wsapi_version}/defect/#{defect_duplicate_1['ObjectID']}\" name=\"#{name_1}\" formatted_i_d=\"#{defect_duplicate_1['FormattedID']}\" />\n"
    good_xml = good_xml + "      <Defect ref=\"https://#{TestConfig::RALLY_SOURCE_URL}/slm/webservice/#{@wsapi_version}/defect/#{defect_duplicate_2['ObjectID']}\" name=\"#{name_2}\" formatted_i_d=\"#{defect_duplicate_2['FormattedID']}\" />\n"
    good_xml = good_xml + "    </Duplicates>\n"
    @fh.transform_out(defect).should == good_xml
    defect.delete
  end
end

