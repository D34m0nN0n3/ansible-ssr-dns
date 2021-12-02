function addRow() {
          
    var NAME = document.getElementById("name");
    var DOMAIN = document.getElementById("domain");
    var IP = document.getElementById("ip");
 
    let reversip = IP.value;
    let ptrip = reversip.split(".").reverse();

    var PTR = ptrip.join(".");
 
    var rowCount = table.rows.length;
    var row = table.insertRow(rowCount);
 
    row.insertCell(0).innerHTML= NAME.value + '.' + DOMAIN.value + '.' + '&nbsp;&nbsp;&nbsp;&nbsp;IN&nbsp;&nbsp;A&nbsp;&nbsp;&nbsp;&nbsp;' + IP.value;
    row.insertCell(1).innerHTML= PTR + '.in-addr.arpa.&nbsp;&nbsp;&nbsp;&nbsp;IN&nbsp;&nbsp;PTR&nbsp;&nbsp;&nbsp;&nbsp;' + NAME.value + '.' + DOMAIN.value + '.';
    row.insertCell(3).innerHTML= '<input type="button" value = "Удалить" onClick="Javacsript:deleteRow(this)">';

}
 
function deleteRow(obj) {
      
    var index = obj.parentNode.parentNode.rowIndex;
    var table = document.getElementById("myTableData");
    table.deleteRow(index);
    
}
 
function load() {
    
    console.log("Page load finished");
 
}
