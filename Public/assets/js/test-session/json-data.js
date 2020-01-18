class MissingDataError extends Error {
    constructor() {
        // Pass remaining arguments (including vendor specific ones) to parent constructor
        super()
        this.name = 'MissingDataError'
      }
}

function jsonData() {
    var selectedChoises = [];

    $("input:checkbox[name=choiseInput]:checked").each(function() {
        selectedChoises.push(parseInt(this.id));
    });

    $("input:radio[name=choiseInput]:checked").each(function() {
        selectedChoises.push(parseInt(this.id));
    });

    if (selectedChoises.length < 1) {
        throw new MissingDataError();
    }

    let taskID = testTaskID()

    if (isNaN(taskID) || taskID < 0) {
        throw Error("Oi! En feil oppstod, men dette er ikke din feil");
    }

    return JSON.stringify({
        "choises": selectedChoises,
        "taskIndex": taskID
    });
}

function testTaskID() {
    let path = window.location.pathname;
    let splitURI = "tasks/";
    return parseInt(path.substring(
        path.indexOf(splitURI) + splitURI.length, 
        path.length
    ));
}