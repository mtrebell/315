<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="BuildModel.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="../Scripts/jquery-1.10.2.js"></script>
    <script>
        var recomeded;

        console.log("Running");
        $.ajax({
            type: "POST",
            url: "Recomend.aspx/buildModel",
            data: "{}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (result) {
                recomended = result;
                console.log(recomeded);
            }
        });
    </script>
</asp:Content>
