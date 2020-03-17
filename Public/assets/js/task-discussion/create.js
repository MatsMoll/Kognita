
function taskDiscussionData() {
    let description = $("#create-discussion-question").val()
    //let description = creatediscussionquestion.value();
    let taskID = parseInt($("#task-id").val());

    if(description.length < 4) {
        throw Error("Lengden av diskusjonsspørsmålet er for lite")
    }

    $("#create-discussion-question").val()

    return JSON.stringify({
        "description": description,
        "taskID" : taskID
    });
}

function createDiscussion() {

    var url = "/api/task-discussion";
    let taskID = parseInt($("#task-id").val());

    try {
        fetch(url, {
            method: "POST",
            headers: {
                "Accept": "application/json, text/plain, */*",
                "Content-Type" : "application/json"
            },
            body: taskDiscussionData()
        })
        .then(function (response) {
            if (response.ok) {
                fetchDiscussions(taskID);
                presentControlls();
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
        $("#submitButton").attr("disabled", false);
        $("#error-massage").text(error.message);
        $("#error-div").fadeIn();
        $("#error-div").removeClass("d-none");
    }

    $("#create-discussion-question").val("")
}