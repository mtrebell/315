$(function () {
    $('#EditTemplate').hide();
    $('#AddEntryTemplate').hide();

    $("#dvAccordian").accordion({
        header: "h3",
        heightStyle: "content"
    });

    $("#clearAllMedia").click(function (e) {
        e.preventDefault();
        if(confirm('Are you sure you would like to clear all media content?')) {
            ClearDataBase();
            return false;
        }
    });
});

function ClearDataBase() {
    //var path = '<%= ServerRootPath %>';
    $.ajax({
        type: "POST",
        url: "Admin/EditEntries.aspx/DeleteAllMedia",
        data: "{}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (msg) {   
        },
        cache: false
    });
}

function AddEntry() {
    //var path = '<%= ServerRootPath %>';
    console.log("creating object");
    var objectData =
    {
        'mov_id': document.getElementById('Add_mov_id').value,
        'mov_title': document.getElementById('Add_mov_title').value,
        'mov_plot': document.getElementById('Add_mov_plot').value,
        'mov_genre': document.getElementById('Add_mov_genre').value,
        'mov_size': document.getElementById('Add_mov_size').value,
        'mov_fileType': $('#Add_mov_filetype').val(),
        'mov_rating': document.getElementById('Add_mov_rating').value,
        'mov_runTime': document.getElementById('Add_mov_runtime').value,
        'mov_lgPoster': $('#Add_mov_lgPoster').attr("src"),
        'mov_smPoster': $('#Add_mov_smPoster').attr("src"),
        'mov_trailer': document.getElementById('Add_mov_trailer').value,
        'mov_imdbUrl': document.getElementById('Add_mov_imdbURL').value,
        'updatedLg': InsertLg.updated,
        'updatedSm': InsertSm.updated
    };
    console.log(objectData);
    $.ajax({
        type: "POST",
        url: "Admin/EditEntries.aspx/AddEntryDB",
        data: JSON.stringify(objectData),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (msg) {
            var ret = msg.d.split('|');
            var mov_id = ret[0];
            var lgPost = ret[1];
            var smPost = ret[2];
            var dateAdded = ret[3];
            document.getElementById('hf_usedindexes').value =
                document.getElementById('hf_usedindexes').value + ", " + mov_id;

            var head = '<h3 id="Hdr' + mov_id + '"><label id="' + mov_id + 'bt" style="font-size: 140%;">' + objectData.mov_title + '~' + mov_id + '</label></h3>';

            var accord = '<div id="Acc' + mov_id + '">' +
                '<table><tr><td><label id="' + mov_id + 'bt" style="font-size: 140%;">' + objectData.mov_title + '~' + mov_id + '</label></td>' +
                '<td style="margin-left: auto;"><input type="button" value="Edit"  id="' + mov_id + 'Up" onclick="UpdateEntry(this.id)" class="Button" />' +
                '<input type="button" value="Delete" id="' + mov_id + '" class="Button"' +  
                    'onclick="if (confirm("Are you sure you would like to clear all media content?")){ DeleteEntry(this.id); } else return false;" />' + 
                '</td></tr><tr><td style="vertical-align: top;"><b>Movie ID: ' + mov_id + '</b></td><td rowspan="2">' +
                '<img id="' + mov_id + 'iL" src="' + lgPost + '" style="width: 200px; height: 300px;" /></td></tr>' +
                '<tr><td><b>Plot: </b><br /><label id="' + mov_id + 'bp">' + objectData.mov_plot + '</label></td></tr><tr><td colspan="2"><hr /></td></tr>' + 
                '<tr><td style="vertical-align: top;"><b>Genre: </b><label id="' + mov_id + 'bg">' + objectData.mov_genre + '</label></td><td rowspan="6">' +
                '<center><img id="' + mov_id + 'iS" src="' + smPost + '" style="width:100px; Height:150px" />' +
                '</center></td></tr><tr><td><label id="' + mov_id + 'bs">Size: ' + objectData.mov_size + '</label></td></tr>' +
                '<tr><td><label id="' + mov_id + 'bf">Format: ' + objectData.mov_fileType + '</label></td></tr>' + 
                '<tr><td><label id="' + mov_id + 'bm">Runtime: ' + objectData.mov_runTime + '</label></td></tr>' +
                '<tr><td><label id="' + mov_id + 'bd">Date Added: ' + dateAdded + '</label></td></tr>' +
                '<tr><td><label id="' + mov_id + 'br">Rating: ' + objectData.mov_rating + '</label></td></tr>' + 
                '<tr><td><label id="' + mov_id + 'be">Trailer Link:' + objectData.mov_trailer + '</label></td></tr>' +
                '<tr><td><label id="' + mov_id + 'bi">IMDb URL: ' + objectData.mov_imdbUrl + '</label></td></tr></table></div>';

            console.log(accord);
            $("#dvAccordian").append(head).append(accord).accordion('destroy').accordion();
            InsertLg = InsertSm = false;
        },
        cache: false
    });
}

