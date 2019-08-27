function startPracticeSession(topicId, subjectId) {

    var selectedTopics = [parseInt(topicId)];
    var taskGoal = 5;
    if (isNaN(selectedTopics)) {
        selectedTopics = $("#practice-topic-selector").val().map(x => parseInt(x));
        taskGoal = parseInt($("#task-number-input").val());
    }

    var xhr = new XMLHttpRequest();
    var url = "/api/subjects/" + subjectId + "/practice-sessions/start";
    if (isNaN(subjectId)) {
        var url = "/api/" + window.location.pathname + "/practice-sessions/start";
    }
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            var data = JSON.parse(this.responseText);
            window.location.href = data["redirectionUrl"];
        }
    };
    var data = JSON.stringify({
        "subtopicsIDs" : selectedTopics,
        "numberOfTaskGoal" : taskGoal,
    });
    console.log(data);
    xhr.send(data);
}