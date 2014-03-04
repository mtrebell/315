//------------------------------------------------------------------------
// generic filtering support functions
//------------------------------------------------------------------------
var FILTER_COVER_ALPHA = 0;
var FILTER_COVER_GENRE = 1;
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
};

function AddAlphaFilter(filterID)
// Add a Filter span to the filter bar.
{
    var filterBar = $("#FilterBar");
    filterBar.append(
          '<span class = "filter filter_alpha" '
        + 'id="Filter_' + filterID + '" '
        + 'data="' + filterID + '" '
        + 'filterKey="'+ $("#"+filterID).html() +'" '
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

    coverFlowCtrl.coverflow("invalidateCache").coverflow('refresh');
};


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
          '<span class = "filter filter_genre" '
        + 'id="Filter_' + filterID + '" '
        + 'data="' + filterID + '" '
        + 'filterKey="'+ key +'" '
        + '>'
        + key
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

    coverFlowCtrl.coverflow("invalidateCache").coverflow('refresh');
};


function DelGenreFilter(filterID)
// Remove a filter div
{
    RemoveFilterSpan($("#FilterBar #Filter_" + filterID));
    // do this as mutating events cause problems.

};
//------------------------------------------------------------------------

//------------------------------------------------------------------------
// Handle the adding of Tag filters.
//------------------------------------------------------------------------
function AddTagFilter(filterTag)
{
    console.log("add tag filter " + $("#TagFilterInput").val());
    var filterBar = $("#FilterBar");
    var filterID = filterTagID;
    filterTagID ++;
    filterBar.append(
          '<span class = "filter filter_tag" '
        + 'id="Filter_Tag_' + filterID + '" '
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
    var log=false;
    var title = $(cover).find("#info #mov_title").html();
    var genre = $(cover).find("#info #mov_genre").html().trim().toLowerCase();
    var filters = $("#FilterBar span");
    var res = filters.length === 0;

    if (log) console.groupCollapsed("filter: %s res= %s", title, res);
    filters.each(function(idx, value)
    {
        if ($(value).hasClass("filter_alpha")) {
            res |= title.substr(0,1).toUpperCase() == $(this).attr('filterKey');
            if (log) console.log("Alpha: %s res= %s", $(this).attr('filterKey'), res);

        } else if ($(value).hasClass("filter_tag")) {
            if (log) console.log("Tag: %s res= %s", $(this).attr('filterKey'), res);

        } else if ($(value).hasClass("filter_genre")) {
            if (log) console.log("Genre: %s %s res= %s, %s",genre, $(this).attr('filterKey'), res, genre.indexOf($(this).attr('filterKey')+','));
            res |= genre.indexOf($(this).attr('filterKey').trim().toLowerCase()+',') >= 0;

        }
    });
    if (res) res = true;
    if (log) console.log("Result=" + res);
    if (log) console.groupEnd();
    return res;
}



