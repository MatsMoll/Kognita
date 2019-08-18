function submitProgress(duration, score) {

    var xhr = new XMLHttpRequest();
    var url = $("input:hidden[id=progressUrl]").first().val();
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            var data = JSON.parse(this.responseText);

            console.log(data);

            if (data["progress"]) {
                (window.jQuery).NotificationApp.send(
                    "Bra jobba!",
                    "Du har nå oppnådd " + Math.round(data["progress"] * 100) + "%.",
                    "bottom-right",
                    "rgba(0,0,0,0.2)",
                    "success"
                );
            } else if (data["scoreIncrease"] > 0) {
                (window.jQuery).NotificationApp.send(
                    "Bra jobba!",
                    "Du gikk opp " + Math.round(data["scoreIncrease"] * 100) + " poeng i " + data["topicName"] + ".",
                    "bottom-right",
                    "rgba(0,0,0,0.2)",
                    "success"
                );
            } else if (data["scoreIncrease"]) {
                (window.jQuery).NotificationApp.send(
                    "Oh, prøv en gang til!",
                    "Du gikk ned " + Math.round(data["scoreIncrease"] * 100) + " poeng i " + data["topicName"] + ".",
                    "bottom-right",
                    "rgba(0,0,0,0.2)",
                    "warning"
                );
            }

            if (data["goalProgress"]) {
                $("#goal-progress-label").text(data["goalProgress"] + "%");
                $("#goal-progress-bar").attr("aria-valuenow", data["goalProgress"]);
                $("#goal-progress-bar").attr("style", "width: " + data["goalProgress"] + "%;");
            }
            
        }
    };

    var data = JSON.stringify({
        "correctScore" : score,
        "duration" : duration
    });
    xhr.send(data);
}