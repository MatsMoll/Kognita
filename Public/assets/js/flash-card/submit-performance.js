var startDate = new Date();
var now = new Date();

var isSubmitting = false;
var hasSubmittedSucessfully = false;
var knowledgeScore = 0;

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
    
    var timeUsed = (now.getTime() - startDate.getTime()) / 1000;
    let knowledge = parseFloat(score);
    let submitedAnswer = $("#flash-card-answer").val();

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