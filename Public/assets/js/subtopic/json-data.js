function jsonData() {

    var topicId = parseInt($("#topic-id").val());
    var name = $("#subtopic-name").val();

    if (isNaN(topicId) || topicId < 1) {
        throw Error("Velg et tema");
    }
    if (name.length <= 1) {
        throw Error("Du må skrive inn et navn på delemnet");
    }

    return JSON.stringify({
        "topicId"       : topicId,
        "name"          : name
    });
}