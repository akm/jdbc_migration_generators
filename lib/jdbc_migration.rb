module JdbcMigration

  class << self
    def configs
      @configs ||= []
    end
    
    def config(jdbc_url, options = nil)
      config = Config.new(jdbc_url, options)
      yield(config) if block_given?
      configs << config
      config
    end
    
    def process(manifest)
      configs.each do |config|
        migration = Base.new(manifest, config)
        migration.process
      end
    end
  end
  
  autoload :Config, 'jdbc_migration/config'
  autoload :Base, 'jdbc_migration/base'
  autoload :RubeusExtension, 'jdbc_migration/rubeus_extension'
end
