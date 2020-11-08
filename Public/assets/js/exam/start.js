function startExam(id) {

    let url = "/api/exams/" + id + "/start";

    fetch(url, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        }
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
        window.location.href = "/exam-sessions/" + sessionID + "/tasks/1";
    })
}