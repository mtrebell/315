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
        return;
    }
    $(this).toggleClass('genre-selected');
    var idStr = $(this).attr('id');
    if ($("#FilterBar #Filter_" + idStr).length !== 0)
    {
        $("." + idStr).removeClass("genre-selected");
        DelGenreFilter($(this).attr('id'));
    }
    else
    {
        $("." + idStr).addClass("genre-selected");
        AddGenreFilter($(this).attr('id'), $(this).find("span").html());
    }
}

function AddGenreFilter(filterID, key)
// Add a Filter span to the filter bar.
{
    var filterBar = $("#FilterBar");
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
        alpha: $("#FilterBar span.filter_alpha").length === 0,
        tag: true,
        genre: $("#FilterBar span.filter_genre").length === 0,
        newMovie: true,
        recommend: true
    };
    if (log) console.groupCollapsed("filter: %s res= %s", title, res);
    filters.each(function(idx, value)
    {
        if ($(value).hasClass("filter_alpha")) {
            results.alpha |= title.substr(0,1).toUpperCase() == $(this).attr('filterKey');
            if (log) console.log("Alpha: %s %s res= %s", $(this).attr('filterKey'), title.substr(0,1).toUpperCase() == $(this).attr('filterKey'), results.alpha);

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

function GenerateMovieGrid(srcData, dest, moviesPerRow, cssClass)
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
    $(srcData + ' ' + cssClass).each(function () {
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
        }).addClass('gridCover-unloaded');

        $(container).append(movie, movieInfo);
        $(container).appendTo(dest + ' .gridRow' + curRow);
        i++;
    });
}

function MovieGridShowInView(dialogName)
/*
MoviesGridShowInView
    Loads the images of movies in the grid view based on
    whether they are "in view" or not.

    Also, while it loops each image, it adds a click
    method to take the user to that movie on the coverflow
*/
{
    $("#" + dialogName).find($(".gridCover-unloaded")).each(function (cover) {
        var imgContainer = this;
        var img = $(this).find('img');
        if ($(this).visible(true)) {
            //if image is visible
            if (!$(img).attr('src')){
                //set the img src attribute
                $(img).attr('src', $(img).attr('data-src')).click(function(e){
                    //when image is clicked, exit grid view and set main page
                    //to clicked image.
                    $('#' + dialogName).dialog('close');


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
                //remove this cover object from the queue of unloaded covers
                $(imgContainer).removeClass('.gridCover-unloaded');
                $(imgContainer).addClass('.gridCover');
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
    $.ajax({
        type: "POST",
        url: "MainPage.aspx/GetIMDbReviews",
        data: JSON.stringify({ 'imdbID': ui.newPanel.attr("dataUrl") }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (msg) {
            var div = msg.d;
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
            ui.newPanel.html(div);
        },
        cache: false
    });
}

function GetMovieUserReview(ui)
    // This will get the rotten tomato reviews into the selected tab.
{
    $.ajax({
        type: "POST",
        url: "MainPage.aspx/GetUserReviews",
        data: JSON.stringify({ 'mov_id': ui.newPanel.attr("dataUrl") }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (msg) {
            var reviews = msg.d;
            if (msg.d == "")
                return;

            temps = reviews.split('<divide>')[0];
            tempo = reviews.split('<divide>')[1];

            var self = {
                'self_rating': temps.split('<split>')[0],
                'self_review': temps.split('<split>')[1]
            };
            var others = [];
            var tempoo = null;
            if (tempo.indexOf("<end>") != -1)
                tempoo = tempo.split('<end>');

            if (tempoo != null) {
                for (var other in tempoo) {
                    var ora = tempoo[other].split('<split>')[0];
                    var ore = tempoo[other].split('<split>')[1];
                    others.push({
                        'other_rating': ora,
                        'other_review': ore
                    });
                }
            }
            $('#UserRating').html("You've currently given this title a " + self.self_rating + " rating");
            $('#UserReview').val(self.self_review);

            others.pop();
            if (others.length > 0)
                for (var i in others) {
                    $("#UserReviewDisplay").append("<hr /><div><label>Score Given: " + others[i].other_rating
                        + "</label><br /><p>" + others[i].other_review + "</p><hr /></div>");
                }
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
//------------------------------------------------------------------------
// Movie Rating Code
//------------------------------------------------------------------------
function setMovieRating(score, mov_id, starObj) {

    //multiply 5 scale value to 10 scale
    var finalScore = score * 2;
    //more details of raty here: http://wbotelhos.com/raty/
    var obj = { 'mov_id': mov_id, 'rating': finalScore};
    $.ajax({
        type: "POST",
        url: "MainPage.aspx/SaveRating",
        data: JSON.stringify(obj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (response) {
            if (response.d !== "")
            {
                //response should be the new average rating of the movie
                //startObj.score = response or something
            }
            else
                console.log("No rating response!");
        }
    });
}

function setMovieReview(review, mov_id, starObj) {

    //multiply 5 scale value to 10 scale
    //more details of raty here: http://wbotelhos.com/raty/
    var obj = { 'mov_id': mov_id,'review': review };
    $.ajax({
        type: "POST",
        url: "MainPage.aspx/SaveReview",
        data: JSON.stringify(obj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (response) {
            if (response.d !== "") {
                //response should be the new average rating of the movie
                //startObj.score = response or something
            }
            else
                console.log("No rating response!");
        }
    });
}
//-------------------------------------------------------------
//Recomender Calls
//-------------------------------------------------------------

//-----------------Get Recomendations-------------------
function recomender(){
    var recomended;
    $.ajax({
        type: "POST",
        url: "Members/Recomend.aspx/allRecomendations",
        data: "{}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (result) {
            recomended = result['d'];
            for (var i = 0; i < recomended.length; i++) {
                $("#movID_" + recomended[i]).prepend('<span class ="ui-recommended-movie-label theme"><h1 class="ui-recommended-movie-text theme fa fa-star"></h1></span>').addClass("recommended-movie");
            }
        }
    });
}

//Build the similarity Table
function buildModel() {
    $('<div id="updateRecDialog">Updating....</div>').dialog({
        dialogClass: "ui-ontop",
        resizable: false,
        title: "Update Recomendations"
        });

    $.ajax({
        type: "POST",
        url: "Members/Recomend.aspx/buildModel",
        data: "{}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function () {
            $('#updateRecDialog').append("Done");
        }
    });
}