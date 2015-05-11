class AddChefBootstrappedCol < ActiveRecord::Migration
  def change
    add_column :nodes, :chef_bootstrapped, :string
  end
end
