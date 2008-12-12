module JdbcMigration

  module ClassMethods
    def define(sourcer_database, catalog, schema_pattern, table_name_pattern)
      jdbc_migration = Base.new
      yield(jdbc_migration)
    end
  end
  
  extend ClassMethods
  
  autoload :Base, 'jdbc_migration/base'
end
