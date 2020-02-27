var isVoting = false;

function voteOnSolution(id) {

    if (isVoting) {
        return
    }
    isVoting = true;

    let uri = "/api/task-solutions/" + id + "/upvote";

    fetch(uri, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*"
        }
    })
    .then(function (response) {
        isVoting = false;
        if (response.ok) {
            $("#like-button").removeClass("mdi-heart-outline")
            $("#like-button").addClass("mdi-heart text-danger")
        } else if (response.status == 400) {
            throw new Error("Sjekk at all nødvendig info er fylt ut");
        } else {
            throw new Error(response.statusText);
        }
    })
    .catch(function (error) {
        $("#submitButton").attr("disabled", false);
        $("#error-massage").text(error.message);
        if ($("#error-div").css("display") == "block") {
            $("#error-div").shake();
        } else {
            $("#error-div").fadeIn();
            $("#error-div").removeClass("d-none");
        }
    });
}