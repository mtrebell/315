<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="true" Async="true" AutoEventWireup="true" CodeFile="AddToDataBase.aspx.cs" Inherits="_Default" ViewStateMode="Enabled" %>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
<form runat="server">
    <script src="Admin/filedrag.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            console.log("set progress bar");
            $("#pBar").progressbar({ value: 0 });
            $(".Button").button();
        });

        $(document).on('drop', function (e) {
            console.log("drop");
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
                    else {
                        $("#pBar").progressbar({ value: "0" });
                        $("#Cancel").attr('value', 'Back');
                        $('#messages').empty();
                    }
                },
                cache: false
            });
        }
    </script>

    <script type="text/javascript">
        function StartProcess() {
            var content = document.getElementById("HiddenList").value.toString();
            var path = '<%= ServerRootPath %>';

            updateProgress();

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
</form>
</asp:Content>

