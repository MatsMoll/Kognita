
fetchStatus();

Number.prototype.toMinuteString = function() {
    var minutes = Math.floor((this % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((this % (1000 * 60)) / 1000);
    if (minutes < 10) { minutes = "0" + minutes; }
    if (seconds < 10) { seconds = "0" + seconds; }
    return minutes + ":" + seconds;
}


var userStatusTimer = setInterval(fetchStatus, 5000); // Each 5 seconds

function fetchStatus() {
    let url = "status";

    fetch(url, {
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
        $("#user-status").html(html);
    });
}

function updateTimer() {
    let endsAt = new Date($("#ends-at").val());
    let now = new Date();
    let millisecondsLeft = endsAt - now;
    console.log(endsAt);
    console.log(now);
    console.log(millisecondsLeft);
    if (millisecondsLeft < 2 * 60 * 1000) {
        $("#time-left-badge").removeClass("badge-primary");
        $("#time-left-badge").addClass("badge-danger");
    } 
    if (millisecondsLeft < 0) {
        clearInterval(timer)
    }
    $("#time-left").html(millisecondsLeft.toMinuteString());
}

updateTimer()
var timeLeftTimer = setInterval(updateTimer, 1000);