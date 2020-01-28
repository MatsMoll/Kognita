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
$("#create-multiple-choise").summernote("code", "");

var numberOfChoises = 1;

function addChoise() {
    if ($('#create-multiple-choise').summernote("isEmpty")) { return; }
    var choise = $('#create-multiple-choise').summernote("code");
    var table = $("#create-multiple-choises");
    table.append('<div id="choise--' + numberOfChoises + '" class="card shadow-none border mb-1"><div class="card-body"><div class="p-2 text-secondary"><div class="custom-control custom-radio"><input name="choiseInput" class="custom-control-input" id="' + numberOfChoises + '" type="radio"><label class="custom-control-label" for="' + numberOfChoises + '">' + choise + '</label><button type="button" onclick="deleteChoise(-' + numberOfChoises + ');" class="btn btn-danger btn-rounded float-right"><i class="mdi mdi-delete"></i></button></div></div></div></div>');
    numberOfChoises += 1;
    $("#create-multiple-choise").summernote("code", "");
}

function deleteChoise(choiseID) {
    $("#choise-" + choiseID).remove();
}

$("#create-multiple-select").change(function() {
    if(this.checked) {
        $("input[name=choiseInput]").each(function() {
            $(this).prop("type", "checkbox");
            $(this).parent().prop("class", "custom-control custom-checkbox");
        });
    } else {
        $("input[name=choiseInput]").each(function() {
            $(this).prop("type", "radio");
            $(this).parent().prop("class", "custom-control custom-radio");
        });
    }
});