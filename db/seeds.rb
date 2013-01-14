# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Whiteteam
whiteteam = Team.create(color: 'white', name: 'Whiteteam', alias: 'Whiteteam' )
whiteteam_member = Member.create(username: 'whiteteam', team_id: whiteteam.id, password: 'whiteteam', password_confirmation: 'whiteteam')

# Redteam
redteam = Team.create(color: 'red', name: 'Redteam', alias: 'Redteam' )

# Blueteam
