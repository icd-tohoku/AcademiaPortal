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
    <h2 class="mdl-card__title-text">Registerd authors</h2>
    <div class="mdl-layout-spacer"></div>

        <button id="add-author-button" class="mdl-button mdl-js-ripple-effect mdl-js-button mdl-button--fab mdl-color--accent">
              <i class="material-icons">add</i>
            </button>
        
            
        
        
            <asp:Table class="acp-table mdl-data-table mdl-js-data-table mdl-shadow--2dp" ID="authorTable" runat="server">
                <asp:TableHeaderRow TableSection="TableHeader">
                    <asp:TableHeaderCell CssClass="mdl-data-table__cell--non-numeric">氏名</asp:TableHeaderCell>
                    <asp:TableHeaderCell CssClass="mdl-data-table__cell--non-numeric">NAME</asp:TableHeaderCell>
                </asp:TableHeaderRow>
            </asp:Table>
        



    <dialog id="add-author-dialog" class="mdl-dialog acp-wide-form">
        <h3 class="mdl-dialog__title">Add author</h3>
        <div class="mdl-dialog__content">
            <ul class="mdl-list">
                <li class="mdl-list__item">
                    <span class="mdl-list__item-primary-content">姓
                    </span>

                    <div class="mdl-list__item-secondary-action">
                        <div class="mdl-textfield mdl-js-textfield">
                            <asp:TextBox class="mdl-textfield__input" ID="ja_fimily" runat="server"></asp:TextBox>
                            <label class="mdl-textfield__label" for="ja_fimily">姓...</label>
                        </div>
                    </div>
                </li>
                <li class="mdl-list__item">
                    <span class="mdl-list__item-primary-content">名
                    </span>

                    <div class="mdl-list__item-secondary-action">
                        <div class="mdl-textfield mdl-js-textfield">
                            <asp:TextBox class="mdl-textfield__input" ID="ja_First" runat="server"></asp:TextBox>
                            <label class="mdl-textfield__label" for="ja_First">名...</label>
                        </div>
                    </div>
                </li>

                <li class="mdl-list__item">
                    <span class="mdl-list__item-primary-content">ふりがな
                    </span>

                    <div class="mdl-list__item-secondary-action">
                        <div class="mdl-textfield mdl-js-textfield">
                            <asp:TextBox class="mdl-textfield__input" ID="Hiragana" runat="server"></asp:TextBox>
                            <label class="mdl-textfield__label" for="ja_First">ふりがな...</label>
                        </div>
                    </div>
                </li>

                <li class="mdl-list__item">
                    <span class="mdl-list__item-primary-content">First Name
                    </span>

                    <div class="mdl-list__item-secondary-action">
                        <div class="mdl-textfield mdl-js-textfield">
                            <asp:TextBox class="mdl-textfield__input" ID="En_first" runat="server"></asp:TextBox>
                            <label class="mdl-textfield__label" for="En_first">First Name...</label>
                        </div>
                    </div>
                </li>
                <li class="mdl-list__item">
                    <span class="mdl-list__item-primary-content">Middle Name
                    </span>

                    <div class="mdl-list__item-secondary-action">
                        <div class="mdl-textfield mdl-js-textfield">
                            <asp:TextBox class="mdl-textfield__input" ID="En_middle" runat="server"></asp:TextBox>
                            <label class="mdl-textfield__label" for="En_middle">Middle Name...</label>
                        </div>
                    </div>
                </li>
                <li class="mdl-list__item">
                    <span class="mdl-list__item-primary-content">Family Name
                    </span>

                    <div class="mdl-list__item-secondary-action">
                        <div class="mdl-textfield mdl-js-textfield">
                            <asp:TextBox class="mdl-textfield__input" ID="En_family" runat="server"></asp:TextBox>
                            <label class="mdl-textfield__label" for="En_family">Family Name...</label>
                        </div>
                    </div>
                </li>
            </ul>
        </div>
        <div class="mdl-dialog__actions">
            <asp:Button CssClass="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" runat="server" ID="authorRegisterButton" Text="Register" OnClick="authorRegisterButton_Click"></asp:Button>
            <button id="add-author-cancel" type="button" class="mdl-button">Cancel</button>
        </div>
    </dialog>
</asp:Content>
