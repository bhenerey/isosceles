class CreateSensuStashes < ActiveRecord::Migration
  def change
    create_table :sensu_stashes do |t|
      t.belongs_to  :node
      t.text  :path
      t.integer :stash_timestamp
      t.text  :expire
      t.text  :reason
      t.text  :full_content
      t.text  :silence_path
      t.text  :client_silence_path
      t.timestamps
    end
  end
end
