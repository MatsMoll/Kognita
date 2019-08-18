function redirectToMultiple() {
    var subjectID = parseInt($("#subject-selector").val());
    window.location.href = "/subjects/" + subjectID + "/task/multiple/create";
}