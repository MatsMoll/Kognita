$("#create-multiple-description").summernote({
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

$("#create-multiple-solution").summernote({
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

$("#create-multiple-choise").summernote({
    toolbar: [
        // [groupName, [list of button]]
        ['insert', ['picture', 'math']],
        ['para', ['style']],
      ]
})

function editMultipleChoise() {

    var path = window.location.pathname;
    var subjectURI = "multiple-choise/";

    var taskId = parseInt(path.substring(
        path.indexOf(subjectURI) + subjectURI.length, 
        path.lastIndexOf("/edit")
    ));

    let url = "/api/tasks/multiple-choise/" + taskId;

    try {
        fetch(url, {
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
            window.location.href = "/tasks/multiple-choise/" + json.task.id;
        })
        .catch(function (error) {
            presentErrorMessage(error.message);
        });
    } catch(error) {
        presentErrorMessage(error.message);
    }
}

var numberOfChoises = 0;

function addChoise() {
    if ($('#create-multiple-choise').summernote("isEmpty")) { return; }
    var choise = $('#create-multiple-choise').summernote("code");
    var table = $("#create-multiple-choises");
    table.append('<tr id="choise-' + numberOfChoises + '"><td>' + choise + '</td><td><input type="checkbox" id="switch' + numberOfChoises + '" data-switch="bool"/><label for="switch' + numberOfChoises + '" data-on-label="Ja" data-off-label="Nei"></label></td><td><button  type="button" class="btn btn-danger btn-rounded" onclick="deleteChoise(' + numberOfChoises + ');"><i class="mdi mdi-delete"></i></button></td></tr>');
    numberOfChoises += 1;
    $("#create-multiple-choise").val(null);
}

function deleteChoise(choiseID) {
    $("#choise-" + choiseID).remove();
}