window._id = 0
window._act = (dest, key) ->
    window._pub dest.replace(/\/values/, ''), key
get_tile = (dest, key, value) ->
    "<div class='tiles' style='display: inline;'><div class=
    'small tile'><i class='icon-#{value['icon']}' onclick='
    window._act(\"#{dest}\", \"#{key}\");'></i></div></div>"
get_options = (v) ->
    ["<option value='#{i}' #{"selected=selected" if v['default'] == i}
    >#{i}</option>" for i in [v['start']..v['end']] when i % v.step == 0].join("\n")
window._get_values = (id) ->
    result = {}
    result[c.name] = c.value for c in $('#' + id).children()
    JSON.stringify result
get_parametered_input = (dest, key, value) ->
    str = "<form  id='#{window._id}'>"
    str += for k, v of value["parameters"]
        switch v.type
            when "string" then "<input placeholder='#{k}' name='#{k}' value='#{if v.default? then v.default else '' }'/>"
            when "range" then "<select class='modal button green' name='#{k}'>#{get_options v}</select>"
    str += "</form><input type='button' onclick='window._act(\"#{dest}\",
    \"#{key} \" + window._get_values(#{window._id}))' value='#{key}'>"
    window._id++
    str
get_control = (dest, key, value) ->
    if value['parameters']?
        get_parametered_input dest, key, value
    else
        get_tile dest, key, value
get_message_title = (msg) ->
    "<h3>#{msg.destinationName.replace(
        '/home/actuators/([^/]+)/values', '$1')}</h3>"
add_values = (msg) ->
    console.log msg.payloadString
    console.log $.parseJSON msg.payloadString
    $("#content").append "#{get_message_title msg}
        #{(for k, v of $.parseJSON msg.payloadString
            get_control msg.destinationName, k, v).join(" ")
    }<br/>"
add_sense = (msg) ->
    payload = $.parseJSON msg.payloadString
    _id = "sense_#{msg.destinationName.replace /\//g, "_"}"
    id = "#" + _id
    element = $(id)
    if not element.length
        console.log "adding element"
        $("#content").append "#{get_message_title msg}<div id='#{_id}'></div>"
        element = $(id)
    element.html "#{payload.join "<br/>"}"
window._pub = (topic, str) ->
    console.log str
    message = new Messaging.Message str
    message.destinationName = topic
    window._cli.send message
client = new Messaging.Client "127.0.0.1", 8080, "clientId"
window._cli = client
client.onConnectionLost = (response) -> console.log response
client.onMessageArrived = (message) ->
    if /\/values/.test message.destinationName then add_values message
    else if /\/sensors\//.test message.destinationName then add_sense message
client.connect
    onSuccess : () ->
        client.subscribe "/home/actuators/#"
        client.subscribe "/home/sensors/#"
        window._pub "/home/actuators", "list"
    onFailure : (e) -> console.log e
