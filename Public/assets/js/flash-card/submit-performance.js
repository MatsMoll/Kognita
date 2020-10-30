var startDate = new Date();
var now = new Date();

var isSubmitting = false;
var hasSubmittedSucessfully = false;
var knowledgeScore = 2;
var didSubmitt = false;

var nextIndex=1;
function navigateTo(index) {
    submitPerformance(knowledgeScore, function() {
        if ($("#goal-progress-bar").attr("aria-valuenow") >= 100) {
            nextIndex=index;
            $("#goal-completed").modal("show");
        } else {
            location.href = index;
        }
    })
}

function revealSolution() {
    didSubmitt = $("#solution").hasClass("d-none");
    presentControllsAndKnowledge();

    if ($("#solution").hasClass("d-none")) {
        now = new Date();
        $("#nextButton").removeClass("d-none");
        var goalValue = parseFloat($("#goal-value").text());
        var porgressBarValue = parseFloat($("#goal-progress-bar").attr("aria-valuenow"))
        var currentCompleted = porgressBarValue / 100 * goalValue;
        var progress = parseInt(Math.ceil((currentCompleted + 1) * 100 / goalValue));
    
        if (!isNaN(progress)) {
            $("#goal-progress-label").text(progress + "% ");
            $("#goal-progress-bar").attr("aria-valuenow", progress);
            $("#goal-progress-bar").attr("style", "width: " + progress + "%;");
            if (progress >= 100) {
                $("#goal-progress-bar").addClass("bg-success");
            }
        }
        submitPerformance(knowledgeScore, function (){})
    }
}

function updateScoreButton() {
    if (knowledgeScore < 2) {
        $("#" + knowledgeScore).attr("class", "btn btn-danger");    
    } else if (knowledgeScore < 4) {
        $("#" + knowledgeScore).attr("class", "btn btn-warning");
    } else {
        $("#" + knowledgeScore).attr("class", "btn btn-success");
    }
}

function registerScore(score) {
    $("#" + knowledgeScore).attr("class", "btn btn-light");
    knowledgeScore = score;
    updateScoreButton()
    submitPerformance(knowledgeScore, function() {})
}

function submitAndEndSession() {
    endSession()
}

function submitPerformance(score, handleSuccess) {

    if (isSubmitting) {
        return
    }
    isSubmitting = true;

    var url = "/api/practice-sessions/" + sessionID() + "/submit/flash-card";

    fetch(url, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        },
        body: answerJsonData(score)
    })
    .then(function (response) {
        isSubmitting = false;
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
        isSubmitting = false;
        $("#submitButton").attr("disabled", false);
        $("#error-massage").text(error.message);
        $("#error-div").fadeIn();
        $("#error-div").removeClass("d-none");
    });
}

function presentControlls() {
    estimatedScore(didSubmitt);
    $("#flash-card-answer").prop('readonly', true)
    $("#submitButton").prop('disabled', true)
    $("#nextButton").removeClass("d-none");
    $(".reveal").each(function () {
        $(this).fadeIn();
        $(this).removeClass("d-none");
    });
    fetchSolutions();
    fetchDiscussions($("#task-id").val())
    $("#knowledge-card").removeClass("d-none");
    updateScoreButton()
}

function presentControllsAndKnowledge() {
    presentControlls()
    hasSubmitted = false;
    hasSubmittedSucessfully = false;
}


Number.prototype.toMinuteString = function() {
    var minutes = Math.floor((this % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((this % (1000 * 60)) / 1000);
    if (minutes < 10) { minutes = "0" + minutes; }
    if (seconds < 10) { seconds = "0" + seconds; }
    return minutes + ":" + seconds;
}

function endSession() {
    $("#end-session-form").submit();
}

function answerJsonData(score) {
    var timeUsed = (now.getTime() - startDate.getTime()) / 1000;
    let knowledge = parseFloat(score);
    let submitedAnswer = $("#flash-card-answer").val();

    if (knowledge == null) {
        return
    }
    return JSON.stringify({
        "timeUsed" : timeUsed,
        "knowledge": knowledge,
        "taskIndex": taskIndex(),
        "answer": submitedAnswer
    });
}

function estimatedScore(shouldSetScore) {
    let url = "/api/practice-sessions/" + sessionID() + "/tasks/" + taskIndex() + "/estimate";
    
    $("#estimated-score-card").fadeIn();
    $("#estimated-score-card").removeClass("d-none");
    $("#estimate-spinner").html('<div class="d-flex justify-content-center"><div class="spinner-border" role="status"><span class="sr-only">Loading...</span></div></div>')

    fetch(url, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        },
        body: answerJsonData("3")
    })
    .then(function (response) {
        if (response.ok) {
            return response.json();
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (json) {
        let score = json["score"];
        let roundedScore = Math.round(score * 4);

        var text = "Vi estimerer at du";
        if (shouldSetScore == true) {
            registerScore(roundedScore);
        }
        if (roundedScore >= 4) {
            text += " kan denne oppgaven veldig godt 💯"
        } else if (roundedScore >= 3) {
            text += " kan denne oppgaven godt 🔥"
        } else if (roundedScore >= 2) {
            text += " kan noe 🙌"
        } else {
            text += " kanskje burde lese litt mer 🤔"
        }
        
        $("#estimate-spinner").addClass("d-none");
        $("#answer-estimate").text(text);
        $("#answer-estimate").removeClass("d-none");
        let improvements = json["improvements"];
        if (improvements.lenght != 0) {
            $("#estimated-score-card .card-body").append("<br>Kanskje nevn noe mer om dette?<ul>")
        }
        console.log(improvements);
        for (const index in improvements) {
            $("#estimated-score-card .card-body").append("<li>" + improvements[index]["word"] + "</li>");
        }
        if (improvements.lenght != 0) {
            $("#estimated-score-card .card-body").append("</ul>")
        }
    })
    .catch(function (error) {
        console.log(error)
    })
}

var hints = []
var hintIndex = 0;

function loadHints() {
    if (hints.length > 0 && hintIndex < hints.length) {
        revealHint();
        return
    } else if (hintIndex > 0) { 
        return 
    }
    let url = "/api/practice-sessions/" + sessionID() + "/tasks/" + taskIndex() + "/estimate";

    fetch(url, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        },
        body: answerJsonData("3")
    })
    .then(function (response) {
        if (response.ok) {
            return response.json();
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (json) {
        hints = json["improvements"];
        revealHint();
    })
    .catch(function (error) {
        console.log(error)
    })
}

function revealHint() {
    console.log($('#hint-card').length);
    if ($('#hint-card').length == 0) {
        $("#main-task-content .col-lg-7").append("<div class='card'><div class='card-body' id='hint-card'></div></div>")
        $("#hint-card").append("<h6>Hint nr: " + (hintIndex + 1) + "</h6><p class='text-dark'>" + hints[hintIndex++]["word"] + "</p>")
    } else {
        $("#hint-card").append("<h6>Hint nr: " + (hintIndex + 1) + "</h6><p class='text-dark'>" + hints[hintIndex++]["word"] + "</p>")
    }
}