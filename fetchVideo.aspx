
<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="FetchVideo.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
    <asp:Repeater ID="VideosRepeater" runat="server">
   <ItemTemplate>
      <object width="427" height="258">
           <param name="movie" value="http://www.youtube.com/v/
		<%# Eval("VideoId") %>"></param>
           <param name="allowFullScreen" value="true"></param>
           <param name="allowscriptaccess" value="always"></param>
           <param name="wmode" value="opaque"></param>
           <embed src="http://www.youtube.com/v/<%# Eval("VideoId") %>?" 
		type="application/x-shockwave-flash" width="427" 
		height="258" allowscriptaccess="always" allowfullscreen="true" 
		wmode="opaque"></embed>
         </object>
   </ItemTemplate>
   <SeparatorTemplate>
     <br />
   </SeparatorTemplate>
   </asp:Repeater>
</asp:Content>

