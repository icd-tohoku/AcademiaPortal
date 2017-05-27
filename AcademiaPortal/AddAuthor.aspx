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
        function addToAuthorTable(table_body, author) {
            var row = $("<tr>");
            var checkbox_id = "row[" + author.authorID + "]";
            var checkbox = $("<label>").addClass("mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect mdl-data-table__select").attr("for", checkbox_id)
                .append($("<input>").addClass("mdl-checkbox__input").attr("type", "checkbox").attr("id", checkbox_id));
            componentHandler.upgradeElements(checkbox[0]);
            var checkbox_cell = $("<td>").append(checkbox);
            row.append(checkbox_cell);
            row.append($("<td>").text(author.authorID).addClass("acp-data-table__primary-key"));
            row.append($("<td>").text([author.familyName_Ja, author.firstName_Ja].join(" ")).addClass("mdl-data-table__cell--non-numeric"));
            row.append($("<td>").text([author.firstName_En, author.middleName_En, author.familyName_En].filter(function (s) { return s; }).join(" ")).addClass("mdl-data-table__cell--non-numeric"));
            row.append($("<td>").text(author.hiragana).addClass("mdl-data-table__cell--non-numeric"));
            table_body.append(row);
        }
        function clearInput(field_id) {
            var field = $("#" + field_id);
            field.parent().removeClass('is-invalid');
            field.parent().removeClass('is-dirty');
            field.val("");
        }
        function clearDialog() {
            clearInput("family_ja_input");
            clearInput("first_ja_input");
            clearInput("hiragana_ja_input");
            clearInput("family_en_input");
            clearInput("middle_en_input");
            clearInput("first_en_input");
        }
        $(document).ready(function () {
            var add_author_dialog = $("#add-author-dialog")[0];
            if (!add_author_dialog.showModal) {
                dialogPolyfill.registerDialog(add_author_dialog);
            }
            $("#add_author_button").click(function () {
                add_author_dialog.showModal();
            });
            $("#add_author_cancel").click(function () {
                add_author_dialog.close();
            });
            var form_validator = new FormValidator();
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
                    var authors = result.d;
                    for (var i = 0; i < authors.length; i++) {
                        addToAuthorTable(table_body, authors[i])
                    }
                    initializeTable();
                }
            });
            $("#add_author_confirm").click(function () {
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
                        console.log(result);
                        addToAuthorTable($("#author_2_table").find("tbody"), result.d);
                        clearDialog();
                        add_author_dialog.close();
                        console.log($("#author-snackbar"));
                        console.log($("#author-snackbar")[0]);
                        $("#author-snackbar")[0].MaterialSnackbar.showSnackbar({ message: "Author added." });
                    }
                });
            })
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="author-snackbar" class="mdl-js-snackbar mdl-snackbar">
        <div class="mdl-snackbar__text"></div>
        <button class="mdl-snackbar__action" type="button"></button>
    </div>
    <div class="acp-card-wide mdl-card mdl-shadow--2dp">
        <div class="mdl-card__title">
            <button type="button" id="add_author_button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary">Add</button>
        </div>
        <div class="acp-card__supporting-text mdl-card__supporting-text">
            <table id="author_2_table" class="acp-table mdl-data-table mdl-shadow--2dp">
                <thead>
                    <tr>
                        <th>
                            <label class="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect mdl-data-table__select" for="table-header">
                                <input type="checkbox" id="table-header" class="mdl-checkbox__input" />
                            </label>
                        </th>
                        <th class="acp-data-table__primary-key mdl-data-table__cell--non-numeric">id</th>
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
    <dialog id="add-author-dialog" class="acp-fit-form mdl-dialog">
        <h3 class="mdl-dialog__title">Add Author</h3>
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
            <button id="add_author_confirm" type="button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary">Add</button>
            <button id="add_author_cancel" type="button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect">Cancel</button>
        </div>
    </dialog>
</asp:Content>
