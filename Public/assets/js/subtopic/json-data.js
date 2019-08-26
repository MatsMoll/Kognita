function jsonData() {

    var topicId = parseInt($("#topic-id").val());
    var name = $("#subtopic-name").val();
    var chapter = parseInt($("#subtopic-chapter").val());

    if (isNaN(topicId) || topicId < 1) {
        throw Error("Velg et tema");
    }
    if (name.length <= 1) {
        throw Error("Du må skrive inn et navn på delemnet");
    }
    if (isNaN(chapter) || chapter < 1) {
        throw Error("Du må skrive inn et kapittel");
    }

    return JSON.stringify({
        "topicId"       : topicId,
        "name"          : name,
        "chapter"       : chapter
    });
}