class AddChefClientColumns < ActiveRecord::Migration
  def change
    add_column :nodes, :chef_name, :string
    rename_column :nodes, :chef_env, :aws_tag_environment
    add_column :nodes, :chef_env, :string
    add_column :nodes, :chef_uptime, :string, default: "Unknown"
    add_column :nodes, :chef_version, :string, default: "Unknown"
    add_column :nodes, :chef_platform, :string, default: "Unknown"
    add_column :nodes, :chef_last_ohai, :integer, default: nil
  end
end
