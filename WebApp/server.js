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

var path = "password.txt";
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
    query = `
    SELECT *
    FROM MTAMJQ.flights WHERE MTAMJQ.flights.departure_airport LIKE '${depart}' 
    And MTAMJQ.flights.arrival_airport LIKE '${arrival}' 
    And '${time1}' < MTAMJQ.flights.scheduled_departure 
    And MTAMJQ.flights.scheduled_departure < '${time2}';`;
    try{
        const client = await pool.connect();
        const result = await client.query(query);
        res.json(result.rows);
        client.end();
    } 
    catch(err){
        res.json(JSON.stringify(err.message));
    }

    fs.writeFile('query.sql', query,  function(err) {
        if (err) {
            return console.error(err);
        }
    });
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
    query = `
    SELECT
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
    FROM MTAMJQ.flights as fl1
    INNER JOIN MTAMJQ.flights as fl2 ON fl1.departure_airport = '${depart}' AND  fl2.arrival_airport = '${arrival}'
    AND '${time1}' < fl1.scheduled_departure 
    AND fl1.scheduled_departure < '${time2}'
    AND fl1.arrival_airport NOT LIKE '${arrival}'
    AND fl2.departure_airport NOT LIKE '${depart}' 
    AND fl1.arrival_airport  = fl2.departure_airport
	AND fl2.scheduled_departure > fl1.scheduled_arrival
    AND DATE_PART('day', fl2.scheduled_departure::timestamp WITH time zone - fl1.scheduled_arrival::timestamp WITH time zone) < 2
    AND fl1.seats_available > 0 AND fl2.seats_available > 0;
    `;
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

    fs.writeFile('query.sql', query,  {'flag':'a'},  function(err) {
        if (err) {
            return console.error(err);
        }
    });
  });

