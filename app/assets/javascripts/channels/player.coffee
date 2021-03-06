$(document).on "turbolinks:load", ->
  if (logged_in && !App.player)
    App.player = App.cable.subscriptions.create "PlayerChannel",
      # Called when the subscription is ready for use on the server.
      connected:->
     
      # Called when the WebSocket connection is closed.
      disconnected:->
      
      # On message received
      received: (data)->
        if (data.method == 'received_mail')
          received_mail()
        else if (data.method == 'refresh_target_info')
          refresh_target_info()
        else if (data.method == 'refresh_player_info')
          refresh_player_info()
        else if (data.method == 'getting_targeted' && data.name)
          getting_targeted(data.name)
        else if (data.method == 'stopping_target' && data.name)
          stopping_target(data.name)
        else if (data.method == 'getting_attacked' && data.name)
          getting_attacked(data.name)
        else if (data.method == 'stopping_attack' && data.name)
          stopping_attack(data.name)
        else if (data.method == 'getting_helped' && data.name)
          getting_helped(data.name)
        else if (data.method == 'disable_equipment')
          disable_equipment()
        else if (data.method == 'update_health' && data.hp)
          update_health(data.hp)
        else if (data.method == 'update_target_health' && data.hp)
          update_target_health(data.hp)
        else if (data.method == 'update_asteroid_resources' && data.resources)
          update_asteroid_resources(data.resources, true)
        else if (data.method == 'update_asteroid_resources_only' && data.resources)
          update_asteroid_resources(data.resources, false)
        else if (data.method == 'asteroid_depleted')
          remove_target()
          reload_players_card()
        else if (data.method == 'remove_target')
          remove_target()
        else if (data.method == 'died_modal' && data.text)
          show_died_modal(data.text)
        else if (data.method == 'log' && data.text)
          log(data.text)
        else if (data.method == 'new_friendrequest')
          new_friendrequest()
        else if (data.method == 'invited_to_conversation' && data.data)
          invited_to_conversation(data.data)
        else if (data.method == 'invited_to_fleet' && data.data)
          invited_to_fleet(data.data)
        else if (data.method == 'show_error' && data.text)
          show_error(data.text)
        else if (data.method == 'notify_alert' && data.text)
          if (data.delay)
            setTimeout ->
              $.notify(data.text, {style: 'alert'})
            , data.delay
          else
            $.notify(data.text, {style: 'alert'})
        else if (data.method == 'notify_info' && data.text)
          $.notify(data.text, {style: 'info'})
        else if (data.method == 'reload_chat')
          if (window.location.pathname == "/game" || window.location.pathname == "/station")
            reload_chat()
        else if (data.method == 'reload_corporation' || data.method == 'reload_fleet')
          if (window.location.pathname == "/game" || window.location.pathname == "/station" || window.location.pathname == "/corporation")
            reload_chat()
            reload_players_card()
        else if (data.method == 'warp_finish')
            clear_jump(data.local)
        else if (data.method == 'reload_page')
          reload_page()
        else if (data.method == 'warp_disrupted')
          warp_disrupted()
        else if (data.method == 'fleet_warp' && data.location)
          fleet_warp(data.location, data.align_time)