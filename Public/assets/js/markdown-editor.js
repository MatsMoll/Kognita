function toolbar() {
    return [
        "bold",
        "italic",
        "heading",
        "|",
        "code",
        "quote",
        "unordered-list",
        "ordered-list",
        "|",
        "link",
        "image",
        {
            name: "LaTeX",
            action: function (editor) {
                var text = editor.value();
                text += "$$$$";
                editor.value(text);
                let cm = editor.codemirror;
                var startPoint = cm.getCursor('start');
                var endPoint = cm.getCursor('end');
                startPoint.ch += 2;
                endPoint.ch += 2;
                cm.setSelection(startPoint, endPoint);
                cm.focus();
            },
            className: "fa fa-calculator",
			title: "LaTeX",
        },
        "|",
        "preview",
        "guide"
    ]    
}

function editorForID(id) {
    return new SimpleMDE({ 
        element: document.getElementById(id),
        spellChecker: false,
        toolbar: toolbar(),
        previewRender: function(text) {
            return this.parent.markdown(renderKatex(text));
        }
    });
}