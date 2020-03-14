function renderKatex(plainText) {
    var output = "";
    var leftovers = plainText;
    var index = leftovers.indexOf("$$");
    while (index != -1) {
        output += leftovers.substring(0, index);
        leftovers = leftovers.substring(index + 2, leftovers.length);
        let endIndex = leftovers.indexOf("$$");
        if (endIndex != -1) {
            let katexSubstring = new DOMParser().parseFromString(leftovers.substring(0, endIndex), "text/html").documentElement.textContent;
            output += katex.renderToString(katexSubstring);
            leftovers = leftovers.substring(endIndex + 2, leftovers.length);
        } else {
            output += "$$";
        }
        index = leftovers.indexOf("$$");
    }
    return output + leftovers;
}

function renderMarkdown(markdown) {
    return marked(renderKatex(markdown));
}

$(".render-markdown").each(function () {
    this.innerHTML = renderMarkdown(this.innerHTML);
});