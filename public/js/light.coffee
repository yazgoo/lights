window._id = 0
window._act = (dest, key) ->
    window._pub dest.replace(/\/values/, ''), key
get_tile = (dest, key, value) ->
    "<div class='tiles' style='display: inline;'><div class=
    'small tile'><i class='icon-#{value['icon']}' onclick='
    window._act(\"#{dest}\", \"#{key}\");'></i></div></div>"
get_parametered_input = (dest, key, value) ->
    str = ""
    for k, v of value["parameters"]
        str += "<input placeholder='#{k}' 
        id='#{window._id}' name='#{k}'/>"
    str += "<input type='button' onclick='window._act(\"#{dest}\",
    \"#{key} \" + $(\"#\" + #{window._id}).val())' value='#{key}'>"
    window._id++
    str
get_control = (dest, key, value) ->
    if value['parameters']?
        get_parametered_input dest, key, value
    else
        get_tile dest, key, value
add_values = (msg) -> 
    console.log msg
    console.log msg.destinationName
    n = msg.destinationName.replace(/\/values/, '').replace('/home/actuators/', '')
    console.log n
    $("#content").append "<h3>#{n}</h3>"
    for k, v of $.parseJSON msg.payloadString
        $("#content").append get_control msg.destinationName, k, v
    $("#content").append "<br/>"
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
    onFailure : (e) -> console.log e
