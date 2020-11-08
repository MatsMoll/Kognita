function jsonData() {
    var subtopicId = parseInt($("#card-topic-id").val());
    var examID = parseInt($("#card-exam-id").val());
    var descriptionValue = description.value();
    if (descriptionValue.length == 0) {
        descriptionValue = null;
    }
    var question = $("#card-question").val();
    var solutionValue = solution.value();

    if (isNaN(examID)) {
        examID = null
    }
    if (isNaN(subtopicId) || subtopicId < 1) {
        throw Error("Velg et tema");
    }
    if (question.length < 1) {
        throw Error("Du må skrive inn et spørsmål");
    }
    if (solution.length < 1) {
        throw Error("Du må skrive inn en løsning");
    }

    return JSON.stringify({
        "isTestable" : false,
        "examID" : examID,
        "subtopicId" : subtopicId,
        "description" : descriptionValue,
        "question" : question,
        "solution" : solutionValue
    });
}