function DeleteEntry(id) {
    //var path = '<%= ServerRootPath %>';
    window.alert(id);
    var objectData = { 'mov_id': id };
    $.ajax({
        type: "POST",
        url: "Admin/EditEntries.aspx/DeleteEntryDB",
        data: JSON.stringify(objectData),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (msg) {
            var parent = document.getElementById('dvAccordian');

            parent.removeChild(document.getElementById('Hdr' + id));
            parent.removeChild(document.getElementById('Acc' + id));
        },
        cache: false
    });
}

function UpdateEntry(id) {
    //var path = '<%= ServerRootPath %>';
    var movid = str = id.substring(0, id.length - 2);

    var objectData = { 'mov_id': movid };
    $.ajax({
        type: "POST",
        url: "Admin/EditEntries.aspx/UpdateEntryDB",
        data: JSON.stringify(objectData),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (msg) {

            var divHTML = document.getElementById('Acc' + movid).innerHTML;
            document.getElementById('Acc' + movid).innerHTML
                = document.getElementById('EditTemplate').innerHTML;
            document.getElementById('EditTemplate').innerHTML = divHTML;

            var array = msg["d"].toString().split('|');
            console.log(array);

            document.getElementById('Edit_mov_id').innerHTML = array[0].toString();
            document.getElementById('Edit_mov_title').value = array[1].toString();
            document.getElementById('Edit_mov_plot').value = array[2].toString();
            document.getElementById('Edit_mov_genre').value = array[3].toString();
            document.getElementById('Edit_mov_size').value = array[4].toString();
            $('#Edit_mov_filetype').val(array[5].toString());
            document.getElementById('Edit_mov_dateAdded').value = array[6].toString();
            document.getElementById('Edit_mov_rating').value = array[7].toString();
            document.getElementById('Edit_mov_runtime').value = array[8].toString();
            $('#Edit_mov_lgPoster').attr("src", array[9].toString());
            $('#Edit_mov_smPoster').attr("src", array[10].toString());
            document.getElementById('Edit_mov_trailer').value = array[11].toString();
            document.getElementById('Edit_mov_imdbURL').value = array[12].toString();

            AddDropHandle();
        },
        cache: false
    });
}

var EditLg = { "updated": false };
var EditSm = { "updated": false };
function AddDropHandle() {

    addDropProperties($("#dragandrophandler1"), $('#status1'), $('#Edit_mov_lgPoster'), EditLg);
    addDropProperties($("#dragandrophandler2"), $('#status2'), $('#Edit_mov_smPoster'), EditSm);

    $(document).on('dragenter', function (e) {
        e.stopPropagation();
        e.preventDefault();
    });
    $(document).on('dragover', function (e) {
        e.stopPropagation();
        e.preventDefault();
        obj.css('border', '2px dotted #0B85A1');
    });
    $(document).on('drop', function (e) {
        e.stopPropagation();
        e.preventDefault();
    });
}

