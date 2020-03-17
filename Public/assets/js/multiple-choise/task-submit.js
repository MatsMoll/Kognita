var startDate = new Date();

var timer = setInterval(updateTimer, 1000);

if (window.location.pathname.includes("session") == false) {
    $("#nextButton").removeClass("d-none");
}

function navigateTo(index) {
    location.href = index;
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

    var url = "/api/practice-sessions/" + sessionID() + "/submit/multiple-choise";

    var data = JSON.stringify({
        "timeUsed" : timeUsed,
        "choises": selectedChoises,
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
    var timeString = timeUsed.toMinuteString();
    $("#timer").html(timeString);
}

function handleSuccess(results) {

    let progress = results["progress"];
    results = results["result"] != null ? results["result"] : results;

    presentControlls();

    for (var i = 0; i < results.length; i++) {

        var id = results[i]["id"];
        let div = $("#" + id + "-div");
        let label = div.find("label");
        div.removeClass("text-secondary");

        if (results[i]["isCorrect"]) {
            div.addClass("bg-success");
        } else {
            div.addClass("bg-danger text-white");
        }
        label.addClass("text-white");
    }

    $("input[name=choiseInput]").attr('disabled', true);

    if (progress) {
        $("#goal-progress-label").text(progress + "% ");
        $("#goal-progress-bar").attr("aria-valuenow", progress);
        $("#goal-progress-bar").attr("style", "width: " + progress + "%;");
    }
}

function fetchSolutions() {
    fetch("/practice-sessions/" + sessionID() + "/tasks/" + taskIndex() + "/solutions", {
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
    $("#submitButton").attr("disabled", true);
    $("#nextButton").removeClass("d-none");
    $("#solution-button").removeClass("d-none");
    $(".reveal").each(function () {
        $(this).fadeIn();
        $(this).removeClass("d-none");
    });
    fetchSolutions();
    fetchDiscussions($("#task-id").val())
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

$("input[name='choiseInput']").each(function () {
    $("label[for='" + $(this).attr("id") + "']").each(function (){
        this.innerHTML = renderMarkdown(this.innerHTML);
    });
});
$("#task-description").each(function () {
    this.innerHTML = renderMarkdown(this.innerHTML);
})