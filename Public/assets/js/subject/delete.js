function deleteSubject(subjectID) {

    var xhr = new XMLHttpRequest();
    var url = "/api/subjects/" + subjectID
    xhr.open("DELETE", url, true);
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            window.location.href = "/subjects";
        }
    };
    xhr.send();
}