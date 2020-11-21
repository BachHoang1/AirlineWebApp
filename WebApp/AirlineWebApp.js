var userKey = ["UserName", "UserPhoneNum", "UserEmail", "UserCardNum"];
var searchKey = ["searchDepartingCity", "searchArrivalCity", "searchStartDate", "SearchendDate", "SearchnumberOfPeople"];
let tableKey = ['Departing City', 'Arrival City', 'Flight Duration', 'Connecting Flights', 'Fare Condition', 'Price'];

function getInfo()
{
  form = document.getElementById("UserInfo");
  form.addEventListener("submit", function(e){
    e.preventDefault();
    for( var i = 0; i < form.elements.length-1; i++)
    {
      sessionStorage.setItem(userKey[i], form.elements[i].value);
    }
    //console.log(sessionStorage.getItem("Departing City"));
    //window.location.href = 'AirlineWebApp.html';
  });
}

function searchFlights()
{
  form = document.getElementById("search");
  form.addEventListener("submit", function(e){
    e.preventDefault();
    for( var i = 0; i < form.elements.length-1; i++)
    {
      sessionStorage.setItem(searchKey[i], form.elements[i].value);
    }
    window.location.href = 'flightData.html';
  });
}

function displayResults()
{
  var selectedRow = [];
  let flights = [{ Departing_City: 'Houston', Arrival_City:'Tokyo', Flight_duration:'15 hours', Connecting_Flights: '0', Fare_Condition: 'Economy', Price: '$200'},
                 { Departing_City: 'Houston', Arrival_City:'Tokyo', Flight_duration:'15 hours', Connecting_Flights: '0', Fare_Condition: 'Economy', Price: '$200'}];
  let myTable = document.getElementById('table');
  let table = document.createElement('table');
  let headerRow = document.createElement('tr');
  tableKey.forEach(headerText => {
    let header = document.createElement('th');
    let textNode = document.createTextNode(headerText);
    header.appendChild(textNode);
    headerRow.appendChild(header);
    });
 
  table.appendChild(headerRow);
 
  flights.forEach(emp => {
    let row = document.createElement('tr');
    Object.values(emp).forEach(text => {
      let cell = document.createElement('td');
      let textNode = document.createTextNode(text);
      cell.appendChild(textNode);
      row.appendChild(cell);
      })
    table.appendChild(row);

    row.addEventListener('click', function(){
      for(var i = 0; i < table.rows.length; i++)
        table.rows[i].classList.remove('selected');
      row.classList.add('selected');
      selectedRow = [];
      for(var i = 0; i < row.cells.length; i++)
        selectedRow.push(row.cells[i].innerText);
    });
  });
 
  myTable.appendChild(table);
  form = document.getElementById("confirmFlight");
  form.addEventListener('click', function(e){
    e.preventDefault();
    for( var i = 0; i < selectedRow.length; i++)
    {
      sessionStorage.setItem(tableKey[i], selectedRow[i]);
    }
    window.location.href = 'NewUser.html';
  });
}
