var startDate = new Date();

var timer = setInterval(updateTimer, 1000);

if (window.location.pathname.includes("session") == false) {
    $("#nextButton").removeClass("d-none");
}

function sessionID() {
    let path = window.location.pathname;
    let splitURI = "sessions/"
    return parseInt(path.substring(
        path.indexOf(splitURI) + splitURI.length, 
        path.lastIndexOf("/tasks")
    ));
}

function taskIndex() {
    let path = window.location.pathname;
    let splitURI = "tasks/";
    return parseInt(path.substring(
        path.indexOf(splitURI) + splitURI.length, 
        path.length
    ));
}

function submitAnswer() {

    var answerString = $("#answer").val()
    answerString = answerString.replace(".", "");
    answerString = answerString.replace(" ", "");
    answerString = answerString.replace(",", ".");
    var answer = parseFloat(answerString);
    
    var url = "/api/practice-sessions/" + sessionID() + "/submit/input";
    
    var now = new Date();
    var timeUsed = (now.getTime() - startDate.getTime()) / 1000;

    if (isNaN(answer)) {
        return
    }
    $("#submitButton").attr("disabled", true);
    clearInterval(timer);
    var data = JSON.stringify({
        "timeUsed" : timeUsed,
        "answer": answer,
        "taskIndex": taskIndex()
    });
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
        handleSuccess(json);
    })
    .catch(function (error) {
        $("#submitButton").attr("disabled", false);
        $("#error-massage").text(error.message);
        $("#error-div").fadeIn();
        $("#error-div").removeClass("d-none");
    });
}

Number.prototype.toMinuteString = function() {
    var minutes = Math.floor((this % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((this % (1000 * 60)) / 1000);
    if (minutes < 10) { minutes = "0" + minutes; }
    if (seconds < 10) { seconds = "0" + seconds; }
    return minutes + ":" + seconds;
}

function updateTimer() {
    var now = new Date();
    var timeUsed = now.getTime() -  startDate.getTime();
    $("#timer").html(timeUsed.toMinuteString());
}

function handleSuccess(response) {
    console.log(response);
    let progress = response["progress"];
    results = response["result"]
    
    presentControlls();

    if (results["wasCorrect"]) {
        $("#answer").addClass("bg-success text-white");
    } else {
        $("#answer").addClass("bg-danger text-white");
        $("#correct-answer").removeClass("d-none");
        $("#correct-answer").html("Riktig svar: " + results["correctAnswer"]);
    }

    if (progress) {
        $("#goal-progress-label").text(progress + "%");
        $("#goal-progress-bar").attr("aria-valuenow", progress);
        $("#goal-progress-bar").attr("style", "width: " + progress + "%; ");
    }
}

function presentControlls() {
    $("#submitButton").attr("disabled", true);
    $("#nextButton").removeClass("d-none");
    $("#prevButton").removeClass("d-none");
    $("#solution-button").removeClass("d-none");
    fetchSolutions(taskIndex(), sessionID());
}

function fetchSolutions(taskIndex, practiceSessionID) {
    fetch("/practice-sessions/" + practiceSessionID + "/tasks/" + taskIndex + "/solutions", {
        method: "GET",
        headers: {
            "Accept": "application/html, text/plain, */*",
        }
    })
    .then(function (response) {
        if (response.ok) {
            return response.text();
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (html) {
        $("#solution").html(html);
        $("#solution").fadeIn();
        $("#solution").removeClass("d-none");
    })
    .catch(function (error) {
        $("#submitButton").attr("disabled", false);
        $("#error-massage").text(error.message);
        $("#error-div").fadeIn();
        $("#error-div").removeClass("d-none");
    });
}