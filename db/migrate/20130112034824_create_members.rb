class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :username
      t.string :password_digest
      t.integer :team_id

      t.timestamps
    end
  end
end
