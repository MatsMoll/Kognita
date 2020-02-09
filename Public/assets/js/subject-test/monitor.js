
fetchStatus();

var timer = setInterval(fetchStatus, 5000); // Each 5 seconds

function fetchStatus() {
    let url = "status";

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
        $("#user-status").html(html);
    });
}