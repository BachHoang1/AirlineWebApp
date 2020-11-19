
var userInfo = []

function getInfo()
{
  form = document.getElementById("UserInfo");
  form.addEventListener("submit", function(e){
    e.preventDefault();
    for( var i = 0; i < form.elements.length-1; i++)
    {
      userInfo.push(form.elements[i].value);
    }
    //document.getElementById("output").innerHTML = userInfo[0];
    window.location.href = 'AirlineWebApp.html';
  });
}

function searchFlights()
{
  form = document.getElementById("search");
  form.addEventListener("submit", function(e){
    e.preventDefault();
    window.location.href = 'flightData.html';
  });
}

function displayResults()
{
  let myTable = document.getElementById('table');
  let flights = [{ Departing_City: 'Houston', Arrival_City:'Tokyo', Flight_duration:'15 hours', Connecting_Flights: '0', Fare_Condition: 'Economy', Price: '$200'}]
  let headers = ['Departing City', 'Arrival City', 'Flight Duration', 'Connecting Flights', 'Fare Condition', 'Price'];
  let table = document.createElement('table');
  let headerRow = document.createElement('tr');
 
  headers.forEach(headerText => {
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
  });
 
  myTable.appendChild(table);
}
