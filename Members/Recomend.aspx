<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Recomend.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <script src="../Scripts/jquery-1.10.2.js"></script>
    <script>
    console.log("Running");
   $.ajax({
  type: "POST",
  url: "Recomend.aspx/buildModel",
  data: "{}",
  contentType: "application/json; charset=utf-8",
  dataType: "json",
  success: function(msg) {
    console.log("DID IT");
  }
});
    </script>
</asp:Content>
