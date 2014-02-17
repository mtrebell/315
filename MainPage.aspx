﻿<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="MainPage.aspx.cs" Inherits="_Default" %>
<asp:Content ContentPlaceHolderID="head" Runat="Server">
    <link href="CssSheets/MainPage.css" rel="stylesheet" type="text/css" />
    <script src="scripts/MainPage.js"></script>

    <style>

        .movieTitle {
            color: gray;
            text-shadow: 0px 0px 2em black;
            background-image: url("Background_Images/semitransparent_black.png");
            position: absolute;
            top: 300px;
            text-align: center;
            width: 100%;
            font-size: larger;
            font-weight: bold;
        }
        .inline-display{
            display: -webkit-inline-box;
        }
        .icon-button{
            width:  40px;
            height: 40px;
        }
    </style>


</asp:Content>



<asp:Content ContentPlaceHolderID="body" Runat="Server">
    <script type="text/javascript">
        var filterTagID = 0;
        var coverFlowCtrl = null;
        var filterFlowCtrl = null;
        function ShowMovieDetails(e, cover, index)
        {
            var info = $(cover).find("div#info");
            $("#tabs-info>span>.details-info").each(function(idx, val){
                console.log("val.id %s", $(val).attr('id'));
                $(val).html(info.find("#"+$(val).attr('id')).html());
            })
        }


        // DOCUMENT READY!
        $(function() 
        {
            $("#CoverFlow").load("GetMovieList.aspx", function() 
            {
                $('#CoverFlow .hidden').hide();
                if ($.fn.reflect) 
                {
                    // only possible in very specific situations
                    $('#CoverFlow .cover img').attr("height", "300px").attr("width", "200px").reflect();   
                }

                $('#CoverFlow .cover').each(function(idx, value) {
                    if ($(value).find(".missing_poster").length !== 0) {
                        $(value).append('<span class="movieTitle">' + $(value).find("#info #mov_title").html() + '</span>');
                    }
                });

                coverFlowCtrl = $('#CoverFlow').coverflow(
                {
                    index:          6,
                    density:        2,
                    innerOffset:    50,
                    innerScale:     .7,
                    duration:       10, 
                    animateStep:    function(event, cover, offset, isVisible, isMiddle, sin, cos) {
                        if (isVisible) 
                        {
                            if (isMiddle) 
                            {
                                $(cover).css(
                                {
                                    'filter':           'none',
                                    '-webkit-filter':   'none'
                                });
                            } else 
                            {
                                var brightness  = 1 + Math.abs(sin),
                                    contrast    = 1 - Math.abs(sin),
                                    filter      = 'contrast('+contrast+') brightness('+brightness+')';
                                $(cover).css(
                                {
                                    'filter':           filter,
                                    '-webkit-filter':   filter
                                });
                            }
                        }
                    },
                    filterCover: CoverFilter,
                    animateDone: ShowMovieDetails,
                    loadCover: function(e, cover, id, dataUrl, dataClass){
                        $(cover).prepend('<img id="' + $(cover).attr('id') + '" src="' + $(cover).attr('dataUrl') + '"/>"');
                        var imgObj = $(cover).find("img");
                        if (dataClass !== undefined && dataClass != "")
                        {
                            imgObj.addClass(dataClass);
                        }
                        imgObj.attr("height", "300px").attr("width", "200px").reflect();  
                    },
                });
            });

            filterFlowCtrl = $('#MovieFilter').coverflow();

            $("#Content").tabs();
            $("#dialogContainer").hide();
            $("#LoginDialog").hide();   
            $('#menu').multilevelpushmenu({
                backItemIcon: 'fa fa-angle-left',
                groupIcon: 'fa fa-angle-right',
                collapsed: true,
                // containersToPush: [ $( '#mainBody' ), $('#Content') ],
            });


            // Set up the click event for the alpha filters.
            $('.AlphaFilterButton').click(function(e) { 
                e.preventDefault();
                if ( filterFlowCtrl.coverflow('index') !== 0)
                {
                    return;
                }
                $(this).toggleClass('AlphaFilterActive'); 
                if ($("#FilterBar #Filter_"+$(this).attr('id')).length !== 0)
                {
                    DelAlphaFilter($(this).attr('id'));
                }
                else
                {
                    AddAlphaFilter($(this).attr('id'));
                }
            });
            //$("#TagFilterInput").input();
            $(".TagFilterButton").button().click(function (e){
                e.preventDefault();
                AddTagFilter($("#TagFilterInput").val());
                $("#TagFilterInput").val("");
            })
            $( window ).resize(function() {
                $( '#menu' ).multilevelpushmenu( 'redraw' );
            });

            $("#LoginDialog").load("Login.aspx");
            $("#LoginButton").click(function(e) {
                e.preventDefault();
                $("#LoginDialog").dialog({dialogClass: "ui-ontop"});
            });
            $("#ClearAllFilters")
                .button()//{icons: {secondary: "ui-icon-closethick"}})
                .click(function(e){
                    $("#FilterBar .filter").remove();
                    $('#FilterAlpha .AlphaFilterActive').removeClass('AlphaFilterActive'); 

                    coverFlowCtrl.coverflow("invalidateCache").coverflow('refresh');
                })
            <asp:LoginView ID="LoginView1" runat="server" >
                <LoggedInTemplate>
                    $("#AddContentButton").click(function(e) {
                        e.preventDefault();
                        $("#AddContentDialog").dialog({dialogClass: "ui-ontop"});
                    });
                    $("#EdditEntriesButton").click(function(e) {
                        e.preventDefault();
                        $("#EditEditEntriesDialog").dialog({dialogClass: "ui-ontop"});
                    });
                    $("#EditUsersButton").click(function(e) {
                        e.preventDefault();
                        $("#EditUsersDialog").dialog({dialogClass: "ui-ontop"});
                    });
                </LoggedInTemplate> 
                <AnonymousTemplate> 
                </AnonymousTemplate> 
            </asp:LoginView>
            $("#MenuGridView").click(function(e) {
                e.preventDefault();
                $("#GridDialog").dialog({dialogClass: "ui-ontop"});
            });
            $("#MenuRecomendations").click(function(e) {
                e.preventDefault();
                $("#RecomendationsDialog").dialog({dialogClass: "ui-ontop"});
            });
            $("#MenuEnterRequest").click(function(e) {
                e.preventDefault();
                $("#EnterRequestDialog").dialog({dialogClass: "ui-ontop"});
            });

        }); // End Doc Ready.
    </script>
    

    <div id="mainBody" class="tableContainer MainBodyOffset Border">
        <div class="tableRow">
            <section class="tableCell">
                <img src="Background_Images/Std_Header.png" style="width:100%"/>
                <div id="CoverFlow" > </div>
            </section>
        </div>

        <div class="tableRow">
            <section class="tableCell">
                <span class="inline-display">
                    <img id="ClearAllFilters" class="icon-button" src="Background_Images/close_icon.png">
                    <div id="FilterBar">
                    </div>
                </span>
                <img src="Background_Images/Std_Seperator.png" style="width:100%"/>
            </section>
        </div>
        <div class="tableRow">
            <section class="tableCell">
                <div id="MovieFilterBox">
                    <div id="MovieFilter">
                        <div id="FilterAlpha" class="cover" > 
                            <p>Select movies starting with:</p>
                            <div class="filterGrooup">
                                <span id="Alpha_A" class="AlphaFilterButton">A</span> 
                                <span id="Alpha_B" class="AlphaFilterButton">B</span> 
                                <span id="Alpha_C" class="AlphaFilterButton">C</span> 
                                <span id="Alpha_D" class="AlphaFilterButton">D</span> 
                                <span id="Alpha_E" class="AlphaFilterButton">E</span> 
                                <span id="Alpha_F" class="AlphaFilterButton">F</span> 
                                <span id="Alpha_G" class="AlphaFilterButton">G</span> 
                                <span id="Alpha_H" class="AlphaFilterButton">H</span> 
                                <span id="Alpha_I" class="AlphaFilterButton">I</span> 
                                <span id="Alpha_J" class="AlphaFilterButton">J</span> 
                                <span id="Alpha_K" class="AlphaFilterButton">K</span> 
                                <span id="Alpha_L" class="AlphaFilterButton">L</span> 
                                <span id="Alpha_M" class="AlphaFilterButton">M</span>
                                <span id="Alpha_N" class="AlphaFilterButton">N</span> 
                                <span id="Alpha_O" class="AlphaFilterButton">O</span> 
                                <span id="Alpha_P" class="AlphaFilterButton">P</span> 
                                <span id="Alpha_Q" class="AlphaFilterButton">Q</span> 
                            </div>
                            <div class="filterGrooup">
                                <span id="Alpha_R" class="AlphaFilterButton">R</span> 
                                <span id="Alpha_S" class="AlphaFilterButton">S</span> 
                                <span id="Alpha_T" class="AlphaFilterButton">T</span> 
                                <span id="Alpha_U" class="AlphaFilterButton">U</span> 
                                <span id="Alpha_V" class="AlphaFilterButton">V</span> 
                                <span id="Alpha_W" class="AlphaFilterButton">W</span> 
                                <span id="Alpha_X" class="AlphaFilterButton">X</span> 
                                <span id="Alpha_Y" class="AlphaFilterButton">Y</span> 
                                <span id="Alpha_Z" class="AlphaFilterButton">Z</span> 
                                <span id="Alpha_0" class="AlphaFilterButton">0</span> 
                                <span id="Alpha_1" class="AlphaFilterButton">1</span> 
                                <span id="Alpha_2" class="AlphaFilterButton">2</span> 
                                <span id="Alpha_3" class="AlphaFilterButton">3</span> 
                                <span id="Alpha_4" class="AlphaFilterButton">4</span> 
                                <span id="Alpha_5" class="AlphaFilterButton">5</span> 
                                <span id="Alpha_6" class="AlphaFilterButton">6</span> 
                                <span id="Alpha_7" class="AlphaFilterButton">7</span> 
                                <span id="Alpha_8" class="AlphaFilterButton">8</span> 

                            </div>
                        </div>
                        <div id="FilterTag" class="cover" >
                            <p>Enter a tag to filter movies by:</p>

                            <input id="TagFilterInput"/> 
                            <button class="TagFilterButton">Add Tag</button> 
                        </div>
                        <div id="FilterGeneral" class="cover" >
                            <p>Enter general filter:</p>
                        </div>
                        <div id="FilterRating" class="cover" > 
                            <p>Enter rating filter:</p>
                        </div>
                    </div>
                </div>
            </section>
        </div>

    </div>
    <div class="MainBodyOffset">
        <img src="Background_Images/Std_Seperator.png" style="width:100%"/>
    </div>
    <div id="Content" class="MainBodyOffset">

        <ul>
            <li><a href="#tabs-info">Details</a></li>
            <li><a href="#tabs-1">Personal</a></li>
            <li><a href="#tabs-2">IMDB</a></li>
            <li><a href="#tabs-3">Rotten Toimato</a></li>
        </ul>
        <div id="tabs-info">
            <span id="info_title" class="infoline"> <p class="left">Title:</p> <p id="mov_title" class="right details-info"></p></span>
            <span id="info_rating" class="infoline"> <p class="left">Rating:</p> <p id="mov_rating" class="right details-info"></p></span>
            <span id="info_rating" class="infoline"> <p class="left">Run Time:</p> <p id="mov_runTime" class="right details-info"></p></span>
            <span id="info_rating" class="infoline"> <p class="left">Title:</p> <img src="" id="mov_rating" class="right details-info"/></span>
        </div>
        <div id="tabs-1">
            <p>Proin elit arcu, rutrum commodo, vehicula tempus, commodo a, risus. Curabitur nec arcu. Donec sollicitudin mi sit amet mauris. Nam elementum quam ullamcorper ante. Etiam aliquet massa et lorem. Mauris dapibus lacus auctor risus. Aenean tempor ullamcorper leo. Vivamus sed magna quis ligula eleifend adipiscing. Duis orci. Aliquam sodales tortor vitae ipsum. Aliquam nulla. Duis aliquam molestie erat. Ut et mauris vel pede varius sollicitudin. Sed ut dolor nec orci tincidunt interdum. Phasellus ipsum. Nunc tristique tempus lectus.
            </p>
        </div>
        <div id="tabs-2">
            <p>Morbi tincidunt, dui sit amet facilisis feugiat, odio metus gravida ante, ut pharetra massa metus id nunc. Duis scelerisque molestie turpis. Sed fringilla, massa eget luctus malesuada, metus eros molestie lectus, ut tempus eros massa ut dolor. Aenean aliquet fringilla sem. Suspendisse sed ligula in ligula suscipit aliquam. Praesent in eros vestibulum mi adipiscing adipiscing. Morbi facilisis. Curabitur ornare consequat nunc. Aenean vel metus. Ut posuere viverra nulla. Aliquam erat volutpat. Pellentesque convallis. Maecenas feugiat, tellus pellentesque pretium posuere, felis lorem euismod felis, eu ornare leo nisi vel felis. Mauris consectetur tortor et purus.</p>
        </div>
        <div id="tabs-3">
            <p>Mauris eleifend est et turpis. Duis id erat. Suspendisse potenti. Aliquam vulputate, pede vel vehicula accumsan, mi neque rutrum erat, eu congue orci lorem eget lorem. Vestibulum non ante. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Fusce sodales. Quisque eu urna vel enim commodo pellentesque. Praesent eu risus hendrerit ligula tempus pretium. Curabitur lorem enim, pretium nec, feugiat nec, luctus a, lacus.</p>
            <p>Duis cursus. Maecenas ligula eros, blandit nec, pharetra at, semper at, magna. Nullam ac lacus. Nulla facilisi. Praesent viverra justo vitae neque. Praesent blandit adipiscing velit. Suspendisse potenti. Donec mattis, pede vel pharetra blandit, magna ligula faucibus eros, id euismod lacus dolor eget odio. Nam scelerisque. Donec non libero sed nulla mattis commodo. Ut sagittis. Donec nisi lectus, feugiat porttitor, tempor ac, tempor vitae, pede. Aenean vehicula velit eu tellus interdum rutrum. Maecenas commodo. Pellentesque nec elit. Fusce in lacus. Vivamus a libero vitae lectus hendrerit hendrerit.
        </p>
        </div>
    </div>

    <div id="menu">
      <nav>
        <h2><i class="fa fa-reorder"></i>Menu</h2>
        <ul>
            <li><a id="" href="#">Favorites</a></li>
            <li><a id="MenuGridView" href="#">Grid View</a></li>
            <li><a id="MenuRecomendations" href="#">My Recommended</a></li>
            <li><a id="MenuEnterRequest" href="#">Enter Request</a></li>
            <li><a id="" href="#">My Settings</a></li>
            <li><a id="" href="#">Credits</a></li>
            <asp:LoginView ID="LoginView2" runat="server" >
                <LoggedInTemplate>
                    <li><a id="AddContentButton" href="#">Add Content</a></li>
                    <li><a id="EdditEntriesButton" href="#">Edit Entries</a></li>
                    <li><a id="EditUsersButton" href="#">Edit Users</a></li>
                    <li><a id="LogOutButton" href="#">Logout</a></li>
                </LoggedInTemplate> 
                <AnonymousTemplate> 
                    <a id="LoginButton" href="#">Login</a>

                </AnonymousTemplate> 

            </asp:LoginView>

        </ul>
      </nav>
    </div>
    <div id="dialogContainer"></div>
    <div id="RecomendationsDialog"></div>
    <div id="EnterRequestDialog"></div>
    <div id="GridDialog"></div>
    <div id="LoginDialog"> </div>
    <asp:LoginView ID="LoginView3" runat="server" >
        <LoggedInTemplate>
            <div id="AddContentDialog"></div>
            <div id="EditEditEntriesDialog"></div>
            <div id="EditUsersDialog"></div>
        </LoggedInTemplate> 
        <AnonymousTemplate> 
        </AnonymousTemplate> 

    </asp:LoginView>
</asp:Content>

