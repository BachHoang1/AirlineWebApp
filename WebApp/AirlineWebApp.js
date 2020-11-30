var userKey = ["Name", "PhoneNumber", "Email", "CardNumber"];
var searchKey = ["searchDepartingCity", "searchArrivalCity", "searchStartDate", "SearchendDate", "SearchnumberOfPeople", "fareCondition"];
let tableKey = ['Departing City', 'Arrival City', 'Flight Duration', 'Connecting Flights', 'Fare Condition', 'Price'];

function getInfo()
{  
    form = document.getElementById("UserInfo");
    form.addEventListener("submit", function(e){
        e.preventDefault();
        userInfo = [];
        document.querySelector('.bg-modal').style.display = "flex";
        for( var i = 0; i < form.elements.length-1; i++)
            userInfo.push(form.elements[i].value);
        
        var selectedFlight = JSON.parse(sessionStorage.getItem("selectedFlight"));
        var columnNames = JSON.parse(sessionStorage.getItem("columnNames"));
        var flightText = "Flight Information<br><br>";
        for(var i = 0; i < columnNames.length; i++)
            flightText += columnNames[i] + ": " + selectedFlight[i] + "<br>";
        
        flightText += "fare Condition: " + sessionStorage.getItem("fareCondition") + "<br>";
        var UserText = "User information<br><br>";
        for(var i = 0; i < userKey.length; i++)
        {
            UserText += userKey[i] + ": " + UserInfo[i].value + "<br>";
        }
        console.log(userInfo);
        //sessionStorage.setItem("userInfo", JSON.stringify(userInfo));
        for(var i = 0; i < userKey.length; i++)
        {
            sessionStorage.setItem(userKey[i], userInfo[i]);
        }

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
        console.log(JSON.parse(sessionStorage.getItem("UserInfo")));
        window.location.href = 'http://localhost:8000/bookedFlight';
    });
}

function searchFlights()
{
    searchInfo = [];
    form = document.getElementById("search");
    form.addEventListener('submit', function(e){
        e.preventDefault();

        for( var i = 0; i < form.elements.length-1; i++)
            searchInfo.push(form.elements[i].value);
        console.log(searchInfo);
        //sessionStorage.setItem("searchInfo", JSON.stringify(searchInfo));
        for(var i = 0; i < searchKey.length; i++)
        {
            sessionStorage.setItem(searchKey[i], searchInfo[i]);
        }

        window.location.href = 'http://localhost:8000/flightData';
    });
}

async function displayResults()
{
    var selectedRow = [];
    var columnNames = [];
    var searchInfo = [];
    //var searchInfo = JSON.parse(sessionStorage.getItem("searchInfo"));
    for(var i = 0; i < searchKey.length; i++)
    {
        searchInfo.push(sessionStorage.getItem(searchKey[i]));
    }

    //=============================Direct Flight Table==========================

    const body = searchInfo;
    const response = await fetch("http://localhost:8000/searchDirectResults", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body)
    });
    const jsonData = await response.json();
    console.log(jsonData);

    for(var key in jsonData[0])
    {
        var name = key.replace(/_/g,' ');
        columnNames.push(name);
    }

    let flights = jsonData;
    let myTable = document.getElementById('table');
    let table = document.createElement('table');
    let headerRow = document.createElement('tr');
    columnNames.forEach(headerText => {
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
        
        for(var i = 0; i < table2.rows.length; i++)
            table2.rows[i].classList.remove('selected');

        row.classList.add('selected');
        selectedRow = [];
        for(var i = 0; i < row.cells.length; i++)
            selectedRow.push(row.cells[i].innerText);
        });
    });    
    myTable.appendChild(table);

    //=============================Indirect Flight Table==========================

    const response2 = await fetch("http://localhost:8000/searchIndirectResults", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body)
    });
    const jsonData2 = await response2.json();
    console.log(jsonData2);

    columnNames = [];
    for(var key in jsonData2[0])
    {
        var name = key.replace(/_/g,' ');
        columnNames.push(name);
    }

    let flights2 = jsonData2;
    let myTable2 = document.getElementById('table2');
    let table2 = document.createElement('table');
    let headerRow2 = document.createElement('tr');
    columnNames.forEach(headerText2 => {
        let header2 = document.createElement('th');
        let textNode2 = document.createTextNode(headerText2);
        header2.appendChild(textNode2);
        headerRow2.appendChild(header2);
        });
 
    table2.appendChild(headerRow2);
    
    flights2.forEach(emp => {
        let row = document.createElement('tr');
        Object.values(emp).forEach(text => {
        let cell = document.createElement('td');
        let textNode = document.createTextNode(text);
        cell.appendChild(textNode);
        row.appendChild(cell);
        })
        table2.appendChild(row);

        row.addEventListener('click', function(){
            for(var i = 0; i < table.rows.length; i++)
            table.rows[i].classList.remove('selected');
        
            for(var i = 0; i < table2.rows.length; i++)
                table2.rows[i].classList.remove('selected');

            row.classList.add('selected');
            selectedRow = [];
            for(var i = 0; i < row.cells.length; i++)
            selectedRow.push(row.cells[i].innerText);
        });
    });    
    myTable2.appendChild(table2);

    //=============================Confirm Button==========================
    form = document.getElementById("confirmFlight");
    form.addEventListener('click', function(e){
        e.preventDefault();
        sessionStorage.setItem("selectedFlight", JSON.stringify(selectedRow));
        sessionStorage.setItem("columnNames", JSON.stringify(columnNames));
        window.location.href = 'http://localhost:8000/UserInfo';
    });
}

