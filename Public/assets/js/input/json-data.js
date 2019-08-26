function jsonData() {

    var subtopicId = parseInt($("#create-input-topic-id").val());
    var description = null;
    if (!$('#create-input-description').summernote("isEmpty")) {
        description = $("#create-input-description").summernote("code");
    }
    var examPaperSemester = $("#create-input-exam-semester").val();
    var examPaperYear = parseInt($("#create-input-exam-year").val());
    var unit = $("#create-input-unit").val();
    var isExaminable = $("#create-input-examinable").prop("checked");
    var answerString = $("#create-input-answer").val()
    answerString = answerString.replace(".", "");
    answerString = answerString.replace(" ", "");
    answerString = answerString.replace(",", ".");
    var correctAnswer = parseFloat(answerString);
    var question = $("#create-input-question").val();
    var solution = null;
    if (!$('#create-input-solution').summernote("isEmpty")) {
        solution = $("#create-input-solution").summernote("code");
    }

    if (isNaN(subtopicId) && subtopicId < 1) {
        throw Error("Velg et tema");
    }
    if (question.length < 1) {
        throw Error("Du må skrive inn et spørsmål");
    }
    if (solution.length < 1) {
        throw Error("Du må skrive inn en løsning");
    }

    return JSON.stringify({
        "unit" : unit,
        "isExaminable" : isExaminable,
        "correctAnswer" : correctAnswer,
        "examPaperSemester" : examPaperSemester === "" ? null : examPaperSemester,
        "examPaperYear" : examPaperYear,
        "subtopicId" : subtopicId,
        "description" : description,
        "question" : question,
        "solution" : solution
    });
}