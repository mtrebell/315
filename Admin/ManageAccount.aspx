<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="ManageAccount.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
<form runat="server">
    <script language="javascript" type="text/javascript">
        $(function () {
            $(".Button").button();
        });

        function RemoveRow(index, uID, uN)
        {
            var objectdata = { 'sUserID': uID, 'sUserName': uN };
            
            console.log(objectdata);
            $.ajax({
                type: "POST",
                url: "Admin/ManageAccount.aspx/DeleteUser",
                data: JSON.stringify(objectdata),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (msg) {
                    var rowDelete = document.getElementById(index);
                    var parent = rowDelete.parentElement;
                    parent.removeChild(rowDelete);
                },
                cache: false
            });
        }
    </script>
    <asp:table id="UserTable" runat="server" Width="500" CssClass="UserTable" >
        <asp:TableHeaderRow>
            <asp:TableCell CssClass="Header">User ID</asp:TableCell>
            <asp:TableCell CssClass="Header">User Name</asp:TableCell>
            <asp:TableCell CssClass="Header">Date Added</asp:TableCell>
            <asp:TableCell CssClass="Header">Delete User</asp:TableCell>
        </asp:TableHeaderRow>
    </asp:table>
</form>
</asp:Content>

