class AddNewrelicReporting < ActiveRecord::Migration
  def change
    add_column :nodes, :newrelic_reporting, :boolean
  end
end
