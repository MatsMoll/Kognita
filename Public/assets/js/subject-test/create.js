
function createTest() {

    let url = "/api/subject-tests";

    try {
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
                window.location.href = "/subjects";
            } else if (response.status == 400) {
                throw new Error("Sjekk at all nødvendig info er fylt ut");
            } else {
                throw new Error(response.statusText);
            }
        })
        .catch(function (error) {
            presentErrorMessage(error.message);
        });
    } catch(error) {
        presentErrorMessage(error.message);
    }
}