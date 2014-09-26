require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/xml_spec_helper'

include XMLSpecHelper
include YetiTestUtils

# THIS CONNECTS TO RALLY.  WILL BE SLOWER

describe "Given configuration in the Connector section" do
  before(:all) do
    #
  end
  
  it "should read field mappings when various maps applied" do
    root = YetiTestUtils::load_xml(XMLSpecHelper::XML_CONNECTOR_STANDARD_CONFIG).root
    xml_connection = xml_connect(XMLSpecHelper::XML_STATIC_CONFIG)
    rally_connection = rally_connect(XMLSpecHelper::XML_CONNECTOR_STANDARD_CONFIG)
    
    connector = RallyEIF::WRK::Connector.new(root,rally_connection,xml_connection)
  
    connector.field_mapping.length.should == 2
    
#    puts connector.field_mapping[0].rally_attr
#    puts connector.field_mapping[0].other_attr
  end
  
  it "should set field mappings when ALL chosen" do
    root = YetiTestUtils::load_xml(XMLSpecHelper::XML_CONNECTOR_MAPPING_ALL_CONFIG).root
    xml_connection = xml_connect(XMLSpecHelper::XML_STATIC_CONFIG)
    rally_connection = rally_connect(XMLSpecHelper::XML_CONNECTOR_MAPPING_ALL_CONFIG)
    
    connector = RallyEIF::WRK::Connector.new(root,rally_connection,xml_connection)
  
    connector.field_mapping.length.should > 2
  end
  
  it "should set field mappings when both ALL and mappings chosen" do
    
  end
  
  it "should assume all if no field mappings given" do
    
  end
  
  it "should format reference fields properly" do
    # TODO: create a reference field handler (needs tests, too)
  end
  
  it "should handle duplicates properly" do
    # TODO: create a duplicates field handler (needs tests, too)
  end
end