function renderKatex(plainText) {
    var output = "";
    var leftovers = plainText;
    var index = leftovers.indexOf("$$");
    while (index != -1) {
        output += leftovers.substring(0, index);
        leftovers = leftovers.substring(index + 2, leftovers.length);
        let endIndex = leftovers.indexOf("$$");
        try {
            if (endIndex != -1) {
                let katexSubstring = new DOMParser().parseFromString(leftovers.substring(0, endIndex), "text/html").documentElement.textContent;
                
                    output += katex.renderToString(katexSubstring);
                    leftovers = leftovers.substring(endIndex + 2, leftovers.length);
            } else {
                output += "$$";
            }
            index = leftovers.indexOf("$$");
        } catch (error) {
            index = leftovers.indexOf("$$");
            if (endIndex != -1) {
                output += "<span class='text-warning'>" + leftovers.substring(0, endIndex) + "<br/></span><span class='text-danger'>" + error + "</span><br/>"
                leftovers = leftovers.substring(endIndex + 2, leftovers.length);
            } else {
                output += "<span class='text-warning'>" + leftovers + "</span><span class='text-danger'>" + error + "</span>"
            }
        }
    }
    return output + leftovers;
}

function renderMarkdown(markdown) {
    let stringMarkdown = String(markdown).replace(/&gt;+/g, '>')
    let html = marked(renderKatex(stringMarkdown));
    let parser = new DOMParser()
    let document = parser.parseFromString(html, "text/html")
    Array.from(document.getElementsByTagName("a")).map(x => x.setAttribute("target", "_blank"))
    Array.from(document.getElementsByTagName("img")).map(x => x.setAttribute("style", "max-width:100%"))
    Array.from(document.getElementsByTagName("table")).map(x => x.setAttribute("style", "width:100%"))
    Array.from(document.getElementsByTagName("td")).map(x => x.setAttribute("class", "px-1"))
    Array.from(document.getElementsByTagName("blockquote")).map(x => x.setAttribute("class", "blockquote"))
    Array.from(document.getElementsByTagName("pre")).map(x => x.setAttribute("style", "line-height: 90%;"))
    return document.getElementsByTagName("body")[0].innerHTML
}

function renderMarkdownNodesIn(document) {
    $(document).find(".render-markdown").each(function () {
        this.innerHTML = renderMarkdown(this.innerHTML);
    });
}

renderMarkdownNodesIn(document);