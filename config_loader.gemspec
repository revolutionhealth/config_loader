Gem::Specification.new do |s|
  s.name = "config_loader"
  s.version = "2.0.0"
  s.date = "2008-06-20"
  s.summary = "Provides convenience methods for the loading of configuration files"
  s.email = "rails@revolutionhealth.com"
  s.homepage = "http://github.com/revolutionhealth/config_loader"
  s.description = "Abstracts out the loading of common configuration files such as database.yml dependent on the Rails environment"
  s.has_rdoc = true
  s.authors = ["Revolution Health"]
  s.files = %w(Manifest.txt LICENSE README TODO Rakefile) + Dir.glob("{lib,test}/**/*")
  s.test_files = Dir.glob('test/**/test_*.rb') - ['test/test_helper.rb']
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["Manifest.txt", "README"]
end
