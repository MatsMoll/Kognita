
function createResource() {
    let activeTab = document.querySelector("#create-resource-modal .tab-content .active")
    let resourceTabID = activeTab.getAttribute("id");
    let title = document.getElementById("resource-title").value;
    
    let connectedID = document.getElementById("resource-connect-id").value;
    let connectionType = document.getElementById("resource-connect-type").value;

    var url = "/api/resources/"
    var jsonData;

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
        if (connectionType == "term") {
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