actuate = (dest, key) -> console.log(dest + " " + key)
get_tile = (dest, key, value) ->
    str = "<div class='tiles'><div class='small tile'>"
    str += "<i class='icon-#{key}' onclick='"
    str += "actuate(\"#{dest}\", \"#{key}\");'></i></div></div>"
add_values = (msg) -> 
    $("#content").append msg.destinationName
    for k, v of $.parseJSON msg.payloadString
        $("#content").append get_tile msg.destinationName, k, v
client = new Messaging.Client "127.0.0.1", 8080, "clientId"
client.onConnectionLost = (response) -> console.log response
client.onMessageArrived = (message) ->
    add_values message if /\/values/.test message.destinationName
client.connect
    onSuccess : () ->
        client.subscribe "/home/actuators/#"
        message = new Messaging.Message "list"
        message.destinationName = "/home/actuators"
        client.send message
    onFailure : (e) ->
        console.log e
