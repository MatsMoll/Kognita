function jsonData() {

    let title = $("#create-test-title").val();
    let duration = parseInt($("#create-test-duration").val());
    let password = $("#create-test-password").val();
    let tasks = $("#create-test-tasks").val().map(value => parseInt(value));
    let subjectID = parseSubjectID();

    // Need the .split in order to make it work with the server
    let scheduledAt = new Date($("#create-test-scheduled-at").val());
    let scheduledAtISO = scheduledAt.toISOString().split('.')[0]+"Z";

    if (isNaN(subjectID) || subjectID < 1) {
        throw Error("Ups! Det oppstod et problem, men dette er ikke din feil. Prøv å last inn siden på nytt eller kontakt oss");
    }
    if (title.length <= 1) {
        throw Error("Du må ha en tittel");
    }
    if (isNaN(duration) || duration < 1) {
        throw Error("Du må definere en varighet på testen");
    }
    if (tasks.length < 1) {
        throw Error("Du må ha med minst en oppgave");
    }
    if (password.length < 1) {
        throw Error("Du må skrive inn et passord");
    }

    let data = JSON.stringify({
        "title" : title,
        "duration" : duration * 60, // Transforming from minutes to seconds
        "tasks" : tasks,
        "subjectID" : subjectID,
        "password" : password,
        "scheduledAt" : scheduledAtISO
    });

    return data;
}

function parseSubjectID() {

    let subjectID = parseInt($("#subject-id").val());

    if (isNaN(subjectID) || subjectID < 1) {
        let path = window.location.pathname;
        let splitURI = "subjects/";
        return parseInt(path.substring(
            path.indexOf(splitURI) + splitURI.length, 
            path.lastIndexOf("/subject-tests/")
        ));
    } else {
        return subjectID;
    }
}