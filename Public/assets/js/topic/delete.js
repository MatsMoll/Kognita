function deleteTopic(id) {

    var xhr = new XMLHttpRequest();
    var url = "/api/topics/" + id;

    xhr.open("DELETE", url, true);
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            window.location.reload()
        }
    };

    xhr.send();
}