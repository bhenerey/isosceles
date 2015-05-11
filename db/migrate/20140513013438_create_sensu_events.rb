class CreateSensuEvents < ActiveRecord::Migration
  def change
    create_table :sensu_events do |t|
      t.belongs_to  :node
      t.datetime  :date
      t.text  :output
      t.integer  :status, :limit => 1  
      t.text  :handlers
      t.integer  :occurrences
      t.text  :client
      t.text  :check
      t.text  :event_id
      t.text  :status_name 
      t.text  :url
      t.text  :client_silence_path
      t.text  :silence_path
      t.boolean  :client_silenced
      t.timestamps
    end
  end
end
