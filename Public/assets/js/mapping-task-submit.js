var startDate = new Date();

updateTimer();
var timer = setInterval(updateTimer, 1000);

function submitChoise() {
    var endDate = new Date();
    var duration = (endDate.getTime() - startDate.getTime()) / 1000;
    var selectedChoises = [];

    $("submit-status-badge").removeClass("badge-success");
    $("submit-status-badge").addClass("badge-danger");
    $("submit-status-badge").html("Unsaved");

    $("input:checkbox[name=choiseInput]:checked").each(function() {
        selectedChoises.push({
            "id" : this.id,
        });
    });

    $("input:radio[name=choiseInput]:checked").each(function() {
        selectedChoises.push({
            "id" : this.id,
        });
    });

    var xhr = new XMLHttpRequest();
    var url = window.location.pathname;
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
        if (this.status == 200) {
            $("submit-status-badge").removeClass("badge-danger");
            $("submit-status-badge").addClass("badge-success");
            $("submit-status-badge").html("Saved");
        }
    };
    var data = JSON.stringify({
        "timeUsed" : duration,
        "choises": selectedChoises
    });
    xhr.send(data);
}


function updateTimer() {
    var now = new Date();
    var endTimeValue = $("#end-time").html();
    var endTime = new Date("December 30, 2018 " + endTimeValue);
    var timeUsed = endTime.getTime() - now.getTime();

    if (timeUsed > 0) {
        var minutes = Math.floor((timeUsed % (1000 * 60 * 60)) / (1000 * 60));
        var seconds = Math.floor((timeUsed % (1000 * 60)) / 1000);
        if (minutes < 10) { minutes = "0" + minutes; }
        if (seconds < 10) { seconds = "0" + seconds; }
        $("#timer").html(minutes + ":" + seconds);
    } else {
        $("#timer").html("Tiden er ute");
    }
    
}