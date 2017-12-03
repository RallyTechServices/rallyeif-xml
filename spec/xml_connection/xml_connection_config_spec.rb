require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/xml_spec_helper'

include XMLSpecHelper
include YetiTestUtils

describe "Given configuration in the XMLConnection section," do
  before(:all) do
    #
  end

  it "should successfully load basic config settings" do
    xml_connection = xml_connect(XMLSpecHelper::XML_STATIC_CONFIG)
    xml_connection.artifact_type.should == "Defect"
    xml_connection.path.should == "./output_dir"

    # remember to clean up!
    FileUtils.remove_dir('./output_dir')
  end

  it "should reject missing required fields" do
    expect { xml_connect(XMLSpecHelper::XML_MISSING_ARTIFACT_CONFIG) }.to raise_error
    expect { xml_connect(XMLSpecHelper::XML_MISSING_PATH_CONFIG) }.to raise_error
  end

  it "should reject invalid artifact types" do
    fred_artifact_config = YetiTestUtils::modify_config_data(XMLSpecHelper::XML_STATIC_CONFIG,"XMLConnection","ArtifactType","Fred","replace","ArtifactType")
    expect { xml_connect(fred_artifact_config) }.to raise_error(/Unsupported ArtifactType/)
  end

  it "should determine file name" do
    seconds_right_now = Time.new.to_i
    xml_connection = xml_connect(XMLSpecHelper::XML_STATIC_CONFIG)
    xml_connection.path_to_output_file.should == "./output_dir/#{seconds_right_now}.xml"
    # remember to clean up!
    FileUtils.remove_dir('./output_dir')
  end

  it "should force path to relative to local if seems to start at root" do
    modified_config = YetiTestUtils::modify_config_data(XMLSpecHelper::XML_STATIC_CONFIG,"XMLConnection","Path","/arnold","replace","Path")
    xml_connection = xml_connect(modified_config)

    xml_connection.path.should == "./arnold"
    # remember to clean up!
    FileUtils.rm_rf('./arnold')
  end

  it "should force path to relative to local if seems to start at root" do
    modified_config = YetiTestUtils::modify_config_data(XMLSpecHelper::XML_STATIC_CONFIG,"XMLConnection","Path","/arnold","replace","Path")
    xml_connection = xml_connect(modified_config)

    xml_connection.path.should == "./arnold"
    # remember to clean up!
    FileUtils.rm_rf('./arnold')
  end

  it "should create directory path if path does not exist" do
    test_dir = "./output_tests/test-#{Time.new.to_i}"
    modified_config = YetiTestUtils::modify_config_data(XMLSpecHelper::XML_STATIC_CONFIG,"XMLConnection","Path","#{test_dir}","replace","Path")

    xml_connection = xml_connect(modified_config)

    xml_connection.path.should == test_dir
    Dir.exists?(test_dir).should == (true)
    # remember to clean up!
    FileUtils.rm_rf("./#{test_dir}")
  end

  it "should create deep directory path if path does not exist" do
    test_dir = "./output_tests/child/grandchild/greatgrandchild/test-#{Time.new.to_i}"
    modified_config = YetiTestUtils::modify_config_data(XMLSpecHelper::XML_STATIC_CONFIG,"XMLConnection","Path","#{test_dir}","replace","Path")

    xml_connection = xml_connect(modified_config)

    xml_connection.path.should == test_dir
    Dir.exists?(test_dir).should == (true)
    # remember to clean up!
    FileUtils.remove_dir("./output_tests")
  end

  it "should raise exception if file given instead of directory" do
    test_dir = "./test-#{Time.new.to_i}.xml"
    modified_config = YetiTestUtils::modify_config_data(XMLSpecHelper::XML_STATIC_CONFIG,"XMLConnection","Path","#{test_dir}","replace","Path")

    FileUtils.touch(test_dir)
    expect { xml_connection = xml_connect(modified_config) }.to raise_error(/Path must be a directory, not a file/)

    # remember to clean up!
    File.delete(test_dir)
  end

end
