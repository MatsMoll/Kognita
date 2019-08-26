function jsonData() {
    var subtopicId = parseInt($("#create-multiple-topic-id").val());

    var choises = [];

    $("#create-multiple-choises").children().each(function() {
        choises.push({
            "choise" : $(this).children(":nth-child(1)").html(),
            "isCorrect" : $(this).find("input[type=checkbox]").prop("checked"),
        });
    })

    var description = null;
    if (!$('#create-multiple-description').summernote("isEmpty")) {
        description = $("#create-multiple-description").summernote("code");
    }
    var examPaperSemester = $("#create-multiple-exam-semester").val();
    var examPaperYear = parseInt($("#create-multiple-exam-year").val());
    var question = $("#create-multiple-question").val();
    var isMultipleSelect = $("#create-multiple-select").prop("checked");
    var isExaminable = $("#create-multiple-examinable").prop("checked");
    var solution = null;
    if (!$('#create-multiple-solution').summernote("isEmpty")) {
        solution = $("#create-multiple-solution").summernote("code");
    }

    if (isNaN(subtopicId) || subtopicId < 1) {
        throw Error("Velg et tema");
    }
    if (question.length <= 1) {
        throw Error("Du må skrive inn et spørsmål");
    }
    if (solution.length <= 1) {
        throw Error("Du må skrive inn en løsning");
    }
    if (choises.length <= 1) {
        throw Error("Lag to eller flere alternativer");
    }

    return JSON.stringify({
        "isExaminable" : isExaminable,
        "examPaperSemester" : examPaperSemester === "" ? null : examPaperSemester,
        "examPaperYear" : examPaperYear,
        "subtopicId" : subtopicId,
        "description" : description,
        "question" : question,
        "isMultipleSelect" : isMultipleSelect,
        "choises" : choises,
        "solution" : solution
    });
}