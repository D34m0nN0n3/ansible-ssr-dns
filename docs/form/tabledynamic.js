function addRow() {
          
    var NAME = document.getElementById("name");
    var DOMAIN = document.getElementById("domain");
    var TYPE = document.getElementById("type");
    var RESOURCERECORD = document.getElementById("rr");
    var table = document.getElementById("myTableData");
 
    let reversip = RESOURCERECORD.value;
    let ptrip = reversip.split(".").reverse();

    var PTR = ptrip.join(".");
 
    var rowCount = table.rows.length;
    var row = table.insertRow(rowCount);
 
    if (TYPE.value === 'A') {
       row.insertCell(0).innerHTML= NAME.value + '.' + DOMAIN.value + '.' + '&nbsp;&nbsp;&nbsp;&nbsp;IN&nbsp;&nbsp;A&nbsp;&nbsp;&nbsp;&nbsp;' + RESOURCERECORD.value;
       row.insertCell(1).innerHTML= PTR + '.in-addr.arpa.&nbsp;&nbsp;&nbsp;&nbsp;IN&nbsp;&nbsp;PTR&nbsp;&nbsp;&nbsp;&nbsp;' + NAME.value + '.' + DOMAIN.value + '.';
       row.insertCell(2).innerHTML= '<input type="button" value = "Удалить" onClick="Javacsript:deleteRow(this)">';
    } else {
        row.insertCell(0).innerHTML= NAME.value + '.' + DOMAIN.value + '.' + '&nbsp;&nbsp;&nbsp;&nbsp;IN&nbsp;&nbsp;' + TYPE.value + '&nbsp;&nbsp;&nbsp;&nbsp;' + RESOURCERECORD.value;
        row.insertCell(1).innerHTML= '&nbsp;';
        row.insertCell(2).innerHTML= '<input type="button" value = "Удалить" onClick="Javacsript:deleteRow(this)">';
    }
 
}
 
function deleteRow(obj) {
      
    var index = obj.parentNode.parentNode.rowIndex;
    var table = document.getElementById("myTableData");
    table.deleteRow(index);
    
}
 
function load() {
    
    console.log("Page load finished");
 
}

function download_table_as_csv(table_id, separator = ';') {
    var rows = document.querySelectorAll('table#' + table_id + ' tr');
    var csv = [];
 
    for (var i = 0; i < rows.length; i++) {
        var row = [], cols = rows[i].querySelectorAll('td, th');
        for (var j = 0; j < cols.length; j++) {
            var data = cols[j].innerText.replace(/(\r\n|\n|\r)/gm, '').replace(/(\s\s)/gm, ' ')
            data = data.replace(/"/g, '""');
            row.push(data);
        }
        csv.push(row.join(separator));
    }
 
    var csv_string = csv.join('\n');
    var filename = 'export_' + new Date().toLocaleDateString() + '.csv';
    var link = document.createElement('a');
    link.style.display = 'none';
    link.setAttribute('target', '_blank');
    link.setAttribute('href', 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv_string));
    link.setAttribute('download', filename);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}
