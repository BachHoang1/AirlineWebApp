const express = require("express");
const cors = require('cors');
const fs = require('fs');
const {Pool} = require('pg');
const { json } = require("express");

const server = express();
const port = 8000;
const host = "localhost";

server.use(cors());
server.use(express.json());
server.use(express.static(__dirname));

var path = "C:/Users/beast/OneDrive/Documents/Javascript/password.txt"
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

server.get('/AirlineWebApp', function(req, res) {
    res.sendFile(__dirname + '/AirlineWebApp.html');
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

server.get('/showTicket', function(req, res) {
    res.sendFile(__dirname + '/showTicket.html');
});

server.post('/searchDirectResults', async(req, res)=>{
    try{
        //query database for flights based on search fields
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
  });

  server.post('/searchIndirectResults', async(req, res)=>{
    try{
        //query database for flights based on search fields
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
        res.json(JSON.stringify(err.message));
    }
  });

  server.post('/Ticket', async(req, res)=>{
    try{
        //start booking transaction
        //then if successful, return boarding info
        const body = req.body;
        console.log(body);
        const client = await pool.connect();
        const result = await client.query("select * from bookings.aircraft;");
        client.end();
        res.json(result.rows[0]);
    } 
    catch(err){
        res.json(JSON.stringify(err.message));
    }
  });
