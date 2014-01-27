
(function () {
    // output information
    function Output(msg) {
        var m = document.getElementById("messages");
        m.innerHTML = m.innerHTML + msg;
    }

    // file drag hover
    function FileDragHover(e) {
        e.stopPropagation();
        e.preventDefault();
        e.target.className = (e.type == "dragover" ? "hover" : "");
    }

    // file selection
    function FileSelectHandler(e) {

        // cancel event and hover styling
        FileDragHover(e);

        // fetch FileList object
        var files = e.target.files || e.dataTransfer.files;

        // process all File objects
        var cookieString = "";
        var index = 0;
        for (var i = 0, f; f = files[i]; i++) {
            ParseFile(f);
            cookieString = cookieString + (f.name + "~" + f.type + "~" + f.size + "|");
        }
        document.getElementById("HiddenList").value = cookieString;
    }


    // output file information
    function ParseFile(file) {

        Output(
			"<p>File information: <strong>" + file.name +
			"</strong> type: <strong>" + file.type +
			"</strong> size: <strong>" + file.size +
			"</strong> bytes</p>"
		);
    }

    // initialize
    function Init() {

        var filedrag = document.getElementById("filedrag");

        // is XHR2 available?
        var xhr = new XMLHttpRequest();
        if (xhr.upload) {

            // file drop
            filedrag.addEventListener("dragover", FileDragHover, false);
            filedrag.addEventListener("dragleave", FileDragHover, false);
            filedrag.addEventListener("drop", FileSelectHandler, false);
            filedrag.style.display = "block";
        }

    }

    // call initialization file
    if (window.File && window.FileList && window.FileReader) {
        Init();
    }
})();