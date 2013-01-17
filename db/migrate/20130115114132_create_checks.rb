class CreateChecks < ActiveRecord::Migration
  def change
    create_table :checks do |t|
      t.integer :service_id, null: false
      t.boolean :passed, null: false
      t.text :request, null: false
      t.text :response, null: false

      t.timestamps
    end
  end
end
