function createResponse() {

    var url = "/api/task-discussion-response";
    
    let response = $("#create-discussion-response").val();
    let discussionID = parseInt($("#disc-id").val());

    var data = JSON.stringify({
        "response": response,
        "discussionID" : discussionID
    });

    console.log(response)

    if (response.lenght < 1) {
        return
    }

    fetch(url, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        },
        body: data
    })
    .then(function (response) {
        if (response.ok) {
            return response.json();
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

    fetchDiscussionResponses(discussionID);
}