server.post('/searchRoundTrip', async(req, res)=>{
    const body = req.body;
    console.log(body);
    var depart = body [0];
    var arrival = body [1];
    var time1 = body [2];
    var time2 = body [3];
    query = `
    SELECT
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
    FROM MTAMJQ.flights as fl1
    INNER JOIN MTAMJQ.flights as fl2 ON fl1.departure_airport = '${depart}' AND  fl2.arrival_airport = '${depart}'
    AND '${time1}' < fl1.scheduled_departure 
    AND fl1.scheduled_departure < '${time2}'
    AND fl1.arrival_airport LIKE '${arrival}'
    AND fl1.arrival_airport  = fl2.departure_airport
    AND fl2.scheduled_departure > fl1.scheduled_arrival
    AND DATE_PART('day', fl2.scheduled_departure::timestamp WITH time zone - fl1.scheduled_arrival::timestamp WITH time zone) < 2
    AND fl1.seats_available > 0 AND fl2.seats_available > 0;
    `;
    try{
        const client = await pool.connect();
        const result = await client.query(query);
        client.end();
        res.json(result.rows);
    } 
    catch(err){
        res.json(JSON.stringify(err.message));
    }

    fs.writeFile('query.sql', query,  function(err) {
        if (err) {
            return console.error(err);
        }
    });
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
            tax = price*5/100;
            total = price + tax;
        }
        else if(condition === "Comfort"){
            price = 600;
            tax = price*5/100;
            total = price + tax;
        }
        else {
            price = 700;
            tax = price*5/100;
            total = price + tax;
        }   
        if (seat_avalible > 0)
        {
        try{
            text = `BEGIN;
            INSERT INTO MTAMJQ.bookings VALUES(${booking_no} , CURRENT_TIMESTAMP, ${price} );
            INSERT INTO MTAMJQ.payment VALUES (${reservation_no}, ${credit} , ${tax}, ${total});
            INSERT INTO MTAMJQ.ticket VALUES(${ticket_no}, ${booking_no} , ${passenger_id}, '${name}', '${email}', '${phone}', ${group_id});
            INSERT INTO MTAMJQ.reservation VALUES(${booking_no},${reservation_no});
            INSERT INTO MTAMJQ.client_flight VALUES(${ticket_no},${flight_id});
            INSERT INTO MTAMJQ.ticket_flights VALUES(${boarding_id},${flight_id},'${condition}');
            INSERT INTO MTAMJQ.ticket_boarding VALUES(${boarding_id},${ticket_no});
            UPDATE MTAMJQ.flights SET seats_available = seats_available - 1, seats_booked = seats_booked + 1 WHERE MTAMJQ.flights.flight_id = ${flight_id};
            UPDATE MTAMJQ.boarding SET checked_bag = checked_bag + 1 WHERE MTAMJQ.boarding.flight_id = ${flight_id};
            COMMIT;`;
            await client.query(text);
            fs.writeFile('transaction.sql', text + "\n",  {'flag':'a'},  function(err) {
                if (err) {
                    return console.error(err);
                }
            });
            query += "Transaction\n\n" + text + "\n\n";
            }
            catch(err)
            {
                res.json(JSON.stringify(err.message));
            }   
        }
        else{
            try{
                text = `BEGIN;
                INSERT INTO MTAMJQ.bookings VALUES(${booking_no} , CURRENT_TIMESTAMP, ${price} );
                INSERT INTO MTAMJQ.payment VALUES (${reservation_no}, ${credit} , ${tax}, ${total});
                INSERT INTO MTAMJQ.wait_list_info VALUES(${ticket_no}, ${booking_no} , ${passenger_id}, '${name}', '${email}', '${phone}', ${group_id});
                INSERT INTO MTAMJQ.reservation VALUES(${booking_no},${reservation_no});
                INSERT INTO MTAMJQ.wait_list VALUES(${ticket_no},${flight_id});
                INSERT INTO MTAMJQ.ticket_flights_wait VALUES(${boarding_id},${flight_id},'${condition}');
                INSERT INTO MTAMJQ.ticket_boarding_wait VALUES(${boarding_id},${ticket_no});
                COMMIT;`;
                await client.query(text);
                fs.writeFile('transaction.sql', text + "\n",  {'flag':'a'},  function(err) {
                    if (err) {
                        return console.error(err);
                    }
                });
                query += "Transaction\n\n" + text + "\n\n";
            }
            catch(err)
            {
                res.json(JSON.stringify(err.message));  
            }
        }
    }
    text = `
        SELECT DISTINCT 
        tck.ticket_no as ticket_id,
        tck.passenger_name as name,
        tck_flight.fare_conditions as fare_condition,
        fl.departure_airport as departure_airport,
        fl.arrival_airport as arrival_airport,
        clt_flight.flight_id as flight_id,
        brd.boarding_time as boarding_time,
        brd.boarding_gate as boarding_gate
        FROM MTAMJQ.ticket as tck 
        INNER JOIN MTAMJQ.client_flight as clt_flight on clt_flight.ticket_no = tck.ticket_no
        INNER JOIN MTAMJQ.flights as fl on clt_flight.flight_id = fl.flight_id
        INNER JOIN MTAMJQ.boarding as brd on clt_flight.flight_id = brd.flight_id
        INNER JOIN MTAMJQ.ticket_flights as tck_flight on clt_flight.flight_id = tck_flight.flight_id
        WHERE tck.group_id = '${group_id}'
        ORDER BY tck.ticket_no;
        `;
        const result = await client.query(text);
        fs.writeFile('query.sql', text + "\n",  {'flag':'a'},  function(err) {
            if (err) {
                return console.error(err);
            }
        });
        query += "\n\nDisplays All Tickets\n\n" + text;
        res.json(result.rows);
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
    console.log(body);
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
            tax = price*5/100;
            total = price + tax;
        }
        else if(condition === "Comfort"){
            price = 600;
            tax = price*5/100;
            total = price + tax;
        }
        else {
            price = 700;
            tax = price*5/100;
            total = price + tax;
        }   
        try{
            text = `BEGIN;
            INSERT INTO MTAMJQ.bookings VALUES(${booking_no} , CURRENT_TIMESTAMP, 2*${price} );
            INSERT INTO MTAMJQ.payment VALUES (${reservation_no}, ${credit} , 2*${tax}, 2*${total});
            INSERT INTO MTAMJQ.ticket VALUES(${ticket_no}, ${booking_no} , ${passenger_id}, '${name}', '${email}', '${phone}', ${group_id});
            INSERT INTO MTAMJQ.reservation VALUES(${booking_no},${reservation_no});
            INSERT INTO MTAMJQ.client_flight VALUES(${ticket_no},${flight_id});
            INSERT INTO MTAMJQ.ticket_flights VALUES(${boarding_id},${flight_id},'${condition}');
            INSERT INTO MTAMJQ.ticket_boarding VALUES(${boarding_id},${ticket_no});
            UPDATE MTAMJQ.flights SET seats_available = seats_available - 1, seats_booked = seats_booked + 1 WHERE flights.flight_id = ${flight_id};
            UPDATE MTAMJQ.boarding SET checked_bag = checked_bag + 1 WHERE boarding.flight_id = ${flight_id};
            UPDATE MTAMJQ.flights SET seats_available = seats_available - 1, seats_booked = seats_booked + 1 WHERE flights.flight_id = ${flight_id2};
            UPDATE MTAMJQ.boarding SET checked_bag = checked_bag + 1 WHERE boarding.flight_id = ${flight_id2};`;

            ticket_no = ++ticket_no;
            boarding_id = ++boarding_id;

            text += `INSERT INTO MTAMJQ.ticket VALUES(${ticket_no}, ${booking_no} , ${passenger_id}, '${name}', '${email}', '${phone}', ${group_id});
            INSERT INTO MTAMJQ.client_flight VALUES(${ticket_no},${flight_id2});
            INSERT INTO MTAMJQ.ticket_flights VALUES(${boarding_id},${flight_id2},'${condition}');
            INSERT INTO MTAMJQ.ticket_boarding VALUES(${boarding_id},${ticket_no});
            COMMIT;`;
            await client.query(text);
            fs.writeFile('transaction.sql', text + "\n",  {'flag':'a'},  function(err) {
                if (err) {
                    return console.error(err);
                }
            });
            query += "Transaction\n\n" + text + "\n\n";
            }
            catch(err)
            {
                res.json(err.message);
            }   
        } 
        // this is for when all flight is booked
        text = `
        SELECT DISTINCT 
        tck.ticket_no as ticket_id,
        tck.passenger_name as name,
        tck_flight.fare_conditions as fare_condition,
        fl.departure_airport as departure_airport,
        fl.arrival_airport as arrival_airport,
        clt_flight.flight_id as flight_id,
        brd.boarding_time as boarding_time,
        brd.boarding_gate as boarding_gate
        FROM MTAMJQ.ticket as tck 
        INNER JOIN MTAMJQ.client_flight as clt_flight on clt_flight.ticket_no = tck.ticket_no
        INNER JOIN MTAMJQ.flights as fl on clt_flight.flight_id = fl.flight_id
        INNER JOIN MTAMJQ.boarding as brd on clt_flight.flight_id = brd.flight_id
        INNER JOIN MTAMJQ.ticket_flights as tck_flight on clt_flight.flight_id = tck_flight.flight_id
        WHERE tck.group_id = '${group_id}'
        ORDER BY tck.ticket_no;
        `;
        const result = await client.query(text);
        query += "\n\nDisplays All Tickets\n\n" + text;
        res.json(result.rows);

        fs.writeFile('query.sql', text + "\n",  {'flag':'a'},  function(err) {
            if (err) {
                return console.error(err);
            }
        });
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
        query = `
        SELECT tck.ticket_no as ticket_no,
		tck.book_ref as book_ref,
		tck.passenger_id as passenger_id,
		tck.passenger_name as passenger_name,
		tck.email as email,
		tck.phone as phone,
		tck.group_id as group_id
        FROM MTAMJQ.ticket as tck
        INNER JOIN MTAMJQ.client_flight as cf on tck.ticket_no = cf.ticket_no
        WHERE cf.flight_id = ${ticket_search};`;
        const result = await client.query(query);
        client.end();
        res.json(result.rows);
    } 
    catch(err){
        res.json(JSON.stringify(err.message));
    }

    fs.writeFile('query.sql', query,  {'flag':'a'},  function(err) {
        if (err) {
            return console.error(err);
        }
    });
  });

