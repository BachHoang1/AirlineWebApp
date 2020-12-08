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

var ticket_no = 1;
var reservation_no = 2;
var booking_no = 0;
var group_id = 3;
var boarding_id = 4;
var passenger_id = 5;
var query = "";

//var path = "C:/Users/Bakh/Documents/password.txt"
var path = "C:/Users/beast/OneDrive/Documents/Javascript/password.txt";
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

server.get('/query', function(req, res) {
    res.json(query);
});

server.post('/searchDirectResults', async(req, res)=>{
    const body = req.body;
    console.log(body);
    var depart = body [0];
    var arrival = body [1];
    var time1 = body [2];
    var time2 = body [3];
    query = `SELECT *
    FROM flights WHERE flights.departure_airport LIKE '${depart}' 
    And flights.arrival_airport LIKE '${arrival}' 
    And '${time1}' < flights.scheduled_departure 
    And flights.scheduled_departure < '${time2}';`;
    try{
        const client = await pool.connect();
        const result = await client.query(query);
        res.json(result.rows);
        client.end();
    } 
    catch(err){
        res.json(JSON.stringify(err.message));
    }
  });

server.post('/searchIndirectResults', async(req, res)=>{
    const body = req.body;
    console.log(body);
    var depart = body [0];
    var arrival = body [1];
    var time1 = body [2];
    var time2 = body [3];
    var fly_type = body [6];
   // if (fly_type === "One-Way"){
    query = `SELECT
    fl1.flight_id as flight_id_1,
    fl1.scheduled_departure as time_depfl1,
    fl1.scheduled_arrival as time_arrfl1,
    fl1.departure_airport as depfl1,
    fl1.arrival_airport as arrfl1,
    fl1.seats_available as seats_available1,
    fl2.flight_id as flight_id_2,
    fl2.scheduled_departure as time_depfl2,
    fl2.scheduled_arrival as time_arrfl2,
    fl2.departure_airport as depfl2,
    fl2.arrival_airport as arrfl2,
    fl2.seats_available as seats_available2
    FROM flights fl1
    INNER JOIN flights fl2 ON fl1.departure_airport = '${depart}' AND  fl2.arrival_airport = '${arrival}'
    AND '${time1}' < fl1.scheduled_departure 
    AND fl1.scheduled_departure < '${time2}'
    AND fl1.arrival_airport NOT LIKE '${arrival}'
    AND fl2.departure_airport NOT LIKE '${depart}' 
    AND fl1.arrival_airport  = fl2.departure_airport
	AND fl2.scheduled_departure > fl1.scheduled_arrival
    AND DATE_PART('day', fl2.scheduled_departure::timestamp WITH time zone - fl1.scheduled_arrival::timestamp WITH time zone) < 2
    AND fl1.seats_available > 0 AND fl2.seats_available > 0;`;
    try{
        const client = await pool.connect();
        const result = await client.query(query);
        client.end();
        res.json(result.rows);
    } 
    catch(err){
        res.json(JSON.stringify(err.message));
    }
    //}   else{
        
    //}
  });

server.post('/searchRoundTrip', async(req, res)=>{
    const body = req.body;
    console.log(body);
    var depart = body [0];
    var arrival = body [1];
    var time1 = body [2];
    var time2 = body [3];
    query = `SELECT
    fl1.flight_id as flight_id_1,
    fl1.scheduled_departure as time_depfl1,
    fl1.scheduled_arrival as time_arrfl1,
    fl1.departure_airport as depfl1,
    fl1.arrival_airport as arrfl1,
    fl1.seats_available as seats_available1,
    fl2.flight_id as flight_id_2,
    fl2.scheduled_departure as time_depfl2,
    fl2.scheduled_arrival as time_arrfl2,
    fl2.departure_airport as depfl2,
    fl2.arrival_airport as arrfl2,
    fl2.seats_available as seats_available2
    FROM flights fl1
    INNER JOIN flights fl2 ON fl1.departure_airport = '${depart}' AND  fl2.arrival_airport = '${depart}'
    AND '${time1}' < fl1.scheduled_departure 
    AND fl1.scheduled_departure < '${time2}'
    AND fl1.arrival_airport LIKE '${arrival}'
    AND fl1.arrival_airport  = fl2.departure_airport
    AND fl2.scheduled_departure > fl1.scheduled_arrival
    AND DATE_PART('day', fl2.scheduled_departure::timestamp WITH time zone - fl1.scheduled_arrival::timestamp WITH time zone) < 2
    AND fl1.seats_available > 0 AND fl2.seats_available > 0;`;
    try{
        const client = await pool.connect();
        const result = await client.query(query);
        client.end();
        res.json(result.rows);
    } 
    catch(err){
        res.json(JSON.stringify(err.message));
    }
  });

