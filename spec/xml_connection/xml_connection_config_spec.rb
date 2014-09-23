require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/xml_spec_helper'

include XMLSpecHelper
include YetiTestUtils

describe "Given configuration in the XMLConnection section" do
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
    fred_artifact_config = YetiTestUtils::modify_config_data(XMLSpecHelper::XML_STATIC_CONFIG,"XMLConnection","ArtifactType","Fred","replace","ArtifactType")
    expect { xml_connect(fred_artifact_config) }.to raise_error(/Unsupported ArtifactType/)
  end
  
  it "should determine file name " do
    @xml_connection = xml_connect(XMLSpecHelper::XML_STATIC_CONFIG)
    
  end
  
  
end