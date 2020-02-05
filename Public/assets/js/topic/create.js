
function createTopic() {
    
    var url = "/api/topics";

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
                return response.json();
            } else if (response.status == 400) {
                throw new Error("Sjekk at all nødvendig info er fylt ut");
            } else {
                throw new Error(response.statusText);
            }
        })
        .then(function (json) {
            window.location.href = "/subjects"
        })
        .catch(function (error) {
            presentErrorMessage(error.message);
        });
    } catch(error) {
        presentErrorMessage(error.message);
    }
}

function presentErrorMessage(message) {
    $("#submitButton").attr("disabled", false);
    $("#error-massage").text(message);
    if ($("#error-div").css("display") == "block") {
        $("#error-div").shake();
    } else {
        $("#error-div").fadeIn();
        $("#error-div").removeClass("d-none");
    }
}

function jsonData() {
    let path = window.location.pathname;
    let subjectURI = "subjects/"

    let subjectId = parseInt(path.substring(
        path.indexOf(subjectURI) + subjectURI.length, 
        path.lastIndexOf("/topics")
    ));

    let name = $("#create-topic-name").val();
    let chapter = parseInt($("#create-topic-chapter").val());

    if (isNaN(subjectId) || subjectId < 1) {
        throw Error("Klarer ikke å finne faget oppgaven tilhører. Dette er ikke din feil, så kontakt Kognita");
    }
    if (isNaN(chapter) || chapter < 1) {
        throw Error("Du på skrive inn et kapittel");
    }
    if (name.length <= 1) {
        throw Error("Du må skrive inn et navn på temaet");
    }

    return JSON.stringify({
        "subjectId"     : subjectId,
        "name"          : name,
        "chapter"       : chapter
    });
}