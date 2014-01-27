<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Request.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
<div style="min-height: 300px;">

    <!-- Sql datasource and gridview for the requests database, automatically created select function, acts as delete call -->
    <asp:SqlDataSource ID="SqlDataSource_Requests" runat="server" 
        ConflictDetection="CompareAllValues" 
        ConnectionString="<%$ ConnectionStrings:InternalConnectionString %>" 
        DeleteCommand="DELETE FROM [Requests] WHERE ([request_id] = @original_request_id)" 
        InsertCommand="INSERT INTO [Requests] ([users_id], [requestDate], [requestTitle]) VALUES (@users_id, @requestDate, @requestTitle)" 
        OldValuesParameterFormatString="original_{0}" 
        SelectCommand="SELECT Requests.request_id, aspnet_Users.UserName, Requests.requestDate, Requests.requestTitle FROM Requests INNER JOIN aspnet_Users ON Requests.users_id = aspnet_Users.UserId ORDER BY Requests.requestTitle, Requests.requestDate" 
        
        UpdateCommand="UPDATE [Requests] SET [users_id] = @users_id, [requestDate] = @requestDate, [requestTitle] = @requestTitle WHERE [request_id] = @original_request_id AND (([users_id] = @original_users_id) OR ([users_id] IS NULL AND @original_users_id IS NULL)) AND (([requestDate] = @original_requestDate) OR ([requestDate] IS NULL AND @original_requestDate IS NULL)) AND [requestTitle] = @original_requestTitle">
        <DeleteParameters>
            <asp:Parameter Name="original_request_id" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="users_id" Type="Object" />
            <asp:Parameter Name="requestDate" Type="DateTime" />
            <asp:Parameter Name="requestTitle" Type="String" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="users_id" Type="Object" />
            <asp:Parameter Name="requestDate" Type="DateTime" />
            <asp:Parameter Name="requestTitle" Type="String" />
            <asp:Parameter Name="original_request_id" Type="Int32" />
            <asp:Parameter Name="original_users_id" Type="Object" />
            <asp:Parameter Name="original_requestDate" Type="DateTime" />
            <asp:Parameter Name="original_requestTitle" Type="String" />
        </UpdateParameters>
    </asp:SqlDataSource>

    <asp:GridView ID="GridView_Request" runat="server" AllowPaging="True" 
        BackColor="White" BorderColor="#999999" BorderStyle="Solid" BorderWidth="2px" 
        CellPadding="3" DataSourceID="SqlDataSource_Requests" ForeColor="Black" Width="99%"
        GridLines="Vertical" AutoGenerateColumns="False" DataKeyNames="request_id" 
        onload="GridView_Request_Load">
        <RowStyle BackColor="White" ForeColor="Black" />
        <AlternatingRowStyle BackColor="Black" ForeColor="White" />
        <Columns>
            <asp:CommandField ButtonType="Button" ShowDeleteButton="True" ControlStyle-CssClass="button" />
            <asp:BoundField DataField="request_id" HeaderText="request_id" 
                InsertVisible="False" ReadOnly="True" SortExpression="request_id" />
            <asp:BoundField DataField="UserName" HeaderText="UserName" 
                SortExpression="UserName" />
            <asp:BoundField DataField="requestDate" HeaderText="requestDate" 
                SortExpression="requestDate" />
            <asp:BoundField DataField="requestTitle" HeaderText="requestTitle" 
                SortExpression="requestTitle" />
        </Columns>
        <FooterStyle BackColor="#CCCCCC" />
        <HeaderStyle BackColor="#DAA520" Font-Bold="True" ForeColor="White"/>
        <PagerStyle BackColor="#999999" ForeColor="Black" HorizontalAlign="Center" />
        <SelectedRowStyle BackColor="#000099" Font-Bold="True" ForeColor="White" />
        <SortedAscendingCellStyle BackColor="#F1F1F1" />
        <SortedAscendingHeaderStyle BackColor="#808080" />
        <SortedDescendingCellStyle BackColor="#CAC9C9" />
        <SortedDescendingHeaderStyle BackColor="#383838" />
    </asp:GridView>
    <br />

    <!-- Request area at bottom of page. used to insert items into database. determines if invalid characters present before add -->
    <asp:Label ID="Label1" runat="server" ForeColor="White" >Please write in the title of the movie you would like to request</asp:Label>
    <asp:TextBox ID="TB_Title" runat="server" AutoPostBack="false" ></asp:TextBox>
    <asp:RequiredFieldValidator ID="RFV_Title" runat="server" ControlToValidate="TB_title" 
    ErrorMessage="Need Title" ForeColor="Red" Display="Dynamic" InitialValue="&quot;&quot;" >*
    </asp:RequiredFieldValidator>
    <asp:RegularExpressionValidator ID="REV_Title" runat="server" ForeColor="Red" Display="Dynamic"  
    ErrorMessage="RegularExpressionValidator" ControlToValidate="TB_title"  ValidationExpression="^[a-zA-Z0-9_' ']*$">*
    </asp:RegularExpressionValidator>
    <asp:Button ID="BTN_AddRequest" runat="server" Text="Add Request" 
        CssClass="Button" onclick="BTN_AddRequest_Click" />
</div>
</asp:Content>
