# Configuration Files Loader can be used as a gem or a Rails plugin to load config files.
# 
# It finds config file fragments in a rails config directory and in config directories of plugins and dependent gems.
# It then tries to merge them in order gem<-plugin<-application thus allowing overrides of global (gem/plugin) configs by individual applications.
# The supported types for merging are String, Hash, and Array.
# 
# It caches the content of files by default. 
# 
# ConfigurationLoader is RoR environment aware and provides a short-cut 'load_section' to load a section of a config file corresponding to RAILS_ENV.
# It is being used in another method provided by ConfigurationLoader - load_db_config.
# It loads a section from 'config/database.yml' providing a convenience method for getting secondary DB entries in a code like this:
# 
# establish_connection config_loader.load_db_config['secondary_db']
#  
# See the 'DRYing Up Configuration Files' post in our team blog http://revolutiononrails.blogspot.com/2007/03/drying-up-configuration-files.html
# for additional details.
#
#
# == Usage
#
# In your environment.rb
#   config.gem 'revolutionhealth-config_loader', :lib => 'config_loader, :source => 'http://gems.github.com'
# 
# Examples
#   Gets the RAILS_ENV section from database.yml
#   ConfigLoader.load_db_config                 
#
#   Loads a YAML-processed config file
#   ConfigLoader.load_file('cfg.yml')
# 
#   Loads a ERB+YAML-processed config file
#   ConfigLoader.load_dynamic_file('cfg.yml')
# 
#   Loads a current RAILS_ENV section from a YAML-processed config file
#   ConfigLoader.load_section('cfg.yml')
# 
#   Loads a 'test' section from a ERB+YAML-processed config file
#   ConfigLoader.load_dynamic_section('cfg.yml', 'test')
#

require 'yaml'
require 'pp'
require 'erb'
require File.join(File.dirname(__FILE__), 'service_config')

class ConfigurationLoader
  
  def initialize(cache_option = :force_cache)
    @caching = (cache_option == :force_cache)
  end
  
  def load_file(file, use_env = false)
    merge(load_assembled_file(file, use_env))
  end
  
  def load_dynamic_file(file, use_env = false)
    merge(load_assembled_dynamic_file(file, use_env))
  end
    
  def load_assembled_file(file, use_env = false)
    cache[key(file, use_env)] ||= yaml_load_file(file, use_env)
  end
  
  def load_assembled_dynamic_file(file, use_env = false)
	  cache[key(file, use_env)] ||= yaml_load_file(file, use_env, :erb)
  end
    
  def load_section(file, section = default_section, follow_links = false)
    loaded = load_assembled_file(file)
    section(loaded, section, follow_links)
  end
  
  def load_dynamic_section(file, section = default_section, follow_links = false)
    loaded = load_assembled_dynamic_file(file)
    section(loaded, section, follow_links)
  end
  
  def load_raw_file(file)
	  cache[key(file, false)] ||= yaml_load_file(file, false, :raw).last
  end

  def load_service_config
    begin
      load_dynamic_section('service.yml')
    rescue => ex
      puts "Warning: no or broken service.yml detected for this project - #{ ex }"
      {}
    end
  end

  def load_db_config(section = default_section)
    load_section('database.yml', section)
  end

private

  def section(loaded_configs, section, follow_links)
    loaded_configs.empty? ? nil : merge(collect_sections(loaded_configs, section, follow_links))
  end
  
  def collect_sections(loaded_configs, section, follow_links)
    loaded_configs.inject([]) do |combined_section, config|    
      s = select_section(config, section, follow_links)
      combined_section << s if s
      combined_section
    end
  end

  def select_section(loaded_config, section, follow_links)
    
    section = loaded_config[section]
    if follow_links
      seen_sections = [ ]
      while section.class == String
        if seen_sections.include? section
          raise ArgumentError("Circular references in config file")
        end
        seen_sections << section
        section = loaded_config[section]
      end
    end
    section

  end
    
  def default_section
    rails_env
  end
  
  def rails_env
    RAILS_ENV || 'development'
  end
  
  def file_path(path, file, use_env)
    to_load = use_env ? "environments/#{ rails_env }-#{ file }" : file
    File.join(path, to_load)
  end
  
  def cache
    if cache? 
      if loaded_file_changed?
        @@cached = nil
        loaded_files.clear
      end 
      (@@cached ||= {})
    else 
      {}
    end
  end
  
  def key(file, env)
    "#{ file }_#{ env }"
  end
  
  def loaded_files
    (@@loaded_files ||= {})
  end
    
  # frequency in secs to reload config files
  RELOAD_FREQ_SECS = 10
  
  def loaded_file_changed?
    result = false
    now = Time.now
    # check every 10 sec
    if (now > ((@@last_file_changed_check ||= now) + RELOAD_FREQ_SECS))
      loaded_files.each do |file, time|
        if (File.stat(file).mtime <=> time) != 0
          result = true
          break
        end
      end
      @@last_file_changed_check = now
    end
    result
  end

  def configs
    cache[:configs] ||= begin 
      (load_pathes("/gems/") + load_pathes("vendor/plugins/") + app_root).uniq.inject([]) do |configs, path|
        puts "Component: #{ path }" if ENV['CONFIG_LOADER_DEBUG']      
        config = File.join(path, 'config')
        configs << config if File.exist?(config)
        configs
      end
    end 
  end

  def app_root
    [ File.expand_path(RAILS_ROOT) ]
  end
  
  def load_pathes(pattern)
    $:.grep(%r{#{ pattern }}).collect { |path| File.expand_path(path[%r{.*#{ pattern }[^/]+}]) }
  end

  def yaml_load_file(file_name, use_env, file_type = :none)    
    configs.inject([]) do |loaded, config_path|
      file = file_path(config_path, file_name, use_env)
      puts "Probing #{ file }" if ENV['CONFIG_LOADER_DEBUG']
      if File.exist?(file)
        f = file_loader(file, file_type)
        res = (file_type == :raw) ? f : YAML.load(f)
        loaded << res
      end
      loaded
    end
  end
  
  def file_loader(file, file_type)
    loaded_files[file.to_s] = File.stat(file).mtime
    case file_type
      when :erb then ERB.new(IO.read(file)).result
      else IO.read(file)
    end
  end

  def cache?
    @caching
  end
  
  def merge(values)
    
    if ENV['CONFIG_LOADER_DEBUG']
      puts "Merging configs: "
      pp values
    end
      
    case
      when all_are?(values, Hash) then
        values.inject({}) { |c, v| c.merge(v) }
      when all_are?(values, Array) then
        values.inject([]) { |c, v| c + v }
      else
        values.last
    end
    
  end
  
  def all_are?(values, type)
    values.all? { |v| v.is_a?(type) }
  end

end

::ConfigLoader = ConfigurationLoader.new unless defined?(ConfigLoader)