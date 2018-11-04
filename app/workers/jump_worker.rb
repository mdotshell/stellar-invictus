class JumpWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id)
    
    # Make user in warp and loose its target
    user.update_columns(in_warp: true, target_id: nil)
    
    # Tell everyone in location that user warped out
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
    
    # Remove user from being targeted by others
    User.where(target_id: user.id).each do |u|
      u.update_columns(target_id: nil)
      ActionCable.server.broadcast("player_#{u.id}", method: 'refresh_target_info')
    end
    
    # Sleep for the given traveltime by the jumpgate
    sleep(user.location.jumpgate.traveltime-1)
    
    # Set user system to new system
    to_system = System.where(name: user.location.name).first
    user.update_columns(system_id: to_system.id, location_id: Location.where(location_type: 'jumpgate', name: user.system.name, system: to_system.id).first.id, in_warp: false)
    
    # Tell everyone in new location that user has appeared
    ActionCable.server.broadcast("location_#{user.reload.location_id}", method: 'player_appeared')
  end
end