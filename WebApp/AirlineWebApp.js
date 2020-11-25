var userKey = ["UserName", "UserPhoneNum", "UserEmail", "UserCardNum"];
var searchKey = ["searchDepartingCity", "searchArrivalCity", "searchStartDate", "SearchendDate", "SearchnumberOfPeople"];
let tableKey = ['Departing City', 'Arrival City', 'Flight Duration', 'Connecting Flights', 'Fare Condition', 'Price'];

function getInfo()
{  
    form = document.getElementById("UserInfo");
    form.addEventListener("submit", function(e){
        e.preventDefault();
        document.querySelector('.bg-modal').style.display = "flex";
        for( var i = 0; i < form.elements.length-1; i++)
            sessionStorage.setItem(userKey[i], form.elements[i].value);

        var flightText = "Flight Information<br><br>";
        for(var i = 0; i < tableKey.length; i++)
            flightText += tableKey[i] + ": " + sessionStorage.getItem(tableKey[i]) + "<br>";
            
        var UserText = "User information<br><br>";
        for(var i = 0; i < userKey.length; i++)
            UserText += userKey[i] + ": " + sessionStorage.getItem(userKey[i]) + "<br>";

        var text = "<br><br>Is this information correct? By clicking submit, your flight will be booked<br>";
        document.getElementById("FlightData").innerHTML = flightText;
        document.getElementById("UserData").innerHTML = UserText;
        document.getElementById("output").innerHTML = text;
    });

    button = document.getElementById("Cancel");
    button.addEventListener('click', function(e){
        e.preventDefault();
        document.querySelector('.bg-modal').style.display = "none";
    });

    button = document.getElementById("confirmFlight");
    button.addEventListener('click', function(e){
        e.preventDefault();
        //window.location.href = 'NewUser.html';
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
        //window.location.href = 'flightData.html';
        fs.readFile('airlineWebApp.html', function(err, data) {
            res.writeHead(200, {'Content-Type': 'text/html'});
            res.write(data);
            return res.end();
        });
    });
}

function displayResults()
{
    var selectedRow = [];
    let flights = [{ Departing_City: 'Houston',
                    Arrival_City:'Tokyo', 
                    Flight_duration:'15 hours', 
                    Connecting_Flights: '0', 
                    Fare_Condition: 'Economy', 
                    Price: '$200'},

                    { Departing_City: 'Houston', 
                    Arrival_City:'Tokyo', 
                    Flight_duration:'15 hours', 
                    Connecting_Flights: '0', 
                    Fare_Condition: 'Economy', 
                    Price: '$200'}];
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
