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
        ['custom', ['math']],
        ['para', ['style']],
      ]
})

function createMultipleChoise() {
    
    var topicId = parseInt($("#create-multiple-topic-id").val());

    var xhr = new XMLHttpRequest();
    console.log($("#edit-task"));
    if ($("#edit-task") == null) {
        let url = "/api" + window.location.pathname.replace("creator/", "") + "/topics/" + topicId + "/tasks/multiple-choise";
        xhr.open("POST", url, true);
        console.log("POST");
    } else {
        let url = "/api" + window.location.pathname.replace("creator/", "");
        xhr.open("PUT", url, true);
        console.log("PUT");
    }
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            var data = JSON.parse(this.responseText);
            if (window.location.pathname.includes("multiple-choise")) {
                window.location.href = data["taskId"];
            } else {
                window.location.href = window.location.pathname + "/topics/" + topicId + "/tasks/multiple-choise/" + data["taskId"];
            }
        }
    };

    var description = null;
    if (!$('#create-multiple-description').summernote("isEmpty")) {
        description = $("#create-multiple-description").summernote("code");
    }
    var question = $("#create-multiple-question").val();
    var difficulty = parseInt($("#create-multiple-difficulty").val());
    var estimatedTime = parseInt($("#create-multiple-estimated-time").val());
    var isMultipleSelect = $("#create-multiple-select").prop("checked");
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

    if (question && difficulty && estimatedTime && choises.length > 1) {
        
        xhr.send(data);
        var data = JSON.stringify({
            "difficulty" : difficulty,
            "estimatedTime" : estimatedTime,
            "description" : description,
            "question" : question,
            "isMultipleSelect" : isMultipleSelect,
            "choises" : choises,
            "solution" : solution
        });
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