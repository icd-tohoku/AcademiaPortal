function FieldLengthValidator(input_id, min_length, max_length, events) {
    this.min_length = (min_length == void 0) ? 1 : min_length;
    this.max_length = max_length;
    this.events = events || "change";
    this.input_id = input_id;
    this.field = $("#" + this.input_id);
    this.registerHandler();
}
FieldLengthValidator.prototype.validate = function () {
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
};
FieldLengthValidator.prototype.registerHandler = function () {
    this.field.on(this.events, this.validate.bind(this));
};

function FieldIntegerRangeValidator(input_id, min_value, max_value, events) {
    this.min_value = (min_value == void 0) ? 0 : min_value;
    this.max_value = max_value;
    this.events = events || "change";
    this.input_id = input_id;
    this.field = $("#" + this.input_id);
    this.registerHandler();
}

FieldIntegerRangeValidator.prototype.validate = function () {
    var result = false;
    var field_parent = this.field.parent();
    var field_error_lable = this.field.parent().find("span.mdl-textfield__error");
    var parsed_value = parseInt(this.field.val());
    if (isNaN(parsed_value) || parsed_value < this.min_value || parsed_value > this.max_value) {
        field_parent.addClass('is-invalid');
    } else {
        field_parent.removeClass('is-invalid');
        result = true;
    }
    return result;
};

FieldIntegerRangeValidator.prototype.registerHandler = function () {
    this.field.on(this.events, this.validate.bind(this));
};

function DropzoneValidator(input_id, min_file_count) {
    this.input_id = input_id;
    this.dropzone_container = $("#" + input_id);
    this.min_file_count = (min_file_count == void 0) ? 1 : min_file_count;
}

DropzoneValidator.prototype.validate = function () {
    var result = false;
    var dropzone = this.dropzone_container[0].dropzone;
    if (dropzone.getAcceptedFiles().length < this.min_file_count) {
        this.dropzone_container.addClass('is-invalid');
    } else {
        this.dropzone_container.removeClass('is-invalid');
        result = true;
    }
    return result;
};

function FormValidator() {
    this.validators = [];
}
FormValidator.prototype.add = function (validator) {
    this.validators.push(validator);
};
FormValidator.prototype.validate = function () {
    var result = true;
    for (var i = 0; i < this.validators.length; i++) {
        result &= this.validators[i].validate();
    }
    return result;
};
FormValidator.prototype.validateAndGetFirstError = function () {
    var first_invalid_field = null;
    for (var i = 0; i < this.validators.length; i++) {
        if (!this.validators[i].validate() && first_invalid_field == void 0) {
            first_invalid_field = this.validators[i];
        }
    }
    return first_invalid_field;
};


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


function switchTab(tab_id) {
    $("a.mdl-tabs__tab").removeClass("is-active");
    $("a[href='#" + tab_id + "']").addClass("is-active");
    $(".mdl-tabs__panel").removeClass("is-active");
    $("#" + tab_id).addClass("is-active");
}