<%@ Page Title="ICD Academia Portal - Author" Language="C#" MasterPageFile="~/AcademiaPortal.Master" AutoEventWireup="true" CodeBehind="Paper.aspx.cs" Inherits="AcademiaPortal.Paper" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script defer src="bower_components/mdl-select-component/mdl-selectfield.min.js"></script>
    <link rel="stylesheet" href="bower_components/mdl-select-component/mdl-selectfield.min.css">

    <script defer src="bower_components/dropzone/dist/min/dropzone.min.js"></script>
    <link rel="stylesheet" href="bower_components/dropzone/dist/min/dropzone.min.css">

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
            })
        }

        function addToPaperTable(table_body, paper) {
            var row = $("<tr>");
            var checkbox_id = "row[" + paper.paperID + "]";
            var checkbox = $("<input>").addClass("mdl-checkbox__input").attr("type", "checkbox").attr("id", checkbox_id).attr("acp-primary-key", paper.paperID);
            var checkbox_container = $("<label>").addClass("mdl-checkbox mdl-js-checkbox mdl-data-table__select").attr("for", checkbox_id)
                .append(checkbox);
            componentHandler.upgradeElements(checkbox_container[0]);

            var checkbox_cell = $("<td>").append(checkbox_container);
            row.append(checkbox_cell);
            row.append($("<td>").text(paper.title).addClass("mdl-data-table__cell--non-numeric acp-data-table__cell--multiline").attr("acp-col-name", "title"));
            row.append($("<td>").text(getAuthorsText(paper)).addClass("mdl-data-table__cell--non-numeric acp-data-table__cell--multiline").attr("acp-col-name", "authors"));
            row.append($("<td>").text(paper.publication).addClass("mdl-data-table__cell--non-numeric acp-data-table__cell--multiline").attr("acp-col-name", "publication"));
            row.append($("<td>").text(getPublishDateText(paper)).addClass("mdl-data-table__cell--non-numeric").attr("acp-col-name", "publish_date"));
            table_body.append(row);
        }

        function setPaperTable(papers) {
            var table_body = $("#paper_table").find("tbody");
            table_body.empty();
            for (var i = 0; i < papers.length; i++) {
                addToPaperTable(table_body, papers[i]);
            }
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
        }

        function getDropzoneServerFileName(dropzone_id) {
            var accepted_files = $("#" + dropzone_id)[0].dropzone.getAcceptedFiles()
            if (accepted_files.length > 0) {
                return accepted_files[0].server_file_name;
            }
            return null;
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
        function AddPaper() {
            var first_invalid_field = form_validator.validateAndGetFirstError();
            if (first_invalid_field) {
                var first_invalid_tab_id = $("#" + first_invalid_field.input_id).closest(".mdl-tabs__panel").attr("id");
                switchTab(first_invalid_tab_id);
                return;
            }
            var paper = getPaperFromDialog();
            console.log(paper);
            $.ajax({
                type: "POST",
                url: "/api/papers",
                data: JSON.stringify(paper),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                },
                success: function (result) {
                    var paper = result;
                    console.log(paper);
                    papers.push(paper);
                    // TODO: do not update view
                    clearDialog();
                    paper_dialog.close();
                    $("#paper_snackbar")[0].MaterialSnackbar.showSnackbar({ message: "Paper added." });
                }
            });
        }

        function getSearchCriteria() {
            var criteria = {};
            // will be ignored duing query string conversion when authorIDs is empty
            criteria.authorIDs = getMainSelectedAuthorIDs();
            if ($("#main_publish_date_toggle").is(":checked")) {
                criteria.publishDateFrom = Date.UTC(parseInt($("#main_publish_date_from_input").val()))
                criteria.publishDateTo = Date.UTC(parseInt($("#main_publish_date_to_input").val()) + 1);
            }

            if ($("#main_has_enterprise_partnership_toggle").is(":checked")) {
                criteria.hasEnterprisePartnership = $("#main_has_enterprise_partnership_input").is(":checked");
            }
            if ($("#main_has_international_coauthor_toggle").is(":checked")) {
                criteria.hasInternationalCoAuthor = $("#main_has_international_coauthor_input").is(":checked");
            }
            if ($("#main_is_collaborative_project_toggle").is(":checked")) {
                criteria.isCollaborativeProject = $("#main_is_collaborative_project_input").is(":checked");
            }
            if ($("#main_peer_reviewed_toggle").is(":checked")) {
                criteria.peerReviewed = $("#main_peer_reviewed_input").is(":checked");
            }
            if ($("#main_publication_category_toggle").is(":checked")) {
                criteria.publicationCategory = parseInt($("#main_publication_category_input").val());
            }
            if ($("#main_presentation_style_toggle").is(":checked")) {
                criteria.presentationStyle = parseInt($("#main_presentation_style_input").val());
            }
            if ($("#main_genre_toggle").is(":checked")) {
                criteria.genre = parseInt($("#main_genre_input").val());
            }

            criteria.firstAuthorOnly = $("#main_first_author_input").is(":checked");
            criteria.authorConjunctiveMatch = $("#main_author_matching_conjunction").is(":checked");
            return criteria;
        }


        var papers = [];
        var authors = [];
        var authorsByID = {};
        var selected_papers = null;
        var form_validator = new FormValidator();
        var main_validator = new FormValidator();

        $(document).ready(function () {
            initializeTable();
            var paper_dialog = $("#paper_dialog")[0];
            if (!paper_dialog.showModal) {
                dialogPolyfill.registerDialog(paper_dialog);
            }
            $("#add_paper_button").click(function () {
                var dialog = $("#paper_dialog");
                dialog.find(".mdl-dialog__title").text("Add Paper");
                $("#paper_dialog_confirm").text("Add");
                dialog.attr("acp-action", "add");
                paper_dialog.showModal();
            });
            $("#paper_dialog_cancel").click(function () {
                paper_dialog.close();
                if ($("#paper_dialog").attr("acp-action") === "edit") {
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

            $("#paper_dialog_confirm").on("click", function () {
                var action = $("#paper_dialog").attr("acp-action");
                if (action === "add") {
                    AddPaper();
                } else if (action === "edit") {
                    UpdatePaper();
                }
            });

            form_validator.add(new FieldLengthValidator("title_input"));
            form_validator.add(new FieldLengthValidator("publication_input"));
            form_validator.add(new FieldIntegerRangeValidator("publish_date_year_input", 0));
            form_validator.add(new FieldIntegerRangeValidator("publish_date_month_input", 1, 12));
            form_validator.add(new AuthorshipValidator("dialog_author_chips"));

            main_validator.add(new FieldIntegerRangeValidator("main_publish_date_from_input", 0, 3000, "main_publish_date_toggle"));
            main_validator.add(new FieldIntegerRangeValidator("main_publish_date_to_input", 0, 3000, "main_publish_date_toggle"));


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
                }
            });


            $("#main_publish_date_toggle").on('change', function (event) {
                if ($(this).is(":checked")) {
                    $("#main_publish_date_from_input").parent()[0].MaterialTextfield.enable()
                    $("#main_publish_date_to_input").parent()[0].MaterialTextfield.enable()
                } else {
                    $("#main_publish_date_from_input").parent()[0].MaterialTextfield.disable()
                    $("#main_publish_date_to_input").parent()[0].MaterialTextfield.disable()
                }
            });

            $("#main_has_enterprise_partnership_toggle").on('change', function (event) {
                if ($(this).is(":checked")) {
                    $("#main_has_enterprise_partnership_input").parent()[0].MaterialCheckbox.enable()
                } else {
                    $("#main_has_enterprise_partnership_input").parent()[0].MaterialCheckbox.disable()
                }
            });


            $("#main_has_international_coauthor_toggle").on('change', function (event) {
                if ($(this).is(":checked")) {
                    $("#main_has_international_coauthor_input").parent()[0].MaterialCheckbox.enable()
                } else {
                    $("#main_has_international_coauthor_input").parent()[0].MaterialCheckbox.disable()
                }
            });

            $("#main_is_collaborative_project_toggle").on('change', function (event) {
                if ($(this).is(":checked")) {
                    $("#main_is_collaborative_project_input").parent()[0].MaterialCheckbox.enable()
                } else {
                    $("#main_is_collaborative_project_input").parent()[0].MaterialCheckbox.disable()
                }
            });

            $("#main_peer_reviewed_toggle").on('change', function (event) {
                if ($(this).is(":checked")) {
                    $("#main_peer_reviewed_input").parent()[0].MaterialCheckbox.enable()
                } else {
                    $("#main_peer_reviewed_input").parent()[0].MaterialCheckbox.disable()
                }
            });

            $("#main_publication_category_toggle").on('change', function (event) {
                if ($(this).is(":checked")) {
                    $("#main_publication_category_input").parent()[0].MaterialSelectfield.enable();
                } else {
                    $("#main_publication_category_input").parent()[0].MaterialSelectfield.disable();
                }
            });

            $("#main_presentation_style_toggle").on('change', function (event) {
                if ($(this).is(":checked")) {
                    $("#main_presentation_style_input").parent()[0].MaterialSelectfield.enable();
                } else {
                    $("#main_presentation_style_input").parent()[0].MaterialSelectfield.disable();
                }
            });


            $("#main_genre_toggle").on('change', function (event) {
                if ($(this).is(":checked")) {
                    $("#main_genre_input").parent()[0].MaterialSelectfield.enable();
                } else {
                    $("#main_genre_input").parent()[0].MaterialSelectfield.disable();
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

            var current_year = (new Date()).getUTCFullYear();
            $("#main_publish_date_from_input").val(current_year);
            $("#main_publish_date_to_input").val(current_year);

            $("#search_paper_button").on("click", function () {
                if (!main_validator.validate()) {
                    return;
                }
                var criteria = getSearchCriteria();
                console.log(criteria);
                $.ajax({
                    type: "GET",
                    url: "/api/papers?" + $.param(criteria),
                    data: null,
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        alert("Request: " + XMLHttpRequest.toString() + "\n\nStatus: " + textStatus + "\n\nError: " + errorThrown);
                    },
                    success: function (paper_result) {
                        papers = paper_result;
                        setPaperTable(papers);
                    }
                });
            });
            var dropzoneDisplayServerError = function (file, response) {
                $(file.previewElement).find('.dz-error-message').text(response.Message);
            };
            var dropzoneSaveServerSideFileName = function (file, response) {
                console.log(response);
                file.server_file_name = response[0];
            }

            var document_dropzone = new Dropzone("#document_dropzone", {
                url: "/api/blob",
                maxFiles: 1,
                addRemoveLinks: true,
                init: function () {
                    this.on("error", dropzoneDisplayServerError);
                    this.on("success", dropzoneSaveServerSideFileName);
                }
            });
            $("#document_dropzone").addClass("dropzone");

            var video_dropzone = new Dropzone("#video_dropzone", {
                url: "/api/blob",
                maxFiles: 1,
                addRemoveLinks: true,
                init: function () {
                    this.on("error", dropzoneDisplayServerError);
                    this.on("success", dropzoneSaveServerSideFileName);
                }
            });
            $("#video_dropzone").addClass("dropzone");

            var package_dropzone = new Dropzone("#package_dropzone", {
                url: "/api/blob",
                maxFiles: 1,
                addRemoveLinks: true,
                init: function () {
                    this.on("error", dropzoneDisplayServerError);
                    this.on("success", dropzoneSaveServerSideFileName);
                }
            });
            $("#package_dropzone").addClass("dropzone");

            var publication_confirmation_dropzone = new Dropzone("#publication_confirmation_dropzone", {
                url: "/api/blob",
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
                <div class="mdl-cell mdl-cell--3-col">
                    <label class="mdl-switch mdl-js-switch mdl-js-ripple-effect" for="main_publish_date_toggle">
                        <input type="checkbox" id="main_publish_date_toggle" class="mdl-switch__input">
                        <span class="mdl-switch__label">Publish Date</span>
                    </label>
                </div>

                <div class="mdl-cell mdl-cell--2-col">
                    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                        <input type="text" class="mdl-textfield__input" id="main_publish_date_from_input" disabled>
                        <label class="mdl-textfield__label" for="main_publish_date_from_input">From Year</label>
                        <span class="mdl-textfield__error">Invalid Year</span>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--2-col">
                    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                        <input type="text" class="mdl-textfield__input" id="main_publish_date_to_input" disabled>
                        <label class="mdl-textfield__label" for="main_publish_date_to_input">To Year</label>
                        <span class="mdl-textfield__error">Invalid Year</span>
                    </div>
                </div>
                <div class="mdl-cell mdl-cell--1-col"></div>
                <div class="mdl-cell mdl-cell--1-col">
                    <label class="mdl-switch mdl-js-switch mdl-js-ripple-effect" for="main_publication_category_toggle">
                        <input type="checkbox" id="main_publication_category_toggle" class="mdl-switch__input">
                        <span class="mdl-switch__label"></span>
                    </label>
                </div>
                <div class="mdl-cell mdl-cell--3-col">
                    <div class="mdl-selectfield mdl-js-selectfield mdl-selectfield--floating-label">
                        <select class="mdl-selectfield__select" id="main_publication_category_input" disabled>
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
            </div>
            <div class="mdl-grid acp-cell--vertically-centered">
                <div class="mdl-cell mdl-cell--3-col">
                    <label class="mdl-switch mdl-js-switch mdl-js-ripple-effect" for="main_has_enterprise_partnership_toggle">
                        <input type="checkbox" id="main_has_enterprise_partnership_toggle" class="mdl-switch__input">
                        <span class="mdl-switch__label">Enterprise Partnership</span>
                    </label>
                </div>

                <div class="mdl-cell mdl-cell--1-col">
                    <label class="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" for="main_has_enterprise_partnership_input">
                        <input type="checkbox" id="main_has_enterprise_partnership_input" class="mdl-checkbox__input" disabled>
                        <span class="mdl-checkbox__label"></span>
                    </label>
                </div>
                <div class="mdl-cell mdl-cell--3-col">
                    <label class="mdl-switch mdl-js-switch mdl-js-ripple-effect" for="main_has_international_coauthor_toggle">
                        <input type="checkbox" id="main_has_international_coauthor_toggle" class="mdl-switch__input">
                        <span class="mdl-switch__label">International Co-author</span>
                    </label>
                </div>

                <div class="mdl-cell mdl-cell--1-col">
                    <label class="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" for="main_has_international_coauthor_input">
                        <input type="checkbox" id="main_has_international_coauthor_input" class="mdl-checkbox__input" disabled>
                        <span class="mdl-checkbox__label"></span>
                    </label>
                </div>
                <div class="mdl-cell mdl-cell--3-col">
                    <label class="mdl-switch mdl-js-switch mdl-js-ripple-effect" for="main_is_collaborative_project_toggle">
                        <input type="checkbox" id="main_is_collaborative_project_toggle" class="mdl-switch__input">
                        <span class="mdl-switch__label">Collaborative Project</span>
                    </label>
                </div>

                <div class="mdl-cell mdl-cell--1-col">
                    <label class="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" for="main_is_collaborative_project_input">
                        <input type="checkbox" id="main_is_collaborative_project_input" class="mdl-checkbox__input" disabled>
                        <span class="mdl-checkbox__label"></span>
                    </label>
                </div>
            </div>
            <div class="mdl-grid acp-cell--vertically-centered">
                <div class="mdl-cell mdl-cell--3-col">
                    <label class="mdl-switch mdl-js-switch mdl-js-ripple-effect" for="main_peer_reviewed_toggle">
                        <input type="checkbox" id="main_peer_reviewed_toggle" class="mdl-switch__input">
                        <span class="mdl-switch__label">Peer Reviewed</span>
                    </label>
                </div>

                <div class="mdl-cell mdl-cell--1-col">
                    <label class="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" for="main_peer_reviewed_input">
                        <input type="checkbox" id="main_peer_reviewed_input" class="mdl-checkbox__input" disabled>
                        <span class="mdl-checkbox__label"></span>
                    </label>
                </div>
                <div class="mdl-cell mdl-cell--1-col">
                    <label class="mdl-switch mdl-js-switch mdl-js-ripple-effect" for="main_presentation_style_toggle">
                        <input type="checkbox" id="main_presentation_style_toggle" class="mdl-switch__input">
                        <span class="mdl-switch__label"></span>
                    </label>
                </div>

                <div class="mdl-cell mdl-cell--3-col">
                    <div class="mdl-selectfield mdl-js-selectfield mdl-selectfield--floating-label">


                        <select class="mdl-selectfield__select" id="main_presentation_style_input" disabled>
                            <option value="0">Oral Presentation</option>
                            <option value="1">Poster Presentation</option>
                            <option value="2">Demonstration</option>
                            <option value="3">None</option>
                        </select>
                        <label class="mdl-selectfield__label" for="main_presentation_style_input">Presentation Style</label>


                    </div>
                </div>
                <div class="mdl-cell mdl-cell--1-col">
                    <label class="mdl-switch mdl-js-switch mdl-js-ripple-effect" for="main_genre_toggle">
                        <input type="checkbox" id="main_genre_toggle" class="mdl-switch__input">
                        <span class="mdl-switch__label"></span>
                    </label>
                </div>
                <div class="mdl-cell mdl-cell--3-col">
                    <div class="mdl-selectfield mdl-js-selectfield mdl-selectfield--floating-label">
                        <select class="mdl-selectfield__select" id="main_genre_input" disabled>
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
                    <button type="button" id="search_paper_button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary">Search</button>
                </div>
            </div>
        </div>
    </div>
    <div class="acp-card-wide mdl-card mdl-shadow--2dp">
        <div class="mdl-card__title acp-card__actions">
            <button type="button" id="add_paper_button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary">Add</button>
            <button type="button" id="edit_paper_button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary" disabled>Edit</button>
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
            <button id="paper_dialog_confirm" type="button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary"></button>
            <button id="paper_dialog_cancel" type="button" class="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect">Cancel</button>
        </div>
    </dialog>
</asp:Content>
