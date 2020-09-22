
function createDraft() {
    try {
        fetch("/api/notes", {
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
            fetchNote(parseInt(json));
        })
        .catch(function (error) {
            presentErrorMessage(error.message);
        });
    } catch(error) {
        presentErrorMessage(error.message);
    }
}

function fetchNote(id) {
    fetch("/tasks/" + id + "/overview", {
        method: "GET"
    })
    .then(function (response) {
        if (response.ok) {
            return response.text();
        } else if (response.status == 400) {
            throw new Error("Sjekk at all nødvendig info er fylt ut");
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (html) {
        if ($("#note-" + id).length == 0) {
            $("#notes").append(html);
            $("#lecture-note-modal").modal("toggle");
            resetCreateForm();
        } else {
            $("#note-update-modal").modal("toggle");
            $("#note-" + id).replaceWith(html);
            resetUpdateForm();
        }
    })
    .catch(function (error) {
        presentErrorMessage(error.message);
    });
}

function editJsonData() {
    let noteSession = $("#note-session").val();
    var subtopicId = parseInt($("#update-topic-id").val());
    var question = $("#update-question").val();
    var solutionValue = updatesolution.value();

    if (isNaN(subtopicId) || subtopicId < 1) {
        throw Error("Velg et tema");
    }
    if (question.length < 1) {
        throw Error("Du må skrive inn et spørsmål");
    }

    return JSON.stringify({
        "noteSession" : noteSession,
        "subtopicID" : subtopicId,
        "question" : question,
        "solution" : solutionValue
    });
}

function resetCreateForm() {
    $("#card-topic-id").val("");
    $("#card-question").val("");
    solution.value("");
}

function resetUpdateForm() {
    $("#update-topic-id").val("");
    $("#update-question").val("");
    updatesolution.value("");
}

function updateNote() {
    let noteID = parseInt($("#update-id").val());
    try {
        fetch("/api/notes/" + noteID, {
            method: "PUT",
            headers: {
                "Accept": "application/json, text/plain, */*",
                "Content-Type" : "application/json"
            },
            body: editJsonData()
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
            fetchNote(noteID);
        })
        .catch(function (error) {
            console.log("Error", error)
            presentErrorMessage(error.message);
        });
    } catch(error) {
        presentErrorMessage(error.message);
    }
}

function subjectID() {
    let path = window.location.pathname;
    let splitURI = "subjects/"
    return parseInt(path.substring(
        path.indexOf(splitURI) + splitURI.length, 
        path.lastIndexOf("/tasks/")
    ));
}