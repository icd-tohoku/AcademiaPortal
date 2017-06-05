<%@ Page Title="" Language="C#" MasterPageFile="~/AcademiaPortal.Master" AutoEventWireup="true" CodeBehind="VersionHistory.aspx.cs" Inherits="AcademiaPortal.VersionHistory" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="bower_components/showdown/compressed/showdown.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            $.ajax({
                url: "CHANGELOG.txt",
                dataType: "text",
                success: function (data) {
                    var converter = new Showdown.converter();
                    $("#changelog").html(converter.makeHtml(data));
                }
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="mdl-grid">
        <div id="changelog" class="mdl-cell mdl-cell--12-col"></div>
    </div>
</asp:Content>
