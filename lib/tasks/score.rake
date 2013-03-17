namespace :cyberengine do
  task :score => :environment do 
    Rails.logger = Logger.new STDOUT
    Rails.logger.level = Logger::DEBUG
    result = Hash.new
    Team.blueteams.includes([services_for_scoring: :checks_for_scoring]).each do |team|
      result[team.id] = {checks: 0, passed: 0, percent: 0.0, points: 0, available: 0, alias: team.alias, services: Hash.new}
      team.services_for_scoring.each do |service|
        result[team.id][:services][service.id] = {checks: 0, passed: 0, percent: 0.0, points: 0, available: service.available_points, name: service.name, protocol: service.protocol, version: service.version}
        service.checks_for_scoring.each do |check|
          result[team.id][:checks] += 1
          result[team.id][:passed] += 1 if check.passed
          result[team.id][:services][service.id][:checks] += 1
          result[team.id][:services][service.id][:passed] += 1 if check.passed
        end
      end
    end
    # Calculate percent, available, and points
    result.each do |team_id,team|
      team[:percent] = team[:checks] == 0 ? 0 : (team[:passed].to_f/team[:checks].to_f)
      team[:available] = team[:services].map{|i,s| s[:available] }.sum.to_i
      team[:points] = (team[:available]*team[:percent]).to_i
      team[:percent] = (team[:percent]*100).round(1)
      team[:services].each do |service_id,service|
        service[:percent] = service[:checks] == 0 ? 0 : (service[:passed].to_f/service[:checks].to_f)
        service[:available] = service[:available].to_i
        service[:points] = (service[:available]*service[:percent]).to_i
        service[:percent] = (service[:percent]*100).round(1)
      end
    end
  end
end
