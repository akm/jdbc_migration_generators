# require "rubeus"
module JdbcMigration
  module RubeusExtension
    attr_accessor :migrator
  end
end

module Rubeus::Jdbc
  class Table < MetaElement
    def dest_name
      meta_data.migrator.dest_table_name(name)
    end
    
    def setup_cached_access
      primary_keys
      indexes
      [imported_keys, exported_keys].each do |keys|
        keys.each do |key|
          key.rails_fk
          key.belongs_to_name
        end
      end
    end
  end
  
  class Column < TableElement
    def dest_name
      meta_data.migrator.dest_column_name(name)
    end
    
    def dest_type
      meta_data.migrator.dest_column_type(type_name)
    end
  end
  
  class ForeignKey < TableElement
    def single_reference_to_pk?
      fktable.imported_keys.select{|imported_key| imported_key.pktable == pktable}.length > 1
    end
    
    def setup_belongs_to
      if fkcolumn_names.length == 1
        column_name = fkcolumns.first.dest_name.downcase
        if /\_id$/ =~ column_name
          @rails_fk = column_name
          @belongs_to_name = @rails_fk.gsub(/\_id$/, '')
          return
        end
      end
      if single_reference_to_pk?
        base_name = pkcolumns.map{|col|col.dest_name}.join('_')
        @rails_fk = "#{base_name}_id"
        @belongs_to_name = pk_name || "obj_by_#{base_name}"
      else
        @belongs_to_name = pktable.name.underscore
        @rails_fk = "#{@belongs_to_name}_id"
      end
    end
    
    def belongs_to_name
      setup_belongs_to unless @belongs_to_name
      @belongs_to_name
    end
    
    def rails_fk
      setup_belongs_to unless @rails_fk
      @rails_fk
    end
  end
end
