
function recapSessionJsonData() {
    let sessionID = $("#note-session").val();
    let numberOfNotes = Math.min($("#notes").children.length, 5);

    return JSON.stringify({
        "sessionID": sessionID,
        "numberOfTasks": numberOfNotes
    })
}

function startRecapSession() {
    fetch("/api/lecture-note-recap", {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        },
        body: recapSessionJsonData()
    })
    .then(function (response) {
        if (response.ok) {
            console.log(response);
            return response.json();
        } else if (response.status == 400) {
            throw new Error("Sjekk at all nødvendig info er fylt ut");
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (sessionID) {
        window.location = "/lecture-note-recap/" + sessionID + "/tasks/0";
    })
}