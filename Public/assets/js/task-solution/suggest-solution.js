function suggestSolution() {

    let url = "/api/task-solutions"

    fetch(url, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        },
        body: jsonData()
    })
    .then(function (response) {
        if (response.ok) {
            $("#create-alternative-solution").modal("hide");
            fetchSolutions();
            suggestedsolution.value();
        } else {
            console.log("Error: ", response.statusText);
        }
    })
}

function jsonData() {
    let solution = suggestedsolution.value()
    let taskID = parseInt($("#task-id").val());
    let presentUser = $("#present-user").prop("checked");

    if (isNaN(taskID) || taskID < 1) {
        throw Error("Ups! En feil oppstod, men dette er ikke din feil! Prøv igjen eller kontakt oss")
    }
    if (solution.lenght < 1) {
        throw Error("Mangler løsningsforslt");
    }

    return JSON.stringify({
        "solution" : solution,
        "taskID" : taskID,
        "presentUser" : presentUser
    })
}

// setTimeout(function () {
//     suggestedsolution.codemirror.on("change", function(){
//         let parser = new DOMParser(); let htmlDoc = parser.parseFromString(renderMarkdown(suggestedsolution.value()), 'text/html');
//         let hrefs = new Set(Array.from(htmlDoc.getElementsByTagName("a")).map(x => x.getAttribute("href"))); let imgs = new Set(Array.from(htmlDoc.getElementsByTagName("img")).map(x => x.getAttribute("src"))); let lists = Array.from(htmlDoc.getElementsByTagName("li")); let text = htmlDoc.getElementsByTagName("body")[0].innerText.split(/\s+/)
//         var totalPoints = 0; totalPoints += Math.min(hrefs.size * 3, 4); totalPoints += Math.min(imgs.size * 2, 3); totalPoints += Math.min(lists.length, 1); totalPoints += (text.length < 150 && text.length > 60) ? 3 : 0;
//         // Lengde på text, punkt liste, bilde, kilder
//         console.log(text.length);
//         $("#solution-rating").text(totalPoints)
//         if (totalPoints >= 6) {
//             $("#solution-guide").addClass("text-success"); $("#solution-guide").removeClass("text-danger"); $("#solution-guide").removeClass("text-warning");
//         } else if (totalPoints >= 3) {
//             $("#solution-guide").addClass("text-warning"); $("#solution-guide").removeClass("text-danger"); $("#solution-guide").removeClass("text-success");
//         } else {
//             $("#solution-guide").addClass("text-danger"); $("#solution-guide").removeClass("text-warning"); $("#solution-guide").removeClass("text-success");
//         }
//     });
// }, 300)