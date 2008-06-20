require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'lib', 'config_loader')

unless defined?(RAILS_ENV)
  RAILS_ROOT = File.dirname(__FILE__) 
  RAILS_ENV  = 'test'
end