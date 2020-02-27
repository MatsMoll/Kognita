
fetchStatus();

let renderedAt = new Date($("#rendered-at").val());
let timeDiff = new Date() - renderedAt;

Number.prototype.toMinuteString = function() {
    let hours = Math.floor((this / (1000 * 60 * 60)))
    var minutes = Math.floor((this % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((this % (1000 * 60)) / 1000);
    if (minutes < 10) { minutes = "0" + minutes; }
    if (seconds < 10) { seconds = "0" + seconds; }
    if (hours > 0) {
        return hours + ":" + minutes + ":" + seconds;
    } else {
        return minutes + ":" + seconds;
    }
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
    let millisecondsLeft = endsAt - now - timeDiff;

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