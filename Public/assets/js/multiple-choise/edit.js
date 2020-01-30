
function editMultipleChoise() {

    let url = "/api/tasks/multiple-choise/" + taskID();

    try {
        fetch(url, {
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
            window.location.href = "../" + json.id + "/edit?wasUpdated=true";
        })
        .catch(function (error) {
            presentErrorMessage(error.message);
        });
    } catch(error) {
        presentErrorMessage(error.message);
    }
}

function taskID() {
    let path = window.location.pathname;
    let subjectURI = "multiple-choise/";

    return parseInt(path.substring(
        path.indexOf(subjectURI) + subjectURI.length, 
        path.lastIndexOf("/edit")
    ));
}