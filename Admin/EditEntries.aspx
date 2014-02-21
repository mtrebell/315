<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" Async="true" AutoEventWireup="true" CodeFile="EditEntries.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style type="text/css">
    .column
    {
        overflow: scroll;
        background-image: url("../Background_Images/EditEntriesBG.jpg");
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
        #dragandrophandler{
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
        $(function () {
            $('#EditTemplate').hide();

            $("#dvAccordian").accordion({
                header: "h3",
                heightStyle: "content"
            });

            $("#clearAllMedia").click(function (e) {
                e.preventDefault();
                if(confirm('Are you sure you would like to clear all media content?')) {
                    ClearDataBase();
                    return false;
                }
            });
        });

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

        function DeleteEntry(id) {
            var path = '<%= ServerRootPath %>';
            window.alert(id);
            var objectData = { 'sPath': path.toString(), 'mov_id': id };
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
                },
                cache: false
            });
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
                    document.getElementById('Acc' + movid).innerHTML
                        = document.getElementById('EditTemplate').innerHTML;

                    var array = msg["d"].toString().split('|');
                    console.log(array);

                    document.getElementById('Edit_mov_id').innerHTML = array[0].toString();
                    document.getElementById('Edit_mov_title').value = array[1].toString();
                    document.getElementById('Edit_mov_plot').value = array[2].toString();
                    document.getElementById('Edit_mov_genre').value = array[3].toString();
                    document.getElementById('Edit_mov_size').value = array[4].toString();
                    $('#Edit_mov_filetype').val(array[5].toString());
                    document.getElementById('Edit_mov_dateAdded').value = array[6].toString();
                    document.getElementById('Edit_mov_rating').value = array[7].toString();
                    document.getElementById('Edit_mov_runtime').value = array[8].toString();
                    $('#Edit_mov_lgPoster').attr("src", array[9].toString());
                    $('#Edit_mov_smPoster').attr("src", array[10].toString());
                    document.getElementById('Edit_mov_trailer').value = array[11].toString();
                    document.getElementById('Edit_mov_imdbURL').value = array[12].toString();

                    AddDropHandle();
                },
                cache: false
            });
        }

        function AddDropHandle() {
            var obj = $("#dragandrophandler1");
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

                //console.log(files[0]);
                if (files[0].type == "image/jpeg") {
                    var img = $('#Edit_mov_lgPoster');
                    var stat = $('#status1');
                    handleFileUpload(files, stat, img);
                }
            });

            var obj = $("#dragandrophandler2");
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

                //console.log(files[0]);
                if (files[0].type == "image/jpeg") {
                    var img = $('#Edit_mov_smPoster');
                    var stat = $('#status2')
                    handleFileUpload(files, stat, img);
                }
            });


            $(document).on('dragenter', function (e) {
                e.stopPropagation();
                e.preventDefault();
            });
            $(document).on('dragover', function (e) {
                e.stopPropagation();
                e.preventDefault();
                obj.css('border', '2px dotted #0B85A1');
            });
            $(document).on('drop', function (e) {
                e.stopPropagation();
                e.preventDefault();
            });
        }
    </script>

    <input type="button" id="clearAllMedia" value="Clear all media" class="Button" />
    <br />

    <div id="dvAccordian" style = "width:100%; height: 600px; overflow-y: scroll;">
        <asp:Repeater ID="rptAccordian" runat="server" ClientIDMode="Static">
            <ItemTemplate>
                <h3 id='Hdr<%#Eval("mov_id")%>'>
                    <%#Eval("mov_title")%> ~ <%# Eval("mov_id")%>
                </h3>
                <div id='Acc<%# Eval("mov_id")%>'>
                    <table>
                        <tr>
                            <td><b style="font-size: 140%;"><%#Eval("mov_title") %></b></td>
                            <td style="margin-left: auto;">
                                <input type="button" value="Edit"  id="<%# Eval("mov_id")%>Up" onclick="UpdateEntry(this.id)" />
                                <input type="button" value="Delete" id="<%# Eval("mov_id")%>" 
                                    onclick="if (confirm('Are you sure you would like to clear all media content?'))
                                                { DeleteEntry(this.id); } else return false;" />
                            </td>                           
                        </tr>
                        <tr >
                            <td style="vertical-align: top;"><b>Movie ID: <%#Eval("mov_id") %></b></td>
                            <td rowspan="2">
                                <asp:Image ID="Image2" runat="server" ImageUrl='<%#Eval("mov_lgPoster")%>' width="250" Height="300" />
                            </td>
                        </tr>
                        <tr>
                            <td><b>Plot:<br /><%#Eval("mov_plot") %></b></td>
                        </tr>
                        <tr><td colspan="2"><hr /></td></tr>
                        <tr >
                            <td style="vertical-align: top;"><b>Genre: <%#Eval("mov_genre") %></b></td>
                            <td rowspan="6">
                                <center>
                                    <asp:Image ID="Image1" runat="server" ImageUrl='<%#Eval("mov_smPoster")%>' width="100" Height="150" />
                                </center>
                            </td>
                        </tr>
                        <tr><td><b>Size: <%#Eval("mov_size") %></b></td></tr>
                        <tr><td><b>Format: <%#Eval("mov_fileType") %></b></td></tr>
                        <tr><td><b>Date Added: <%#Eval("mov_dateAdded") %></b></td></tr>
                        <tr><td><b>Rating: <%#Eval("mov_rating") %></b></td></tr>
                        <tr><td><b>Trailer Link: <%#Eval("mov_trailer") %></b></td></tr>
                        <tr><td><b>IMDb URL: <%#Eval("mov_imdbUrl") %></b></td></tr>
                    </table>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <div id="EditTemplate">
        <table style="width: 99%;">
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
                <td>Genre: </td><td><input type="text" id="Edit_mov_genre" value="" style="width: 99%;" /></td>
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
                <td colspan="2">
                    <table>
                        <tr>
                            <td style="width: 50%;">
                                <img height="250" width="200" src="" id="Edit_mov_lgPoster" /><br />
                                <div id="dragandrophandler1">Drag & Drop Files Here</div>
                                <div id="status1"></div>
                            </td>
                            <td style="width: 50%; vertical-align: central;" >
                                <img height="150" width="100" src="" id="Edit_mov_smPoster" /><br />
                                <div id="dragandrophandler2">Drag & Drop Files Here</div>
                                <div id="status2"></div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>  
    </div>

    <script type="text/javascript">

        var data;
        function sendFileToServer(formData, status, img) {
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
            $('#status1').show();
            var status = new createStatusbar(obj); //Using this we can set progress.
            status.setFileNameSize(files[0].name, files[0].size);

            sendFileToServer(fd, status, img);
        }       
</script>
</form>
</asp:Content>

