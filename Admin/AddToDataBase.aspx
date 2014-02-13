<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" Async="true" AutoEventWireup="true" CodeFile="AddToDataBase.aspx.cs" Inherits="_Default" ViewStateMode="Enabled" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <link href="../CssSheets/AddToDataBase.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript">
        $(document).ready(function () {
            updateProgress();
            $("#pBar").progressbar({ value: 0 });
        });

        function updateProgress() {
            $.ajax({
                type: "POST",
                url: "AddToDataBase.aspx/GetProgress",
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
                },
                cache: false
            });
        }
</script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
<form runat="server">
    <div id="DIV_Progress" runat="server">       
        <div class="Status">
            <div style="display:table-cell; padding-bottom: 5px;">
                <asp:Label runat="server" Text="Percentage Processed: "></asp:Label>
                <label id="lblProgress"></label>
                <asp:Button ID="BTN_Cancel" runat="server" Text="Cancel" CssClass="Button" 
                        style="margin-left: auto;" onclick="BTN_Cancel_Click" />
            </div>               
        </div>
        <div id="pBar"></div>
        <br />
    </div>
    
    <div id="DIV_AddMedia">
        <div class="Status">
            <div style="display:table-cell; width: 99%;">
                <form id="upload" action="AddToDataBase.aspx" method="POST" enctype="multipart/form-data">
                    <input id="HiddenList" name="HiddenList" type="hidden" />
		            <fieldset>
			            <input type="hidden" id="MAX_FILE_SIZE" name="MAX_FILE_SIZE" value="300000" />
			            <div id="filedrag" >Drop Media Files Here</div>
                    </fieldset>
	            </form>
            </div>
            <div style="display:table-cell;">
                <asp:Button runat="server" Text="Add Listed" CssClass="Button"
                        id="AddSelected" OnClick="AddSelected_Click" />
            </div>
        </div>

	    <div id="messages"></div> 
    </div>
    <script src="filedrag.js" type="text/javascript"></script>
</form>
</asp:Content>

