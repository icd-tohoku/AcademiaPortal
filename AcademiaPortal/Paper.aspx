<%@ Page Title="" Language="C#" MasterPageFile="~/AcademiaPortal.Master" AutoEventWireup="true" CodeBehind="Paper.aspx.cs" Inherits="AcademiaPortal.Paper" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script defer src="bower_components/mdl-select-component/mdl-selectfield.min.js"></script>
    <link rel="stylesheet" href="bower_components/mdl-select-component/mdl-selectfield.min.css">

    <script defer src="bower_components/dropzone/dist/min/dropzone.min.js"></script>
    <link rel="stylesheet" href="bower_components/dropzone/dist/min/dropzone.min.css">

    <script type="text/javascript">
        function getPublishDateText(paper) {
            var d = new Date(paper.publishDate);
            return d.getUTCFullYear() + "年" + (d.getUTCMonth() + 1) + "月";
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
        function searchAuthors(search_text) {
            var matched_authors = [];
            var lowercase_search_text = search_text.toLowerCase();
            for (var i = 0; i < authors.length; i++) {
                var searchable_tokens = [];
                var author = authors[i];
                searchable_tokens.push(getAuthorName_En(author));
                searchable_tokens.push(getAuthorName_Ja(author));
                searchable_tokens.push(author.hiragana);
                searchable_tokens.push(author.email);
                for (var j = 0; j < searchable_tokens.length; j++) {
                    var position = searchable_tokens[j].toLowerCase().indexOf(lowercase_search_text);
                    if (position > -1) {
                        matched_authors.push(author);
                        break;
                    }
                }
            }
            return matched_authors;
        }

        function addToDialogSelectedAuthors(author_id) {
            var author = authorsByID[author_id];
            dialog_selected_authors.push(author);
            var delete_button = $("<button>").addClass("mdl-chip__action").attr("type", "button")
                .append($("<i>").addClass("material-icons").text("cancel"));
            var chip = $("<span>")
                .addClass("mdl-chip")
                .addClass("mdl-chip--deletable")
                .addClass("acp-author-chip")
                .attr("acp-primary-key", author_id)
                .attr("draggable", true)
                .append($("<span>").addClass("mdl-chip__text").text(getAuthorName(author)))
                .append(delete_button);
            componentHandler.upgradeElements(chip[0]);
            delete_button.on("click", function (event) {
                console.log($(this).parent());
                removeFromDialogSelectedAuthors($(this).parent().attr("acp-primary-key"), true);
            });
            $("#dialog_author_chips").append(chip);
        }
        function removeFromDialogSelectedAuthors(author_id, update_checkbox) {
            $("#dialog_author_chips").remove("span.acp-author-chip[acp-primary-key" + author_id + "]");
            for (var i = 0; i < dialog_selected_authors.length; i++) {
                if (dialog_selected_authors[i].authorID === author_id) {
                    dialog_selected_authors.splice(i, 1);
                    break;
                }
            }
            $("#dialog_author_chips").find("span.acp-author-chip[acp-primary-key=" + author_id + "]").remove();
            console.log("remove triggered for id " + author_id + " and update_checkbox = " + update_checkbox);
            if (update_checkbox) {
                var checkbox = $("#dialog_matched_author_list").find("label.acp-author-checkbox[acp-primary-key=" + author_id + "]");
                console.log(checkbox);
                checkbox[0].MaterialCheckbox.uncheck();
            }
        }
        function dialogSelectedAuthorsContain(author_id) {
            for (var i = 0; i < dialog_selected_authors.length; i++) {
                if (dialog_selected_authors[i].authorID === author_id) {
                    return true;
                }
            }
            return false;
        }

        var papers = [];
        var authors = [];
        var dialog_selected_authors = [];
        var authorsByID = {};
        var selected_papers = null;

        $(document).ready(function () {

            var paper_dialog = $("#paper_dialog")[0];
            if (!paper_dialog.showModal) {
                dialogPolyfill.registerDialog(paper_dialog);
            }
            $("#add_paper_button").click(function () {
                var dialog = $("#paper_dialog");
                dialog.find(".mdl-dialog__title").text("Add Paper");
                $("#paper_dialog_confirm").text("Add");
                dialog.attr("acp-paper-action", "add");
                paper_dialog.showModal();
            });
            $("#paper_dialog_cancel").click(function () {
                paper_dialog.close();
                if ($("#paper_dialog").attr("acp-paper-action") === "edit") {
                    clearDialog();
                }
            });
            $("#author_dialog_search").on("keyup", function (event) {
                var search_text = $(this).val();
                var author_list = $("#dialog_matched_author_list");
                var matched_authors = searchAuthors(search_text);
                author_list.empty();

                for (var i = 0; i < matched_authors.length; i++) {
                    var author = matched_authors[i];

                    var primary_content = $("<span>")
                        .addClass("mdl-list__item-primary-content")
                        .append($("<i>").addClass("material-icons").addClass("mdl-list__item-icon").text("person"))
                        .append(getAuthorName(author))
                        .append($("<span>").addClass("mdl-list__item-sub-title").text(getAuthorDescription(author)));
                    var checkbox_id = "dialog-author-checkbox-" + author.authorID;
                    var checkbox = $("<label>")
                        .addClass("mdl-checkbox")
                        .addClass("mdl-js-checkbox")
                        .addClass("mdl-js-ripple-effect")
                        .addClass("acp-author-checkbox")
                        .attr("for", checkbox_id)
                        .attr("acp-primary-key", author.authorID)
                        .append($("<input>").addClass("mdl-checkbox__input").attr("type", "checkbox")
                            .attr("id", checkbox_id));
                    checkbox.on("change", function (event) {
                        var author_id = parseInt($(this).attr("acp-primary-key"));
                        if (event.target.checked) {
                            addToDialogSelectedAuthors(author_id);
                        } else {
                            removeFromDialogSelectedAuthors(author_id);
                        }
                    });
                    componentHandler.upgradeElements(checkbox[0]);
                    if (dialogSelectedAuthorsContain(author.authorID)) {
                        checkbox[0].MaterialCheckbox.check();
                    }

                    var secondary_content = $("<span>")
                        .addClass("mdl-list__item-secondary-content")
                        .append($("<span>").addClass("mdl-list__item-secondary-action").append(checkbox));
                    var author_item = $("<li>")
                        .addClass("acp-list__item--two-line--thin")
                        .addClass("mdl-list__item")
                        .addClass("mdl-list__item--two-line")
                        .append(primary_content)
                        .append(secondary_content);
                    author_list.append(author_item);
                }
            });

            $.ajax({
                type: "GET",
                url: "/api/papers",
                data: null,
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                },
                success: function (paper_result) {
                    papers = paper_result;
                    $.ajax({
                        type: "GET",
                        url: "/api/authors",
                        data: null,
                        contentType: 'application/json; charset=utf-8',
                        dataType: 'json',
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                        },
                        success: function (author_result) {
                            authors = author_result;
                            for (var i = 0; i < authors.length; i++) {
                                authorsByID[authors[i].authorID] = authors[i];
                            }

                            var table_body = $("#paper_table").find("tbody");
                            for (var i = 0; i < papers.length; i++) {
                                addToPaperTable(table_body, papers[i])
                            }
                        }
                    });
                }
            });
            var dropzoneDisplayServerError = function (file, response) {
                $(file.previewElement).find('.dz-error-message').text(response.Message);
            };

            var document_dropzone = new Dropzone("#document_dropzone", {
                url: "/api/blob",
                maxFiles: 1,
                addRemoveLinks: true,
                init: function () {
                    this.on("error", dropzoneDisplayServerError);
                }
            });
            $("#document_dropzone").addClass("dropzone");

            var video_dropzone = new Dropzone("#video_dropzone", {
                url: "/api/blob",
                maxFiles: 1,
                addRemoveLinks: true,
                init: function () {
                    this.on("error", dropzoneDisplayServerError);
                }
            });
            $("#video_dropzone").addClass("dropzone");

            var package_dropzone = new Dropzone("#package_dropzone", {
                url: "/api/blob",
                maxFiles: 1,
                addRemoveLinks: true,
                init: function () {
                    this.on("error", dropzoneDisplayServerError);
                }
            });
            $("#package_dropzone").addClass("dropzone");

            var publication_confirmation_dropzone = new Dropzone("#publication_confirmation_dropzone", {
                url: "/api/blob",
                maxFiles: 1,
                addRemoveLinks: true,
                init: function () {
                    this.on("error", dropzoneDisplayServerError);
                }
            });
            $("#publication_confirmation_dropzone").addClass("dropzone");
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
    <dialog id="paper_dialog" class="acp-wide-form mdl-dialog">
        <h3 class="mdl-dialog__title"></h3>
        <div class="mdl-dialog__content">
            <div class="mdl-tabs mdl-js-tabs mdl-js-ripple-effect">
                <div class="mdl-tabs__tab-bar">
                    <a href="#general-panel" class="mdl-tabs__tab is-active">General</a>
                    <a href="#authors-panel" class="mdl-tabs__tab">Authors</a>
                    <a href="#files-panel" class="mdl-tabs__tab">Files</a>
                </div>

                <div class="mdl-tabs__panel is-active" id="general-panel">
                    <div class="mdl-grid">
                        <div class="mdl-cell mdl-cell--2-col">
                            <div class="mdl-selectfield mdl-js-selectfield mdl-selectfield--floating-label">
                                <select class="mdl-selectfield__select" id="genre_input">
                                    <option value="0">Long Paper</option>
                                    <option value="1">Short Paper</option>
                                    <option value="2">Abstract</option>
                                    <option value="3">Other</option>
                                </select>
                                <label class="mdl-selectfield__label" for="genre_input">Genre</label>
                            </div>
                        </div>
                        <div class="mdl-cell mdl-cell--10-col">
                            <div class="acp-textfield--full-width mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                                <input type="text" class="mdl-textfield__input" id="title_input">
                                <label class="mdl-textfield__label" for="title_input">Title</label>
                            </div>
                        </div>
                    </div>
                    <div class="mdl-grid">
                        <div class="mdl-cell mdl-cell--4-col">
                            <div class="mdl-selectfield mdl-js-selectfield mdl-selectfield--floating-label">
                                <select class="mdl-selectfield__select" id="publication_category_input">
                                    <option value="0">Journal</option>
                                    <option value="1">International Conference</option>
                                    <option value="2">Domestic Conference</option>
                                    <option value="3">Review</option>
                                    <option value="4">English Journal</option>
                                    <option value="5">Other</option>
                                </select>
                                <label class="mdl-selectfield__label" for="publication_category_input">Publication Category</label>
                            </div>
                        </div>
                        <div class="mdl-cell mdl-cell--6-col">
                            <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                                <input type="text" class="mdl-textfield__input" id="publication_input">
                                <label class="mdl-textfield__label" for="publication_input">Publication</label>
                            </div>
                        </div>
                        <div class="mdl-cell mdl-cell--1-col">
                            <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                                <input type="text" class="mdl-textfield__input" id="volume_input">
                                <label class="mdl-textfield__label" for="volume_input">Volume</label>
                            </div>
                        </div>
                        <div class="mdl-cell mdl-cell--1-col">
                            <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                                <input type="text" class="mdl-textfield__input" id="page_input">
                                <label class="mdl-textfield__label" for="page_input">Page</label>
                            </div>
                        </div>
                    </div>
                    <div class="mdl-grid">
                        <div class="mdl-cell mdl-cell--1-col">
                            <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                                <input type="text" class="mdl-textfield__input" id="publish_date_year_input">
                                <label class="mdl-textfield__label" for="publish_date_year_input">Year</label>
                                <span class="mdl-textfield__error">Invalid Year</span>
                            </div>
                        </div>
                        <div class="mdl-cell mdl-cell--1-col">
                            <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                                <input type="text" class="mdl-textfield__input" id="publish_date_month_input">
                                <label class="mdl-textfield__label" for="document_url_input">Month</label>
                                <span class="mdl-textfield__error">Invalid Month</span>
                            </div>
                        </div>
                        <div class="mdl-cell mdl-cell--4-col">
                            <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                                <input type="text" class="mdl-textfield__input" id="digital_object_id_input">
                                <label class="mdl-textfield__label" for="digital_object_id_input">DOI</label>
                            </div>
                        </div>
                        <div class="mdl-cell mdl-cell--3-col acp-cell--vertically-centered">
                            <label class="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" for="peer_reviewed_input">
                                <input type="checkbox" id="peer_reviewed_input" class="mdl-checkbox__input">
                                <span class="mdl-checkbox__label">Peer Reviewed</span>
                            </label>
                        </div>
                        <div class="mdl-cell mdl-cell--3-col">
                            <div class="mdl-selectfield mdl-js-selectfield mdl-selectfield--floating-label">
                                <select class="mdl-selectfield__select" id="presentation_style">
                                    <option value="0">Oral Presentation</option>
                                    <option value="1">Poster Presentation</option>
                                    <option value="2">Demonstration</option>
                                    <option value="3">None</option>
                                </select>
                                <label class="mdl-selectfield__label" for="presentation_style">Presentation Style</label>
                            </div>
                        </div>
                    </div>
                    <div class="mdl-grid">
                        <div class="mdl-cell mdl-cell--12-col">
                            <div class="acp-textfield--full-width mdl-textfield mdl-js-textfield">
                                <textarea class="mdl-textfield__input" rows="3" id="acknowledgment_input"></textarea>
                                <label class="mdl-textfield__label" for="acknowledgment_input">Acknowledgment</label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="mdl-tabs__panel" id="authors-panel">
                    <div class="mdl-grid">
                        <div class="mdl-cell mdl-cell--12-col">
                            <div class="acp-textfield--full-width mdl-textfield mdl-js-textfield">
                                <input type="text" class="mdl-textfield__input" id="author_dialog_search">
                                <label class="mdl-textfield__label" for="author_dialog_search">Search for authors...</label>
                            </div>
                        </div>
                    </div>
                    <div class="mdl-grid">
                        <div class="mdl-cell mdl-cell--12-col mdl-shadow--2dp">
                            <div class="acp-scrollable-list">
                                <ul class="mdl-list" id="dialog_matched_author_list">
                                </ul>
                            </div>
                        </div>
                    </div>
                    <div class="mdl-grid">
                        <div class="mdl-cell mdl-cell--12-col mdl-shadow--2dp">
                            <div class="acp-chip-container" id="dialog_author_chips">No author selected</div>
                        </div>
                    </div>
                    <div class="mdl-grid">
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" for="has_enterprise_partnership_input">
                                <input type="checkbox" id="has_enterprise_partnership_input" class="mdl-checkbox__input">
                                <span class="mdl-checkbox__label">産業連携</span>
                            </label>
                        </div>
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" for="has_international_co_author_input">
                                <input type="checkbox" id="has_international_co_author_input" class="mdl-checkbox__input">
                                <span class="mdl-checkbox__label">国際共著</span>
                            </label>
                        </div>
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" for="is_collaborative_project_input">
                                <input type="checkbox" id="is_collaborative_project_input" class="mdl-checkbox__input">
                                <span class="mdl-checkbox__label">共同プロジェクト</span>
                            </label>
                        </div>
                    </div>
                </div>
                <div class="mdl-tabs__panel" id="files-panel">
                    <div class="mdl-grid">
                        <div class="mdl-cell mdl-cell--6-col acp-dropzone-container">
                            <label for="document_dropzone"><span>Paper PDF</span></label>
                            <div id="document_dropzone">
                                <div class="dz-message" data-dz-message><span>Drop a file (or click) to upload</span></div>
                            </div>
                        </div>
                        <div class="mdl-cell mdl-cell--6-col acp-dropzone-container">
                            <label for="video_dropzone"><span>Video</span></label>
                            <div id="video_dropzone">
                                <div class="dz-message" data-dz-message><span>Drop a file (or click) to upload</span></div>
                            </div>
                        </div>
                    </div>
                    <div class="mdl-grid">
                        <div class="mdl-cell mdl-cell--6-col acp-dropzone-container">
                            <label for="package_dropzone"><span>Package</span></label>
                            <div id="package_dropzone">
                                <div class="dz-message" data-dz-message><span>Drop a file (or click) to upload</span></div>
                            </div>
                        </div>
                        <div class="mdl-cell mdl-cell--6-col acp-dropzone-container">
                            <label for="publication_confirmation_dropzone"><span>研究成果発表確認シート</span></label>
                            <div id="publication_confirmation_dropzone">
                                <div class="dz-message" data-dz-message><span>Drop a file (or click) to upload</span></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <p>* Required</p>
        </div>
    </dialog>
    <div class="mdl-dialog__actions">
        <button id="paper_dialog_confirm" type="button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary"></button>
        <button id="paper_dialog_cancel" type="button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect">Cancel</button>
    </div>
</asp:Content>
