function deleteTerm() {
    let termID = parseInt(document.getElementById("term-id").value)
    if (isNaN(termID)) {
        throw new Error("Ups! En feil oppstod");
    }
    let url = "/api/terms/" + termID
    fetch(url, {
        method: "DELETE",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        }
    })
    .then(function (response) {
        if (response.ok) {
            return
        } else if (response.status == 400) {
            throw new Error("Sjekk at all nødvendig info er fylt ut");
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (json) {
        document.location.reload();
    })
}