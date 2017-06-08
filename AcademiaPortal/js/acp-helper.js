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

function FieldIntegerRangeValidator(input_id, min_value, max_value, toggle_id, events) {
    this.min_value = (min_value == void 0) ? 0 : min_value;
    this.max_value = max_value;
    this.toggle_id = toggle_id;
    this.events = events || "change";
    this.input_id = input_id;
    this.field = $("#" + this.input_id);
    this.registerHandler();
}

FieldIntegerRangeValidator.prototype.validate = function () {
    if (this.toggle_id && !$("#" + this.toggle_id).is(":checked")) {
        console.log("toggle is off");
        return true;
    }
    console.log("toggle is on");
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

function isForeignKatakanaName(name) {
    var filtered_name = name.replace(/[ａ-ｚa-z 　\.]/gi, "");
    var matched_katakana = filtered_name.match(/[\u30a0-\u30ff]/g);
    var katakana_occurence = matched_katakana ? matched_katakana.length : 0;
    return katakana_occurence === filtered_name.length;
}
function getAuthorName(author) {
    var name_ja = getAuthorName_Ja(author);
    if (name_ja.length > 0 && !isForeignKatakanaName(name_ja)) {
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
        authorNames.push(getAuthorName(author));
    }
    return authorNames.join(", ");
}

function getAuthorsText_En(paper) {
    var authorNames = [];
    for (var i = 0; i < paper.authorIDs.length; i++) {
        var author = authorsByID[paper.authorIDs[i]];
        authorNames.push(getAuthorName_En(author));
    }
    if (authorNames.length < 2) {
        return authorNames[0];
    }
    return authorNames.slice(0, -1).join(", ") + " and " + authorNames.slice(-1);
}

function getAuthorsText_Ja(paper) {
    var authorNames = [];
    for (var i = 0; i < paper.authorIDs.length; i++) {
        var author = authorsByID[paper.authorIDs[i]];
        authorNames.push(getAuthorName_Ja(author));
    }
    return authorNames.join(", ");
}

function getPublishDateText_Ja(paper) {
    var d = new Date(paper.publishDate);
    return d.getUTCFullYear() + "年" + (d.getUTCMonth() + 1) + "月";
}

var month_names_en = ["January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
];
function getPublishDateText_En(paper) {
    var d = new Date(paper.publishDate);
    return month_names_en[d.getUTCMonth()] + " " + d.getUTCFullYear();
}

function getPublicationText(paper) {
    var tokens = [];
    tokens.push(paper.publication);
    if (paper.volume) {
        tokens.push(paper.volume);
    }
    if (paper.page) {
        tokens.push(paper.page);
    }
    return tokens.join(", ");
}

function getPaperSummary(paper) {
    var tokens = [];
    var authors_text;
    var publish_date_text;
    if (paper.publicationCategory === 1 || paper.publicationCategory === 4) {
        authors_text = getAuthorsText_En(paper);
        publish_date_text = getPublishDateText_En(paper);
    } else {
        authors_text = getAuthorsText_Ja(paper);
        publish_date_text = getPublishDateText_Ja(paper);
    }
    tokens.push(authors_text);
    tokens.push(paper.title);
    tokens.push(getPublicationText(paper));
    tokens.push(publish_date_text);
    return tokens.join(", ") + ".";
}

function switchTab(tab_id) {
    $("a.mdl-tabs__tab").removeClass("is-active");
    $("a[href='#" + tab_id + "']").addClass("is-active");
    $(".mdl-tabs__panel").removeClass("is-active");
    $("#" + tab_id).addClass("is-active");
}

function arrayToHash(list, key_name, hash) {
    for (var i = 0; i < list.length; i++) {
        var element = list[i];
        hash[element[key_name]] = element;
    }
    return hash;
}

//WARNING: MaterialTextfield may not be upgraded inside $(document.ready())
function changeMaterialTextfieldValue(field_id, value) {
    console.log($("#" + field_id).parent()[0]);
    $("#" + field_id).parent()[0].MaterialTextfield.change(value);
}

function enableMaterialTextfield(field_id) {
    $("#" + field_id).parent()[0].MaterialTextfield.enable()
}
function disableMaterialTextfield(field_id) {
    $("#" + field_id).parent()[0].MaterialTextfield.disable()
}

function enableMaterialCheckbox(checkbox_id) {
    $("#" + checkbox_id).parent()[0].MaterialCheckbox.enable()
}
function disableMaterialCheckbox(checkbox_id) {
    $("#" + checkbox_id).parent()[0].MaterialCheckbox.disable()
}

function enableMaterialSelectfield(select_id) {
    $("#" + select_id).parent()[0].MaterialSelectfield.enable()
}
function disableMaterialSelectfield(select_id) {
    $("#" + select_id).parent()[0].MaterialSelectfield.disable()
}

function setMaterialCheckbox(checkbox_id, to_be_checked) {
    var checkbox = $("#" + checkbox_id).parent()[0].MaterialCheckbox;
    if (to_be_checked) {
        checkbox.check();
    } else {
        checkbox.uncheck();
    }
}

function setMaterialSelectfieldBeforeUpgrade(select_id, value) {
    var select = $("#" + select_id);
    select.val(value);
}
function setMaterialSelectfield(select_id, value) {
    var select = $("#" + select_id);
    select.val(value);
    select.parent()[0].MaterialSelectfield.refreshOptions();
}

function clearDropzone(dropzone_id) {
    var dropzone = $("#" + dropzone_id)[0].dropzone;
    dropzone.removeAllFiles();
}
function setDropzoneFile(dropzone_id, filename) {
    clearDropzone(dropzone_id);
    if (!filename) return;
    var dropzone_container = $("#" + dropzone_id);
    var dropzone = $("#" + dropzone_id)[0].dropzone;
    // Create the mock file:
    var mockFile = {
        name: filename,
        server_file_name: filename,
        size: 0, accepted: true
    };

    //hacky: the following action is not stated in Wiki
    dropzone.files.push(mockFile);
    // Call the default addedfile event handler
    dropzone.emit("addedfile", mockFile);

    //// And optionally show the thumbnail of the file:
    //dropzone.emit("thumbnail", mockFile, "/image/url");
    //// Or if the file on your server is not yet in the right
    //// size, you can let Dropzone download and resize it
    //// callback and crossOrigin are optional.
    //dropzone.createThumbnailFromUrl(file, imageUrl, callback, crossOrigin);

    // Make sure that there is no progress bar, etc...
    dropzone.emit("complete", mockFile);

    dropzone_container.find(".dz-size").first().css("visibility", "hidden");
}

function getDropzoneServerFileName(dropzone_id) {
    var accepted_files = $("#" + dropzone_id)[0].dropzone.getAcceptedFiles()
    if (accepted_files.length > 0) {
        return accepted_files[0].server_file_name;
    }
    return null;
}

function removeGuidFromFilePath(file_path) {
    safe_file_path = file_path.replace(/\//g, "-");
    if (safe_file_path.match(/[a-z0-9]{8}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{12}\-/i)) {
        return safe_file_path.slice(37);
    }
    return safe_file_path;
}