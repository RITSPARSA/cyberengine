class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :username, null: false
      t.string :password_digest, null: false
      t.integer :team_id, null: false

      t.timestamps
    end
  end
end
