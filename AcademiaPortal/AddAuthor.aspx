<%@ Page Title="Add Author" Language="C#" MasterPageFile="~/AcademiaPortal.Master" AutoEventWireup="true" CodeBehind="AddAuthor.aspx.cs" Inherits="AcademiaPortal.AddAuthor" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
        function validateRequiredField(field) {
            var result = false;
            if (field.val().length > 0) {
                result = true;
                field.parent().removeClass('is-invalid');
            } else {
                field.parent().addClass('is-invalid');
            }
            return result;
        }
        function addToAuthorTable(table_body, author) {
            var row = $("<tr>");
            row.append($("<td>").text(author.familyName_Ja + author.firstName_Ja).addClass("mdl-data-table__cell--non-numeric"))
            row.append($("<td>").text([author.firstName_En, author.middleName_En, author.familyName_En].filter(function (s) { return s; }).join(" ")).addClass("mdl-data-table__cell--non-numeric"));
            table_body.append(row);
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
            $("#family_en_input").change(function () {
                validateRequiredField($("#family_en_input"));
            });
            $("#first_en_input").change(function () {
                validateRequiredField($("#first_en_input"));
            });
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
                }
            });
            $("#add_author_confirm").click(function () {
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
                    }
                });
            })
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="acp-card-wide mdl-card mdl-shadow--2dp">
        <div class="mdl-card__title">
            <button type="button" id="add_author_button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary">Add</button>
        </div>
        <div class="acp-card__supporting-text mdl-card__supporting-text">
            <table id="author_2_table" class="acp-table mdl-data-table mdl-js-data-table mdl-shadow--2dp">
                <thead>
                    <tr>
                        <th class="mdl-data-table__cell--non-numeric">氏名</th>
                        <th class="mdl-data-table__cell--non-numeric">Name</th>
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
