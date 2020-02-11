
Number.prototype.toMinuteString = function() {
    var minutes = Math.floor((this % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((this % (1000 * 60)) / 1000);
    if (minutes < 10) { minutes = "0" + minutes; }
    if (seconds < 10) { seconds = "0" + seconds; }
    return minutes + ":" + seconds;
}

function updateTimer() {
    let endsAt = new Date($("#ends-at").val());
    let now = new Date();
    let millisecondsLeft = endsAt - now;
    if (millisecondsLeft < 2 * 60 * 1000) {
        $("#time-left-badge").removeClass("badge-primary");
        $("#time-left-badge").addClass("badge-danger");
    } 
    if (millisecondsLeft < 0) {
        clearInterval(timer)
    }
    $("#time-left").html(millisecondsLeft.toMinuteString());
}

updateTimer();
let timer = setInterval(updateTimer, 1000); // Each 1 seconds

function saveChoise() {
    let testID = testSessionID();
    let url = "/api/test-sessions/" + testID + "/save";

    try {
        fetch(url, {
            method: "POST",
            headers: {
                "Accept": "application/json, text/plain, */*",
                "Content-Type" : "application/json"
            },
            body: jsonData()
        })
        .then(function (response) {
            if (response.ok) {
                return
            } else {
                throw new Error(response.statusText);
            }
        })
        .catch(function (error) {
            $("#submitButton").attr("disabled", false);
            $("#error-massage").text(error.message);
            $("#error-div").fadeIn();
            $("#error-div").removeClass("d-none");
        });
    } catch (error) {
        if (error.name == "MissingDataError") {
            return
        }
    }   
}

function testSessionID() {
    let path = window.location.pathname;
    let splitURI = "test-sessions/";
    return parseInt(path.substring(
        path.indexOf(splitURI) + splitURI.length, 
        path.lastIndexOf("/tasks/")
    ));
}

$('input[name="choiseInput"]').click(function () {
    saveChoise();
});

$("#task-description").each(function () {
    this.innerHTML = renderMarkdown(this.innerHTML);
})
$("input[name='choiseInput']").each(function () {
    $("label[for='" + $(this).attr("id") + "']").each(function (){
        this.innerHTML = renderMarkdown(this.innerHTML);
    });
});