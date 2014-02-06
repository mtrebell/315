<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="MainPage.aspx.cs" Inherits="_Default" %>

<asp:Content ContentPlaceHolderID="head" Runat="Server">
    <style>
        #MovieList {
            padding-top: 50px;
            padding-bottom: 150px;
            /*height: 500px;*/
            background: black;
            border:     solid white 1px;

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
        #LeftMenu {
            float:      left;
            position:   absolute;
            top:        0px;
            background: rgb(100,100,100);
            height:     100em;
            width:      15em;
            z-index:    1000;
            border:     solid white 1px;
            color:      white;
        }
        #MovieFilterBox {
            background: black;
            border:     solid white 1px;
            width:      100%;            
        }
        #MovieFilter div.cover {
            height:     7em;
            width:      30em;
        }
        #FilterAlpha {
            background: red;
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

        div.tableContainer{
            display:    table;
        }
        div.tableRow{
            display: tabe-erow;
        }
        section.tableCell {
            display:    table-cell;
        }
    </style>


</asp:Content>



<asp:Content ContentPlaceHolderID="body" Runat="Server">
    <script type="text/javascript">
        var coverFlowCtrl = null;
        $(function() 
        {
            $("#CoverFlow").load("GetMovieList.aspx", function() 
            {
                $('#CoverFlow .hidden').hide();
                console.log("got Movie List");
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
            $('#MovieFilter').coverflow()
            $("#LeftMenu").hide();
            $("ul.menu").menu();
            $("#Content").tabs();
            $("#OpenMenu").button({icons: {primary:"ui-icon-home"}   })
                .click(function(event){
                    $( "#LeftMenu" ).show( "slide", {}, 500 );
                    event.preventDefault();
                });
            $("#closeBtn").click(function(event){
                $( "#LeftMenu" ).hide( "slide", {}, 500 );
            });
            $("#TestBtn").button().click(function(event) {
                $("#MenuHandle").toggle({width:"15em"}, 500, function(){$('#CoverFlow').coverflow("refres");});

            });
        });
    </script>
    <div class="tableContainer">
    <div class="tableRow">
        <section class="tableCell">
            <div id="LeftMenu">
                <ul class="menu">
                    <li class="ui-state-disabled"><a href="#">Aberdeen</a></li>
                    <li><a id="closeBtn" href="#">Ada</a></li>
                    <li><a href="#">Adamsville</a></li>
                    <li><a href="#">Addyston</a></li>
                </ul>
            </div>

            <div id="MenuHandle">
                <a id="OpenMenu" ></a> 
                <a id="TestBtn" ></a> 
            </div>

        </section>
        <section class="tableCell">

            <div id="MovieList">
                <div id="CoverFlow" > </div>
            </div>
            <div id="MovieFilterBox">
                <div id="MovieFilter">
                    <div id="FilterAlpha" class="cover" > Alpha Filter </div>
                    <div id="FilterTag" class="cover" > tag Filter </div>
                    <div id="FilterGenra" class="cover" > genera Filter </div>
                    <div id="FilterRating" class="cover" > rating Filter </div>
                </div>
            </div>
            <div id="Content">
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

        </section>
    </div>
</div>
</asp:Content>

