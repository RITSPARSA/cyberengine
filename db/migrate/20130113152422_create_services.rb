class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.integer :server_id,  null: false
      t.string :name,  null: false
      t.string :protocol,  null: false
      t.string :version,  null: false
      t.boolean :enabled,  null: false

      t.timestamps
    end
  end
end
