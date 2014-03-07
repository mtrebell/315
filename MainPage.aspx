<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="MainPage.aspx.cs" Inherits="_Default" %>
<asp:Content ContentPlaceHolderID="body" Runat="Server">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>

    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Media Server Db</title>

        <script src="Scripts/jquery-1.10.2.js"></script>
        <script src="Scripts/jquery-ui-1.10.4.custom.js"></script> 
        <script src="Scripts/jquery.coverflow.js"></script>
        <script src="Scripts/jquery.interpolate.js"></script>
        <script src="Scripts/jquery.mousewheel.js"></script>
        <script src="Scripts/jquery.touchSwipe.min.js"></script>
        <script src="Scripts/jquery.multilevelpushmenu.js"></script>
        <script src="Scripts/reflection.js"></script>
        <script src='Scripts/jquery.fileupload.js'></script>
        <script src="Scripts/jquery.visible.min.js"></script>

        <link href="CssSheets/font-awesome.min.css" rel="stylesheet" type="text/css"/>
        <link href="Scripts/jquery-ui-1.10.4.css" rel="stylesheet" type="text/css" />
        <link href="Scripts/jquery-ui-1.10.4.custom.css" rel="stylesheet" type="text/css" /> 
        <link href="Scripts/jquery.multilevelpushmenu.css" rel="stylesheet" type="text/css" /> 
        <link href="Scripts/jquery.tagit.css" rel="stylesheet" type="text/css" /> 

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
    </head>


    <body>
        <script type="text/javascript">
            var filterTagID = 0;
            var coverFlowCtrl = null;
            var filterFlowCtrl = null;
            var genreList = [];

            function ShowMovieDetails(e, cover, index) {

                //$("#Content").tabs();
                var info = $(cover).find("div#info");
                var mov_id = info.find("#mov_id").html();
                $("#Content").tabs("option", "active", 0);
                $("#tabs_imdb").empty().addClass("no-content").attr("dataUrl", mov_id);
                $("#tabs_rotten_tomatoes").empty().addClass("no-content").attr("dataUrl", mov_id);
                $(".details-info").each(function (idx, val) {
                    var htmlData = info.find("#" + $(val).attr('id')).html();
                    //        console.log(" details %o %o ",$(val).attr("id"), info.find("#"+$(val).attr('id')).html());
                    if ($(val).is("img")) {
                        //console.log("image");
                        $(val).attr("src", htmlData);
                    }

                    else if ($(val).is("div")) {
                        //console.log("ul %s",htmlData);
                        if (htmlData !== undefined) {
                            $(val).empty();
                            htmlData.split(",").forEach(function (value, idx) {
                                var v = value.trim();
                                if (v !== undefined && v.length > 0) {
                                    var genreStr = value.replace(",", "").trim();
                                    var selectedStr = ""
                                    if ($('#FilterGenreList#genre_' + genreStr).hasClass("genre-selected")) {
                                        selectedStr = "genre-selected";
                                    }
                                    $(val).append('<span class="genre_' + genreStr + ' genre-label theme ' + selectedStr + '">' + genreStr + "</span>");
                                }
                            });
                        }
                        else {
                            //todo: make all the fields get cleared.
                        }
                    }

                    else {
                        //console.log("default");
                        $(val).html(htmlData);
                    }

                    $(".cover-details-infoline #mov_rating i").remove();
                    $(".cover-details-infoline #mov_rating").remove('i')
                        .each(function (idx, val) {
                            for (var i = 0; i <= parseInt($(val).html()) / 2; i++) {
                                $(val).append('<i class="fa fa-star star-theme"/>')
                            }
                        });
                })
            }

            function GenerateMovieGrid(srcData, dest, moviesPerRow) {

                $(dest).css('display', 'table');
                var i = 0, divObj;
                $(srcData + ' .cover').each(function () {
                    var curRow = parseInt(i / moviesPerRow);

                    //create new row if necessary
                    if (i % moviesPerRow == 0) {
                        divObj = document.createElement('div');
                        $(divObj).addClass('gridRow' + curRow).css('display', 'table-row').appendTo($(dest));
                    }

                    var movie = $(this).clone();
                    var movieInfo = $(movie).find('#info');

                    //if movie cover isn't loaded, construct image data
                    if ($(movie).hasClass("cover-not-loaded")) {
                        var newMovie = document.createElement('img');
                        $(newMovie).attr('id', $(movie).attr('id')).attr('data-src', $(movie).attr('dataUrl'));
                        $(newMovie).removeAttr('dataUrl').attr('cfIndex', i);
                        movie = $(newMovie);
                    } else {
                        //otherwise just grab the image data
                        movie = $(movie).find('img');
                        var tempUrl = $(movie).attr('src');
                        $(movie).removeAttr('src').attr('data-src', tempUrl).attr('cfIndex', i);
                    }

                    var dispData = '<h1>' + $(movie).attr('id') + '</h1><div></div>';
                    $(movie).removeAttr('style').attr('height', '300px').attr('width', '200px').show()

                    var container = document.createElement('div');
                    $(container).css({
                        'display': 'table-cell',
                        'padding': '5px'
                    }).addClass('gridCover');

                    $(container).append(movie, movieInfo);
                    $(container).appendTo(dest + ' .gridRow' + curRow);
                    i++;
                });
            }

            function MovieGridShowInView() {
                $("#GridDialog").find($(".gridCover")).each(function(cover){
                    var img = $(this).find('img');
                    if ($(this).visible(true)) {
                        //if image is visible
                        if (!$(img).attr('src')){
                            //set the img src attribute
                            $(img).attr('src', $(img).attr('data-src')).click(function(e){
                                //when image is clicked, exit grid view and set main page
                                //to clicked image.
                                $('#GridDialog').dialog('destroy');

                                var cfIndex = $(img).attr('cfIndex');
                                coverFlowCtrl.coverflow('index', cfIndex);
                            });
                        }
                    }

                });
            }

            // DOCUMENT READY!
            $(function () {
                $(".ui-validator").html("");
                $("#LogOutButton").button();
                $("#SettingsButton").button({ icons: { primary: "ui-icon-gear" } });

                $("#CoverFlow").load("GetMovieList.aspx", function () {
                    $('#CoverFlow .hidden').hide();
                    if ($.fn.reflect) {
                        // only possible in very specific situations
                        $('#CoverFlow .cover img').attr("height", "300px").attr("width", "200px").reflect();
                    }
                    var genre_list = {};
                    $('#CoverFlow .cover').each(function (idx, value) {
                        if ($(value).find(".missing_poster").length !== 0) {
                            $(value).append('<span class="movieTitle">' + $(value).find("#info #mov_title").html() + '</span>');
                        }
                        // get the genre from the info and add them to the object, we are using the object
                        // as a poor mans set. 
                        var htmlData = $(value).find("#info #mov_genre").html();
                        htmlData.split(",").forEach(function (data) {
                            data = data.trim();
                            if (data !== undefined && data.length > 0) {
                                genre_list[data] = 1;
                            }
                        });
                    });
                    // turn the object into a list of strings. 
                    var filter_genre_list = $("#FilterGenreList").empty();
                    $.each(genre_list, function (name) {
                        genreList.push(name);
                        $(filter_genre_list).append('<span id="genre_' + name + '" class="GenreFilterButton theme">' + name + '</span>');
                    });
                    $(".GenreFilterButton").button().click(GenreFilterButtonClick);

                    coverFlowCtrl = $('#CoverFlow').coverflow(
                    {
                        index: 6,
                        density: 2,
                        innerOffset: 50,
                        innerScale: .7,
                        duration: 10,
                        animateStep: function (event, cover, offset, isVisible, isMiddle, sin, cos) {
                            if (isVisible) {
                                if (isMiddle) {
                                    $(cover).css(
                                    {
                                        'filter': 'none',
                                        '-webkit-filter': 'none'
                                    });
                                } else {
                                    var brightness = 1 + Math.abs(sin),
                                        contrast = 1 - Math.abs(sin),
                                        filter = 'contrast(' + contrast + ') brightness(' + brightness + ')';
                                    $(cover).css(
                                    {
                                        'filter': filter,
                                        '-webkit-filter': filter
                                    });
                                }
                            }
                        },
                        filterCover: CoverFilter,
                        animateDone: ShowMovieDetails,
                        loadCover: function (e, cover, id, dataUrl, dataClass) {
                            $(cover).prepend('<img id="' + $(cover).attr('id') + '" src="' + $(cover).attr('dataUrl') + '"/>"');
                            var imgObj = $(cover).find("img");
                            if (dataClass !== undefined && dataClass != "") {
                                imgObj.addClass(dataClass);
                            }
                            imgObj.attr("height", "300px").attr("width", "200px").reflect();
                        },
                    });
                });

                filterFlowCtrl = $('#MovieFilter').coverflow();

                $("#Content").tabs({
                    beforeActivate: function (event, ui) {
                        var tab_id = ui.newPanel.attr("id");
                        if (ui.newPanel.hasClass("no-content")) {
                            ui.newPanel.removeClass("no-content");
                            if (tab_id === "tabs_imdb") {
                                // TODO: REplace with actuall page url and arguments.
                                ui.newPanel.load("Admin/AddToDataBase.aspx");

                                //GetIMDBReviews(mov_id);
                            }
                            else if (tab_id === "tabs_rotten_tomatoes") {
                                // TODO: REplace with actuall page url and arguments.
                                ui.newPanel.load("Admin/EditEntries.aspx");
                                //GEtRottenReviews(mov_id);
                            }
                        }
                    }
                });
                $("#dialogContainer").hide();
                $("#LoginDialog").hide();
                $('#menu').multilevelpushmenu({
                    backItemIcon: 'fa fa-angle-left',
                    groupIcon: 'fa fa-angle-right',
                    collapsed: true,
                });


                // Set up the click event for the alpha filters.
                $('.AlphaFilterButton').click(AlphaFilterButtonClick);

                //$("#TagFilterInput").input();
                $(".TagFilterButton").button().click(function (e) {
                    e.preventDefault();
                    AddTagFilter($("#TagFilterInput").val());
                    $("#TagFilterInput").val("");
                })
                $(window).resize(function () {
                    $('#menu').multilevelpushmenu('redraw');
                });

                // //$("#LoginDialog").load("Login.aspx");
                // $("#LoginButton").click(function(e) {
                //     e.preventDefault();
                //     $("#LoginDialog").dialog({dialogClass: "ui-ontop"});
                // });

                $("#LogOutButton").click(function (e) {
                    e.preventDefault();
                    window.location.replace("Logout.aspx");
                });

                $("#ClearAllFilters")
                    .button()//{icons: {secondary: "ui-icon-closethick"}})
                    .click(function (e) {
                        $("#FilterBar .filter").remove();
                        $('#FilterAlpha .AlphaFilterActive').removeClass('AlphaFilterActive');

                        coverFlowCtrl.coverflow("invalidateCache").coverflow('refresh');
                    })

                $("#MenuGridView").click(function (e) {
                    e.preventDefault();
                    $("#GridDialog").dialog({
                        dialogClass: "ui-ontop",
                        width: '900',
                        height: '900',
                        modal: true,
                        resizeable: true,
                        //Todo: improve calculation for number of movies per row.
                        resizeStop: function (e, ui) {

                            $('.gridContainer').empty();
                            var _numperRow = parseInt($(this).outerWidth() / 200);
                            console.log("movies per row: " + _numperRow);

                            GenerateMovieGrid('#CoverFlow', '.gridContainer', _numperRow);
                        },
                        open: function () {
                            $(".cover-div").addClass("cover-disabled");
                        },
                        close: function () {
                            $(".cover-div").removeClass("cover-disabled");
                        },

                    }).position({ at: 'center' });

                    //set movies to load on scroll
                    $("#GridDialog").scroll(function(e){
                        MovieGridShowInView();
                    });


                    GenerateMovieGrid('#CoverFlow', '.gridContainer', 4);
                    MovieGridShowInView();
                });

                $("#MenuRecomendations").click(function (e) {
                    e.preventDefault();
                    $("#RecomendationsDialog").dialog({ dialogClass: "ui-ontop" });
                });
                $("#MenuEnterRequest").click(function (e) {
                    e.preventDefault();
                    $("#EnterRequestDialog").dialog({ dialogClass: "ui-ontop" });
                });

            }); // End Doc Ready.
    </script>

    <asp:LoginView ID="LoginView5" runat="server">
        <LoggedInTemplate>
            <script>
                $(function () {
                    console.log("loggedin template");
                    $("#loggedin_bar").show();
                    $("#login_bar").hide();
                    $("#body_Login1_LoginButton").button();
                });
            </script>
        </LoggedInTemplate>
        <AnonymousTemplate> 
            <script>
                $(function () {
                    console.log("anon template");
                    $("#loggedin_bar").hide();
                    $("#login_bar").show();
                    $("#body_Login1_LoginButton").button();
                });
            </script>
        </AnonymousTemplate> 
    </asp:LoginView>

    <asp:LoginView ID="LoginView1" runat="server">
        <RoleGroups>
            <asp:RoleGroup Roles="Administrator">
                <ContentTemplate>
                    <link href="CssSheets/Admin.css" rel="stylesheet" type="text/css" />
                    <link href="CssSheets/AddToDataBase.css" rel="stylesheet" type="text/css" />

                    <script type="text/javascript">
                        $(function () {
                            $("#AddContentDialog").hide();
                            $("#AddContentDialog").load("Admin/AddToDataBase.aspx", function(){
                                $("#AddContentDialog").dialog({ 
                                    dialogClass: "ui-ontop", 
                                    width: "50%", 
                                    modal: true,
                                    resizable: false,
                                    title: "Add new content",
                                    autoOpen: false,
                                    draggable: false,
                                    open: function() {
                                        $(".cover-div").addClass("cover-disabled");
                                    },
                                    close: function() {
                                        $(".cover-div").removeClass("cover-disabled");
                                    },
                                });
                                $("#AddContentButton").click(function (e) {
                                    e.preventDefault();
                                    $("#AddContentDialog").dialog('open');

                                });
                                    
                            });
        
                            $("#EditEntriesDialog").hide();
                            $("#EditEntriesDialog").load("Admin/EditEntries.aspx", function(){
                                $("#EditEntriesDialog").dialog({
                                    dialogClass: "ui-ontop",
                                    width: "50%",
                                    minHeight: 350,
                                    modal: true,
                                    resizable: false,
                                    title: "Edit Movies",
                                    autoOpen: false,
                                    draggable: false,

                                    create: function () {
                                        $(this).css("maxHeight", 350);
                                    },
                                    open: function() {
                                        $(".cover-div").addClass("cover-disabled");
                                    },
                                    close: function() {
                                        $(".cover-div").removeClass("cover-disabled");
                                    },
                                });
                                $("#EditEntriesButton").click(function (e) {
                                    e.preventDefault();
                                    $("#EditEntriesDialog").dialog('open');
                                });
                            });

                            $("#EditUsersDialog").hide();
                            $("#EditUsersDialog").load("Admin/ManageAccount.aspx", function(){
                                $("#EditUsersDialog").dialog({
                                    dialogClass: "ui-ontop",
                                    width: "540px",
                                    minHeight: 350,
                                    modal: true,
                                    resizable: false,
                                    title: "Edit Users",
                                    autoOpen: false,
                                    draggable: false,
                                    open: function() {
                                        $(".cover-div").addClass("cover-disabled");
                                    },
                                    close: function() {
                                        $(".cover-div").removeClass("cover-disabled");
                                    },
                                });
                                $("#EditUsersButton").click(function (e) {
                                    e.preventDefault();
                                    $("#EditUsersDialog").dialog('open');
                                });                            
                            });
                        })
                    </script>
                </ContentTemplate>
            </asp:RoleGroup>
        </RoleGroups>
    </asp:LoginView>
    <div class="ui-header-fixed ui-ontop">
        <img src="Background_Images/Std_Header.png" style="width: 100%" />
        <form runat="server">
            <asp:Login ID="Login1" runat="server" BackColor="Black" BorderColor="#DAA520" ForeColor="#DAA520"
                BorderStyle="None" BorderWidth="0px" Font-Names="Verdana" Font-Size="8pt"
                OnLoggedIn="Login1_LoggedIn" DestinationPageUrl="~/MainPage.aspx">
                <LayoutTemplate>
                    <div id="loggedin_bar" class="logedin-bar theme ui-ontop">
                        <asp:LoginName ID="LoginName" runat="Server" FormatString="Welcome {0}" class="user-name"></asp:LoginName>
                        <span class="btn-group-right">
                            <a id="LogOutButton" href="#">Logout?</a>
                            <a id="SettingsButton" href="#">Settings </a>
                        </span>
                    </div>
                    <div id="login_bar" class="login-bar ui-ontop">
                        <span>User:
                            <asp:TextBox ID="UserName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="UserNameRequired" class="ui-validator fa fa-exclamation-circle" runat="server" ControlToValidate="UserName" ErrorMessage="User Name is required." ToolTip="User Name is required." ValidationGroup="Login1">*</asp:RequiredFieldValidator>
                        </span>
                        Password:
                        <asp:TextBox ID="Password" runat="server" TextMode="Password"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="PasswordRequired" class="ui-validator fa fa-exclamation-circle" runat="server" ControlToValidate="Password" ErrorMessage="Password is required." ToolTip="Password is required." ValidationGroup="Login1">*</asp:RequiredFieldValidator>
                        <asp:CheckBox ID="RememberMe" runat="server" Text="Remember." />
                        <asp:Literal ID="FailureText" runat="server" EnableViewState="False"></asp:Literal>
                        <asp:Button ID="LoginButton" runat="server" CommandName="Login" Text="Log In" ValidationGroup="Login1" class="tiny-btn" />
                    </div>
                </LayoutTemplate>
            </asp:Login>
        </form>
    </div>

    <div>

        <div id="mainBody" class="tableContainer MainBodyOffset Border">
            <div class="tableRow">
                <section class="tableCell">
                    <div id="CoverFlow" class="cover-div"></div>
                </section>
            </div>

            <div class="tableRow">
                <section class="tableCell">
                    <span class="inline-display">
                        <img id="ClearAllFilters" class="icon-button" src="Background_Images/close_icon.png">
                        <div id="FilterBar" class="theme">
                        </div>
                    </span>
                    <img src="Background_Images/Std_Seperator.png" style="width: 100%" />
                </section>
            </div>
            <div class="tableRow">
                <section class="tableCell">
                    <div id="MovieFilterBox" class="theme">
                        <div id="MovieFilter" class="cover-div theme">
                            <div id="FilterAlpha" class="cover theme">
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
                            <div id="FilterGenrePage" class="cover">
                                <p>Filter by Genre:</p>
                                <div id="FilterGenreList" class="filter-list-genre">
                                </div>
                            </div>
                            <div id="FilterTag" class="cover">
                                <p>Enter a tag to filter movies by:</p>

                                <input id="TagFilterInput" />
                                <button class="TagFilterButton">Add Tag</button>
                            </div>
                            <div id="FilterRating" class="cover">
                                <p>Enter rating filter:</p>
                            </div>
                        </div>
                    </div>
                </section>
            </div>

        </div>
        <div class="MainBodyOffset">
            <img src="Background_Images/Std_Seperator.png" style="width: 100%" />
        </div>
        <div id="Content" class="MainBodyOffset">

            <ul>
                <li><a href="#tabs_info">Details</a></li>
                <li><a href="#tabs_imdb">IMDB</a></li>
                <li><a href="#tabs_rotten_tomatoes">Rotten Toimato</a></li>
            </ul>

            <div id="tabs_info" class="hex-background no-tab-padding">
                <div class="tableContainer">
                    <div class="tableRow">
                        <section id="cover-details" class="tableCell table-thirds">
                            <span class="cover-details-infoline">
                                <p class="cover-details-element-label theme">Title:</p>
                                <p id="mov_title" class="cover-details-element-detail theme details-info"></p>
                            </span>
                            <br />
                            <span class="cover-details-infoline multi-line">
                                <p class="cover-details-element-label theme multi-line">
                                    Plot<br>
                                    Summary:
                                </p>
                                <p id="mov_plot" class="cover-details-element-detail theme details-info multi-line"></p>
                            </span>
                            <br />
                            <span class="cover-details-infoline">
                                <p class="cover-details-element-label theme">Rating:</p>
                                <p id="mov_rating" class="cover-details-element-detail theme details-info"></p>
                            </span>
                            <span class="cover-details-infoline">
                                <p class="cover-details-element-label theme">Run Time:</p>
                                <p id="mov_runTime" class="cover-details-element-detail theme details-info">
                                </p>
                            </span>
                            <br />
                            <span class="cover-details-infoline">
                                <p class="cover-details-element-label theme">Genre:</p>
                                <div id="mov_genre" class="cover-details-element-detail theme details-info"></div>
                            </span>
                        </section>
                        <section id="cover-details" class="tableCell table-thirds">
                            <span class="cover-details-infoline">
                                <img src="" id="mov_lgPoster" class="details-info theme" />
                            </span>
                        </section>
                        <section id="cover-details" class="tableCell table-thirds">
                            <span class="cover-details-infoline">
                                <p class="cover-details-element-label theme">Run Time:</p>
                                <p id="mov_trailer" class="cover-details-element-detail theme details-info"></p>
                            </span>
                        </section>
                    </div>
                </div>
            </div>
            <div id="tabs_imdb" class="imdb-review hex-background no-tab-padding">
            </div>
            <div id="tabs_rotten_tomatoes" class="rotten-tomatoes-review hex-background no-tab-padding">
            </div>
        </div>

        <div id="dialogContainer"></div>
        <div id="RecomendationsDialog"></div>
        <div id="EnterRequestDialog"></div>
        <div id="GridDialog">
            <div class="gridContainer"></div>
        </div>
        <asp:LoginView ID="LoginView4" runat="server">
            <RoleGroups>
                <asp:RoleGroup Roles="Administrator">
                    <ContentTemplate>
                        <div id="AddContentDialog"></div>
                        <div id="EditEntriesDialog" style="height: 400px;"></div>
                        <div id="EditUsersDialog"></div>
                    </ContentTemplate>
                </asp:RoleGroup>
            </RoleGroups>
        </asp:LoginView>
    </div>

    <div id="menu" class="ui-ontop theme">
        <nav>
            <h2><i class="fa fa-reorder"></i>Menu</h2>
            <ul>
                <li><a id="" href="#">Favorites</a></li>
                <li><a id="MenuGridView" href="#">Grid View</a></li>
                <asp:LoginView ID="LoginView3" runat="server">
                    <RoleGroups>
                        <asp:RoleGroup Roles="Administrator">
                            <ContentTemplate>
                                <li><a id="MenuRecomendations" href="#">Recommendations</a></li>
                                <li><a id="MenuEnterRequest" href="#">Enter Request</a></li>
                                <li><a href="#">Admin</a>
                                    <h2>Admin</h2>
                                    <ul>
                                        <li><a id="AddContentButton" href="#">Add Content</a></li>
                                        <li><a id="EditEntriesButton" href="#">Edit Movies</a></li>
                                        <li><a id="EditUsersButton" href="#">Edit Users</a></li>
                                    </ul>
                                </li>
                            </ContentTemplate>
                        </asp:RoleGroup>
                    </RoleGroups>
                    <RoleGroups>
                        <asp:RoleGroup Roles="Members">
                            <ContentTemplate>
                                <li><a id="MenuRecomendations" href="#">My Recommended</a></li>
                                <li><a id="MenuEnterRequest" href="#">Enter Request</a></li>
                            </ContentTemplate>
                        </asp:RoleGroup>
                    </RoleGroups>
                </asp:LoginView>
            </ul>
        </nav>
    </div>
</body>
</asp:Content>
