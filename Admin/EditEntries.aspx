<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" Async="true" AutoEventWireup="true" CodeFile="EditEntries.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style type="text/css" >
        .column
        {
            overflow: scroll;
            background-image: url("Background_Images/EditEntriesBG.jpg");
            background-repeat:repeat;
        }
    
        .ui-accordion .ui-accordion-header {
            cursor: pointer;
            position: relative;
            margin-top: 1px;
            zoom: 1;
        }

        .ui-accordion .ui-accordion-li-fix {
            display: inline;
        }

        .ui-accordion .ui-accordion-header-active {
            border-bottom: 0 !important;
        }

        .ui-accordion .ui-accordion-header a {
            display: block;
            font-size: 1em;
            padding: .5em .5em .5em .7em;
        }

        .ui-accordion a {
            zoom: 1;
        }

        .ui-accordion-icons .ui-accordion-header a {
            padding-left: 2.2em;
        }

        .ui-accordion .ui-accordion-header .ui-icon {
            position: absolute;
            left: .5em;
            top: 50%;
            margin-top: -8px;
        }

        .ui-accordion .ui-accordion-content {
            padding: 1em 2.2em;
            border-top: 0;
            margin-top: -2px;
            position: relative;
            top: 1px;
            margin-bottom: 2px;
            overflow: auto;
            display: none;
            zoom: 1;
        }

        .ui-accordion .ui-accordion-content-active {
            display: block;
        } 
    </style>

    <style type="text/css">
        #AddEntryTemplate
        {
            border: 3px solid #92AAB0;
            padding: 5px 5px 5px 5px;
            margin-top;
        }

        .dragandrophandler{
            border:2px dotted #0B85A1;
            width:200px;
            height: 25px;
            color:#92AAB0;
            text-align: center;
            vertical-align:middle;
            padding:10px 10px 10px 10px;
            margin-bottom:10px;
            font-size: 80%;
        }

        .progressBar {
            width: 120px;
            height: 22px;
            border: 1px solid #ddd;
            border-radius: 5px; 
            overflow: hidden;
            display:inline-block;
            margin:0px 10px 5px 5px;
            vertical-align:top;
            font-size: 70%;
        }
 
        .progressBar div {
            height: 100%;
            color: #fff;
            text-align: right;
            line-height: 22px; /* same as #progressBar height if we want text middle aligned */
            width: 0;
            background-color: #0ba1b5; border-radius: 3px; 
        }
        
        .statusbar {
            border-top:1px solid #A9CCD1;
            min-height:25px;
            width:200px;
            padding:10px 10px 0px 10px;
            vertical-align:top;
        }

        .filesize
        {
            display:inline-block;
            vertical-align:top;
            color:#EBEFF0;
            width:70px;
            margin-right:5px;
            font-size: 14px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
    <form runat="server">
    <script type="text/javascript">
        var bEditModeActive = false;
        var minval = 0,
            maxval = 100,
            initvalue = 0;

        $(function () {
            $('#EditTemplate').hide();
            $('#AddEntryTemplate').hide();

            $("#dvAccordian").accordion({
                header: "h3",
                heightStyle: "content",
                active: false,
                collapsible: true,
                beforeActivate: function (event, ui) {  if (bEditModeActive) event.preventDefault(); }
            });

            $("#clearAllMedia").click(function (e) {
                e.preventDefault();
                if(confirm('Are you sure you would like to clear all media content?')) {
                    ClearDataBase();
                    return false;
                }
            });
        });

        var EditLg = { "updated": false };
        var EditSm = { "updated": false };
        function AddDropHandle() {

            addDropProperties($("#dragandrophandler1"), $('#status1'), $('#Edit_mov_lgPoster'), EditLg);
            addDropProperties($("#dragandrophandler2"), $('#status2'), $('#Edit_mov_smPoster'), EditSm);

            $(document).on('dragenter', function (e) {
                e.stopPropagation();
                e.preventDefault();
            });
            $(document).on('dragover', function (e) {
                e.stopPropagation();
                e.preventDefault();
            });
            $(document).on('drop', function (e) {
                e.stopPropagation();
                e.preventDefault();
            });
        }

        var InsertLg = { "updated": false };
        var InsertSm = { "updated": false };
        function addEntryInit() {
            $('#AddEntryTemplate').show();
            DragRemove('AddEntryTemplate');

            addDropProperties($("#dragandrophandlerAdd1"), $('#statusAdd1'), $('#Add_mov_lgPoster'), InsertLg);
            addDropProperties($("#dragandrophandlerAdd2"), $('#statusAdd2'), $('#Add_mov_smPoster'), InsertSm);

            $('#Add_mov_id').change(function () {
                var indexes = $('#hf_usedindexes').val().split('|');
                var txt = this.value;
                //console.log(indexes);
                //console.log(txt);
                var pattern = /[t][t][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/;
                //console.log(pattern.exec(txt));

                if (pattern.exec(txt) != null && $.inArray(txt, indexes) < 0) {
                    $('#Add_mov_id').attr('style', 'color: #00ff00;');
                }
                else
                    $('#Add_mov_id').attr('style', 'color: #ff0000;');
            });
        }

        function ClearDataBase() {
            var path = '<%= ServerRootPath %>';
            var objectData = { 'sPath' : path.toString() };
            $.ajax({
                type: "POST",
                url: "Admin/EditEntries.aspx/DeleteAllMedia",
                data: JSON.stringify(objectData),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (msg) {   
                },
                cache: false
            });
        }

        function AddEntry() {
            var objectData =
            {
                'mov_id': document.getElementById('Add_mov_id').value,
                'mov_title': document.getElementById('Add_mov_title').value,
                'mov_plot': document.getElementById('Add_mov_plot').value,
                'mov_genre': getCheckBoxes(document.getElementById('Add_mov_genre')).toString(),
                'mov_size': document.getElementById('Add_mov_size').value,
                'mov_fileType': $('#Add_mov_filetype').val(),
                'mov_rating': document.getElementById('Add_mov_rating').value,
                'mov_runTime': document.getElementById('Add_mov_runtime').value,
                'mov_lgPoster': $('#Add_mov_lgPoster').attr("src"),
                'mov_smPoster': $('#Add_mov_smPoster').attr("src"),
                'mov_directors': ListItemsToString('Add_mov_directors'),
                'mov_writers': ListItemsToString('Add_mov_writers'),
                'mov_cast': ListItemsToString('Add_mov_cast'),
                'mov_producers': ListItemsToString('Add_mov_producers'),
                'mov_oscars' : $('#Add_mov_oscars').val(),
	            'mov_nominations' : $('#Add_mov_nominations').val(),
	            'mov_plotkeywords' : document.getElementById('Add_mov_plotkeywords').value,
                'mov_trailer': document.getElementById('Add_mov_trailer').value,
                'mov_imdbUrl': document.getElementById('Add_mov_imdbURL').value,
                'updatedLg': InsertLg.updated,
                'updatedSm': InsertSm.updated,
                'mov_rottenID': document.getElementById('Add_mov_rottenID').value,
                'mov_rottenRating': document.getElementById('Add_mov_rottenRating').value
            };
            //console.log(objectData);
            $.ajax({
                type: "POST",
                url: "Admin/EditEntries.aspx/AddEntryDB",
                data: JSON.stringify(objectData),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (msg) {
                    var ret = msg.d.split('|');
                    var mov_id = ret[0];
                    var mov_title = ret[1];

                    document.getElementById('hf_usedindexes').value =
                        document.getElementById('hf_usedindexes').value + "|" + mov_id;

                    var head = '<h3 id="Hdr' + mov_id + '"><label id="' + mov_id + 'bt" >' + mov_title + '~' + mov_id + '</label></h3>';

                    $("#dvAccordian").append(head).append(TemplateCell(ret)).accordion('destroy').accordion();

                    clearAddTemplate();
                    $('#AddEntryTemplate').hide();

                    InsertLg.updated = false;
                    InsertSm.updated = false;
                },
                cache: false
            });
        }

        function DeleteEntry(id) {
            var path = '<%= ServerRootPath %>';
            var objectData = { 'sPath': path.toString(), 'mov_id': id };

            if (confirm("Are you sure you would like to delete this media content?")) {
                $.ajax({
                    type: "POST",
                    url: "Admin/EditEntries.aspx/DeleteEntryDB",
                    data: JSON.stringify(objectData),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: true,
                    success: function (msg) {
                        var parent = document.getElementById('dvAccordian');

                        parent.removeChild(document.getElementById('Hdr' + id));
                        parent.removeChild(document.getElementById('Acc' + id));
                        var hfIndexes = document.getElementById('hf_usedindexes').value.toString().split("|");

                        var filtered = jQuery.grep(y, function (value) {
                            return value != id;
                        });

                        var out = "";
                        for (var index in hfIndexes) {
                            out += index + "|";
                        }

                        document.getElementById('hf_usedindexes').value = out.substring(0, out.length - 1);
                    },
                    cache: false
                });
            }
        }

        function UpdateEntry(id) {
            var path = '<%= ServerRootPath %>';
            var movid = str = id.substring(0, id.length - 2);

            var objectData = { 'sPath': path.toString(), 'mov_id': movid };
            $.ajax({
                type: "POST",
                url: "Admin/EditEntries.aspx/UpdateEntryDB",
                data: JSON.stringify(objectData),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (msg) {
                    var ret = msg.d.split('|');
         
                    var objD = {
                        'mov_id': ret[0],
                        'mov_title': ret[1],
                        'mov_plot': ret[2],
                        'mov_genre': ret[3],
                        'mov_size': ret[4],
                        'mov_fileType': ret[5],
                        'mov_dateAdded': ret[6],
                        'mov_rating': ret[7],
                        'mov_runTime': ret[8],
                        'mov_lgPoster': ret[9],
                        'mov_smPoster': ret[10],
                        'mov_directors': ret[11],
                        'mov_writers': ret[12],
                        'mov_cast': ret[13],
                        'mov_producers': ret[14],
                        'mov_oscars': ret[15],
                        'mov_nominations': ret[16],
                        'mov_plotkeywords': ret[17],
                        'mov_trailer': ret[18],
                        'mov_imdbUrl': ret[19],
                        'mov_rottenID': ret[20],
                        'mov_rottenRating': ret[21]
                    };

                    console.log(objD);

                    var divHTML = document.getElementById('Acc' + objD.mov_id).innerHTML;
                    document.getElementById('Acc' + objD.mov_id).innerHTML
                        = document.getElementById('EditTemplate').innerHTML;
                    document.getElementById('EditTemplate').innerHTML = divHTML;

                    document.getElementById('Edit_mov_id').innerHTML = objD.mov_id;
                    document.getElementById('Edit_mov_title').value = objD.mov_title;
                    document.getElementById('Edit_mov_plot').value = objD.mov_plot;
                    setCheckBoxes(objD.mov_genre, document.getElementById('Edit_mov_genre'));
                    document.getElementById('Edit_mov_size').value = objD.mov_size;
                    $('#Edit_mov_filetype').val(objD.mov_fileType);
                    document.getElementById('Edit_mov_dateAdded').value = objD.mov_dateAdded;
                    document.getElementById('Edit_mov_rating').value = objD.mov_rating;
                    document.getElementById('Edit_mov_runtime').value = objD.mov_runTime;
                    $('#Edit_mov_lgPoster').attr("src", objD.mov_lgPoster);
                    $('#Edit_mov_smPoster').attr("src", objD.mov_smPoster);

                    $('#Edit_mov_directors').html(StringToListItems(objD.mov_directors, "EdDire"));
                    $('#Edit_mov_writers').html(StringToListItems(objD.mov_writers, "EdWrit"));
                    $('#Edit_mov_cast').html(StringToListItems(objD.mov_cast, "EdCast"));
                    $('#Edit_mov_producers').html(StringToListItems(objD.mov_producers, "EdProd"));

                    $('#Edit_mov_oscars').val(parseInt(objD.mov_oscars));
                    $('#Edit_mov_nominations').val(parseInt(objD.mov_nominations));
                    document.getElementById('Edit_mov_plotkeywords').value = objD.mov_plotkeywords;

                    document.getElementById('Edit_mov_trailer').value = objD.mov_trailer;
                    document.getElementById('Edit_mov_imdbURL').value = objD.mov_imdbUrl;
                    document.getElementById('Edit_mov_rottenID').value = objD.mov_rottenID;
                    document.getElementById('Edit_mov_rottenRating').value = objD.mov_rottenRating;

                    AddDropHandle();
                    DragRemove('EditTemplate');
                    bEditModeActive = true;
                },
                cache: false
            });
        }

        function commitUpdate() {
            var path = '<%= ServerRootPath %>';

            console.log(EditLg.updated + ":" + EditSm.updated);
            var objectData =
            {
                'mov_id': document.getElementById('Edit_mov_id').innerHTML,
                'mov_title': document.getElementById('Edit_mov_title').value,
                'mov_plot': document.getElementById('Edit_mov_plot').value,
                'mov_genre': getCheckBoxes(document.getElementById('Edit_mov_genre')).toString(),
                'mov_size': document.getElementById('Edit_mov_size').value,
                'mov_fileType': $('#Edit_mov_filetype').val(),
                'mov_dateAdded': document.getElementById('Edit_mov_dateAdded').value,
                'mov_rating': document.getElementById('Edit_mov_rating').value,
                'mov_runTime': document.getElementById('Edit_mov_runtime').value,
                'mov_lgPoster': $('#Edit_mov_lgPoster').attr("src"),
                'mov_smPoster': $('#Edit_mov_smPoster').attr("src"),
                'mov_directors': ListItemsToString('Edit_mov_directors'),
                'mov_writers': ListItemsToString('Edit_mov_writers'),
                'mov_cast': ListItemsToString('Edit_mov_cast'),
                'mov_producers': ListItemsToString('Edit_mov_producers'),
                'mov_oscars': $('#Edit_mov_oscars').val(),
                'mov_nominations': $('#Edit_mov_nominations').val(),
                'mov_plotkeywords': document.getElementById('Edit_mov_plotkeywords').value,
                'mov_trailer': document.getElementById('Edit_mov_trailer').value,
                'mov_imdbUrl': document.getElementById('Edit_mov_imdbURL').value,
                'updatedLg': EditLg.updated,
                'updatedSm': EditSm.updated,
                'mov_rottenID': document.getElementById('Edit_mov_rottenID').value,
                'mov_rottenRating': document.getElementById('Edit_mov_rottenRating').value
            };

            $.ajax({
                type: "POST",
                url: "<%= ResolveUrl("EditEntries.aspx/commitUpdateDB") %>",
                data: JSON.stringify(objectData),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (msg) {

                    var ret = msg.d.split('|');
                    
                    var mov_id = ret[0];

                    var div = new String(document.getElementById('Acc' + mov_id).innerHTML.toString());
                    document.getElementById('EditTemplate').innerHTML = div;
                    clearEditTemplate();

                    document.getElementById('Acc' + mov_id).innerHTML = TemplateCell(ret).toString();
                    $('#dvAccordian').accordion('destroy').accordion();
                    EditLg.updated = false;
                    EditSm.updated = false;
                    bEditModeActive = false;
                },
                cache: false
            });
        }

        // ---------------------------------------------------------------------------
        // support functions ---------------------------------------------------------
        // ---------------------------------------------------------------------------

        function addDropProperties(obj, stat, img, updated)
        {
            obj.on('dragenter', function (e) {
                e.stopPropagation();
                e.preventDefault();
                $(this).css('border', '2px solid #fff');
            });

            obj.on('dragover', function (e) {
                e.stopPropagation();
                e.preventDefault();
            });

            obj.on('drop', function (e) {
                $(this).css('border', '2px dotted #0B85A1');
                e.preventDefault();
                var files = e.originalEvent.dataTransfer.files;

                if (files[0].type == "image/jpeg") {
                    updated.updated = true;
                    handleFileUpload(files, stat, img);
                }
            });
        }

        function getCheckBoxes(chkBoxLst)
        {
            var val = [];
            $('#' + chkBoxLst.id).find('input[type=checkbox]:checked').each(function () {
                val.push($(this).val());
            });
            return (val.join(','));
        }

        function setCheckBoxes(items, chkBoxLst) {
            var values = items.toString().split(",");
            $('#' + chkBoxLst.id).find('input[type=checkbox]').each(function () {
                var comp = this.value.toString().toLowerCase().trim();
                for (var i = 0; i < values.length; i++) {
                    var val = values[i].toString().toLowerCase().trim();
                    if (comp == val && val != "") {
                        $(this).prop('checked', true);
                    }
                }
            });
        }

        function cancelUpdate()
        {
            var mov_id = document.getElementById('Edit_mov_id').innerHTML;
            clearEditTemplate();
            var div = new String(document.getElementById('Acc' + mov_id).innerHTML.toString());

            document.getElementById('Acc' + mov_id).innerHTML
                = document.getElementById('EditTemplate').innerHTML;

            document.getElementById('EditTemplate').innerHTML = div;
            bEditModeActive = false;
        }

        function cancelInsert() {
            clearAddTemplate();
            $('#AddEntryTemplate').hide();
        }

        function clearAddTemplate()
        {
            document.getElementById('Add_mov_id').value = "";
            document.getElementById('Add_mov_title').value = "";
            document.getElementById('Add_mov_plot').value = "";
            document.getElementById('Add_mov_genre').value = "";
            document.getElementById('Add_mov_size').value = "";
            $('#Add_mov_filetype').val(".wmv");
            document.getElementById('Add_mov_rating').value = "";
            document.getElementById('Add_mov_runtime').value = "";
            $('#Add_mov_lgPoster').attr("src", "");
            $('#Add_mov_smPoster').attr("src", "");
            document.getElementById('Add_mov_trailer').value = "";
            document.getElementById('Add_mov_imdbURL').value = "";
            document.getElementById('Add_mov_rottenID').value = "";
            document.getElementById('Add_mov_rottenRating').value = "";
            $('#Add_mov_directors').html("");
            $('#Add_mov_writers').html("");
            $('#Add_mov_cast').html("");
            $('#Add_mov_producers').html("");
            $('#Add_mov_oscars').val(0);
            $('#Add_mov_nominations').val(0);
            document.getElementById('Add_mov_plotkeywords').value = "";
        }

        function clearEditTemplate()
        {
            document.getElementById('Edit_mov_id').innerHTML = "";
            document.getElementById('Edit_mov_title').value = "";
            document.getElementById('Edit_mov_plot').value = "";
            document.getElementById('Edit_mov_genre').value = "";
            document.getElementById('Edit_mov_size').value = "";
            $('#Edit_mov_filetype').val("");
            document.getElementById('Edit_mov_dateAdded').value = "";
            document.getElementById('Edit_mov_rating').value = "";
            document.getElementById('Edit_mov_runtime').value = "";
            $('#Edit_mov_lgPoster').attr("src", "");
            $('#Edit_mov_smPoster').attr("src", "");
            document.getElementById('Edit_mov_trailer').value = "";
            document.getElementById('Edit_mov_imdbURL').value = "";
            document.getElementById('Edit_mov_rottenID').value = "";
            document.getElementById('Edit_mov_rottenRating').value = "";
            $('#Edit_mov_directors').html("");
            $('#Edit_mov_writers').html("");
            $('#Edit_mov_cast').html("");
            $('#Edit_mov_producers').html("");
            $('#Edit_mov_oscars').val(0);
            $('#Edit_mov_nominations').val(0);
            document.getElementById('Edit_mov_plotkeywords').value = "";
        }

        // #region  sendFileToServer
        function sendFileToServer(formData, status, img) {
            var data;
            var uploadURL = "<%= ResolveUrl("AjaxPosterHandler.ashx") %>"; //Upload URL
            var extraData = {}; //Extra Data.
            var jqXHR = $.ajax({
                xhr: function () {
                    var xhrobj = $.ajaxSettings.xhr();
                    if (xhrobj.upload) {
                        xhrobj.upload.addEventListener('progress', function (event) {
                            var percent = 0;
                            var position = event.loaded || event.position;
                            var total = event.total;
                            if (event.lengthComputable) {
                                percent = Math.ceil(position / total * 100);
                            }
                            //Set progress
                            status.setProgress(percent);
                        }, false);
                    }
                    return xhrobj;
                },
                url: uploadURL,
                type: "POST",
                contentType: false,
                processData: false,
                cache: false,
                data: formData,
                success: function (data) {
                    status.setProgress(100);
                    console.log(data);
                    img.attr('src', data);
                }
            });
        }
        // #endregion

        function createStatusbar(obj) {
            this.statusbar = $("<div class='statusbar'></div>");
            this.size = $("<div class='filesize'></div>").appendTo(this.statusbar);
            this.progressBar = $("<div class='progressBar'><div></div></div>").appendTo(this.statusbar);
            obj.html = this.statusbar;

            this.setFileNameSize = function (name, size) {
                var sizeStr = "";
                var sizeKB = size / 1024;
                if (parseInt(sizeKB) > 1024) {
                    var sizeMB = sizeKB / 1024;
                    sizeStr = sizeMB.toFixed(2) + " MB";
                }
                else {
                    sizeStr = sizeKB.toFixed(2) + " KB";
                }

                this.size.html(sizeStr);
            }
            this.setProgress = function (progress) {
                var progressBarWidth = progress * this.progressBar.width() / 100;
                this.progressBar.find('div').animate({ width: progressBarWidth }, 10).html(progress + "% ");
                if (progress == 100)
                    obj.hide();
            }
        }

        function handleFileUpload(files, obj, img) {
            var fd = new FormData();
            fd.append('file', files[0]);
            obj.show();
            var status = new createStatusbar(obj); //Using this we can set progress.
            status.setFileNameSize(files[0].name, files[0].size);

            sendFileToServer(fd, status, img);
        }

        function DragRemove(objName)
        {
            $('#' + objName).on('dragenter', function (e) {
                e.stopPropagation();
                e.preventDefault();
            });
            $('#' + objName).on('dragover', function (e) {
                e.stopPropagation();
                e.preventDefault();
            });
            $('#' + objName).on('drop', function (e) {
                e.stopPropagation();
                e.preventDefault();
            });
        }

        function TemplateCell(ret) {
            var objD = {
                'mov_id': ret[0],
                'mov_title': ret[1],
                'mov_plot': ret[2],
                'mov_genre': ret[3],
                'mov_size': ret[4],
                'mov_fileType': ret[5],
                'mov_dateAdded': ret[6],
                'mov_rating': ret[7],
                'mov_runTime': ret[8],
                'mov_lgPoster': ret[9],
                'mov_smPoster': ret[10],
                'mov_directors': ret[11],
                'mov_writers': ret[12],
                'mov_cast': ret[13],
                'mov_producers': ret[14],
                'mov_oscars': ret[15],
                'mov_nominations': ret[16],
                'mov_plotkeywords': ret[17],
                'mov_trailer': ret[18],
                'mov_imdbUrl': ret[19],
                'mov_rottenID': ret[20],
                'mov_rottenRating': ret[21]
            };

            var accord = '<div id="Acc' + objD.mov_id + '">'
                + '<table><tr>'
                +     '<td><label id="' + objD.mov_id + 'bt" style="font-size: 140%;">' + objD.mov_title + '</label></td>'
                +     '<td style="margin-left: auto;">' 
                +         '<input type="button" value="Edit"  id="' + objD.mov_id + 'Up" onclick="UpdateEntry(this.id)" class="Button" />'
                +         '<input type="button" value="Delete" id="' + objD.mov_id + '" class="Button" onclick="DeleteEntry(this.id);  return false;" />'
                +     '</td>'
                + '</tr><tr>'
                +     '<td style="vertical-align: top;"><b>Movie ID: ' + objD.mov_id + '</b></td>'
                +     '<td rowspan="3"><img id="' + objD.mov_id + 'iL" src="' + objD.mov_lgPoster + '" style="width: 200px; height: 300px;" /></td>' 
                + '</tr><tr>' 
                +     '<td><b>Plot: </b><br /><label id="' + objD.mov_id + 'bp">' + objD.mov_plot + '</label></td>'
                + '</tr><tr>'
                +      '<td>Plot Keywords: <label id="' + objD.mov_id + 'pk">' + objD.mov_plotkeywords + '</label></td>'
                + '</tr><tr><td colspan="2"><hr /></td></tr>'
                + '<tr>'
                +     '<td style="vertical-align: top;"><b>Genre: </b><label id="' + objD.mov_id + 'bg">' + objD.mov_genre + '</label></td>'
                +     '<td rowspan="6"><center><img id="' + objD.mov_id + 'iS" src="' + objD.mov_smPoster + '" style="width:100px; Height:150px" /></center></td>'
                + '</tr><tr>'
                +     '<td><label id="' + objD.mov_id + 'bs">Size: ' + objD.mov_size + '</label></td>'
                + '</tr><tr>'
                +     '<td><label id="' + objD.mov_id + 'bf">Format: ' + objD.mov_fileType + '</label></td>'
                + '</tr><tr>'
                +     '<td><label id="' + objD.mov_id + 'bm">Runtime: ' + objD.mov_runTime + '</label></td>'
                + '</tr><tr>'
                +     '<td><label id="' + objD.mov_id + 'bd">Date Added: ' + objD.mov_dateAdded + '</label></td>'
                + '</tr><tr>'
                +     '<td><label id="' + objD.mov_id + 'br">Rating: ' + objD.mov_rating + '</label></td>'
                + '</tr><tr>'
                +     '<td><label id="' + objD.mov_id + 'be">Trailer Link:' + objD.mov_trailer + '</label></td>'
                + '</tr><tr>'
                +     '<td><label id="' + objD.mov_id + 'bi">IMDb URL: ' + objD.mov_imdbUrl + '</label></td>'
                + '</tr><tr>'
                +     '<td><label id="' + objD.mov_id + 'bo">Rotten ID: '+ objD.mov_rottenID + '</label></td>'
                +     '<td><label id="' + objD.mov_id + 'bt">Rotten Rating: ' + objD.mov_rottenRating + '</label></td>'
                + '</tr><tr style="vertical-align: middle; padding-top: 10px;">'
                +     '<td>'
                +          '<img src="Background_Images/Oscar_IMG.png" width="45" height="75" />'
                +          '<label id="' + objD.mov_id + 'os">Oscars: '+ objD.mov_oscars + '</label>'
                +     '</td><td>'
                +          '<img src="Background_Images/Nomination_IMG.png" width="45" height="75" />'
                +          '<label id="' + objD.mov_id + 'nm">Nominations: '+ objD.mov_nominations + '</label></td>'
                + '</tr><tr style="vertical-align: top; padding-top: 10px;">'
                +     '<td><label id="' + objD.mov_id + 'dr">Directors: ' + objD.mov_directors + '</label></td>'
                +     '<td><label id="' + objD.mov_id + 'ct">Cast: ' + objD.mov_cast + '</label></td>'
                + '</tr><tr style="vertical-align: top; padding-top: 10px;">'
                +     '<td><label id="' + objD.mov_id + 'wt">Writers: ' + objD.mov_writers + '</label></td>'
                +     '<td><label id="' + objD.mov_id + 'pr">Producers: ' + objD.mov_producers + '</label></td>'
                + '</tr></tr></table></div>';
            return accord;
        }

        function ListItemsToString(orderedListID) {
            var out = "";
            $('#' + orderedListID).children().each(function () {
                out += $(this).attr("value") + ",";
            });
            out = out.substring(0, out.length - 1);
            console.log(out);
            return out;
        }

        function StringToListItems(strItems, uniqueid) {
            var olHtml = "";
            var items = strItems.split(',');
            console.log(items);
            for (var count in items)
                olHtml += '<li id="' + uniqueid + count + '" value="' + items[count]
                    + '" onclick="RemoveMe(this.id)">' + items[count] + '</li>';
            return olHtml;
        }

        function RemoveMe(id)
        {
            $('#' + id).remove();
        }

        var idGen = 0;
        function AddType(type, option)
        {
            var text;
            var list;
            switch (type)
            {
                case 'director':

                    if (option == 'add') {
                        text = document.getElementById('Add_director').value;
                        list = '#Add_mov_directors';
                    }
                    else
                    {
                        text = document.getElementById('Edit_director').value;
                        list = '#Edit_mov_directors';
                    }
                    break;

                case 'cast':

                    if (option == 'add') {
                        text = document.getElementById('Add_cast').value;
                        list = '#Add_mov_cast';
                    }
                    else {
                        text = document.getElementById('Edit_cast').value;
                        list = '#Edit_mov_cast';
                    }
                    break;

                case 'writer':
                    if (option == 'add') {
                        text = document.getElementById('Add_writer').value;
                        list = '#Add_mov_writers';
                    }
                    else {
                        text = document.getElementById('Edit_writer').value;
                        list = '#Edit_mov_writers';
                    }
                    break;

                case 'producer':
                    if (option == 'add') {
                        text = document.getElementById('Add_producer').value;
                        list = '#Add_mov_producers';
                    }
                    else {
                        text = document.getElementById('Edit_producer').value;
                        list = '#Edit_mov_producers';
                    }
                    break;
            }

            $(list).append('<li id="MyAdd' + idGen + '" value="'
                + text + '"onclick="RemoveMe(this.id)">' + text + '</li>');
            idGen++;
        }
    </script>

    <asp:HiddenField ID="hf_usedindexes" runat="server" ClientIDMode="Static"/>

    <input type="button" id="clearAllMedia" value="Clear all media" class="Button" />

    <input type="button" id="addEntryMedia" value="Add Manual Entry" class="Button" 
        onclick="addEntryInit(); return false;" style="margin-left: auto;" />
    <br />
    <div id="AddEntryTemplate">
        <table style="width: 99%;">
            <tr>
                <td><input type="button" id="InsertBTN" value="Insert" onclick="AddEntry(); return false;" class="Button" /></td>
                <td><input type="button" id="CancelInBTN" value="Cancel" onclick="cancelInsert(); return false;" class="Button" /></td>
            </tr>
            <tr>
                <td>Movie ID: </td><td><input type="text" id="Add_mov_id" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td>Movie Title: </td><td><input type="text" id="Add_mov_title" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td colspan="2">Plot:
                    <br /><textarea id="Add_mov_plot" rows="10" cols="50" style="width: 99%;"></textarea></td>
            </tr>
            <tr>
                <td>Genre: </td>
                <td><asp:CheckBoxList ID="Add_mov_genre" runat="server" ClientIDMode="Static" RepeatColumns ="3" /></td>
            </tr>
            <tr>
                <td>Movie Size:</td><td><input type="text" id="Add_mov_size" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td>Movie Format: </td>
                <td>
                    <select id="Add_mov_filetype" style="width: 99%;">
                        <option value=".wmv">.wmv</option>
                        <option value=".mkv">.mkv</option>
                        <option value=".avi">.avi</option>
                        <option value=".divx">.divx</option>
                        <option value=".xvid">.xvid</option>
                        <option value=".mp4">.mp4</option>
                        <option value=".mpeg">.mpeg</option>
                        <option value=".h264">.h264</option>
                        <option value=".x264">.x264</option>
                        <option value=".m2ts">.m2ts</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>Rating: </td><td><input type="text" id="Add_mov_rating" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td>RunTime (minutes): </td><td><input type="text" id="Add_mov_runtime" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td>trailer link: </td><td><input type="text" id="Add_mov_trailer" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td>IMDb URL: </td><td><input type="text" id="Add_mov_imdbURL" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td>Plot Keywords: </td><td><input type="text" id="Add_mov_plotkeywords" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td colspan="2">
                    <hr />
                    <table >
                        <tr>
                            <td style="vertical-align: bottom; text-align: center;">
                                <img height="250" width="200" src="" id="Add_mov_lgPoster" /><br />
                                <div id="dragandrophandlerAdd1" class="dragandrophandler">Drag & Drop Files Here</div>
                                <div id="statusAdd1"></div>
                            </td>
                            <td style="padding-left: 20px; vertical-align: bottom; text-align: center;" >
                                <img height="150" width="100" style="align-self:center;" src="" id="Add_mov_smPoster" /><br />
                                <div id="dragandrophandlerAdd2" class="dragandrophandler">Drag & Drop Files Here</div>
                                <div id="statusAdd2"></div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td><label>Rotten ID: </label></td>
                <td><input type="text" id="Add_mov_rottenID" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td><label>Rotten Rating: </label></td>
                <td><input type="text" id="Add_mov_rottenRating" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td><img src="Background_Images/Oscar_IMG.png" width="30" height="75" /><label>Oscars: </label></td>
                <td><input id="Add_mov_oscars"/></td>
            </tr>
            <tr>
                <td><img src="Background_Images/Nomination_IMG.png" width="30" height="75" /><label>Nominations: </label></td>
                <td><input id="Add_mov_nominations"/></td>
            </tr>
            <tr>
                <td style="vertical-align: top;">
                    <label>Directors</label><ol id="Add_mov_directors"></ol>
                    <input type="text" id="Add_director" /><input type="button" value="Add" class="Button"  onclick="AddType('director', 'add');" /> 
                </td>
                <td style="vertical-align: top;">
                    <label>Cast</label><ol id="Add_mov_cast"></ol>
                    <input type="text" id="Add_cast" /><input type="button" value="Add" class="Button"  onclick="AddType('cast', 'add');" /> 
                </td>
            </tr>
            <tr>
                <td style="vertical-align: top;">
                    <label>Writers</label><ol id="Add_mov_writers"></ol>
                    <input type="text" id="Add_writer" /><input type="button" value="Add" class="Button"  onclick="AddType('writer', 'add');" /> 
                </td>
                <td style="vertical-align: top;">
                    <label>Producers</label><ol id="Add_mov_producers"></ol>
                    <input type="text" id="Add_producer" /><input type="button" value="Add" class="Button"  onclick="AddType('producer', 'add');" /> 
                </td>
            </tr>
        </table>  
    </div>

    <div id="dvAccordian" style = "width:100%; height: 600px; overflow-y: scroll;">
        <asp:Repeater ID="rptAccordian" runat="server" ClientIDMode="Static">
            <ItemTemplate>
                <h3 id='Hdr<%#Eval("mov_id")%>'>
                    <%#Eval("mov_title")%> ~ <%# Eval("mov_id")%>
                </h3>
                <div id='Acc<%# Eval("mov_id")%>'>
                    <table>
                        <tr>
                            <td><label id="<%#Eval("mov_id")%>bt" style="font-size: 140%;"><%#Eval("mov_title") %></label></td>
                            <td style="margin-left: auto;">
                                <input type="button" value="Edit"  id="<%# Eval("mov_id")%>Up" onclick="UpdateEntry(this.id)" class="Button" />
                                <input type="button" value="Delete" id="<%# Eval("mov_id")%>" class="Button" 
                                    onclick=" DeleteEntry(this.id); return false;" />
                            </td>                           
                        </tr>
                        <tr >
                            <td style="vertical-align: top;"><b>Movie ID: <%#Eval("mov_id") %></b></td>
                            <td rowspan="3">
                                <img id="<%# Eval("mov_id")%>iL" src='<%#Eval("mov_lgPoster").ToString().Replace("~/","")%>' 
                                    style="width: 200px; height: 300px;" />
                            </td>
                        </tr>
                        <tr>
                            <td><b>Plot: </b><br />
                                <label id="<%# Eval("mov_id")%>bp"><%#Eval("mov_plot") %></label></td>
                        </tr>
                        <tr>
                            <td>Plot Keywords: <label id="<%# Eval("mov_id")%>pk"><%# Eval("mov_plotkeywords")%></label></td>
                        </tr>
                        <tr><td colspan="2"><hr /></td></tr>
                        <tr >
                            <td style="vertical-align: top;"><b>Genre: </b>
                                <label id="<%# Eval("mov_id")%>bg"><%#Eval("mov_genre") %></label></td>
                            <td rowspan="6">
                                <center>
                                    <img id="<%# Eval("mov_id")%>iS" src='<%#Eval("mov_smPoster").ToString().Replace("~/","")%>' 
                                        style="width:100px; Height:150px" />
                                </center>
                            </td>
                        </tr>
                        <tr><td><label id="<%# Eval("mov_id")%>bs">Size: <%#Eval("mov_size") %></label></td></tr>
                        <tr><td><label id="<%# Eval("mov_id")%>bf">Format: <%#Eval("mov_fileType") %></label></td></tr>
                        <tr><td><label id="<%# Eval("mov_id")%>bm">Runtime: <%#Eval("mov_runTime") %></label></td></tr>
                        <tr><td><label id="<%# Eval("mov_id")%>bd">Date Added: <%#Eval("mov_dateAdded") %></label></td></tr>
                        <tr><td><label id="<%# Eval("mov_id")%>br">Rating: <%#Eval("mov_rating") %></label></td></tr>
                        <tr><td><label id="<%# Eval("mov_id")%>be">Trailer Link: <%#Eval("mov_trailer") %></label></td></tr>
                        <tr><td><label id="<%# Eval("mov_id")%>bi">IMDb URL: <%#Eval("mov_imdbUrl") %></label></td></tr>
                        <tr>
                            <td><label id="<%# Eval("mov_id")%>bo">Rotten ID: <%#Eval("mov_rottenID") %></label></td>
                            <td><label id="<%# Eval("mov_id")%>bt">Rotten Rating: <%#string.Format("{0:F1}", Eval("mov_rottenRating")) %></label></td>
                        </tr>
                        <tr style="vertical-align: middle; padding-top: 10px;">
                            <td><img src="Background_Images/Oscar_IMG.png" width="45" height="75" /><label id="<%# Eval("mov_id")%>os">Oscars: <%#Eval("mov_oscars") %></label></td>
                            <td><img src="Background_Images/Nomination_IMG.png" width="45" height="75" /><label id="<%# Eval("mov_id")%>nm">Nominations: <%#Eval("mov_nominations") %></label></td>
                        </tr>
                        <tr style="vertical-align: top; padding-top: 10px;">
                            <td><label id="<%# Eval("mov_id")%>dr">Directors: <%#Eval("mov_directors") %> </label></td>
                            <td><label id="<%# Eval("mov_id")%>ct">Cast: <%#Eval("mov_cast") %> </label></td>
                        </tr>
                        <tr style="vertical-align: top; padding-top: 10px;">
                            <td><label id="<%# Eval("mov_id")%>wt">Writers: <%#Eval("mov_writers") %> </label></td>
                            <td><label id="<%# Eval("mov_id")%>pr">Producers: <%#Eval("mov_producers") %> </label></td>
                        </tr>
                    </table>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <div id="EditTemplate">
        <table style="width: 99%;">
            <tr>
                <td><input type="button" id="UpdateBTN" value="Update" onclick="commitUpdate(); return false;" class="Button" /></td>
                <td><input type="button" id="CancelBTN" value="Cancel" 
                    onclick="cancelUpdate(); return false;" class="Button" /></td>
            </tr>
            <tr>
                <td>Movie ID: </td><td><label id="Edit_mov_id" style="color: white;"></label></td>
            </tr>
            <tr>
                <td>Movie Title: </td><td><input type="text" id="Edit_mov_title" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td colspan="2">Plot:
                    <br /><textarea id="Edit_mov_plot" rows="10" cols="50" style="width: 99%;"></textarea></td>
            </tr>
            <tr>
                <td>Genre: </td>
                <td><asp:CheckBoxList ID="Edit_mov_genre" runat="server" ClientIDMode="Static"  RepeatColumns ="3" /></td>
            </tr>
            <tr>
                <td>Movie Size:</td><td><input type="text" id="Edit_mov_size" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td>Movie Format: </td>
                <td>
                    <select id="Edit_mov_filetype" style="width: 99%;">
                        <option value=".wmv">.wmv</option>
                        <option value=".mkv">.mkv</option>
                        <option value=".avi">.avi</option>
                        <option value=".divx">.divx</option>
                        <option value=".xvid">.xvid</option>
                        <option value=".mp4">.mp4</option>
                        <option value=".mpeg">.mpeg</option>
                        <option value=".h264">.h264</option>
                        <option value=".x264">.x264</option>
                        <option value=".m2ts">.m2ts</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>Date Added: </td><td><input type="text" id="Edit_mov_dateAdded" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td>Rating: </td><td><input type="text" id="Edit_mov_rating" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td>RunTime (minutes): </td><td><input type="text" id="Edit_mov_runtime" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td>trailer link: </td><td><input type="text" id="Edit_mov_trailer" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td>IMDb URL: </td><td><input type="text" id="Edit_mov_imdbURL" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td>Plot Keywords: </td><td><input type="text" id="Edit_mov_plotkeywords" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td colspan="2">
                    <hr />
                    <table >
                        <tr>
                            <td style="vertical-align: bottom; text-align: center;">
                                <img height="250" width="200" src="" id="Edit_mov_lgPoster" /><br />
                                <div id="dragandrophandler1" class="dragandrophandler">Drag & Drop Files Here</div>
                                <div id="status1"></div>
                            </td>
                            <td style="padding-left: 20px; vertical-align: bottom; text-align: center;" >
                                <img height="150" width="100" style="align-self:center;" src="" id="Edit_mov_smPoster" /><br />
                                <div id="dragandrophandler2" class="dragandrophandler">Drag & Drop Files Here</div>
                                <div id="status2"></div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td><label>Rotten ID: </label></td><td><input type="text" id="Edit_mov_rottenID" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td><label>Rating: </label></td><td><input type="text" id="Edit_mov_rottenRating" value="" style="width: 99%;" /></td>
            </tr>
            <tr>
                <td><img src="Background_Images/Oscar_IMG.png" width="70" height="75" /><label>Oscars:</label></td>
                <td><input id="Edit_mov_oscars" type="number" style="display: inline;"/></td>
            </tr>
            <tr>
                <td><img src="Background_Images/Nomination_IMG.png" width="70" height="75" /><label>Nominations:</label></td>
                <td><input id="Edit_mov_nominations" type="number" style="display: inline;" /></td>
            </tr>
            <tr>
                <td style="vertical-align: top;">
                    <label>Directors</label><ol id="Edit_mov_directors"></ol>
                    <input type="text" id="Edit_director" /><input type="button" value="Add" class="Button"  onclick="AddType('director', 'edit');" /> 
                </td>
                <td style="vertical-align: top;">
                    <label>Cast</label><ol id="Edit_mov_cast"></ol>
                    <input type="text" id="Edit_cast" /><input type="button" value="Add" class="Button"  onclick="AddType('cast', 'edit');" /> 
                </td>
            </tr>
            <tr>
                <td style="vertical-align: top;">
                    <label>Writers</label><ol id="Edit_mov_writers"></ol>
                    <input type="text" id="Edit_writer" /><input type="button" value="Add" class="Button"  onclick="AddType('writer', 'edit');" /> 
                </td>
                <td style="vertical-align: top;">
                    <label>Producers</label><ol id="Edit_mov_producers"></ol>
                    <input type="text" id="Edit_producer" /><input type="button" value="Add" class="Button"  onclick="AddType('producer', 'edit');" /> 
                </td>
            </tr>
        </table>  
    </div>

    <script type="text/javascript">
       
</script>
</form>
</asp:Content>

