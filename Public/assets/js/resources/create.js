
function createResource() {
    let activeTab = document.querySelector("#create-resource-modal .tab-content .active")
    let resourceTabID = activeTab.getAttribute("id");
    let title = document.getElementById("resource-title").value;
    
    let connectedID = document.getElementById("resource-connect-id").value;
    let connectionType = document.getElementById("resource-connect-type").value;
    let inputName = document.getElementById("resource-input-name").value;
    let formName = document.getElementById("resource-form-name").value;

    var url = "/api/resources/"
    var jsonData;

    try {
        if (title.length == 0) {
            throw new Error("Ups! Mangler tittel");
        }
        if (resourceTabID == "article-rec") {
            url += "article"
            jsonData = articleData(title)
        } else if (resourceTabID == "video-rec") {
            url += "video"
            jsonData = videoData(title)
        } else if (resourceTabID == "book-rec") {
            url += "book"
            jsonData = bookData(title)
        } else {
            return
        }
    } catch (error) {
        console.log(error);
        $("#resource-form").addClass("was-validated");
    }

    fetch(url, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        },
        body: jsonData
    })
    .then(function (response) {
        if (response.ok) {
            $("#create-resource-modal").modal('hide');
            return response.json();
        } else if (response.status == 400) {
            throw new Error("Sjekk at all nødvendig info er fylt ut");
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (json) {
        console.log(json);
        if (isNaN(json)) {
            console.log("Not a number");
            return
        }
        if (inputName.length != 0 && formName.length != 0) {
            let form = document.getElementById(formName);
            var input = document.createElement("input");
            input.type = "hidden";
            input.name = inputName + "[]";
            input.value = json;
            form.appendChild(input);
        } else if (connectionType == "term") {
            connectTerm(connectedID, json);
        } else if (connectionType == "subtopic") {
            connectSubtopic(connectedID, json);
        }
    })
}

function videoData(title) {
    let url = document.getElementById("video-url").value;
    var duration = document.getElementById("video-duration").value;
    let creator = document.getElementById("video-creator").value;

    if (isNaN(duration)) {
        duration = null;
    }
    if (url.length == 0 || creator.length == 0) {
        throw Error("Ups! Mangeler noe data");
    }
    return JSON.stringify({
        "url": url,
        "creator": creator,
        "duration": duration,
        "title": title
    })
}

function bookData(title) {

}

function articleData(title) {
    let url = document.getElementById("article-url").value;
    let author = document.getElementById("article-author").value;

    if (url.length == 0 || author.length == 0) {
        throw new Error("Ups! Noe data mangler");
    }

    return JSON.stringify({
        "url": url,
        "author": author,
        "title": title
    })
}

function connectTerm(termID, resourceID) {
    let url = "/api/terms/" + termID + "/resources/" + resourceID;

    fetch(url, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        }
    })
    .then(function (response) {
        if (response.ok) {
            return
        } else if (response.status == 400) {
            throw new Error("Sjekk at all nødvendig info er fylt ut");
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (json) {
        console.log(json);
    })
}

function connectSubtopic(subtopicID, resourceID) {
    let url = "/api/subtopics/" + subtopicID + "/resources/" + resourceID;

    fetch(url, {
        method: "POST",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        }
    })
    .then(function (response) {
        if (response.ok) {
            return
        } else if (response.status == 400) {
            throw new Error("Sjekk at all nødvendig info er fylt ut");
        } else {
            throw new Error(response.statusText);
        }
    })
    .then(function (json) {
        console.log(json);
    })
}