function refreshPage(){
    window.location.reload();
} 

function taskDiscussionData() {
    let description = creatediscussionquestion.value();
    let taskID = parseInt($("#task-id").val());

    if(description.length < 4) {
        throw Error("Lengden av diskusjonsspørsmålet er for lite")
    }

    return JSON.stringify({
        "description": description,
        "taskID" : taskID
    });
}

function createDiscussion() {

    var url = "/api/task-discussion";

    creatediscussionquestion.value("");

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
                refreshPage()
                presentControlls()
                pres
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
}