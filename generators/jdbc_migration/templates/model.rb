class <%= table.dest_name.classify %> < ActiveRecord::Base
<% table.imported_keys.each do |imported_key| -%>
<%= "  # original foreign_keys was  #{imported_key.fkcolumns.map{|c| c.dest_name}.join(', ').inspect}\n" if imported_key.fkcolumns.length > 1 -%>
  belongs_to :<%= imported_key.belongs_to_name %>, :foreign_key => '<%= imported_key.rails_fk %>', :class_name => '<%= imported_key.pktable.dest_name.classify %>'
<% end -%>
end
