require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/xml_spec_helper'

include XMLSpecHelper
include YetiTestUtils

describe "Given " do
  before(:each) do
    @xml_connection = xml_connect(XMLSpecHelper::XML_STATIC_CONFIG)
  end
  
  it "should save a single defect into the file" do
    # do create_internal(int_work_item)
    # int_work_item is an OrderedHash
  end

  it "should save multiple defects into the same file" do
    
  end
  
  it "should format reference fields properly" do
    
  end
end