
var submitedAnswer = "";
var startDate = new Date();
var now = new Date();

var timer = setInterval(updateTimer, 1000);
var hasSubmitted = false;

function navigateTo(index) {
    if (hasSubmitted) {
        location.href = index
    } else {
        location.href = "#knowledge-card";
        $("#knowledge-card").addClass("bg-primary text-white")
        $("#knowledge-card").shake();
    }
}

function revealSolution() {
    submitedAnswer = $("#flash-card-answer").val();
    clearInterval(timer);
    presentControllsAndKnowledge();

    if ($("#solution").hasClass("d-none")) {
        now = new Date();
        $("#nextButton").removeClass("d-none");
        var goalValue = parseFloat($("#goal-value").text());
        var porgressBarValue = parseFloat($("#goal-progress-bar").attr("aria-valuenow"))
        var currentCompleted = porgressBarValue / 100 * goalValue;
        var progress = parseInt((currentCompleted + 1) * 100 / goalValue);
    
        if (!isNaN(progress)) {
            $("#goal-progress-label").text(progress + "% ");
            $("#goal-progress-bar").attr("aria-valuenow", progress);
            $("#goal-progress-bar").attr("style", "width: " + progress + "%;");
            if (progress == 100) {
                $("#goal-progress-bar").addClass("bg-success");
                $("#achivement-success").modal();
            }
        }
    }
}

function nextTask(score) {
    submitPerformance(score, function() {
        location.href = $("#next-task").val();
    })
}

function submitAndEndSession() {
    if ($("#solution").hasClass("d-none")) {
        endSession();
    } else {
        submitPerformance(2, function() { 
            endSession(); 
        });
    }
}

function submitPerformance(score, handleSuccess) {

    if (hasSubmitted) {
        handleSuccess();
        return
    }
    hasSubmitted = true;

    var url = "/api/practice-sessions/" + sessionID() + "/submit/flash-card";
    
    var timeUsed = (now.getTime() - startDate.getTime()) / 1000;
    let knowledge = parseFloat(score);

    if (knowledge == null) {
        return
    }
    var data = JSON.stringify({
        "timeUsed" : timeUsed,
        "knowledge": knowledge,
        "taskIndex": taskIndex(),
        "answer": submitedAnswer
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
        $(".solutions").each(function () {
            this.innerHTML = renderMarkdown(this.innerHTML);
        });
    })
    .catch(function (error) {
        $("#submitButton").attr("disabled", false);
        $("#error-massage").text(error.message);
        $("#error-div").fadeIn();
        $("#error-div").removeClass("d-none");
    });
}

function presentControlls() {
    $("#flash-card-answer").prop('readonly', true)
    $("#submitButton").prop('disabled', true)
    $("#nextButton").removeClass("d-none");
    fetchSolutions(taskIndex(), sessionID());
    hasSubmitted = true;
}

function presentControllsAndKnowledge() {
    presentControlls()
    hasSubmitted = false;
    $("#knowledge-card").removeClass("d-none");
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

function endSession() {
    $("#end-session-form").submit();
}

$("#task-description").html(renderMarkdown($("#task-description").html()));