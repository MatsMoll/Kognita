
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

var hasSaved = true;

function timeout(ms, promise) {
    return new Promise(function(resolve, reject) {
        setTimeout(function() {
            reject(new Error("timeout"))
        }, ms)
        promise.then(resolve, reject)
    })
}

function saveChoise() {
    let testID = testSessionID();
    let url = "/api/test-sessions/" + testID + "/save";

    try {
        if (hasSaved) {
            $("#save-status").html("Lagrer");
            $("#save-status-spinner").attr("class", "spinner-grow spinner-grow-sm");
            $("#save-status-badge").removeClass("badge-success");
            $("#save-status-badge").addClass("badge-danger");
            $("#save-status-icon").addClass("d-none");
        } else {
            $("#save-status").html("Lagrer - Sjekk internett koblingen din");
        }
        hasSaved = false;
        timeout(5000,
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
                    if (hasSaved == false) {
                        $("#save-status-badge").removeClass("badge-danger");
                        $("#save-status-badge").addClass("badge-success");
                        $("#save-status-spinner").attr("class", "d-none");
                        $("#save-status-icon").removeClass("d-none");
                        $("#save-status").html("Lagret");
                    }
                    hasSaved = true;
                    return
                } else {
                    saveChoise();
                    throw new Error(response.statusText);
                }
            })
        ).catch(function() {
            saveChoise();
        })
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