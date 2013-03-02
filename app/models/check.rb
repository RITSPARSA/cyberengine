class Check < ActiveRecord::Base
  attr_accessible :team_id, :server_id, :service_id, :passed, :request, :response, :round

  belongs_to :team
  belongs_to :server
  belongs_to :service

  validates :request, presence: true
  validates :response, presence: true
  validates :team, presence: { message: "must exist" }
  validates :server, presence: { message: "must exist" }
  validates :service, presence: { message: "must exist" }
  validates :round, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, uniqueness: { scope: :service_id, message: "already taken" }
  validate :right_team?


  private
  def self.ordered
    order('round ASC')
  end

  def self.latest
    order('round DESC').first
  end

  def self.linegraph_compact
    linegraph = [[0,0]]
    checks = self.ordered
    return linegraph if checks.empty?
    available_points = checks.first.service.available_points
    checks.each do |check| 
      points = checks.where('round <= ?',check.round).points
      linegraph << [check.round,points]
    end
    #linegraph = linegraph.sort.group_by{|a,b| a }.map{|k,v| v.compact.inject{|a,b| [a[0], b[1]+a[1]] } }
    #for i in 1..linegraph.size-1 do linegraph[i] = [linegraph[i][0], linegraph[i][1]+linegraph[i-1][1]] end
    linegraph
  end

  def self.linegraph_full
    @rounds = unscoped.select('round').uniq.map{|c| c.round}
    compact = linegraph_compact
    linegraph = Array.new
    last = compact.last
    @rounds.each do |round|
      linegraph << [round,last[1]] and next if round > last[0]
      compact.each_with_index do |point,index|
        linegraph << point and break if point[0] == round
        linegraph << [round,compact[index-1][1]] and break if point[0] > round
      end
    end
    linegraph 
  end

  def self.linegraph
    #self.linegraph_compact
    self.linegraph_full
  end

  def self.bargraph
    [self.points]
  end

  def self.points
    first = self.first
    return 0 unless first
    available_points = first.service.available_points
    percent = self.percent
    (available_points*percent).round(1)
  end

  def self.passing
    where("passed = ?", true)
  end

  def self.failing
    where("passed = ?", false)
  end

  def self.percent
    total = count.to_f
    return 0.round(1) if total == 0
    pass = passing.count.to_f
    pass / total
  end

  def self.last_round
    latest = self.latest
    return 0 unless latest
    latest.round
  end

  def right_team?
    team = Team.find_by_id(team_id)
    server = Server.find_by_id(server_id)
    service = Service.find_by_id(service_id)
    unless team && server && service && team.id == server.team_id && team.id == service.team_id && team.id == team_id
      errors.add_to_base("Server, Service, and Check must belong to same Team")
    end
    unless team && server && service && server.id == service.server_id && server.id == server_id
      errors.add_to_base("Service and Check must belong to same Server")
    end
  end

end
