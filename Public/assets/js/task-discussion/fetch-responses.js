function fetchDiscussionResponses(discussionID) {
    let url = "/task-discussions/" + discussionID + "/responses"

    fetch(url, {
        method: "GET",
        headers: {
            "Accept": "application/html, text/plain, */*",
        }
    })
    .then(function (response) {
        if (response.ok) {
            return response.text();
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (html) {
        $("#disc-responses").html(html);
        $("#disc-responses").fadeIn();
        $("#disc-responses").removeClass("d-none");
    })
    .catch(function (error) {
        $("#submitButton").attr("disabled", false);
        $("#error-massage").text(error.message);
        $("#error-div").fadeIn();
        $("#error-div").removeClass("d-none");
    });
}