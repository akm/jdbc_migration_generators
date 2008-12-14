class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table.dest_name %> do |t|
<% table.columns.each do |column| -%>
<%   next if column.dest_name.nil? -%>
      t.<%= column.dest_type.to_s %> :<%= column.dest_name %>
<% end -%>
<% table.imported_keys.each do |imported_key| -%>
<%   next if imported_key.fkcolumn_names.length < 2 -%>
      t.integer :<%= imported_key.rails_fk %>
<% end -%>
<% unless options[:append_timestamps] %>
      t.timestamps
<% end -%>
    end
  end

  def self.down
    drop_table :<%= table.dest_name %>
  end
end
