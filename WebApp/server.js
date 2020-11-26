const express = require("express");
const cors = require('cors');
const fs = require('fs');
const {Client} = require('pg');

const server = express();
const port = 8000;
const host = "localhost";

server.use(cors());
server.use(express.json());
server.use(express.static(__dirname));

var path = "C:/Users/beast/OneDrive/Documents/Javascript/password.txt"
var data = fs.readFileSync(path, "utf8").split(",");

const client = new Client({
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

server.post('/searchResults', async(req, res)=>{
    try{
  
        const body = req.body;
        console.log(body);
        await client.connect()
        const result = await client.query("select * from bookings.aircraft;");
        client.end();
        res.json(result.rows);
    } 
    catch(err){
        console.log(err.message);
    }
  });
