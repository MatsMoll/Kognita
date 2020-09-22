
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
            window.location.href = "/creator/subjects/" + subjectID() + "/overview";
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

    let name = $("#create-topic-name").val();
    let chapter = parseInt($("#create-topic-chapter").val());
    let subjectId = subjectID();

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
        "subjectID"     : subjectId,
        "name"          : name,
        "chapter"       : chapter
    });
}

function jsonDataVTwo() {
    var topics = []
    $("#dragables > div").each(function () {
        topics.push({
            "id": parseInt($(this).attr("id")),
            "name": $(this).find(".topic-name").text(),
            "chapter": parseInt($(this).find(".chapter").text()),
            "subjectID": 0
        })
    })
    return JSON.stringify(topics)
}

function saveTopics() {
    var url = "/api/subjects/" + subjectID() + "/topics";

    try {
        fetch(url, {
            method: "PUT",
            headers: {
                "Accept": "application/json, text/plain, */*",
                "Content-Type" : "application/json"
            },
            body: jsonDataVTwo()
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
        .catch(function (error) {
            presentErrorMessage(error.message);
        });
    } catch(error) {
        presentErrorMessage(error.message);
    }
}

function subjectID() {
    let path = window.location.pathname;
    let subjectURI = "subjects/"

    return parseInt(path.substring(
        path.indexOf(subjectURI) + subjectURI.length, 
        path.lastIndexOf("/topics")
    ));
}

var numberOfAddedTopics = 0;

function addTopic() {
    let name = $("#create-topic-name").val();
    let numberOfTopics = $("#dragables > div").length;

    let url = "topics/row?name=" + name + "&subjectID=" + subjectID() + "&id=" + --numberOfAddedTopics + "&chapter=" + (numberOfTopics + 1)
    fetch(url).then(function (response) {
        if (response.ok) {
            return response.text();
        } else if (response.status == 400) {
            throw new Error("Sjekk at all nødvendig info er fylt ut");
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (html) {
        $("#dragables").append(html)
        $("#create-topic").modal("toggle");
        $("#create-topic-name").val("");
    })
}

function deleteTopic() {
    let id = $("#delete-topic-id").val();
    $("#dragables").find("#" + id).remove();
    $("#delete-topic").modal("toggle");
}

function saveChanges() {
    let id = $("#edit-topic-id").val();
    let name = $("#edit-topic-name").val();
    $("#dragables").find("#" + id).find(".topic-name").text(name);
    $("#edit-topic").modal("toggle");
    $("#edit-topic-name").val("")
}