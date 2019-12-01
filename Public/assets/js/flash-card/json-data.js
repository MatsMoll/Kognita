function jsonData() {
    var subtopicId = parseInt($("#card-topic-id").val());
    var examPaperSemester = $("#card-exam-semester").val();
    var examPaperYear = parseInt($("#card-exam-year").val());
    var description = null;
    if (!$('#card-description').summernote("isEmpty")) {
        description = $("#card-description").summernote("code");
    }
    var question = $("#card-question").val();
    var solution = null;
    if (!$('#card-solution').summernote("isEmpty")) {
        solution = $("#card-solution").summernote("code");
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
        "isExaminable" : false,
        "examPaperSemester" : examPaperSemester === "" ? null : examPaperSemester,
        "examPaperYear" : examPaperYear,
        "subtopicId" : subtopicId,
        "description" : description,
        "question" : question,
        "solution" : solution
    });
}