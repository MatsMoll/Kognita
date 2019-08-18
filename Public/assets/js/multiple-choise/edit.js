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
    
    var topicId = parseInt($("#create-multiple-topic-id").val());

    var path = window.location.pathname;
    var subjectURI = "multiple-choise/";

    var taskId = parseInt(path.substring(
        path.indexOf(subjectURI) + subjectURI.length, 
        path.lastIndexOf("/edit")
    ));

    var xhr = new XMLHttpRequest();
    let url = "/api/tasks/multiple-choise/" + taskId;
    xhr.open("PUT", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            var data = JSON.parse(this.responseText);
            window.location.href = "/creator/dashboard";
        }
    };

    var description = null;
    if (!$('#create-multiple-description').summernote("isEmpty")) {
        description = $("#create-multiple-description").summernote("code");
    }
    var examPaperSemester = $("#create-multiple-exam-semester").val();
    var examPaperYear = parseInt($("#create-multiple-exam-year").val());
    var question = $("#create-multiple-question").val();
    var isMultipleSelect = $("#create-multiple-select").prop("checked");
    var isExaminable = $("#create-multiple-examinable").prop("checked");
    var solution = null;
    if (!$('#create-multiple-solution').summernote("isEmpty")) {
        solution = $("#create-multiple-solution").summernote("code");
    }

    var choises = [];

    $("#create-multiple-choises").children().each(function() {
        choises.push({
            "choise" : $(this).children(":nth-child(1)").html(),
            "isCorrect" : $(this).find("input[type=checkbox]").prop("checked"),
        });
    })

    if (question && choises.length > 1) {
        
        var data = JSON.stringify({
            "isExaminable" : isExaminable,
            "examPaperSemester" : examPaperSemester === "" ? null : examPaperSemester,
            "examPaperYear" : examPaperYear,
            "topicId" : topicId,
            "difficulty" : 20,
            "estimatedTime" : 20,
            "description" : description,
            "question" : question,
            "isMultipleSelect" : isMultipleSelect,
            "choises" : choises,
            "solution" : solution
        });
        xhr.send(data);
    } else {
        console.log("Error");
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