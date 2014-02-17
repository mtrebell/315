//------------------------------------------------------------------------
// generic filtering support functions
//------------------------------------------------------------------------
function RemoveFilterSpan(filter)
// Remove the span, and clean up/ refresh...
{
    $("#"+filter.attr("data")).removeClass('AlphaFilterActive');

    filter.remove();
    coverFlowCtrl.coverflow("invalidateCache").coverflow('refresh');

}

//------------------------------------------------------------------------
// Functions for adding and removing the Alpha filters
//------------------------------------------------------------------------
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

        }
    });
    if (log) console.log("Result=" + res);
    if (log) console.groupEnd();
    return res;
}



