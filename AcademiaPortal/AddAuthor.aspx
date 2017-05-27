<%@ Page Title="Add Author" Language="C#" MasterPageFile="~/AcademiaPortal.Master" AutoEventWireup="true" CodeBehind="AddAuthor.aspx.cs" Inherits="AcademiaPortal.AddAuthor" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
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
            return [author.familyName_Ja, author.firstName_Ja].join(" ");
        }
        function addToAuthorTable(table_body, author) {
            var row = $("<tr>");
            var checkbox_id = "row[" + author.authorID + "]";
            var checkbox = $("<input>").addClass("mdl-checkbox__input").attr("type", "checkbox").attr("id", checkbox_id).attr("acp-primary-key", author.authorID);
            var checkbox_container = $("<label>").addClass("mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect mdl-data-table__select").attr("for", checkbox_id)
                .append(checkbox);
            checkbox.on('change', function (event) {
                var table = $("#author_2_table");
                var checkboxes = table.find('tbody .mdl-data-table__select');

                if (event.target.checked) {
                    for (var i = 0, length = checkboxes.length; i < length; i++) {
                        if (event.target.id != checkboxes[i].getAttribute('for')) {
                            checkboxes[i].MaterialCheckbox.uncheck();
                        }
                    }

                    var selected_id = parseInt(event.target.getAttribute("acp-primary-key"));

                    //find the selected author
                    for (var i = 0; i < authors.length; i++) {
                        if (authors[i].authorID === selected_id) {
                            selected_author = authors[i];
                            break;
                        }
                    }

                    $("#edit_author_button").prop("disabled", false);
                } else {
                    selected_author = null;
                    $("#edit_author_button").prop("disabled", true);
                }
            })
            componentHandler.upgradeElements(checkbox_container[0]);

            var checkbox_cell = $("<td>").append(checkbox_container);
            row.append(checkbox_cell);
            row.append($("<td>").text(getAuthorName_Ja(author)).addClass("mdl-data-table__cell--non-numeric").attr("acp-col-name", "name_ja"));
            row.append($("<td>").text(getAuthorName_En(author)).addClass("mdl-data-table__cell--non-numeric").attr("acp-col-name", "name_en"));
            row.append($("<td>").text(author.hiragana).addClass("mdl-data-table__cell--non-numeric").attr("acp-col-name", "hiragana"));
            table_body.append(row);
        }
        function updateAuthorTable(table_body, author) {
            var rows = table_body.find("tr");
            for (var i = 0; i < rows.length; i++) {
                var row = $(rows[i]);
                var row_primary_key = parseInt(row.find("label.mdl-data-table__select input.mdl-checkbox__input").attr("acp-primary-key"));
                if (row_primary_key === author.authorID) {
                    row.find("td[acp-col-name='name_ja']").text(getAuthorName_Ja(author));
                    row.find("td[acp-col-name='name_en']").text(getAuthorName_En(author));
                    row.find("td[acp-col-name='hiragana']").text(author.hiragana);
                    break;
                }
            }

        }
        function clearDialog() {
            $("#family_ja_input").parent()[0].MaterialTextfield.change("");
            $("#first_ja_input").parent()[0].MaterialTextfield.change("");
            $("#hiragana_ja_input").parent()[0].MaterialTextfield.change("");
            $("#family_en_input").parent()[0].MaterialTextfield.change("");
            $("#middle_en_input").parent()[0].MaterialTextfield.change("");
            $("#first_en_input").parent()[0].MaterialTextfield.change("");
        }
        function AddAuthor() {
            if (!form_validator.validate()) return;
            var author = {};
            author.familyName_En = $("#family_en_input").val();
            author.firstName_En = $("#first_en_input").val();
            author.middleName_En = $("#middle_en_input").val();
            author.familyName_Ja = $("#family_ja_input").val();
            author.firstName_Ja = $("#first_ja_input").val();
            author.hiragana = $("#hiragana_ja_input").val();
            console.log(author);
            $.ajax({
                type: "POST",
                url: "Author.asmx/AddAuthor",
                data: JSON.stringify({
                    author: author
                }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                },
                success: function (result) {
                    var author = result.d;
                    console.log(author);
                    authors.push(author)
                    addToAuthorTable($("#author_2_table").find("tbody"), author);
                    clearDialog();
                    author_dialog.close();
                    $("#author_snackbar")[0].MaterialSnackbar.showSnackbar({ message: "Author added." });
                }
            });
        }
        function UpdateAuthor() {
            if (!form_validator.validate()) return;
            selected_author.familyName_En = $("#family_en_input").val();
            selected_author.firstName_En = $("#first_en_input").val();
            selected_author.middleName_En = $("#middle_en_input").val();
            selected_author.familyName_Ja = $("#family_ja_input").val();
            selected_author.firstName_Ja = $("#first_ja_input").val();
            selected_author.hiragana = $("#hiragana_ja_input").val();
            console.log(selected_author);
            $.ajax({
                type: "POST",
                url: "Author.asmx/UpdateAuthor",
                data: JSON.stringify({
                    author: selected_author
                }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                },
                success: function (result) {
                    var author = result.d;
                    console.log(author);
                    clearDialog();
                    author_dialog.close();
                    // TODO: update the model selected_author
                    updateAuthorTable($("#author_2_table").find("tbody"), author);
                    $("#author_snackbar")[0].MaterialSnackbar.showSnackbar({ message: "Author updated." });
                }
            });
        }
        var authors = [];
        var selected_authors = null;
        var form_validator = new FormValidator();
        $(document).ready(function () {
            var author_dialog = $("#author_dialog")[0];
            if (!author_dialog.showModal) {
                dialogPolyfill.registerDialog(author_dialog);
            }
            $("#add_author_button").click(function () {
                var dialog = $("#author_dialog");
                dialog.find(".mdl-dialog__title").text("Add Author");
                $("#author_dialog_confirm").text("Add");
                dialog.attr("acp-author-action", "add");


                author_dialog.showModal();
            });
            $("#author_dialog_cancel").click(function () {
                author_dialog.close();
                if ($("#author_dialog").attr("acp-author-action") === "edit") {
                    clearDialog();
                }
            });
            $("#edit_author_button").click(function () {
                var dialog = $("#author_dialog");
                dialog.find(".mdl-dialog__title").text("Edit Author");
                $("#author_dialog_confirm").text("Update");
                dialog.attr("acp-author-action", "edit");


                $("#family_ja_input").parent()[0].MaterialTextfield.change(selected_author.familyName_Ja);
                $("#first_ja_input").parent()[0].MaterialTextfield.change(selected_author.firstName_Ja);
                $("#hiragana_ja_input").parent()[0].MaterialTextfield.change(selected_author.hiragana);
                $("#family_en_input").parent()[0].MaterialTextfield.change(selected_author.familyName_En);
                $("#middle_en_input").parent()[0].MaterialTextfield.change(selected_author.middleName_En);
                $("#first_en_input").parent()[0].MaterialTextfield.change(selected_author.firstName_En);
                author_dialog.showModal();
            })


            form_validator.add(new FieldLengthValidator("family_en_input"));
            form_validator.add(new FieldLengthValidator("first_en_input"));

            $.ajax({
                type: "POST",
                url: "Author.asmx/GetAuthors",
                data: null,
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                },
                success: function (result) {
                    var table_body = $("#author_2_table").find("tbody");
                    authors = result.d;
                    for (var i = 0; i < authors.length; i++) {
                        addToAuthorTable(table_body, authors[i])
                    }
                }
            });
            $("#author_dialog_confirm").on("click", function () {
                var action = $("#author_dialog").attr("acp-author-action");
                if (action === "add") {
                    AddAuthor();
                } else if (action === "edit") {
                    UpdateAuthor();
                }
            });

        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="author_snackbar" class="mdl-js-snackbar mdl-snackbar">
        <div class="mdl-snackbar__text"></div>
        <button class="mdl-snackbar__action" type="button"></button>
    </div>
    <div class="acp-card-wide mdl-card mdl-shadow--2dp">
        <div class="mdl-card__title acp-card__actions">
            <button type="button" id="add_author_button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary">Add</button>
            <button type="button" id="edit_author_button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary" disabled>Edit</button>
        </div>
        <div class="acp-card__supporting-text mdl-card__supporting-text">
            <table id="author_2_table" class="acp-table mdl-data-table mdl-shadow--2dp">
                <thead>
                    <tr>
                        <th></th>
                        <th class="mdl-data-table__cell--non-numeric">氏名</th>
                        <th class="mdl-data-table__cell--non-numeric">Name</th>
                        <th class="mdl-data-table__cell--non-numeric">ふりがな</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>

        </div>
    </div>
    <dialog id="author_dialog" class="acp-fit-form mdl-dialog">
        <h3 class="mdl-dialog__title"></h3>
        <div class="mdl-dialog__content">
            <div class="mdl-grid">
                <div class="mdl-cell mdl-cell--6-col">
                    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                        <input type="text" class="mdl-textfield__input" id="family_ja_input">
                        <label class="mdl-textfield__label" for="family_ja_input">姓</label>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--6-col">
                    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                        <input type="text" class="mdl-textfield__input" id="first_ja_input">
                        <label class="mdl-textfield__label" for="first_ja_input">名</label>
                    </div>
                </div>
            </div>
            <div class="mdl-grid">
                <div class="mdl-cell mdl-cell--12-col">
                    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                        <input type="text" class="mdl-textfield__input" id="hiragana_ja_input">
                        <label class="mdl-textfield__label" for="hiragana_ja_input">ふりがな</label>
                    </div>
                </div>
            </div>
            <div class="mdl-grid">
                <div class="mdl-cell mdl-cell--4-col">
                    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                        <input type="text" class="mdl-textfield__input" id="family_en_input">
                        <label class="mdl-textfield__label" for="family_en_input">Family Name *</label>
                        <span class="mdl-textfield__error">Required Field</span>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--4-col">
                    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                        <input type="text" class="mdl-textfield__input" id="middle_en_input">
                        <label class="mdl-textfield__label" for="middle_en_input">Middle Name</label>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--4-col">
                    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                        <input type="text" class="mdl-textfield__input" id="first_en_input">
                        <label class="mdl-textfield__label" for="first_en_input">First Name *</label>
                        <span class="mdl-textfield__error">Required Field</span>
                    </div>
                </div>
            </div>
            <p>* Required</p>
        </div>
        <div class="mdl-dialog__actions">
            <button id="author_dialog_confirm" type="button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary"></button>
            <button id="author_dialog_cancel" type="button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect">Cancel</button>
        </div>
    </dialog>
</asp:Content>
