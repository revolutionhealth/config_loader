require File.join(File.dirname(__FILE__), 'test_helper')

class ConfigurationLoader
  alias :file_loader_old :file_loader
  
  def reset_loader_called
    @@loader_called = false
  end
  
  def loader_called
    (@@loader_called ||= false) 
  end
  
  def file_loader(file, file_type)
    @@loader_called = true
    file_loader_old(file, file_type)
  end
  
  def loaded_file_changed_checkonly?
    orig = @@last_file_changed_check if defined? @@last_file_changed_check
    changed = loaded_file_changed? 
    @@last_file_changed_check = orig
    changed
  end
end

class TestConfigReload < Test::Unit::TestCase
  
  def test_config_reload
    loaded = ConfigLoader.load_file('test_reload.yml')
    assert_not_nil loaded
    assert ConfigLoader.loader_called
    
    another_loaded = ConfigLoader.load_file('database.yml')
    assert_not_nil another_loaded
        
    # should be under threshold of timeout
    changed = false
    changed = ConfigLoader.loaded_file_changed_checkonly?
    assert !changed
    
    sleep 5
    ConfigLoader.reset_loader_called
    ## after sleeping it should not reload since the mtime is same

    changed = false
    changed = ConfigLoader.loaded_file_changed_checkonly?
    assert !changed


    not_reloaded = ConfigLoader.load_file('test_reload.yml')
    assert_equal loaded, not_reloaded

    assert !ConfigLoader.loader_called
    
    #try another file
    another_loaded = ConfigLoader.load_file('database.yml')
    assert_not_nil another_loaded
    assert !ConfigLoader.loader_called
    
    ## change the file
    new_adapter = 'oracle'
    orig_adapter = loaded['test']['adapter']
    loaded['test']['adapter'] = new_adapter

    
    test_reload_file = File.join(File.dirname(__FILE__), 'config', 'test_reload.yml')
    File.open(test_reload_file, 'w' ) do |out|
        YAML.dump(loaded, out )
    end
    
    sleep 5
    ConfigLoader.reset_loader_called
    
    changed = ConfigLoader.loaded_file_changed_checkonly?
    assert changed
    
    reloaded = ConfigLoader.load_file('test_reload.yml')
    assert ConfigLoader.loader_called
    assert_equal new_adapter, reloaded['test']['adapter']
    
    # should be under threshold of timeout
    changed = false
    changed = ConfigLoader.loaded_file_changed_checkonly?
    assert !changed
    
    #try another file
    another_loaded = ConfigLoader.load_file('database.yml')
    assert_not_nil another_loaded
    assert ConfigLoader.loader_called
    
    
    loaded['test']['adapter'] = orig_adapter    
    File.open( test_reload_file, 'w' ) do |out|
      YAML.dump(loaded, out )
    end
  end
  
  def test_check_only
    ConfigLoader.loaded_file_changed_checkonly?
    ConfigLoader.instance_eval { loaded_file_changed? }
    ConfigLoader.loaded_file_changed_checkonly?
  end
  
  def test_use_alternate_base_path
    Object.send(:remove_const, "RAILS_ROOT")
    assert_raise(RuntimeError) {
      ConfigurationLoader.new(false).send(:app_root)
    }
    top_dir = File.join(File.dirname(__FILE__), '..')
    conf = ConfigurationLoader.new(false, top_dir)
    assert conf.send(:app_root).first == File.expand_path(top_dir)
  end
  
end

