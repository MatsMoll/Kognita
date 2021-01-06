function createSubjectData() {

    let name = $("#subject-name").val();
    let description = subjectdescription.value();
    if (description.lenght < 1) {
        description = null;
    }
    let category = $("#subject-category").val();
    let colorClass = $('input[name=color-class]:checked').attr('id');
    let code = $("#subject-code").val();

    return JSON.stringify({
        "name": name,
        "colorClass": colorClass,
        "description": description,
        "category": category,
        "code": code
    });
}