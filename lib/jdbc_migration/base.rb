module JdbcMigration
  class Base
    attr_accessor :config
    attr_reader :manifest
    
    def initialize(manifest, config)
      @manifest = manifest
      @config = config
    end
    
    attr_reader :meta_data
    attr_reader :tables
    
    def process
      config.connect_db do |connection|
        @connection = connection
        @meta_data = connection.meta_data
        @meta_data.extend(JdbcMigration::RubeusExtension)
        @meta_data.migrator = self
        begin
          @tables = @meta_data.table_objects(
            :catalog => config.catalog, 
            :schema_pattern => config.schema_pattern, 
            :table_name_pattern => config.table_name_pattern,
            :name_case => :downcase)
          
          @tables.each{|t| t.setup_cached_access}
          config.invoke_processors(self)
        rescue => e
          puts e.to_s
          puts e.backtrace.join("\n  ")
          raise e
        ensure
          @meta_data = nil
        end
      end
      self
    end
    
    def generate_schema_migrations
      each_tables{|t| generate_schema_migration(t)}
    end
    
    def generate_data_migrations
      each_tables{|t| generate_data_migration(t)}
    end
    
    def generate_models
      each_tables{|t| generate_model(t)}
    end
    
    def generate_schema_migration(table)
      @manifest.migration_template('schema_migration.rb', 'db/migrate', 
        :migration_file_name => "create_#{table.dest_name.gsub(/\//, '_').pluralize}", 
        :assigns => {
          :table => table,
          :migration_name => "Create#{table.dest_name.classify.pluralize.gsub(/::/, '')}"
        })
    end
    
    def generate_data_migration(table)
      puts "generate_data_migration for #{table.name}"
    end
    
    def generate_model(table)
      @manifest.template('model.rb', 
        File.join('app/models', "#{table.dest_name.classify.underscore}.rb"),
        :assigns => {
          :connection => @connection,
          :table => table
        })
    end
    
    def each_tables(&block)
      tables.select{|t| t.dest_name}.each(&block)
    end
    
    def dest_table_name(table_name)
      config.table_patterns.each do |src, dest| 
        return dest if src == table_name
      end
      nil
    end
    
    def dest_column_name(column_name)
      config.column_patterns.each do |src, dest| 
        return dest if src == column_name
      end
      column_name
    end
    
    def dest_column_type(type_name)
      JDBC_TYPE_TO_RAILS_TYPE[type_name.to_s.upcase] || :unknown
    end

    JDBC_TYPE_TO_RAILS_TYPE = {
      # "ARRAY" => :unknown,
      "BIGINT" => :integer,
      "BINARY" => :binary,
      "BIT" => :boolean,
      "BLOB" => :binary,
      "BOOLEAN" => :boolean,
      "CHAR" => :string,
      "CLOB" => :text,
      # "DATALINK" => :unknown,
      "DATE" => :date,
      "DECIMAL" => :decimal,
      # "DISTINCT" => :unknown,
      "DOUBLE" => :float,
      # "Deprecated" => :unknown,
      "FLOAT" => :float,
      "INTEGER" => :integer,
      # "JAVA_OBJECT" => :unknown,
      # "JavaSignal" => :unknown,
      "LONGNVARCHAR" => :text,
      "LONGVARBINARY" => :binary,
      "LONGVARCHAR" => :text,
      "NCHAR" => :string,
      "NCLOB" => :text,
      # "NULL" => :unknown,
      "NUMERIC" => :float,
      "NVARCHAR" => :string,
      # "OTHER" => :unknown,
      "REAL" => :float,
      # "REF" => :unknown,
      "ROWID" => :integer,
      # "SIGNALS" => :unknown,
      "SMALLINT" => :integer,
      # "SQLXML" => :unknown,
      # "STRUCT" => :unknown,
      "TIME" => :time,
      "TIMESTAMP" => :timestamp,
      "TINYINT" => :integer,
      "VARBINARY" => :binary,
      "VARCHAR" => :string
    }
  end

end
