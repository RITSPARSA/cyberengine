namespace :cyberengine do
  task :redteam => :environment do
    team = Team.create(color: 'Red', name: 'Redteam', alias: 'Redteam' )
    member = Member.create(team_id: team.id, username: 'redteam', password: 'redteam', password_confirmation: 'redteam')
    puts "Created: #{team.alias} - Login: #{member.username}:#{member.password}"
  end
end
