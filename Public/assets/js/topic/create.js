$("#create-topic-description").summernote({
    minHeight: 200,
    placeholder: "Skriv beskrivelse her",
    toolbar: [
        // [groupName, [list of button]]
        ['style', ['bold', 'italic', 'underline']],
        ['font', ['strikethrough', 'superscript', 'subscript']],
        ['para', ['ul', 'ol', 'paragraph']],
        ['insert', ['picture', 'link', 'hr']],
        ['misc', ['undo', 'redo', 'help']]
      ]
});

function createTopic() {
    
    var xhr = new XMLHttpRequest();
    var url = "/api/topics";
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            window.location.href = "/creator/dashboard"
        }
    };

    let path = window.location.pathname;
    let subjectURI = "subjects/"
    var subjectId = parseInt(path.substring(
        path.indexOf(subjectURI) + subjectURI.length, 
        path.lastIndexOf("/topics")
    ));
    var name = $("#create-topic-name").val();
    var description = null;
    if (!$('#create-topic-description').summernote("isEmpty")) {
        description = $("#create-topic-description").summernote("code");
    }
    var chapter = parseInt($("#create-topic-chapter").val());

    if (chapter && subjectId) {
        var data = JSON.stringify({
            "subjectId"     : subjectId,
            "name"          : name,
            "description"   : description,
            "chapter"       : chapter
        });
        xhr.send(data);
    }
}