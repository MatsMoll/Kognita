function suggestSolution() {

    let url = "/api/task-solutions"

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
            $("#create-alternative-solution").modal("hide");
            fetchSolutions();
            suggestedsolution.value();
        } else {
            console.log("Error: ", response.statusText);
        }
    })
}

function jsonData() {
    let solution = suggestedsolution.value()
    let taskID = parseInt($("#task-id").val());
    let presentUser = $("#present-user").prop("checked");

    if (isNaN(taskID) || taskID < 1) {
        throw Error("Ups! En feil oppstod, men dette er ikke din feil! Prøv igjen eller kontakt oss")
    }
    if (solution.lenght < 1) {
        throw Error("Mangler løsningsforslt");
    }

    return JSON.stringify({
        "solution" : solution,
        "taskID" : taskID,
        "presentUser" : presentUser
    })
}