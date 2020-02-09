let descriptionEditor = editorForID("create-multiple-description");
let solutionEditor = editorForID("create-multiple-solution");
let choiseEditor = editorForID("create-multiple-choise"); 

var numberOfChoises = 1;

function addChoise() {
    var choise = choiseEditor.value();
    if (choise.length == 0) { return; }
    var table = $("#create-multiple-choises");
    table.append('<div id="choise--' + numberOfChoises + '" class="card shadow-none border mb-1"><div class="card-body"><div class="p-2 text-secondary"><div class="custom-control custom-radio"><input name="choiseInput" class="custom-control-input" id="' + numberOfChoises + '" type="radio"><label class="custom-control-label" for="' + numberOfChoises + '">' + choise + '</label><button type="button" onclick="deleteChoise(-' + numberOfChoises + ');" class="btn btn-danger btn-rounded float-right"><i class="mdi mdi-delete"></i></button></div></div></div></div>');
    numberOfChoises += 1;
    choiseEditor.value("");
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