
function markPotensialSubjects() {

    let url = "/api/subjects/mark-potensial"

    let responses = Array.from(document.querySelectorAll(".rel-switch")).map(node => {
        return {
            id: parseInt(node.querySelector("input").getAttribute("id")),
            isActive: node.querySelector("input").checked
        }
    })
    let data = JSON.stringify(responses)
    fetch(url, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        },
        body: data
    })
    .then(function (response) {
        if (response.ok) {
            window.location.reload();
        } else if (response.status == 400) {
            throw new Error("Sjekk at all nødvendig info er fylt ut");
        } else {
            throw new Error(response.statusText);
        }
    })
}