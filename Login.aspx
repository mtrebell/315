<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <script type="text/javascript">
        $(function () {
            $(".Button").button();
        });
       
        function UserInUse(source, arguments)
        {
            var objectData = { 'sUserName': arguments.Value }
            console.log(objectData);
            var isValid;

            $.ajax({
                type: "POST",
                url: "/Login.aspx/UserNameInUse",
                data: JSON.stringify(objectData),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (msg) {
                    isValid = msg.d;
                    console.log(isValid);
                }
            });
            arguments.IsValid = isValid;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
    <form runat="server">
        <table style="border: 1px solid #DAA520; width: 100%;">
            <tr>
                <td align="center" colspan="2" style="background-color: #6B696B; color: White; font-weight:bold;" >
                    Sign Up for Your New Account</td>
            </tr>
            <tr>
                <td align="right">
                    <asp:Label ID="UserNameLabel" runat="server" AssociatedControlID="UserNameTB">User Name:</asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="UserNameTB" runat="server" clientidmode="static" ></asp:TextBox>
                    <asp:RequiredFieldValidator ID="UserNameRequired" runat="server" 
                        ControlToValidate="UserNameTB" ErrorMessage="User Name is required." 
                        ToolTip="User Name is required." ValidationGroup="CreateUser">*</asp:RequiredFieldValidator>
                    <asp:customvalidator runat="server" ID="UserNameUsed" 
                        ErrorMessage="User name already in use." ToolTip="User name already in use."
                        ValidationGroup="CreateUser" ControlToValidate="UserNameTB" 
                        ClientValidationFunction="UserInUse" Display="Dynamic" >*</asp:customvalidator>

                </td>
            </tr>
            <tr>
                <td align="right">
                    <asp:Label ID="PasswordLabel" runat="server" AssociatedControlID="PasswordTB">Password:</asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="PasswordTB" runat="server" TextMode="Password"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="PasswordRequired" runat="server" 
                        ControlToValidate="PasswordTB" ErrorMessage="Password is required." 
                        ToolTip="Password is required." ValidationGroup="CreateUser">*</asp:RequiredFieldValidator>
                </td>
            </tr>
            <tr>
                <td align="right">
                    <asp:Label ID="ConfirmPasswordLabel" runat="server" 
                        AssociatedControlID="ConfirmPasswordTB">Confirm Password:</asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="ConfirmPasswordTB" runat="server" TextMode="Password"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="ConfirmPasswordRequired" runat="server" 
                        ControlToValidate="ConfirmPasswordTB" 
                        ErrorMessage="Confirm Password is required." 
                        ToolTip="Confirm Password is required." ValidationGroup="CreateUser">*</asp:RequiredFieldValidator>
                </td>
            </tr>
            <tr>
                <td align="center" colspan="2">
                    <asp:CompareValidator ID="PasswordCompare" runat="server" 
                        ControlToCompare="PasswordTB" ControlToValidate="ConfirmPasswordTB" 
                        Display="Dynamic" 
                        ErrorMessage="The Password and Confirmation Password must match." 
                        ValidationGroup="CreateUser"></asp:CompareValidator>
                </td>
            </tr>
            <tr>
                <td align="center" colspan="2" style="color:Red;">
                    <asp:Literal ID="ErrorMessage" runat="server" clientidmode="static" EnableViewState="False"></asp:Literal>
                </td>
            </tr>
        </table>
        <asp:Button runat="server" ID="CreateUserBTN" Text="Create User" Click="CreateUserBTN_Click"
            ValidationGroup="CreateUser" OnClick="CreateUserBTN_Click1" cssClass="Button" style="margin-top: 5px;"  />
    </form>

</asp:Content>

