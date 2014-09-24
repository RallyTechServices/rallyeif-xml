require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/xml_spec_helper'

include XMLSpecHelper
include YetiTestUtils

describe "When writing out data" do
  before(:each) do
    @xml_connection = xml_connect(XMLSpecHelper::XML_STATIC_CONFIG)
  end
  
  after(:each) do
    # clean up (directory created on each connect()
    FileUtils.remove_dir('./output_dir')
  end
  
  it "should turn a work item into XML" do
    item = RallyEIF::WRK::OrderedHash.new()
    item["Name"] = "My Name"
    @xml_connection.item_to_xml(item).should == 
    "  <defect>\n    <Name>My Name</Name>\n  </defect>\n"
  end
  
  it "should turn a work item with several keys into XML" do
    item = RallyEIF::WRK::OrderedHash.new()
    item["Name"] = "My Name"
    item["FormattedID"] = "DE37"

    @xml_connection.item_to_xml(item).should == 
    "  <defect>\n    <Name>My Name</Name>\n    <FormattedID>DE37</FormattedID>\n  </defect>\n"
  end

  
  it "should save a single defect into the file" do
    # int_work_item (from the runner (massaged from Rally through mapping)) is an OrderedHash
    item = RallyEIF::WRK::OrderedHash.new()
    item["Name"] = "My Name"
    item["FormattedID"] = "DE37"
    @xml_connection.create_internal(item)
    
    item["Name"] = "My Name 2"
    item["FormattedID"] = "DE38"
    @xml_connection.create_internal(item)

    File.file?(@xml_connection.path_to_output_file).should be_true

    file = File.open(@xml_connection.path_to_output_file,"rb")
    file.read.should == "<items>\n  <defect>\n    <Name>My Name</Name>\n    <FormattedID>DE37</FormattedID>\n  </defect>\n" +
      "  <defect>\n    <Name>My Name 2</Name>\n    <FormattedID>DE38</FormattedID>\n  </defect>\n</items>\n"
  end

  it "should save multiple defects into the same file" do
    item = RallyEIF::WRK::OrderedHash.new()
    item["Name"] = "My Name"
    item["FormattedID"] = "DE37"

    @xml_connection.create_internal(item)
    File.file?(@xml_connection.path_to_output_file).should be_true

    file = File.open(@xml_connection.path_to_output_file,"rb")
    file.read.should == "<items>\n  <defect>\n    <Name>My Name</Name>\n    <FormattedID>DE37</FormattedID>\n  </defect>\n</items>\n"
   
  end
  
  it "should format reference fields properly" do
    # TODO: create a reference field handler (needs tests, too)
  end
  
  it "should handle duplicates properly" do
    # TODO: create a duplicates field handler (needs tests, too)
  end
end