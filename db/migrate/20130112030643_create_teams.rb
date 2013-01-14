class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :alias, null: false
      t.string :name, null: false
      t.string :color, null: false

      t.timestamps
    end
  end
end
