$("#card-description").summernote({
    minHeight : 200,
    toolbar: [
        // [groupName, [list of button]]
        ['style', ['bold', 'italic', 'underline']],
        ['font', ['strikethrough', 'superscript', 'subscript']],
        ['color', ['color']],
        ['para', ['ul', 'ol', 'paragraph', 'style']],
        ['insert', ['picture', 'link', 'video', 'table', 'hr', 'math']],
        ['misc', ['undo', 'redo', 'fullscreen', 'help']]
      ]
});

$("#card-solution").summernote({
    minHeight : 100,
    toolbar: [
        // [groupName, [list of button]]
        ['style', ['bold', 'italic', 'underline']],
        ['font', ['strikethrough', 'superscript', 'subscript']],
        ['color', ['color']],
        ['para', ['ul', 'ol', 'paragraph', 'style']],
        ['insert', ['picture', 'link', 'video', 'table', 'hr', 'math']],
        ['misc', ['undo', 'redo', 'fullscreen', 'help']]
      ]
});

function editFlashCard() {

    var path = window.location.pathname;
    var subjectURI = "flash-card/";

    var taskId = parseInt(path.substring(
        path.indexOf(subjectURI) + subjectURI.length, 
        path.lastIndexOf("/edit")
    ));

    try {
        fetch("/api/tasks/flash-card/" + taskId, {
            method: "PUT",
            headers: {
                "Accept": "application/json, text/plain, */*",
                "Content-Type" : "application/json"
            },
            body: jsonData()
        })
        .then(function (response) {
            if (response.ok) {
                return response.json();
            } else if (response.status == 400) {
                throw new Error("Sjekk at all nødvendig info er fylt ut");
            } else {
                throw new Error(response.statusText);
            }
        })
        .then(function (json) {
            window.location.href = "/tasks/flash-card/" + json.id;
        })
        .catch(function (error) {
            presentErrorMessage(error.message);
        });
    } catch(error) {
        presentErrorMessage(error.message);
    }
}