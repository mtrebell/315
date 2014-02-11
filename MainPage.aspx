<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="MainPage.aspx.cs" Inherits="_Default" %>

<asp:Content ContentPlaceHolderID="head" Runat="Server">
    <style>
        body {
            margin: 0px;
        }
        #MovieList {
            padding-top: 50px;
            padding-bottom: 150px;
            /*height: 500px;*/
            background: black;
            background-image:  inherit;

        }
        #CoverFlow .cover {
            cursor:     pointer;
            width:      200px;
            height:     250px;
            box-shadow: 0 0 4em 1em #000040;
        }
        #MenuHandle {
            /*float:      left;*/
            position:   absolute;
            top:        0px;
            background: black;
            height:     100em;
        }
        #menu {
            float:      left;
            position:   fixed;
            top:        0px;
            height:     100em;
            width:      15em;
            z-index:    1000;
            color:      white;
        }
        #MovieFilterBox {
            background: black;
            width:      100%; 
            height: 8em;
            background-image:  inherit;

        }
        #MovieFilter div.cover {
            height:     6.5em;
            width:      60%;
            background-image:  url(Background_Images/hex-Bkgrd.jpg);
            background-size: 40%;
            border: blue double 4px;
            border-radius: 30px;
            margin-top: 0.5em;
            margin-bottom: 0.5em;
        }
        #MovieFilter div p {
            text-align: center;
            margin: 0.3em;
            color: white;
        }
        #FilterGeneral {
            background: blue;
        }
        #FilterRating {
            background: yellow;
        }
        .MainBodyOffset {
            padding-left: 40px; 
            background: black;
        }
        div.tableContainer{
            display:    table;
            position:   relative;
            width: 100%;
            background-image:  url(Background_Images/hex-Bkgrd.jpg);
        }
        div.tableRow{
            display: table-row;
<<<<<<< HEAD
=======
            width: 100%;
            background-image:  inherit;
>>>>>>> origin
        }
        section.tableCell {
            display:    table-cell;
            background-image:  inherit;

        }
        #Content{
            min-height: 30em;
        }
        #FilterAlpha {
            background: black;
            color: white;
        }
        #FilterAlpha span{
            text-align: center;
            vertical-align: top;       
            margin: 1em 1.2em 1em 1.0em;
            color: white;     
            cursor: crosshair;    
        }
        #FilterAlpha .filterGrooup {
            padding-top:   0.2em;
            padding-bottom: 1em; 
            text-align: center;
            margin-left: auto;
            margin-right:  auto;
        }
        .AlphaFilterActive{
            background-color: rgba(0,0,255,128);
            -webkit-box-shadow: 1px 1px 5px 10px rgba(0,0,255,128);
            -moz-box-shadow: 1px 1px 5px 10px rgba(0,0,255,128);
            box-shadow: 1px 1px 5px 10px rgba(0,0,255,128);

            -webkit-border-radius: 70px;
            -moz-border-radius: 70px;
            border-radius: 70px;

            -webkit-transition: box-shadow .4s ease;
            -moz-transition: box-shadow .4s ease;
            -o-transition: box-shadow .4s ease;
            -ms-transition: box-shadow .4s ease;
            transition: box-shadow .4s ease;
        }
        #FilterTag
        {
            background: black;
        }

        #FilterBar{
            height: 3em;
        }
        #FilterBar span{
            color: white;

            /*background: blue;*/
        }
        .ui-icon { display: inline; text-indent: -99999px; overflow: hidden; background-repeat: no-repeat; }
        .Border{
            background-image:url("Background_Images/Std_Header.png");
            background-position: top;
            background-repeat: no-repeat;   
        }
    </style>


</asp:Content>



