$LOAD_PATH << File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
require 'rallyeif/xml/version'

Gem::Specification.new do |spec|
  spec.name          = "rallyeif-xml"
  spec.version       = RallyEIF::XML::Version
  spec.authors       = ["Rally Software Development Corp"]
  spec.email         = ["support@rallydev.com"]
  spec.description   = %q{XML Spoke for EIF connectors}
  spec.summary       = %q{XML spoke for use with Hub of EIF}
  spec.homepage      = "https://github.com/RallyTechServices/rallyeif-xml"
  spec.license       = "MIT"

  all_files          = `git ls-files`.split($/)
  spec.executables   = all_files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.files         = []
  exclusions         = %w(spec test features coverage pkg .gitignore Rakefile)
  spec.files         = all_files.reject{|fn| fn =~ /^(#{exclusions.join("|")})/}
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rallyeif-wrk",     "= 0.5.2"
  spec.add_runtime_dependency "xml-simple",       "= 1.1.2"
  spec.add_runtime_dependency "mime-types",       "= 2.0"

  spec.add_development_dependency "bundler",      "= 1.5.1"
  spec.add_development_dependency "rake",         "= 10.1.0"
  spec.add_development_dependency "rspec",        "= 3.1.0"
  spec.add_development_dependency "simplecov",    "= 0.7.1"
  spec.add_development_dependency "ci_reporter",  "= 1.9.0"
  spec.add_development_dependency "geminabox",    "= 0.10.7"
  spec.add_development_dependency "ambient_spec",    ">= 0.13.2"

end
