function jsonData() {
    var subtopicId = parseInt($("#create-multiple-topic-id").val());

    var choises = [];

    $("input[name=choiseInput]").each(function() {
        choises.push({
            "choise" : $("label[for=" + this.id + "]").html(),
            "isCorrect" : this.checked,
        });
    })

    var description = descriptionEditor.value();
    if (description.length < 1) {
        description = null;
    }
    var examPaperSemester = $("#create-multiple-exam-semester").val();
    var examPaperYear = parseInt($("#create-multiple-exam-year").val());
    var question = $("#create-multiple-question").val();
    var isMultipleSelect = $("#create-multiple-select").prop("checked");
    var isTestable = $("#create-multiple-testable").prop("checked");
    var solutionValue = solution.value();
    if (solutionValue.length < 1) {
        solutionValue = null;
    }

    if (isNaN(subtopicId) || subtopicId < 1) {
        throw Error("Velg et tema");
    }
    if (question.length <= 1) {
        throw Error("Du må skrive inn et spørsmål");
    }
    if (solutionValue.length <= 1) {
        throw Error("Du må skrive inn en løsning");
    }
    if (choises.length <= 1) {
        throw Error("Lag to eller flere alternativer");
    }

    return JSON.stringify({
        "isTestable" : isTestable,
        "examPaperSemester" : examPaperSemester === "" ? null : examPaperSemester,
        "examPaperYear" : examPaperYear,
        "subtopicId" : subtopicId,
        "description" : description,
        "question" : question,
        "isMultipleSelect" : isMultipleSelect,
        "choises" : choises,
        "solution" : solutionValue
    });
}