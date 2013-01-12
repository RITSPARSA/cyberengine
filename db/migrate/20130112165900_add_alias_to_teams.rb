class AddAliasToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :alias, :string
  end
end
