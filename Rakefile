require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'

GEM = "config_loader"
GEM_VERSION = "2.0." + `git rev-parse --short HEAD`.to_s.hex.to_s
AUTHOR = "Revolution Health"
EMAIL = "rails-trunk@revolutionhealth.com"
HOMEPAGE = %q{http://github.com/revolutionhealth/config_loader}
SUMMARY = "Provides convenience methods for the loading of configuration files"
DESCRIPTION = "Abstracts out the loading of common configuration files such as database.yml dependent on the Rails environment"

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.date = Time.now.strftime("%Y-%m-%d")
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["Manifest.txt", "README"]
  s.rdoc_options = ["--main", "README"]
  
  s.summary = SUMMARY
  s.description = DESCRIPTION
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  
  # Uncomment this to add a dependency
  # s.add_dependency "foo"
  
  s.require_path = 'lib'
  s.autorequire = GEM
  s.files = %w(Manifest.txt LICENSE README TODO Rakefile) + Dir.glob("{lib,test}/**/*")
  s.test_files = Dir.glob('test/**/test_*.rb') - ['test/test_helper.rb']
end



Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

require 'rake/testtask'
require 'test/unit'

Rake::TestTask.new() do |t|
  t.libs << 'test'
  t.pattern = 'test/**/test_*.rb'
  t.warning = true
  t.verbose = true
end

task :default => [:test, :package] do
end
