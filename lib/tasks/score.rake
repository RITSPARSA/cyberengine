task :score => :environment do
  response = Hash.new
  response[:services] = Hash.new
  response[:services][:versions] = Hash.new
  response[:services][:protocols] = Array.new
  Service.select(:version).uniq.each do |service|
    version = service.version
    response[:versions][version] = Hash.new
    response[version]
    Service.select(:protocol).where("version = ?",version).uniq.each do |service|
      protocol = service.protocol
      Team.where("color = 'blue'").each do |team|
        name = team.alias
        puts "#{name} : #{version} : #{protocol}"
        team.services.where("version = ? AND protocol = ?", version, protocol).each do |service|
          count = service.checks.where("passed = ?",true).count
          score = count * service.points_per_check
          puts score
        end
      end
    end
  end
end
