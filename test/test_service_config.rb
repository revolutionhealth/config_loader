require File.join(File.dirname(__FILE__), 'test_helper')
require 'yaml'

class TestServiceConfig < Test::Unit::TestCase
  
  def test_service_config
    service_yaml = YAML::load_file(File.join(File.dirname(__FILE__), 'config', 'service.yml'))
    service_yaml['test']['search'].each do |k, v|
      real_key = case k 
                 when 'url'
                   'endpoint'
                 when 'timeout'
                   'config_timeout'
                 else 
                   k
                 end
      assert_equal v, ServiceConfig.send(real_key.to_sym, 'search')
    end
  end

end