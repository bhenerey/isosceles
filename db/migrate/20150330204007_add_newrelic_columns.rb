class AddNewrelicColumns < ActiveRecord::Migration
  def change
    add_column :nodes, :newrelic_id, :integer
    add_column :nodes, :newrelic_name, :text
    add_column :nodes, :newrelic_host, :text
    add_column :nodes, :newrelic_health_status, :text
    add_column :nodes, :newrelic_last_reported_at, :text
  end
end
