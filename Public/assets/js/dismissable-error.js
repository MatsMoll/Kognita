function presentErrorMessage(errorMessage) {
    $("#submitButton").attr("disabled", false);
    $("#error-massage").text(errorMessage);
    if ($("#error-div").css("display") == "block") {
        $("#error-div").shake();
    } else {
        $("#error-div").fadeIn();
        $("#error-div").removeClass("d-none");
    }
}