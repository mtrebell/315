<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="ManageAccount.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style type="text/css">
        .UserTable
        {
            border: 1px solid #fff;
            text-align: center;
            margin-left: auto;
            margin-right: auto;
        }
        .Header {
            color: #fff;
            background-color: #000;
            border: 1px solid #fff;
        }
        .UserCell{
            color: white;
            border-bottom: 2px dashed #0b0a65;
            border-right: 2px dashed #0b0a65;
            padding: 2px 5px 2px 5px;
        }
        .DeleteButton
        {
            font-size: 120%;
            color: white;
            border-right: 5px outset #fff;
            border-left: 5px outset #fff; 
            border-top: 2px outset #fff;
            border-bottom: 2px outset #fff;

            background-color: #0e3b98;
        }
        .DeleteButton:hover
        {
            background-color: #fff;
            color: black;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
<form runat="server">
    <script language="javascript" type="text/javascript">
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