server.post('/removeTicket', async(req, res)=>{
    try{
        //start booking transaction
        //then if successful, return boarding info
        const body = req.body;
        console.log(body);
        flight_id = body[0];
        book_ref = body [2];
        const client = await pool.connect();
        query = `BEGIN;
        ALTER TABLE MTAMJQ.client_flight DROP CONSTRAINT client_flight_ticket_no;
        ALTER TABLE MTAMJQ.client_flight DROP CONSTRAINT client_flight_flight_id;
        ALTER TABLE MTAMJQ.ticket_boarding DROP CONSTRAINT ticket_boarding_ticket_no_fkey;
        ALTER TABLE MTAMJQ.ticket_boarding DROP CONSTRAINT ticket_boarding_boarding_id_fkey;
        ALTER TABLE MTAMJQ.ticket_flights DROP CONSTRAINT ticket_flights_flight_id_fkey;
        ALTER TABLE MTAMJQ.ticket_flights DROP CONSTRAINT ticket_flights_fare_conditions;
        ALTER TABLE MTAMJQ.ticket DROP CONSTRAINT ticket_book_ref_fkey;
        ALTER TABLE MTAMJQ.reservation DROP CONSTRAINT reservation_reservation_no_fkey;
        DELETE 
        FROM MTAMJQ.ticket_flights as tf
        USING MTAMJQ.ticket_boarding as tb, MTAMJQ.ticket as tck
        WHERE tb.boarding_id = tf.boarding_id AND
        tck.ticket_no = tb.ticket_no AND
        tck.book_ref = ${book_ref};
        DELETE  
        FROM MTAMJQ.client_flight cf
	    USING MTAMJQ.ticket tck
        WHERE tck.ticket_no = cf.ticket_no AND
        tck.book_ref = ${book_ref};	 
        DELETE  
        FROM MTAMJQ.ticket_boarding tb 
	    USING MTAMJQ.ticket tck
        WHERE tck.ticket_no = tb.ticket_no AND
        tck.book_ref = ${book_ref};	 
        DELETE 
        FROM
        MTAMJQ.ticket tck
        WHERE tck.book_ref = ${book_ref};
        DELETE 
        FROM MTAMJQ.payment pm 
        USING MTAMJQ.reservation rs 
        WHERE pm.reservation_no  = rs.reservation_no AND
        rs.book_ref = ${book_ref};
        DELETE 
        FROM
        MTAMJQ.reservation rs 
        WHERE rs.book_ref = ${book_ref};
        ALTER TABLE MTAMJQ.client_flight ADD CONSTRAINT client_flight_ticket_no FOREIGN KEY (ticket_no) REFERENCES MTAMJQ.ticket(ticket_no) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.client_flight ADD CONSTRAINT client_flight_flight_id FOREIGN KEY (flight_id) REFERENCES MTAMJQ.flights(flight_id) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.ticket_boarding ADD CONSTRAINT ticket_boarding_ticket_no_fkey FOREIGN KEY (ticket_no) REFERENCES MTAMJQ.ticket(ticket_no) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.ticket_boarding ADD CONSTRAINT ticket_boarding_boarding_id_fkey FOREIGN KEY (boarding_id) REFERENCES MTAMJQ.ticket_flights(boarding_id) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.ticket_flights ADD CONSTRAINT ticket_flights_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES MTAMJQ.flights(flight_id) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.ticket_flights ADD CONSTRAINT ticket_flights_fare_conditions FOREIGN KEY (fare_conditions) REFERENCES MTAMJQ.fare_price(fare_conditions) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.ticket ADD CONSTRAINT ticket_book_ref_fkey FOREIGN KEY (book_ref) REFERENCES MTAMJQ.bookings(book_ref) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.reservation ADD CONSTRAINT reservation_reservation_no_fkey
        FOREIGN KEY (reservation_no) 
        REFERENCES MTAMJQ.payment(reservation_no)
        ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.ticket DROP CONSTRAINT ticket_book_ref_fkey;
        ALTER TABLE MTAMJQ.ticket_flights DROP CONSTRAINT ticket_flights_flight_id_fkey;
        ALTER TABLE MTAMJQ.ticket_flights DROP CONSTRAINT ticket_flights_fare_conditions;
        ALTER TABLE MTAMJQ.ticket_boarding DROP CONSTRAINT ticket_boarding_ticket_no_fkey;
        ALTER TABLE MTAMJQ.ticket_boarding DROP CONSTRAINT ticket_boarding_boarding_id_fkey;
        ALTER TABLE MTAMJQ.client_flight DROP CONSTRAINT client_flight_ticket_no;
        ALTER TABLE MTAMJQ.client_flight DROP CONSTRAINT client_flight_flight_id;
        insert into MTAMJQ.ticket (ticket_no, book_ref, passenger_id, passenger_name, email, phone, group_id)
        select wli.ticket_no, wli.book_ref, wli.passenger_id, wli.passenger_name, wli.email, wli.phone, wli.group_id from MTAMJQ.wait_list_info as wli
        inner join MTAMJQ.wait_list wl on wli.ticket_no = wl.ticket_no
        where wl.flight_id = ${flight_id}
        LIMIT 1;
        insert into MTAMJQ.ticket_flights (boarding_id, flight_id, fare_conditions)
        select tfw.boarding_id, tfw.flight_id, tfw.fare_conditions from MTAMJQ.ticket_flights_wait as tfw
        where tfw.flight_id = ${flight_id}
        LIMIT 1;
        insert into MTAMJQ.ticket_boarding (boarding_id, ticket_no)
        select tbw.boarding_id, tbw.ticket_no from MTAMJQ.ticket_boarding_wait as tbw
        inner join MTAMJQ.wait_list wl on tbw.ticket_no = wl.ticket_no
        where wl.flight_id = ${flight_id}
        LIMIT 1;
        INSERT INTO MTAMJQ.client_flight(ticket_no, flight_id)
        select wl.ticket_no, wl.flight_id from MTAMJQ.wait_list as wl
        where wl.flight_id = ${flight_id}
        LIMIT 1;
        ALTER TABLE MTAMJQ.ticket ADD CONSTRAINT ticket_book_ref_fkey FOREIGN KEY (book_ref) REFERENCES MTAMJQ.bookings(book_ref) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.ticket_flights ADD CONSTRAINT ticket_flights_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES MTAMJQ.flights(flight_id) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.ticket_flights ADD CONSTRAINT ticket_flights_fare_conditions FOREIGN KEY (fare_conditions) REFERENCES MTAMJQ.fare_price(fare_conditions) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.ticket_boarding ADD CONSTRAINT ticket_boarding_ticket_no_fkey FOREIGN KEY (boarding_id) REFERENCES MTAMJQ.ticket_flights(boarding_id) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.ticket_boarding ADD CONSTRAINT ticket_boarding_boarding_id_fkey FOREIGN KEY (boarding_id) REFERENCES MTAMJQ.ticket_flights(boarding_id) ON DELETE CASCADE;
        ALter table MTAMJQ.client_flight ADD CONSTRAINT client_flight_ticket_no FOREIGN KEY (ticket_no) REFERENCES MTAMJQ.ticket(ticket_no) ON DELETE CASCADE;
        ALter table MTAMJQ.client_flight ADD CONSTRAINT client_flight_flight_id FOREIGN KEY (flight_id) REFERENCES MTAMJQ.flights(flight_id) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.wait_list_info DROP CONSTRAINT wait_list_book_ref_fkey;
        ALter table MTAMJQ.wait_list DROP CONSTRAINT wait_list_ticket_no_fkey;
        ALter table MTAMJQ.wait_list DROP CONSTRAINT wait_list_flight_id_fkey;
        ALter table MTAMJQ.ticket_flights_wait DROP CONSTRAINT ticket_flights_wait_flight_id_fkey;
        ALter table MTAMJQ.ticket_flights_wait DROP CONSTRAINT ticket_flights_wait_fare_conditions;
        ALter table MTAMJQ.ticket_boarding_wait DROP CONSTRAINT ticket_boarding_wait_ticket_no_fkey;
        ALter table MTAMJQ.ticket_boarding_wait DROP CONSTRAINT ticket_boarding_wait_boarding_id_fkey;
        DELETE 
        FROM MTAMJQ.wait_list_info as wli
        WHERE wli.ticket_no IN(select ticket_no
                                 from MTAMJQ.wait_list as wl
                                 where wl.flight_id = ${flight_id} LIMIT 1);
        DELETE 
        from MTAMJQ.ticket_flights_wait as tfw
        where ctid IN (select ctid 
                                 from MTAMJQ.ticket_flights_wait
                                 where flight_id = ${flight_id} LIMIT 1);
        DELETE 
        from MTAMJQ.ticket_boarding_wait as tbw
        WHERE tbw.ticket_no IN(select ticket_no
                                 from MTAMJQ.wait_list as wl
                                 where wl.flight_id = ${flight_id} LIMIT 1);
        DELETE 
        FROM MTAMJQ.wait_list as wl
        Where ctid in (select ctid 
                       from MTAMJQ.wait_list 
                       where flight_id = ${flight_id} LIMIT 1);
        ALTER TABLE MTAMJQ.wait_list_info ADD CONSTRAINT wait_list_book_ref_fkey FOREIGN KEY (book_ref) REFERENCES MTAMJQ.bookings(book_ref) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.wait_list ADD CONSTRAINT wait_list_ticket_no_fkey FOREIGN KEY (ticket_no) REFERENCES MTAMJQ.wait_list_info(ticket_no) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.wait_list ADD CONSTRAINT wait_list_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES MTAMJQ.flights(flight_id) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.ticket_flights_wait ADD CONSTRAINT ticket_flights_wait_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES MTAMJQ.flights(flight_id) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.ticket_flights_wait ADD CONSTRAINT ticket_flights_wait_fare_conditions FOREIGN KEY (fare_conditions) REFERENCES MTAMJQ.fare_price(fare_conditions) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.ticket_boarding_wait ADD CONSTRAINT ticket_boarding_wait_ticket_no_fkey FOREIGN KEY (ticket_no) REFERENCES MTAMJQ.wait_list_info(ticket_no) ON DELETE CASCADE;
        ALTER TABLE MTAMJQ.ticket_boarding_wait ADD CONSTRAINT ticket_boarding_wait_boarding_id_fkey FOREIGN KEY (boarding_id) REFERENCES MTAMJQ.ticket_flights_wait(boarding_id) ON DELETE CASCADE;
        COMMIT;`;
        const result = await client.query(query);
        client.end();

        res.json("completed");
    } 
    catch(err){
        res.json(JSON.stringify(err.message));
    }

    fs.writeFile('transaction.sql', query ,  {'flag':'a'},  function(err) {
        if (err) {
            return console.error(err);
        }
    });
  });
