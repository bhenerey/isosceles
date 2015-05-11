class AddSensuTimestamp < ActiveRecord::Migration
  def change
    add_column :nodes, :sensu_timestamp, :integer
  end
end
