function startMappingSession() {

    var selectedTopics = $("#mapping-topic-selector").val();
    var maxDuration = 60 * 15;

    var xhr = new XMLHttpRequest();
    var url = $("input:hidden[id=mapping-session-url]").first().val();
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            var data = JSON.parse(this.responseText);
            var redirectionUrl = data["redirectionUrl"];
            window.location.href = redirectionUrl;
        }
    };
    var data = JSON.stringify({
        "topicIDs" : selectedTopics,
        "maxDuration" : maxDuration,
    });
    xhr.send(data);
}