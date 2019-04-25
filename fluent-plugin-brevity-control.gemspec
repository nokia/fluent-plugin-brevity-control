# -*- mode:ruby -*-

Gem::Specification.new do |gem|

  gem.summary       = "brevity control"
  gem.authors       = ["csf clog"]
  gem.files         = "lib/fluent/plugin/filter_brevity_control.rb"
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "fluent-plugin-brevity-control"
  gem.require_paths = ["lib"]
  gem.version       = "0.0.2"

  gem.add_runtime_dependency "fluentd", [">= 0.14.8", "< 2"]
  gem.add_development_dependency "rake", ">= 0.9.2"
  gem.add_development_dependency "test-unit", ">= 3.0"
end
