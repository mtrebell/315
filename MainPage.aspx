<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="MainPage.aspx.cs" Inherits="_Default" %>

<asp:Content ContentPlaceHolderID="head" Runat="Server">
    <link href="CssSheets/MainPage.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        function NavigateToMoreInfo(index) {
            window.location = "MoreInfo.aspx?idx=" + index.toString();
        }

        var oritop = -100;
        var oribot = -100;
        window.onscroll = moveMenu;

        function moveMenu() {
            var scrollt = window.scrollY;
            var elm = document.getElementById("DIV_Float");
            var elm2 = document.getElementById("DIV_Main");

            if (oritop < 0) {
                oritop = elm.offsetTop;   
                oribot = elm2.offsetHeight + elm.offsetTop - elm.offsetHeight;
            }

            if (scrollt >= oritop && scrollt < oribot) 
                elm.style.top = (scrollt - oritop + 5).toString() + 'px';
            
            else if (scrollt < oribot) 
                elm.style.top = '0px';

            else
                elm.style.top = (oribot - oritop).toString() + 'px';
         }    
    </script>
</asp:Content>

<asp:Content ContentPlaceHolderID="body" Runat="Server">
    <div id="DIV_Main" class="Main">
        <div id="DIV_Menu" class="MainLeft" >   
            <div id="DIV_Float" class="FloatingMenu">
                <asp:TextBox ID="TB_Search" runat="server" CssClass="TextBox" ></asp:TextBox>   
                        <asp:RegularExpressionValidator ID="REV_Search" runat="server" ForeColor="Red" Display="Dynamic"  
            ErrorMessage="RegularExpressionValidator" ControlToValidate="TB_Search"  ValidationExpression="^[a-zA-Z0-9_' ']*$">*
            </asp:RegularExpressionValidator>
                <br /><asp:Button ID="BTN_Search" runat="server" Text="Search" cssClass="ButtonMini" onclick="BTN_Search_Click"/><br />  
                                               
                 <asp:Menu ID="Alpha_Menu" runat="server" OnMenuItemClick="Alpha_Menu_MenuItemClick" 
                    CssClass="Menu" 
                    StaticSelectedStyle-CssClass="MenuSelected" 
                    StaticHoverStyle-CssClass="MenuHover"
                    StaticMenuItemStyle-CssClass="MenuStatic">                                                                                                                             
                        <Items>
                        <asp:MenuItem Text="All Movies" Value="*" Selected="true" />
                        <asp:MenuItem Text="A Movies" Value="A" />
                        <asp:MenuItem Text="B Movies" Value="B" />
                        <asp:MenuItem Text="C Movies" Value="C" />
                        <asp:MenuItem Text="D Movies" Value="D" />
                        <asp:MenuItem Text="E Movies" Value="E" />
                        <asp:MenuItem Text="F Movies" Value="F" />
                        <asp:MenuItem Text="G Movies" Value="G" />
                        <asp:MenuItem Text="H Movies" Value="H" />
                        <asp:MenuItem Text="I Movies" Value="I" />
                        <asp:MenuItem Text="J Movies" Value="J" />
                        <asp:MenuItem Text="K Movies" Value="K" />
                        <asp:MenuItem Text="L Movies" Value="L" />
                        <asp:MenuItem Text="M Movies" Value="M" />
                        <asp:MenuItem Text="N Movies" Value="N" />
                        <asp:MenuItem Text="O Movies" Value="O" />
                        <asp:MenuItem Text="P Movies" Value="P" />
                        <asp:MenuItem Text="Q Movies" Value="Q" />
                        <asp:MenuItem Text="R Movies" Value="R" />
                        <asp:MenuItem Text="S Movies" Value="S" />
                        <asp:MenuItem Text="T Movies" Value="T" />
                        <asp:MenuItem Text="U Movies" Value="U" />
                        <asp:MenuItem Text="V Movies" Value="V" />
                        <asp:MenuItem Text="W Movies" Value="W" />
                        <asp:MenuItem Text="X Movies" Value="X" />
                        <asp:MenuItem Text="Y Movies" Value="Y" />
                        <asp:MenuItem Text="Z Movies" Value="Z" />
                    </Items>
                 </asp:Menu>
            </div>
        </div> 

        <div id="DIV_Content" class="MainRight">                      
            <center>
                <asp:Label ID="LBL_TotalCount" runat="server" Text="Over x movies and counting"
                style="color: White; font-size: large;" ></asp:Label>
                <hr style="color: #DAA520; background-color: #DAA520;" />
                <div ID="DIV_Movie" runat="server"></div>
            </center>          
        </div> 
    </div>
</asp:Content>
