require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/xml_spec_helper'

include XMLSpecHelper
include YetiTestUtils

describe "The XML Connection Config File" do
  before(:all) do
    #
  end
  
  it "should successfully load basic config settings " do
    @xml_connection = xml_connect(XMLSpecHelper::XML_STATIC_CONFIG)
    @xml_connection.artifact_type.should == "Defect"
    @xml_connection.path.should == "/test_dir"
  end
  
  it "should reject missing required fields" do
    expect { xml_connect(XMLSpecHelper::XML_MISSING_ARTIFACT_CONFIG) }.to raise_error
    expect { xml_connect(XMLSpecHelper::XML_MISSING_PATH_CONFIG) }.to raise_error
  end
  it "should reject invalid artifact types" do
    expect { xml_connect(XMLSpecHelper::XML_BAD_ARTIFACT_CONFIG) }.to raise_error
  end
  
  it "should read field setting when various maps applied" do
    
  end
  
  it "should set field settings when ALL chosen" do

  end
  
  it "should set field settings when both ALL and mappings chosen" do
    
  end
  
  it "should assume all if no field setttings given" do
    
  end
end