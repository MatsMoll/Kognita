
function deleteTest(id) {

    let url = "/api/subject-tests/" + String(id);

    fetch(url, {
        method: "DELETE",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        }
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
}