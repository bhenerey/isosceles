class AwsCreatedAt < ActiveRecord::Migration
  def change
    add_column :nodes, :aws_created_at, :text
  end
end