async function displayFlight()
{
    const body = [];
    var UserInfo = [];
    var selectedFlight = JSON.parse(sessionStorage.getItem("selectedFlight"));
    //var UserInfo = JSON.parse(sessionStorage.getItem("UserInfo"));
    for(var i = 0; i < userKey.length; i++)
    {
        UserInfo.push(sessionStorage.getItem(userKey[i]));
    }
    
    for( var i = 0; i < selectedFlight.length; i++)
        body.push(selectedFlight[i]);

    body.push(sessionStorage.getItem("fareCondition"));

    for( var i = 0; i < UserInfo.length; i++)
        body.push(UserInfo[i]);

    const response = await fetch("http://localhost:8000/UserFlight", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
    });
    const jsonData = await response.json();
    console.log(jsonData);

    if(typeof(jsonData) == "object")
    {
        document.getElementById("output").innerHTML = "Booking was successful! Below is the boarding information";
        var div = document.getElementById("flight");
        for(var i = 0; i < jsonData.length; i++)
        {
            table = document.createElement('table');
            let headerRow = document.createElement('th');
            let textNode = document.createTextNode("Ticket #" + (i + 1));
            headerRow.appendChild(textNode);
            table.appendChild(headerRow);
            for( const [key, value] of Object.entries(jsonData[i]))
            {
                let row = document.createElement('tr');
                let cell1 = document.createElement('td');
                let cell2 = document.createElement('td');
                let textNode1 = document.createTextNode(key);
                let textNode2 = document.createTextNode(value);
                cell1.appendChild(textNode1);
                cell2.appendChild(textNode2);
                row.appendChild(cell1);
                row.appendChild(cell2);
                table.appendChild(row);
            }
            div.appendChild(table);
        }
    }
    else
        document.getElementById("output").innerHTML = "Booking was not successful";

    button = document.getElementById("Home");
    button.addEventListener('click', function(e){
        e.preventDefault();
        window.location.href = 'http://localhost:8000/AirlineWebApp';
    });
}

function checkFlight()
{
    var ticketNumber;
    form = document.getElementById("checkFlight");
    form.addEventListener('submit', function(e){
        e.preventDefault();

        ticketNumber = form.elements[0].value;
        console.log(ticketNumber);
        sessionStorage.setItem("ticketNumber", ticketNumber);

        window.location.href = 'http://localhost:8000/showTicket';
    });
}

async function displayTicket()
{
    const body =[];
    body.push(sessionStorage.getItem("ticketNumber"));

    const response = await fetch("http://localhost:8000/Ticket", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
    });
    const jsonData = await response.json();
    console.log(jsonData);

    document.getElementById("output").innerHTML = "Your ticket information";
    var div = document.getElementById("flight");
    table = document.createElement('table');
    let headerRow = document.createElement('th');
    let textNode = document.createTextNode("Ticket");
    headerRow.appendChild(textNode);
    table.appendChild(headerRow);
    for( const [key, value] of Object.entries(jsonData))
    {
        let row = document.createElement('tr');
        let cell1 = document.createElement('td');
        let cell2 = document.createElement('td');
        let textNode1 = document.createTextNode(key);
        let textNode2 = document.createTextNode(value);
        cell1.appendChild(textNode1);
        cell2.appendChild(textNode2);
        row.appendChild(cell1);
        row.appendChild(cell2);
        table.appendChild(row);
    }
    div.appendChild(table);

    button = document.getElementById("Home");
    button.addEventListener('click', function(e){
        e.preventDefault();
        window.location.href = 'http://localhost:8000/AirlineWebApp';
    });
}