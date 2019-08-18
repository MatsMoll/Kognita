$("#create-input-description").summernote({
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

$("#create-input-solution").summernote({
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

$("#create-input-choise").summernote({
    toolbar: [
        // [groupName, [list of button]]
        ['custom', ['math']],
        ['para', ['style']],
      ]
})

function editInputChoise() {
    
    var topicId = parseInt($("#create-input-topic-id").val());

    var xhr = new XMLHttpRequest();

    var path = window.location.pathname;
    var subjectURI = "input/";

    var taskId = parseInt(path.substring(
        path.indexOf(subjectURI) + subjectURI.length, 
        path.lastIndexOf("/edit")
    ));
    let url = "/api/tasks/input/" + taskId;
    xhr.open("PUT", url, true);

    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            var data = JSON.parse(this.responseText);
            window.location.href = "/tasks/input/" + data["task"]["id"];
        }
    };

    var description = null;
    if (!$('#create-input-description').summernote("isEmpty")) {
        description = $("#create-input-description").summernote("code");
    }
    var examPaperSemester = $("#create-input-exam-semester").val();
    var examPaperYear = parseInt($("#create-input-exam-year").val());
    var unit = $("#create-input-unit").val();
    var isExaminable = $("#create-input-examinable").prop("checked");
    var correctAnswer = parseFloat($("#create-input-answer").val());
    var question = $("#create-input-question").val();
    var solution = null;
    if (!$('#create-input-solution').summernote("isEmpty")) {
        solution = $("#create-input-solution").summernote("code");
    }

    if (question && correctAnswer) {
        
        var data = JSON.stringify({
            "unit" : unit,
            "isExaminable" : isExaminable,
            "correctAnswer" : correctAnswer,
            "examPaperSemester" : examPaperSemester === "" ? null : examPaperSemester,
            "examPaperYear" : examPaperYear,
            "topicId" : topicId,
            "difficulty" : 20,
            "estimatedTime" : 20,
            "description" : description,
            "question" : question,
            "solution" : solution
        });
        xhr.send(data);
    } else {
        console.log("Not sending");
        console.log(question + ", " + difficulty + ", " + estimatedTime + ", " + choises.length + ", " + subjectId);
        // FIXME: Present error (Reload with query argument?)
    }
}