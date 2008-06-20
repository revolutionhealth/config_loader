require 'logger'

module ServiceConfig
  extend self

  ConfigLogger = defined?(RAILS_DEFAULT_LOGGER) ? RAILS_DEFAULT_LOGGER : Logger.new(STDOUT)
      
  def endpoint(service)
	  begin
      cfg[service.to_s]['url']
		rescue
			nil
		end
  end
  
  def config_timeout(service)
	  begin
      cfg[service.to_s]['timeout']
		rescue
		  log_not_found service
			ConfigLogger.error "Configuring a default timeout of 5 seconds."
			5
		end
  end
  
  def is_mocked?(service)
    begin
      cfg[service.to_s][:mocked.to_s]
    rescue
      log_not_found service
      false
    end
  end

  def is_service_backed?(service)
    begin
      cfg[service.to_s][:service_backed.to_s]
    rescue
      log_not_found service
      false
    end
  end

  def mocked(service)
    cfg[service.to_s][:mocked.to_s]
  end
  
  def service_backed(service)
    cfg[service.to_s][:service_backed.to_s]
  end
  
  def login
    cfg[:service_creds.to_s][:login.to_s]
  end
  
  def host(service)
	  begin
      cfg[service.to_s]['host']
		rescue
		  log_not_found service
			nil
		end
  end

  def path(service)
	  begin
      cfg[service.to_s]['path']
		rescue
		  log_not_found service
			nil
		end
  end

  def port(service)
	  begin
      cfg[service.to_s]['port']
		rescue
		  log_not_found service
			nil
		end
  end

  def service_params(service)
    cfg[service.to_s]
  end

  def sp_entity_value(service)
    find_target(service, 'sp_entity_value')
  end
  
  def sp_target_value(service)
    find_target(service, 'sp_target_value')
  end

  def find_target(service, name)
    begin
      cfg[service.to_s][name]
    rescue
      log_not_found "service: #{service.to_s}, attr: #{name}"
      nil
    end
  end

  def ends_with_slash(url)
    (url[-1,1] == '/') ? url : url + '/'
  end

private

  def log_not_found(service)
    ConfigLogger.error "Could not load endpoint configuration for #{service.to_s}"
  end
  
  def cfg
    ConfigLoader.load_service_config
  end

end
