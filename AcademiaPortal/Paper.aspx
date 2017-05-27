<%@ Page Title="" Language="C#" MasterPageFile="~/AcademiaPortal.Master" AutoEventWireup="true" CodeBehind="Paper.aspx.cs" Inherits="AcademiaPortal.Paper" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
        function getPublishDateText(paper) {
            var d = new Date(paper.publishDate);
            return d.getUTCFullYear() + "年" + (d.getUTCMonth() + 1) + "月";
        }
        function getAuthorName_En(author) {
            return [author.firstName_En, author.middleName_En, author.familyName_En].filter(function (s) { return s; }).join(" ");
        }
        function getAuthorsText(paper) {
            var authorIDs = authorships[paper.paperID]
            var authorNames = [];
            for (var i = 0; i < authorIDs.length; i++) {
                var author = authorsByID[authorIDs[i]];
                authorNames.push(getAuthorName_En(author));
            }
            return authorNames.join(", ");
        }
        function addToPaperTable(table_body, paper) {
            var row = $("<tr>");
            var checkbox_id = "row[" + paper.paperID + "]";
            var checkbox = $("<input>").addClass("mdl-checkbox__input").attr("type", "checkbox").attr("id", checkbox_id).attr("acp-primary-key", paper.paperID);
            var checkbox_container = $("<label>").addClass("mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect mdl-data-table__select").attr("for", checkbox_id)
                .append(checkbox);
            checkbox.on('change', function (event) {
                var table = $("#paper_table");
                var checkboxes = table.find('tbody .mdl-data-table__select');

                if (event.target.checked) {
                    for (var i = 0, length = checkboxes.length; i < length; i++) {
                        if (event.target.id != checkboxes[i].getAttribute('for')) {
                            checkboxes[i].MaterialCheckbox.uncheck();
                        }
                    }

                    var selected_id = parseInt(event.target.getAttribute("acp-primary-key"));

                    //find the selected paper
                    for (var i = 0; i < papers.length; i++) {
                        if (papers[i].paperID === selected_id) {
                            selected_paper = papers[i];
                            break;
                        }
                    }

                    $("#edit_paper_button").prop("disabled", false);
                } else {
                    selected_paper = null;
                    $("#edit_paper_button").prop("disabled", true);
                }
            })
            componentHandler.upgradeElements(checkbox_container[0]);

            var checkbox_cell = $("<td>").append(checkbox_container);
            row.append(checkbox_cell);
            row.append($("<td>").text(paper.title).addClass("mdl-data-table__cell--non-numeric acp-data-table__cell--multiline").attr("acp-col-name", "title"));
            row.append($("<td>").text(getAuthorsText(paper)).addClass("mdl-data-table__cell--non-numeric acp-data-table__cell--multiline").attr("acp-col-name", "authors"));
            row.append($("<td>").text(paper.publication).addClass("mdl-data-table__cell--non-numeric acp-data-table__cell--multiline").attr("acp-col-name", "publication"));
            row.append($("<td>").text(getPublishDateText(paper)).addClass("mdl-data-table__cell--non-numeric").attr("acp-col-name", "publish_date"));
            table_body.append(row);
        }

        var papers = [];
        var authors = [];
        var authorsByID = {};
        var authorships = {};
        var selected_papers = null;

        $(document).ready(function () {
            $.ajax({
                type: "POST",
                url: "Papers.asmx/GetPapers",
                data: null,
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                },
                success: function (paper_result) {
                    
                    papers = paper_result.d;
                    $.ajax({
                        type: "POST",
                        url: "Author.asmx/GetAuthors",
                        data: null,
                        contentType: 'application/json; charset=utf-8',
                        dataType: 'json',
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                        },
                        success: function (author_result) {
                            
                            authors = author_result.d;
                            for (var i = 0; i < authors.length; i++) {
                                authorsByID[authors[i].authorID] = authors[i];
                            }

                            $.ajax({
                                type: "POST",
                                url: "Papers.asmx/GetPaperAuthorships",
                                data: null,
                                contentType: 'application/json; charset=utf-8',
                                dataType: 'json',
                                error: function (XMLHttpRequest, textStatus, errorThrown) {
                                    alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                                },
                                success: function (authorship_result) {
                                    var linear_authorships = authorship_result.d;
                                    for (var i = 0; i < linear_authorships.length; i++) {
                                        var tokens = linear_authorships[i].split(":");
                                        var paperID = parseInt(tokens[0]);
                                        var authorID = parseInt(tokens[1]);
                                        if (!authorships[paperID]) {
                                            authorships[paperID] = [];
                                        }
                                        authorships[paperID].push(authorID);
                                    }
                                    
                                    var table_body = $("#paper_table").find("tbody");
                                    for (var i = 0; i < papers.length; i++) {
                                        addToPaperTable(table_body, papers[i])
                                    }
                                }
                            });
                        }
                    });
                }
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="acp-card-wide mdl-card mdl-shadow--2dp">
        <div class="mdl-card__title acp-card__actions">
            <button type="button" id="add_paper_button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary">Add</button>
            <button type="button" id="edit_paper_button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary" disabled>Edit</button>
        </div>
        <div class="acp-card__supporting-text mdl-card__supporting-text">
            <table id="paper_table" class="acp-table mdl-data-table mdl-shadow--2dp">
                <thead>
                    <tr>
                        <th></th>
                        <th class="mdl-data-table__cell--non-numeric">Title</th>
                        <th class="mdl-data-table__cell--non-numeric">Authors</th>
                        <th class="mdl-data-table__cell--non-numeric">Published In</th>
                        <th class="mdl-data-table__cell--non-numeric">Date</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>

        </div>
    </div>
</asp:Content>
