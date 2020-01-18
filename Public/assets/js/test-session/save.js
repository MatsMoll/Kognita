
function navigateTo(nextTaskID) {
    
    let testID = testSessionID();

    if (isNaN(testID)) {
        throw Error("Oi! En feil oppstod, men dette er ikke din feil");
    }

    let url = "/api/test-sessions/" + testID + "/save";

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
                window.location.href = nextTaskID;
            } else {
                throw new Error(response.statusText);
            }
        })
        .then(function (json) {
            handleSuccess(json);
        })
        .catch(function (error) {
            $("#submitButton").attr("disabled", false);
            $("#error-massage").text(error.message);
            $("#error-div").fadeIn();
            $("#error-div").removeClass("d-none");
        });
    } catch (error) {
        console.log(error);
        if (error.name == "MissingDataError") {
            window.location.href = nextTaskID;
        }
    }
}

function testSessionID() {
    let path = window.location.pathname;
    let splitURI = "test-sessions/";
    return parseInt(path.substring(
        path.indexOf(splitURI) + splitURI.length, 
        path.lastIndexOf("/tasks/")
    ));
}