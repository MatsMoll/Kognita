function jsonData() {
    var subtopicId = parseInt($("#card-topic-id").val());
    var examPaperSemester = $("#card-exam-semester").val();
    var examPaperYear = parseInt($("#card-exam-year").val());
    var descriptionValue = description.value();
    if (description.length == 0) {
        descriptionValue = null;
    }
    var question = $("#card-question").val();
    var solutionValue = solution.value();
    if (solutionValue.length == 0) {
        solutionValue = null;
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
        "examPaperSemester" : examPaperSemester === "" ? null : examPaperSemester,
        "examPaperYear" : examPaperYear,
        "subtopicId" : subtopicId,
        "description" : descriptionValue,
        "question" : question,
        "solution" : solutionValue
    });
}