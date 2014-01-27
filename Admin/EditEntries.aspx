<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="EditEntries.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style type="text/css">
    .column
    {
        overflow: scroll;
        background-image: url("../Background_Images/EditEntriesBG.jpg");
        background-repeat:repeat;
    }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
    <div style="color: White;">
    <center>
    <!-- Grid view and paired swl datasource, used to collect all entries found in the movie summary database
         autocreated delete, selected, and edit functionality -->
    <asp:GridView ID="GV_EditDatabase" runat="server" AutoGenerateColumns="False" 
            DataKeyNames="mov_id" DataSourceID="SqlDataSource1" AllowPaging="True"
            CssClass="column" AllowSorting="True">
        <HeaderStyle BackColor="#DAA520" />
        <Columns>
            <asp:CommandField ButtonType="Button" ShowDeleteButton="True" 
                ShowEditButton="True" ControlStyle-CssClass="Button" />
            <asp:BoundField DataField="mov_title" HeaderText="Title" 
                SortExpression="mov_title" ControlStyle-Width="350" />
            <asp:BoundField DataField="mov_plot" HeaderText="Plot"
                SortExpression="mov_plot" />
            <asp:BoundField DataField="mov_size" HeaderText="File Size"
                SortExpression="mov_size" />
            <asp:BoundField DataField="mov_fileType" HeaderText="File Type"
                SortExpression="mov_fileType" />
            <asp:BoundField DataField="mov_dateAdded" HeaderText="Date Added"
                SortExpression="mov_dateAdded" />
            <asp:BoundField DataField="mov_rating" HeaderText="Rating"
                SortExpression="mov_rating" />
            <asp:BoundField DataField="mov_runTime" HeaderText="Run Time"
                SortExpression="mov_runTime" >
            
            </asp:BoundField>
            <asp:BoundField DataField="mov_lgPoster" HeaderText="Large Poster Link"
                SortExpression="mov_lgPoster" Visible="False" >
            </asp:BoundField>
            <asp:BoundField DataField="mov_smPoster" HeaderText="Small Poster Link" 
                SortExpression="mov_smPoster" Visible="False" />
            <asp:BoundField DataField="mov_id" HeaderText="ID" InsertVisible="False" 
                ReadOnly="True" SortExpression="mov_id" Visible="False" />
            <asp:ImageField DataImageUrlField="mov_smPoster" HeaderText="Small Poster Link"
             ControlStyle-Width="150" ControlStyle-Height="200" >
            </asp:ImageField>
            <asp:ImageField DataImageUrlField="mov_lgPoster" HeaderText="Large Poster Link"
                ControlStyle-Width="300" ControlStyle-Height="400" >
            </asp:ImageField>
        </Columns>
    </asp:GridView>
    </center>
    </div>

    <!-- Sql Datasource for gridview -->
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
        ConnectionString="<%$ ConnectionStrings:InternalConnectionString %>" 
        DeleteCommand="DELETE FROM [MovieSummary] WHERE [mov_id] = @mov_id" 
        InsertCommand="INSERT INTO [MovieSummary] ([mov_title], [mov_plot], [mov_size], [mov_fileType], [mov_dateAdded], [mov_rating], [mov_runTime], [mov_lgPoster], [mov_smPoster]) VALUES (@mov_title, @mov_plot, @mov_size, @mov_fileType, @mov_dateAdded, @mov_rating, @mov_runTime, @mov_lgPoster, @mov_smPoster)" 
        SelectCommand="SELECT [mov_title], [mov_plot], [mov_size], [mov_fileType], [mov_dateAdded], [mov_rating], [mov_runTime], [mov_lgPoster], [mov_smPoster], [mov_id] FROM [MovieSummary] ORDER BY [mov_title]" 
        UpdateCommand="UPDATE [MovieSummary] SET [mov_title] = @mov_title, [mov_plot] = @mov_plot, [mov_size] = @mov_size, [mov_fileType] = @mov_fileType, [mov_dateAdded] = @mov_dateAdded, [mov_rating] = @mov_rating, [mov_runTime] = @mov_runTime, [mov_lgPoster] = @mov_lgPoster, [mov_smPoster] = @mov_smPoster WHERE [mov_id] = @mov_id">
        <DeleteParameters>
            <asp:Parameter Name="mov_id" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="mov_title" Type="String" />
            <asp:Parameter Name="mov_plot" Type="String" />
            <asp:Parameter Name="mov_size" Type="String" />
            <asp:Parameter Name="mov_fileType" Type="String" />
            <asp:Parameter Name="mov_dateAdded" Type="DateTime" />
            <asp:Parameter Name="mov_rating" Type="String" />
            <asp:Parameter Name="mov_runTime" Type="String" />
            <asp:Parameter Name="mov_lgPoster" Type="String" />
            <asp:Parameter Name="mov_smPoster" Type="String" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="mov_title" Type="String" />
            <asp:Parameter Name="mov_plot" Type="String" />
            <asp:Parameter Name="mov_size" Type="String" />
            <asp:Parameter Name="mov_fileType" Type="String" />
            <asp:Parameter Name="mov_dateAdded" Type="DateTime" />
            <asp:Parameter Name="mov_rating" Type="String" />
            <asp:Parameter Name="mov_runTime" Type="String" />
            <asp:Parameter Name="mov_lgPoster" Type="String" />
            <asp:Parameter Name="mov_smPoster" Type="String" />
            <asp:Parameter Name="mov_id" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:Button ID="BTN_ClearAllMedia" runat="server" Text="Clear all media" 
        CssClass="Button" onclick="BTN_ClearAllMedia_Click" 
            OnClientClick="if(confirm('Are you sure you would like to clear all media content?')) return true; else return false;" />
</asp:Content>

