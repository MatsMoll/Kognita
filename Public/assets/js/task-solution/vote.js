var isVoting = false;

function voteOnSolution(id, e) {

    if (isVoting) {
        return
    }
    isVoting = true;

    let hasVoted = $(e).find(".vote-button").hasClass("mdi-heart")
    var uri = "/api/task-solutions/" + id + "/upvote";
    if (hasVoted) {
        uri = "/api/task-solutions/" + id + "/revoke-vote";
    }

    fetch(uri, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*"
        }
    })
    .then(function (response) {
        isVoting = false;
        if (response.ok) {
            $(e).find(".vote-button").toggleClass("mdi-heart-outline")
            $(e).find(".vote-button").toggleClass("mdi-heart text-danger")
            var numberOfVotes = parseInt($("#solution-" + id).text())
            if (hasVoted) {
                $("#solution-" + id).text(numberOfVotes - 1)
            } else {
                $("#solution-" + id).text(numberOfVotes + 1)
            }
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