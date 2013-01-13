class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.integer :server_id
      t.string :protocol
      t.string :version
      t.boolean :enabled

      t.timestamps
    end
  end
end
