DROP TABLE IF EXISTS airport CASCADE;
DROP TABLE IF EXISTS seats CASCADE;
DROP TABLE IF EXISTS aircraft CASCADE;
DROP TABLE IF EXISTS ticket CASCADE;
DROP TABLE IF EXISTS ticket_flights CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS flights CASCADE;
DROP TABLE IF EXISTS wait_list CASCADE;
DROP TABLE IF EXISTS fare_price CASCADE;
DROP TABLE IF EXISTS arrival CASCADE;
DROP TABLE IF EXISTS boarding CASCADE;
DROP TABLE IF EXISTS client_flight CASCADE;
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS reservation CASCADE;
DROP TABLE IF EXISTS ticket_boarding CASCADE;
DROP TABLE IF EXISTS wait_list_info CASCADE;
DROP TABLE IF EXISTS ticket_flights_wait CASCADE;
DROP TABLE IF EXISTS ticket_boarding_wait CASCADE;

CREATE TABLE airport (
    airport_code char(3) NOT NULL,
    airport_name char(40),
    city char(20),
    coordinates point,
    timezone text,
    PRIMARY KEY (airport_code)
    /*
     ,CONSTRAINT flights_arrival_airport_fkey
     FOREIGN KEY (arrival_airport)
     REFERENCES airport(airport_code)
     ,CONSTRAINT seats_aircraft_code_fkey FOREIGN KEY (aircraft_code)
     REFERENCES aircraft(aircraft_code) ON DELETE CASCADE
     */
);

CREATE TABLE bookings (
    book_ref integer NOT NULL,
    book_date timestamp WITH time zone NOT NULL,
    total_amount_in_dollar numeric(10, 2) NOT NULL,
    PRIMARY KEY(book_ref)
);

CREATE TABLE aircraft(
    aircraft_code char(3),
    model char(25),
    RANGE integer NOT NULL,
    PRIMARY KEY(aircraft_code),
    CONSTRAINT flights_aircraft_code_fkey FOREIGN KEY (aircraft_code) REFERENCES aircraft(aircraft_code),
    CONSTRAINT seats_aircraft_code_fkey FOREIGN KEY (aircraft_code) REFERENCES aircraft(aircraft_code) ON DELETE CASCADE
);

CREATE TABLE fare_price(
    fare_conditions character varying(10) NOT NULL,
    price numeric(10,2) NOT NULL,
    PRIMARY KEY (fare_conditions),
    CONSTRAINT seats_fare_conditions_check CHECK (
        (
            (fare_conditions)::text = ANY (
                ARRAY [('Economy'::character varying)::text, ('Comfort'::character varying)::text, ('Business'::character varying)::text]
            )
        )
    )
);

CREATE TABLE seats (
    aircraft_code character(3) NOT NULL,
    seat_no character varying(4) NOT NULL,
    fare_conditions character varying(10) NOT NULL,
    PRIMARY KEY (aircraft_code, seat_no),
    CONSTRAINT seats_aircraft_code_fkey FOREIGN KEY (aircraft_code) REFERENCES aircraft(aircraft_code) ON DELETE CASCADE,
    CONSTRAINT seats_fare_conditions FOREIGN KEY (fare_conditions) REFERENCES fare_price(fare_conditions)
);

CREATE TABLE payment (
    reservation_no integer NOT NULL,
    card_number character(16) NOT NULL,
    taxes_in_dollar numeric (10, 2),
    amount_in_dollar numeric (10, 2),
    PRIMARY KEY(reservation_no)
);

CREATE TABLE reservation (
    book_ref integer NOT NULL,
    reservation_no integer NOT NULL,
    PRIMARY KEY(book_ref,reservation_no),
    CONSTRAINT reservation_book_ref_fkey FOREIGN KEY (book_ref) REFERENCES bookings(book_ref),
    CONSTRAINT reservation_reservation_no_fkey FOREIGN KEY (reservation_no) REFERENCES payment(reservation_no)
);

CREATE TABLE ticket(
    ticket_no integer NOT NULL,
    book_ref integer NOT NULL,
    passenger_id varchar(20) NOT NULL,
    passenger_name text,
    email char(50),
    phone text,
    group_id char(6),
    PRIMARY KEY (ticket_no),
    CONSTRAINT ticket_book_ref_fkey FOREIGN KEY (book_ref) REFERENCES bookings(book_ref)
);

