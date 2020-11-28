const express = require("express");
const cors = require('cors');
const fs = require('fs');
const {Pool} = require('pg');

const server = express();
const port = 8000;
const host = "localhost";

server.use(cors());
server.use(express.json());
server.use(express.static(__dirname));

var searchKey = ["searchDepartingCity", "searchArrivalCity", "searchStartDate", "SearchendDate", "SearchnumberOfPeople"];
var path = "C:/Users/Bakh/Documents/password.txt"
var data = fs.readFileSync(path, "utf8").split(",");

const pool = new Pool({
    user: data[0],
    password: data[1],
    host: "code.cs.uh.edu",
    database: "COSC3380"
})

server.listen(port, host, () => {
    console.log(`Server is running on http://${host}:${port}`);
});

server.get('/AirlineWebA,pp', function(req, res) {
    res.sendFile(__dirname + '/AirlineWebA,pp.html');
});

server.get('/flightData', function(req, res) {
    res.sendFile(__dirname + '/flightData.html');
});

server.get('/UserInfo', function(req, res) {
    res.sendFile(__dirname + '/NewUser.html');
});

server.get('/bookedFlight', function(req, res) {
    res.sendFile(__dirname + '/confirmedFlight.html');
});

function getInfo()
{       form = document.getElementById("UserInfo");
        form.addEventListener("submit", function(e){
        var flightText = "Flight Information<br><br>";
        for(var i = 0; i < tableKey.length; i++)
            flightText += tableKey[i] + ": " + sessionStorage.getItem(tableKey[i]) + "<br>";
        
        var text = "<br><br>Is this information correct? By clicking submit, your flight will be booked<br>";
        document.getElementById("FlightData").innerHTML = flightText;
    });

    button = document.getElementById("Cancel");
    button.addEventListener('click', function(e){
        e.preventDefault();
        document.querySelector('.bg-modal').style.display = "none";
    });

    button = document.getElementById("confirmFlight");
    button.addEventListener('click', function(e){
        e.preventDefault();
        window.location.href = 'http://localhost:8000/bookedFlight';
    });
}

function searchFlights()
{
    form = document.getElementById("search");
    form.addEventListener('submit', function(e){
        e.preventDefault();
        for( var i = 0; i < form.elements.length-1; i++)
        {
        sessionStorage.setItem(searchKey[i], form.elements[i].value);
        //console.log(sessionStorage.getItem(searchKey[i]));
        }
        window.location.href = 'http://localhost:8000/flightData';
    });
}

server.post('/searchResults', async(req, res)=>{
    try{
        //query database for flights based on search fields
        const body = req.body;
        console.log(body);
        console.log(sessionStorage.getItem(searchKey[i]));
        const client = await pool.connect();
        const result = await client.query(`SELECT * FROM flights WHERE flights.departure_airport LIKE '$1' and flights.departure_airport LIKE '$1' and flights.arrival_airport LIKE '$2' and timestamp '$3' < flights.scheduled_departure and flights.scheduled_departure < timestamp '$4';`);
        client.end();
        res.json(result.rows);
    } 
    catch(err){
        console.log(err.message);
    }
  });

  server.post('/UserFlight', async(req, res)=>{
    try{
        //start booking transaction
        //then if successful, return boarding info
        const body = req.body;
        console.log(body);
        const client = await pool.connect();
        const result = await client.query("select * from bookings.aircraft;");
        client.end();
        res.json(result.rows);
    } 
    catch(err){
        console.log(err.message);
    }
      // for airline 
      server.post('/booking', async(req, res)=>{
        try{
          let a = 3;
          const b = ++a;
      
          console.log(`a:${a}, b:${b}`);
          // expected output: "a:4, b:4"    
          const {description} = req.body;
          const newTodo = await pool.query(`INSERT INTO booking VALUES($1,CURRENT_TIMESTAMP, $2 )`,
            [description]);
      
          res.json(newTodo);              
      
        } catch(err){
          console.log(err.message);
        }
      });
      
      // for airline 
      server.post('/payment', async(req, res)=>{
        try{
          let a = 3;
          const b = ++a;
      
          console.log(`a:${a}, b:${b}`);
          // expected output: "a:4, b:4"    
          const {description} = req.body;
          const newTodo = await pool.query(`INSERT INTO payment VALUES($1,$2,$3,$4)`,
            [description]);
      
          res.json(newTodo);              
      
        } catch(err){
          console.log(err.message);
        }
      });
      
      server.post('/reservation', async(req, res)=>{
        try{
          let a = 3;
          const b = ++a;
      
          console.log(`a:${a}, b:${b}`);
          // expected output: "a:4, b:4"    
          const {description} = req.body;
          const newTodo = await pool.query(`INSERT INTO reservation VALUES($1,$2)`,
            [description]);
      
          res.json(newTodo);              
      
        } catch(err){
          console.log(err.message);
        }
      });
      
      server.post('/ticket', async(req, res)=>{
        try{
          let a = 3;
          const b = ++a;
      
          console.log(`a:${a}, b:${b}`);
          // expected output: "a:4, b:4"    
          const {description} = req.body;
          const newTodo = await pool.query(`INSERT INTO ticket VALUES($1,$2,$3,$4,$5,$6,$7)`,
            [description]);
      
          res.json(newTodo);              
      
        } catch(err){
          console.log(err.message);
        }
      });
      
      server.post('/payment', async(req, res)=>{
        try{
          let a = 3;
          const b = ++a;
      
          console.log(`a:${a}, b:${b}`);
          // expected output: "a:4, b:4"    
          const {description} = req.body;
          const newTodo = await pool.query(`INSERT INTO payment VALUES($1,$2,$3,$4)`,
            [description]);
      
          res.json(newTodo);              
      
        } catch(err){
          console.log(err.message);
        }
      });

      server.post('/client_flight', async(req, res)=>{
        try{
          let a = 3;
          const b = ++a;
      
          console.log(`a:${a}, b:${b}`);
          // expected output: "a:4, b:4"    
          const {description} = req.body;
          const newTodo = await pool.query(`INSERT INTO client_flight VALUES($1,$2)`,
            [description]);
      
          res.json(newTodo);              
      
        } catch(err){
          console.log(err.message);
        }
      });

      server.post('/ticket_boarding', async(req, res)=>{
        try{
          let a = 3;
          const b = ++a;
      
          console.log(`a:${a}, b:${b}`);
          // expected output: "a:4, b:4"    
          const {description} = req.body;
          const newTodo = await pool.query(`INSERT INTO ticket_boarding VALUES($1,$2)`,
            [description]);
      
          res.json(newTodo);              
      
        } catch(err){
          console.log(err.message);
        }
      });
      
      server.post('/ticket_flights', async(req, res)=>{
        try{
          let a = 3;
          const b = ++a;
      
          console.log(`a:${a}, b:${b}`);
          // expected output: "a:4, b:4"    
          const {description} = req.body;
          const newTodo = await pool.query(`INSERT INTO ticket_flights VALUES($1,$2,$3,$4)`,
            [description]);
      
          res.json(newTodo);              
      
        } catch(err){
          console.log(err.message);
        }
      });

      //update a todo by id
      server.put("/todos/:id", async (req, res) => {
        try {
          const { id } = req.params;
          const { description } = req.body;
          const updateTodo = await pool.query(`UPDATE boarding SET boarding = $1 
                                               WHERE boarding_time = $2`,
            [description, id]);
          res.json("Todo was updated!");
        } catch (err) {
          console.error(err.message);
        }
      });
  });
