
function saveChoise() {
    let testID = testSessionID();
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
                return
            } else {
                throw new Error(response.statusText);
            }
        })
        .catch(function (error) {
            $("#submitButton").attr("disabled", false);
            $("#error-massage").text(error.message);
            $("#error-div").fadeIn();
            $("#error-div").removeClass("d-none");
        });
    } catch (error) {
        if (error.name == "MissingDataError") {
            return
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

$('input[name="choiseInput"]').click(function () {
    saveChoise();
});