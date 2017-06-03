function FieldLengthValidator(field_id, min_length, max_length, events) {
    this.min_length = (min_length == void 0) ? 1 : min_length;
    this.max_length = max_length;
    this.events = events || "change";
    this.field_id = field_id;
    this.field = $("#" + this.field_id);
    this.registerHandler();
}
FieldLengthValidator.prototype.validate = function () {
    if (this.min_length == void 0) this.min_length = 1;
    var result = false;
    var field_parent = this.field.parent();
    var field_error_lable = this.field.parent().find("span.mdl-textfield__error");
    if (this.field.val().length < this.min_length) {
        field_parent.addClass('is-invalid');
        field_error_lable.text("Required Field");
    } else if (this.max_length && this.field.val().length > this.max_length) {
        field_parent.addClass('is-invalid');
        field_error_lable.text("Too Long");
    } else {
        field_parent.removeClass('is-invalid');
        result = true;
    }
    return result;
}
FieldLengthValidator.prototype.registerHandler = function () {
    this.field.on(this.events, this.validate.bind(this));
}

function FormValidator() {
    this.validators = [];
}
FormValidator.prototype.add = function (validator) {
    this.validators.push(validator);
}
FormValidator.prototype.validate = function () {
    var result = true;
    for (var i = 0; i < this.validators.length; i++) {
        result &= this.validators[i].validate();
    }
    return result;
}


function getAuthorName_En(author) {
    return [author.firstName_En, author.middleName_En, author.familyName_En].filter(function (s) { return s; }).join(" ");
}
function getAuthorName_Ja(author) {
    return [author.familyName_Ja, author.firstName_Ja].filter(function (s) { return s; }).join(" ");
}
function getAuthorName(author) {
    var name_ja = getAuthorName_Ja(author);
    if (name_ja.length > 0) {
        return name_ja;
    }
    return getAuthorName_En(author);
}
function getAuthorDescription(author) {
    return author.email.length > 0 ?
        author.hiragana + "<" + author.email + ">" :
        author.hiragana;
}
function getAuthorsText(paper) {
    var authorNames = [];
    for (var i = 0; i < paper.authorIDs.length; i++) {
        var author = authorsByID[paper.authorIDs[i]];
        authorNames.push(getAuthorName_En(author));
    }
    return authorNames.join(", ");
}

function getPublishDateText(paper) {
    var d = new Date(paper.publishDate);
    return d.getUTCFullYear() + "年" + (d.getUTCMonth() + 1) + "月";
}
