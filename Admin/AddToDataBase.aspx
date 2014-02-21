<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="true" Async="true" AutoEventWireup="true" CodeFile="AddToDataBase.aspx.cs" Inherits="_Default" ViewStateMode="Enabled" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <script src="../Scripts/jquery-1.10.2.js" type="text/javascript"></script>
    <script src="../Scripts/jquery-ui-1.10.4.custom.js" type="text/javascript"></script> 

    <link href="../CssSheets/AddToDataBase.css" rel="stylesheet" type="text/css" /> 
    <style type="text/css">
        .Button
        {
            font-size: 120%;
            color: white;
            border-right: 5px outset #fff;
            border-left: 5px outset #fff; 
            border-top: 2px outset #fff;
            border-bottom: 2px outset #fff;
            background-color: #0e3b98;
        }
        .Button:hover
        {
            background-color: #fff;
            color: black;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
<form runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            updateProgress();
            $("#pBar").progressbar({ value: 0 });
        });

        $(document).on('drop', function (e) {
            e.stopPropagation();
            e.preventDefault();
        });

        function updateProgress() {
            $.ajax({
                type: "POST",
                url: "Admin/AddToDataBase.aspx/GetProgress",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (msg) {
                    $("#lblProgress").text(msg.d);
                    $("#pBar").progressbar({ value: msg.d });

                    if (msg.d < 100) {
                        setTimeout(updateProgress, 100);
                    }
                    else
                        $("#Cancel").attr('value', 'Back');
                },
                cache: false
            });
        }
    </script>


    <script type="text/javascript">
        function StartProcess() {
            var content = document.getElementById("HiddenList").value.toString();
            var path = '<%= ServerRootPath %>';

            var objectdata = { 'hiddenListContent': content.toString() , 'imageRootPath':  path.toString() };

            console.log(objectdata);
            $.ajax({
                type: "POST",
                url: "Admin/AddToDataBase.aspx/RunServer",
                data: JSON.stringify(objectdata),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (msg) {
                    $("#DIV_Progress").show();
                    $("#DIV_AddMedia").hide();
                },
                cache: false
            });
        }

        function CancelProcess() {
            $.ajax({
                type: "POST",
                url: "Admin/AddToDataBase.aspx/CancelServer",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (msg) {
                    $("#DIV_Progress").hide();
                    $("#DIV_AddMedia").show();
                    $("#Cancel").attr('value', 'Cancel');
                },
                cache: false
            });
        }
    </script>

    <div id="DIV_Progress" style="display: none">       
        <div class="Status">
            <div style="display:table-cell; padding-bottom: 5px;">
                <asp:Label runat="server" Text="Percentage Processed: "></asp:Label>    
                <label id="lblProgress"></label>
                <input type="button" id="Cancel" class="Button"
                     onclick="CancelProcess(); return false;" value="Cancel" />
            </div>               
        </div>
        <div id="pBar"></div>
        <br />
    </div>
    
    <div id="DIV_AddMedia">
        <div class="Status">
            <div style="display:table-cell; width: 99%; border: none;">
                <input id="HiddenList" name="HiddenList" type="hidden" />
		        <fieldset>
			        <input type="hidden" id="MAX_FILE_SIZE" name="MAX_FILE_SIZE" value="300000" />
			        <div id="filedrag" >Drop Media Files Here</div>
                </fieldset>
            </div>
            <div style="display:table-cell;">
                <input type="button" class="Button" onclick="StartProcess(); return false;" value="Add Media Content" />
            </div>
        </div> 
    </div>
    <div id="messages" style="height: 400px; width: 95%; overflow-y:scroll; margin-left: auto; margin-right: auto;"></div>
    <script src="Admin/filedrag.js" type="text/javascript"></script>
</form>
</asp:Content>

