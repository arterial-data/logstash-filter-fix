Gem::Specification.new do |s|
  s.name = 'logstash-filter-fix'
  s.version         = '0.0.1'
  s.licenses = ['Apache License (2.0)']
  s.summary = "This example filter replaces the contents of the message field with the specified value."
  s.description = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.authors = ["Mountain Pass"]
  s.email = 'info@mountain-pass.com.au'
  s.homepage = "https://github.com/mountain-pass/logstash-filter-fix"
  s.require_paths = ["lib"]
  s.platform = 'java'

  # Files
  s.files = `git ls-files`.split($\)
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", '>= 1.4.0', '< 2.0.0'
  s.add_runtime_dependency "quickfix-jruby", '1.6.0'
  s.add_runtime_dependency 'xml-simple'
  s.add_runtime_dependency 'nokogiri'
  s.add_runtime_dependency 'nori'
  s.add_development_dependency 'logstash-devutils'

  # Jar dependencies
  #s.requirements << "jar 'quickfixj:quickfixj-all', '1.5.3'"
  #s.add_runtime_dependency 'jar-dependencies'
end
