function fetchDiscussions(taskID) {
    let url = "/tasks/" + taskID + "/discussions"

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
        $("#discussions").html(html);
        $("#discussions").fadeIn();
        $("#discussions").removeClass("d-none");
        $("#discussion-modal").modal('hide');
    })
    .catch(function (error) {
        $("#submitButton").attr("disabled", false);
        $("#error-massage").text(error.message);
        $("#error-div").fadeIn();
        $("#error-div").removeClass("d-none");
    });
}