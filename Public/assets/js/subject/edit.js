$("#edit-subject-description").summernote({
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


function editSubject() {
    
    var xhr = new XMLHttpRequest();
    var url = "/api" + window.location.pathname.replace("creator/", "");
    xhr.open("PUT", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            window.location.reload();
        }
    };

    var name = $("#edit-subject-name").val();
    var description = null;
    if (!$('#edit-subject-description').summernote("isEmpty")) {
        description = $("#edit-subject-description").summernote("code");
    }
    var category = $("#create-subject-category").val();
    var colorClass = $("#create-subject-color-class").val();

    var data = JSON.stringify({
        "name": name,
        "colorClass": colorClass,
        "description": description,
        "category": category,
    });
    xhr.send(data);
}