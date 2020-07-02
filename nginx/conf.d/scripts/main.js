var devices = JSON.parse(containers);

var headers = [];
for (var pos = 0; pos < devices.length; pos++) {
    for (var deviceKey in devices[pos]) {
        // Check if key is already added to headers
        if (headers.indexOf(deviceKey) === -1) {
            headers.push(deviceKey);
        }
    }
}

// Create a table
var table = document.createElement("table");

// Insert table header
var tr = table.insertRow(-1); 
for (var pos = 0; pos < headers.length; pos++) {
    var th = document.createElement("th");      // TABLE HEADER.
    var header = headers[pos];
    th.innerHTML = header;
    tr.appendChild(th);
}

// Insert table content
for (var pos = 0; pos < devices.length; pos++) {
    tr = table.insertRow(-1);
    for (var index = 0; index < headers.length; index++) {
        var td = document.createElement("td");
        var content = devices[pos][headers[index]];

        if (index === 1) {
            var link = document.createElement("a");
            link.href = devices[pos][headers[index+1]];
            link.innerHTML = content;
            td.appendChild(link);
        } else if (index === 2) {
            var object = document.createElement("object");
            object.type = "text/html";
            object.data = content;
            object.width = "950px";
            object.height = "950px";
            td.appendChild(object);
        } else {
            td.innerHTML = content;    
        }

        tr.appendChild(td);
    }
}

// Put the table inside div
var divContainer = document.getElementById("showData");
divContainer.innerHTML = "";
divContainer.appendChild(table);
