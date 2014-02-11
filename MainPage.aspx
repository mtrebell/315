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
            border:     solid white 1px;
            background-image:  inherit;

        }
        #CoverFlow .cover {
            cursor:     pointer;
            width:      200px;
            height:     300px;
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
            border:     solid white 1px;
            width:      100%;            
            background-image:  inherit;

        }
        #MovieFilter div.cover {
            height:     7em;
            width:      30em;
        }
        #FilterTag
        {
            background: green;
        }
        #FilterGenra {
            background: blue;
        }
        #FilterRating {
            background: yellow;
        }
        .MainBodyOffset {
            padding-left: 35px; 
        }
        div.tableContainer{
            display:    table;
            position:   relative;
            width: 100%;
            background-image:  url(Background_Images/hex-Bkgrd.jpg);
        }
        div.tableRow{
            display: table-row;
            width: 100%;
            background-image:  inherit;
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
        }
        #FilterAlpha span{
            display: inline-block;
            text-align: center;
            vertical-align: middle;       
            padding: 0.2em;
            margin: 0.4em;
            color: white;     
        }
        .AlphaFilterActive{
            background-color: rgba(0,0,255,255);
            -webkit-box-shadow: 1px 1px 5px 5px rgba(0,0,255,255);
            -moz-box-shadow: 1px 1px 5px 5px rgba(0,0,255,255);
            box-shadow: 1px 1px 5px 5px rgba(0,0,255,255);

            -webkit-border-radius: 50px;
            -moz-border-radius: 50px;
            border-radius: 50px;

            -webkit-transition: box-shadow .4s ease;
            -moz-transition: box-shadow .4s ease;
            -o-transition: box-shadow .4s ease;
            -ms-transition: box-shadow .4s ease;
            transition: box-shadow .4s ease;
        }
        #FilterBar span{
            color: white;
            /*background: blue;*/
        }
        .ui-icon { display: inline; text-indent: -99999px; overflow: hidden; background-repeat: no-repeat; }
    </style>


</asp:Content>



<asp:Content ContentPlaceHolderID="body" Runat="Server">
    <script type="text/javascript">

        var coverFlowCtrl = null;
        function AddAlphaFilter(filterID)
        {
            console.log("AddAlphaFilter "+ filterID);
            var filterBar = $("#FilterBar");
            filterBar.append(
                  '<span id="Filter_' 
                + filterID 
                +'" data="'
                + filterID 
                + '">' 
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
            })
        };
        function DelAlphaFilter(filterID)
        {
            console.log("DelAlphaFilter "+ filterID);
            RemoveFilterSpan($("#FilterBar").find("span #Filter_" + filterID));
        };
        function RemoveFilterSpan(filter)
        {
            console.log("RemoveFilterSpan");
            $("#"+filter.attr("data")).removeClass('AlphaFilterActive'); 

            filter.remove();
        }
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
                    }
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

            $('.AlphaFilterButton').click(function(e) { 
                e.preventDefault();
                $(this).toggleClass('AlphaFilterActive'); 
                var f = "#FilterBar #Filter_"+$(this).attr('id');
                console.log(e);
                console.log(f);
                if ($(f).length !== 0)
                {
                    DelAlphaFilter($(this).attr('id'));
                }
                else
                {
                    AddAlphaFilter($(this).attr('id'));
                }
            });

            $( window ).resize(function() {
                $( '#menu' ).multilevelpushmenu( 'redraw' );
            });

        }); // End Doc Ready.
    </script>

    <div id="mainBody" class="tableContainer MainBodyOffset">
        <div class="tableRow">
            <section class="tableCell">
                <div id="MovieList">
                    <div id="CoverFlow" > </div>
                </div>
            </section>
        </div>

        <div class="tableRow">
            <section class="tableCell">
                <div id="FilterBar"></div>
            </section>
        </div>
        <div class="tableRow">
            <section class="tableCell">
                <div id="MovieFilterBox">
                    <div id="MovieFilter">
                        <div id="FilterAlpha" class="cover" > 
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
                        <div id="FilterTag" class="cover" > tag Filter </div>
                        <div id="FilterGenra" class="cover" > genera Filter </div>
                        <div id="FilterRating" class="cover" > rating Filter </div>
                    </div>
                </div>
            </section>
        </div>

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

