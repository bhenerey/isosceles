class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :ec2_id
      t.string :ec2_name
      t.string :ec2_private_ip
      t.index  :ec2_private_ip
      t.string :ec2_availability_zone
      t.string :ec2_state
      t.string :chef_env
      t.string :chef_apps
      t.string :chef_runlist
      t.string :sensu_client_name
      t.string :sensu_subscriptions
      t.text :sensu_checks
      t.integer :events_count, :default => 0
      t.integer :sensu_events_count, :default => 0
      t.integer :sensu_stashes_count, :default => 0
      t.timestamps
    end


    create_table :events do |t|
      t.belongs_to :node
      t.datetime :event_date
      t.text :event_message
      t.integer :event_status
      t.timestamps 
    end
  end

end
