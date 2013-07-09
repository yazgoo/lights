window._act = (dest, key) ->
    window._pub dest.replace(/\/values/, ''), key
get_tile = (dest, key, value) ->
    str = "<div class='tiles' style='display: inline;'><div class="
    str += "'small tile'><i class='icon-#{key}' onclick='"
    str += "window._act(\"#{dest}\", \"#{key}\");'></i></div></div>"
add_values = (msg) -> 
    for k, v of $.parseJSON msg.payloadString
        $("#content").append get_tile msg.destinationName, k, v
window._pub = (topic, str) ->
    console.log topic, str
    message = new Messaging.Message str
    message.destinationName = topic
    window._cli.send message
client = new Messaging.Client "127.0.0.1", 8080, "clientId"
window._cli = client
client.onConnectionLost = (response) -> console.log response
client.onMessageArrived = (message) ->
    add_values message if /\/values/.test message.destinationName
client.connect
    onSuccess : () ->
        client.subscribe "/home/actuators/#"
        window._pub "/home/actuators", "list"
    onFailure : (e) ->
        console.log e
