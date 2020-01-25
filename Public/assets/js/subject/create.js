$("#create-subject-description").summernote({
    minHeight : 100,
    toolbar: [
        // [groupName, [list of button]]
        ['style', ['bold', 'italic', 'underline']],
        ['font', ['strikethrough', 'superscript', 'subscript']],
        ['para', ['ul', 'ol', 'paragraph']],
        ['insert', ['link', 'hr']],
        ['misc', ['undo', 'redo', 'help']]
      ]
});


function createSubject() {
    var url = "/api/subjects";

    var name = $("#create-subject-name").val();
    var description = null;
    if (!$('#create-subject-description').summernote("isEmpty")) {
        description = $("#create-subject-description").summernote("code");
    }
    var category = $("#create-subject-category").val();
    var colorClass = $('input[name=color-class]:checked').attr('id');

    var data = JSON.stringify({
        "name": name,
        "colorClass": colorClass,
        "description": description,
        "category": category,
    });

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
            window.location.href = "/subjects";
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
