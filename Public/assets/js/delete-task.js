function deleteTask(id) {
    var xhr = new XMLHttpRequest();
    let typePath = $("#" + id).val();
    let url = "/api/" + typePath + "/" + id;
    xhr.open("DELETE", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            window.location.reload();
        }
    };
    xhr.send();
}