<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="MoreInfo.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
    <div >
    <table width="99%">  
        <tr>
            <td style=" width: 500px;
                        height: 50%;" >

                <asp:Image ID="IMG_Poster" runat="server" style="Width: 280px;
                                                                 Height: 400px;
                                                                 border: 5px solid white; 
                                                                 padding: 3px 3px 3px 3px;
                                                                 margin-left: 50px;
                                                                 margin-bottom: 25px;" />
            </td>
            <td style=" height: 50%;" width="*" > 
                <div style="background-color: Black;
                            border: 2px solid white;
                            width: auto;
                            padding: 10px 10px 10px 10px;" >
                    <asp:Label ID="LBL_Title" runat="server" Text="*" style="color:#DAA520; 
                                                                             font-size:50pt; 
                                                                             margin: 10px 0px 10px 0px;" >
                    </asp:Label><br />
                    <asp:Label ID="LBL_Runtime" runat="server" Text="*" style="color:white;
                                                                               font-size:30pt;" >
                    </asp:Label><br />
                    <asp:Label ID="LBL_Rating" runat="server" Text="*" style="color:white;
                                                                              font-size:30pt;"  >
                    </asp:Label><br />
                    <asp:Label ID="LBL_File_Size" runat="server" Text="*" style="color:white;
                                                                          font-size:20pt;" >
                    </asp:Label><br />
                    <asp:Label ID="LBL_Date" runat="server" Text="*" style="color:white;
                                                                            font-size:20pt;" >
                    </asp:Label><br />
                    <asp:Button ID="BTN_imdb" runat="server" Text="IMDb Full Link" style="background-color: #DAA520;
                                                                        color: Black;
                                                                        border-radius: 10px; 
                                                                        margin-right: 10px;
                                                                        font-size: 12pt;" />
                    <asp:LoginView ID="LoginView_Favorite" runat="server">
                        <LoggedInTemplate>
                            <asp:Button ID="BTN_Favorite" runat="server" Text="Add To Favorites" style="background-color: #DAA520;
                                                                                color: Black;
                                                                                border-radius: 10px; 
                                                                                font-size: 12pt;"   
                            onclick="BTN_Favorite_Click" /> 
                        </LoggedInTemplate>
                    </asp:LoginView>
                        
                </div>                
            </td>
        </tr>
        <tr>
            <td colspan="2" style="width:auto; 
                                   height: 200px; 
                                   vertical-align:text-top; 
                                   border-top: 5px solid white; 
                                   padding-top: 25px;" >
                <center>
               <div ID="DIV_Plot" runat="server" style="padding:2px 2px 2px 2px;
                                                        width: 80%;
                                                        color:#DAA520;
                                                        font-size: 30px;
                                                        background-color: Black;                                                                         
                                                        border:2px solid white;" >
                </div>
                </center>
            </td>
        </tr>    
    </table>
    </div>
</asp:Content>

