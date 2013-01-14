class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :name, null: false
      t.integer :team_id, null: false

      t.timestamps
    end
  end
end
