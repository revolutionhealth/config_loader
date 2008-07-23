Gem::Specification.new do |s|
  s.name = %q{config_loader}
  s.version = "2.0.40655071"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Revolution Health"]
  s.autorequire = %q{config_loader}
  s.date = %q{2008-07-23}
  s.description = %q{Abstracts out the loading of common configuration files such as database.yml dependent on the Rails environment}
  s.email = %q{rails-trunk@revolutionhealth.com}
  s.extra_rdoc_files = ["Manifest.txt", "README"]
  s.files = ["Manifest.txt", "LICENSE", "README", "TODO", "Rakefile", "lib/config_loader.rb", "lib/service_config.rb", "test/config", "test/config/database.yml", "test/config/service.yml", "test/config/test_reload.yml", "test/test_config_reload.rb", "test/test_helper.rb", "test/test_service_config.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/revolutionhealth/config_loader}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Provides convenience methods for the loading of configuration files}
  s.test_files = ["test/test_config_reload.rb", "test/test_service_config.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
    else
    end
  else
  end
end
