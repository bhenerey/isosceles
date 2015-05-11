class AddXen < ActiveRecord::Migration
  def change
    add_column :nodes, :xen_name, :text
    add_column :nodes, :xen_power_state, :text
    add_column :nodes, :xen_last_shutdown_time, :text
  end
end
