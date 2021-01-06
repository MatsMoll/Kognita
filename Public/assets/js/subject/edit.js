function editSubject(subjectID) {
    
    let url = "/api/subjects/" + subjectID
    fetch(url, {
        method: "PUT",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        },
        body: createSubjectData()
    })
    .then(function (response) {
        if (response.ok) {
            window.location.reload()
        } else if (response.status == 400) {
            throw new Error("Sjekk at all nødvendig info er fylt ut");
        } else {
            throw new Error(response.statusText);
        }
    })
    .catch(function (error) {
        $("#submitButton").attr("disabled", false);
        $("#error-massage").text(error.message);
        if ($("#error-div").css("display") == "block") {
            $("#error-div").shake();
        } else {
            $("#error-div").fadeIn();
            $("#error-div").removeClass("d-none");
        }
    });
}