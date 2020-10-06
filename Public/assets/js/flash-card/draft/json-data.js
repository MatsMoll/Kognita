function jsonData() {

    return new Promise(function (resolve, reject) {
        let noteSession = $("#note-session").val();

        var subtopicId = parseInt($("#card-topic-id").val());
        var question = $("#card-question").val();
        var solutionValue = solution.value();

        if (isNaN(subtopicId) || subtopicId < 1) {
            reject(Error("Velg et tema"));
        }
        if (question.length < 1) {
            reject(Error("Du må skrive inn et spørsmål"));
        }

        if (noteSession == "" || noteSession == null) {
            createSession().then(function (json) {
                resolve(JSON.stringify({
                    "noteSession" : json["id"],
                    "subtopicID" : subtopicId,
                    "question" : question,
                    "solution" : solutionValue
                }))
            })
        } else {
            resolve(JSON.stringify({
                "noteSession" : noteSession,
                "subtopicID" : subtopicId,
                "question" : question,
                "solution" : solutionValue
            }))
        }
    })
}