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
    
    var xhr = new XMLHttpRequest();
    var url = "/api/subjects";
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            window.location.href = "/subjects";
        }
    };

    var name = $("#create-subject-name").val();
    var code = $("#create-subject-code").val();
    var description = null;
    if (!$('#create-subject-description').summernote("isEmpty")) {
        description = $("#create-subject-description").summernote("code");
    }
    var imageURL = $("#create-subject-image").val();

    var data = JSON.stringify({
        "name": name,
        "code": code,
        "description": description,
        "imageURL": imageURL,
    });
    xhr.send(data);
}