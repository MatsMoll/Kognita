function createTerm() {
    let url = "/api/terms"
    fetch(url, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        },
        body: termData()
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
        console.log(json);
        document.location.reload();
    })
}

function termData() {
    let term = document.getElementById("new-term").value;
    let meaning = newtermmeaning.value();
    let subtopicID = parseInt(document.getElementById("new-term-subtopic-id").value);
    if (term.length == 0) {
        throw new Error("Ups! Må skrive inn et begrep");
    }
    if (meaning.length == 0) {
        throw new Error("Ups! Må skrive hva begrepet betyr");
    }
    if (isNaN(subtopicID)) {
        throw new Error("Ups! En feil oppstod");
    }
    return JSON.stringify({
        "term": term,
        "meaning": meaning,
        "subtopicID": subtopicID
    })
}