<asp:Content ContentPlaceHolderID="body" Runat="Server">
    <script type="text/javascript">
        var filterTagID = 0;
        var coverFlowCtrl = null;
        // Add a Filter span to the filter bar. 
        function AddAlphaFilter(filterID)
        {
            var filterBar = $("#FilterBar");
            filterBar.append(
                  '<span id="Filter_' + filterID + '" '
                + 'data="' + filterID + '"'
                + ' filterKind="ALPHA" '
                + ' filterKey="'+ $("#"+filterID).html() +'" '
                + '>' 
                + $("#"+filterID).html() 
                +'</span>'
            );

            filterBar.find("#Filter_"+filterID)
                .button({icons: {
                    secondary: "ui-icon-closethick"
                }})
                .click(function(e){
                    e.preventDefault();
                    RemoveFilterSpan($(this));
                }
            );
        };
        // Remove a filter div
        function DelAlphaFilter(filterID)
        {
            RemoveFilterSpan($("#FilterBar").find("span #Filter_" + filterID));
        };

        function AddTagFilter(filterTag)
        {
            console.log("add tag filter " + $("#TagFilterInput").val());
            var filterBar = $("#FilterBar");
            var filterID = filterTagID;
            filterTagID ++;
            filterBar.append(
                  '<span id="Filter_Tag_' + filterID + '" ' 
                + ' data="'/* + filterID */ + '" '
                + ' filterKind="TAG" '
                + ' filterKey="'+ filterTag +'" '
                +'>' 
                + "Tag: " + filterTag
                +'</span>'
            );

            filterBar.find("#Filter_Tag_"+filterID)
                .button({icons: {
                    secondary: "ui-icon-closethick"
                }})
                .click(function(e){
                e.preventDefault();
                RemoveFilterSpan($(this));
            });
        }
        // REmove the span, and clean up/ refresh...
        function RemoveFilterSpan(filter)
        {
            $("#"+filter.attr("data")).removeClass('AlphaFilterActive'); 

            filter.remove();
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
                    filterCover:   function (cover) {}
                });
            });

            $('#MovieFilter').coverflow();
            $("#Content").tabs();
            $("#dialogContainer").hide();
            $('#menu').multilevelpushmenu({
                backItemIcon: 'fa fa-angle-left',
                groupIcon: 'fa fa-angle-right',
                collapsed: true,
                // containersToPush: [ $( '#mainBody' ), $('#Content') ],
            });

            // Set up the click event for the alpha filters.
            $('.AlphaFilterButton').click(function(e) { 
                e.preventDefault();
                if ( $("#MovieFilter").coverflow('index') !== 0)
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

        }); // End Doc Ready.
    </script>

    <div id="mainBody" class="tableContainer MainBodyOffset Border">
        <div class="tableRow">
            <section class="tableCell">
                <img src="Background_Images/Std_Header.png" style="width:100%"/>
                <div id="MovieList">
                    <div id="CoverFlow" > </div>
                </div>
            </section>
        </div>

        <div class="tableRow">
            <section class="tableCell">
                <div id="FilterBar"></div>
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
                            </div>
                            <div class="filterGrooup">
                                <span id="Alpha_N" class="AlphaFilterButton">N</span> 
                                <span id="Alpha_O" class="AlphaFilterButton">O</span> 
                                <span id="Alpha_P" class="AlphaFilterButton">P</span> 
                                <span id="Alpha_Q" class="AlphaFilterButton">Q</span> 
                                <span id="Alpha_R" class="AlphaFilterButton">R</span> 
                                <span id="Alpha_S" class="AlphaFilterButton">S</span> 
                                <span id="Alpha_T" class="AlphaFilterButton">T</span> 
                                <span id="Alpha_U" class="AlphaFilterButton">U</span> 
                                <span id="Alpha_V" class="AlphaFilterButton">V</span> 
                                <span id="Alpha_W" class="AlphaFilterButton">W</span> 
                                <span id="Alpha_X" class="AlphaFilterButton">X</span> 
                                <span id="Alpha_Y" class="AlphaFilterButton">Y</span> 
                                <span id="Alpha_Z" class="AlphaFilterButton">Z</span> 
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
            <li><a href="#tabs-1">Personal</a></li>
            <li><a href="#tabs-2">IMDB</a></li>
            <li><a href="#tabs-3">Rotten Toimato</a></li>
        </ul>
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
        <h2><i class="fa fa-reorder"></i>Movie Madness</h2>
        <ul>
            <li>
                <a href="#">Login</a>
            </li>
            <li>
                <a href="#">Collections</a>
            </li>
            <li>
                <a href="#">Credits</a>
            </li>
        </ul>
      </nav>
    </div>
    <div id="dialogContainer"> this is a popup</div>
</asp:Content>

