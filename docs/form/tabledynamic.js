function addRow() {
          
    var NAME = document.getElementById("name");
    var DOMAIN = document.getElementById("domain");
    var RESOURCERECORD = document.getElementById("rr");
    var table = document.getElementById("myTableData");
 
    let reversip = RESOURCERECORD.value;
    let ptrip = reversip.split(".").reverse();

    var PTR = ptrip.join(".");
 
    var rowCount = table.rows.length;
    var row = table.insertRow(rowCount);
 
    row.insertCell(0).innerHTML= NAME.value + '.' + DOMAIN.value + '.' + '&nbsp;&nbsp;&nbsp;&nbsp;IN&nbsp;&nbsp;A&nbsp;&nbsp;&nbsp;&nbsp;' + RESOURCERECORD.value;
    row.insertCell(1).innerHTML= PTR + '.in-addr.arpa.&nbsp;&nbsp;&nbsp;&nbsp;IN&nbsp;&nbsp;PTR&nbsp;&nbsp;&nbsp;&nbsp;' + NAME.value + '.' + DOMAIN.value + '.';
    row.insertCell(2).innerHTML= '<input type="button" value = "Удалить" onClick="Javacsript:deleteRow(this)">';
    
}
 
function deleteRow(obj) {
      
    var index = obj.parentNode.parentNode.rowIndex;
    var table = document.getElementById("myTableData");
    table.deleteRow(index);
    
}
 
function load() {
    
    console.log("Page load finished");
 
}

function downloadCSV(csv, filename) {
    var csvFile;
    var downloadLink;

    csvFile = new Blob([csv], {type: "text/csv"});
    downloadLink = document.createElement("a");
    downloadLink.download = filename;
    downloadLink.href = window.URL.createObjectURL(csvFile);
    downloadLink.style.display = "none";
    document.body.appendChild(downloadLink);
    downloadLink.click();
}

function exportTableToCSV(filename) {
    var csv = [];
    var rows = document.querySelectorAll("table tr");
    
    for (var i = 0; i < rows.length; i++) {
        var row = [], cols = rows[i].querySelectorAll("td, th");
        for (var j = 0; j < cols.length; j++) 
            row.push(cols[j].innerText);
        csv.push(row.join(","));
    }

    // Download CSV file
    downloadCSV(csv.join("\n"), filename);
}
