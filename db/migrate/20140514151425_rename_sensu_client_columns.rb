class RenameSensuClientColumns < ActiveRecord::Migration
  def change
    rename_column :nodes, :sensu_subscriptions, :sensu_client_subscriptions
    add_column :nodes, :sensu_client_address, :text
  end
end
