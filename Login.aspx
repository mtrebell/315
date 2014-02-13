<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
    <form runat="server">
        <center>
        <div>
        <br />
        
        <!-- login box for current users -->
        <asp:Login ID="Login1" runat="server" BackColor="Black" BorderColor="#DAA520" ForeColor="#DAA520"
          BorderStyle="Solid" BorderWidth="1px" Font-Names="Verdana" Font-Size="10pt"
          OnLoggedIn="Login1_LoggedIn" DestinationPageUrl="~/MainPage.aspx">
          <TitleTextStyle BackColor="#6B696B" Font-Bold="True" ForeColor="#FFFFFF" />
          <LoginButtonStyle CssClass="ButtonMini" />
        </asp:Login>
        <asp:ValidationSummary ID="ValidationSummary1" ForeColor="#FFFFFF" runat="server" ValidationGroup="Login1" />

        <br />
        <!-- create user box for new users -->
        <asp:CreateUserWizard ID="CreateUserWizard1" runat="server" BackColor="Black" 
                BorderColor="Goldenrod" ForeColor="Goldenrod"
          BorderStyle="Solid" BorderWidth="1px" ContinueDestinationPageUrl="~/MainPage.aspx"
          Font-Names="Verdana" Font-Size="10pt" OnCreatedUser="CreateUserWizard1_CreatedUser"
          RequireEmail="False">
          <ContinueButtonStyle BackColor="#FFFBFF" BorderColor="#CCCCCC" BorderStyle="Solid"
            BorderWidth="1px" Font-Names="Verdana" ForeColor="#284775" />
          <CreateUserButtonStyle BackColor="#FFFBFF" BorderColor="#CCCCCC" BorderStyle="Solid"
            BorderWidth="1px" Font-Names="Verdana" ForeColor="#284775" />
          <TitleTextStyle BackColor="#6B696B" Font-Bold="True" ForeColor="#FFFFFF" />
          <WizardSteps>
            <asp:CreateUserWizardStep ID="CreateUserWizardStep1" runat="server">
                <ContentTemplate>
                    <table>
                    <tr>
                        <td align="center" colspan="2"  style="background-color: #6B696B; color: White; font-weight:bold;" >
                            Sign Up for Your New Account</td>
                    </tr>
                    <tr>
                        <td align="right">
                            <asp:Label ID="UserNameLabel" runat="server" AssociatedControlID="UserName">User Name:</asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="UserName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="UserNameRequired" runat="server" 
                                ControlToValidate="UserName" ErrorMessage="User Name is required." 
                                ToolTip="User Name is required." ValidationGroup="CreateUserWizard2">*</asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>
                        <td align="right">
                            <asp:Label ID="PasswordLabel" runat="server" AssociatedControlID="Password">Password:</asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="Password" runat="server" TextMode="Password"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="PasswordRequired" runat="server" 
                                ControlToValidate="Password" ErrorMessage="Password is required." 
                                ToolTip="Password is required." ValidationGroup="CreateUserWizard2">*</asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>
                        <td align="right">
                            <asp:Label ID="ConfirmPasswordLabel" runat="server" 
                                AssociatedControlID="ConfirmPassword">Confirm Password:</asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="ConfirmPassword" runat="server" TextMode="Password"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="ConfirmPasswordRequired" runat="server" 
                                ControlToValidate="ConfirmPassword" 
                                ErrorMessage="Confirm Password is required." 
                                ToolTip="Confirm Password is required." ValidationGroup="CreateUserWizard2">*</asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>
                        <td align="center" colspan="2">
                            <asp:CompareValidator ID="PasswordCompare" runat="server" 
                                ControlToCompare="Password" ControlToValidate="ConfirmPassword" 
                                Display="Dynamic" 
                                ErrorMessage="The Password and Confirmation Password must match." 
                                ValidationGroup="CreateUserWizard2"></asp:CompareValidator>
                        </td>
                    </tr>
                    <tr>
                        <td align="center" colspan="2" style="color:Red;">
                            <asp:Literal ID="ErrorMessage" runat="server" EnableViewState="False"></asp:Literal>
                        </td>
                    </tr>
                </table>

                </ContentTemplate>
            </asp:CreateUserWizardStep>
            <asp:CompleteWizardStep ID="CompleteWizardStep1" runat="server" >
                <ContentTemplate>
                    <table style="font-family:Verdana;font-size:100%;">
                        <tr>
                            <td align="center" colspan="2" 
                                style="color:White;background-color:#6B696B;font-weight:bold;">
                                Complete</td>
                        </tr>
                        <tr>
                            <td>
                                Your account has been successfully created.</td>
                        </tr>
                        <tr>
                            <td align="right" colspan="2">
                                <asp:Button ID="ContinueButton" runat="server" BackColor="#FFFBFF" 
                                    BorderColor="#CCCCCC" BorderStyle="Solid" BorderWidth="1px" 
                                    CausesValidation="False" CommandName="Continue" Font-Names="Verdana" 
                                    ForeColor="#284775" Text="Continue" ValidationGroup="CreateUserWizard1" />
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
            </asp:CompleteWizardStep>
          </WizardSteps>
          <HeaderStyle BackColor="#6B696B" Font-Bold="True" ForeColor="#FFFFFF" HorizontalAlign="Center" />
          <NavigationButtonStyle BackColor="#FFFBFF" BorderColor="#CCCCCC" BorderStyle="Solid"
            BorderWidth="1px" Font-Names="Verdana" ForeColor="#284775" />
          <SideBarButtonStyle ForeColor="#FFFFFF" BorderWidth="0px" Font-Names="Verdana" />
          <SideBarStyle BackColor="#7C6F57" Font-Size="0.9em" VerticalAlign="Top" BorderWidth="0px" />
            <StepNavigationTemplate>
                <asp:Button ID="StepPreviousButton" runat="server" BackColor="#FFFBFF" 
                    BorderColor="#CCCCCC" BorderStyle="Solid" BorderWidth="1px" 
                    CausesValidation="False" CommandName="MovePrevious" Font-Names="Verdana" 
                    ForeColor="#284775" Text="Previous" />
                <asp:Button ID="StepNextButton" runat="server" BackColor="#FFFBFF" 
                    BorderColor="#CCCCCC" BorderStyle="Solid" BorderWidth="1px" 
                    CommandName="MoveNext" Font-Names="Verdana" ForeColor="#284775" Text="Next" />
            </StepNavigationTemplate>
          <StepStyle BorderWidth="0px" />
          <CreateUserButtonStyle CssClass="ButtonMini" />
        </asp:CreateUserWizard>
        </div>
        </center>
    </form>

</asp:Content>

