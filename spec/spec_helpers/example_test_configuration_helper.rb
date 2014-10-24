module TestConfig

  # MAKE YOUR OWN VERSION OF THIS and name it 
  # test_configuration_helper.rb
  #
  # DO NOT CHECK IT IN
  
  #
  #
  # rally connection information
  RALLY_SOURCE_USER       = "someone@somewhere.com"
  RALLY_SOURCE_USER_OID   = "123456"  #for slow testing of UserTransformer
  RALLY_SOURCE_PASSWORD   = "secret"
  RALLY_SOURCE_URL        = "demo01.rallydev.com"
  RALLY_SOURCE_WORKSPACE  = "Integrations"
  
  # rally configurable information for testing
  # choose a place where we can put lots and lots and lots of 
  # defects and stories.  You can always close these projects later
  RALLY_SOURCE_EXTERNAL_ID_FIELD  = "ExternalID"
  RALLY_SOURCE_PROJECT_1          = "Payment Team"
  RALLY_SOURCE_PROJECT_1_OID      = "723161" # Object ID of Project_1
  RALLY_SOURCE_PROJECT_2          = "Shopping Team"
  RALLY_SOURCE_WEBLINK_FIELD      = "IdeaURL"
  
  # rally projects in a hierarchical tree for hierarchy tests
  RALLY_SOURCE_PROJECT_HIERARCHICAL_PARENT      = "Online Store"
  RALLY_SOURCE_PROJECT_HIERARCHICAL_CHILD       = "Reseller Site"
  RALLY_SOURCE_PROJECT_HIERARCHICAL_GRANDCHILD  = "Reseller Portal Team"
  
end