server.post('/UserFlight', async(req, res)=>{
    const body = req.body;
    var text = "";
    query = "";
    const client = await pool.connect();
if (body.length === 17){
    //then it is a direct flight set up
    flight_id=body[0];
    condition=body[11];
    name=body[12];
    phone=body[13];
    email=body[14];
    credit= body[15];
    number_of_ticket = body[16];
    group_id = ++group_id;
    //for loop for ticket 
    for(i = 0; i < number_of_ticket; i++)
    {
        ticket_no = ++ticket_no;
        reservation_no = ++reservation_no;
        booking_no = ++booking_no;
        boarding_id = ++boarding_id;
        passenger_id = ++passenger_id;
        seat_avalible=body[7];
        //seat_booked=body[8];
        if(condition === "Economy"){
            price = 500;
            tax = 90;
            total = price + tax;
        }
        else if(condition === "Comfort"){
            price = 600;
            tax = 100;
            total = price + tax;
        }
        else {
            price = 700;
            tax = 120;
            total = price + tax;
        }   
        if (seat_avalible > 0)
        {
        try{
            text = `BEGIN;
            INSERT INTO bookings VALUES(${booking_no} , CURRENT_TIMESTAMP, ${price} );
            INSERT INTO payment VALUES (${reservation_no}, ${credit} , ${tax}, ${total});
            INSERT INTO ticket VALUES(${ticket_no}, ${booking_no} , ${passenger_id}, '${name}', '${email}', '${phone}', ${group_id});
            INSERT INTO reservation VALUES(${booking_no},${reservation_no});
            INSERT INTO client_flight VALUES(${ticket_no},${flight_id});
            INSERT INTO ticket_flights VALUES(${boarding_id},${flight_id},'${condition}');
            INSERT INTO ticket_boarding VALUES(${boarding_id},${ticket_no});
            UPDATE flights SET seats_available = seats_available - 1, seats_booked = seats_booked + 1 WHERE flights.flight_id = ${flight_id};
            UPDATE boarding SET checked_bag = checked_bag + 1 WHERE boarding.flight_id = ${flight_id};
            COMMIT;`;
            await client.query(text);
            query += "Transaction\n\n" + text + "|";
            }
            catch(err)
            {
                res.json(JSON.stringify(err.message));
            }   
        }
        else{
            try{
                text = `BEGIN;
                INSERT INTO bookings VALUES(${booking_no} , CURRENT_TIMESTAMP, ${price} );
                INSERT INTO payment VALUES (${reservation_no}, ${credit} , ${tax}, ${total});
                INSERT INTO ticket VALUES(${ticket_no}, ${booking_no} , ${passenger_id}, '${name}', '${email}', '${phone}', ${group_id});
                INSERT INTO reservation VALUES(${booking_no},${reservation_no});
                INSERT INTO wait_list VALUES(${ticket_no},${flight_id});
                COMMIT;`;
                await client.query(text);
                query += "Transaction\n\n" + text + "|";
            }
            catch(err)
            {
                res.json(JSON.stringify(err.message));  
            }
        } 
    }
}
else
{
    //then it is a indirect flight set up
    flight_id=body[0];
    flight_id2=body[6];
    condition=body[12];
    name=body[13];
    phone=body[14];
    email=body[15];
    credit= body[16];
    number_of_ticket = body[17];
    group_id = ++group_id;
    //for loop for ticket 
    for(i = 0; i < number_of_ticket; i++)
    {
        ticket_no = ++ticket_no;
        reservation_no = ++reservation_no;
        boarding_id = ++boarding_id;
        passenger_id = ++passenger_id;
        booking_no = ++booking_no;
        seat_avalible=body[7];
        //seat_booked=body[8];
        if(condition === "Economy"){
            price = 500;
            tax = 90;
            total = price + tax;
        }
        else if(condition === "Comfort"){
            price = 600;
            tax = 100;
            total = price + tax;
        }
        else {
            price = 700;
            tax = 120;
            total = price + tax;
        }   
        try{
            text = `BEGIN;
            INSERT INTO bookings VALUES(${booking_no} , CURRENT_TIMESTAMP, 2*${price} );
            INSERT INTO payment VALUES (${reservation_no}, ${credit} , 2*${tax}, 2*${total});
            INSERT INTO ticket VALUES(${ticket_no}, ${booking_no} , ${passenger_id}, '${name}', '${email}', '${phone}', ${group_id});
            INSERT INTO reservation VALUES(${booking_no},${reservation_no});
            INSERT INTO client_flight VALUES(${ticket_no},${flight_id});
            INSERT INTO ticket_flights VALUES(${boarding_id},${flight_id},'${condition}');
            INSERT INTO ticket_boarding VALUES(${boarding_id},${ticket_no});
            UPDATE flights SET seats_available = seats_available - 1, seats_booked = seats_booked + 1 WHERE flights.flight_id = ${flight_id};
            UPDATE boarding SET checked_bag = checked_bag + 1 WHERE boarding.flight_id = ${flight_id};
            UPDATE flights SET seats_available = seats_available - 1, seats_booked = seats_booked + 1 WHERE flights.flight_id = ${flight_id2};
            UPDATE boarding SET checked_bag = checked_bag + 1 WHERE boarding.flight_id = ${flight_id2};`;

            ticket_no = ++ticket_no;
            boarding_id = ++boarding_id;

            text += `INSERT INTO ticket VALUES(${ticket_no}, ${booking_no} , ${passenger_id}, '${name}', '${email}', '${phone}', ${group_id});
            INSERT INTO client_flight VALUES(${ticket_no},${flight_id2});
            INSERT INTO ticket_flights VALUES(${boarding_id},${flight_id2},'${condition}');
            INSERT INTO ticket_boarding VALUES(${boarding_id},${ticket_no});
            COMMIT;`;
            await client.query(text);
            query += "Transaction\n\n" + text + "|";
            }
            catch(err)
            {
                res.json(err.message);
            }   
        } 
        // this is for when all flight is booked
        text = `SELECT DISTINCT 
        tck.ticket_no as ticket_id,
        tck.passenger_name as name,
        tck_flight.fare_conditions as fare_condition,
        fl.departure_airport as departure_airport,
        fl.arrival_airport as arrival_airport,
        clt_flight.flight_id as flight_id,
        brd.boarding_time as boarding_time,
        brd.boarding_gate as boarding_gate
        FROM ticket tck 
        INNER JOIN client_flight clt_flight on clt_flight.ticket_no = tck.ticket_no
        INNER JOIN flights fl on clt_flight.flight_id = fl.flight_id
        INNER JOIN boarding brd on clt_flight.flight_id = brd.flight_id
        INNER JOIN ticket_flights tck_flight on clt_flight.flight_id = tck_flight.flight_id
        WHERE tck.group_id = '${group_id}'
        ORDER BY tck.ticket_no;`;
        const result = await client.query(text);
        query += "Displays All Tickets\n\n" + text;
        res.json(result.rows);
    }
});

server.post('/ticketsForFlight', async(req, res)=>{
    try{
        //start booking transaction
        //then if successful, return boarding info
        const body = req.body;
        console.log(body);
        ticket_search = body [0];
        const client = await pool.connect();
        const result = await client.query(`select * from bookings.aircraft;`);
        client.end();
        res.json(result.rows);
    } 
    catch(err){
        res.json(JSON.stringify(err.message));
    }
  });

server.post('/removeTicket', async(req, res)=>{
    try{
        //start booking transaction
        //then if successful, return boarding info
        const body = req.body;
        console.log(body);
        ticket_search = body [0];
        const client = await pool.connect();
        const result = await client.query(`select * from bookings.aircraft;`);
        client.end();

        res.json("completed");
    } 
    catch(err){
        res.json(JSON.stringify(err.message));
    }
  });
