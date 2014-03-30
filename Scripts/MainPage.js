//------------------------------------------------------------------------
// generic filtering support functions
//------------------------------------------------------------------------
var FILTER_COVER_ALPHA = 0;
var FILTER_COVER_GENRE = 1;
var dbg_log_cover_filter = false;
var dbg = null;
function RemoveFilterSpan(filter)
// Remove the span, and clean up/ refresh...
{
    $("#"+filter.attr("data")).removeClass('AlphaFilterActive').removeClass("genre-selected");

    filter.remove();
    coverFlowCtrl.coverflow("invalidateCache").coverflow('refresh');

}

//------------------------------------------------------------------------
// Functions for adding and removing the Alpha filters
//------------------------------------------------------------------------
function AlphaFilterButtonClick(e)
// when the alpha filter is clicked then this is called
{
    e.preventDefault();
    if ( filterFlowCtrl.coverflow('index') !== FILTER_COVER_ALPHA || $('.ui-dialog-content').dialog('isOpen').length > 0)
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
}

function AddAlphaFilter(filterID)
// Add a Filter span to the filter bar.
{
    var filterBar = $("#FilterBar");
    filterBar.append(
        '<span class = "filter filter_alpha theme" ' +
        'id="Filter_' + filterID + '" ' +
        'data="' + filterID + '" ' +
        'filterKey="'+ $("#"+filterID).html() +'" ' +
        '>' +
        $("#"+filterID).html() +
        '</span>'
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

    coverFlowCtrl.coverflow("invalidateCache").coverflow('refresh');
}


function DelAlphaFilter(filterID)
// Remove a filter div
{
    RemoveFilterSpan($("#FilterBar #Filter_" + filterID));
    // do this as mutating events cause problems.

}
//------------------------------------------------------------------------
// Functions for adding and removing the Alpha filters
//------------------------------------------------------------------------
function GenreFilterButtonClick(e)
// When the genre filter buttons are clicked, then this is activated.
{
    e.preventDefault();
    if ( filterFlowCtrl.coverflow('index') !== FILTER_COVER_GENRE)
    {
        console.log("GenreFilterButtonClick %s", filterFlowCtrl.coverflow('index'));
        return;
    }
    $(this).toggleClass('genre-selected');
    var idStr = $(this).attr('id');
    if ($("#FilterBar #Filter_" + idStr).length !== 0)
    {
        console.log(" remove selected %o", $("." + idStr));
        $("." + idStr).removeClass("genre-selected");
        DelGenreFilter($(this).attr('id'));
    }
    else
    {
        console.log(" add selected %o", $("." + idStr));
        $("." + idStr).addClass("genre-selected");
        AddGenreFilter($(this).attr('id'), $(this).find("span").html());
    }
}

function AddGenreFilter(filterID, key)
// Add a Filter span to the filter bar.
{
    var filterBar = $("#FilterBar");
    console.log("add genere %o", filterID);
    filterBar.append(
        '<span class = "filter filter_genre theme" ' +
        'id="Filter_' + filterID + '" ' +
        'data="' + filterID + '" ' +
        'filterKey="'+ key +'" ' +
        '>' +
        key +
        '</span>'
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

    coverFlowCtrl.coverflow("invalidateCache").coverflow('refresh');
}


function DelGenreFilter(filterID)
// Remove a filter div
{
    RemoveFilterSpan($("#FilterBar #Filter_" + filterID));
    // do this as mutating events cause problems.

}
//------------------------------------------------------------------------

//------------------------------------------------------------------------
// Handle the adding of Tag filters.
//------------------------------------------------------------------------
function AddTagFilter(filterTag)
{
    var filterBar = $("#FilterBar");
    console.log("add tag filter %s", $("#TagFilterInput").val());
    if (filterBar.find(".filter_tag[filterKey='" + filterTag.toLowerCase() + "']").length === 0)
    {
        var filterID = filterTagID;
        filterTagID ++;
        filterBar.append(
            '<span class = "filter filter_tag" ' +
            'id="Filter_Tag_' + filterID + '" ' +
            ' data="'/* + filterID */ + '" ' +
            ' filterKind="TAG" ' +
            ' filterKey="'+ filterTag +'" ' +
            '>' +
            "Plot Keyword: " + filterTag +
            '</span>'
        );

        filterBar.find("#Filter_Tag_"+filterID)
            .button({icons: {
                secondary: "ui-icon-closethick"
            }})
            .click(function(e){
            e.preventDefault();
            RemoveFilterSpan($(this));
        });
        coverFlowCtrl.coverflow("invalidateCache").coverflow('refresh');

    }


}
//------------------------------------------------------------------------

//------------------------------------------------------------------------
// Cover flow support functions
//------------------------------------------------------------------------
function AddNewMovieFilter()
{
    var filterBar = $("#FilterBar");
    if (filterBar.find("#Filter_New").length !== 0)
    {
        filterBar.find("#Filter_New").remove();
    }
    else
    {
        filterBar.append(
            '<span class = "filter filter_new" ' +
            ' id="Filter_New"' +
            ' filterKind="NEW" ' +
            ' filterKey="" ' +
            '>New Movies</span>'
        );

        filterBar.find("#Filter_New")
            .button({icons: {
                secondary: "ui-icon-closethick"
            }})
            .click(function(e){
                e.preventDefault();
                RemoveFilterSpan($(this));
                $(".NewMovieFilter").prop('checked', false).button('refresh');
            });
    }
    coverFlowCtrl.coverflow("invalidateCache").coverflow('refresh');
}
//------------------------------------------------------------------------
//------------------------------------------------------------------------
// Cover flow support functions
//------------------------------------------------------------------------
function AddRecomendedMovieFilter()
{
    var filterBar = $("#FilterBar");
    if (filterBar.find("#Filter_Recommend").length !== 0)
    {
        filterBar.find("#Filter_Recommend").remove();
    }
    else
    {

        filterBar.append(
            '<span class = "filter filter_recomend" ' +
            ' id="Filter_Recommend"' +
            ' filterKind="RECOMMEND" ' +
            ' filterKey="" ' +
            '>Recommended Movies</span>'
        );

        filterBar.find("#Filter_Recommend")
            .button({icons: {
                secondary: "ui-icon-closethick"
            }})
            .click(function(e){
                e.preventDefault();
                RemoveFilterSpan($(this));
                $(".RecomendedMovieFilter").prop('checked', false).button('refresh');

            });
    }
    coverFlowCtrl.coverflow("invalidateCache").coverflow('refresh');
}
//------------------------------------------------------------------------


//------------------------------------------------------------------------
// Cover flow support functions
//------------------------------------------------------------------------
function CoverFilter(cover)
// This will look at the filter division and cause the cover flow to
// hide the some covers based on these filtering criteria
//
{
    var log=dbg_log_cover_filter;
    var title = $(cover).find("#info #mov_title").html();
    var genre = $(cover).find("#info #mov_genre").html().trim().toLowerCase();
    var new_movie = $(cover).hasClass("new-movie");
    var recommended_movie = $(cover).hasClass("recommended-movie");

    var filters = $("#FilterBar span");
    var results = {
        alpha: true,
        tag: true,
        genre: true,
        newMovie: true,
        recommend: true
    };
    if (log) console.groupCollapsed("filter: %s res= %s", title, res);
    filters.each(function(idx, value)
    {
        if ($(value).hasClass("filter_alpha")) {
            results.alpha |= title.substr(0,1).toUpperCase() == $(this).attr('filterKey');
            if (log) console.log("Alpha: %s res= %s", $(this).attr('filterKey'), results.alpha);

        } else if ($(value).hasClass("filter_tag")) {
            if (log) console.log("Tag: %s res= %s", $(this).attr('filterKey'), results.tag);
            results.tag &= $(cover).hasClass("plot-keyword-" + $(this).attr('filterKey').toLowerCase());

        } else if ($(value).hasClass("filter_genre")) {
            results.genre |= genre.indexOf($(this).attr('filterKey').trim().toLowerCase()+',') >= 0;
            if (log) console.log("Genre: %s %s res= %s, %s",genre, $(this).attr('filterKey'), results.genre, genre.indexOf($(this).attr('filterKey')+','));

        } else if ($(value).hasClass("filter_new")) {
            results.newMovie &= new_movie;
            if (log) console.log("New: %s res= %s", new_movie, results.newMovie);

        } else if ($(value).hasClass("filter_recomend")) {
            if (log) console.log("Recommend: res= %s", results.recommend);
            results.recommend &= recommended_movie;
        }
    });
    var res = (results.alpha && results.tag && results.genre && results.newMovie && results.recommend);
    if (res) res = true;
    if (log) console.log("Result = %o (%o)", results, res);
    if (log) console.groupEnd();
    return res;
}

//------------------------------------------------------------------------
// Movie label code.
//------------------------------------------------------------------------
function MovieOlderThanDays(currentD, movieD, daysOlderThan)
// Is a movie older than a given number of days
{
    var date = new Date();

    var month = date.getMonth() + 1;
    var day = date.getDate();
    var year = date.getFullYear();
    var dateArr = movieD.split("/");

    //Movie is new if less than 11 days old
    if (Math.abs(day - dateArr[1]) < daysOlderThan) {
        //with in month
        if (month == dateArr[0] && year == dateArr[2])
            return true;
        //Account for end of month
        if (Math.abs(dateArr[0] - month) < 2 && year == dateArr[2])
            return true;
        //account for end of year
        if (dateArr[2] - year < 2 && dateArr[0] == 12)
            return true;
    }

    return false;

}
//------------------------------------------------------------------------
// Grid View Code
//------------------------------------------------------------------------

function GenerateMovieGrid(srcData, dest, moviesPerRow)
/*
    GenerateMovieGrid:
        Creates a table and displays all covers within
        the current filter.

        srcData:
            source data containing divs of class cover or cover-not-loaded

        dest:
            destination div to stuff the generated table into

        moviesPerRow:
            the number of movies to display per row
*/
{

    $(dest).css('display', 'table');
    var i = 0, divObj;
    $(srcData + ' .cover').each(function () {
        //If movie is not in the current filter, skip it
        if (!CoverFilter($(this))) return;

        var curRow = parseInt(i / moviesPerRow , 10);

        //create new row if necessary
        if (i % moviesPerRow === 0) {
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
        $(movie).removeAttr('style').attr('height', '300px').attr('width', '200px').show();

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

function MovieGridShowInView()
/*
MoviesGridShowInView
    Loads the images of movies in the grid view based on
    whether they are "in view" or not.

    Also, while it loops each image, it adds a click
    method to take the user to that movie on the coverflow
*/
{
    $("#GridDialog").find($(".gridCover")).each(function(cover){
        var img = $(this).find('img');
        if ($(this).visible(true)) {
            //if image is visible
            if (!$(img).attr('src')){
                //set the img src attribute
                $(img).attr('src', $(img).attr('data-src')).click(function(e){
                    //when image is clicked, exit grid view and set main page
                    //to clicked image.
                    $('#GridDialog').dialog('close');


                    //if the movie is within 10 covers of the coverflows current index
                    //then animate, otherwise, jump
                    var curIndex = coverFlowCtrl.coverflow('index');
                    var cfIndex = $(img).attr('cfIndex');
                    //coverflow shows 9 movies on both sides of the current one
                    if (cfIndex >= curIndex - 9 && cfIndex <= curIndex + 9) {
                        coverFlowCtrl.coverflow('index', cfIndex);
                    } else {
                        coverFlowCtrl.coverflow('index', cfIndex, false);
                    }
                });
            }
        }
    });
}


//------------------------------------------------------------------------
// Movie Review Code
//------------------------------------------------------------------------
function GetMovieReviewIMDB(ui)
// this will get the IMDB reviews into the new tab
{
    console.log("IMDB: %o", ui.newPanel.attr("dataUrl"));
    $.ajax({
        type: "POST",
        url: "MainPage.aspx/GetIMDbReviews",
        data: JSON.stringify({ 'imdbID': ui.newPanel.attr("dataUrl") }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (msg) {
            var div = msg.d;
            console.log(msg);
            ui.newPanel.html(div);
        },
        cache: false
    });
}

function GetMovieReviewRotten(ui)
// This will get the rotten tomato reviews into the selected tab.
{
    $.ajax({
        type: "POST",
        url: "MainPage.aspx/GetRottenReviews",
        data: JSON.stringify({ 'imdbID': ui.newPanel.attr("dataUrl") }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (msg) {
            var div = msg.d;
            console.log(msg);
            ui.newPanel.html(div);
        },
        cache: false
    });
}

//------------------------------------------------------------------------
// Movie trailer Code
//------------------------------------------------------------------------
function getTrailer(movieId)
{
    if (movieId === undefined)
    {
        $("#trailer").html("");
        return;
    }
    var obj = { 'mov_id': movieId };
    $.ajax({
        type: "POST",
        url: "MainPage.aspx/getURL",
        data: JSON.stringify(obj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (response) {
            if (response.d !== "")
            {
                var id = response.d;
                //Add video
                var frame = "<iframe  type='text/html' width='425' height='349' src=' http://www.youtube.com/embed/" + id + "' frameborder='0'></iframe>";
                $("#trailer").html(frame);
            }
            else
            {
                $("#trailer").html("");
            }
        }
    });
}
