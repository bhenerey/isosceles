class ChangeChefColumns < ActiveRecord::Migration
  def change
    rename_column :nodes, :chef_apps, :aws_tag_apps
  end
end
