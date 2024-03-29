function jsonData() {
    var subtopicId = parseInt($("#create-multiple-topic-id").val());

    var choises = [];

    $("input[name=choiseInput]").each(function() {
        choises.push({
            "choice" : $("label[for=" + this.id + "]").html(),
            "isCorrect" : this.checked,
        });
    })

    var descriptionValue = description.value();
    if (descriptionValue.length < 1) {
        descriptionValue = null;
    }
    var examID = parseInt($("#card-exam-id").val());
    var question = $("#create-multiple-question").val();
    var isMultipleSelect = $("#create-multiple-select").prop("checked");
    var isTestable = $("#create-multiple-testable").prop("checked");
    var solutionValue = solution.value();

    if (isNaN(examID)) {
        examID = null
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
    if (choises.filter(choise => choise.isCorrect).length < 1) {
        throw Error("Minst et alternativ må være markert som riktig. Dette kan gjøres ved å trykke på det riktige alternativet")
    }
    if (isTestable == null) {
        isTestable = false
    }

    return JSON.stringify({
        "isTestable" : isTestable,
        "examID" : examID,
        "subtopicId" : subtopicId,
        "description" : descriptionValue,
        "question" : question,
        "isMultipleSelect" : isMultipleSelect,
        "choises" : choises,
        "solution" : solutionValue,
        "resources": []
    });
}
