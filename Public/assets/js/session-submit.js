function submitSession() {

    var xhr = new XMLHttpRequest();
    xhr.open("POST", "submit", true);
    xhr.onreadystatechange = function () {
        if (this.readyState != 4) return;
    
        if (this.status == 200) {
            window.location.href = "/results";
        }
    };
    xhr.send();
}