<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="MainPage.aspx.cs" Inherits="_Default" %>
<asp:Content ContentPlaceHolderID="body" Runat="Server">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>

    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Media Server Db</title>

        <link href="CssSheets/font-awesome.min.css" rel="stylesheet" type="text/css"/>
        <link href="Scripts/jquery-ui-1.10.4.css" rel="stylesheet" type="text/css" />
        <link href="Scripts/jquery-ui-1.10.4.custom.css" rel="stylesheet" type="text/css" /> 
        <link href="Scripts/jquery.multilevelpushmenu.css" rel="stylesheet" type="text/css" /> 
        <link href="Scripts/jquery.tagit.css" rel="stylesheet" type="text/css" /> 

        <link href="CssSheets/MainPage.css" rel="stylesheet" type="text/css" />
        <link href="CssSheets/MainPage-default.css" rel="stylesheet" type="text/css" />

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

        <script src="scripts/MainPage.js"></script>
        <script src="scripts/jquery.raty.js"></script>

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
            var DAYS_OLD = 11;
            var filterTagID = 0;
            var coverFlowCtrl = null;
            var filterFlowCtrl = null;
            var genreList = [];
            var trailerLoadID = null;

            function ShowMovieDetails(e, cover, index) {

                //$("#Content").tabs();
                var info = $(cover).find("div#info");
                var mov_id = info.find("#mov_id").html();
                $("#trailer").fadeOut(0);
                if (trailerLoadID !== null )
                {
                    window.clearTimeout(trailerLoadID);
                    trailerLoadID = null;
                }
                trailerLoadID = window.setTimeout(function(){
                    getTrailer(mov_id);
                    $("#trailer").fadeIn(100);

                    trailerLoadID = null;
                }, 750);

                $("#Content").tabs("option", "active", 0);

                $("#tabs_imdb").empty().addClass("no-content").attr("dataUrl", mov_id);
                $("#tabs_reviews").addClass("no-content").attr("dataUrl", mov_id);
                $("#tabs_reviews #UserReviewDisplay").empty();
                $("#tabs_rotten_tomatoes").empty().addClass("no-content").attr("dataUrl", mov_id);
                $("#tabs_user_reviews").remove(".other-review").addClass("no-content").attr("dataUrl", mov_id);

                $(".details-info").each(function (idx, val) {
                    var htmlData = info.find("#" + $(val).attr('id')).html();
                    if ($(val).is("img")) {
                        $(val).attr("src", htmlData);
                    }

                    else if ($(val).is("div")) {
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
                    }

                    else {
                        //console.log("default");
                        $(val).html(htmlData);
                    }

                    //create movie rating object
                    $(".cover-details-infoline #mov_rating .Star-Rating").empty();
                    $('.Star-Rating').raty({
                        half: true, //enable half star selection
                        score: $('.cover-details-infoline #mov_rating').text() / 2,
                        click: function (score, evt) {
                            //if (!this.readOnly()) return; //if in readOnly mode, do not submit anything

                            console.log("Rating clicked!");
                            setMovieRating(score, mov_id, this);//MainPage.js
                        }
                        //readOnly: function () {
                        //    //a simple, probably very insecure method to detect if a user is logged in
                        //    return !$('#loggedin_bar').is(":visible");
                        //}
                    });


                })
            }

            //********************************************************************************
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
                    var plot_keyword_list = {};
                    $('#CoverFlow .cover').each(function (idx, value) {
                        //Add Label to new movies
                        //Remove timestamp
                        var date = $(value).find("#mov_dateAdded")[0].innerText;
                        if (date) {
                            date = date.split(" ")[0];
                            if (MovieOlderThanDays(new Date(), date, DAYS_OLD)) {
                                $(value).prepend('<span class ="ui-new-movie-label theme"><h1 class="ui-new-movie-text theme">N</h1></span>').addClass("new-movie")
                            }
                        }
                        var recommended = $(value).find("#mov_recommended")[0].innerText;
                        if (recommended && recommended.length !==  0) {
                            $(value).prepend('<span class ="ui-recommended-movie-label theme"><h1 class="ui-recommended-movie-text theme fa fa-star"></h1></span>').addClass("recommended-movie")
                        }


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


                        var htmlData = $(value).find("#info #mov_plotkeywords").html();
                        htmlData.split(",").forEach(function (data) {
                            data = data.trim();
                            if (data !== undefined && data.length > 0) {
                                plot_keyword_list[data] = data.toLowerCase();
                                $(value).addClass("plot-keyword-" + data.toLowerCase());
                            }
                        });
                    }); // $('#CoverFlow .cover').each

                    // turn the object into a list of strings. 
                    var filter_genre_list = $("#FilterGenreList").empty();
                    $.each(genre_list, function (name) {
                        genreList.push(name);
                        $(filter_genre_list).append('<span id="genre_' + name + '" class="GenreFilterButton theme">' + name + '</span>');
                    });
                    $(".GenreFilterButton").button().click(GenreFilterButtonClick);

                    var l = [];
                    $.each(plot_keyword_list, function(prop, obj){
                        l.push(prop);
                    });
                    l.sort().forEach(function(prop, idx){
                        $("#PlotKeywords").append('<option value="' + plot_keyword_list[prop] + '">' + prop + "</option>");
                    });

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

                filterFlowCtrl = $('#MovieFilter').coverflow({index:1});

                $("#Content").tabs({
                    beforeActivate: function (event, ui) {
                        var tab_id = ui.newPanel.attr("id");

                        if (ui.newPanel.hasClass("no-content")) {
                            console.log(tab_id);
                            ui.newPanel.removeClass("no-content");

                            if (tab_id === "tabs_imdb") 
                                GetMovieReviewIMDB(ui);
 
                            else if (tab_id === "tabs_rotten_tomatoes")
                                GetMovieReviewRotten(ui);

                            else if (tab_id === "tabs_reviews")
                                GetMovieUserReview(ui);
                        }
                    }
                });

                $('#btn_submit_review').click(function () 
                {
                    $("#userReviewForm").animate({height:"toggle"}, 100); // collaps user review form
                    var mov_id = $(this).parent().parent().attr('dataurl');
                    var review = $('#UserReview').val();
                    console.log(review);
                    console.log(mov_id);
                    setMovieReview(review, mov_id, this);
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

                $(window).resize(function () {
                    $('#menu').multilevelpushmenu('redraw');
                });

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
                            $('.gridContainer').empty();
                        },

                    }).position({ at: 'center' });

                    //set movies to load on scroll
                    $("#GridDialog").scroll(function(e){
                        MovieGridShowInView('GridDialog');
                    });

                    GenerateMovieGrid('#CoverFlow', '.gridContainer', 4, '.cover');
                    MovieGridShowInView('GridDialog');
                });

                $("#MenuRecomendations").click(function (e) {
                    e.preventDefault();
                    $("#RecomendationsDialog").dialog({
                        dialogClass: "ui-ontop",
                        width: '900',
                        height: '400',
                        modal: true,
                        resizeable: true,
                        //Todo: improve calculation for number of movies per row.
                        resizeStop: function (e, ui) {

                            $('.recContainer').empty();
                            var _numperRow = parseInt($(this).outerWidth() / 200);
                            console.log("movies per row: " + _numperRow);

                            GenerateMovieGrid('#CoverFlow', '.recContainer', _numperRow);
                        },
                        open: function () {
                            $(".cover-div").addClass("cover-disabled");
                        },
                        close: function () {
                            $(".cover-div").removeClass("cover-disabled");
                            $('.recContainer').empty();
                        },

                    }).position({ at: 'center' });

                    //set movies to load on scroll
                    $("#RecomendationsDialog").scroll(function (e) {
                        MovieGridShowInView('RecomendationsDialog');
                    });

                    GenerateMovieGrid('#CoverFlow', '.recContainer', 4, '.recommended-movie');
                    MovieGridShowInView('RecomendationsDialog');
                });

                $("#MenuEnterRequest").click(function (e) {
                    e.preventDefault();
                    $("#EnterRequestDialog").dialog({ dialogClass: "ui-ontop", minWidth: "500" });
                    $("#EnterRequestDialog").load("Members/Request.aspx");
                });

                $("#CreateUserDialog").hide();
                $("#CreateUserButton").click(function (e) {
                    e.preventDefault();
                    $("#CreateUserDialog").dialog({ dialogClass: "ui-ontop", minWidth: "500" });
                    $("#CreateUserDialog").load("Login.aspx");
                });

                // the general filter Keywords                
                $(".TagFilterButton").button().click(function (e) {
                    e.preventDefault();
                    if ($("#PlotKeywords").val().length > 0)
                    {
                        AddTagFilter($("#PlotKeywords").val());
                    }
                }).keypress(function(event){
                    // 
                    if ( event.keyCode == 10 || event.keyCode == 13 ||event.keyCode == 32) {
                        console.log(" TagFilterButton keypress ", event.keyCode);
                        event.keyCode = null;
                        event.preventDefault();
                    }
                });
                $("#PlotKeywords").keypress(function(event){
                    // 
                    if ( event.keyCode == 10 || event.keyCode == 13 ||event.keyCode == 32) {
                        console.log(" PlotKeywords keypress ", event.keyCode);
                        event.preventDefault();
                    }
                });
                $(".NewMovieFilter").button().click(function (e) {
                    AddNewMovieFilter();
                })
                $(".RecomendedMovieFilter").button().click(function (e) {
                    AddRecomendedMovieFilter();
                })

                $("#toggleUserReview").click(function(e) { 
                    $("#userReviewForm").animate({height:"toggle"}, 200);
                })
                $("#userReviewForm").animate({height:"toggle"}, 0);
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
                    $('#CreateUserButton').button();
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
                            $("#EditEntriesButton").click(function (e) {
                                e.preventDefault();
                                if (!$("#EditEntriesDialog").hasClass("dialog-loaded"))
                                {
                                    $("#EditEntriesDialog").addClass("dialog-loaded").load("Admin/EditEntries.aspx", function()
                                    {
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
                                        $("#EditEntriesDialog").dialog('open');

                                    });
                                }
                                else
                                {
                                    $("#EditEntriesDialog").dialog('open');
                                }
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
                        <input type="button" id="CreateUserButton" value="Create User" class="tiny-btn" />
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
                                <p>Filter movies by:</p>
                                <button class="ui-filter-btn TagFilterButton">Filter by Keyword <br>
                                    <select id="PlotKeywords" class="ui-plot-keywords theme"></select>
                                </button>
                                <input type="checkbox" class="ui-filter-btn NewMovieFilter" id="NewMovieFilter"/> 
                                <label for="NewMovieFilter" class="ui-filter-btn"> Show only <br>New Movies </label>
                                <input type="checkbox" class="ui-filter-btn RecomendedMovieFilter" id="RecomendedMovieFilter"/> 
                                <label for="RecomendedMovieFilter" class="ui-filter-btn">Show only <br>Recommended Movies</label>
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
                <li><a href="#tabs_reviews">Reviews</a></li>
                <li><a href="#tabs_imdb">IMDB</a></li>
                <li><a href="#tabs_rotten_tomatoes">Rotten Tomatoes</a></li>
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
                                <p id="mov_rating" class="cover-details-element-detail theme details-info">
                                    <div class="Star-Rating"></div>
                                </p>
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
                            </span> <br/>
                            <span class="cover-details-infoline multi-line">
                                <p class="cover-details-element-label theme multi-line">Keywords:</p>
                                <div id="mov_plotkeywords" class="cover-details-element-detail theme details-info multi-line"></div>
                        </section>
                        <section id="cover-details" class="tableCell table-thirds">
                            <span class="cover-details-infoline multi-line">
                                <p class="cover-details-element-label theme multi-line">
                                    Cast:
                                </p>
                                <p id="mov_cast" class="cover-details-element-detail theme details-info multi-line"></p>
                            </span>
                            <span class="cover-details-infoline multi-line">
                                <p class="cover-details-element-label theme multi-line">
                                    Producer:
                                </p>
                                <p id="mov_directors" class="cover-details-element-detail theme details-info multi-line"></p>
                            </span>
                            <span class="cover-details-infoline multi-line">
                                <p class="cover-details-element-label theme multi-line">
                                    Writers:
                                </p>
                                <p id="mov_writers" class="cover-details-element-detail theme details-info multi-line"></p>
                            </span>
                            <br />
                            <span class="cover-details-infoline ">
                                <p class="cover-details-element-label theme ">
                                    Oscars:
                                </p>
                                <p id="mov_oscars" class="cover-details-element-detail theme details-info "></p>
                            </span>
                            <span class="cover-details-infoline ">
                                <p class="cover-details-element-label theme ">
                                    Nominations:
                                </p>
                                <p id="mov_nominations" class="cover-details-element-detail theme details-info "></p>
                            </span>


                        </section>
                        <section id="cover-details" class="tableCell table-thirds">
                            <div id="trailer"></div>
                        </section>
                    </div>
                </div>
            </div>
            <div id="tabs_reviews" class="MainBodyOffset user-review hex-background ">
                <div class="ui-user-review theme"> 
                    <a id="toggleUserReview" class="ui-toggle-user-review theme">Your review of this movie.</a>
                </div>
                <div id="userReviewForm" class="current-user-review">
                    <label id="UserRating" class="ui-user-review-text"></label><br />
                    <textarea id="UserReview" class = "ui-user-review-text theme" cols="50" rows="5" ></textarea><br />
                    <input id="btn_submit_review" type="button" class="Button" value="Submit Review" />
                </div>
                <div id="UserReviewDisplay" class="ui-user-Review-display theme"></div>
            </div>
            <div id="tabs_imdb" class="MainBodyOffset imdb-review hex-background ">
            </div>
            <div id="tabs_rotten_tomatoes" class="MainBodyOffset rotten-tomatoes-review hex-background ">
            </div>
        </div>

        <div id="dialogContainer"></div>
        <div id="RecomendationsDialog">
            <div class="recContainer"></div>
        </div>
        <div id="EnterRequestDialog"></div>

        <div id="CreateUserDialog"></div>

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
