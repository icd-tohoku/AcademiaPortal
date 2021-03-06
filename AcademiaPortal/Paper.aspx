﻿<%@ Page Title="ICD Academia Portal - Author" Language="C#" MasterPageFile="~/AcademiaPortal.Master" AutoEventWireup="true" CodeBehind="Paper.aspx.cs" Inherits="AcademiaPortal.Paper" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script defer src="bower_components/mdl-select-component/mdl-selectfield.min.js"></script>
    <link rel="stylesheet" href="bower_components/mdl-select-component/mdl-selectfield.min.css">

    <script defer src="bower_components/dropzone/dist/min/dropzone.min.js"></script>
    <link rel="stylesheet" href="bower_components/dropzone/dist/min/dropzone.min.css">

    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>

    <script type="text/javascript">
        function AuthorshipValidator(input_id, min_author_count) {
            this.input_id = input_id;
            this.chip_container = $("#" + this.input_id);
            this.min_author_count = (min_author_count == void 0) ? 1 : min_file_count;
        }

        AuthorshipValidator.prototype.validate = function () {
            console.log("validating authorship");
            var result = false;
            if (getDialogSelectedAuthorCount() < this.min_author_count) {
                console.log("invalid");
                this.chip_container.addClass('is-invalid');
            } else {
                console.log("valid");
                this.chip_container.removeClass('is-invalid');
                result = true;
            }
            return result;
        };

        function getSelectedPapers() {
            var table = $("#paper_table");
            var checked_checkboxes = table.find('tbody .mdl-data-table__select .mdl-checkbox__input:checked');
            var selected_papers = [];
            for (var i = 0; i < checked_checkboxes.length; i++) {
                var paper_id = parseInt(checked_checkboxes[i].getAttribute('acp-primary-key'));
                selected_papers.push(papersByID[paper_id]);
            }
            return selected_papers;
        }

        function updatePaperActionButtons() {
            var edit_paper_button = $("#edit_paper_button")[0].MaterialButton;
            var delete_paper_button = $("#delete_paper_button")[0].MaterialButton;
            var summarize_paper_button = $("#summarize_paper_button")[0].MaterialButton;
            var selected_papers = getSelectedPapers();
            if (selected_papers.length === 0 || selected_papers.length > 1) {
                edit_paper_button.disable();
                delete_paper_button.disable();
            } else {
                var paper = selected_papers[0];
                edit_paper_button.enable();
                delete_paper_button.enable();
            }

            if (selected_papers.length > 0) {
                summarize_paper_button.enable();
            } else {
                summarize_paper_button.disable();
            }
        }

        function initializeTable() {
            var table = $("#paper_table");
            var header_checkbox = table.find('thead .mdl-data-table__select input');

            header_checkbox.on('change', function (event) {
                var checkboxes = table.find('tbody .mdl-data-table__select');

                if ($(this).is(":checked")) {
                    for (var i = 0, length = checkboxes.length; i < length; i++) {

                        checkboxes[i].MaterialCheckbox.check();
                    }
                } else {
                    for (var i = 0, length = checkboxes.length; i < length; i++) {
                        checkboxes[i].MaterialCheckbox.uncheck();
                    }
                }
                updatePaperActionButtons();
            })
        }
        function initializeYearInput() {
            var current_year = (new Date()).getUTCFullYear();
            var from_input = $("#main_publish_date_from_input");
            var to_input = $("#main_publish_date_to_input");

            for (var i = -10; i < 2; i++) {
                var year = current_year + i;
                from_input.append($("<option>").attr("value", year).text(year));
                to_input.append($("<option>").attr("value", year).text(year));
                if (i === -1) {
                    from_input.append($("<option>").attr("value", -1).text("(Any Year)"));
                }
            }
            setMaterialSelectfieldBeforeUpgrade("main_publish_date_from_input", current_year);
            setMaterialSelectfieldBeforeUpgrade("main_publish_date_to_input", current_year);
        }

        function createDownloadAnchor(icon_name, file_path, description) {
            var icon = $("<i>").addClass("material-icons").text(icon_name);
            var anchor = $("<a>").addClass("mdl-button").addClass("acp-download-anchor");
            anchor.attr("title", description);
            if (file_path) {
                icon.addClass("mdl-button--primary");
                anchor.attr("href", blob_base_path + file_path);
                anchor.attr("download", removeGuidFromFilePath(file_path))
            } else {
                anchor.attr("disabled", true);
            }
            return anchor.append(icon);
        }

        function addToPaperTable(table_body, paper) {
            var row = $("<tr>");
            var checkbox_id = "row[" + paper.paperID + "]";
            var checkbox = $("<input>").addClass("mdl-checkbox__input").attr("type", "checkbox").attr("id", checkbox_id).attr("acp-primary-key", paper.paperID);
            var checkbox_container = $("<label>").addClass("mdl-checkbox mdl-js-checkbox mdl-data-table__select").attr("for", checkbox_id)
                .append(checkbox);
            checkbox.on('change', updatePaperActionButtons);
            componentHandler.upgradeElements(checkbox_container[0]);

            var checkbox_cell = $("<td>").append(checkbox_container);
            row.append(checkbox_cell);
            row.append($("<td>").text(paper.title).addClass("mdl-data-table__cell--non-numeric acp-data-table__cell--multiline").attr("acp-col-name", "title"));
            row.append($("<td>").text(getAuthorsText(paper)).addClass("mdl-data-table__cell--non-numeric acp-data-table__cell--multiline").attr("acp-col-name", "authors"));
            row.append($("<td>").text(getPublicationText(paper)).addClass("mdl-data-table__cell--non-numeric acp-data-table__cell--multiline").attr("acp-col-name", "publication"));
            row.append($("<td>").text(getPublishDateText_Ja(paper)).addClass("mdl-data-table__cell--non-numeric").attr("acp-col-name", "publish_date"));

            var icon = $("<i>").addClass("material-icons").text("description");
            var document_file_download_anchor = $("<a>").addClass("mdl-button").attr("disabled", true);

            var download_cell = $("<td>");

            download_cell.append(createDownloadAnchor("description", paper.documentFilePath, "Document"));
            download_cell.append(createDownloadAnchor("movie", paper.videoFilePath, "Video"));
            download_cell.append(createDownloadAnchor("folder_open", paper.packageFilePath, "Package"));
            download_cell.append(createDownloadAnchor("assignment_turned_in", paper.publicationConfirmationFilePath, "研究成果発表確認シート"));

            row.append(download_cell.addClass("mdl-data-table__cell--non-numeric"));
            table_body.append(row);
        }

        function sortPaperTable() {
            var table_body = $("#paper_table tbody");
            var table_rows = table_body.children("tr");
            var publish_date_order = $("#publish_date_th").hasClass("mdl-data-table__header--sorted-ascending") ? 1 : -1;
            table_rows.detach().sort(function (row1, row2) {
                var id1 = parseInt($(row1).find("[acp-primary-key]").attr("acp-primary-key"));
                var id2 = parseInt($(row2).find("[acp-primary-key]").attr("acp-primary-key"));
                var paper1 = papersByID[id1];
                var paper2 = papersByID[id2];
                return (paper1.publishDate - paper2.publishDate) * publish_date_order;
            }).appendTo(table_body);
        }

        function setPaperTable(papers) {
            var table = $("#paper_table");
            var table_body = table.find("tbody");
            table_body.empty();
            for (var i = 0; i < papers.length; i++) {
                addToPaperTable(table_body, papers[i]);
            }
            var header_checkbox = table.find('thead .mdl-data-table__select input');
            header_checkbox.parent()[0].MaterialCheckbox.uncheck();
            sortPaperTable();
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
        function resetDialogAuthorChipsContainerLabel(is_add_chip) {
            var current_chip_count = getDialogSelectedAuthorCount();
            if (is_add_chip && current_chip_count === 0) {
                $("#dialog_author_chips").empty();
            } else if (!is_add_chip && current_chip_count === 0) {
                $("#dialog_author_chips").append("No author selected.");
            }
            $("#dialog_author_chips").sortable({
                placeholder: "mdl-chip",
                forcePlaceholderSize: true,
                helper: "clone",
                items: ".acp-author-chip"
            });
            $("#dialog_author_chips .acp-author-chip").disableSelection();
        }
        function clearDialogSelectedAuthors() {
            $("#dialog_author_chips").empty();
            resetDialogAuthorChipsContainerLabel(false);
        }
        function addToDialogSelectedAuthors(author_id) {
            var author = authorsByID[author_id];
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
            resetDialogAuthorChipsContainerLabel(true);
            $("#dialog_author_chips").append(chip);
        }
        function removeFromDialogSelectedAuthors(author_id, update_checkbox) {
            $("#dialog_author_chips").remove("span.acp-author-chip[acp-primary-key" + author_id + "]");
            $("#dialog_author_chips").find("span.acp-author-chip[acp-primary-key=" + author_id + "]").remove();
            resetDialogAuthorChipsContainerLabel(false);
            console.log("remove triggered for id " + author_id + " and update_checkbox = " + update_checkbox);
            if (update_checkbox) {
                var checkbox = $("#dialog_matched_author_list").find("label.acp-author-checkbox[acp-primary-key=" + author_id + "]");
                if (checkbox.length > 0) {
                    checkbox[0].MaterialCheckbox.uncheck();
                }
            }
        }
        function getDialogSelectedAuthorIDs() {
            var author_chips = $("#dialog_author_chips").find("span.acp-author-chip");
            var authorIDs = [];
            for (var i = 0; i < author_chips.length; i++) {
                authorIDs.push(parseInt($(author_chips[i]).attr("acp-primary-key")));
            }
            return authorIDs;
        }
        function dialogSelectedAuthorsContain(author_id) {
            return $("#dialog_author_chips").find("span.acp-author-chip[acp-primary-key=" + author_id + "]").length > 0;
        }
        function getDialogSelectedAuthorCount() {
            return $("#dialog_author_chips").find("span.acp-author-chip").length;
        }










        function resetMainAuthorChipsContainerLabel(is_add_chip) {
            var current_chip_count = getMainSelectedAuthorCount();
            if (is_add_chip && current_chip_count === 0) {
                $("#main_author_chips").empty();
            } else if (!is_add_chip && current_chip_count === 0) {
                $("#main_author_chips").append("No author selected.");
            }
        }
        function addToMainSelectedAuthors(author_id) {
            var author = authorsByID[author_id];
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
                removeFromMainSelectedAuthors($(this).parent().attr("acp-primary-key"), true);
            });
            resetMainAuthorChipsContainerLabel(true);
            $("#main_author_chips").append(chip);
        }
        function removeFromMainSelectedAuthors(author_id, update_checkbox) {
            $("#main_author_chips").remove("span.acp-author-chip[acp-primary-key" + author_id + "]");
            $("#main_author_chips").find("span.acp-author-chip[acp-primary-key=" + author_id + "]").remove();
            resetMainAuthorChipsContainerLabel(false);
            console.log("remove triggered for id " + author_id + " and update_checkbox = " + update_checkbox);
            if (update_checkbox) {
                var checkbox = $("#main_matched_author_list").find("label.acp-author-checkbox[acp-primary-key=" + author_id + "]");
                if (checkbox.length > 0) {
                    checkbox[0].MaterialCheckbox.uncheck();
                }
            }
        }
        function getMainSelectedAuthorIDs() {
            var author_chips = $("#main_author_chips").find("span.acp-author-chip");
            var authorIDs = [];
            for (var i = 0; i < author_chips.length; i++) {
                authorIDs.push(parseInt($(author_chips[i]).attr("acp-primary-key")));
            }
            return authorIDs;
        }
        function mainSelectedAuthorsContain(author_id) {
            return $("#main_author_chips").find("span.acp-author-chip[acp-primary-key=" + author_id + "]").length > 0;
        }
        function getMainSelectedAuthorCount() {
            return $("#main_author_chips").find("span.acp-author-chip").length;
        }


        function clearDialog() {
            //TODO
            changeMaterialTextfieldValue("title_input", "");
            setMaterialSelectfield("publication_category_input", 0);
            changeMaterialTextfieldValue("publication_input", "");

            changeMaterialTextfieldValue("volume_input", "");
            changeMaterialTextfieldValue("page_input", "");
            changeMaterialTextfieldValue("digital_object_id_input", "");
            changeMaterialTextfieldValue("document_url_input", "");

            setMaterialCheckbox("peer_reviewed_input", false);
            setMaterialSelectfield("genre_input", 0);
            setMaterialSelectfield("presentation_style", 0);
            setMaterialCheckbox("has_enterprise_partnership_input", false);
            setMaterialCheckbox("has_international_co_author_input", false);
            setMaterialCheckbox("is_collaborative_project_input", false);
            changeMaterialTextfieldValue("acknowledgment_input", "");
            clearDialogSelectedAuthors();
            changeMaterialTextfieldValue("publish_date_year_input", "");
            changeMaterialTextfieldValue("publish_date_month_input", "");
            clearDropzone("document_dropzone");
            clearDropzone("video_dropzone");
            clearDropzone("package_dropzone");
            clearDropzone("publication_confirmation_dropzone");
            switchTab("general-panel");
        }

        function setDialog(paper) {
            var paperUTCDate = new Date(paper.publishDate);
            changeMaterialTextfieldValue("title_input", paper.title);
            setMaterialSelectfield("publication_category_input", paper.publicationCategory);
            changeMaterialTextfieldValue("publication_input", paper.publication);

            changeMaterialTextfieldValue("volume_input", paper.volume);
            changeMaterialTextfieldValue("page_input", paper.page);
            changeMaterialTextfieldValue("digital_object_id_input", paper.digitalObjectID);
            changeMaterialTextfieldValue("document_url_input", paper.documentURL);

            setMaterialCheckbox("peer_reviewed_input", paper.peerReviewed);
            setMaterialSelectfield("genre_input", paper.genre);
            setMaterialSelectfield("presentation_style", paper.presentationStyle);
            setMaterialCheckbox("has_enterprise_partnership_input", paper.hasEnterprisePartnership);
            setMaterialCheckbox("has_international_co_author_input", paper.hasInternationalCoAuthor);
            setMaterialCheckbox("is_collaborative_project_input", paper.isCollaborativeProject);
            changeMaterialTextfieldValue("acknowledgment_input", paper.acknowledgment);
            clearDialogSelectedAuthors();
            for (var i = 0, length = paper.authorIDs.length; i < length; i++) {
                addToDialogSelectedAuthors(paper.authorIDs[i]);
            }
            changeMaterialTextfieldValue("publish_date_year_input", paperUTCDate.getUTCFullYear());
            changeMaterialTextfieldValue("publish_date_month_input", paperUTCDate.getUTCMonth() + 1);
            setDropzoneFile("document_dropzone", paper.documentFilePath);
            setDropzoneFile("video_dropzone", paper.videoFilePath);
            setDropzoneFile("package_dropzone", paper.packageFilePath);
            setDropzoneFile("publication_confirmation_dropzone", paper.publicationConfirmationFilePath);
        }


        function getPaperFromDialog() {
            var paper = {};
            paper.title = $("#title_input").val();
            paper.publicationCategory = parseInt($("#publication_category_input").val());
            paper.publication = $("#publication_input").val();
            paper.volume = $("#volume_input").val();
            paper.page = $("#page_input").val();
            paper.digitalObjectID = $("#digital_object_id_input").val();
            paper.documentURL = $("#document_url_input").val();
            paper.peerReviewed = $("#peer_reviewed_input").is(":checked");
            paper.genre = parseInt($("#genre_input").val());
            paper.presentationStyle = parseInt($("#presentation_style").val());
            paper.hasEnterprisePartnership = $("#has_enterprise_partnership_input").is(":checked");
            paper.hasInternationalCoAuthor = $("#has_international_co_author_input").is(":checked");
            paper.isCollaborativeProject = $("#is_collaborative_project_input").is(":checked");
            paper.acknowledgment = $("#acknowledgment_input").val();
            paper.authorIDs = getDialogSelectedAuthorIDs();
            paper.publishDate = Date.UTC(parseInt($("#publish_date_year_input").val()),
                parseInt($("#publish_date_month_input").val()) - 1);
            paper.documentFilePath = getDropzoneServerFileName("document_dropzone");
            paper.videoFilePath = getDropzoneServerFileName("video_dropzone");
            paper.packageFilePath = getDropzoneServerFileName("package_dropzone");
            paper.publicationConfirmationFilePath = getDropzoneServerFileName("publication_confirmation_dropzone");

            return paper;
        }
        function validateDialog() {
            var first_invalid_field = form_validator.validateAndGetFirstError();
            if (first_invalid_field) {
                var first_invalid_tab_id = $("#" + first_invalid_field.input_id).closest(".mdl-tabs__panel").attr("id");
                switchTab(first_invalid_tab_id);
                return false;
            }
            return true;
        }
        function AddPaper() {
            if (!validateDialog()) return;
            var paper = getPaperFromDialog();
            console.log(paper);
            $.ajax({
                type: "POST",
                url: "api/papers",
                data: JSON.stringify(paper),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                },
                success: function (result) {
                    var paper = result;
                    console.log(paper);
                    if (searched) {
                        searchPapers();
                    }
                    clearDialog();
                    paper_dialog.close();
                    $("#paper_snackbar")[0].MaterialSnackbar.showSnackbar({ message: "Paper added." });
                }
            });
        }
        function UpdatePaper() {
            if (!validateDialog()) return;
            var paper = getPaperFromDialog();
            paper.paperID = getSelectedPapers()[0].paperID;
            console.log(paper);
            $.ajax({
                type: "PUT",
                url: "api/papers/" + paper.paperID,
                data: JSON.stringify(paper),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                },
                success: function (result) {
                    var paper = result;
                    console.log(paper);
                    if (searched) {
                        searchPapers();
                    }
                    clearDialog();
                    paper_dialog.close();
                    $("#paper_snackbar")[0].MaterialSnackbar.showSnackbar({ message: "Paper updated." });
                }
            });
        }
        function DeletePaper() {
            var paper_id = getSelectedPapers()[0].paperID;
            $.ajax({
                type: "DELETE",
                url: "api/papers/" + paper_id,
                data: null,
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                },
                success: function (result) {
                    if (searched) {
                        searchPapers();
                    }
                    var dialog = $("#paper_delete_dialog");
                    dialog[0].close();
                    $("#paper_snackbar")[0].MaterialSnackbar.showSnackbar({ message: "Paper deleted." });
                }
            });
        }
        function searchPapers() {
            var criteria = getSearchCriteria();
            console.log(criteria);
            $.ajax({
                type: "GET",
                url: "api/papers?" + $.param(criteria),
                data: null,
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                },
                success: function (paper_result) {
                    papers = paper_result;
                    arrayToHash(papers, "paperID", papersByID);
                    setPaperTable(papers);
                    searched = true;
                    updatePaperActionButtons();
                }
            });
        }
        function setBooleanSearchCriterion(criteria, criterion_name, group_id, input_name) {
            var button_group = $("#" + group_id);
            var selected_button = button_group.find("input:radio[name='" + input_name + "']:checked");
            var parsed_value = parseInt(selected_button.attr("value"));
            console.log(button_group);
            console.log(selected_button);
            console.log(parsed_value);
            if (parsed_value >= 0) {
                criteria[criterion_name] = !!parsed_value;
            }
        }
        function getSearchCriteria() {
            var criteria = {};
            var select_field_parsed_value;
            // will be ignored duing query string conversion when authorIDs is empty
            criteria.authorIDs = getMainSelectedAuthorIDs();

            var from_year = parseInt($("#main_publish_date_from_input").val());
            var start_month_of_year = $("#main_publish_date_year_type").val() === "business_year" ? 3 : 0;
            if (from_year > 0) {
                var to_year = parseInt($("#main_publish_date_to_input").val());
                criteria.publishDateFrom = Date.UTC(from_year, start_month_of_year);
                criteria.publishDateTo = Date.UTC(to_year + 1, start_month_of_year);
            }

            setBooleanSearchCriterion(criteria, "hasEnterprisePartnership", "main_has_enterprise_partnership_group", "main_has_enterprise_partnership");
            setBooleanSearchCriterion(criteria, "hasInternationalCoAuthor", "main_has_international_coauthor_group", "main_has_international_coauthor");
            setBooleanSearchCriterion(criteria, "isCollaborativeProject", "main_is_collaborative_project_group", "main_is_collaborative_project");
            setBooleanSearchCriterion(criteria, "peerReviewed", "main_peer_reviewed_group", "main_peer_reviewed");

            if ((select_field_parsed_value = parseInt($("#main_publication_category_input").val())) >= 0) {
                criteria.publicationCategory = select_field_parsed_value;
            }

            if ((select_field_parsed_value = parseInt($("#main_presentation_style_input").val())) >= 0) {
                criteria.presentationStyle = select_field_parsed_value;
            }

            if ((select_field_parsed_value = parseInt($("#main_genre_input").val())) >= 0) {
                criteria.genre = select_field_parsed_value;
            }


            criteria.firstAuthorOnly = $("#main_first_author_input").is(":checked");
            criteria.authorConjunctiveMatch = $("#main_author_matching_conjunction").is(":checked");
            return criteria;
        }


        var papers = [];
        var papersByID = {};
        var authors = [];
        var authorsByID = {};
        var blob_base_path = "";
        var selected_papers = null;
        var searched = false;
        var form_validator = new FormValidator();

        $(document).ready(function () {
            initializeTable();
            var paper_dialog = $("#paper_dialog")[0];
            if (!paper_dialog.showModal) {
                dialogPolyfill.registerDialog(paper_dialog);
            }
            var paper_summary_dialog = $("#paper_summary_dialog")[0];
            if (!paper_summary_dialog.showModal) {
                dialogPolyfill.registerDialog(paper_summary_dialog);
            }
            $("#add_paper_button").click(function () {
                var dialog = $("#paper_dialog");
                dialog.find(".mdl-dialog__title").text("Add Paper");
                $("#paper_dialog_confirm").text("Add");
                dialog.attr("acp-action", "add");
                paper_dialog.showModal();
            });

            $("#edit_paper_button").on("click", function () {
                var dialog = $("#paper_dialog");
                dialog.find(".mdl-dialog__title").text("Edit Paper");
                $("#paper_dialog_confirm").text("Update");
                dialog.attr("acp-action", "edit");
                setDialog(getSelectedPapers()[0]);
                paper_dialog.showModal();
            });
            $("#delete_paper_button").on('click', function () {
                var dialog = $("#paper_delete_dialog");
                var dialog_content = dialog.find(".mdl-dialog__content");
                var dialog_content_text = $("<p>");
                var selected_paper = getSelectedPapers()[0];
                dialog_content_text.append("Are you sure to delete ")
                dialog_content_text.append($("<strong>").append(selected_paper.title));
                dialog_content_text.append("?");
                dialog_content.empty();
                dialog_content.append(dialog_content_text);
                dialog[0].showModal();
            });
            $("#summarize_paper_button").on("click", function () {
                var selected_papers = getSelectedPapers();
                var paper_summaries = [];
                for (var i = 0; i < selected_papers.length; i++) {
                    paper_summaries.push(getPaperSummary(selected_papers[i]));
                }
                $("#paper_summary_textarea").val(paper_summaries.join("\n\n"));
                paper_summary_dialog.showModal();
            });

            $("#paper_dialog_cancel").click(function () {
                paper_dialog.close();
                if ($("#paper_dialog").attr("acp-action") === "edit") {
                    clearDialog();
                }
            });
            $("#paper_delete_dialog_cancel").on("click", function () {
                var dialog = $("#paper_delete_dialog");
                dialog[0].close();
            });
            $("#summary_dialog_close").on('click', function () {
                paper_summary_dialog.close();
            })
            initializeYearInput();
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


            $("#author_main_search").on("keyup", function (event) {
                var search_text = $(this).val();
                var author_list = $("#main_matched_author_list");
                var matched_authors = searchAuthors(search_text);
                author_list.empty();

                for (var i = 0; i < matched_authors.length; i++) {
                    var author = matched_authors[i];

                    var primary_content = $("<span>")
                        .addClass("mdl-list__item-primary-content")
                        .append($("<i>").addClass("material-icons").addClass("mdl-list__item-icon").text("person"))
                        .append(getAuthorName(author))
                        .append($("<span>").addClass("mdl-list__item-sub-title").text(getAuthorDescription(author)));
                    var checkbox_id = "main-author-checkbox-" + author.authorID;
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
                            addToMainSelectedAuthors(author_id);
                        } else {
                            removeFromMainSelectedAuthors(author_id);
                        }
                    });
                    componentHandler.upgradeElements(checkbox[0]);
                    if (mainSelectedAuthorsContain(author.authorID)) {
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

            $("#publish_date_th").on("click", function (event) {
                var table_header = $(this);
                if (table_header.hasClass("mdl-data-table__header--sorted-descending")) {
                    table_header.removeClass("mdl-data-table__header--sorted-descending");
                    table_header.addClass("mdl-data-table__header--sorted-ascending");
                } else {
                    table_header.removeClass("mdl-data-table__header--sorted-ascending");
                    table_header.addClass("mdl-data-table__header--sorted-descending");
                }
                sortPaperTable();
            });

            $("#paper_dialog_confirm").on("click", function () {
                var action = $("#paper_dialog").attr("acp-action");
                if (action === "add") {
                    AddPaper();
                } else if (action === "edit") {
                    UpdatePaper();
                }
            });
            $("#paper_delete_dialog_confirm").on("click", function () {
                DeletePaper();
            });
            form_validator.add(new FieldLengthValidator("title_input"));
            form_validator.add(new FieldIntegerRangeValidator("publish_date_year_input", 0));
            form_validator.add(new FieldIntegerRangeValidator("publish_date_month_input", 1, 12));
            form_validator.add(new FieldLengthValidator("publication_input"));
            form_validator.add(new AuthorshipValidator("dialog_author_chips"));

            $.ajax({
                type: "GET",
                url: "api/authors",
                data: null,
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                },
                success: function (author_result) {
                    authors = author_result;
                    arrayToHash(authors, "authorID", authorsByID);
                }
            });

            $.ajax({
                type: "GET",
                url: "api/blob",
                data: null,
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (result) {
                    blob_base_path = result.base;
                }
            });

            $("#main_first_author_input").on("change", function (event) {
                if ($(this).is(":checked")) {
                    $("#main_author_matching_disjunction").parent()[0].MaterialRadio.check();
                    $("#main_author_matching_conjunction").parent()[0].MaterialRadio.uncheck();
                    $("#main_author_matching_conjunction").parent()[0].MaterialRadio.disable();
                } else {
                    $("#main_author_matching_conjunction").parent()[0].MaterialRadio.enable();
                }
            });

            $("#main_publish_date_from_input").on("change", function (event) {
                var parsed_value = $(this).val();
                if (parsed_value < 0) {
                    disableMaterialSelectfield("main_publish_date_to_input");
                } else {
                    enableMaterialSelectfield("main_publish_date_to_input");
                }
            })

            $("#search_paper_button").on("click", searchPapers);

            var dropzoneDisplayServerError = function (file, response) {
                $(file.previewElement).find('.dz-error-message').text(response.Message);
            };
            var dropzoneSaveServerSideFileName = function (file, response) {
                console.log(response);
                file.server_file_name = response[0];
            }

            var document_dropzone = new Dropzone("#document_dropzone", {
                url: "api/blob",
                maxFilesize: 500,
                maxFiles: 1,
                addRemoveLinks: true,
                init: function () {
                    this.on("error", dropzoneDisplayServerError);
                    this.on("success", dropzoneSaveServerSideFileName);
                }
            });
            $("#document_dropzone").addClass("dropzone");

            var video_dropzone = new Dropzone("#video_dropzone", {
                url: "api/blob",
                maxFilesize: 500,
                maxFiles: 1,
                addRemoveLinks: true,
                init: function () {
                    this.on("error", dropzoneDisplayServerError);
                    this.on("success", dropzoneSaveServerSideFileName);
                }
            });
            $("#video_dropzone").addClass("dropzone");

            var package_dropzone = new Dropzone("#package_dropzone", {
                url: "api/blob",
                maxFilesize: 500,
                maxFiles: 1,
                addRemoveLinks: true,
                init: function () {
                    this.on("error", dropzoneDisplayServerError);
                    this.on("success", dropzoneSaveServerSideFileName);
                }
            });
            $("#package_dropzone").addClass("dropzone");

            var publication_confirmation_dropzone = new Dropzone("#publication_confirmation_dropzone", {
                url: "api/blob",
                maxFilesize: 500,
                maxFiles: 1,
                addRemoveLinks: true,
                init: function () {
                    this.on("error", dropzoneDisplayServerError);
                    this.on("success", dropzoneSaveServerSideFileName);
                }
            });
            $("#publication_confirmation_dropzone").addClass("dropzone");
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="paper_snackbar" class="mdl-js-snackbar mdl-snackbar">
        <div class="mdl-snackbar__text"></div>
        <button class="mdl-snackbar__action" type="button"></button>
    </div>
    <div class="mdl-grid mdl-grid--no-spacing">
        <div class="mdl-cell mdl-cell--4-col">
            <div class="mdl-grid acp-cell--vertically-centered">
                <div class="mdl-cell mdl-cell--6-col">
                    <div class="acp-textfield--full-width mdl-textfield mdl-js-textfield">
                        <input type="text" class="mdl-textfield__input" id="author_main_search">
                        <label class="mdl-textfield__label" for="author_main_search">Search for authors...</label>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--3-col">
                    <label class="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" for="main_first_author_input">
                        <input type="checkbox" id="main_first_author_input" class="mdl-checkbox__input">
                        <span class="mdl-checkbox__label">First Author</span>
                    </label>
                </div>
                <div class="mdl-cell mdl-cell--3-col">
                    <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="main_author_matching_disjunction">
                        <input type="radio" id="main_author_matching_disjunction" class="mdl-radio__button" name="main_author_matching" value="2" checked>
                        <span class="mdl-radio__label">Match Any</span>
                    </label>
                    <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="main_author_matching_conjunction">
                        <input type="radio" id="main_author_matching_conjunction" class="mdl-radio__button" name="main_author_matching" value="1">
                        <span class="mdl-radio__label">Match All</span>
                    </label>

                </div>
            </div>
            <div class="mdl-grid mdl-grid--no-spacing">
                <div class="mdl-cell mdl-cell--12-col mdl-shadow--2dp">
                    <div class="acp-scrollable-list">
                        <ul class="mdl-list" id="main_matched_author_list">
                        </ul>
                    </div>
                </div>
            </div>
            <div class="mdl-grid mdl-grid--no-spacing">
                <div class="mdl-cell mdl-cell--12-col mdl-shadow--2dp">
                    <div class="acp-chip-container" id="main_author_chips">No author selected.</div>
                </div>
            </div>
        </div>
        <div class="mdl-cell mdl-cell--8-col">
            <div class="mdl-grid acp-cell--vertically-centered">
                <div class="mdl-cell mdl-cell--4-col">
                    <div class="mdl-selectfield mdl-js-selectfield mdl-selectfield--floating-label">
                        <select class="mdl-selectfield__select" id="main_publication_category_input">
                            <option value="-1">All</option>
                            <option value="0">Journal</option>
                            <option value="1">International Conference</option>
                            <option value="2">Domestic Conference</option>
                            <option value="3">Review</option>
                            <option value="4">English Journal</option>
                            <option value="5">Other</option>
                        </select>
                        <label class="mdl-selectfield__label" for="main_publication_category_input">Publication Category</label>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--4-col">
                    <div class="mdl-selectfield mdl-js-selectfield mdl-selectfield--floating-label">
                        <select class="mdl-selectfield__select" id="main_presentation_style_input">
                            <option value="-1">All</option>
                            <option value="0">Oral Presentation</option>
                            <option value="1">Poster Presentation</option>
                            <option value="2">Demonstration</option>
                            <option value="3">None</option>
                        </select>
                        <label class="mdl-selectfield__label" for="main_presentation_style_input">Presentation Style</label>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--4-col">
                    <div class="mdl-selectfield mdl-js-selectfield mdl-selectfield--floating-label">
                        <select class="mdl-selectfield__select" id="main_genre_input">
                            <option value="-1">All</option>
                            <option value="0">Long Paper</option>
                            <option value="1">Short Paper</option>
                            <option value="2">Abstract</option>
                            <option value="3">Other</option>
                        </select>
                        <label class="mdl-selectfield__label" for="main_genre_input">Genre</label>
                    </div>
                </div>
            </div>


            <div class="mdl-grid acp-cell--vertically-centered">
                <div class="mdl-cell mdl-cell--3-col">
                    <div class="mdl-grid">Enterprise Partnership</div>
                    <div class="mdl-grid acp-radio-group-container" id="main_has_enterprise_partnership_group">
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="main_has_enterprise_partnership_any">
                                <input type="radio" id="main_has_enterprise_partnership_any" class="mdl-radio__button" name="main_has_enterprise_partnership" value="-1" checked>
                                <span class="mdl-radio__label">Any</span>
                            </label>
                        </div>
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="main_has_enterprise_partnership_true">
                                <input type="radio" id="main_has_enterprise_partnership_true" class="mdl-radio__button" name="main_has_enterprise_partnership" value="1">
                                <span class="mdl-radio__label">True</span>
                            </label>
                        </div>
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="main_has_enterprise_partnership_false">
                                <input type="radio" id="main_has_enterprise_partnership_false" class="mdl-radio__button" name="main_has_enterprise_partnership" value="0">
                                <span class="mdl-radio__label">False</span>
                            </label>
                        </div>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--3-col">
                    <div class="mdl-grid">International Co-author</div>
                    <div class="mdl-grid acp-radio-group-container" id="main_has_international_coauthor_group">
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="main_has_international_coauthor_any">
                                <input type="radio" id="main_has_international_coauthor_any" class="mdl-radio__button" name="main_has_international_coauthor" value="-1" checked>
                                <span class="mdl-radio__label">Any</span>
                            </label>
                        </div>
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="main_has_international_coauthor_true">
                                <input type="radio" id="main_has_international_coauthor_true" class="mdl-radio__button" name="main_has_international_coauthor" value="1">
                                <span class="mdl-radio__label">True</span>
                            </label>
                        </div>
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="main_has_international_coauthor_false">
                                <input type="radio" id="main_has_international_coauthor_false" class="mdl-radio__button" name="main_has_international_coauthor" value="0">
                                <span class="mdl-radio__label">False</span>
                            </label>
                        </div>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--3-col">
                    <div class="mdl-grid">Collaborative Project</div>
                    <div class="mdl-grid acp-radio-group-container" id="main_is_collaborative_project_group">
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="main_is_collaborative_project_any">
                                <input type="radio" id="main_is_collaborative_project_any" class="mdl-radio__button" name="main_is_collaborative_project" value="-1" checked>
                                <span class="mdl-radio__label">Any</span>
                            </label>
                        </div>
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="main_is_collaborative_project_true">
                                <input type="radio" id="main_is_collaborative_project_true" class="mdl-radio__button" name="main_is_collaborative_project" value="1">
                                <span class="mdl-radio__label">True</span>
                            </label>
                        </div>
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="main_is_collaborative_project_false">
                                <input type="radio" id="main_is_collaborative_project_false" class="mdl-radio__button" name="main_is_collaborative_project" value="0">
                                <span class="mdl-radio__label">False</span>
                            </label>
                        </div>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--3-col">
                    <div class="mdl-grid">Peer Reviewed</div>
                    <div class="mdl-grid acp-radio-group-container" id="main_peer_reviewed_group">
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="main_peer_reviewed_any">
                                <input type="radio" id="main_peer_reviewed_any" class="mdl-radio__button" name="main_peer_reviewed" value="-1" checked>
                                <span class="mdl-radio__label">Any</span>
                            </label>
                        </div>
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="main_peer_reviewed_true">
                                <input type="radio" id="main_peer_reviewed_true" class="mdl-radio__button" name="main_peer_reviewed" value="1">
                                <span class="mdl-radio__label">True</span>
                            </label>
                        </div>
                        <div class="mdl-cell mdl-cell--4-col">
                            <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="main_peer_reviewed_false">
                                <input type="radio" id="main_peer_reviewed_false" class="mdl-radio__button" name="main_peer_reviewed" value="0">
                                <span class="mdl-radio__label">False</span>
                            </label>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mdl-grid acp-cell--vertically-centered">
                <div class="mdl-cell mdl-cell--1-col">
                    <div class="mdl-selectfield mdl-js-selectfield mdl-selectfield--floating-label">
                        <select class="mdl-selectfield__select" id="main_publish_date_year_type">
                            <option value="year">年</option>
                            <option value="business_year">年度</option>
                        </select>
                        <label class="mdl-selectfield__label" for="main_publish_date_year_type">Year Type</label>
                    </div>
                </div>

                <div class="mdl-cell mdl-cell--2-col">
                    <div class="mdl-selectfield mdl-js-selectfield mdl-selectfield--floating-label">
                        <select class="mdl-selectfield__select" id="main_publish_date_from_input">
                        </select>
                        <label class="mdl-selectfield__label" for="main_publish_date_from_input">From Year</label>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--2-col">
                    <div class="mdl-selectfield mdl-js-selectfield mdl-selectfield--floating-label">
                        <select class="mdl-selectfield__select" id="main_publish_date_to_input">
                        </select>
                        <label class="mdl-selectfield__label" for="main_publish_date_to_input">To Year</label>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--3-col">
                    <button type="button" id="search_paper_button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary">Search</button>
                </div>
            </div>
        </div>
    </div>
    <div class="acp-card-wide mdl-card mdl-shadow--2dp">
        <div class="mdl-card__title acp-card__actions">
            <button type="button" id="add_paper_button" class="mdl-button mdl-js-button mdl-button--raised mdl-button--primary">Add</button>
            <button type="button" id="edit_paper_button" class="mdl-button mdl-js-button mdl-button--raised mdl-button--primary" disabled>Edit</button>
            <button type="button" id="delete_paper_button" class="mdl-button mdl-js-button mdl-button--raised mdl-button--primary" disabled>Delete</button>
            <button type="button" id="summarize_paper_button" class="mdl-button mdl-js-button mdl-button--raised" disabled>Summarize</button>
        </div>
        <div class="acp-card-subcomponent--full-width mdl-card__supporting-text">
            <table id="paper_table" class="acp-table--no-scroll mdl-data-table mdl-shadow--2dp">
                <thead>
                    <tr>
                        <th>
                            <label class="mdl-checkbox mdl-js-checkbox mdl-data-table__select" for="table-header">
                                <input type="checkbox" id="table-header" class="mdl-checkbox__input" />
                            </label>
                        </th>
                        <th class="mdl-data-table__cell--non-numeric">Title</th>
                        <th class="mdl-data-table__cell--non-numeric">Authors</th>
                        <th class="mdl-data-table__cell--non-numeric">Published In</th>
                        <th class="mdl-data-table__cell--non-numeric mdl-data-table__header--sorted-descending" id="publish_date_th">Date</th>
                        <th class="mdl-data-table__cell--non-numeric">Downloads</th>
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
                                <label class="mdl-textfield__label" for="title_input">Title *</label>
                                <span class="mdl-textfield__error">Required Field</span>
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
                                <label class="mdl-textfield__label" for="publication_input">Publication *</label>
                                <span class="mdl-textfield__error">Required Field</span>
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
                        <div class="mdl-cell mdl-cell--2-col">
                            <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                                <input type="text" class="mdl-textfield__input" id="publish_date_year_input">
                                <label class="mdl-textfield__label" for="publish_date_year_input">Year *</label>
                                <span class="mdl-textfield__error">Invalid Year</span>
                            </div>
                        </div>
                        <div class="mdl-cell mdl-cell--2-col">
                            <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                                <input type="text" class="mdl-textfield__input" id="publish_date_month_input">
                                <label class="mdl-textfield__label" for="publish_date_month_input">Month *</label>
                                <span class="mdl-textfield__error">Invalid Month</span>
                            </div>
                        </div>

                        <div class="mdl-cell mdl-cell--3-col acp-cell--vertically-centered">
                            <label class="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" for="peer_reviewed_input">
                                <input type="checkbox" id="peer_reviewed_input" class="mdl-checkbox__input">
                                <span class="mdl-checkbox__label">Peer Reviewed</span>
                            </label>
                        </div>
                        <div class="mdl-cell mdl-cell--5-col">
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
                        <div class="mdl-cell mdl-cell--9-col">
                            <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                                <input type="text" class="mdl-textfield__input" id="document_url_input">
                                <label class="mdl-textfield__label" for="document_url_input">Document URL</label>
                            </div>
                        </div>
                        <div class="mdl-cell mdl-cell--3-col">
                            <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                                <input type="text" class="mdl-textfield__input" id="digital_object_id_input">
                                <label class="mdl-textfield__label" for="digital_object_id_input">DOI</label>
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
                    <p>* Required</p>
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
                            <div class="acp-chip-container" id="dialog_author_chips">No author selected.</div>
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
        </div>
        <div class="mdl-dialog__actions">
            <button id="paper_dialog_confirm" type="button" class="mdl-button mdl-js-button mdl-button--raised mdl-button--primary"></button>
            <button id="paper_dialog_cancel" type="button" class="mdl-button mdl-js-button mdl-button--raised">Cancel</button>
        </div>
    </dialog>
    <dialog id="paper_summary_dialog" class="acp-wide-form mdl-dialog">
        <h3 class="mdl-dialog__title">Summary of Papers</h3>
        <div class="mdl-dialog__content">
            <div class="acp-textfield--full-width mdl-textfield mdl-js-textfield">
                <textarea class="mdl-textfield__input" rows="10" id="paper_summary_textarea" readonly></textarea>
                <label class="mdl-textfield__label" for="paper_summary_textarea"></label>
            </div>
        </div>
        <div class="mdl-dialog__actions">
            <button id="summary_dialog_close" type="button" class="mdl-button mdl-js-button mdl-button--raised mdl-button--primary">Close</button>
        </div>
    </dialog>
    <dialog id="paper_delete_dialog" class="acp-wide-form mdl-dialog">
        <h3 class="mdl-dialog__title">Delete Paper</h3>
        <div class="mdl-dialog__content">
        </div>
        <div class="mdl-dialog__actions">
            <button id="paper_delete_dialog_confirm" type="button" class="mdl-button mdl-js-button mdl-button--raised mdl-button--primary">Delete</button>
            <button id="paper_delete_dialog_cancel" type="button" class="mdl-button mdl-js-button mdl-button--raised">Cancel</button>
        </div>
    </dialog>
</asp:Content>