var InsertLg = { "updated": false };
var InsertSm = { "updated": false };
function addEntryInit() {
    $('#AddEntryTemplate').show();

    addDropProperties($("#dragandrophandlerAdd1"), $('#statusAdd1'), $('#Add_mov_lgPoster'), InsertLg);
    addDropProperties($("#dragandrophandlerAdd2"), $('#statusAdd2'), $('#Add_mov_smPoster'), InsertSm);

    $('#Add_mov_id').change(function () {
        var indexes = $('#hf_usedindexes').val().split('|');
        var txt = this.value;
        console.log(indexes);
        console.log(txt);
        var pattern = /[t][t][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/;
        console.log(pattern.exec(txt));

        if (pattern.exec(txt) != null && $.inArray(txt, indexes) < 0) {
            $('#Add_mov_id').attr('style', 'color: #00ff00;');
        }
        else
            $('#Add_mov_id').attr('style', 'color: #ff0000;');
    });
}

function addDropProperties(obj, stat, img, updated)
{
    obj.on('dragenter', function (e) {
        e.stopPropagation();
        e.preventDefault();
        $(this).css('border', '2px solid #fff');
    });

    obj.on('dragover', function (e) {
        e.stopPropagation();
        e.preventDefault();
    });

    obj.on('drop', function (e) {
        $(this).css('border', '2px dotted #0B85A1');
        e.preventDefault();
        var files = e.originalEvent.dataTransfer.files;

        if (files[0].type == "image/jpeg") {
            updated.updated = true;
            handleFileUpload(files, stat, img);
        }
    });
}

function commitUpdate() {
    // var path = '<%= ServerRootPath %>';
    console.log("creating object");
    var objectData =
    {
        'mov_id':    document.getElementById('Edit_mov_id').innerHTML,
        'mov_title': document.getElementById('Edit_mov_title').value,
        'mov_plot':  document.getElementById('Edit_mov_plot').value,
        'mov_genre': document.getElementById('Edit_mov_genre').value,
        'mov_size':  document.getElementById('Edit_mov_size').value,
        'mov_fileType': $('#Edit_mov_filetype').val(),
        'mov_dateAdded':document.getElementById('Edit_mov_dateAdded').value,
        'mov_rating':   document.getElementById('Edit_mov_rating').value,
        'mov_runTime':  document.getElementById('Edit_mov_runtime').value,
        'mov_lgPoster': $('#Edit_mov_lgPoster').attr("src"),
        'mov_smPoster': $('#Edit_mov_smPoster').attr("src"),
        'mov_trailer':  document.getElementById('Edit_mov_trailer').value,
        'mov_imdbUrl': document.getElementById('Edit_mov_imdbURL').value,
        'updatedLg': EditLg.updated,
        'updatedSm': EditSm.updated
    };
    console.log(objectData);
    $.ajax({
        type: "POST",
        url: "Admin/EditEntries.aspx/commitUpdateDB",
    data: JSON.stringify(objectData),
    contentType: "application/json; charset=utf-8",
    dataType: "json",
    async: true,
    success: function (msg) {

        var ret = msg.d.split('|');
        var mov_id = ret[0];
        var lgPost = ret[1];
        var smPost = ret[2];

        console.log(ret);
        var divHTML = document.getElementById('Acc' + mov_id).innerHTML;

        document.getElementById('Acc' + mov_id).innerHTML
            = document.getElementById('EditTemplate').innerHTML;

        document.getElementById('EditTemplate').innerHTML = divHTML;

        document.getElementById(mov_id + 'bt').value = objectData.mov_title;
        document.getElementById(mov_id + 'bp').value = objectData.mov_plot;
        document.getElementById(mov_id + 'bg').value = objectData.mov_genre;
        document.getElementById(mov_id + 'bs').value = objectData.mov_size;
        document.getElementById(mov_id + 'bf').value = objectData.mov_fileType;
        document.getElementById(mov_id + 'bd').value = objectData.mov_dateAdded;
        document.getElementById(mov_id + 'br').value = objectData.mov_rating;
        document.getElementById(mov_id + 'bm').value = objectData.mov_runTime;
        if (EditLg)
            $('#' + mov_id + 'iL').attr("src", lgPost);
        else
            $('#' + mov_id + 'iL').attr("src", $('#Edit_mov_lgPoster').attr("src"));
        if (EditSm)
            $('#' + mov_id + 'iS').attr("src", smPost);
        else
            $('#' + mov_id + 'iS').attr("src", $('#Edit_mov_smPoster').attr("src"));

        document.getElementById(mov_id + 'be').value = objectData.mov_trailer;
        document.getElementById(mov_id + 'bi').value = objectData.mov_imdbUrl;

        EditLg = EditSm = false;
    },
    cache: false
});
}

function cancelUpdate()
{
    var mov_id = document.getElementById('Edit_mov_id').innerHTML;
    var divHTML = document.getElementById('Acc' + mov_id);

    document.getElementById('Acc' + mov_id).innerHTML
        = document.getElementById('EditTemplate').innerHTML;

    document.getElementById('EditTemplate').innerHTML = divHTML;
}

function sendFileToServer(formData, status, img) {
    var data;
    var uploadURL = "/Admin/AjaxPosterHandler.ashx"; //Upload URL
    var extraData = {}; //Extra Data.
    var jqXHR = $.ajax({
        xhr: function () {
            var xhrobj = $.ajaxSettings.xhr();
            if (xhrobj.upload) {
                xhrobj.upload.addEventListener('progress', function (event) {
                    var percent = 0;
                    var position = event.loaded || event.position;
                    var total = event.total;
                    if (event.lengthComputable) {
                        percent = Math.ceil(position / total * 100);
                    }
                    //Set progress
                    status.setProgress(percent);
                }, false);
            }
            return xhrobj;
        },
        url: uploadURL,
        type: "POST",
        contentType: false,
        processData: false,
        cache: false,
        data: formData,
        success: function (data) {
            status.setProgress(100);
            console.log(data);
            img.attr('src', data);
        }
    });
}

function createStatusbar(obj) {
    this.statusbar = $("<div class='statusbar'></div>");
    this.size = $("<div class='filesize'></div>").appendTo(this.statusbar);
    this.progressBar = $("<div class='progressBar'><div></div></div>").appendTo(this.statusbar);
    obj.html = this.statusbar;

    this.setFileNameSize = function (name, size) {
        var sizeStr = "";
        var sizeKB = size / 1024;
        if (parseInt(sizeKB) > 1024) {
            var sizeMB = sizeKB / 1024;
            sizeStr = sizeMB.toFixed(2) + " MB";
        }
        else {
            sizeStr = sizeKB.toFixed(2) + " KB";
        }

        this.size.html(sizeStr);
    }
    this.setProgress = function (progress) {
        var progressBarWidth = progress * this.progressBar.width() / 100;
        this.progressBar.find('div').animate({ width: progressBarWidth }, 10).html(progress + "% ");
        if (progress == 100)
            obj.hide();
    }
}

function handleFileUpload(files, obj, img) {
    var fd = new FormData();
    fd.append('file', files[0]);
    obj.show();
    var status = new createStatusbar(obj); //Using this we can set progress.
    status.setFileNameSize(files[0].name, files[0].size);

    sendFileToServer(fd, status, img);
}