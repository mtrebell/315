<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="ManageAccount.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
<div>
<!-- Gridview and attached sqldatasource used to get user information and allow for deletion of account data
     selections made from gridview using selected inndex event -->
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
        ConnectionString="<%$ ConnectionStrings:InternalConnectionString %>" 
        SelectCommand="GetNonAdminUsers" SelectCommandType="StoredProcedure" ></asp:SqlDataSource>  
    <center>
    <asp:GridView ID="GridView_Accounts" runat="server" AllowPaging="True"  
        BorderWidth="3px" BorderColor="Black"
        AutoGenerateColumns="False" CellPadding="4" DataSourceID="SqlDataSource1" GridLines="None" 
        onselectedindexchanged="GridView_Acoounts_SelectedIndexChanged" Width="99%" >
        <RowStyle ForeColor="White" BackColor="Black" HorizontalAlign="Center" />
        <AlternatingRowStyle BackColor="Black" ForeColor="White" HorizontalAlign="Center" />
        <Columns>
            <asp:BoundField DataField="UserId" HeaderText="UserId" 
                SortExpression="UserId"  />
            <asp:BoundField DataField="UserName" HeaderText="UserName" 
                SortExpression="UserName" />
            <asp:BoundField DataField="LastActivityDate" HeaderText="LastActivityDate" 
                SortExpression="LastActivityDate" />
            <asp:CommandField ButtonType="Button" ControlStyle-CssClass="ButtonMini" 
                SelectText="Delete" ShowSelectButton="True" />
        </Columns>
        <FooterStyle BackColor="#DAA520" Font-Bold="True" ForeColor="White" />
        <HeaderStyle BackColor="#DAA520" BorderColor="Black" Font-Bold="True" ForeColor="White" />
        <PagerStyle BackColor="#DAA520" ForeColor="Black" HorizontalAlign="Center" />
        <RowStyle BackColor="white" ForeColor="Black" />
        <SelectedRowStyle BackColor="#FFCC66" Font-Bold="True" ForeColor="White"  />
    </asp:GridView>   
    </center> 
</div>
</asp:Content>

