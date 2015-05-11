class AddIsoClientIpColumn < ActiveRecord::Migration
  def change
    add_column :nodes, :iso_client_ip, :text
  end
end
