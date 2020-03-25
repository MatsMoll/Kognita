function fetchDiscussionResponses(discussionID) {
    let url = "/task-discussions/" + discussionID + "/responses"

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
        $("#disc-responses").html(html);
        $("#disc-responses").fadeIn();
        $("#disc-responses").removeClass("d-none");
        renderMarkdownNodesIn($("#disc-responses"));
    })
    .catch(function (error) {
        $("#submitButton").attr("disabled", false);
        $("#error-massage").text(error.message);
        $("#error-div").fadeIn();
        $("#error-div").removeClass("d-none");
    });
}

function fetchADiscussionResponse(button) {
    let currentResponse = creatediscussionresponse.value()
    let quote = $(button).siblings(".response").html();
    var markdownQuote = ""

    var leftovers = quote;
    let quoteStart = "<blockquote class=\"blockquote\">\n"
    var index = leftovers.indexOf(quoteStart);


    while (index != -1) {
        markdownQuote += leftovers.substring(0, index);
        let endIndex = leftovers.indexOf("</blockquote>");
        if (endIndex != -1) {
            markdownQuote += "> " + leftovers.substring(index + quoteStart.length, endIndex)
            leftovers = leftovers.substring(endIndex + "</blockquote>".length, leftovers.length);
        }
        index = leftovers.indexOf(quoteStart);
    }

    markdownQuote += leftovers;

    markdownQuote = "> " + markdownQuote.replace(/<p>/gi, "").replace(/<\/p>/gi, "").replace(/\n/g, "\n> ")

    if(currentResponse == "") {
        creatediscussionresponse.value(markdownQuote + "\n\n");
    } else {
        creatediscussionresponse.value(currentResponse + "\n\n" + markdownQuote + "\n\n");
    }
    moveCursorToEnd()
}


function moveCursorToEnd() {

    var cm = creatediscussionresponse.codemirror;
    var textlenght = creatediscussionresponse.value().length;
    cm.focus()
    cm.setCursor({line:textlenght, ch: textlenght});

  }