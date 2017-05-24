<%@ Page Title="Add Author" Language="C#" MasterPageFile="~/AcademiaPortal.Master" AutoEventWireup="true" CodeBehind="AddAuthor.aspx.cs" Inherits="AcademiaPortal.AddAuthor" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            var add_author_dialog = $("#add-author-dialog")[0];
            if (!add_author_dialog.showModal) {
                dialogPolyfill.registerDialog(add_author_dialog);
            }
            $("#add-author-button").click(function () {
                add_author_dialog.showModal();
            });
            $("#add-author-cancel").click(function () {
                add_author_dialog.close();
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="acp-card-wide mdl-card mdl-shadow--2dp">
        <div class="mdl-card__title">
            <button type="button" id="add-author-button" class="mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect">
                Add
            </button>
        </div>
        <div class="acp-card__supporting-text mdl-card__supporting-text">
            <asp:Table class="acp-table mdl-data-table mdl-js-data-table mdl-shadow--2dp" ID="authorTable" runat="server">
                <asp:TableHeaderRow TableSection="TableHeader">
                    <asp:TableHeaderCell CssClass="mdl-data-table__cell--non-numeric">氏名</asp:TableHeaderCell>
                    <asp:TableHeaderCell CssClass="mdl-data-table__cell--non-numeric">NAME</asp:TableHeaderCell>
                </asp:TableHeaderRow>
            </asp:Table>

        </div>
    </div>
    <dialog id="add-author-dialog" class="acp-fit-form mdl-dialog">
        <h3 class="mdl-dialog__title">Add Author</h3>
        <div class="mdl-dialog__content">
            <div class="acp-constrained-grid mdl-grid">
                <div class="mdl-cell mdl-cell--6-col">
                    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                        <asp:TextBox class="mdl-textfield__input" ID="family_ja_input" runat="server"></asp:TextBox>
                        <label class="mdl-textfield__label" for="family_ja_input">姓</label>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--6-col">
                    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                        <asp:TextBox class="mdl-textfield__input" ID="first_ja_input" runat="server"></asp:TextBox>
                        <label class="mdl-textfield__label" for="first_ja_input">名</label>
                    </div>
                </div>
            </div>
            <div class="acp-constrained-grid mdl-grid">
                <div class="mdl-cell mdl-cell--12-col">
                    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                        <asp:TextBox class="mdl-textfield__input" ID="hiragana_ja_input" runat="server"></asp:TextBox>
                        <label class="mdl-textfield__label" for="hiragana_ja_input">ふりがな</label>
                    </div>
                </div>
            </div>
            <div class="acp-constrained-grid mdl-grid">
                <div class="mdl-cell mdl-cell--4-col">
                    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                        <asp:TextBox class="mdl-textfield__input" ID="family_en_input" runat="server"></asp:TextBox>
                        <label class="mdl-textfield__label" for="family_en_input">Family Name</label>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--4-col">
                    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                        <asp:TextBox class="mdl-textfield__input" ID="middle_en_input" runat="server"></asp:TextBox>
                        <label class="mdl-textfield__label" for="middle_en_input">Middle Name</label>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--4-col">
                    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                        <asp:TextBox class="mdl-textfield__input" ID="first_en_input" runat="server"></asp:TextBox>
                        <label class="mdl-textfield__label" for="first_en_input">First Name</label>
                    </div>
                </div>
            </div>
        </div>
        <div class="mdl-dialog__actions">
            <asp:Button CssClass="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" runat="server" ID="authorRegisterButton" Text="Register" OnClick="authorRegisterButton_Click"></asp:Button>
            <button id="add-author-cancel" type="button" class="mdl-button">Cancel</button>
        </div>
    </dialog>
</asp:Content>
