function endSession() {
    var path = window.location.pathname;
    var subjectURI = "practice-sessions/";

    var sessionID =  parseInt(path.substring(
        path.indexOf(subjectURI) + subjectURI.length, 
        path.lastIndexOf("/tasks")
    ));
    
    var xhr = new XMLHttpRequest();
    var url = "/api/practice-session/" + sessionID;
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return
        if (this.status == 200) {
            var response = JSON.parse(this.responseText);
            location.href = response["sessionResultPath"];
        }
    };
    xhr.send();
}