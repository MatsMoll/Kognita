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

function editTopic(id) {
    
    var xhr = new XMLHttpRequest();
    var url = "/api/topics/" + id;
    xhr.open("PUT", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            window.location.reload();
        }
    };

    var name = $("#create-topic-name").val();
    var description = null;
    if (!$('#create-topic-description').summernote("isEmpty")) {
        description = $("#create-topic-description").summernote("code");
    }
    var chapter = parseInt($("#create-topic-chapter").val());

    if (chapter) {
        var data = JSON.stringify({
            "name"          : name,
            "description"   : description,
            "chapter"       : chapter,
        });
        xhr.send(data);
    } else {
        console.log("Error");
    }
}