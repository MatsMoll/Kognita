var startDate = new Date();

var timer = setInterval(updateTimer, 1000);

if (window.location.pathname.includes("session") == false) {
    $("#nextButton").removeClass("d-none");
}

function submitAnswer() {

    var answerString = $("#answer").val()
    answerString = answerString.replace(".", "");
    answerString = answerString.replace(" ", "");
    answerString = answerString.replace(",", ".");
    var answer = parseFloat(answerString);

    var url = "/api/" + window.location.pathname;
    
    var now = new Date();
    var timeUsed = (now.getTime() - startDate.getTime()) / 1000;

    if (isNaN(answer)) {
        return
    }
    $("#submitButton").attr("disabled", true);
    clearInterval(timer);
    var data = JSON.stringify({
        "timeUsed" : timeUsed,
        "answer": answer
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
    $("#timer").html(timeUsed.toMinuteString());
}

function handleSuccess(response) {
    console.log(response);
    let progress = response["progress"];
    let change = response["change"];
    results = response["result"]

    $("#nextButton").removeClass("d-none");
    $("#solution-button").removeClass("d-none");
    $("#solution").fadeIn();
    $("#solution").removeClass("d-none");

    if (results["wasCorrect"]) {
        $("#answer").addClass("bg-success text-white");
    } else {
        $("#answer").addClass("bg-danger text-white");
        $("#correct-answer").removeClass("d-none");
        $("#correct-answer").html("Riktig svar: " + results["correctAnswer"]);
    }

    let notificationLength = 20 * 1000;
    if (change >= 0) {
        (window.jQuery).NotificationApp.send(
            "Bra jobba!",
            "Du gikk opp " + Math.round(change * 100) + "%.",
            "bottom-right",
            "rgba(0,0,0,0.2)",
            "success",
            notificationLength
        );
    } else if (change < 0) {
        (window.jQuery).NotificationApp.send(
            "Oh, prøv en gang til!",
            "Du gikk ned " + Math.round(change * 100) + "%.",
            "bottom-right",
            "rgba(0,0,0,0.2)",
            "warning",
            notificationLength
        );
    }

    if (progress) {
        $("#goal-progress-label").text(progress + "%");
        $("#goal-progress-bar").attr("aria-valuenow", progress);
        $("#goal-progress-bar").attr("style", "width: " + progress + "%; ");
        if (progress == 100) {
            $("#goal-progress-bar").addClass("bg-success");
            $("#achivement-success").modal();
        }
    }
}