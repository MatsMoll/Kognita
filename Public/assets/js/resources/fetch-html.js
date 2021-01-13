function fetchResources(termID) {
    let url = "/terms/" + termID + "/resources";
    let resultID = "term-resources"
    $("#" + resultID).html('<div class="d-flex justify-content-center"><div class="spinner-border" role="status"></div></div>');
    fetch(url, {
        method: "GET",
        headers: {
            "Accept": "application/html, text/plain, */*",
        }
    })
    .then(function (response) {
        if (response.ok) {
            return response.text();
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (html) {
        $("#" + resultID).html(html);
        renderMarkdownNodesIn($("#" + resultID));
    })
    .catch(function (error) {
        console.log(error);
    });
}

function fetchTerm(termID) {
    let url = "/api/terms/" + termID;
    let resultID = "term-meaning"
    $("#" + resultID).html('<div class="d-flex justify-content-center"><div class="spinner-border" role="status"></div></div>');
    fetch(url, {
        method: "GET",
        headers: {
            "Accept": "application/html, text/plain, */*",
        }
    })
    .then(function (response) {
        if (response.ok) {
            return response.json();
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (term) {
        $("#" + resultID).html(term["meaning"]);
        renderMarkdownNodesIn($("#term-detail"));
    })
    .catch(function (error) {
        console.log(error);
    });
}