function jsonData() {
    var subtopicId = parseInt($("#card-topic-id").val());
    var question = $("#card-question").val();
    var solutionValue = solution.value();

    if (isNaN(subtopicId) || subtopicId < 1) {
        throw Error("Velg et tema");
    }
    if (question.length < 1) {
        throw Error("Du må skrive inn et spørsmål");
    }

    return JSON.stringify({
        "subtopicID" : subtopicId,
        "question" : question,
        "solution" : solutionValue
    });
}