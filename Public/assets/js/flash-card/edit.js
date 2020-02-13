
function editFlashCard() {

    var path = window.location.pathname;
    var subjectURI = "flash-card/";

    var taskId = parseInt(path.substring(
        path.indexOf(subjectURI) + subjectURI.length, 
        path.lastIndexOf("/edit")
    ));

    try {
        fetch("/api/tasks/flash-card/" + taskId, {
            method: "PUT",
            headers: {
                "Accept": "application/json, text/plain, */*",
                "Content-Type" : "application/json"
            },
            body: jsonData()
        })
        .then(function (response) {
            if (response.ok) {
                return response.json();
            } else if (response.status == 400) {
                throw new Error("Sjekk at all nødvendig info er fylt ut");
            } else {
                throw new Error(response.statusText);
            }
        })
        .then(function (json) {
            window.location.href = "/creator/tasks/flash-card/" + json.id + "/edit?wasUpdated=true";
        })
        .catch(function (error) {
            presentErrorMessage(error.message);
        });
    } catch(error) {
        presentErrorMessage(error.message);
    }
}