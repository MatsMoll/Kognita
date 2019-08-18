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


function createFlashCard() {
    
    var topicId = parseInt($("#card-topic-id").val());

    var xhr = new XMLHttpRequest();

    let url = "/api/tasks/flash-card";
    xhr.open("POST", url, true);

    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            var data = JSON.parse(this.responseText);
            window.location.href = "/tasks/flash-card/" + data["id"];
        }
    };

    var description = null;
    if (!$('#card-description').summernote("isEmpty")) {
        description = $("#card-description").summernote("code");
    }
    var question = $("#card-question").val();
    var solution = null;
    if (!$('#card-solution').summernote("isEmpty")) {
        solution = $("#card-solution").summernote("code");
    }

    if (question && solution) {
        
        var data = JSON.stringify({
            "isExaminable" : false,
            "examPaperSemester" : null,
            "examPaperYear" : null,
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
        console.log(question + ", " + difficulty + ", " + estimatedTime + ", " + solution);
        // FIXME: Present error (Reload with query argument?)
    }
}