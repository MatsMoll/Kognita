function startPracticeSessionWithTopicIDs(topicIds, subjectId) {

    let taskGoal = 10;

    let data = JSON.stringify({
        "topicIDs" : topicIds,
        "numberOfTaskGoal" : taskGoal,
    });

    let url = "/api/subjects/" + subjectId + "/practice-sessions/start";

    fetch(url, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        },
        body: data
    })
    .then(function (response) {
        if (response.ok) {
            return response.json();
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (json) {
        let sessionID = json["id"];
        window.location.href = "/practice-sessions/" + sessionID + "/tasks/1";
    })
}

function startPracticeSessionWithSubtopicIDs(subtopicIDs, subjectId) {

    let taskGoal = 10;

    let data = JSON.stringify({
        "subtopicsIDs" : subtopicIDs,
        "numberOfTaskGoal" : taskGoal,
    });

    let url = "/api/subjects/" + subjectId + "/practice-sessions/start";

    fetch(url, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        },
        body: data
    })
    .then(function (response) {
        if (response.ok) {
            return response.json();
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (json) {
        let sessionID = json["id"];
        window.location.href = "/practice-sessions/" + sessionID + "/tasks/1";
    })
}