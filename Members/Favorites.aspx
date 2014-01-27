<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Favorites.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <script id="Navigate" type="text/javascript">
        function NavigateToMoreInfoFav(index) 
        {
            window.location = "../MoreInfo.aspx?idx=" + index.toString();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
<div style="background-image: url(../Background_Images/MainBackground.jpg);" >
    <center>
    <!-- panel which holds the movie database table, dynamically created in backend -->
    <asp:Panel ID="Panel_Favorites" runat="server" Width="100%" Height="650px">
        <asp:Table ID="Table_Favorites" runat="server" >
        </asp:Table>
    </asp:Panel>
    </center>
</div>
</asp:Content>

