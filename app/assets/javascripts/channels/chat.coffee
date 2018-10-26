$(document).on "turbolinks:load", ->
  if (logged_in && App.appearance && !App.chat)
    App['local-chat'] = App.cable.subscriptions.create({channel: 'ChatChannel', room: 'local_chat'},
      received: (data) ->
        if ($('#local-chat').length > 0)
          $('#local-chat table tbody').append(data.message)
          scrollChats()
          
      send_message: (message) ->
        @perform 'send_message', message: message
    )
        
    App['global-chat'] = App.cable.subscriptions.create({channel: 'ChatChannel', room: 'global_chat'},
      received: (data) ->
        if ($('#global-chat').length > 0)
          $('#global-chat table tbody').append(data.message)
          scrollChats()
          
      send_message: (message) ->
        @perform 'send_message', message: message
    )