CREATE TABLE wait_list_info(
    ticket_no integer NOT NULL,
    book_ref integer NOT NULL,
    passenger_id varchar(20) NOT NULL,
    passenger_name text,
    email char(50),
    phone text,
    group_id char(6),
    PRIMARY KEY (ticket_no),
    CONSTRAINT wait_list_book_ref_fkey FOREIGN KEY (book_ref) REFERENCES bookings(book_ref)
);

CREATE TABLE flights (
    flight_id integer NOT NULL,
    scheduled_departure timestamp WITH time zone NOT NULL,
    scheduled_arrival timestamp WITH time zone NOT NULL,
    departure_airport character(3) NOT NULL,
    arrival_airport character(3) NOT NULL,
    STATUS character varying(20) NOT NULL,
    aircraft_code character(3) NOT NULL,
    seats_available integer NOT NULL,
    seats_booked integer NOT NULL,
    movie character(1) NOT NULL,
    meal character(1) NOT NULL,

    PRIMARY KEY (flight_id),
    CONSTRAINT flights_aircraft_code_fkey FOREIGN KEY (aircraft_code) REFERENCES aircraft(aircraft_code),
    CONSTRAINT flights_arrival_airport_fkey FOREIGN KEY (arrival_airport) REFERENCES airport(airport_code),
    CONSTRAINT flights_departure_airport_fkey FOREIGN KEY (departure_airport) REFERENCES airport(airport_code),
    CONSTRAINT flights_check CHECK ((scheduled_arrival > scheduled_departure)),
    /*
     CONSTRAINT flights_check1 CHECK (
         (
             (actual_arrival IS NULL)
             OR (
                 (actual_departure IS NOT NULL)
                 AND (actual_arrival IS NOT NULL)
                 AND (actual_arrival > actual_departure)
             )
         )
     ),
     */
    CONSTRAINT flights_status_check CHECK (
        (
            (STATUS)::text = ANY (
                ARRAY [('On Time'::character varying)::text, ('Delayed'::character varying)::text, ('Departed'::character varying)::text, ('Arrived'::character varying)::text, ('Scheduled'::character varying)::text, ('Cancelled'::character varying)::text]
            )
        )
    )
);

