require 'rubygems'
require 'rubeus'
Rubeus::Jdbc.depend_on("DriverManager")

require "activesupport"
require "rails_generator/base"
require 'pathname'

class JdbcMigrationGenerator < Rails::Generator::Base
  DEFAULT_CONFIG_FILE = 'jdbc_migration_config.rb'
  
  def initialize(runtime_args, runtime_options = {})
    super
    @jdbc_config_path = options[:config] || "config/#{DEFAULT_CONFIG_FILE}"
  end
  
  def manifest
    record do |m|
      if options[:generate_config]
        generate_config(m)
      else
        begin
          require_jdbc_migration
          require(@jdbc_config_path)
        rescue Exception => e
          puts e.to_s
          puts e.backtrace.join("\n  ")
          raise e
        end
        JdbcMigration.process(m)
      end      
    end
  end
  
  private
  def require_jdbc_migration
    $LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
    $LOAD_PATH.unshift(Pathname.new('./lib').realpath.to_s)
    begin
      require 'jdbc_migration'
    rescue => e
      puts e.to_s
      puts e.backtrace.join("\n  ")
      raise e
    end
  end
  
  def generate_config(m)
    m.template('jdbc_migration.rb', @jdbc_config_path)
  end
  
  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} jdbc_migration types [Options]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on('-C', "--config=path/to/#{DEFAULT_CONFIG_FILE}",
             "set configuration file to migrate") { |v| options[:config] = v }
      opt.on("--generate-config",
             "generate config/jdbc_migration_config.rb ") { |v| options[:generate_config] = true }
    end
end
