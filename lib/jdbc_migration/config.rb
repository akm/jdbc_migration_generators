require "rubeus"
module JdbcMigration
  class Config
    attr_accessor :jdbc_url, :username, :password
    attr_accessor :catalog, :schema_pattern, :table_name_pattern
    
    def initialize(jdbc_url, options = nil)
      @jdbc_url = jdbc_url
      options = { 
        :username => nil,
        :password => nil,
        :catalog => nil,
        :schema => nil,
        :schema_pattern => nil,
        :table => nil,
        :table_name => nil,
        :table_name_pattern => nil
      }.update(options || {})
      @username = options[:username]
      @password = options[:password]
      @catalog = options[:catalog] 
      @schema_pattern = options[:schema_pattern] || options[:schema]
      @table_name_pattern = options[:table_name_pattern] || options[:table_name] || options[:table]
    end
    
    def table_patterns(patterns = nil)
      @table_patterns ||= {}
      @table_patterns.update(patterns) if patterns
      @table_patterns
    end
    
    def column_patterns(patterns = nil)
      @column_patterns ||= {}
      @column_patterns.update(patterns) if patterns
      @column_patterns
    end
    
    def process(*args, &block)
      @processors ||= []
      @processors += args
      @processors << Proc.new(&block) if block_given?
      nil
    end
    
    def connect_db(&block)
      Rubeus::Jdbc::DriverManager.connect(jdbc_url, username, password, &block)
    end
    
    def invoke_processors(migrator)
      @processors ||= []
      @processors.each do |processor|
        if processor.is_a?(Symbol)
          migrator.send(processor)
        elsif processor.respond_to?(:call)
          processor.call(migrator)
        else
          raise ArgumentError, "Unsupported processor: #{processor.inspect}"
        end
      end
    end
  end
end
