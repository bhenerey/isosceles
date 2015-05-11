class CreateSensuChecks < ActiveRecord::Migration
  def change
    create_table :sensu_checks do |t|
      t.belongs_to  :node
      t.text  :name
      t.integer  :interval
      t.boolean  :standalone
      t.text  :timeout
      t.text  :handlers
      t.text  :subscribers
      t.text  :command
      t.text  :check_type
      t.timestamps
    end
    add_column :nodes, :sensu_checks_count, :integer
  end
end
