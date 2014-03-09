<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Request.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <script type="text/javascript">
        $(function () {
            $(".Button").button();
        });

        function DeleteRequest(request_id) {
            objectData = { 'request_id': request_id }

            $.ajax({
                type: "POST",
                url: "Members/Request.aspx/DeleteRequest",
                data: JSON.stringify(objectData),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (msg) {
                    var tr = $("#" + msg.d).closest('tr');
                    tr.css("background-color", "#fefefe");
                    tr.fadeOut(400, function () {
                        tr.remove();
                    });
                    return false;
                },
                cache: false
            });
        }

        function InsertRequest() {
            objectData = { 'sTitle': document.getElementById('TB_Request').value }
            console.log("Insert Request");
            $.ajax({
                type: "POST",
                url: "Members/Request.aspx/InsertRequest",
                data: JSON.stringify(objectData),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (msg) {
                    $('#RequestTable').append(msg.d);
                },
                cache: false
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
<div style="min-height: 300px; width: 100%;">

    <label>Request</label>
    <input type="text" id="TB_Request" style="margin-left: 10px; margin-right: 10px;" /><input type="button" class="Button" value="Add Request" 
        onclick="InsertRequest(); return false;" />
    <table id="RequestTable" style="width: 100%; text-align: center;">
        <thead>
            <% if (this.User.IsInRole("Administrator")) { %>
                <th style="">User ID</th>
            <% } %>
            <th style="">User Name</th>
            <th style="">Request Date</th>
            <th style="">Request Title</th>
            <% if (this.User.IsInRole("Administrator")) { %>
                <th style="">Option</th>
            <% } %>
        </thead>
        <tbody>
            <asp:Repeater ID="rptAccordian" runat="server" ClientIDMode="Static">
                <ItemTemplate>
                    <tr id="<%# Eval("request_id") %>tr">
                        <% if (this.User.IsInRole("Administrator")) { %>
                            <td><asp:Label runat="server" ><%# Eval("request_id") %></asp:Label></td>
                        <% } %>
                        <td><asp:Label runat="server" Text='<%# Eval("UserName") %>' /></td>
                        <td><asp:Label runat="server" Text='<%# Eval("requestDate") %>' /></td>
                        <td><asp:Label runat="server" Text='<%# Eval("requestTitle") %>' /></td>
                        <% if (this.User.IsInRole("Administrator")) { %>
                            <td><input type="button" id="<%# Eval("request_id") %>" class="Button" value="Delete" 
                                onclick="DeleteRequest(this.id); return false;" /></td>
                        <% } %>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </tbody>
    </table>
</div>
</asp:Content>
