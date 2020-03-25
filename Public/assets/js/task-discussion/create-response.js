function taskDiscussionResponseData() {

    let response = creatediscussionresponse.value();
    let discussionID = parseInt($("#disc-id").val());

    if(response.length < 4) {
        throw Error("Lengden av svaret er for liten")
    }
      
    return JSON.stringify({
        "response": response,
        "discussionID" : discussionID
    });
}

function createResponse() {
    try {
        var url = "/api/task-discussion-response";
        
        let discussionID = parseInt($("#disc-id").val());

        fetch(url, {
            method: "POST",
            headers: {
                "Accept": "application/json, text/plain, */*",
                "Content-Type" : "application/json"
            },
            body: taskDiscussionResponseData()
        })
        .then(function (response) {
            if (response.ok) {
                fetchDiscussionResponses(discussionID);
                creatediscussionresponse.value("")
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
    } catch(error) {
        $("#submitButton").attr("disabled", false);
        $("#error-massage").text(error.message);
        $("#error-div").fadeIn();
        $("#error-div").removeClass("d-none");
    }
}