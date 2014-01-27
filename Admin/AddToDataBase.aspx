<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" Async="true" AutoEventWireup="true" CodeFile="AddToDataBase.aspx.cs" Inherits="_Default" ViewStateMode="Enabled" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <link href="../CssSheets/AddToDataBase.css" rel="stylesheet" type="text/css" />
    <script src="../Scripts/jquery-1.7.min.js" type="text/javascript"></script>
    <script src="../Scripts/ui/jquery-ui-1.8.16.custom.js" type="text/javascript"></script>
    <link href="../Scripts/themes/redmond/jquery-ui-1.8.16.custom.css" rel="stylesheet" type="text/css" />
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
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Always" runat="server">
        <ContentTemplate>
            <asp:MultiView ID="MV_AddMedia" runat="server">
                <asp:View ID="V_Progress" runat="server">
                    <div id="DIV_Progress" runat="server">
                        <div class="Status">
                            <div style="display:table-cell; padding-bottom: 5px;">
                                <asp:Label runat="server" Text="Percentage Processed: "></asp:Label>
                                <label id="lblProgress"></label>
                                <asp:Button ID="BTN_Cancel" runat="server" Text="Cancel" CssClass="Button" 
                                       style="margin-left: auto;" onclick="BTN_Cancel_Click" />
                                <asp:Button ID="BTN_Main" runat="server" Text="Main" CssClass="Button" 
                                    onclick="Button1_Click" />
                            </div>               
                        </div>
                        <div id="pBar"></div>
                        <br />
                    </div>
                </asp:View>
                <asp:View ID="V_Main" runat="server">
                    <!-- start of fairy dust (ignore all warnings, do not move javascript to head) -->
                    <form id="upload" action="AddToDataBase.aspx" method="POST" enctype="multipart/form-data">
                <input id="HiddenList" name="HiddenList" type="hidden" />
		        <fieldset>
                    <div class="Status">
                        <div style="display:table-cell; width: 99%;">
			                <input type="hidden" id="MAX_FILE_SIZE" name="MAX_FILE_SIZE" value="300000" />
			                <div id="filedrag" >Drop Media Files Here</div>
                        </div>
                        <div style="display:table-cell; ">
                            <asp:Button runat="server" Text="Add Listed" CssClass="Button" id="AddSelected" 
                                onclick="AddSelected_Click" />
                        </div>
                    </div>
                </fieldset>
	        </form>
	                <div id="messages"></div>
                    <script src="filedrag.js" type="text/javascript"></script>
                    <!-- end of fairy dust -->
                </asp:View> 
            </asp:MultiView>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

