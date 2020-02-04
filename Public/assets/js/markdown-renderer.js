function renderKatex(plainText) {
    var output = "";
    var leftovers = plainText;
    var index = leftovers.indexOf("$$");
    while (index != -1) {
        output += leftovers.substring(0, index);
        leftovers = leftovers.substring(index + 2, leftovers.length);
        let endIndex = leftovers.indexOf("$$");
        if (endIndex != -1) {
            output += katex.renderToString(leftovers.substring(0, endIndex));
            leftovers = leftovers.substring(endIndex + 2, leftovers.length);
        } else {
            output += "$$";
        }
        index = leftovers.indexOf("$$");
    }
    return output + leftovers;
}

function renderMarkdown(markdown) {
    console.log(markdown);
    if (markdown.startsWith("<") == false) {
        console.log(renderKatex(markdown));
        return marked(renderKatex(markdown));
    } else {
        return markdown;
    }
}