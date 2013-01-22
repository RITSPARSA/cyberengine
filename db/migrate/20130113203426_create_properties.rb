class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.integer :team_id, null: false
      t.integer :server_id, null: false
      t.integer :service_id, null: false
      t.string :category, null: false
      t.string :property, null: false
      t.text :value, null: false

      t.timestamps
    end
  end
end
