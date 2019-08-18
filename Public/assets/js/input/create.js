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

function createInputChoise() {
    
    var topicId = parseInt($("#create-input-topic-id").val());

    var xhr = new XMLHttpRequest();

    let url = "/api/tasks/input";
    xhr.open("POST", url, true);

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
    var answerString = $("#create-input-answer").val()
    answerString = answerString.replace(".", "");
    answerString = answerString.replace(" ", "");
    answerString = answerString.replace(",", ".");
    var correctAnswer = parseFloat(answerString);
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
        console.log(data);
        xhr.send(data);
    } else {
        console.log("Not sending");
        console.log(question + ", " + difficulty + ", " + estimatedTime + ", " + correctAnswer + ", " + topicId);
        // FIXME: Present error (Reload with query argument?)
    }
}