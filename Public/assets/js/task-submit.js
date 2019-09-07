var startDate = new Date();

var timer = setInterval(updateTimer, 1000);

if (window.location.pathname.includes("session") == false) {
    $("#nextButton").removeClass("d-none");
}

function submitChoises() {
    $("#submitButton").attr("disabled", true);

    clearInterval(timer);
    
    var selectedChoises = [];

    $("input:checkbox[name=choiseInput]:checked").each(function() {
        selectedChoises.push(parseInt(this.id));
    });

    $("input:radio[name=choiseInput]:checked").each(function() {
        selectedChoises.push(parseInt(this.id));
    });

    var now = new Date();
    var timeUsed = (now.getTime() - startDate.getTime()) / 1000;

    let path = window.location.pathname;
    let splitURI = "sessions/"
    var sessionId = parseInt(path.substring(
        path.indexOf(splitURI) + splitURI.length, 
        path.lastIndexOf("/tasks")
    ));
    var url = "/api/practice-sessions/" + sessionId + "/submit/multiple-choise";

    var data = JSON.stringify({
        "timeUsed" : timeUsed,
        "choises": selectedChoises
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

var numberOfHints = 0;
function presentHint() {
    numberOfHints += 1;
    $('#hint-card').fadeIn('slow');
    $('#hint-body').append(
        $('<li id="hint-' + numberOfHints + '" style="display: none;"><p>This is hint nr.' + numberOfHints + '</p></li>')
    );
    $('#hint-' + numberOfHints).fadeIn('slow');
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
    var timeString = timeUsed.toMinuteString();
    $("#timer").html(timeString);
}

function handleSuccess(results) {

    let progress = results["progress"];
    let change = results["change"];
    results = results["result"] != null ? results["result"] : results;

    $("#nextButton").removeClass("d-none");
    $("#solution-button").removeClass("d-none");
    $("#solution").fadeIn();
    $("#solution").removeClass("d-none");

    for (var i = 0; i < results.length; i++) {

        var id = results[i]["id"];
        var div = $("#" + id + "-div");
        div.removeClass("text-secondary");

        if (results[i]["isCorrect"]) {
            div.addClass("bg-success text-white");
        } else {
            div.addClass("bg-danger text-white");
        }
    }

    if (progress) {
        $("#goal-progress-label").text(progress + "% ");
        $("#goal-progress-bar").attr("aria-valuenow", progress);
        $("#goal-progress-bar").attr("style", "width: " + progress + "%;");
        if (progress == 100) {
            $("#goal-progress-bar").addClass("bg-success");
            $("#achivement-success").modal();
        }
    }
}