CREATE TABLE client_flight(
    ticket_no integer NOT NULL,
    flight_id integer NOT NULL,
    PRIMARY KEY (ticket_no,flight_id),
    CONSTRAINT client_flight_ticket_no FOREIGN KEY (ticket_no) REFERENCES ticket(ticket_no),
    CONSTRAINT client_flight_flight_id FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

CREATE TABLE ticket_flights (
    boarding_id integer NOT NULL,
    flight_id integer NOT NULL,
    fare_conditions character varying(10) NOT NULL,
    PRIMARY KEY (boarding_id),
    CONSTRAINT ticket_flights_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    CONSTRAINT ticket_flights_fare_conditions FOREIGN KEY (fare_conditions) REFERENCES fare_price(fare_conditions)
);

CREATE TABLE ticket_boarding(
    boarding_id integer NOT NULL,
	ticket_no integer NOT NULL,
    PRIMARY KEY (boarding_id,ticket_no),
	CONSTRAINT ticket_boarding_ticket_no_fkey FOREIGN KEY (ticket_no) REFERENCES ticket(ticket_no),
    CONSTRAINT ticket_boarding_boarding_id_fkey FOREIGN KEY (boarding_id) REFERENCES ticket_flights(boarding_id)
);

CREATE TABLE ticket_flights_wait(
    boarding_id integer NOT NULL,
    flight_id integer NOT NULL,
    fare_conditions character varying(10) NOT NULL,
    PRIMARY KEY (boarding_id),
    CONSTRAINT ticket_flights_wait_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    CONSTRAINT ticket_flights_wait_fare_conditions FOREIGN KEY (fare_conditions) REFERENCES fare_price(fare_conditions)
);

CREATE TABLE ticket_boarding_wait(
    boarding_id integer NOT NULL,
	ticket_no integer NOT NULL,
    PRIMARY KEY (boarding_id,ticket_no),
	CONSTRAINT ticket_boarding_wait_ticket_no_fkey FOREIGN KEY (ticket_no) REFERENCES wait_list_info(ticket_no),
    CONSTRAINT ticket_boarding_wait_boarding_id_fkey FOREIGN KEY (boarding_id) REFERENCES ticket_flights_wait(boarding_id)
);

CREATE TABLE boarding(
	flight_id integer NOT NULL,
	boarding_time timestamp WITH time zone NOT NULL,
	boarding_gate char(2) NOT NULL,
	checked_bag integer NOT NULL,
	PRIMARY KEY (flight_id)
);

CREATE TABLE wait_list (
    ticket_no integer NOT NULL,
    flight_id integer NOT NULL,
    PRIMARY KEY(ticket_no,flight_id),
    CONSTRAINT wait_list_ticket_no_fkey FOREIGN KEY (ticket_no) REFERENCES wait_list_info(ticket_no),
	CONSTRAINT wait_list_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

CREATE TABLE arrival(
	flight_id integer NOT NULL,
    actual_arrival_time timestamp WITH time zone NOT NULL,
	arrival_gate char(2),
    baggage_claim_number char(2),
    PRIMARY KEY (flight_id),
	CONSTRAINT arival_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES flights(flight_id) ON DELETE CASCADE
);

/* INSERT VALUES */
/*airport table */
INSERT INTO airport
VALUES (
        'HOU',
        'George Bush Airport',
        'Houston',
        NULL,
        'CT'
    );

INSERT INTO airport
VALUES (
        'JFK',
        'John F Kennedy Airport',
        'New York',
        NULL,
        'ET'
    );

INSERT INTO airport
VALUES (
        'LAX',
        'Los Angeles Airport',
        'Los Angeles',
        NULL,
        'PT'
    );

INSERT INTO airport
VALUES (
        'ORD', 
        'O Hare Airport', 
        'Chicago', 
        NULL, 
        'CT');

INSERT INTO airport
VALUES ('MIA', 
        'Miami Airport', 
        'Miami', 
        NULL, 
        'ET');

/*aircraft*/
INSERT INTO aircraft
VALUES ('773', 'Boeing 767-300', 11100);

INSERT INTO aircraft
VALUES ('763', 'Boeing 777-300', 7900);

INSERT INTO aircraft
VALUES ('753', 'Boeing 787-300', 4900);

INSERT INTO aircraft
VALUES ('SU7', 'Boeing 767-300', 5700);

INSERT INTO aircraft
VALUES ('SU8', 'Boeing 777-300', 8700);

INSERT INTO aircraft
VALUES ('SU9', 'Boeing 787-300', 5100);

INSERT INTO aircraft
VALUES ('320', 'Boeing 767-300', 4800);

INSERT INTO aircraft
VALUES ('321', 'Boeing 777-300', 6500);

INSERT INTO aircraft
VALUES ('322', 'Boeing 787-300', 7500);

INSERT INTO aircraft
VALUES ('AS1', 'Boeing 767-300', 6400);

INSERT INTO aircraft
VALUES ('AS2', 'Boeing 777-300', 12000);

INSERT INTO aircraft
VALUES ('AS3', 'Boeing 787-300', 3400);

INSERT INTO aircraft
VALUES ('540', 'Boeing 767-300', 5800);

INSERT INTO aircraft
VALUES ('550', 'Boeing 777-300', 7900);

INSERT INTO aircraft
VALUES ('560', 'Boeing 787-300', 5600);

/*farecondition*/
INSERT INTO fare_price
VALUES ('Economy', 500);
INSERT INTO fare_price
VALUES ('Comfort', 600);
INSERT INTO fare_price
VALUES ('Business', 700);
/*flights*/
INSERT INTO flights
VALUES (
        1001,
        '2020-12-10 00:00:00+03',
        '2020-12-10 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1002,
        '2020-12-10 00:00:00+03',
        '2020-12-10 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1003,
        '2020-12-10 01:00:00+03',
        '2020-12-10 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1004,
        '2020-12-10 01:00:00+03',
        '2020-12-10 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1005,
        '2020-12-10 01:00:00+03',
        '2020-12-10 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1006,
        '2020-12-10 01:00:00+03',
        '2020-12-10 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1007,
        '2020-12-10 01:00:00+03',
        '2020-12-10 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1008,
        '2020-12-10 01:00:00+03',
        '2020-12-10 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1009,
        '2020-12-10 01:00:00+03',
        '2020-12-10 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO flights
VALUES (
        1010,
        '2020-12-10 01:00:00+03',
        '2020-12-10 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO flights
VALUES (
        1011,
        '2020-12-10 01:00:00+03',
        '2020-12-10 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO flights
VALUES (
        1012,
        '2020-12-10 01:00:00+03',
        '2020-12-10 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO flights
VALUES (
        1013,
        '2020-12-10 01:00:00+03',
        '2020-12-10 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO flights
VALUES (
        1014,
        '2020-12-10 01:00:00+03',
        '2020-12-10 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO flights
VALUES (
        1015,
        '2020-12-10 01:00:00+03',
        '2020-12-10 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO flights
VALUES (
        1016,
        '2020-12-10 05:00:00+03',
        '2020-12-10 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1017,
        '2020-12-10 04:00:00+03',
        '2020-12-10 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1018,
        '2020-12-10 06:00:00+03',
        '2020-12-10 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1019,
        '2020-12-10 05:00:00+03',
        '2020-12-10 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO flights
VALUES (
        1020,
        '2020-12-10 06:00:00+03',
        '2020-12-10 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1021,
        '2020-12-10 05:00:00+03',
        '2020-12-10 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1022,
        '2020-12-10 08:00:00+03',
        '2020-12-10 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1023,
        '2020-12-10 09:00:00+03',
        '2020-12-10 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1024,
        '2020-12-10 04:00:00+03',
        '2020-12-10 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1025,
        '2020-12-10 05:00:00+03',
        '2020-12-10 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1026,
        '2020-12-10 08:00:00+03',
        '2020-12-10 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO flights
VALUES (
        1027,
        '2020-12-10 08:00:00+03',
        '2020-12-10 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO flights
VALUES (
        1028,
        '2020-12-10 05:00:00+03',
        '2020-12-10 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO flights
VALUES (
        1029,
        '2020-12-10 06:00:00+03',
        '2020-12-10 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO flights
VALUES (
        1030,
        '2020-12-10 05:00:00+03',
        '2020-12-10 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO flights
VALUES (
        1031,
        '2020-12-10 05:00:00+03',
        '2020-12-10 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO flights
VALUES (
        1032,
        '2020-12-10 06:00:00+03',
        '2020-12-10 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO flights
VALUES (
        1033,
        '2020-12-10 09:00:00+03',
        '2020-12-10 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO flights
VALUES (
        1034,
        '2020-12-10 10:00:00+03',
        '2020-12-10 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO flights
VALUES (
        1035,
        '2020-12-10 10:00:00+03',
        '2020-12-10 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO flights
VALUES (
        1036,
        '2020-12-10 12:00:00+03',
        '2020-12-10 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1037,
        '2020-12-10 11:00:00+03',
        '2020-12-10 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1038,
        '2020-12-10 12:00:00+03',
        '2020-12-10 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1039,
        '2020-12-10 11:00:00+03',
        '2020-12-10 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1040,
        '2020-12-10 12:00:00+03',
        '2020-12-10 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO flights
VALUES (
        1041,
        '2020-12-10 09:00:00+03',
        '2020-12-10 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1042,
        '2020-12-10 10:00:00+03',
        '2020-12-10 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1043,
        '2020-12-10 12:00:00+03',
        '2020-12-10 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO flights
VALUES (
        1044,
        '2020-12-10 12:00:00+03',
        '2020-12-10 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO flights
VALUES (
        1045,
        '2020-12-10 10:00:00+03',
        '2020-12-10 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO flights
VALUES (
        1046,
        '2020-12-10 11:00:00+03',
        '2020-12-10 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1047,
        '2020-12-10 14:00:00+03',
        '2020-12-10 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1048,
        '2020-12-10 12:00:00+03',
        '2020-12-10 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO flights
VALUES (
        1049,
        '2020-12-10 12:00:00+03',
        '2020-12-10 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO flights
VALUES (
        1050,
        '2020-12-10 13:00:00+03',
        '2020-12-10 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO flights
VALUES (
        1051,
        '2020-12-10 15:00:00+03',
        '2020-12-10 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO flights
VALUES (
        1052,
        '2020-12-10 16:00:00+03',
        '2020-12-10 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1053,
        '2020-12-10 16:00:00+03',
        '2020-12-10 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1054,
        '2020-12-10 15:00:00+03',
        '2020-12-10 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1055,
        '2020-12-10 15:00:00+03',
        '2020-12-10 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1056,
        '2020-12-10 19:00:00+03',
        '2020-12-10 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1057,
        '2020-12-10 17:00:00+03',
        '2020-12-10 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1058,
        '2020-12-10 17:00:00+03',
        '2020-12-10 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1059,
        '2020-12-10 15:00:00+03',
        '2020-12-10 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO flights
VALUES (
        1060,
        '2020-12-10 15:00:00+03',
        '2020-12-10 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO flights
VALUES (
        1061,
        '2020-12-10 17:00:00+03',
        '2020-12-10 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO flights
VALUES (
        1062,
        '2020-12-10 16:00:00+03',
        '2020-12-10 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1063,
        '2020-12-10 17:00:00+03',
        '2020-12-10 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO flights
VALUES (
        1064,
        '2020-12-10 16:00:00+03',
        '2020-12-10 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO flights
VALUES (
        1065,
        '2020-12-10 17:00:00+03',
        '2020-12-10 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO flights
VALUES (
        1066,
        '2020-12-10 19:00:00+03',
        '2020-12-10 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO flights
VALUES (
        1067,
        '2020-12-10 20:00:00+03',
        '2020-12-10 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1068,
        '2020-12-10 20:00:00+03',
        '2020-12-10 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1069,
        '2020-12-10 22:00:00+03',
        '2020-12-10 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO flights
VALUES (
        1070,
        '2020-12-10 19:00:00+03',
        '2020-12-10 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1071,
        '2020-12-10 18:00:00+03',
        '2020-12-10 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1072,
        '2020-12-10 21:00:00+03',
        '2020-12-10 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1073,
        '2020-12-10 21:00:00+03',
        '2020-12-10 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1074,
        '2020-12-10 21:00:00+03',
        '2020-12-10 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO flights
VALUES (
        1075,
        '2020-12-10 18:00:00+03',
        '2020-12-10 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO flights
VALUES (
        1076,
        '2020-12-10 21:00:00+03',
        '2020-12-10 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO flights
VALUES (
        1077,
        '2020-12-10 18:00:00+03',
        '2020-12-10 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO flights
VALUES (
        1078,
        '2020-12-10 21:00:00+03',
        '2020-12-10 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO flights
VALUES (
        1079,
        '2020-12-10 19:00:00+03',
        '2020-12-10 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO flights
VALUES (
        1080,
        '2020-12-10 22:00:00+03',
        '2020-12-10 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO flights
VALUES (
        1081,
        '2020-12-10 19:00:00+03',
        '2020-12-10 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO flights
VALUES (
        1082,
        '2020-12-10 22:00:00+03',
        '2020-12-10 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  
/*boardig*/
INSERT INTO boarding
VALUES (
        1001,
        '2020-12-10 00:30:00+03',
        'E1',
        0
    );

INSERT INTO boarding
VALUES (
        1002,
        '2020-12-10 00:30:00+03',
        'E2',
        0
    );

INSERT INTO boarding
VALUES (
        1003,
        '2020-12-10 00:30:00+03',
        'E3',
        0
    );

INSERT INTO boarding
VALUES (
        1004,
        '2020-12-10 00:30:00+03',
        'M1',
        0
    );

INSERT INTO boarding
VALUES (
        1005,
        '2020-12-10 00:30:00+03',
        'M2',
        0
    );

INSERT INTO boarding
VALUES (
        1006,
        '2020-12-10 00:30:00+03',
        'M3',
        0
    );

INSERT INTO boarding
VALUES (
        1007,
        '2020-12-10 00:30:00+03',
        'L1',
        0
    );

INSERT INTO boarding
VALUES (
        1008,
        '2020-12-10 00:30:00+03',
        'L2',
        0
    );

INSERT INTO boarding
VALUES (
        1009,
        '2020-12-10 00:30:00+03',
        'L3',
        0 
    );


INSERT INTO boarding
VALUES (
        1010,
        '2020-12-10 00:30:00+03',
        'C1',
        0
    );   

INSERT INTO boarding
VALUES (
        1011,
        '2020-12-10 00:30:00+03',
        'C2',
        0
    );   

INSERT INTO boarding
VALUES (
        1012,
        '2020-12-10 00:30:00+03',
        'C3',
        0
    );      

INSERT INTO boarding
VALUES (
        1013,
        '2020-12-10 00:30:00+03',
        'B1',
        0
    );   

INSERT INTO boarding
VALUES (
        1014,
        '2020-12-10 00:30:00+03',
        'B2',
        0
    );   

INSERT INTO boarding
VALUES (
        1015,
        '2020-12-10 00:30:00+03',
        'B3',
        0
    );   
   
INSERT INTO boarding
VALUES (
        1016,
        '2020-12-10 04:30:00+03',
        'C1',
        0
    );

INSERT INTO boarding
VALUES (
        1017,
        '2020-12-10 03:30:00+03',
        'C2',
        0
    );

INSERT INTO boarding
VALUES (
        1018,
        '2020-12-10 05:30:00+03',
        'M1',
        0
    );

INSERT INTO boarding
VALUES (
        1019,
        '2020-12-10 04:30:00+03',
        'M2',
        0
    );

INSERT INTO boarding
VALUES (
        1020,
        '2020-12-10 05:30:00+03',
        'E1',
        0
    );

INSERT INTO boarding
VALUES (
        1021,
        '2020-12-10 04:30:00+03',
        'L2',
        0
    );

INSERT INTO boarding
VALUES (
        1022,
        '2020-12-10 07:30:00+03',
        'M3',
        0
    );

INSERT INTO boarding
VALUES (
        1023,
        '2020-12-10 08:30:00+03',
        'L3',
        0
    );

INSERT INTO boarding
VALUES (
        1024,
        '2020-12-10 03:30:00+03',
        'E3',
        0
    );

INSERT INTO boarding
VALUES (
        1025,
        '2020-12-10 04:30:00+03',
        'B1',
        0
    );

INSERT INTO boarding
VALUES (
        1026,
        '2020-12-10 07:30:00+03',
        'C1',
        0
    );


INSERT INTO boarding
VALUES (
        1027,
        '2020-12-10 07:30:00+03',
        'M2',
        0
    );   

INSERT INTO boarding
VALUES (
        1028,
        '2020-12-10 04:30:00+03',
        'E1',
        0
    );   

INSERT INTO boarding
VALUES (
        1029,
        '2020-12-10 05:30:00+03',
        'B3',
        0
    );      



INSERT INTO boarding
VALUES (
        1030,
        '2020-12-10 04:30:00+03',
        'M3',
        0
    );   

INSERT INTO boarding
VALUES (
        1031,
        '2020-12-10 04:30:00+03',
        'L3',
        0
    );   

INSERT INTO boarding
VALUES (
        1032,
        '2020-12-10 05:30:00+03',
        'C3',
        0
    );   

INSERT INTO boarding
VALUES (
        1033,
        '2020-12-10 08:30:00+03',
        'B3',
        0
    );   

INSERT INTO boarding
VALUES (
        1034,
        '2020-12-10 09:30:00+03',
        'E2',
        0
    );   

INSERT INTO boarding
VALUES (
        1035,
        '2020-12-10 09:30:00+03',
        'B3',
        0
    );

INSERT INTO boarding
VALUES (
        1036,
        '2020-12-10 11:30:00+03',
        'L2',
        0
    );

INSERT INTO boarding
VALUES (
        1037,
        '2020-12-10 10:30:00+03',
        'E2',
        0
    );

INSERT INTO boarding
VALUES (
        1038,
        '2020-12-10 11:30:00+03',
        'E1',
        0
    );

INSERT INTO boarding
VALUES (
        1039,
        '2020-12-10 10:30:00+03',
        'M1',
        0 
    );

INSERT INTO boarding
VALUES (
        1040,
        '2020-12-10 00:30:00+03',
        'C1',
        0
    );

INSERT INTO boarding
VALUES (
        1041,
        '2020-12-10 08:30:00+03',
        'M2',
        0
    );

INSERT INTO boarding
VALUES (
        1042,
        '2020-12-10 09:30:00+03',
        'C3',
        0
    );

INSERT INTO boarding
VALUES (
        1043,
        '2020-12-10 11:30:00+03',
        'E2',
        0
    );

INSERT INTO boarding
VALUES (
        1044,
        '2020-12-10 11:30:00+03',
        'L1',
        0
    );  

INSERT INTO boarding
VALUES (
        1045,
        '2020-12-10 09:30:00+03',
        'M2',
        0
    );   

INSERT INTO boarding
VALUES (
        1046,
        '2020-12-10 10:30:00+03',
        'M3',
        0
    );

INSERT INTO boarding
VALUES (
        1047,
        '2020-12-10 13:30:00+03',
        'E2',
        0
    );

INSERT INTO boarding
VALUES (
        1048,
        '2020-12-10 11:30:00+03',
        'E3',
        0
    );   

INSERT INTO boarding
VALUES (
        1049,
        '2020-12-10 11:30:00+03',
        'C3',
        0
    );   

INSERT INTO boarding
VALUES (
        1050,
        '2020-12-10 12:30:00+03',
        'L3',
        0
    );   

INSERT INTO boarding
VALUES (
        1051,
        '2020-12-10 14:30:00+03',
        'C1',
        0
    );

INSERT INTO boarding
VALUES (
        1052,
        '2020-12-10 15:30:00+03',
        'B3',
        0
    );

INSERT INTO boarding
VALUES (
        1053,
        '2020-12-10 15:30:00+03',
        'M3',
        0
    );

INSERT INTO boarding
VALUES (
        1054,
        '2020-12-10 14:30:00+03',
        'L2',
        0
    );

INSERT INTO boarding
VALUES (
        1055,
        '2020-12-10 14:30:00+03',
        'B1',
        0
    );

INSERT INTO boarding
VALUES (
        1056,
        '2020-12-10 18:30:00+03',
        'L1',
        0
    );

INSERT INTO boarding
VALUES (
        1057,
        '2020-12-10 16:30:00+03',
        'B1',
        0
    );

INSERT INTO boarding
VALUES (
        1058,
        '2020-12-10 16:30:00+03',
        'L2',  
        0
    );

INSERT INTO boarding
VALUES (
        1059,
        '2020-12-10 14:30:00+03',
        'B2',
        0
    );

INSERT INTO boarding
VALUES (
        1060,
        '2020-12-10 14:30:00+03',
        'E1',
        0
    );   

INSERT INTO boarding
VALUES (
        1061,
        '2020-12-10 16:30:00+03',
        'C3',
        0
    );   

INSERT INTO boarding
VALUES (
        1062,
        '2020-12-10 15:30:00+03',
        'E3',
        0
    );

INSERT INTO boarding
VALUES (
        1063,
        '2020-12-10 16:30:00+03',
        'M2',
        0
    );   

INSERT INTO boarding
VALUES (
        1064,
        '2020-12-10 15:30:00+03',
        'E1',
        0
    );   

INSERT INTO boarding
VALUES (
        1065,
        '2020-12-10 16:30:00+03',
        'M3',
        0
    );  


INSERT INTO boarding
VALUES (
        1066,
        '2020-12-10 18:30:00+03',
        'E1',
        0
    );

INSERT INTO boarding
VALUES (
        1067,
        '2020-12-10 19:30:00+03',     
        'M1',
        0
    );

INSERT INTO boarding
VALUES (
        1068,
        '2020-12-10 19:30:00+03',        
        'B3',    
        0
    );

INSERT INTO boarding
VALUES (
        1069,
        '2020-12-10 21:30:00+03',      
        'L2',
        0
    );


INSERT INTO boarding
VALUES (
        1070,
        '2020-12-10 18:30:00+03',
        'B1',
        0
    );

INSERT INTO boarding
VALUES (
        1071,
        '2020-12-10 17:30:00+03',
        'E2',
        0
    );

INSERT INTO boarding
VALUES (
        1072,
        '2020-12-10 20:30:00+03',
        'L3',
        0
    );

INSERT INTO boarding
VALUES (
        1073,
        '2020-12-10 20:30:00+03',
        'M2',
        0
    );

INSERT INTO boarding
VALUES (
        1074,
        '2020-12-10 20:30:00+03',
        'B1',
        0
    );

INSERT INTO boarding
VALUES (
        1075,
        '2020-12-10 17:30:00+03',
        'E3',
        0
    );

INSERT INTO boarding
VALUES (
        1076,
        '2020-12-10 20:30:00+03',
        'B2',
        0
    );

INSERT INTO boarding
VALUES (
        1077,
        '2020-12-10 17:30:00+03',
        'B3',
        0
    );   

INSERT INTO boarding
VALUES (
        1078,
        '2020-12-10 20:30:00+03',
        'E3',
        0
    );   

INSERT INTO boarding
VALUES (
        1079,
        '2020-12-10 18:30:00+03',
        'B2',
        0
    );

INSERT INTO boarding
VALUES (
        1080,
        '2020-12-10 21:30:00+03',
        'E1',
        0
    );   

INSERT INTO boarding
VALUES (
        1081,
        '2020-12-10 18:30:00+03',
        'L2',
        0
    );   

INSERT INTO boarding
VALUES (
        1082,
        '2020-12-10 21:30:00+03',
        'E2',
        0
    );  