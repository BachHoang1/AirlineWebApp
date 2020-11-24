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
    book_ref character(6) NOT NULL,
    book_date timestamp WITH time zone NOT NULL,
    total_amount numeric(10, 2) NOT NULL,
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
    reservation_no character(6) NOT NULL,
    card_number integer NOT NULL,
    taxes numeric (10, 2),
    amount numeric (10, 2),
    PRIMARY KEY(reservation_no)
);

CREATE TABLE reservation (
    book_ref character(6) NOT NULL,
    reservation_no character(6) NOT NULL,
    PRIMARY KEY(book_ref),
    CONSTRAINT reservation_book_ref_fkey FOREIGN KEY (book_ref) REFERENCES bookings(book_ref),
    CONSTRAINT reservation_reservation_no_fkey FOREIGN KEY (reservation_no) REFERENCES payment(reservation_no)
);

CREATE TABLE ticket(
    ticket_no char(13) NOT NULL,
    book_ref character(6) NOT NULL,
    passenger_id varchar(20) NOT NULL,
    passenger_name text,
    email char(50),
    phone char(15),
    group_id char(6),
    PRIMARY KEY (ticket_no),
    CONSTRAINT ticket_book_ref_fkey FOREIGN KEY (book_ref) REFERENCES bookings(book_ref)
);

CREATE TABLE flights (
    flight_id character(6) NOT NULL,
    scheduled_departure timestamp WITH time zone NOT NULL,
    scheduled_arrival timestamp WITH time zone NOT NULL,
    departure_airport character(3) NOT NULL,
    arrival_airport character(3) NOT NULL,
    STATUS character varying(20) NOT NULL,
    aircraft_code character(3) NOT NULL,
    seats_available character(3) NOT NULL,
    seats_booked character(3) NOT NULL,
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
    ticket_no varchar(20) NOT NULL,
    flight_id character(6) NOT NULL,
    PRIMARY KEY (ticket_no,flight_id),
    CONSTRAINT client_flight_ticket_no FOREIGN KEY (ticket_no) REFERENCES ticket(ticket_no),
    CONSTRAINT client_flight_flight_id FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

CREATE TABLE ticket_flights (
    boarding_id character(6) NOT NULL,
    ticket_no character(6) NOT NULL,
    seat_no character varying(4) NOT NULL,
    fare_conditions character varying(10) NOT NULL,
    PRIMARY KEY (boarding_id),
    CONSTRAINT ticket_flights_boarding_id_fkey FOREIGN KEY (ticket_no) REFERENCES ticket(ticket_no),
    CONSTRAINT ticket_flights_fare_conditions FOREIGN KEY (fare_conditions) REFERENCES fare_price(fare_conditions)
);

CREATE TABLE ticket_boarding(
    boarding_id character(6) NOT NULL,
	ticket_no character(13) NOT NULL,
    PRIMARY KEY (boarding_id),
	CONSTRAINT ticket_boarding_ticket_no_fkey FOREIGN KEY (ticket_no) REFERENCES ticket(ticket_no),
    CONSTRAINT ticket_boarding_boarding_id_fkey FOREIGN KEY (boarding_id) REFERENCES ticket_flights(boarding_id)
);

CREATE TABLE boarding(
	flight_no character(6) NOT NULL,
	boarding_time timestamp WITH time zone NOT NULL,
	seat_no character varying(4) NOT NULL,
	boarding_gate char(10),
	checked_bag integer NOT NULL NOT NULL,
	PRIMARY KEY (flight_no)
);

CREATE TABLE flight_no_flight_id(
    flight_id character(6) NOT NULL,
    flight_no character(6) NOT NULL,
    PRIMARY KEY (flight_id),
    CONSTRAINT client_flight_ticket_id FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    CONSTRAINT client_flight_ticket_no FOREIGN KEY (flight_no) REFERENCES boarding(flight_no)
);  

CREATE TABLE wait_list (
    ticket_no character(6) NOT NULL,
    flight_no character(6) NOT NULL,
    PRIMARY KEY(ticket_no),
    CONSTRAINT wait_list_ticket_no_fkey FOREIGN KEY (ticket_no) REFERENCES ticket(ticket_no),
	CONSTRAINT wait_list_flight_no_fkey FOREIGN KEY (flight_no) REFERENCES boarding(flight_no)
);


CREATE TABLE arival(
	flight_id character(6) NOT NULL,
    actual_arrival_time timestamp WITH time zone NOT NULL,
	arrival_gate char(30),
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

/*flights table*/