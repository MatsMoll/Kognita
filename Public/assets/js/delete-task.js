function deleteTask(id, typePath) {
    
    let url = "/api/" + typePath + "/" + id;
    fetch(url, {
        method: "DELETE",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        }
    })
    .then(function (response) {
        if (response.ok) {
            search()
        } else if (response.status == 400) {
            throw new Error("Sjekk at all nødvendig info er fylt ut");
        } else {
            throw new Error(response.statusText);
        }
    });
}

function forceDelete(id, typePath) {
    let url = "/api/" + typePath + "/" + id + "/force";
    fetch(url, {
        method: "DELETE",
        headers: {
            "Accept": "application/json, text/plain, */*",
            "Content-Type" : "application/json"
        }
    })
    .then(function (response) {
        if (response.ok) {
            window.history.back();
        } else if (response.status == 400) {
            throw new Error("Sjekk at all nødvendig info er fylt ut");
        } else {
            throw new Error(response.statusText);
        }
    });
}