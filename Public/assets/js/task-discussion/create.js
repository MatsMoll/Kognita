function refreshPage(){
    window.location.reload();
} 

function createDiscussion() {

    var url = "/api/task-discussion";
    
    let description = $("#create-discussion-question").val();
    let taskID = parseInt($("#task-id").val());

    var data = JSON.stringify({
        "description": description,
        "taskID" : taskID
    });

    $("#create-discussion-question").val("");

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
            refreshPage()
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
}