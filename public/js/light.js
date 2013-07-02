function add_actors_groups(actorsGroups, container)
{
    $(container).empty(str);
    for(var k in actorsGroups)
    {
        var actors = actorsGroups[k];
        var str = "";
        str += '<div class="tiles"> <input type="hidden" value="" id="action-tiles-'+k+'" class="value">';
        for(var i in actors)
        {
            for(var j in actors[i])
            {
                var button = actors[i][j];
                str += '<div class="tile ' + (button['class'] == undefined?'':button['class'])+ '" data-value="'
                    + i + '_' + (button['specific'] == undefined? '' : (button['specific'] + '_')) + button['name'] + '">';
                str += '<i class="icon-4x icon-' + button['icon'] + '"></i>'
                    if(!actors[i][j].notext) str += i + ' ' + (button['display-name'] == null ?button['name']:button['display-name']);
                str += '</div> ';
            }
        }
        str += "</div>"
            $(container).append(str);
        $('input#action-tiles-' + k).on('change', function() {
            var url = $(this).val().replace(/___/g, "---").replace(/__/g, ".").replace(/_/g, "/").replace(/---/g, "_");
            $.get(url , function(data)
                {
                });
        });
    }
}
$(document).ready(function(){
    var actorsGroups = [ {
        "salon": [
{"icon": "circle", "name": "on"},
{"icon": "circle-blank", "name": "off"},
],
"store": [
{"icon": "arrow-up", "name": "up"},
{"icon": "arrow-down", "name": "down"},
],
"video": [
{"icon": "off", "name": "on-off"},
],
"salon/lamp": [
{"icon": "circle", "name": "on"},
{"icon": "circle-blank", "name": "off"},
{"icon": "circle-blank", "display-name": "cozy", "name": "dim/11"},
],
},
{
    "video": [
    {"icon": "fast-backward", "specific": "control", "name": "fast-backward", "notext": true},
    {"icon": "backward", "specific": "control", "name": "backward", "notext": true},
    {"icon": "play", "specific": "control", "name": "play", "notext": true},
    {"icon": "stop", "specific": "control", "name": "stop", "notext": true},
    {"icon": "pause", "specific": "control", "name": "pause", "notext": true},
    {"icon": "forward", "specific": "control", "name": "forward", "notext": true},
    {"icon": "fast-forward", "specific": "control", "name": "fast-forward", "notext": true},
    ],
},
    ]
    add_actors_groups(actorsGroups, "#content");
    function load_videos() {
        $.getJSON('video/list', function(data) {
            actorsGroups = [ { "media": [ ] } ]
            var videos = actorsGroups[0]['media']
            for(k in data)
        {
            videos.push(
                {"icon": "film", "display-name": data[k]['name'], "class": "one half",
                    "name": data[k]['name'].replace(/_/g, "___").replace(/\./g, "__"), "specific": "play", "small": true});
            videos.push(
                {"icon": "remove", "display-name": data[k]['size'], "class": "one half",
                    "name": data[k]['name'], "specific": "remove", "small": true}
                );
        }
        add_actors_groups(actorsGroups, "#videos");
        });
    }
load_videos();
setInterval(load_videos, 1000 * 10);
function disk_used()
{
    $.get('disk/used', function(data) {
        $("#disk_used").empty();
        $("#disk_used").append(data);
    });
}
disk_used();
setInterval(disk_used, 1000 * 10);
});
function media_download()
{
    $.get('media/download/start/',
            { url: 
                $('#download').find('input[name="url"]').val() })
}
