DROP TABLE IF EXISTS MTAMJQ.ticket CASCADE;
DROP TABLE IF EXISTS MTAMJQ.ticket_flights CASCADE;
DROP TABLE IF EXISTS MTAMJQ.bookings CASCADE;
DROP TABLE IF EXISTS MTAMJQ.flights CASCADE;
DROP TABLE IF EXISTS MTAMJQ.wait_list CASCADE;
DROP TABLE IF EXISTS MTAMJQ.client_flight CASCADE;
DROP TABLE IF EXISTS MTAMJQ.payment CASCADE;
DROP TABLE IF EXISTS MTAMJQ.reservation CASCADE;
DROP TABLE IF EXISTS MTAMJQ.ticket_boarding CASCADE;
DROP TABLE IF EXISTS MTAMJQ.wait_list_info CASCADE;
DROP TABLE IF EXISTS MTAMJQ.ticket_flights_wait CASCADE;
DROP TABLE IF EXISTS MTAMJQ.ticket_boarding_wait CASCADE;

CREATE TABLE MTAMJQ.bookings (
    book_ref integer NOT NULL,
    book_date timestamp WITH time zone NOT NULL,
    total_amount_in_dollar numeric(10, 2) NOT NULL,
    PRIMARY KEY(book_ref)
);

CREATE TABLE MTAMJQ.payment (
    reservation_no integer NOT NULL,
    card_number character(16) NOT NULL,
    taxes_in_dollar numeric (10, 2),
    amount_in_dollar numeric (10, 2),
    PRIMARY KEY(reservation_no)
);

CREATE TABLE MTAMJQ.reservation (
    book_ref integer NOT NULL,
    reservation_no integer NOT NULL,
    PRIMARY KEY(book_ref,reservation_no),
    CONSTRAINT reservation_book_ref_fkey FOREIGN KEY (book_ref) REFERENCES MTAMJQ.bookings(book_ref),
    CONSTRAINT reservation_reservation_no_fkey FOREIGN KEY (reservation_no) REFERENCES MTAMJQ.payment(reservation_no)
);

CREATE TABLE MTAMJQ.ticket(
    ticket_no integer NOT NULL,
    book_ref integer NOT NULL,
    passenger_id varchar(20) NOT NULL,
    passenger_name text,
    email char(50),
    phone text,
    group_id char(6),
    PRIMARY KEY (ticket_no),
    CONSTRAINT ticket_book_ref_fkey FOREIGN KEY (book_ref) REFERENCES MTAMJQ.bookings(book_ref)
);

CREATE TABLE MTAMJQ.wait_list_info(
    ticket_no integer NOT NULL,
    book_ref integer NOT NULL,
    passenger_id varchar(20) NOT NULL,
    passenger_name text,
    email char(50),
    phone text,
    group_id char(6),
    PRIMARY KEY (ticket_no),
    CONSTRAINT wait_list_book_ref_fkey FOREIGN KEY (book_ref) REFERENCES MTAMJQ.bookings(book_ref)
);

CREATE TABLE MTAMJQ.flights (
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
    CONSTRAINT flights_aircraft_code_fkey FOREIGN KEY (aircraft_code) REFERENCES MTAMJQ.aircraft(aircraft_code),
    CONSTRAINT flights_arrival_airport_fkey FOREIGN KEY (arrival_airport) REFERENCES MTAMJQ.airport(airport_code),
    CONSTRAINT flights_departure_airport_fkey FOREIGN KEY (departure_airport) REFERENCES MTAMJQ.airport(airport_code),
    CONSTRAINT flights_check CHECK ((scheduled_arrival > scheduled_departure)),
    CONSTRAINT flights_status_check CHECK (
        (
            (STATUS)::text = ANY (
                ARRAY [('On Time'::character varying)::text, ('Delayed'::character varying)::text, ('Departed'::character varying)::text, ('Arrived'::character varying)::text, ('Scheduled'::character varying)::text, ('Cancelled'::character varying)::text]
            )
        )
    )
);

CREATE TABLE MTAMJQ.client_flight(
    ticket_no integer NOT NULL,
    flight_id integer NOT NULL,
    PRIMARY KEY (ticket_no,flight_id),
    CONSTRAINT client_flight_ticket_no FOREIGN KEY (ticket_no) REFERENCES MTAMJQ.ticket(ticket_no),
    CONSTRAINT client_flight_flight_id FOREIGN KEY (flight_id) REFERENCES MTAMJQ.flights(flight_id)
);

CREATE TABLE MTAMJQ.ticket_flights (
    boarding_id integer NOT NULL,
    flight_id integer NOT NULL,
    fare_conditions character varying(10) NOT NULL,
    PRIMARY KEY (boarding_id),
    CONSTRAINT ticket_flights_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES MTAMJQ.flights(flight_id),
    CONSTRAINT ticket_flights_fare_conditions FOREIGN KEY (fare_conditions) REFERENCES MTAMJQ.fare_price(fare_conditions)
);

CREATE TABLE MTAMJQ.ticket_boarding(
    boarding_id integer NOT NULL,
	ticket_no integer NOT NULL,
    PRIMARY KEY (boarding_id,ticket_no),
	CONSTRAINT ticket_boarding_ticket_no_fkey FOREIGN KEY (ticket_no) REFERENCES MTAMJQ.ticket(ticket_no),
    CONSTRAINT ticket_boarding_boarding_id_fkey FOREIGN KEY (boarding_id) REFERENCES MTAMJQ.ticket_flights(boarding_id)
);

CREATE TABLE MTAMJQ.ticket_flights_wait(
    boarding_id integer NOT NULL,
    flight_id integer NOT NULL,
    fare_conditions character varying(10) NOT NULL,
    PRIMARY KEY (boarding_id),
    CONSTRAINT ticket_flights_wait_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES MTAMJQ.flights(flight_id),
    CONSTRAINT ticket_flights_wait_fare_conditions FOREIGN KEY (fare_conditions) REFERENCES MTAMJQ.fare_price(fare_conditions)
);

CREATE TABLE MTAMJQ.ticket_boarding_wait(
    boarding_id integer NOT NULL,
	ticket_no integer NOT NULL,
    PRIMARY KEY (boarding_id,ticket_no),
	CONSTRAINT ticket_boarding_wait_ticket_no_fkey FOREIGN KEY (ticket_no) REFERENCES MTAMJQ.wait_list_info(ticket_no),
    CONSTRAINT ticket_boarding_wait_boarding_id_fkey FOREIGN KEY (boarding_id) REFERENCES MTAMJQ.ticket_flights_wait(boarding_id)
);

CREATE TABLE MTAMJQ.wait_list (
    ticket_no integer NOT NULL,
    flight_id integer NOT NULL,
    PRIMARY KEY(ticket_no,flight_id),
    CONSTRAINT wait_list_ticket_no_fkey FOREIGN KEY (ticket_no) REFERENCES MTAMJQ.wait_list_info(ticket_no),
	CONSTRAINT wait_list_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES MTAMJQ.flights(flight_id)
);

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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


INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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
   
INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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


INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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



INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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


INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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


INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
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

INSERT INTO MTAMJQ.flights
VALUES (
        1101,
        '2020-12-11 00:00:00+03',
        '2020-12-11 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1102,
        '2020-12-11 00:00:00+03',
        '2020-12-11 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1103,
        '2020-12-11 01:00:00+03',
        '2020-12-11 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1104,
        '2020-12-11 01:00:00+03',
        '2020-12-11 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1105,
        '2020-12-11 01:00:00+03',
        '2020-12-11 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1106,
        '2020-12-11 01:00:00+03',
        '2020-12-11 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1107,
        '2020-12-11 01:00:00+03',
        '2020-12-11 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1108,
        '2020-12-11 01:00:00+03',
        '2020-12-11 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1109,
        '2020-12-11 01:00:00+03',
        '2020-12-11 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1110,
        '2020-12-11 01:00:00+03',
        '2020-12-11 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1111,
        '2020-12-11 01:00:00+03',
        '2020-12-11 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1112,
        '2020-12-11 01:00:00+03',
        '2020-12-11 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        1113,
        '2020-12-11 01:00:00+03',
        '2020-12-11 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1114,
        '2020-12-11 01:00:00+03',
        '2020-12-11 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1115,
        '2020-12-11 01:00:00+03',
        '2020-12-11 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        1116,
        '2020-12-11 05:00:00+03',
        '2020-12-11 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1117,
        '2020-12-11 04:00:00+03',
        '2020-12-11 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1118,
        '2020-12-11 06:00:00+03',
        '2020-12-11 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1119,
        '2020-12-11 05:00:00+03',
        '2020-12-11 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1120,
        '2020-12-11 06:00:00+03',
        '2020-12-11 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1121,
        '2020-12-11 05:00:00+03',
        '2020-12-11 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1122,
        '2020-12-11 08:00:00+03',
        '2020-12-11 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1123,
        '2020-12-11 09:00:00+03',
        '2020-12-11 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1124,
        '2020-12-11 04:00:00+03',
        '2020-12-11 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1125,
        '2020-12-11 05:00:00+03',
        '2020-12-11 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1126,
        '2020-12-11 08:00:00+03',
        '2020-12-11 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1127,
        '2020-12-11 08:00:00+03',
        '2020-12-11 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1128,
        '2020-12-11 05:00:00+03',
        '2020-12-11 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1129,
        '2020-12-11 06:00:00+03',
        '2020-12-11 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        1130,
        '2020-12-11 05:00:00+03',
        '2020-12-11 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1131,
        '2020-12-11 05:00:00+03',
        '2020-12-11 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1132,
        '2020-12-11 06:00:00+03',
        '2020-12-11 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1133,
        '2020-12-11 09:00:00+03',
        '2020-12-11 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1134,
        '2020-12-11 10:00:00+03',
        '2020-12-11 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1135,
        '2020-12-11 10:00:00+03',
        '2020-12-11 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1136,
        '2020-12-11 12:00:00+03',
        '2020-12-11 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1137,
        '2020-12-11 11:00:00+03',
        '2020-12-11 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1138,
        '2020-12-11 12:00:00+03',
        '2020-12-11 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1139,
        '2020-12-11 11:00:00+03',
        '2020-12-11 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1140,
        '2020-12-11 12:00:00+03',
        '2020-12-11 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1141,
        '2020-12-11 09:00:00+03',
        '2020-12-11 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1142,
        '2020-12-11 10:00:00+03',
        '2020-12-11 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1143,
        '2020-12-11 12:00:00+03',
        '2020-12-11 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1144,
        '2020-12-11 12:00:00+03',
        '2020-12-11 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1145,
        '2020-12-11 10:00:00+03',
        '2020-12-11 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1146,
        '2020-12-11 11:00:00+03',
        '2020-12-11 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1147,
        '2020-12-11 14:00:00+03',
        '2020-12-11 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1148,
        '2020-12-11 12:00:00+03',
        '2020-12-11 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1149,
        '2020-12-11 12:00:00+03',
        '2020-12-11 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1150,
        '2020-12-11 13:00:00+03',
        '2020-12-11 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1151,
        '2020-12-11 15:00:00+03',
        '2020-12-11 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1152,
        '2020-12-11 16:00:00+03',
        '2020-12-11 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1153,
        '2020-12-11 16:00:00+03',
        '2020-12-11 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1154,
        '2020-12-11 15:00:00+03',
        '2020-12-11 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1155,
        '2020-12-11 15:00:00+03',
        '2020-12-11 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1156,
        '2020-12-11 19:00:00+03',
        '2020-12-11 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1157,
        '2020-12-11 17:00:00+03',
        '2020-12-11 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1158,
        '2020-12-11 17:00:00+03',
        '2020-12-11 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1159,
        '2020-12-11 15:00:00+03',
        '2020-12-11 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1160,
        '2020-12-11 15:00:00+03',
        '2020-12-11 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1161,
        '2020-12-11 17:00:00+03',
        '2020-12-11 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1162,
        '2020-12-11 16:00:00+03',
        '2020-12-11 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1163,
        '2020-12-11 17:00:00+03',
        '2020-12-11 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1164,
        '2020-12-11 16:00:00+03',
        '2020-12-11 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1165,
        '2020-12-11 17:00:00+03',
        '2020-12-11 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        1166,
        '2020-12-11 19:00:00+03',
        '2020-12-11 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1167,
        '2020-12-11 20:00:00+03',
        '2020-12-11 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1168,
        '2020-12-11 20:00:00+03',
        '2020-12-11 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1169,
        '2020-12-11 22:00:00+03',
        '2020-12-11 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1170,
        '2020-12-11 19:00:00+03',
        '2020-12-11 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1171,
        '2020-12-11 18:00:00+03',
        '2020-12-11 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1172,
        '2020-12-11 21:00:00+03',
        '2020-12-11 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1173,
        '2020-12-11 21:00:00+03',
        '2020-12-11 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1174,
        '2020-12-11 21:00:00+03',
        '2020-12-11 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1175,
        '2020-12-11 18:00:00+03',
        '2020-12-11 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1176,
        '2020-12-11 21:00:00+03',
        '2020-12-11 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1177,
        '2020-12-11 18:00:00+03',
        '2020-12-11 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1178,
        '2020-12-11 21:00:00+03',
        '2020-12-11 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1179,
        '2020-12-11 19:00:00+03',
        '2020-12-11 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1180,
        '2020-12-11 22:00:00+03',
        '2020-12-11 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1181,
        '2020-12-11 19:00:00+03',
        '2020-12-11 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1182,
        '2020-12-11 22:00:00+03',
        '2020-12-11 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1201,
        '2020-12-12 00:00:00+03',
        '2020-12-12 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1202,
        '2020-12-12 00:00:00+03',
        '2020-12-12 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1203,
        '2020-12-12 01:00:00+03',
        '2020-12-12 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1204,
        '2020-12-12 01:00:00+03',
        '2020-12-12 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1205,
        '2020-12-12 01:00:00+03',
        '2020-12-12 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1206,
        '2020-12-12 01:00:00+03',
        '2020-12-12 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1207,
        '2020-12-12 01:00:00+03',
        '2020-12-12 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1208,
        '2020-12-12 01:00:00+03',
        '2020-12-12 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1209,
        '2020-12-12 01:00:00+03',
        '2020-12-12 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1210,
        '2020-12-12 01:00:00+03',
        '2020-12-12 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1211,
        '2020-12-12 01:00:00+03',
        '2020-12-12 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1212,
        '2020-12-12 01:00:00+03',
        '2020-12-12 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        1213,
        '2020-12-12 01:00:00+03',
        '2020-12-12 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1214,
        '2020-12-12 01:00:00+03',
        '2020-12-12 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1215,
        '2020-12-12 01:00:00+03',
        '2020-12-12 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        1216,
        '2020-12-12 05:00:00+03',
        '2020-12-12 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1217,
        '2020-12-12 04:00:00+03',
        '2020-12-12 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1218,
        '2020-12-12 06:00:00+03',
        '2020-12-12 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1219,
        '2020-12-12 05:00:00+03',
        '2020-12-12 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1220,
        '2020-12-12 06:00:00+03',
        '2020-12-12 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1221,
        '2020-12-12 05:00:00+03',
        '2020-12-12 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1222,
        '2020-12-12 08:00:00+03',
        '2020-12-12 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1223,
        '2020-12-12 09:00:00+03',
        '2020-12-12 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1224,
        '2020-12-12 04:00:00+03',
        '2020-12-12 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1225,
        '2020-12-12 05:00:00+03',
        '2020-12-12 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1226,
        '2020-12-12 08:00:00+03',
        '2020-12-12 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1227,
        '2020-12-12 08:00:00+03',
        '2020-12-12 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1228,
        '2020-12-12 05:00:00+03',
        '2020-12-12 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1229,
        '2020-12-12 06:00:00+03',
        '2020-12-12 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        1230,
        '2020-12-12 05:00:00+03',
        '2020-12-12 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1231,
        '2020-12-12 05:00:00+03',
        '2020-12-12 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1232,
        '2020-12-12 06:00:00+03',
        '2020-12-12 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1233,
        '2020-12-12 09:00:00+03',
        '2020-12-12 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1234,
        '2020-12-12 10:00:00+03',
        '2020-12-12 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1235,
        '2020-12-12 10:00:00+03',
        '2020-12-12 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1236,
        '2020-12-12 12:00:00+03',
        '2020-12-12 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1237,
        '2020-12-12 11:00:00+03',
        '2020-12-12 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1238,
        '2020-12-12 12:00:00+03',
        '2020-12-12 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1239,
        '2020-12-12 11:00:00+03',
        '2020-12-12 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1240,
        '2020-12-12 12:00:00+03',
        '2020-12-12 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1241,
        '2020-12-12 09:00:00+03',
        '2020-12-12 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1242,
        '2020-12-12 10:00:00+03',
        '2020-12-12 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1243,
        '2020-12-12 12:00:00+03',
        '2020-12-12 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1244,
        '2020-12-12 12:00:00+03',
        '2020-12-12 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1245,
        '2020-12-12 10:00:00+03',
        '2020-12-12 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1246,
        '2020-12-12 11:00:00+03',
        '2020-12-12 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1247,
        '2020-12-12 14:00:00+03',
        '2020-12-12 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1248,
        '2020-12-12 12:00:00+03',
        '2020-12-12 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1249,
        '2020-12-12 12:00:00+03',
        '2020-12-12 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1250,
        '2020-12-12 13:00:00+03',
        '2020-12-12 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1251,
        '2020-12-12 15:00:00+03',
        '2020-12-12 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1252,
        '2020-12-12 16:00:00+03',
        '2020-12-12 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1253,
        '2020-12-12 16:00:00+03',
        '2020-12-12 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1254,
        '2020-12-12 15:00:00+03',
        '2020-12-12 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1255,
        '2020-12-12 15:00:00+03',
        '2020-12-12 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1256,
        '2020-12-12 19:00:00+03',
        '2020-12-12 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1257,
        '2020-12-12 17:00:00+03',
        '2020-12-12 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1258,
        '2020-12-12 17:00:00+03',
        '2020-12-12 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1259,
        '2020-12-12 15:00:00+03',
        '2020-12-12 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1260,
        '2020-12-12 15:00:00+03',
        '2020-12-12 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1261,
        '2020-12-12 17:00:00+03',
        '2020-12-12 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1262,
        '2020-12-12 16:00:00+03',
        '2020-12-12 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1263,
        '2020-12-12 17:00:00+03',
        '2020-12-12 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1264,
        '2020-12-12 16:00:00+03',
        '2020-12-12 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1265,
        '2020-12-12 17:00:00+03',
        '2020-12-12 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        1266,
        '2020-12-12 19:00:00+03',
        '2020-12-12 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1267,
        '2020-12-12 20:00:00+03',
        '2020-12-12 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1268,
        '2020-12-12 20:00:00+03',
        '2020-12-12 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1269,
        '2020-12-12 22:00:00+03',
        '2020-12-12 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1270,
        '2020-12-12 19:00:00+03',
        '2020-12-12 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1271,
        '2020-12-12 18:00:00+03',
        '2020-12-12 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1272,
        '2020-12-12 21:00:00+03',
        '2020-12-12 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1273,
        '2020-12-12 21:00:00+03',
        '2020-12-12 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1274,
        '2020-12-12 21:00:00+03',
        '2020-12-12 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1275,
        '2020-12-12 18:00:00+03',
        '2020-12-12 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1276,
        '2020-12-12 21:00:00+03',
        '2020-12-12 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1277,
        '2020-12-12 18:00:00+03',
        '2020-12-12 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1278,
        '2020-12-12 21:00:00+03',
        '2020-12-12 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1279,
        '2020-12-12 19:00:00+03',
        '2020-12-12 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1280,
        '2020-12-12 22:00:00+03',
        '2020-12-12 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1281,
        '2020-12-12 19:00:00+03',
        '2020-12-12 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1282,
        '2020-12-12 22:00:00+03',
        '2020-12-12 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1301,
        '2020-12-13 00:00:00+03',
        '2020-12-13 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1302,
        '2020-12-13 00:00:00+03',
        '2020-12-13 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1303,
        '2020-12-13 01:00:00+03',
        '2020-12-13 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1304,
        '2020-12-13 01:00:00+03',
        '2020-12-13 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1305,
        '2020-12-13 01:00:00+03',
        '2020-12-13 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1306,
        '2020-12-13 01:00:00+03',
        '2020-12-13 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1307,
        '2020-12-13 01:00:00+03',
        '2020-12-13 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1308,
        '2020-12-13 01:00:00+03',
        '2020-12-13 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1309,
        '2020-12-13 01:00:00+03',
        '2020-12-13 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1310,
        '2020-12-13 01:00:00+03',
        '2020-12-13 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1311,
        '2020-12-13 01:00:00+03',
        '2020-12-13 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1312,
        '2020-12-13 01:00:00+03',
        '2020-12-13 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        1313,
        '2020-12-13 01:00:00+03',
        '2020-12-13 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1314,
        '2020-12-13 01:00:00+03',
        '2020-12-13 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1315,
        '2020-12-13 01:00:00+03',
        '2020-12-13 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        1316,
        '2020-12-13 05:00:00+03',
        '2020-12-13 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1317,
        '2020-12-13 04:00:00+03',
        '2020-12-13 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1318,
        '2020-12-13 06:00:00+03',
        '2020-12-13 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1319,
        '2020-12-13 05:00:00+03',
        '2020-12-13 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1320,
        '2020-12-13 06:00:00+03',
        '2020-12-13 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1321,
        '2020-12-13 05:00:00+03',
        '2020-12-13 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1322,
        '2020-12-13 08:00:00+03',
        '2020-12-13 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1323,
        '2020-12-13 09:00:00+03',
        '2020-12-13 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1324,
        '2020-12-13 04:00:00+03',
        '2020-12-13 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1325,
        '2020-12-13 05:00:00+03',
        '2020-12-13 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1326,
        '2020-12-13 08:00:00+03',
        '2020-12-13 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1327,
        '2020-12-13 08:00:00+03',
        '2020-12-13 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1328,
        '2020-12-13 05:00:00+03',
        '2020-12-13 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1329,
        '2020-12-13 06:00:00+03',
        '2020-12-13 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        1330,
        '2020-12-13 05:00:00+03',
        '2020-12-13 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1331,
        '2020-12-13 05:00:00+03',
        '2020-12-13 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1332,
        '2020-12-13 06:00:00+03',
        '2020-12-13 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1333,
        '2020-12-13 09:00:00+03',
        '2020-12-13 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1334,
        '2020-12-13 10:00:00+03',
        '2020-12-13 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1335,
        '2020-12-13 10:00:00+03',
        '2020-12-13 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1336,
        '2020-12-13 12:00:00+03',
        '2020-12-13 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1337,
        '2020-12-13 11:00:00+03',
        '2020-12-13 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1338,
        '2020-12-13 12:00:00+03',
        '2020-12-13 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1339,
        '2020-12-13 11:00:00+03',
        '2020-12-13 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1340,
        '2020-12-13 12:00:00+03',
        '2020-12-13 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1341,
        '2020-12-13 09:00:00+03',
        '2020-12-13 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1342,
        '2020-12-13 10:00:00+03',
        '2020-12-13 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1343,
        '2020-12-13 12:00:00+03',
        '2020-12-13 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1344,
        '2020-12-13 12:00:00+03',
        '2020-12-13 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1345,
        '2020-12-13 10:00:00+03',
        '2020-12-13 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1346,
        '2020-12-13 11:00:00+03',
        '2020-12-13 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1347,
        '2020-12-13 14:00:00+03',
        '2020-12-13 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1348,
        '2020-12-13 12:00:00+03',
        '2020-12-13 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1349,
        '2020-12-13 12:00:00+03',
        '2020-12-13 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1350,
        '2020-12-13 13:00:00+03',
        '2020-12-13 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1351,
        '2020-12-13 15:00:00+03',
        '2020-12-13 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1352,
        '2020-12-13 16:00:00+03',
        '2020-12-13 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1353,
        '2020-12-13 16:00:00+03',
        '2020-12-13 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1354,
        '2020-12-13 15:00:00+03',
        '2020-12-13 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1355,
        '2020-12-13 15:00:00+03',
        '2020-12-13 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1356,
        '2020-12-13 19:00:00+03',
        '2020-12-13 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1357,
        '2020-12-13 17:00:00+03',
        '2020-12-13 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1358,
        '2020-12-13 17:00:00+03',
        '2020-12-13 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1359,
        '2020-12-13 15:00:00+03',
        '2020-12-13 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1360,
        '2020-12-13 15:00:00+03',
        '2020-12-13 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1361,
        '2020-12-13 17:00:00+03',
        '2020-12-13 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1362,
        '2020-12-13 16:00:00+03',
        '2020-12-13 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1363,
        '2020-12-13 17:00:00+03',
        '2020-12-13 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1364,
        '2020-12-13 16:00:00+03',
        '2020-12-13 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1365,
        '2020-12-13 17:00:00+03',
        '2020-12-13 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        1366,
        '2020-12-13 19:00:00+03',
        '2020-12-13 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1367,
        '2020-12-13 20:00:00+03',
        '2020-12-13 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1368,
        '2020-12-13 20:00:00+03',
        '2020-12-13 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1369,
        '2020-12-13 22:00:00+03',
        '2020-12-13 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1370,
        '2020-12-13 19:00:00+03',
        '2020-12-13 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1371,
        '2020-12-13 18:00:00+03',
        '2020-12-13 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1372,
        '2020-12-13 21:00:00+03',
        '2020-12-13 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1373,
        '2020-12-13 21:00:00+03',
        '2020-12-13 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1374,
        '2020-12-13 21:00:00+03',
        '2020-12-13 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1375,
        '2020-12-13 18:00:00+03',
        '2020-12-13 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1376,
        '2020-12-13 21:00:00+03',
        '2020-12-13 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1377,
        '2020-12-13 18:00:00+03',
        '2020-12-13 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1378,
        '2020-12-13 21:00:00+03',
        '2020-12-13 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1379,
        '2020-12-13 19:00:00+03',
        '2020-12-13 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1380,
        '2020-12-13 22:00:00+03',
        '2020-12-13 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1381,
        '2020-12-13 19:00:00+03',
        '2020-12-13 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1382,
        '2020-12-13 22:00:00+03',
        '2020-12-13 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1401,
        '2020-12-14 00:00:00+03',
        '2020-12-14 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1402,
        '2020-12-14 00:00:00+03',
        '2020-12-14 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1403,
        '2020-12-14 01:00:00+03',
        '2020-12-14 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1404,
        '2020-12-14 01:00:00+03',
        '2020-12-14 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1405,
        '2020-12-14 01:00:00+03',
        '2020-12-14 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1406,
        '2020-12-14 01:00:00+03',
        '2020-12-14 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1407,
        '2020-12-14 01:00:00+03',
        '2020-12-14 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1408,
        '2020-12-14 01:00:00+03',
        '2020-12-14 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1409,
        '2020-12-14 01:00:00+03',
        '2020-12-14 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1410,
        '2020-12-14 01:00:00+03',
        '2020-12-14 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1411,
        '2020-12-14 01:00:00+03',
        '2020-12-14 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1412,
        '2020-12-14 01:00:00+03',
        '2020-12-14 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        1413,
        '2020-12-14 01:00:00+03',
        '2020-12-14 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1414,
        '2020-12-14 01:00:00+03',
        '2020-12-14 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1415,
        '2020-12-14 01:00:00+03',
        '2020-12-14 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        1416,
        '2020-12-14 05:00:00+03',
        '2020-12-14 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1417,
        '2020-12-14 04:00:00+03',
        '2020-12-14 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1418,
        '2020-12-14 06:00:00+03',
        '2020-12-14 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1419,
        '2020-12-14 05:00:00+03',
        '2020-12-14 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1420,
        '2020-12-14 06:00:00+03',
        '2020-12-14 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1421,
        '2020-12-14 05:00:00+03',
        '2020-12-14 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1422,
        '2020-12-14 08:00:00+03',
        '2020-12-14 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1423,
        '2020-12-14 09:00:00+03',
        '2020-12-14 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1424,
        '2020-12-14 04:00:00+03',
        '2020-12-14 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1425,
        '2020-12-14 05:00:00+03',
        '2020-12-14 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1426,
        '2020-12-14 08:00:00+03',
        '2020-12-14 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1427,
        '2020-12-14 08:00:00+03',
        '2020-12-14 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1428,
        '2020-12-14 05:00:00+03',
        '2020-12-14 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1429,
        '2020-12-14 06:00:00+03',
        '2020-12-14 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        1430,
        '2020-12-14 05:00:00+03',
        '2020-12-14 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1431,
        '2020-12-14 05:00:00+03',
        '2020-12-14 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1432,
        '2020-12-14 06:00:00+03',
        '2020-12-14 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1433,
        '2020-12-14 09:00:00+03',
        '2020-12-14 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1434,
        '2020-12-14 10:00:00+03',
        '2020-12-14 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1435,
        '2020-12-14 10:00:00+03',
        '2020-12-14 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1436,
        '2020-12-14 12:00:00+03',
        '2020-12-14 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1437,
        '2020-12-14 11:00:00+03',
        '2020-12-14 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1438,
        '2020-12-14 12:00:00+03',
        '2020-12-14 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1439,
        '2020-12-14 11:00:00+03',
        '2020-12-14 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1440,
        '2020-12-14 12:00:00+03',
        '2020-12-14 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1441,
        '2020-12-14 09:00:00+03',
        '2020-12-14 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1442,
        '2020-12-14 10:00:00+03',
        '2020-12-14 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1443,
        '2020-12-14 12:00:00+03',
        '2020-12-14 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1444,
        '2020-12-14 12:00:00+03',
        '2020-12-14 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1445,
        '2020-12-14 10:00:00+03',
        '2020-12-14 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1446,
        '2020-12-14 11:00:00+03',
        '2020-12-14 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1447,
        '2020-12-14 14:00:00+03',
        '2020-12-14 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1448,
        '2020-12-14 12:00:00+03',
        '2020-12-14 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1449,
        '2020-12-14 12:00:00+03',
        '2020-12-14 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1450,
        '2020-12-14 13:00:00+03',
        '2020-12-14 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1451,
        '2020-12-14 15:00:00+03',
        '2020-12-14 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1452,
        '2020-12-14 16:00:00+03',
        '2020-12-14 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1453,
        '2020-12-14 16:00:00+03',
        '2020-12-14 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1454,
        '2020-12-14 15:00:00+03',
        '2020-12-14 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1455,
        '2020-12-14 15:00:00+03',
        '2020-12-14 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1456,
        '2020-12-14 19:00:00+03',
        '2020-12-14 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1457,
        '2020-12-14 17:00:00+03',
        '2020-12-14 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1458,
        '2020-12-14 17:00:00+03',
        '2020-12-14 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1459,
        '2020-12-14 15:00:00+03',
        '2020-12-14 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1460,
        '2020-12-14 15:00:00+03',
        '2020-12-14 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1461,
        '2020-12-14 17:00:00+03',
        '2020-12-14 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1462,
        '2020-12-14 16:00:00+03',
        '2020-12-14 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1463,
        '2020-12-14 17:00:00+03',
        '2020-12-14 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1464,
        '2020-12-14 16:00:00+03',
        '2020-12-14 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1465,
        '2020-12-14 17:00:00+03',
        '2020-12-14 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        1466,
        '2020-12-14 19:00:00+03',
        '2020-12-14 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1467,
        '2020-12-14 20:00:00+03',
        '2020-12-14 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1468,
        '2020-12-14 20:00:00+03',
        '2020-12-14 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1469,
        '2020-12-14 22:00:00+03',
        '2020-12-14 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1470,
        '2020-12-14 19:00:00+03',
        '2020-12-14 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1471,
        '2020-12-14 18:00:00+03',
        '2020-12-14 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1472,
        '2020-12-14 21:00:00+03',
        '2020-12-14 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1473,
        '2020-12-14 21:00:00+03',
        '2020-12-14 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1474,
        '2020-12-14 21:00:00+03',
        '2020-12-14 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1475,
        '2020-12-14 18:00:00+03',
        '2020-12-14 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1476,
        '2020-12-14 21:00:00+03',
        '2020-12-14 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1477,
        '2020-12-14 18:00:00+03',
        '2020-12-14 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1478,
        '2020-12-14 21:00:00+03',
        '2020-12-14 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1479,
        '2020-12-14 19:00:00+03',
        '2020-12-14 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1480,
        '2020-12-14 22:00:00+03',
        '2020-12-14 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1481,
        '2020-12-14 19:00:00+03',
        '2020-12-14 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1482,
        '2020-12-14 22:00:00+03',
        '2020-12-14 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1501,
        '2020-12-15 00:00:00+03',
        '2020-12-15 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1502,
        '2020-12-15 00:00:00+03',
        '2020-12-15 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1503,
        '2020-12-15 01:00:00+03',
        '2020-12-15 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1504,
        '2020-12-15 01:00:00+03',
        '2020-12-15 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1505,
        '2020-12-15 01:00:00+03',
        '2020-12-15 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1506,
        '2020-12-15 01:00:00+03',
        '2020-12-15 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1507,
        '2020-12-15 01:00:00+03',
        '2020-12-15 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1508,
        '2020-12-15 01:00:00+03',
        '2020-12-15 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1509,
        '2020-12-15 01:00:00+03',
        '2020-12-15 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1510,
        '2020-12-15 01:00:00+03',
        '2020-12-15 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1511,
        '2020-12-15 01:00:00+03',
        '2020-12-15 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1512,
        '2020-12-15 01:00:00+03',
        '2020-12-15 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        1513,
        '2020-12-15 01:00:00+03',
        '2020-12-15 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1514,
        '2020-12-15 01:00:00+03',
        '2020-12-15 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1515,
        '2020-12-15 01:00:00+03',
        '2020-12-15 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        1516,
        '2020-12-15 05:00:00+03',
        '2020-12-15 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1517,
        '2020-12-15 04:00:00+03',
        '2020-12-15 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1518,
        '2020-12-15 06:00:00+03',
        '2020-12-15 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1519,
        '2020-12-15 05:00:00+03',
        '2020-12-15 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1520,
        '2020-12-15 06:00:00+03',
        '2020-12-15 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1521,
        '2020-12-15 05:00:00+03',
        '2020-12-15 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1522,
        '2020-12-15 08:00:00+03',
        '2020-12-15 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1523,
        '2020-12-15 09:00:00+03',
        '2020-12-15 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1524,
        '2020-12-15 04:00:00+03',
        '2020-12-15 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1525,
        '2020-12-15 05:00:00+03',
        '2020-12-15 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1526,
        '2020-12-15 08:00:00+03',
        '2020-12-15 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1527,
        '2020-12-15 08:00:00+03',
        '2020-12-15 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1528,
        '2020-12-15 05:00:00+03',
        '2020-12-15 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1529,
        '2020-12-15 06:00:00+03',
        '2020-12-15 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        1530,
        '2020-12-15 05:00:00+03',
        '2020-12-15 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1531,
        '2020-12-15 05:00:00+03',
        '2020-12-15 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1532,
        '2020-12-15 06:00:00+03',
        '2020-12-15 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1533,
        '2020-12-15 09:00:00+03',
        '2020-12-15 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1534,
        '2020-12-15 10:00:00+03',
        '2020-12-15 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1535,
        '2020-12-15 10:00:00+03',
        '2020-12-15 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1536,
        '2020-12-15 12:00:00+03',
        '2020-12-15 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1537,
        '2020-12-15 11:00:00+03',
        '2020-12-15 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1538,
        '2020-12-15 12:00:00+03',
        '2020-12-15 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1539,
        '2020-12-15 11:00:00+03',
        '2020-12-15 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1540,
        '2020-12-15 12:00:00+03',
        '2020-12-15 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1541,
        '2020-12-15 09:00:00+03',
        '2020-12-15 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1542,
        '2020-12-15 10:00:00+03',
        '2020-12-15 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1543,
        '2020-12-15 12:00:00+03',
        '2020-12-15 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1544,
        '2020-12-15 12:00:00+03',
        '2020-12-15 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1545,
        '2020-12-15 10:00:00+03',
        '2020-12-15 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1546,
        '2020-12-15 11:00:00+03',
        '2020-12-15 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1547,
        '2020-12-15 14:00:00+03',
        '2020-12-15 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1548,
        '2020-12-15 12:00:00+03',
        '2020-12-15 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1549,
        '2020-12-15 12:00:00+03',
        '2020-12-15 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1550,
        '2020-12-15 13:00:00+03',
        '2020-12-15 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1551,
        '2020-12-15 15:00:00+03',
        '2020-12-15 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1552,
        '2020-12-15 16:00:00+03',
        '2020-12-15 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1553,
        '2020-12-15 16:00:00+03',
        '2020-12-15 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1554,
        '2020-12-15 15:00:00+03',
        '2020-12-15 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1555,
        '2020-12-15 15:00:00+03',
        '2020-12-15 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1556,
        '2020-12-15 19:00:00+03',
        '2020-12-15 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1557,
        '2020-12-15 17:00:00+03',
        '2020-12-15 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1558,
        '2020-12-15 17:00:00+03',
        '2020-12-15 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1559,
        '2020-12-15 15:00:00+03',
        '2020-12-15 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1560,
        '2020-12-15 15:00:00+03',
        '2020-12-15 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1561,
        '2020-12-15 17:00:00+03',
        '2020-12-15 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1562,
        '2020-12-15 16:00:00+03',
        '2020-12-15 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1563,
        '2020-12-15 17:00:00+03',
        '2020-12-15 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1564,
        '2020-12-15 16:00:00+03',
        '2020-12-15 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1565,
        '2020-12-15 17:00:00+03',
        '2020-12-15 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        1566,
        '2020-12-15 19:00:00+03',
        '2020-12-15 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1567,
        '2020-12-15 20:00:00+03',
        '2020-12-15 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1568,
        '2020-12-15 20:00:00+03',
        '2020-12-15 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1569,
        '2020-12-15 22:00:00+03',
        '2020-12-15 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1570,
        '2020-12-15 19:00:00+03',
        '2020-12-15 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1571,
        '2020-12-15 18:00:00+03',
        '2020-12-15 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1572,
        '2020-12-15 21:00:00+03',
        '2020-12-15 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1573,
        '2020-12-15 21:00:00+03',
        '2020-12-15 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1574,
        '2020-12-15 21:00:00+03',
        '2020-12-15 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1575,
        '2020-12-15 18:00:00+03',
        '2020-12-15 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1576,
        '2020-12-15 21:00:00+03',
        '2020-12-15 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1577,
        '2020-12-15 18:00:00+03',
        '2020-12-15 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1578,
        '2020-12-15 21:00:00+03',
        '2020-12-15 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1579,
        '2020-12-15 19:00:00+03',
        '2020-12-15 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1580,
        '2020-12-15 22:00:00+03',
        '2020-12-15 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1581,
        '2020-12-15 19:00:00+03',
        '2020-12-15 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1582,
        '2020-12-15 22:00:00+03',
        '2020-12-15 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1601,
        '2020-12-16 00:00:00+03',
        '2020-12-16 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1602,
        '2020-12-16 00:00:00+03',
        '2020-12-16 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1603,
        '2020-12-16 01:00:00+03',
        '2020-12-16 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1604,
        '2020-12-16 01:00:00+03',
        '2020-12-16 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1605,
        '2020-12-16 01:00:00+03',
        '2020-12-16 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1606,
        '2020-12-16 01:00:00+03',
        '2020-12-16 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1607,
        '2020-12-16 01:00:00+03',
        '2020-12-16 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1608,
        '2020-12-16 01:00:00+03',
        '2020-12-16 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1609,
        '2020-12-16 01:00:00+03',
        '2020-12-16 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1610,
        '2020-12-16 01:00:00+03',
        '2020-12-16 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1611,
        '2020-12-16 01:00:00+03',
        '2020-12-16 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1612,
        '2020-12-16 01:00:00+03',
        '2020-12-16 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        1613,
        '2020-12-16 01:00:00+03',
        '2020-12-16 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1614,
        '2020-12-16 01:00:00+03',
        '2020-12-16 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1615,
        '2020-12-16 01:00:00+03',
        '2020-12-16 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        1616,
        '2020-12-16 05:00:00+03',
        '2020-12-16 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1617,
        '2020-12-16 04:00:00+03',
        '2020-12-16 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1618,
        '2020-12-16 06:00:00+03',
        '2020-12-16 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1619,
        '2020-12-16 05:00:00+03',
        '2020-12-16 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1620,
        '2020-12-16 06:00:00+03',
        '2020-12-16 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1621,
        '2020-12-16 05:00:00+03',
        '2020-12-16 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1622,
        '2020-12-16 08:00:00+03',
        '2020-12-16 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1623,
        '2020-12-16 09:00:00+03',
        '2020-12-16 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1624,
        '2020-12-16 04:00:00+03',
        '2020-12-16 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1625,
        '2020-12-16 05:00:00+03',
        '2020-12-16 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1626,
        '2020-12-16 08:00:00+03',
        '2020-12-16 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1627,
        '2020-12-16 08:00:00+03',
        '2020-12-16 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1628,
        '2020-12-16 05:00:00+03',
        '2020-12-16 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1629,
        '2020-12-16 06:00:00+03',
        '2020-12-16 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        1630,
        '2020-12-16 05:00:00+03',
        '2020-12-16 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1631,
        '2020-12-16 05:00:00+03',
        '2020-12-16 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1632,
        '2020-12-16 06:00:00+03',
        '2020-12-16 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1633,
        '2020-12-16 09:00:00+03',
        '2020-12-16 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1634,
        '2020-12-16 10:00:00+03',
        '2020-12-16 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1635,
        '2020-12-16 10:00:00+03',
        '2020-12-16 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1636,
        '2020-12-16 12:00:00+03',
        '2020-12-16 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1637,
        '2020-12-16 11:00:00+03',
        '2020-12-16 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1638,
        '2020-12-16 12:00:00+03',
        '2020-12-16 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1639,
        '2020-12-16 11:00:00+03',
        '2020-12-16 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1640,
        '2020-12-16 12:00:00+03',
        '2020-12-16 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1641,
        '2020-12-16 09:00:00+03',
        '2020-12-16 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1642,
        '2020-12-16 10:00:00+03',
        '2020-12-16 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1643,
        '2020-12-16 12:00:00+03',
        '2020-12-16 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1644,
        '2020-12-16 12:00:00+03',
        '2020-12-16 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1645,
        '2020-12-16 10:00:00+03',
        '2020-12-16 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1646,
        '2020-12-16 11:00:00+03',
        '2020-12-16 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1647,
        '2020-12-16 14:00:00+03',
        '2020-12-16 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1648,
        '2020-12-16 12:00:00+03',
        '2020-12-16 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1649,
        '2020-12-16 12:00:00+03',
        '2020-12-16 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1650,
        '2020-12-16 13:00:00+03',
        '2020-12-16 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1651,
        '2020-12-16 15:00:00+03',
        '2020-12-16 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1652,
        '2020-12-16 16:00:00+03',
        '2020-12-16 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1653,
        '2020-12-16 16:00:00+03',
        '2020-12-16 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1654,
        '2020-12-16 15:00:00+03',
        '2020-12-16 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1655,
        '2020-12-16 15:00:00+03',
        '2020-12-16 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1656,
        '2020-12-16 19:00:00+03',
        '2020-12-16 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1657,
        '2020-12-16 17:00:00+03',
        '2020-12-16 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1658,
        '2020-12-16 17:00:00+03',
        '2020-12-16 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1659,
        '2020-12-16 15:00:00+03',
        '2020-12-16 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1660,
        '2020-12-16 15:00:00+03',
        '2020-12-16 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1661,
        '2020-12-16 17:00:00+03',
        '2020-12-16 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1662,
        '2020-12-16 16:00:00+03',
        '2020-12-16 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1663,
        '2020-12-16 17:00:00+03',
        '2020-12-16 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1664,
        '2020-12-16 16:00:00+03',
        '2020-12-16 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1665,
        '2020-12-16 17:00:00+03',
        '2020-12-16 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        1666,
        '2020-12-16 19:00:00+03',
        '2020-12-16 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1667,
        '2020-12-16 20:00:00+03',
        '2020-12-16 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1668,
        '2020-12-16 20:00:00+03',
        '2020-12-16 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1669,
        '2020-12-16 22:00:00+03',
        '2020-12-16 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1670,
        '2020-12-16 19:00:00+03',
        '2020-12-16 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1671,
        '2020-12-16 18:00:00+03',
        '2020-12-16 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1672,
        '2020-12-16 21:00:00+03',
        '2020-12-16 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1673,
        '2020-12-16 21:00:00+03',
        '2020-12-16 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1674,
        '2020-12-16 21:00:00+03',
        '2020-12-16 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1675,
        '2020-12-16 18:00:00+03',
        '2020-12-16 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1676,
        '2020-12-16 21:00:00+03',
        '2020-12-16 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1677,
        '2020-12-16 18:00:00+03',
        '2020-12-16 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1678,
        '2020-12-16 21:00:00+03',
        '2020-12-16 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1679,
        '2020-12-16 19:00:00+03',
        '2020-12-16 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1680,
        '2020-12-16 22:00:00+03',
        '2020-12-16 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1681,
        '2020-12-16 19:00:00+03',
        '2020-12-16 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1682,
        '2020-12-16 22:00:00+03',
        '2020-12-16 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1701,
        '2020-12-17 00:00:00+03',
        '2020-12-17 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1702,
        '2020-12-17 00:00:00+03',
        '2020-12-17 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1703,
        '2020-12-17 01:00:00+03',
        '2020-12-17 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1704,
        '2020-12-17 01:00:00+03',
        '2020-12-17 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1705,
        '2020-12-17 01:00:00+03',
        '2020-12-17 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1706,
        '2020-12-17 01:00:00+03',
        '2020-12-17 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1707,
        '2020-12-17 01:00:00+03',
        '2020-12-17 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1708,
        '2020-12-17 01:00:00+03',
        '2020-12-17 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1709,
        '2020-12-17 01:00:00+03',
        '2020-12-17 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1710,
        '2020-12-17 01:00:00+03',
        '2020-12-17 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1711,
        '2020-12-17 01:00:00+03',
        '2020-12-17 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1712,
        '2020-12-17 01:00:00+03',
        '2020-12-17 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        1713,
        '2020-12-17 01:00:00+03',
        '2020-12-17 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1714,
        '2020-12-17 01:00:00+03',
        '2020-12-17 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1715,
        '2020-12-17 01:00:00+03',
        '2020-12-17 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        1716,
        '2020-12-17 05:00:00+03',
        '2020-12-17 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1717,
        '2020-12-17 04:00:00+03',
        '2020-12-17 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1718,
        '2020-12-17 06:00:00+03',
        '2020-12-17 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1719,
        '2020-12-17 05:00:00+03',
        '2020-12-17 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1720,
        '2020-12-17 06:00:00+03',
        '2020-12-17 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1721,
        '2020-12-17 05:00:00+03',
        '2020-12-17 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1722,
        '2020-12-17 08:00:00+03',
        '2020-12-17 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1723,
        '2020-12-17 09:00:00+03',
        '2020-12-17 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1724,
        '2020-12-17 04:00:00+03',
        '2020-12-17 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1725,
        '2020-12-17 05:00:00+03',
        '2020-12-17 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1726,
        '2020-12-17 08:00:00+03',
        '2020-12-17 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1727,
        '2020-12-17 08:00:00+03',
        '2020-12-17 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1728,
        '2020-12-17 05:00:00+03',
        '2020-12-17 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1729,
        '2020-12-17 06:00:00+03',
        '2020-12-17 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        1730,
        '2020-12-17 05:00:00+03',
        '2020-12-17 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1731,
        '2020-12-17 05:00:00+03',
        '2020-12-17 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1732,
        '2020-12-17 06:00:00+03',
        '2020-12-17 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1733,
        '2020-12-17 09:00:00+03',
        '2020-12-17 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1734,
        '2020-12-17 10:00:00+03',
        '2020-12-17 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1735,
        '2020-12-17 10:00:00+03',
        '2020-12-17 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1736,
        '2020-12-17 12:00:00+03',
        '2020-12-17 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1737,
        '2020-12-17 11:00:00+03',
        '2020-12-17 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1738,
        '2020-12-17 12:00:00+03',
        '2020-12-17 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1739,
        '2020-12-17 11:00:00+03',
        '2020-12-17 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1740,
        '2020-12-17 12:00:00+03',
        '2020-12-17 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1741,
        '2020-12-17 09:00:00+03',
        '2020-12-17 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1742,
        '2020-12-17 10:00:00+03',
        '2020-12-17 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1743,
        '2020-12-17 12:00:00+03',
        '2020-12-17 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1744,
        '2020-12-17 12:00:00+03',
        '2020-12-17 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1745,
        '2020-12-17 10:00:00+03',
        '2020-12-17 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1746,
        '2020-12-17 11:00:00+03',
        '2020-12-17 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1747,
        '2020-12-17 14:00:00+03',
        '2020-12-17 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1748,
        '2020-12-17 12:00:00+03',
        '2020-12-17 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1749,
        '2020-12-17 12:00:00+03',
        '2020-12-17 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1750,
        '2020-12-17 13:00:00+03',
        '2020-12-17 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1751,
        '2020-12-17 15:00:00+03',
        '2020-12-17 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1752,
        '2020-12-17 16:00:00+03',
        '2020-12-17 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1753,
        '2020-12-17 16:00:00+03',
        '2020-12-17 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1754,
        '2020-12-17 15:00:00+03',
        '2020-12-17 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1755,
        '2020-12-17 15:00:00+03',
        '2020-12-17 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1756,
        '2020-12-17 19:00:00+03',
        '2020-12-17 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1757,
        '2020-12-17 17:00:00+03',
        '2020-12-17 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1758,
        '2020-12-17 17:00:00+03',
        '2020-12-17 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1759,
        '2020-12-17 15:00:00+03',
        '2020-12-17 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1760,
        '2020-12-17 15:00:00+03',
        '2020-12-17 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1761,
        '2020-12-17 17:00:00+03',
        '2020-12-17 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1762,
        '2020-12-17 16:00:00+03',
        '2020-12-17 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1763,
        '2020-12-17 17:00:00+03',
        '2020-12-17 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1764,
        '2020-12-17 16:00:00+03',
        '2020-12-17 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1765,
        '2020-12-17 17:00:00+03',
        '2020-12-17 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        1766,
        '2020-12-17 19:00:00+03',
        '2020-12-17 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1767,
        '2020-12-17 20:00:00+03',
        '2020-12-17 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1768,
        '2020-12-17 20:00:00+03',
        '2020-12-17 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1769,
        '2020-12-17 22:00:00+03',
        '2020-12-17 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1770,
        '2020-12-17 19:00:00+03',
        '2020-12-17 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1771,
        '2020-12-17 18:00:00+03',
        '2020-12-17 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1772,
        '2020-12-17 21:00:00+03',
        '2020-12-17 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1773,
        '2020-12-17 21:00:00+03',
        '2020-12-17 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1774,
        '2020-12-17 21:00:00+03',
        '2020-12-17 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1775,
        '2020-12-17 18:00:00+03',
        '2020-12-17 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1776,
        '2020-12-17 21:00:00+03',
        '2020-12-17 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1777,
        '2020-12-17 18:00:00+03',
        '2020-12-17 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1778,
        '2020-12-17 21:00:00+03',
        '2020-12-17 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1779,
        '2020-12-17 19:00:00+03',
        '2020-12-17 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1780,
        '2020-12-17 22:00:00+03',
        '2020-12-17 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1781,
        '2020-12-17 19:00:00+03',
        '2020-12-17 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1782,
        '2020-12-17 22:00:00+03',
        '2020-12-17 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1801,
        '2020-12-18 00:00:00+03',
        '2020-12-18 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1802,
        '2020-12-18 00:00:00+03',
        '2020-12-18 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1803,
        '2020-12-18 01:00:00+03',
        '2020-12-18 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1804,
        '2020-12-18 01:00:00+03',
        '2020-12-18 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1805,
        '2020-12-18 01:00:00+03',
        '2020-12-18 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1806,
        '2020-12-18 01:00:00+03',
        '2020-12-18 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1807,
        '2020-12-18 01:00:00+03',
        '2020-12-18 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1808,
        '2020-12-18 01:00:00+03',
        '2020-12-18 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1809,
        '2020-12-18 01:00:00+03',
        '2020-12-18 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1810,
        '2020-12-18 01:00:00+03',
        '2020-12-18 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1811,
        '2020-12-18 01:00:00+03',
        '2020-12-18 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1812,
        '2020-12-18 01:00:00+03',
        '2020-12-18 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        1813,
        '2020-12-18 01:00:00+03',
        '2020-12-18 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1814,
        '2020-12-18 01:00:00+03',
        '2020-12-18 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1815,
        '2020-12-18 01:00:00+03',
        '2020-12-18 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        1816,
        '2020-12-18 05:00:00+03',
        '2020-12-18 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1817,
        '2020-12-18 04:00:00+03',
        '2020-12-18 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1818,
        '2020-12-18 06:00:00+03',
        '2020-12-18 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1819,
        '2020-12-18 05:00:00+03',
        '2020-12-18 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1820,
        '2020-12-18 06:00:00+03',
        '2020-12-18 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1821,
        '2020-12-18 05:00:00+03',
        '2020-12-18 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1822,
        '2020-12-18 08:00:00+03',
        '2020-12-18 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1823,
        '2020-12-18 09:00:00+03',
        '2020-12-18 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1824,
        '2020-12-18 04:00:00+03',
        '2020-12-18 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1825,
        '2020-12-18 05:00:00+03',
        '2020-12-18 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1826,
        '2020-12-18 08:00:00+03',
        '2020-12-18 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1827,
        '2020-12-18 08:00:00+03',
        '2020-12-18 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1828,
        '2020-12-18 05:00:00+03',
        '2020-12-18 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1829,
        '2020-12-18 06:00:00+03',
        '2020-12-18 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        1830,
        '2020-12-18 05:00:00+03',
        '2020-12-18 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1831,
        '2020-12-18 05:00:00+03',
        '2020-12-18 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1832,
        '2020-12-18 06:00:00+03',
        '2020-12-18 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1833,
        '2020-12-18 09:00:00+03',
        '2020-12-18 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1834,
        '2020-12-18 10:00:00+03',
        '2020-12-18 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1835,
        '2020-12-18 10:00:00+03',
        '2020-12-18 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1836,
        '2020-12-18 12:00:00+03',
        '2020-12-18 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1837,
        '2020-12-18 11:00:00+03',
        '2020-12-18 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1838,
        '2020-12-18 12:00:00+03',
        '2020-12-18 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1839,
        '2020-12-18 11:00:00+03',
        '2020-12-18 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1840,
        '2020-12-18 12:00:00+03',
        '2020-12-18 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1841,
        '2020-12-18 09:00:00+03',
        '2020-12-18 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1842,
        '2020-12-18 10:00:00+03',
        '2020-12-18 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1843,
        '2020-12-18 12:00:00+03',
        '2020-12-18 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1844,
        '2020-12-18 12:00:00+03',
        '2020-12-18 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1845,
        '2020-12-18 10:00:00+03',
        '2020-12-18 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1846,
        '2020-12-18 11:00:00+03',
        '2020-12-18 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1847,
        '2020-12-18 14:00:00+03',
        '2020-12-18 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1848,
        '2020-12-18 12:00:00+03',
        '2020-12-18 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1849,
        '2020-12-18 12:00:00+03',
        '2020-12-18 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1850,
        '2020-12-18 13:00:00+03',
        '2020-12-18 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1851,
        '2020-12-18 15:00:00+03',
        '2020-12-18 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1852,
        '2020-12-18 16:00:00+03',
        '2020-12-18 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1853,
        '2020-12-18 16:00:00+03',
        '2020-12-18 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1854,
        '2020-12-18 15:00:00+03',
        '2020-12-18 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1855,
        '2020-12-18 15:00:00+03',
        '2020-12-18 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1856,
        '2020-12-18 19:00:00+03',
        '2020-12-18 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1857,
        '2020-12-18 17:00:00+03',
        '2020-12-18 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1858,
        '2020-12-18 17:00:00+03',
        '2020-12-18 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1859,
        '2020-12-18 15:00:00+03',
        '2020-12-18 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1860,
        '2020-12-18 15:00:00+03',
        '2020-12-18 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1861,
        '2020-12-18 17:00:00+03',
        '2020-12-18 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1862,
        '2020-12-18 16:00:00+03',
        '2020-12-18 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1863,
        '2020-12-18 17:00:00+03',
        '2020-12-18 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1864,
        '2020-12-18 16:00:00+03',
        '2020-12-18 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1865,
        '2020-12-18 17:00:00+03',
        '2020-12-18 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        1866,
        '2020-12-18 19:00:00+03',
        '2020-12-18 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1867,
        '2020-12-18 20:00:00+03',
        '2020-12-18 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1868,
        '2020-12-18 20:00:00+03',
        '2020-12-18 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1869,
        '2020-12-18 22:00:00+03',
        '2020-12-18 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1870,
        '2020-12-18 19:00:00+03',
        '2020-12-18 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1871,
        '2020-12-18 18:00:00+03',
        '2020-12-18 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1872,
        '2020-12-18 21:00:00+03',
        '2020-12-18 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1873,
        '2020-12-18 21:00:00+03',
        '2020-12-18 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1874,
        '2020-12-18 21:00:00+03',
        '2020-12-18 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1875,
        '2020-12-18 18:00:00+03',
        '2020-12-18 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1876,
        '2020-12-18 21:00:00+03',
        '2020-12-18 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1877,
        '2020-12-18 18:00:00+03',
        '2020-12-18 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1878,
        '2020-12-18 21:00:00+03',
        '2020-12-18 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1879,
        '2020-12-18 19:00:00+03',
        '2020-12-18 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1880,
        '2020-12-18 22:00:00+03',
        '2020-12-18 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1881,
        '2020-12-18 19:00:00+03',
        '2020-12-18 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1882,
        '2020-12-18 22:00:00+03',
        '2020-12-18 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  
INSERT INTO MTAMJQ.flights
VALUES (
        1901,
        '2020-12-19 00:00:00+03',
        '2020-12-19 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1902,
        '2020-12-19 00:00:00+03',
        '2020-12-19 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1903,
        '2020-12-19 01:00:00+03',
        '2020-12-19 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1904,
        '2020-12-19 01:00:00+03',
        '2020-12-19 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1905,
        '2020-12-19 01:00:00+03',
        '2020-12-19 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1906,
        '2020-12-19 01:00:00+03',
        '2020-12-19 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1907,
        '2020-12-19 01:00:00+03',
        '2020-12-19 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1908,
        '2020-12-19 01:00:00+03',
        '2020-12-19 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1909,
        '2020-12-19 01:00:00+03',
        '2020-12-19 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1910,
        '2020-12-19 01:00:00+03',
        '2020-12-19 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1911,
        '2020-12-19 01:00:00+03',
        '2020-12-19 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1912,
        '2020-12-19 01:00:00+03',
        '2020-12-19 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        1913,
        '2020-12-19 01:00:00+03',
        '2020-12-19 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1914,
        '2020-12-19 01:00:00+03',
        '2020-12-19 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1915,
        '2020-12-19 01:00:00+03',
        '2020-12-19 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        1916,
        '2020-12-19 05:00:00+03',
        '2020-12-19 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1917,
        '2020-12-19 04:00:00+03',
        '2020-12-19 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1918,
        '2020-12-19 06:00:00+03',
        '2020-12-19 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1919,
        '2020-12-19 05:00:00+03',
        '2020-12-19 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1920,
        '2020-12-19 06:00:00+03',
        '2020-12-19 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1921,
        '2020-12-19 05:00:00+03',
        '2020-12-19 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1922,
        '2020-12-19 08:00:00+03',
        '2020-12-19 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1923,
        '2020-12-19 09:00:00+03',
        '2020-12-19 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1924,
        '2020-12-19 04:00:00+03',
        '2020-12-19 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1925,
        '2020-12-19 05:00:00+03',
        '2020-12-19 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1926,
        '2020-12-19 08:00:00+03',
        '2020-12-19 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1927,
        '2020-12-19 08:00:00+03',
        '2020-12-19 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1928,
        '2020-12-19 05:00:00+03',
        '2020-12-19 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1929,
        '2020-12-19 06:00:00+03',
        '2020-12-19 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        1930,
        '2020-12-19 05:00:00+03',
        '2020-12-19 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1931,
        '2020-12-19 05:00:00+03',
        '2020-12-19 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1932,
        '2020-12-19 06:00:00+03',
        '2020-12-19 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1933,
        '2020-12-19 09:00:00+03',
        '2020-12-19 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1934,
        '2020-12-19 10:00:00+03',
        '2020-12-19 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1935,
        '2020-12-19 10:00:00+03',
        '2020-12-19 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1936,
        '2020-12-19 12:00:00+03',
        '2020-12-19 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1937,
        '2020-12-19 11:00:00+03',
        '2020-12-19 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1938,
        '2020-12-19 12:00:00+03',
        '2020-12-19 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1939,
        '2020-12-19 11:00:00+03',
        '2020-12-19 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1940,
        '2020-12-19 12:00:00+03',
        '2020-12-19 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1941,
        '2020-12-19 09:00:00+03',
        '2020-12-19 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1942,
        '2020-12-19 10:00:00+03',
        '2020-12-19 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1943,
        '2020-12-19 12:00:00+03',
        '2020-12-19 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1944,
        '2020-12-19 12:00:00+03',
        '2020-12-19 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        1945,
        '2020-12-19 10:00:00+03',
        '2020-12-19 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1946,
        '2020-12-19 11:00:00+03',
        '2020-12-19 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1947,
        '2020-12-19 14:00:00+03',
        '2020-12-19 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1948,
        '2020-12-19 12:00:00+03',
        '2020-12-19 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1949,
        '2020-12-19 12:00:00+03',
        '2020-12-19 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1950,
        '2020-12-19 13:00:00+03',
        '2020-12-19 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1951,
        '2020-12-19 15:00:00+03',
        '2020-12-19 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1952,
        '2020-12-19 16:00:00+03',
        '2020-12-19 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1953,
        '2020-12-19 16:00:00+03',
        '2020-12-19 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1954,
        '2020-12-19 15:00:00+03',
        '2020-12-19 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1955,
        '2020-12-19 15:00:00+03',
        '2020-12-19 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1956,
        '2020-12-19 19:00:00+03',
        '2020-12-19 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1957,
        '2020-12-19 17:00:00+03',
        '2020-12-19 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1958,
        '2020-12-19 17:00:00+03',
        '2020-12-19 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1959,
        '2020-12-19 15:00:00+03',
        '2020-12-19 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1960,
        '2020-12-19 15:00:00+03',
        '2020-12-19 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1961,
        '2020-12-19 17:00:00+03',
        '2020-12-19 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1962,
        '2020-12-19 16:00:00+03',
        '2020-12-19 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1963,
        '2020-12-19 17:00:00+03',
        '2020-12-19 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1964,
        '2020-12-19 16:00:00+03',
        '2020-12-19 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1965,
        '2020-12-19 17:00:00+03',
        '2020-12-19 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        1966,
        '2020-12-19 19:00:00+03',
        '2020-12-19 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1967,
        '2020-12-19 20:00:00+03',
        '2020-12-19 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1968,
        '2020-12-19 20:00:00+03',
        '2020-12-19 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1969,
        '2020-12-19 22:00:00+03',
        '2020-12-19 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        1970,
        '2020-12-19 19:00:00+03',
        '2020-12-19 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1971,
        '2020-12-19 18:00:00+03',
        '2020-12-19 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1972,
        '2020-12-19 21:00:00+03',
        '2020-12-19 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1973,
        '2020-12-19 21:00:00+03',
        '2020-12-19 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1974,
        '2020-12-19 21:00:00+03',
        '2020-12-19 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1975,
        '2020-12-19 18:00:00+03',
        '2020-12-19 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1976,
        '2020-12-19 21:00:00+03',
        '2020-12-19 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1977,
        '2020-12-19 18:00:00+03',
        '2020-12-19 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1978,
        '2020-12-19 21:00:00+03',
        '2020-12-19 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1979,
        '2020-12-19 19:00:00+03',
        '2020-12-19 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        1980,
        '2020-12-19 22:00:00+03',
        '2020-12-19 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1981,
        '2020-12-19 19:00:00+03',
        '2020-12-19 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        1982,
        '2020-12-19 22:00:00+03',
        '2020-12-19 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2001,
        '2020-12-20 00:00:00+03',
        '2020-12-20 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2002,
        '2020-12-20 00:00:00+03',
        '2020-12-20 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2003,
        '2020-12-20 01:00:00+03',
        '2020-12-20 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2004,
        '2020-12-20 01:00:00+03',
        '2020-12-20 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2005,
        '2020-12-20 01:00:00+03',
        '2020-12-20 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2006,
        '2020-12-20 01:00:00+03',
        '2020-12-20 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2007,
        '2020-12-20 01:00:00+03',
        '2020-12-20 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2008,
        '2020-12-20 01:00:00+03',
        '2020-12-20 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2009,
        '2020-12-20 01:00:00+03',
        '2020-12-20 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2010,
        '2020-12-20 01:00:00+03',
        '2020-12-20 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2011,
        '2020-12-20 01:00:00+03',
        '2020-12-20 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2012,
        '2020-12-20 01:00:00+03',
        '2020-12-20 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        2013,
        '2020-12-20 01:00:00+03',
        '2020-12-20 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2014,
        '2020-12-20 01:00:00+03',
        '2020-12-20 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2015,
        '2020-12-20 01:00:00+03',
        '2020-12-20 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        2016,
        '2020-12-20 05:00:00+03',
        '2020-12-20 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2017,
        '2020-12-20 04:00:00+03',
        '2020-12-20 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2018,
        '2020-12-20 06:00:00+03',
        '2020-12-20 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2019,
        '2020-12-20 05:00:00+03',
        '2020-12-20 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2020,
        '2020-12-20 06:00:00+03',
        '2020-12-20 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2021,
        '2020-12-20 05:00:00+03',
        '2020-12-20 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2022,
        '2020-12-20 08:00:00+03',
        '2020-12-20 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2023,
        '2020-12-20 09:00:00+03',
        '2020-12-20 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2024,
        '2020-12-20 04:00:00+03',
        '2020-12-20 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2025,
        '2020-12-20 05:00:00+03',
        '2020-12-20 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2026,
        '2020-12-20 08:00:00+03',
        '2020-12-20 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2027,
        '2020-12-20 08:00:00+03',
        '2020-12-20 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2028,
        '2020-12-20 05:00:00+03',
        '2020-12-20 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2029,
        '2020-12-20 06:00:00+03',
        '2020-12-20 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        2030,
        '2020-12-20 05:00:00+03',
        '2020-12-20 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2031,
        '2020-12-20 05:00:00+03',
        '2020-12-20 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2032,
        '2020-12-20 06:00:00+03',
        '2020-12-20 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2033,
        '2020-12-20 09:00:00+03',
        '2020-12-20 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2034,
        '2020-12-20 10:00:00+03',
        '2020-12-20 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2035,
        '2020-12-20 10:00:00+03',
        '2020-12-20 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2036,
        '2020-12-20 12:00:00+03',
        '2020-12-20 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2037,
        '2020-12-20 11:00:00+03',
        '2020-12-20 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2038,
        '2020-12-20 12:00:00+03',
        '2020-12-20 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2039,
        '2020-12-20 11:00:00+03',
        '2020-12-20 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2040,
        '2020-12-20 12:00:00+03',
        '2020-12-20 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2041,
        '2020-12-20 09:00:00+03',
        '2020-12-20 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2042,
        '2020-12-20 10:00:00+03',
        '2020-12-20 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2043,
        '2020-12-20 12:00:00+03',
        '2020-12-20 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2044,
        '2020-12-20 12:00:00+03',
        '2020-12-20 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2045,
        '2020-12-20 10:00:00+03',
        '2020-12-20 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2046,
        '2020-12-20 11:00:00+03',
        '2020-12-20 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2047,
        '2020-12-20 14:00:00+03',
        '2020-12-20 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2048,
        '2020-12-20 12:00:00+03',
        '2020-12-20 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2049,
        '2020-12-20 12:00:00+03',
        '2020-12-20 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2050,
        '2020-12-20 13:00:00+03',
        '2020-12-20 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2051,
        '2020-12-20 15:00:00+03',
        '2020-12-20 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2052,
        '2020-12-20 16:00:00+03',
        '2020-12-20 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2053,
        '2020-12-20 16:00:00+03',
        '2020-12-20 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2054,
        '2020-12-20 15:00:00+03',
        '2020-12-20 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2055,
        '2020-12-20 15:00:00+03',
        '2020-12-20 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2056,
        '2020-12-20 19:00:00+03',
        '2020-12-20 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2057,
        '2020-12-20 17:00:00+03',
        '2020-12-20 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2058,
        '2020-12-20 17:00:00+03',
        '2020-12-20 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2059,
        '2020-12-20 15:00:00+03',
        '2020-12-20 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2060,
        '2020-12-20 15:00:00+03',
        '2020-12-20 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2061,
        '2020-12-20 17:00:00+03',
        '2020-12-20 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2062,
        '2020-12-20 16:00:00+03',
        '2020-12-20 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2063,
        '2020-12-20 17:00:00+03',
        '2020-12-20 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2064,
        '2020-12-20 16:00:00+03',
        '2020-12-20 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2065,
        '2020-12-20 17:00:00+03',
        '2020-12-20 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        2066,
        '2020-12-20 19:00:00+03',
        '2020-12-20 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2067,
        '2020-12-20 20:00:00+03',
        '2020-12-20 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2068,
        '2020-12-20 20:00:00+03',
        '2020-12-20 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2069,
        '2020-12-20 22:00:00+03',
        '2020-12-20 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2070,
        '2020-12-20 19:00:00+03',
        '2020-12-20 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2071,
        '2020-12-20 18:00:00+03',
        '2020-12-20 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2072,
        '2020-12-20 21:00:00+03',
        '2020-12-20 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2073,
        '2020-12-20 21:00:00+03',
        '2020-12-20 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2074,
        '2020-12-20 21:00:00+03',
        '2020-12-20 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2075,
        '2020-12-20 18:00:00+03',
        '2020-12-20 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2076,
        '2020-12-20 21:00:00+03',
        '2020-12-20 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2077,
        '2020-12-20 18:00:00+03',
        '2020-12-20 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2078,
        '2020-12-20 21:00:00+03',
        '2020-12-20 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2079,
        '2020-12-20 19:00:00+03',
        '2020-12-20 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2080,
        '2020-12-20 22:00:00+03',
        '2020-12-20 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2081,
        '2020-12-20 19:00:00+03',
        '2020-12-20 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2082,
        '2020-12-20 22:00:00+03',
        '2020-12-20 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2101,
        '2020-12-21 00:00:00+03',
        '2020-12-21 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2102,
        '2020-12-21 00:00:00+03',
        '2020-12-21 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2103,
        '2020-12-21 01:00:00+03',
        '2020-12-21 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2104,
        '2020-12-21 01:00:00+03',
        '2020-12-21 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2105,
        '2020-12-21 01:00:00+03',
        '2020-12-21 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2106,
        '2020-12-21 01:00:00+03',
        '2020-12-21 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2107,
        '2020-12-21 01:00:00+03',
        '2020-12-21 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2108,
        '2020-12-21 01:00:00+03',
        '2020-12-21 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2109,
        '2020-12-21 01:00:00+03',
        '2020-12-21 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2110,
        '2020-12-21 01:00:00+03',
        '2020-12-21 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2111,
        '2020-12-21 01:00:00+03',
        '2020-12-21 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2112,
        '2020-12-21 01:00:00+03',
        '2020-12-21 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        2113,
        '2020-12-21 01:00:00+03',
        '2020-12-21 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2114,
        '2020-12-21 01:00:00+03',
        '2020-12-21 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2115,
        '2020-12-21 01:00:00+03',
        '2020-12-21 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        2116,
        '2020-12-21 05:00:00+03',
        '2020-12-21 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2117,
        '2020-12-21 04:00:00+03',
        '2020-12-21 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2118,
        '2020-12-21 06:00:00+03',
        '2020-12-21 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2119,
        '2020-12-21 05:00:00+03',
        '2020-12-21 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2120,
        '2020-12-21 06:00:00+03',
        '2020-12-21 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2121,
        '2020-12-21 05:00:00+03',
        '2020-12-21 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2122,
        '2020-12-21 08:00:00+03',
        '2020-12-21 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2123,
        '2020-12-21 09:00:00+03',
        '2020-12-21 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2124,
        '2020-12-21 04:00:00+03',
        '2020-12-21 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2125,
        '2020-12-21 05:00:00+03',
        '2020-12-21 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2126,
        '2020-12-21 08:00:00+03',
        '2020-12-21 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2127,
        '2020-12-21 08:00:00+03',
        '2020-12-21 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2128,
        '2020-12-21 05:00:00+03',
        '2020-12-21 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2129,
        '2020-12-21 06:00:00+03',
        '2020-12-21 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        2130,
        '2020-12-21 05:00:00+03',
        '2020-12-21 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2131,
        '2020-12-21 05:00:00+03',
        '2020-12-21 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2132,
        '2020-12-21 06:00:00+03',
        '2020-12-21 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2133,
        '2020-12-21 09:00:00+03',
        '2020-12-21 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2134,
        '2020-12-21 10:00:00+03',
        '2020-12-21 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2135,
        '2020-12-21 10:00:00+03',
        '2020-12-21 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2136,
        '2020-12-21 12:00:00+03',
        '2020-12-21 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2137,
        '2020-12-21 11:00:00+03',
        '2020-12-21 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2138,
        '2020-12-21 12:00:00+03',
        '2020-12-21 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2139,
        '2020-12-21 11:00:00+03',
        '2020-12-21 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2140,
        '2020-12-21 12:00:00+03',
        '2020-12-21 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2141,
        '2020-12-21 09:00:00+03',
        '2020-12-21 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2142,
        '2020-12-21 10:00:00+03',
        '2020-12-21 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2143,
        '2020-12-21 12:00:00+03',
        '2020-12-21 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2144,
        '2020-12-21 12:00:00+03',
        '2020-12-21 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2145,
        '2020-12-21 10:00:00+03',
        '2020-12-21 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2146,
        '2020-12-21 11:00:00+03',
        '2020-12-21 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2147,
        '2020-12-21 14:00:00+03',
        '2020-12-21 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2148,
        '2020-12-21 12:00:00+03',
        '2020-12-21 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2149,
        '2020-12-21 12:00:00+03',
        '2020-12-21 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2150,
        '2020-12-21 13:00:00+03',
        '2020-12-21 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2151,
        '2020-12-21 15:00:00+03',
        '2020-12-21 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2152,
        '2020-12-21 16:00:00+03',
        '2020-12-21 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2153,
        '2020-12-21 16:00:00+03',
        '2020-12-21 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2154,
        '2020-12-21 15:00:00+03',
        '2020-12-21 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2155,
        '2020-12-21 15:00:00+03',
        '2020-12-21 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2156,
        '2020-12-21 19:00:00+03',
        '2020-12-21 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2157,
        '2020-12-21 17:00:00+03',
        '2020-12-21 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2158,
        '2020-12-21 17:00:00+03',
        '2020-12-21 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2159,
        '2020-12-21 15:00:00+03',
        '2020-12-21 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2160,
        '2020-12-21 15:00:00+03',
        '2020-12-21 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2161,
        '2020-12-21 17:00:00+03',
        '2020-12-21 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2162,
        '2020-12-21 16:00:00+03',
        '2020-12-21 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2163,
        '2020-12-21 17:00:00+03',
        '2020-12-21 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2164,
        '2020-12-21 16:00:00+03',
        '2020-12-21 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2165,
        '2020-12-21 17:00:00+03',
        '2020-12-21 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        2166,
        '2020-12-21 19:00:00+03',
        '2020-12-21 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2167,
        '2020-12-21 20:00:00+03',
        '2020-12-21 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2168,
        '2020-12-21 20:00:00+03',
        '2020-12-21 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2169,
        '2020-12-21 22:00:00+03',
        '2020-12-21 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2170,
        '2020-12-21 19:00:00+03',
        '2020-12-21 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2171,
        '2020-12-21 18:00:00+03',
        '2020-12-21 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2172,
        '2020-12-21 21:00:00+03',
        '2020-12-21 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2173,
        '2020-12-21 21:00:00+03',
        '2020-12-21 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2174,
        '2020-12-21 21:00:00+03',
        '2020-12-21 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2175,
        '2020-12-21 18:00:00+03',
        '2020-12-21 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2176,
        '2020-12-21 21:00:00+03',
        '2020-12-21 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2177,
        '2020-12-21 18:00:00+03',
        '2020-12-21 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2178,
        '2020-12-21 21:00:00+03',
        '2020-12-21 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2179,
        '2020-12-21 19:00:00+03',
        '2020-12-21 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2180,
        '2020-12-21 22:00:00+03',
        '2020-12-21 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2181,
        '2020-12-21 19:00:00+03',
        '2020-12-21 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2182,
        '2020-12-21 22:00:00+03',
        '2020-12-21 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2201,
        '2020-12-22 00:00:00+03',
        '2020-12-22 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2202,
        '2020-12-22 00:00:00+03',
        '2020-12-22 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2203,
        '2020-12-22 01:00:00+03',
        '2020-12-22 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2204,
        '2020-12-22 01:00:00+03',
        '2020-12-22 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2205,
        '2020-12-22 01:00:00+03',
        '2020-12-22 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2206,
        '2020-12-22 01:00:00+03',
        '2020-12-22 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2207,
        '2020-12-22 01:00:00+03',
        '2020-12-22 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2208,
        '2020-12-22 01:00:00+03',
        '2020-12-22 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2209,
        '2020-12-22 01:00:00+03',
        '2020-12-22 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2210,
        '2020-12-22 01:00:00+03',
        '2020-12-22 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2211,
        '2020-12-22 01:00:00+03',
        '2020-12-22 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2212,
        '2020-12-22 01:00:00+03',
        '2020-12-22 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        2213,
        '2020-12-22 01:00:00+03',
        '2020-12-22 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2214,
        '2020-12-22 01:00:00+03',
        '2020-12-22 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2215,
        '2020-12-22 01:00:00+03',
        '2020-12-22 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        2216,
        '2020-12-22 05:00:00+03',
        '2020-12-22 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2217,
        '2020-12-22 04:00:00+03',
        '2020-12-22 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2218,
        '2020-12-22 06:00:00+03',
        '2020-12-22 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2219,
        '2020-12-22 05:00:00+03',
        '2020-12-22 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2220,
        '2020-12-22 06:00:00+03',
        '2020-12-22 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2221,
        '2020-12-22 05:00:00+03',
        '2020-12-22 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2222,
        '2020-12-22 08:00:00+03',
        '2020-12-22 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2223,
        '2020-12-22 09:00:00+03',
        '2020-12-22 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2224,
        '2020-12-22 04:00:00+03',
        '2020-12-22 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2225,
        '2020-12-22 05:00:00+03',
        '2020-12-22 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2226,
        '2020-12-22 08:00:00+03',
        '2020-12-22 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2227,
        '2020-12-22 08:00:00+03',
        '2020-12-22 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2228,
        '2020-12-22 05:00:00+03',
        '2020-12-22 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2229,
        '2020-12-22 06:00:00+03',
        '2020-12-22 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        2230,
        '2020-12-22 05:00:00+03',
        '2020-12-22 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2231,
        '2020-12-22 05:00:00+03',
        '2020-12-22 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2232,
        '2020-12-22 06:00:00+03',
        '2020-12-22 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2233,
        '2020-12-22 09:00:00+03',
        '2020-12-22 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2234,
        '2020-12-22 10:00:00+03',
        '2020-12-22 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2235,
        '2020-12-22 10:00:00+03',
        '2020-12-22 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2236,
        '2020-12-22 12:00:00+03',
        '2020-12-22 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2237,
        '2020-12-22 11:00:00+03',
        '2020-12-22 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2238,
        '2020-12-22 12:00:00+03',
        '2020-12-22 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2239,
        '2020-12-22 11:00:00+03',
        '2020-12-22 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2240,
        '2020-12-22 12:00:00+03',
        '2020-12-22 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2241,
        '2020-12-22 09:00:00+03',
        '2020-12-22 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2242,
        '2020-12-22 10:00:00+03',
        '2020-12-22 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2243,
        '2020-12-22 12:00:00+03',
        '2020-12-22 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2244,
        '2020-12-22 12:00:00+03',
        '2020-12-22 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2245,
        '2020-12-22 10:00:00+03',
        '2020-12-22 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2246,
        '2020-12-22 11:00:00+03',
        '2020-12-22 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2247,
        '2020-12-22 14:00:00+03',
        '2020-12-22 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2248,
        '2020-12-22 12:00:00+03',
        '2020-12-22 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2249,
        '2020-12-22 12:00:00+03',
        '2020-12-22 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2250,
        '2020-12-22 13:00:00+03',
        '2020-12-22 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2251,
        '2020-12-22 15:00:00+03',
        '2020-12-22 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2252,
        '2020-12-22 16:00:00+03',
        '2020-12-22 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2253,
        '2020-12-22 16:00:00+03',
        '2020-12-22 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2254,
        '2020-12-22 15:00:00+03',
        '2020-12-22 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2255,
        '2020-12-22 15:00:00+03',
        '2020-12-22 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2256,
        '2020-12-22 19:00:00+03',
        '2020-12-22 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2257,
        '2020-12-22 17:00:00+03',
        '2020-12-22 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2258,
        '2020-12-22 17:00:00+03',
        '2020-12-22 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2259,
        '2020-12-22 15:00:00+03',
        '2020-12-22 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2260,
        '2020-12-22 15:00:00+03',
        '2020-12-22 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2261,
        '2020-12-22 17:00:00+03',
        '2020-12-22 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2262,
        '2020-12-22 16:00:00+03',
        '2020-12-22 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2263,
        '2020-12-22 17:00:00+03',
        '2020-12-22 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2264,
        '2020-12-22 16:00:00+03',
        '2020-12-22 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2265,
        '2020-12-22 17:00:00+03',
        '2020-12-22 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        2266,
        '2020-12-22 19:00:00+03',
        '2020-12-22 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2267,
        '2020-12-22 20:00:00+03',
        '2020-12-22 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2268,
        '2020-12-22 20:00:00+03',
        '2020-12-22 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2269,
        '2020-12-22 22:00:00+03',
        '2020-12-22 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2270,
        '2020-12-22 19:00:00+03',
        '2020-12-22 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2271,
        '2020-12-22 18:00:00+03',
        '2020-12-22 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2272,
        '2020-12-22 21:00:00+03',
        '2020-12-22 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2273,
        '2020-12-22 21:00:00+03',
        '2020-12-22 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2274,
        '2020-12-22 21:00:00+03',
        '2020-12-22 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2275,
        '2020-12-22 18:00:00+03',
        '2020-12-22 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2276,
        '2020-12-22 21:00:00+03',
        '2020-12-22 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2277,
        '2020-12-22 18:00:00+03',
        '2020-12-22 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2278,
        '2020-12-22 21:00:00+03',
        '2020-12-22 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2279,
        '2020-12-22 19:00:00+03',
        '2020-12-22 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2280,
        '2020-12-22 22:00:00+03',
        '2020-12-22 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2281,
        '2020-12-22 19:00:00+03',
        '2020-12-22 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2282,
        '2020-12-22 22:00:00+03',
        '2020-12-22 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2301,
        '2020-12-23 00:00:00+03',
        '2020-12-23 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2302,
        '2020-12-23 00:00:00+03',
        '2020-12-23 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2303,
        '2020-12-23 01:00:00+03',
        '2020-12-23 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2304,
        '2020-12-23 01:00:00+03',
        '2020-12-23 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2305,
        '2020-12-23 01:00:00+03',
        '2020-12-23 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2306,
        '2020-12-23 01:00:00+03',
        '2020-12-23 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2307,
        '2020-12-23 01:00:00+03',
        '2020-12-23 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2308,
        '2020-12-23 01:00:00+03',
        '2020-12-23 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2309,
        '2020-12-23 01:00:00+03',
        '2020-12-23 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2310,
        '2020-12-23 01:00:00+03',
        '2020-12-23 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2311,
        '2020-12-23 01:00:00+03',
        '2020-12-23 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2312,
        '2020-12-23 01:00:00+03',
        '2020-12-23 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        2313,
        '2020-12-23 01:00:00+03',
        '2020-12-23 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2314,
        '2020-12-23 01:00:00+03',
        '2020-12-23 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2315,
        '2020-12-23 01:00:00+03',
        '2020-12-23 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        2316,
        '2020-12-23 05:00:00+03',
        '2020-12-23 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2317,
        '2020-12-23 04:00:00+03',
        '2020-12-23 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2318,
        '2020-12-23 06:00:00+03',
        '2020-12-23 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2319,
        '2020-12-23 05:00:00+03',
        '2020-12-23 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2320,
        '2020-12-23 06:00:00+03',
        '2020-12-23 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2321,
        '2020-12-23 05:00:00+03',
        '2020-12-23 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2322,
        '2020-12-23 08:00:00+03',
        '2020-12-23 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2323,
        '2020-12-23 09:00:00+03',
        '2020-12-23 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2324,
        '2020-12-23 04:00:00+03',
        '2020-12-23 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2325,
        '2020-12-23 05:00:00+03',
        '2020-12-23 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2326,
        '2020-12-23 08:00:00+03',
        '2020-12-23 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2327,
        '2020-12-23 08:00:00+03',
        '2020-12-23 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2328,
        '2020-12-23 05:00:00+03',
        '2020-12-23 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2329,
        '2020-12-23 06:00:00+03',
        '2020-12-23 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        2330,
        '2020-12-23 05:00:00+03',
        '2020-12-23 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2331,
        '2020-12-23 05:00:00+03',
        '2020-12-23 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2332,
        '2020-12-23 06:00:00+03',
        '2020-12-23 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2333,
        '2020-12-23 09:00:00+03',
        '2020-12-23 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2334,
        '2020-12-23 10:00:00+03',
        '2020-12-23 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2335,
        '2020-12-23 10:00:00+03',
        '2020-12-23 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2336,
        '2020-12-23 12:00:00+03',
        '2020-12-23 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2337,
        '2020-12-23 11:00:00+03',
        '2020-12-23 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2338,
        '2020-12-23 12:00:00+03',
        '2020-12-23 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2339,
        '2020-12-23 11:00:00+03',
        '2020-12-23 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2340,
        '2020-12-23 12:00:00+03',
        '2020-12-23 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2341,
        '2020-12-23 09:00:00+03',
        '2020-12-23 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2342,
        '2020-12-23 10:00:00+03',
        '2020-12-23 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2343,
        '2020-12-23 12:00:00+03',
        '2020-12-23 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2344,
        '2020-12-23 12:00:00+03',
        '2020-12-23 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2345,
        '2020-12-23 10:00:00+03',
        '2020-12-23 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2346,
        '2020-12-23 11:00:00+03',
        '2020-12-23 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2347,
        '2020-12-23 14:00:00+03',
        '2020-12-23 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2348,
        '2020-12-23 12:00:00+03',
        '2020-12-23 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2349,
        '2020-12-23 12:00:00+03',
        '2020-12-23 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2350,
        '2020-12-23 13:00:00+03',
        '2020-12-23 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2351,
        '2020-12-23 15:00:00+03',
        '2020-12-23 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2352,
        '2020-12-23 16:00:00+03',
        '2020-12-23 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2353,
        '2020-12-23 16:00:00+03',
        '2020-12-23 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2354,
        '2020-12-23 15:00:00+03',
        '2020-12-23 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2355,
        '2020-12-23 15:00:00+03',
        '2020-12-23 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2356,
        '2020-12-23 19:00:00+03',
        '2020-12-23 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2357,
        '2020-12-23 17:00:00+03',
        '2020-12-23 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2358,
        '2020-12-23 17:00:00+03',
        '2020-12-23 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2359,
        '2020-12-23 15:00:00+03',
        '2020-12-23 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2360,
        '2020-12-23 15:00:00+03',
        '2020-12-23 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2361,
        '2020-12-23 17:00:00+03',
        '2020-12-23 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2362,
        '2020-12-23 16:00:00+03',
        '2020-12-23 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2363,
        '2020-12-23 17:00:00+03',
        '2020-12-23 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2364,
        '2020-12-23 16:00:00+03',
        '2020-12-23 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2365,
        '2020-12-23 17:00:00+03',
        '2020-12-23 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        2366,
        '2020-12-23 19:00:00+03',
        '2020-12-23 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2367,
        '2020-12-23 20:00:00+03',
        '2020-12-23 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2368,
        '2020-12-23 20:00:00+03',
        '2020-12-23 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2369,
        '2020-12-23 22:00:00+03',
        '2020-12-23 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2370,
        '2020-12-23 19:00:00+03',
        '2020-12-23 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2371,
        '2020-12-23 18:00:00+03',
        '2020-12-23 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2372,
        '2020-12-23 21:00:00+03',
        '2020-12-23 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2373,
        '2020-12-23 21:00:00+03',
        '2020-12-23 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2374,
        '2020-12-23 21:00:00+03',
        '2020-12-23 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2375,
        '2020-12-23 18:00:00+03',
        '2020-12-23 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2376,
        '2020-12-23 21:00:00+03',
        '2020-12-23 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2377,
        '2020-12-23 18:00:00+03',
        '2020-12-23 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2378,
        '2020-12-23 21:00:00+03',
        '2020-12-23 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2379,
        '2020-12-23 19:00:00+03',
        '2020-12-23 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2380,
        '2020-12-23 22:00:00+03',
        '2020-12-23 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2381,
        '2020-12-23 19:00:00+03',
        '2020-12-23 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2382,
        '2020-12-23 22:00:00+03',
        '2020-12-23 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2401,
        '2020-12-24 00:00:00+03',
        '2020-12-24 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2402,
        '2020-12-24 00:00:00+03',
        '2020-12-24 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2403,
        '2020-12-24 01:00:00+03',
        '2020-12-24 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2404,
        '2020-12-24 01:00:00+03',
        '2020-12-24 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2405,
        '2020-12-24 01:00:00+03',
        '2020-12-24 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2406,
        '2020-12-24 01:00:00+03',
        '2020-12-24 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2407,
        '2020-12-24 01:00:00+03',
        '2020-12-24 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2408,
        '2020-12-24 01:00:00+03',
        '2020-12-24 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2409,
        '2020-12-24 01:00:00+03',
        '2020-12-24 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2410,
        '2020-12-24 01:00:00+03',
        '2020-12-24 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2411,
        '2020-12-24 01:00:00+03',
        '2020-12-24 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2412,
        '2020-12-24 01:00:00+03',
        '2020-12-24 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        2413,
        '2020-12-24 01:00:00+03',
        '2020-12-24 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2414,
        '2020-12-24 01:00:00+03',
        '2020-12-24 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2415,
        '2020-12-24 01:00:00+03',
        '2020-12-24 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        2416,
        '2020-12-24 05:00:00+03',
        '2020-12-24 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2417,
        '2020-12-24 04:00:00+03',
        '2020-12-24 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2418,
        '2020-12-24 06:00:00+03',
        '2020-12-24 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2419,
        '2020-12-24 05:00:00+03',
        '2020-12-24 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2420,
        '2020-12-24 06:00:00+03',
        '2020-12-24 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2421,
        '2020-12-24 05:00:00+03',
        '2020-12-24 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2422,
        '2020-12-24 08:00:00+03',
        '2020-12-24 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2423,
        '2020-12-24 09:00:00+03',
        '2020-12-24 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2424,
        '2020-12-24 04:00:00+03',
        '2020-12-24 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2425,
        '2020-12-24 05:00:00+03',
        '2020-12-24 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2426,
        '2020-12-24 08:00:00+03',
        '2020-12-24 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2427,
        '2020-12-24 08:00:00+03',
        '2020-12-24 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2428,
        '2020-12-24 05:00:00+03',
        '2020-12-24 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2429,
        '2020-12-24 06:00:00+03',
        '2020-12-24 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        2430,
        '2020-12-24 05:00:00+03',
        '2020-12-24 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2431,
        '2020-12-24 05:00:00+03',
        '2020-12-24 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2432,
        '2020-12-24 06:00:00+03',
        '2020-12-24 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2433,
        '2020-12-24 09:00:00+03',
        '2020-12-24 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2434,
        '2020-12-24 10:00:00+03',
        '2020-12-24 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2435,
        '2020-12-24 10:00:00+03',
        '2020-12-24 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2436,
        '2020-12-24 12:00:00+03',
        '2020-12-24 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2437,
        '2020-12-24 11:00:00+03',
        '2020-12-24 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2438,
        '2020-12-24 12:00:00+03',
        '2020-12-24 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2439,
        '2020-12-24 11:00:00+03',
        '2020-12-24 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2440,
        '2020-12-24 12:00:00+03',
        '2020-12-24 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2441,
        '2020-12-24 09:00:00+03',
        '2020-12-24 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2442,
        '2020-12-24 10:00:00+03',
        '2020-12-24 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2443,
        '2020-12-24 12:00:00+03',
        '2020-12-24 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2444,
        '2020-12-24 12:00:00+03',
        '2020-12-24 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2445,
        '2020-12-24 10:00:00+03',
        '2020-12-24 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2446,
        '2020-12-24 11:00:00+03',
        '2020-12-24 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2447,
        '2020-12-24 14:00:00+03',
        '2020-12-24 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2448,
        '2020-12-24 12:00:00+03',
        '2020-12-24 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2449,
        '2020-12-24 12:00:00+03',
        '2020-12-24 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2450,
        '2020-12-24 13:00:00+03',
        '2020-12-24 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2451,
        '2020-12-24 15:00:00+03',
        '2020-12-24 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2452,
        '2020-12-24 16:00:00+03',
        '2020-12-24 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2453,
        '2020-12-24 16:00:00+03',
        '2020-12-24 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2454,
        '2020-12-24 15:00:00+03',
        '2020-12-24 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2455,
        '2020-12-24 15:00:00+03',
        '2020-12-24 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2456,
        '2020-12-24 19:00:00+03',
        '2020-12-24 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2457,
        '2020-12-24 17:00:00+03',
        '2020-12-24 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2458,
        '2020-12-24 17:00:00+03',
        '2020-12-24 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2459,
        '2020-12-24 15:00:00+03',
        '2020-12-24 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2460,
        '2020-12-24 15:00:00+03',
        '2020-12-24 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2461,
        '2020-12-24 17:00:00+03',
        '2020-12-24 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2462,
        '2020-12-24 16:00:00+03',
        '2020-12-24 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2463,
        '2020-12-24 17:00:00+03',
        '2020-12-24 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2464,
        '2020-12-24 16:00:00+03',
        '2020-12-24 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2465,
        '2020-12-24 17:00:00+03',
        '2020-12-24 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        2466,
        '2020-12-24 19:00:00+03',
        '2020-12-24 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2467,
        '2020-12-24 20:00:00+03',
        '2020-12-24 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2468,
        '2020-12-24 20:00:00+03',
        '2020-12-24 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2469,
        '2020-12-24 22:00:00+03',
        '2020-12-24 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2470,
        '2020-12-24 19:00:00+03',
        '2020-12-24 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2471,
        '2020-12-24 18:00:00+03',
        '2020-12-24 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2472,
        '2020-12-24 21:00:00+03',
        '2020-12-24 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2473,
        '2020-12-24 21:00:00+03',
        '2020-12-24 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2474,
        '2020-12-24 21:00:00+03',
        '2020-12-24 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2475,
        '2020-12-24 18:00:00+03',
        '2020-12-24 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2476,
        '2020-12-24 21:00:00+03',
        '2020-12-24 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2477,
        '2020-12-24 18:00:00+03',
        '2020-12-24 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2478,
        '2020-12-24 21:00:00+03',
        '2020-12-24 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2479,
        '2020-12-24 19:00:00+03',
        '2020-12-24 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2480,
        '2020-12-24 22:00:00+03',
        '2020-12-24 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2481,
        '2020-12-24 19:00:00+03',
        '2020-12-24 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2482,
        '2020-12-24 22:00:00+03',
        '2020-12-24 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2501,
        '2020-12-25 00:00:00+03',
        '2020-12-25 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2502,
        '2020-12-25 00:00:00+03',
        '2020-12-25 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2503,
        '2020-12-25 01:00:00+03',
        '2020-12-25 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2504,
        '2020-12-25 01:00:00+03',
        '2020-12-25 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2505,
        '2020-12-25 01:00:00+03',
        '2020-12-25 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2506,
        '2020-12-25 01:00:00+03',
        '2020-12-25 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2507,
        '2020-12-25 01:00:00+03',
        '2020-12-25 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2508,
        '2020-12-25 01:00:00+03',
        '2020-12-25 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2509,
        '2020-12-25 01:00:00+03',
        '2020-12-25 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2510,
        '2020-12-25 01:00:00+03',
        '2020-12-25 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2511,
        '2020-12-25 01:00:00+03',
        '2020-12-25 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2512,
        '2020-12-25 01:00:00+03',
        '2020-12-25 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        2513,
        '2020-12-25 01:00:00+03',
        '2020-12-25 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2514,
        '2020-12-25 01:00:00+03',
        '2020-12-25 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2515,
        '2020-12-25 01:00:00+03',
        '2020-12-25 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        2516,
        '2020-12-25 05:00:00+03',
        '2020-12-25 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2517,
        '2020-12-25 04:00:00+03',
        '2020-12-25 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2518,
        '2020-12-25 06:00:00+03',
        '2020-12-25 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2519,
        '2020-12-25 05:00:00+03',
        '2020-12-25 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2520,
        '2020-12-25 06:00:00+03',
        '2020-12-25 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2521,
        '2020-12-25 05:00:00+03',
        '2020-12-25 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2522,
        '2020-12-25 08:00:00+03',
        '2020-12-25 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2523,
        '2020-12-25 09:00:00+03',
        '2020-12-25 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2524,
        '2020-12-25 04:00:00+03',
        '2020-12-25 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2525,
        '2020-12-25 05:00:00+03',
        '2020-12-25 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2526,
        '2020-12-25 08:00:00+03',
        '2020-12-25 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2527,
        '2020-12-25 08:00:00+03',
        '2020-12-25 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2528,
        '2020-12-25 05:00:00+03',
        '2020-12-25 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2529,
        '2020-12-25 06:00:00+03',
        '2020-12-25 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        2530,
        '2020-12-25 05:00:00+03',
        '2020-12-25 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2531,
        '2020-12-25 05:00:00+03',
        '2020-12-25 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2532,
        '2020-12-25 06:00:00+03',
        '2020-12-25 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2533,
        '2020-12-25 09:00:00+03',
        '2020-12-25 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2534,
        '2020-12-25 10:00:00+03',
        '2020-12-25 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2535,
        '2020-12-25 10:00:00+03',
        '2020-12-25 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2536,
        '2020-12-25 12:00:00+03',
        '2020-12-25 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2537,
        '2020-12-25 11:00:00+03',
        '2020-12-25 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2538,
        '2020-12-25 12:00:00+03',
        '2020-12-25 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2539,
        '2020-12-25 11:00:00+03',
        '2020-12-25 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2540,
        '2020-12-25 12:00:00+03',
        '2020-12-25 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2541,
        '2020-12-25 09:00:00+03',
        '2020-12-25 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2542,
        '2020-12-25 10:00:00+03',
        '2020-12-25 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2543,
        '2020-12-25 12:00:00+03',
        '2020-12-25 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2544,
        '2020-12-25 12:00:00+03',
        '2020-12-25 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2545,
        '2020-12-25 10:00:00+03',
        '2020-12-25 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2546,
        '2020-12-25 11:00:00+03',
        '2020-12-25 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2547,
        '2020-12-25 14:00:00+03',
        '2020-12-25 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2548,
        '2020-12-25 12:00:00+03',
        '2020-12-25 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2549,
        '2020-12-25 12:00:00+03',
        '2020-12-25 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2550,
        '2020-12-25 13:00:00+03',
        '2020-12-25 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2551,
        '2020-12-25 15:00:00+03',
        '2020-12-25 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2552,
        '2020-12-25 16:00:00+03',
        '2020-12-25 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2553,
        '2020-12-25 16:00:00+03',
        '2020-12-25 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2554,
        '2020-12-25 15:00:00+03',
        '2020-12-25 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2555,
        '2020-12-25 15:00:00+03',
        '2020-12-25 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2556,
        '2020-12-25 19:00:00+03',
        '2020-12-25 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2557,
        '2020-12-25 17:00:00+03',
        '2020-12-25 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2558,
        '2020-12-25 17:00:00+03',
        '2020-12-25 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2559,
        '2020-12-25 15:00:00+03',
        '2020-12-25 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2560,
        '2020-12-25 15:00:00+03',
        '2020-12-25 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2561,
        '2020-12-25 17:00:00+03',
        '2020-12-25 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2562,
        '2020-12-25 16:00:00+03',
        '2020-12-25 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2563,
        '2020-12-25 17:00:00+03',
        '2020-12-25 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2564,
        '2020-12-25 16:00:00+03',
        '2020-12-25 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2565,
        '2020-12-25 17:00:00+03',
        '2020-12-25 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        2566,
        '2020-12-25 19:00:00+03',
        '2020-12-25 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2567,
        '2020-12-25 20:00:00+03',
        '2020-12-25 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2568,
        '2020-12-25 20:00:00+03',
        '2020-12-25 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2569,
        '2020-12-25 22:00:00+03',
        '2020-12-25 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2570,
        '2020-12-25 19:00:00+03',
        '2020-12-25 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2571,
        '2020-12-25 18:00:00+03',
        '2020-12-25 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2572,
        '2020-12-25 21:00:00+03',
        '2020-12-25 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2573,
        '2020-12-25 21:00:00+03',
        '2020-12-25 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2574,
        '2020-12-25 21:00:00+03',
        '2020-12-25 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2575,
        '2020-12-25 18:00:00+03',
        '2020-12-25 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2576,
        '2020-12-25 21:00:00+03',
        '2020-12-25 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2577,
        '2020-12-25 18:00:00+03',
        '2020-12-25 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2578,
        '2020-12-25 21:00:00+03',
        '2020-12-25 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2579,
        '2020-12-25 19:00:00+03',
        '2020-12-25 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2580,
        '2020-12-25 22:00:00+03',
        '2020-12-25 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2581,
        '2020-12-25 19:00:00+03',
        '2020-12-25 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2582,
        '2020-12-25 22:00:00+03',
        '2020-12-25 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2601,
        '2020-12-26 00:00:00+03',
        '2020-12-26 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2602,
        '2020-12-26 00:00:00+03',
        '2020-12-26 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2603,
        '2020-12-26 01:00:00+03',
        '2020-12-26 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2604,
        '2020-12-26 01:00:00+03',
        '2020-12-26 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2605,
        '2020-12-26 01:00:00+03',
        '2020-12-26 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2606,
        '2020-12-26 01:00:00+03',
        '2020-12-26 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2607,
        '2020-12-26 01:00:00+03',
        '2020-12-26 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2608,
        '2020-12-26 01:00:00+03',
        '2020-12-26 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2609,
        '2020-12-26 01:00:00+03',
        '2020-12-26 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2610,
        '2020-12-26 01:00:00+03',
        '2020-12-26 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2611,
        '2020-12-26 01:00:00+03',
        '2020-12-26 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2612,
        '2020-12-26 01:00:00+03',
        '2020-12-26 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        2613,
        '2020-12-26 01:00:00+03',
        '2020-12-26 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2614,
        '2020-12-26 01:00:00+03',
        '2020-12-26 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2615,
        '2020-12-26 01:00:00+03',
        '2020-12-26 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        2616,
        '2020-12-26 05:00:00+03',
        '2020-12-26 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2617,
        '2020-12-26 04:00:00+03',
        '2020-12-26 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2618,
        '2020-12-26 06:00:00+03',
        '2020-12-26 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2619,
        '2020-12-26 05:00:00+03',
        '2020-12-26 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2620,
        '2020-12-26 06:00:00+03',
        '2020-12-26 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2621,
        '2020-12-26 05:00:00+03',
        '2020-12-26 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2622,
        '2020-12-26 08:00:00+03',
        '2020-12-26 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2623,
        '2020-12-26 09:00:00+03',
        '2020-12-26 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2624,
        '2020-12-26 04:00:00+03',
        '2020-12-26 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2625,
        '2020-12-26 05:00:00+03',
        '2020-12-26 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2626,
        '2020-12-26 08:00:00+03',
        '2020-12-26 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2627,
        '2020-12-26 08:00:00+03',
        '2020-12-26 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2628,
        '2020-12-26 05:00:00+03',
        '2020-12-26 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2629,
        '2020-12-26 06:00:00+03',
        '2020-12-26 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        2630,
        '2020-12-26 05:00:00+03',
        '2020-12-26 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2631,
        '2020-12-26 05:00:00+03',
        '2020-12-26 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2632,
        '2020-12-26 06:00:00+03',
        '2020-12-26 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2633,
        '2020-12-26 09:00:00+03',
        '2020-12-26 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2634,
        '2020-12-26 10:00:00+03',
        '2020-12-26 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2635,
        '2020-12-26 10:00:00+03',
        '2020-12-26 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2636,
        '2020-12-26 12:00:00+03',
        '2020-12-26 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2637,
        '2020-12-26 11:00:00+03',
        '2020-12-26 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2638,
        '2020-12-26 12:00:00+03',
        '2020-12-26 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2639,
        '2020-12-26 11:00:00+03',
        '2020-12-26 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2640,
        '2020-12-26 12:00:00+03',
        '2020-12-26 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2641,
        '2020-12-26 09:00:00+03',
        '2020-12-26 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2642,
        '2020-12-26 10:00:00+03',
        '2020-12-26 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2643,
        '2020-12-26 12:00:00+03',
        '2020-12-26 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2644,
        '2020-12-26 12:00:00+03',
        '2020-12-26 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2645,
        '2020-12-26 10:00:00+03',
        '2020-12-26 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2646,
        '2020-12-26 11:00:00+03',
        '2020-12-26 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2647,
        '2020-12-26 14:00:00+03',
        '2020-12-26 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2648,
        '2020-12-26 12:00:00+03',
        '2020-12-26 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2649,
        '2020-12-26 12:00:00+03',
        '2020-12-26 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2650,
        '2020-12-26 13:00:00+03',
        '2020-12-26 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2651,
        '2020-12-26 15:00:00+03',
        '2020-12-26 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2652,
        '2020-12-26 16:00:00+03',
        '2020-12-26 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2653,
        '2020-12-26 16:00:00+03',
        '2020-12-26 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2654,
        '2020-12-26 15:00:00+03',
        '2020-12-26 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2655,
        '2020-12-26 15:00:00+03',
        '2020-12-26 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2656,
        '2020-12-26 19:00:00+03',
        '2020-12-26 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2657,
        '2020-12-26 17:00:00+03',
        '2020-12-26 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2658,
        '2020-12-26 17:00:00+03',
        '2020-12-26 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2659,
        '2020-12-26 15:00:00+03',
        '2020-12-26 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2660,
        '2020-12-26 15:00:00+03',
        '2020-12-26 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2661,
        '2020-12-26 17:00:00+03',
        '2020-12-26 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2662,
        '2020-12-26 16:00:00+03',
        '2020-12-26 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2663,
        '2020-12-26 17:00:00+03',
        '2020-12-26 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2664,
        '2020-12-26 16:00:00+03',
        '2020-12-26 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2665,
        '2020-12-26 17:00:00+03',
        '2020-12-26 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        2666,
        '2020-12-26 19:00:00+03',
        '2020-12-26 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2667,
        '2020-12-26 20:00:00+03',
        '2020-12-26 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2668,
        '2020-12-26 20:00:00+03',
        '2020-12-26 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2669,
        '2020-12-26 22:00:00+03',
        '2020-12-26 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2670,
        '2020-12-26 19:00:00+03',
        '2020-12-26 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2671,
        '2020-12-26 18:00:00+03',
        '2020-12-26 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2672,
        '2020-12-26 21:00:00+03',
        '2020-12-26 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2673,
        '2020-12-26 21:00:00+03',
        '2020-12-26 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2674,
        '2020-12-26 21:00:00+03',
        '2020-12-26 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2675,
        '2020-12-26 18:00:00+03',
        '2020-12-26 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2676,
        '2020-12-26 21:00:00+03',
        '2020-12-26 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2677,
        '2020-12-26 18:00:00+03',
        '2020-12-26 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2678,
        '2020-12-26 21:00:00+03',
        '2020-12-26 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2679,
        '2020-12-26 19:00:00+03',
        '2020-12-26 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2680,
        '2020-12-26 22:00:00+03',
        '2020-12-26 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2681,
        '2020-12-26 19:00:00+03',
        '2020-12-26 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2682,
        '2020-12-26 22:00:00+03',
        '2020-12-26 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2701,
        '2020-12-27 00:00:00+03',
        '2020-12-27 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2702,
        '2020-12-27 00:00:00+03',
        '2020-12-27 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2703,
        '2020-12-27 01:00:00+03',
        '2020-12-27 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2704,
        '2020-12-27 01:00:00+03',
        '2020-12-27 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2705,
        '2020-12-27 01:00:00+03',
        '2020-12-27 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2706,
        '2020-12-27 01:00:00+03',
        '2020-12-27 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2707,
        '2020-12-27 01:00:00+03',
        '2020-12-27 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2708,
        '2020-12-27 01:00:00+03',
        '2020-12-27 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2709,
        '2020-12-27 01:00:00+03',
        '2020-12-27 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2710,
        '2020-12-27 01:00:00+03',
        '2020-12-27 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2711,
        '2020-12-27 01:00:00+03',
        '2020-12-27 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2712,
        '2020-12-27 01:00:00+03',
        '2020-12-27 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        2713,
        '2020-12-27 01:00:00+03',
        '2020-12-27 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2714,
        '2020-12-27 01:00:00+03',
        '2020-12-27 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2715,
        '2020-12-27 01:00:00+03',
        '2020-12-27 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        2716,
        '2020-12-27 05:00:00+03',
        '2020-12-27 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2717,
        '2020-12-27 04:00:00+03',
        '2020-12-27 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2718,
        '2020-12-27 06:00:00+03',
        '2020-12-27 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2719,
        '2020-12-27 05:00:00+03',
        '2020-12-27 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2720,
        '2020-12-27 06:00:00+03',
        '2020-12-27 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2721,
        '2020-12-27 05:00:00+03',
        '2020-12-27 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2722,
        '2020-12-27 08:00:00+03',
        '2020-12-27 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2723,
        '2020-12-27 09:00:00+03',
        '2020-12-27 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2724,
        '2020-12-27 04:00:00+03',
        '2020-12-27 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2725,
        '2020-12-27 05:00:00+03',
        '2020-12-27 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2726,
        '2020-12-27 08:00:00+03',
        '2020-12-27 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2727,
        '2020-12-27 08:00:00+03',
        '2020-12-27 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2728,
        '2020-12-27 05:00:00+03',
        '2020-12-27 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2729,
        '2020-12-27 06:00:00+03',
        '2020-12-27 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        2730,
        '2020-12-27 05:00:00+03',
        '2020-12-27 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2731,
        '2020-12-27 05:00:00+03',
        '2020-12-27 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2732,
        '2020-12-27 06:00:00+03',
        '2020-12-27 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2733,
        '2020-12-27 09:00:00+03',
        '2020-12-27 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2734,
        '2020-12-27 10:00:00+03',
        '2020-12-27 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2735,
        '2020-12-27 10:00:00+03',
        '2020-12-27 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2736,
        '2020-12-27 12:00:00+03',
        '2020-12-27 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2737,
        '2020-12-27 11:00:00+03',
        '2020-12-27 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2738,
        '2020-12-27 12:00:00+03',
        '2020-12-27 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2739,
        '2020-12-27 11:00:00+03',
        '2020-12-27 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2740,
        '2020-12-27 12:00:00+03',
        '2020-12-27 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2741,
        '2020-12-27 09:00:00+03',
        '2020-12-27 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2742,
        '2020-12-27 10:00:00+03',
        '2020-12-27 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2743,
        '2020-12-27 12:00:00+03',
        '2020-12-27 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2744,
        '2020-12-27 12:00:00+03',
        '2020-12-27 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2745,
        '2020-12-27 10:00:00+03',
        '2020-12-27 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2746,
        '2020-12-27 11:00:00+03',
        '2020-12-27 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2747,
        '2020-12-27 14:00:00+03',
        '2020-12-27 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2748,
        '2020-12-27 12:00:00+03',
        '2020-12-27 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2749,
        '2020-12-27 12:00:00+03',
        '2020-12-27 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2750,
        '2020-12-27 13:00:00+03',
        '2020-12-27 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2751,
        '2020-12-27 15:00:00+03',
        '2020-12-27 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2752,
        '2020-12-27 16:00:00+03',
        '2020-12-27 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2753,
        '2020-12-27 16:00:00+03',
        '2020-12-27 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2754,
        '2020-12-27 15:00:00+03',
        '2020-12-27 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2755,
        '2020-12-27 15:00:00+03',
        '2020-12-27 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2756,
        '2020-12-27 19:00:00+03',
        '2020-12-27 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2757,
        '2020-12-27 17:00:00+03',
        '2020-12-27 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2758,
        '2020-12-27 17:00:00+03',
        '2020-12-27 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2759,
        '2020-12-27 15:00:00+03',
        '2020-12-27 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2760,
        '2020-12-27 15:00:00+03',
        '2020-12-27 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2761,
        '2020-12-27 17:00:00+03',
        '2020-12-27 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2762,
        '2020-12-27 16:00:00+03',
        '2020-12-27 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2763,
        '2020-12-27 17:00:00+03',
        '2020-12-27 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2764,
        '2020-12-27 16:00:00+03',
        '2020-12-27 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2765,
        '2020-12-27 17:00:00+03',
        '2020-12-27 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        2766,
        '2020-12-27 19:00:00+03',
        '2020-12-27 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2767,
        '2020-12-27 20:00:00+03',
        '2020-12-27 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2768,
        '2020-12-27 20:00:00+03',
        '2020-12-27 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2769,
        '2020-12-27 22:00:00+03',
        '2020-12-27 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2770,
        '2020-12-27 19:00:00+03',
        '2020-12-27 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2771,
        '2020-12-27 18:00:00+03',
        '2020-12-27 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2772,
        '2020-12-27 21:00:00+03',
        '2020-12-27 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2773,
        '2020-12-27 21:00:00+03',
        '2020-12-27 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2774,
        '2020-12-27 21:00:00+03',
        '2020-12-27 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2775,
        '2020-12-27 18:00:00+03',
        '2020-12-27 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2776,
        '2020-12-27 21:00:00+03',
        '2020-12-27 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2777,
        '2020-12-27 18:00:00+03',
        '2020-12-27 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2778,
        '2020-12-27 21:00:00+03',
        '2020-12-27 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2779,
        '2020-12-27 19:00:00+03',
        '2020-12-27 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2780,
        '2020-12-27 22:00:00+03',
        '2020-12-27 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2781,
        '2020-12-27 19:00:00+03',
        '2020-12-27 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2782,
        '2020-12-27 22:00:00+03',
        '2020-12-27 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2801,
        '2020-12-28 00:00:00+03',
        '2020-12-28 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2802,
        '2020-12-28 00:00:00+03',
        '2020-12-28 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2803,
        '2020-12-28 01:00:00+03',
        '2020-12-28 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2804,
        '2020-12-28 01:00:00+03',
        '2020-12-28 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2805,
        '2020-12-28 01:00:00+03',
        '2020-12-28 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2806,
        '2020-12-28 01:00:00+03',
        '2020-12-28 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2807,
        '2020-12-28 01:00:00+03',
        '2020-12-28 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2808,
        '2020-12-28 01:00:00+03',
        '2020-12-28 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2809,
        '2020-12-28 01:00:00+03',
        '2020-12-28 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2810,
        '2020-12-28 01:00:00+03',
        '2020-12-28 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2811,
        '2020-12-28 01:00:00+03',
        '2020-12-28 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2812,
        '2020-12-28 01:00:00+03',
        '2020-12-28 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        2813,
        '2020-12-28 01:00:00+03',
        '2020-12-28 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2814,
        '2020-12-28 01:00:00+03',
        '2020-12-28 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2815,
        '2020-12-28 01:00:00+03',
        '2020-12-28 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        2816,
        '2020-12-28 05:00:00+03',
        '2020-12-28 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2817,
        '2020-12-28 04:00:00+03',
        '2020-12-28 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2818,
        '2020-12-28 06:00:00+03',
        '2020-12-28 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2819,
        '2020-12-28 05:00:00+03',
        '2020-12-28 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2820,
        '2020-12-28 06:00:00+03',
        '2020-12-28 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2821,
        '2020-12-28 05:00:00+03',
        '2020-12-28 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2822,
        '2020-12-28 08:00:00+03',
        '2020-12-28 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2823,
        '2020-12-28 09:00:00+03',
        '2020-12-28 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2824,
        '2020-12-28 04:00:00+03',
        '2020-12-28 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2825,
        '2020-12-28 05:00:00+03',
        '2020-12-28 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2826,
        '2020-12-28 08:00:00+03',
        '2020-12-28 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2827,
        '2020-12-28 08:00:00+03',
        '2020-12-28 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2828,
        '2020-12-28 05:00:00+03',
        '2020-12-28 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2829,
        '2020-12-28 06:00:00+03',
        '2020-12-28 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        2830,
        '2020-12-28 05:00:00+03',
        '2020-12-28 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2831,
        '2020-12-28 05:00:00+03',
        '2020-12-28 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2832,
        '2020-12-28 06:00:00+03',
        '2020-12-28 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2833,
        '2020-12-28 09:00:00+03',
        '2020-12-28 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2834,
        '2020-12-28 10:00:00+03',
        '2020-12-28 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2835,
        '2020-12-28 10:00:00+03',
        '2020-12-28 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2836,
        '2020-12-28 12:00:00+03',
        '2020-12-28 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2837,
        '2020-12-28 11:00:00+03',
        '2020-12-28 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2838,
        '2020-12-28 12:00:00+03',
        '2020-12-28 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2839,
        '2020-12-28 11:00:00+03',
        '2020-12-28 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2840,
        '2020-12-28 12:00:00+03',
        '2020-12-28 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2841,
        '2020-12-28 09:00:00+03',
        '2020-12-28 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2842,
        '2020-12-28 10:00:00+03',
        '2020-12-28 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2843,
        '2020-12-28 12:00:00+03',
        '2020-12-28 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2844,
        '2020-12-28 12:00:00+03',
        '2020-12-28 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2845,
        '2020-12-28 10:00:00+03',
        '2020-12-28 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2846,
        '2020-12-28 11:00:00+03',
        '2020-12-28 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2847,
        '2020-12-28 14:00:00+03',
        '2020-12-28 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2848,
        '2020-12-28 12:00:00+03',
        '2020-12-28 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2849,
        '2020-12-28 12:00:00+03',
        '2020-12-28 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2850,
        '2020-12-28 13:00:00+03',
        '2020-12-28 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2851,
        '2020-12-28 15:00:00+03',
        '2020-12-28 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2852,
        '2020-12-28 16:00:00+03',
        '2020-12-28 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2853,
        '2020-12-28 16:00:00+03',
        '2020-12-28 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2854,
        '2020-12-28 15:00:00+03',
        '2020-12-28 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2855,
        '2020-12-28 15:00:00+03',
        '2020-12-28 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2856,
        '2020-12-28 19:00:00+03',
        '2020-12-28 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2857,
        '2020-12-28 17:00:00+03',
        '2020-12-28 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2858,
        '2020-12-28 17:00:00+03',
        '2020-12-28 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2859,
        '2020-12-28 15:00:00+03',
        '2020-12-28 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2860,
        '2020-12-28 15:00:00+03',
        '2020-12-28 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2861,
        '2020-12-28 17:00:00+03',
        '2020-12-28 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2862,
        '2020-12-28 16:00:00+03',
        '2020-12-28 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2863,
        '2020-12-28 17:00:00+03',
        '2020-12-28 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2864,
        '2020-12-28 16:00:00+03',
        '2020-12-28 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2865,
        '2020-12-28 17:00:00+03',
        '2020-12-28 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        2866,
        '2020-12-28 19:00:00+03',
        '2020-12-28 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2867,
        '2020-12-28 20:00:00+03',
        '2020-12-28 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2868,
        '2020-12-28 20:00:00+03',
        '2020-12-28 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2869,
        '2020-12-28 22:00:00+03',
        '2020-12-28 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2870,
        '2020-12-28 19:00:00+03',
        '2020-12-28 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2871,
        '2020-12-28 18:00:00+03',
        '2020-12-28 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2872,
        '2020-12-28 21:00:00+03',
        '2020-12-28 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2873,
        '2020-12-28 21:00:00+03',
        '2020-12-28 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2874,
        '2020-12-28 21:00:00+03',
        '2020-12-28 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2875,
        '2020-12-28 18:00:00+03',
        '2020-12-28 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2876,
        '2020-12-28 21:00:00+03',
        '2020-12-28 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2877,
        '2020-12-28 18:00:00+03',
        '2020-12-28 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2878,
        '2020-12-28 21:00:00+03',
        '2020-12-28 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2879,
        '2020-12-28 19:00:00+03',
        '2020-12-28 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2880,
        '2020-12-28 22:00:00+03',
        '2020-12-28 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2881,
        '2020-12-28 19:00:00+03',
        '2020-12-28 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2882,
        '2020-12-28 22:00:00+03',
        '2020-12-28 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2901,
        '2020-12-29 00:00:00+03',
        '2020-12-29 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2902,
        '2020-12-29 00:00:00+03',
        '2020-12-29 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2903,
        '2020-12-29 01:00:00+03',
        '2020-12-29 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2904,
        '2020-12-29 01:00:00+03',
        '2020-12-29 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2905,
        '2020-12-29 01:00:00+03',
        '2020-12-29 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2906,
        '2020-12-29 01:00:00+03',
        '2020-12-29 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2907,
        '2020-12-29 01:00:00+03',
        '2020-12-29 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2908,
        '2020-12-29 01:00:00+03',
        '2020-12-29 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2909,
        '2020-12-29 01:00:00+03',
        '2020-12-29 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2910,
        '2020-12-29 01:00:00+03',
        '2020-12-29 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2911,
        '2020-12-29 01:00:00+03',
        '2020-12-29 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2912,
        '2020-12-29 01:00:00+03',
        '2020-12-29 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        2913,
        '2020-12-29 01:00:00+03',
        '2020-12-29 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2914,
        '2020-12-29 01:00:00+03',
        '2020-12-29 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2915,
        '2020-12-29 01:00:00+03',
        '2020-12-29 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        2916,
        '2020-12-29 05:00:00+03',
        '2020-12-29 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2917,
        '2020-12-29 04:00:00+03',
        '2020-12-29 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2918,
        '2020-12-29 06:00:00+03',
        '2020-12-29 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2919,
        '2020-12-29 05:00:00+03',
        '2020-12-29 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2920,
        '2020-12-29 06:00:00+03',
        '2020-12-29 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2921,
        '2020-12-29 05:00:00+03',
        '2020-12-29 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2922,
        '2020-12-29 08:00:00+03',
        '2020-12-29 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2923,
        '2020-12-29 09:00:00+03',
        '2020-12-29 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2924,
        '2020-12-29 04:00:00+03',
        '2020-12-29 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2925,
        '2020-12-29 05:00:00+03',
        '2020-12-29 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2926,
        '2020-12-29 08:00:00+03',
        '2020-12-29 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2927,
        '2020-12-29 08:00:00+03',
        '2020-12-29 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2928,
        '2020-12-29 05:00:00+03',
        '2020-12-29 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2929,
        '2020-12-29 06:00:00+03',
        '2020-12-29 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        2930,
        '2020-12-29 05:00:00+03',
        '2020-12-29 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2931,
        '2020-12-29 05:00:00+03',
        '2020-12-29 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2932,
        '2020-12-29 06:00:00+03',
        '2020-12-29 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2933,
        '2020-12-29 09:00:00+03',
        '2020-12-29 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2934,
        '2020-12-29 10:00:00+03',
        '2020-12-29 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2935,
        '2020-12-29 10:00:00+03',
        '2020-12-29 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2936,
        '2020-12-29 12:00:00+03',
        '2020-12-29 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2937,
        '2020-12-29 11:00:00+03',
        '2020-12-29 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2938,
        '2020-12-29 12:00:00+03',
        '2020-12-29 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2939,
        '2020-12-29 11:00:00+03',
        '2020-12-29 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2940,
        '2020-12-29 12:00:00+03',
        '2020-12-29 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2941,
        '2020-12-29 09:00:00+03',
        '2020-12-29 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2942,
        '2020-12-29 10:00:00+03',
        '2020-12-29 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2943,
        '2020-12-29 12:00:00+03',
        '2020-12-29 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2944,
        '2020-12-29 12:00:00+03',
        '2020-12-29 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        2945,
        '2020-12-29 10:00:00+03',
        '2020-12-29 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2946,
        '2020-12-29 11:00:00+03',
        '2020-12-29 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2947,
        '2020-12-29 14:00:00+03',
        '2020-12-29 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2948,
        '2020-12-29 12:00:00+03',
        '2020-12-29 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2949,
        '2020-12-29 12:00:00+03',
        '2020-12-29 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2950,
        '2020-12-29 13:00:00+03',
        '2020-12-29 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2951,
        '2020-12-29 15:00:00+03',
        '2020-12-29 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2952,
        '2020-12-29 16:00:00+03',
        '2020-12-29 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2953,
        '2020-12-29 16:00:00+03',
        '2020-12-29 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2954,
        '2020-12-29 15:00:00+03',
        '2020-12-29 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2955,
        '2020-12-29 15:00:00+03',
        '2020-12-29 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2956,
        '2020-12-29 19:00:00+03',
        '2020-12-29 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2957,
        '2020-12-29 17:00:00+03',
        '2020-12-29 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2958,
        '2020-12-29 17:00:00+03',
        '2020-12-29 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2959,
        '2020-12-29 15:00:00+03',
        '2020-12-29 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2960,
        '2020-12-29 15:00:00+03',
        '2020-12-29 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2961,
        '2020-12-29 17:00:00+03',
        '2020-12-29 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2962,
        '2020-12-29 16:00:00+03',
        '2020-12-29 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2963,
        '2020-12-29 17:00:00+03',
        '2020-12-29 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2964,
        '2020-12-29 16:00:00+03',
        '2020-12-29 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2965,
        '2020-12-29 17:00:00+03',
        '2020-12-29 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        2966,
        '2020-12-29 19:00:00+03',
        '2020-12-29 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2967,
        '2020-12-29 20:00:00+03',
        '2020-12-29 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2968,
        '2020-12-29 20:00:00+03',
        '2020-12-29 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2969,
        '2020-12-29 22:00:00+03',
        '2020-12-29 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        2970,
        '2020-12-29 19:00:00+03',
        '2020-12-29 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2971,
        '2020-12-29 18:00:00+03',
        '2020-12-29 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2972,
        '2020-12-29 21:00:00+03',
        '2020-12-29 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2973,
        '2020-12-29 21:00:00+03',
        '2020-12-29 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2974,
        '2020-12-29 21:00:00+03',
        '2020-12-29 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2975,
        '2020-12-29 18:00:00+03',
        '2020-12-29 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2976,
        '2020-12-29 21:00:00+03',
        '2020-12-29 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2977,
        '2020-12-29 18:00:00+03',
        '2020-12-29 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2978,
        '2020-12-29 21:00:00+03',
        '2020-12-29 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2979,
        '2020-12-29 19:00:00+03',
        '2020-12-29 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        2980,
        '2020-12-29 22:00:00+03',
        '2020-12-29 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2981,
        '2020-12-29 19:00:00+03',
        '2020-12-29 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        2982,
        '2020-12-29 22:00:00+03',
        '2020-12-29 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3001,
        '2020-12-30 00:00:00+03',
        '2020-12-30 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3002,
        '2020-12-30 00:00:00+03',
        '2020-12-30 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3003,
        '2020-12-30 01:00:00+03',
        '2020-12-30 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3004,
        '2020-12-30 01:00:00+03',
        '2020-12-30 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3005,
        '2020-12-30 01:00:00+03',
        '2020-12-30 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3006,
        '2020-12-30 01:00:00+03',
        '2020-12-30 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3007,
        '2020-12-30 01:00:00+03',
        '2020-12-30 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3008,
        '2020-12-30 01:00:00+03',
        '2020-12-30 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3009,
        '2020-12-30 01:00:00+03',
        '2020-12-30 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3010,
        '2020-12-30 01:00:00+03',
        '2020-12-30 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3011,
        '2020-12-30 01:00:00+03',
        '2020-12-30 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3012,
        '2020-12-30 01:00:00+03',
        '2020-12-30 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        3013,
        '2020-12-30 01:00:00+03',
        '2020-12-30 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3014,
        '2020-12-30 01:00:00+03',
        '2020-12-30 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3015,
        '2020-12-30 01:00:00+03',
        '2020-12-30 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        3016,
        '2020-12-30 05:00:00+03',
        '2020-12-30 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3017,
        '2020-12-30 04:00:00+03',
        '2020-12-30 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3018,
        '2020-12-30 06:00:00+03',
        '2020-12-30 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3019,
        '2020-12-30 05:00:00+03',
        '2020-12-30 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3020,
        '2020-12-30 06:00:00+03',
        '2020-12-30 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3021,
        '2020-12-30 05:00:00+03',
        '2020-12-30 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3022,
        '2020-12-30 08:00:00+03',
        '2020-12-30 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3023,
        '2020-12-30 09:00:00+03',
        '2020-12-30 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3024,
        '2020-12-30 04:00:00+03',
        '2020-12-30 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3025,
        '2020-12-30 05:00:00+03',
        '2020-12-30 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3026,
        '2020-12-30 08:00:00+03',
        '2020-12-30 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3027,
        '2020-12-30 08:00:00+03',
        '2020-12-30 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3028,
        '2020-12-30 05:00:00+03',
        '2020-12-30 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3029,
        '2020-12-30 06:00:00+03',
        '2020-12-30 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        3030,
        '2020-12-30 05:00:00+03',
        '2020-12-30 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3031,
        '2020-12-30 05:00:00+03',
        '2020-12-30 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3032,
        '2020-12-30 06:00:00+03',
        '2020-12-30 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3033,
        '2020-12-30 09:00:00+03',
        '2020-12-30 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3034,
        '2020-12-30 10:00:00+03',
        '2020-12-30 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3035,
        '2020-12-30 10:00:00+03',
        '2020-12-30 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3036,
        '2020-12-30 12:00:00+03',
        '2020-12-30 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3037,
        '2020-12-30 11:00:00+03',
        '2020-12-30 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3038,
        '2020-12-30 12:00:00+03',
        '2020-12-30 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3039,
        '2020-12-30 11:00:00+03',
        '2020-12-30 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3040,
        '2020-12-30 12:00:00+03',
        '2020-12-30 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3041,
        '2020-12-30 09:00:00+03',
        '2020-12-30 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3042,
        '2020-12-30 10:00:00+03',
        '2020-12-30 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3043,
        '2020-12-30 12:00:00+03',
        '2020-12-30 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3044,
        '2020-12-30 12:00:00+03',
        '2020-12-30 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3045,
        '2020-12-30 10:00:00+03',
        '2020-12-30 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3046,
        '2020-12-30 11:00:00+03',
        '2020-12-30 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3047,
        '2020-12-30 14:00:00+03',
        '2020-12-30 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3048,
        '2020-12-30 12:00:00+03',
        '2020-12-30 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3049,
        '2020-12-30 12:00:00+03',
        '2020-12-30 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3050,
        '2020-12-30 13:00:00+03',
        '2020-12-30 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3051,
        '2020-12-30 15:00:00+03',
        '2020-12-30 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3052,
        '2020-12-30 16:00:00+03',
        '2020-12-30 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3053,
        '2020-12-30 16:00:00+03',
        '2020-12-30 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3054,
        '2020-12-30 15:00:00+03',
        '2020-12-30 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3055,
        '2020-12-30 15:00:00+03',
        '2020-12-30 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3056,
        '2020-12-30 19:00:00+03',
        '2020-12-30 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3057,
        '2020-12-30 17:00:00+03',
        '2020-12-30 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3058,
        '2020-12-30 17:00:00+03',
        '2020-12-30 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3059,
        '2020-12-30 15:00:00+03',
        '2020-12-30 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3060,
        '2020-12-30 15:00:00+03',
        '2020-12-30 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3061,
        '2020-12-30 17:00:00+03',
        '2020-12-30 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3062,
        '2020-12-30 16:00:00+03',
        '2020-12-30 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3063,
        '2020-12-30 17:00:00+03',
        '2020-12-30 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3064,
        '2020-12-30 16:00:00+03',
        '2020-12-30 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3065,
        '2020-12-30 17:00:00+03',
        '2020-12-30 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        3066,
        '2020-12-30 19:00:00+03',
        '2020-12-30 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3067,
        '2020-12-30 20:00:00+03',
        '2020-12-30 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3068,
        '2020-12-30 20:00:00+03',
        '2020-12-30 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3069,
        '2020-12-30 22:00:00+03',
        '2020-12-30 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3070,
        '2020-12-30 19:00:00+03',
        '2020-12-30 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3071,
        '2020-12-30 18:00:00+03',
        '2020-12-30 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3072,
        '2020-12-30 21:00:00+03',
        '2020-12-30 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3073,
        '2020-12-30 21:00:00+03',
        '2020-12-30 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3074,
        '2020-12-30 21:00:00+03',
        '2020-12-30 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3075,
        '2020-12-30 18:00:00+03',
        '2020-12-30 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3076,
        '2020-12-30 21:00:00+03',
        '2020-12-30 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3077,
        '2020-12-30 18:00:00+03',
        '2020-12-30 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3078,
        '2020-12-30 21:00:00+03',
        '2020-12-30 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3079,
        '2020-12-30 19:00:00+03',
        '2020-12-30 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3080,
        '2020-12-30 22:00:00+03',
        '2020-12-30 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3081,
        '2020-12-30 19:00:00+03',
        '2020-12-30 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3082,
        '2020-12-30 22:00:00+03',
        '2020-12-30 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3101,
        '2020-12-31 00:00:00+03',
        '2020-12-31 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3102,
        '2020-12-31 00:00:00+03',
        '2020-12-31 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3103,
        '2020-12-31 01:00:00+03',
        '2020-12-31 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3104,
        '2020-12-31 01:00:00+03',
        '2020-12-31 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3105,
        '2020-12-31 01:00:00+03',
        '2020-12-31 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3106,
        '2020-12-31 01:00:00+03',
        '2020-12-31 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3107,
        '2020-12-31 01:00:00+03',
        '2020-12-31 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3108,
        '2020-12-31 01:00:00+03',
        '2020-12-31 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3109,
        '2020-12-31 01:00:00+03',
        '2020-12-31 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3110,
        '2020-12-31 01:00:00+03',
        '2020-12-31 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3111,
        '2020-12-31 01:00:00+03',
        '2020-12-31 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3112,
        '2020-12-31 01:00:00+03',
        '2020-12-31 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        3113,
        '2020-12-31 01:00:00+03',
        '2020-12-31 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3114,
        '2020-12-31 01:00:00+03',
        '2020-12-31 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3115,
        '2020-12-31 01:00:00+03',
        '2020-12-31 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        3116,
        '2020-12-31 05:00:00+03',
        '2020-12-31 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3117,
        '2020-12-31 04:00:00+03',
        '2020-12-31 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3118,
        '2020-12-31 06:00:00+03',
        '2020-12-31 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3119,
        '2020-12-31 05:00:00+03',
        '2020-12-31 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3120,
        '2020-12-31 06:00:00+03',
        '2020-12-31 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3121,
        '2020-12-31 05:00:00+03',
        '2020-12-31 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3122,
        '2020-12-31 08:00:00+03',
        '2020-12-31 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3123,
        '2020-12-31 09:00:00+03',
        '2020-12-31 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3124,
        '2020-12-31 04:00:00+03',
        '2020-12-31 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3125,
        '2020-12-31 05:00:00+03',
        '2020-12-31 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3126,
        '2020-12-31 08:00:00+03',
        '2020-12-31 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3127,
        '2020-12-31 08:00:00+03',
        '2020-12-31 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3128,
        '2020-12-31 05:00:00+03',
        '2020-12-31 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3129,
        '2020-12-31 06:00:00+03',
        '2020-12-31 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        3130,
        '2020-12-31 05:00:00+03',
        '2020-12-31 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3131,
        '2020-12-31 05:00:00+03',
        '2020-12-31 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3132,
        '2020-12-31 06:00:00+03',
        '2020-12-31 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3133,
        '2020-12-31 09:00:00+03',
        '2020-12-31 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3134,
        '2020-12-31 10:00:00+03',
        '2020-12-31 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3135,
        '2020-12-31 10:00:00+03',
        '2020-12-31 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3136,
        '2020-12-31 12:00:00+03',
        '2020-12-31 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3137,
        '2020-12-31 11:00:00+03',
        '2020-12-31 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3138,
        '2020-12-31 12:00:00+03',
        '2020-12-31 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3139,
        '2020-12-31 11:00:00+03',
        '2020-12-31 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3140,
        '2020-12-31 12:00:00+03',
        '2020-12-31 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3141,
        '2020-12-31 09:00:00+03',
        '2020-12-31 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3142,
        '2020-12-31 10:00:00+03',
        '2020-12-31 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3143,
        '2020-12-31 12:00:00+03',
        '2020-12-31 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3144,
        '2020-12-31 12:00:00+03',
        '2020-12-31 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3145,
        '2020-12-31 10:00:00+03',
        '2020-12-31 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3146,
        '2020-12-31 11:00:00+03',
        '2020-12-31 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3147,
        '2020-12-31 14:00:00+03',
        '2020-12-31 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3148,
        '2020-12-31 12:00:00+03',
        '2020-12-31 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3149,
        '2020-12-31 12:00:00+03',
        '2020-12-31 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3150,
        '2020-12-31 13:00:00+03',
        '2020-12-31 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3151,
        '2020-12-31 15:00:00+03',
        '2020-12-31 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3152,
        '2020-12-31 16:00:00+03',
        '2020-12-31 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3153,
        '2020-12-31 16:00:00+03',
        '2020-12-31 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3154,
        '2020-12-31 15:00:00+03',
        '2020-12-31 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3155,
        '2020-12-31 15:00:00+03',
        '2020-12-31 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3156,
        '2020-12-31 19:00:00+03',
        '2020-12-31 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3157,
        '2020-12-31 17:00:00+03',
        '2020-12-31 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3158,
        '2020-12-31 17:00:00+03',
        '2020-12-31 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3159,
        '2020-12-31 15:00:00+03',
        '2020-12-31 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3160,
        '2020-12-31 15:00:00+03',
        '2020-12-31 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3161,
        '2020-12-31 17:00:00+03',
        '2020-12-31 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3162,
        '2020-12-31 16:00:00+03',
        '2020-12-31 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3163,
        '2020-12-31 17:00:00+03',
        '2020-12-31 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3164,
        '2020-12-31 16:00:00+03',
        '2020-12-31 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3165,
        '2020-12-31 17:00:00+03',
        '2020-12-31 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        3166,
        '2020-12-31 19:00:00+03',
        '2020-12-31 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3167,
        '2020-12-31 20:00:00+03',
        '2020-12-31 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3168,
        '2020-12-31 20:00:00+03',
        '2020-12-31 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3169,
        '2020-12-31 22:00:00+03',
        '2020-12-31 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3170,
        '2020-12-31 19:00:00+03',
        '2020-12-31 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3171,
        '2020-12-31 18:00:00+03',
        '2020-12-31 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3172,
        '2020-12-31 21:00:00+03',
        '2020-12-31 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3173,
        '2020-12-31 21:00:00+03',
        '2020-12-31 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3174,
        '2020-12-31 21:00:00+03',
        '2020-12-31 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3175,
        '2020-12-31 18:00:00+03',
        '2020-12-31 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3176,
        '2020-12-31 21:00:00+03',
        '2020-12-31 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3177,
        '2020-12-31 18:00:00+03',
        '2020-12-31 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3178,
        '2020-12-31 21:00:00+03',
        '2020-12-31 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3179,
        '2020-12-31 19:00:00+03',
        '2020-12-31 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3180,
        '2020-12-31 22:00:00+03',
        '2020-12-31 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3181,
        '2020-12-31 19:00:00+03',
        '2020-12-31 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3182,
        '2020-12-31 22:00:00+03',
        '2020-12-31 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3201,
        '2021-01-01 00:00:00+03',
        '2021-01-01 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3202,
        '2021-01-01 00:00:00+03',
        '2021-01-01 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3203,
        '2021-01-01 01:00:00+03',
        '2021-01-01 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3204,
        '2021-01-01 01:00:00+03',
        '2021-01-01 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3205,
        '2021-01-01 01:00:00+03',
        '2021-01-01 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3206,
        '2021-01-01 01:00:00+03',
        '2021-01-01 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3207,
        '2021-01-01 01:00:00+03',
        '2021-01-01 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3208,
        '2021-01-01 01:00:00+03',
        '2021-01-01 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3209,
        '2021-01-01 01:00:00+03',
        '2021-01-01 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3210,
        '2021-01-01 01:00:00+03',
        '2021-01-01 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3211,
        '2021-01-01 01:00:00+03',
        '2021-01-01 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3212,
        '2021-01-01 01:00:00+03',
        '2021-01-01 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        3213,
        '2021-01-01 01:00:00+03',
        '2021-01-01 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3214,
        '2021-01-01 01:00:00+03',
        '2021-01-01 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3215,
        '2021-01-01 01:00:00+03',
        '2021-01-01 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        3216,
        '2021-01-01 05:00:00+03',
        '2021-01-01 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3217,
        '2021-01-01 04:00:00+03',
        '2021-01-01 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3218,
        '2021-01-01 06:00:00+03',
        '2021-01-01 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3219,
        '2021-01-01 05:00:00+03',
        '2021-01-01 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3220,
        '2021-01-01 06:00:00+03',
        '2021-01-01 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3221,
        '2021-01-01 05:00:00+03',
        '2021-01-01 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3222,
        '2021-01-01 08:00:00+03',
        '2021-01-01 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3223,
        '2021-01-01 09:00:00+03',
        '2021-01-01 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3224,
        '2021-01-01 04:00:00+03',
        '2021-01-01 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3225,
        '2021-01-01 05:00:00+03',
        '2021-01-01 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3226,
        '2021-01-01 08:00:00+03',
        '2021-01-01 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3227,
        '2021-01-01 08:00:00+03',
        '2021-01-01 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3228,
        '2021-01-01 05:00:00+03',
        '2021-01-01 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3229,
        '2021-01-01 06:00:00+03',
        '2021-01-01 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        3230,
        '2021-01-01 05:00:00+03',
        '2021-01-01 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3231,
        '2021-01-01 05:00:00+03',
        '2021-01-01 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3232,
        '2021-01-01 06:00:00+03',
        '2021-01-01 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3233,
        '2021-01-01 09:00:00+03',
        '2021-01-01 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3234,
        '2021-01-01 10:00:00+03',
        '2021-01-01 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3235,
        '2021-01-01 10:00:00+03',
        '2021-01-01 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3236,
        '2021-01-01 12:00:00+03',
        '2021-01-01 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3237,
        '2021-01-01 11:00:00+03',
        '2021-01-01 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3238,
        '2021-01-01 12:00:00+03',
        '2021-01-01 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3239,
        '2021-01-01 11:00:00+03',
        '2021-01-01 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3240,
        '2021-01-01 12:00:00+03',
        '2021-01-01 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3241,
        '2021-01-01 09:00:00+03',
        '2021-01-01 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3242,
        '2021-01-01 10:00:00+03',
        '2021-01-01 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3243,
        '2021-01-01 12:00:00+03',
        '2021-01-01 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3244,
        '2021-01-01 12:00:00+03',
        '2021-01-01 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3245,
        '2021-01-01 10:00:00+03',
        '2021-01-01 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3246,
        '2021-01-01 11:00:00+03',
        '2021-01-01 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3247,
        '2021-01-01 14:00:00+03',
        '2021-01-01 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3248,
        '2021-01-01 12:00:00+03',
        '2021-01-01 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3249,
        '2021-01-01 12:00:00+03',
        '2021-01-01 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3250,
        '2021-01-01 13:00:00+03',
        '2021-01-01 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3251,
        '2021-01-01 15:00:00+03',
        '2021-01-01 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3252,
        '2021-01-01 16:00:00+03',
        '2021-01-01 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3253,
        '2021-01-01 16:00:00+03',
        '2021-01-01 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3254,
        '2021-01-01 15:00:00+03',
        '2021-01-01 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3255,
        '2021-01-01 15:00:00+03',
        '2021-01-01 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3256,
        '2021-01-01 19:00:00+03',
        '2021-01-01 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3257,
        '2021-01-01 17:00:00+03',
        '2021-01-01 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3258,
        '2021-01-01 17:00:00+03',
        '2021-01-01 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3259,
        '2021-01-01 15:00:00+03',
        '2021-01-01 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3260,
        '2021-01-01 15:00:00+03',
        '2021-01-01 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3261,
        '2021-01-01 17:00:00+03',
        '2021-01-01 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3262,
        '2021-01-01 16:00:00+03',
        '2021-01-01 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3263,
        '2021-01-01 17:00:00+03',
        '2021-01-01 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3264,
        '2021-01-01 16:00:00+03',
        '2021-01-01 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3265,
        '2021-01-01 17:00:00+03',
        '2021-01-01 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        3266,
        '2021-01-01 19:00:00+03',
        '2021-01-01 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3267,
        '2021-01-01 20:00:00+03',
        '2021-01-01 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3268,
        '2021-01-01 20:00:00+03',
        '2021-01-01 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3269,
        '2021-01-01 22:00:00+03',
        '2021-01-01 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3270,
        '2021-01-01 19:00:00+03',
        '2021-01-01 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3271,
        '2021-01-01 18:00:00+03',
        '2021-01-01 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3272,
        '2021-01-01 21:00:00+03',
        '2021-01-01 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3273,
        '2021-01-01 21:00:00+03',
        '2021-01-01 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3274,
        '2021-01-01 21:00:00+03',
        '2021-01-01 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3275,
        '2021-01-01 18:00:00+03',
        '2021-01-01 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3276,
        '2021-01-01 21:00:00+03',
        '2021-01-01 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3277,
        '2021-01-01 18:00:00+03',
        '2021-01-01 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3278,
        '2021-01-01 21:00:00+03',
        '2021-01-01 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3279,
        '2021-01-01 19:00:00+03',
        '2021-01-01 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3280,
        '2021-01-01 22:00:00+03',
        '2021-01-01 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3281,
        '2021-01-01 19:00:00+03',
        '2021-01-01 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3282,
        '2021-01-01 22:00:00+03',
        '2021-01-01 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3301,
        '2021-01-02 00:00:00+03',
        '2021-01-02 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3302,
        '2021-01-02 00:00:00+03',
        '2021-01-02 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3303,
        '2021-01-02 01:00:00+03',
        '2021-01-02 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3304,
        '2021-01-02 01:00:00+03',
        '2021-01-02 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3305,
        '2021-01-02 01:00:00+03',
        '2021-01-02 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3306,
        '2021-01-02 01:00:00+03',
        '2021-01-02 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3307,
        '2021-01-02 01:00:00+03',
        '2021-01-02 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3308,
        '2021-01-02 01:00:00+03',
        '2021-01-02 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3309,
        '2021-01-02 01:00:00+03',
        '2021-01-02 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3310,
        '2021-01-02 01:00:00+03',
        '2021-01-02 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3311,
        '2021-01-02 01:00:00+03',
        '2021-01-02 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3312,
        '2021-01-02 01:00:00+03',
        '2021-01-02 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        3313,
        '2021-01-02 01:00:00+03',
        '2021-01-02 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3314,
        '2021-01-02 01:00:00+03',
        '2021-01-02 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3315,
        '2021-01-02 01:00:00+03',
        '2021-01-02 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        3316,
        '2021-01-02 05:00:00+03',
        '2021-01-02 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3317,
        '2021-01-02 04:00:00+03',
        '2021-01-02 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3318,
        '2021-01-02 06:00:00+03',
        '2021-01-02 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3319,
        '2021-01-02 05:00:00+03',
        '2021-01-02 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3320,
        '2021-01-02 06:00:00+03',
        '2021-01-02 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3321,
        '2021-01-02 05:00:00+03',
        '2021-01-02 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3322,
        '2021-01-02 08:00:00+03',
        '2021-01-02 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3323,
        '2021-01-02 09:00:00+03',
        '2021-01-02 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3324,
        '2021-01-02 04:00:00+03',
        '2021-01-02 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3325,
        '2021-01-02 05:00:00+03',
        '2021-01-02 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3326,
        '2021-01-02 08:00:00+03',
        '2021-01-02 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3327,
        '2021-01-02 08:00:00+03',
        '2021-01-02 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3328,
        '2021-01-02 05:00:00+03',
        '2021-01-02 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3329,
        '2021-01-02 06:00:00+03',
        '2021-01-02 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        3330,
        '2021-01-02 05:00:00+03',
        '2021-01-02 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3331,
        '2021-01-02 05:00:00+03',
        '2021-01-02 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3332,
        '2021-01-02 06:00:00+03',
        '2021-01-02 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3333,
        '2021-01-02 09:00:00+03',
        '2021-01-02 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3334,
        '2021-01-02 10:00:00+03',
        '2021-01-02 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3335,
        '2021-01-02 10:00:00+03',
        '2021-01-02 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3336,
        '2021-01-02 12:00:00+03',
        '2021-01-02 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3337,
        '2021-01-02 11:00:00+03',
        '2021-01-02 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3338,
        '2021-01-02 12:00:00+03',
        '2021-01-02 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3339,
        '2021-01-02 11:00:00+03',
        '2021-01-02 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3340,
        '2021-01-02 12:00:00+03',
        '2021-01-02 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3341,
        '2021-01-02 09:00:00+03',
        '2021-01-02 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3342,
        '2021-01-02 10:00:00+03',
        '2021-01-02 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3343,
        '2021-01-02 12:00:00+03',
        '2021-01-02 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3344,
        '2021-01-02 12:00:00+03',
        '2021-01-02 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3345,
        '2021-01-02 10:00:00+03',
        '2021-01-02 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3346,
        '2021-01-02 11:00:00+03',
        '2021-01-02 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3347,
        '2021-01-02 14:00:00+03',
        '2021-01-02 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3348,
        '2021-01-02 12:00:00+03',
        '2021-01-02 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3349,
        '2021-01-02 12:00:00+03',
        '2021-01-02 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3350,
        '2021-01-02 13:00:00+03',
        '2021-01-02 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3351,
        '2021-01-02 15:00:00+03',
        '2021-01-02 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3352,
        '2021-01-02 16:00:00+03',
        '2021-01-02 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3353,
        '2021-01-02 16:00:00+03',
        '2021-01-02 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3354,
        '2021-01-02 15:00:00+03',
        '2021-01-02 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3355,
        '2021-01-02 15:00:00+03',
        '2021-01-02 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3356,
        '2021-01-02 19:00:00+03',
        '2021-01-02 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3357,
        '2021-01-02 17:00:00+03',
        '2021-01-02 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3358,
        '2021-01-02 17:00:00+03',
        '2021-01-02 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3359,
        '2021-01-02 15:00:00+03',
        '2021-01-02 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3360,
        '2021-01-02 15:00:00+03',
        '2021-01-02 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3361,
        '2021-01-02 17:00:00+03',
        '2021-01-02 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3362,
        '2021-01-02 16:00:00+03',
        '2021-01-02 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3363,
        '2021-01-02 17:00:00+03',
        '2021-01-02 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3364,
        '2021-01-02 16:00:00+03',
        '2021-01-02 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3365,
        '2021-01-02 17:00:00+03',
        '2021-01-02 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        3366,
        '2021-01-02 19:00:00+03',
        '2021-01-02 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3367,
        '2021-01-02 20:00:00+03',
        '2021-01-02 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3368,
        '2021-01-02 20:00:00+03',
        '2021-01-02 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3369,
        '2021-01-02 22:00:00+03',
        '2021-01-02 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3370,
        '2021-01-02 19:00:00+03',
        '2021-01-02 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3371,
        '2021-01-02 18:00:00+03',
        '2021-01-02 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3372,
        '2021-01-02 21:00:00+03',
        '2021-01-02 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3373,
        '2021-01-02 21:00:00+03',
        '2021-01-02 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3374,
        '2021-01-02 21:00:00+03',
        '2021-01-02 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3375,
        '2021-01-02 18:00:00+03',
        '2021-01-02 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3376,
        '2021-01-02 21:00:00+03',
        '2021-01-02 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3377,
        '2021-01-02 18:00:00+03',
        '2021-01-02 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3378,
        '2021-01-02 21:00:00+03',
        '2021-01-02 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3379,
        '2021-01-02 19:00:00+03',
        '2021-01-02 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3380,
        '2021-01-02 22:00:00+03',
        '2021-01-02 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3381,
        '2021-01-02 19:00:00+03',
        '2021-01-02 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3382,
        '2021-01-02 22:00:00+03',
        '2021-01-02 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3401,
        '2021-01-03 00:00:00+03',
        '2021-01-03 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3402,
        '2021-01-03 00:00:00+03',
        '2021-01-03 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3403,
        '2021-01-03 01:00:00+03',
        '2021-01-03 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3404,
        '2021-01-03 01:00:00+03',
        '2021-01-03 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3405,
        '2021-01-03 01:00:00+03',
        '2021-01-03 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3406,
        '2021-01-03 01:00:00+03',
        '2021-01-03 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3407,
        '2021-01-03 01:00:00+03',
        '2021-01-03 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3408,
        '2021-01-03 01:00:00+03',
        '2021-01-03 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3409,
        '2021-01-03 01:00:00+03',
        '2021-01-03 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3410,
        '2021-01-03 01:00:00+03',
        '2021-01-03 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3411,
        '2021-01-03 01:00:00+03',
        '2021-01-03 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3412,
        '2021-01-03 01:00:00+03',
        '2021-01-03 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        3413,
        '2021-01-03 01:00:00+03',
        '2021-01-03 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3414,
        '2021-01-03 01:00:00+03',
        '2021-01-03 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3415,
        '2021-01-03 01:00:00+03',
        '2021-01-03 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        3416,
        '2021-01-03 05:00:00+03',
        '2021-01-03 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3417,
        '2021-01-03 04:00:00+03',
        '2021-01-03 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3418,
        '2021-01-03 06:00:00+03',
        '2021-01-03 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3419,
        '2021-01-03 05:00:00+03',
        '2021-01-03 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3420,
        '2021-01-03 06:00:00+03',
        '2021-01-03 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3421,
        '2021-01-03 05:00:00+03',
        '2021-01-03 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3422,
        '2021-01-03 08:00:00+03',
        '2021-01-03 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3423,
        '2021-01-03 09:00:00+03',
        '2021-01-03 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3424,
        '2021-01-03 04:00:00+03',
        '2021-01-03 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3425,
        '2021-01-03 05:00:00+03',
        '2021-01-03 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3426,
        '2021-01-03 08:00:00+03',
        '2021-01-03 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3427,
        '2021-01-03 08:00:00+03',
        '2021-01-03 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3428,
        '2021-01-03 05:00:00+03',
        '2021-01-03 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3429,
        '2021-01-03 06:00:00+03',
        '2021-01-03 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        3430,
        '2021-01-03 05:00:00+03',
        '2021-01-03 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3431,
        '2021-01-03 05:00:00+03',
        '2021-01-03 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3432,
        '2021-01-03 06:00:00+03',
        '2021-01-03 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3433,
        '2021-01-03 09:00:00+03',
        '2021-01-03 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3434,
        '2021-01-03 10:00:00+03',
        '2021-01-03 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3435,
        '2021-01-03 10:00:00+03',
        '2021-01-03 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3436,
        '2021-01-03 12:00:00+03',
        '2021-01-03 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3437,
        '2021-01-03 11:00:00+03',
        '2021-01-03 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3438,
        '2021-01-03 12:00:00+03',
        '2021-01-03 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3439,
        '2021-01-03 11:00:00+03',
        '2021-01-03 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3440,
        '2021-01-03 12:00:00+03',
        '2021-01-03 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3441,
        '2021-01-03 09:00:00+03',
        '2021-01-03 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3442,
        '2021-01-03 10:00:00+03',
        '2021-01-03 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3443,
        '2021-01-03 12:00:00+03',
        '2021-01-03 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3444,
        '2021-01-03 12:00:00+03',
        '2021-01-03 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3445,
        '2021-01-03 10:00:00+03',
        '2021-01-03 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3446,
        '2021-01-03 11:00:00+03',
        '2021-01-03 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3447,
        '2021-01-03 14:00:00+03',
        '2021-01-03 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3448,
        '2021-01-03 12:00:00+03',
        '2021-01-03 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3449,
        '2021-01-03 12:00:00+03',
        '2021-01-03 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3450,
        '2021-01-03 13:00:00+03',
        '2021-01-03 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3451,
        '2021-01-03 15:00:00+03',
        '2021-01-03 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3452,
        '2021-01-03 16:00:00+03',
        '2021-01-03 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3453,
        '2021-01-03 16:00:00+03',
        '2021-01-03 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3454,
        '2021-01-03 15:00:00+03',
        '2021-01-03 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3455,
        '2021-01-03 15:00:00+03',
        '2021-01-03 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3456,
        '2021-01-03 19:00:00+03',
        '2021-01-03 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3457,
        '2021-01-03 17:00:00+03',
        '2021-01-03 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3458,
        '2021-01-03 17:00:00+03',
        '2021-01-03 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3459,
        '2021-01-03 15:00:00+03',
        '2021-01-03 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3460,
        '2021-01-03 15:00:00+03',
        '2021-01-03 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3461,
        '2021-01-03 17:00:00+03',
        '2021-01-03 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3462,
        '2021-01-03 16:00:00+03',
        '2021-01-03 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3463,
        '2021-01-03 17:00:00+03',
        '2021-01-03 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3464,
        '2021-01-03 16:00:00+03',
        '2021-01-03 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3465,
        '2021-01-03 17:00:00+03',
        '2021-01-03 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        3466,
        '2021-01-03 19:00:00+03',
        '2021-01-03 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3467,
        '2021-01-03 20:00:00+03',
        '2021-01-03 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3468,
        '2021-01-03 20:00:00+03',
        '2021-01-03 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3469,
        '2021-01-03 22:00:00+03',
        '2021-01-03 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3470,
        '2021-01-03 19:00:00+03',
        '2021-01-03 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3471,
        '2021-01-03 18:00:00+03',
        '2021-01-03 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3472,
        '2021-01-03 21:00:00+03',
        '2021-01-03 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3473,
        '2021-01-03 21:00:00+03',
        '2021-01-03 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3474,
        '2021-01-03 21:00:00+03',
        '2021-01-03 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3475,
        '2021-01-03 18:00:00+03',
        '2021-01-03 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3476,
        '2021-01-03 21:00:00+03',
        '2021-01-03 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3477,
        '2021-01-03 18:00:00+03',
        '2021-01-03 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3478,
        '2021-01-03 21:00:00+03',
        '2021-01-03 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3479,
        '2021-01-03 19:00:00+03',
        '2021-01-03 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3480,
        '2021-01-03 22:00:00+03',
        '2021-01-03 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3481,
        '2021-01-03 19:00:00+03',
        '2021-01-03 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3482,
        '2021-01-03 22:00:00+03',
        '2021-01-03 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3501,
        '2021-01-04 00:00:00+03',
        '2021-01-04 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3502,
        '2021-01-04 00:00:00+03',
        '2021-01-04 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3503,
        '2021-01-04 01:00:00+03',
        '2021-01-04 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3504,
        '2021-01-04 01:00:00+03',
        '2021-01-04 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3505,
        '2021-01-04 01:00:00+03',
        '2021-01-04 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3506,
        '2021-01-04 01:00:00+03',
        '2021-01-04 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3507,
        '2021-01-04 01:00:00+03',
        '2021-01-04 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3508,
        '2021-01-04 01:00:00+03',
        '2021-01-04 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3509,
        '2021-01-04 01:00:00+03',
        '2021-01-04 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3510,
        '2021-01-04 01:00:00+03',
        '2021-01-04 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3511,
        '2021-01-04 01:00:00+03',
        '2021-01-04 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3512,
        '2021-01-04 01:00:00+03',
        '2021-01-04 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        3513,
        '2021-01-04 01:00:00+03',
        '2021-01-04 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3514,
        '2021-01-04 01:00:00+03',
        '2021-01-04 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3515,
        '2021-01-04 01:00:00+03',
        '2021-01-04 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        3516,
        '2021-01-04 05:00:00+03',
        '2021-01-04 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3517,
        '2021-01-04 04:00:00+03',
        '2021-01-04 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3518,
        '2021-01-04 06:00:00+03',
        '2021-01-04 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3519,
        '2021-01-04 05:00:00+03',
        '2021-01-04 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3520,
        '2021-01-04 06:00:00+03',
        '2021-01-04 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3521,
        '2021-01-04 05:00:00+03',
        '2021-01-04 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3522,
        '2021-01-04 08:00:00+03',
        '2021-01-04 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3523,
        '2021-01-04 09:00:00+03',
        '2021-01-04 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3524,
        '2021-01-04 04:00:00+03',
        '2021-01-04 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3525,
        '2021-01-04 05:00:00+03',
        '2021-01-04 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3526,
        '2021-01-04 08:00:00+03',
        '2021-01-04 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3527,
        '2021-01-04 08:00:00+03',
        '2021-01-04 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3528,
        '2021-01-04 05:00:00+03',
        '2021-01-04 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3529,
        '2021-01-04 06:00:00+03',
        '2021-01-04 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        3530,
        '2021-01-04 05:00:00+03',
        '2021-01-04 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3531,
        '2021-01-04 05:00:00+03',
        '2021-01-04 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3532,
        '2021-01-04 06:00:00+03',
        '2021-01-04 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3533,
        '2021-01-04 09:00:00+03',
        '2021-01-04 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3534,
        '2021-01-04 10:00:00+03',
        '2021-01-04 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3535,
        '2021-01-04 10:00:00+03',
        '2021-01-04 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3536,
        '2021-01-04 12:00:00+03',
        '2021-01-04 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3537,
        '2021-01-04 11:00:00+03',
        '2021-01-04 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3538,
        '2021-01-04 12:00:00+03',
        '2021-01-04 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3539,
        '2021-01-04 11:00:00+03',
        '2021-01-04 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3540,
        '2021-01-04 12:00:00+03',
        '2021-01-04 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3541,
        '2021-01-04 09:00:00+03',
        '2021-01-04 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3542,
        '2021-01-04 10:00:00+03',
        '2021-01-04 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3543,
        '2021-01-04 12:00:00+03',
        '2021-01-04 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3544,
        '2021-01-04 12:00:00+03',
        '2021-01-04 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3545,
        '2021-01-04 10:00:00+03',
        '2021-01-04 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3546,
        '2021-01-04 11:00:00+03',
        '2021-01-04 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3547,
        '2021-01-04 14:00:00+03',
        '2021-01-04 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3548,
        '2021-01-04 12:00:00+03',
        '2021-01-04 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3549,
        '2021-01-04 12:00:00+03',
        '2021-01-04 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3550,
        '2021-01-04 13:00:00+03',
        '2021-01-04 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3551,
        '2021-01-04 15:00:00+03',
        '2021-01-04 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3552,
        '2021-01-04 16:00:00+03',
        '2021-01-04 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3553,
        '2021-01-04 16:00:00+03',
        '2021-01-04 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3554,
        '2021-01-04 15:00:00+03',
        '2021-01-04 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3555,
        '2021-01-04 15:00:00+03',
        '2021-01-04 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3556,
        '2021-01-04 19:00:00+03',
        '2021-01-04 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3557,
        '2021-01-04 17:00:00+03',
        '2021-01-04 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3558,
        '2021-01-04 17:00:00+03',
        '2021-01-04 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3559,
        '2021-01-04 15:00:00+03',
        '2021-01-04 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3560,
        '2021-01-04 15:00:00+03',
        '2021-01-04 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3561,
        '2021-01-04 17:00:00+03',
        '2021-01-04 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3562,
        '2021-01-04 16:00:00+03',
        '2021-01-04 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3563,
        '2021-01-04 17:00:00+03',
        '2021-01-04 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3564,
        '2021-01-04 16:00:00+03',
        '2021-01-04 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3565,
        '2021-01-04 17:00:00+03',
        '2021-01-04 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        3566,
        '2021-01-04 19:00:00+03',
        '2021-01-04 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3567,
        '2021-01-04 20:00:00+03',
        '2021-01-04 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3568,
        '2021-01-04 20:00:00+03',
        '2021-01-04 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3569,
        '2021-01-04 22:00:00+03',
        '2021-01-04 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3570,
        '2021-01-04 19:00:00+03',
        '2021-01-04 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3571,
        '2021-01-04 18:00:00+03',
        '2021-01-04 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3572,
        '2021-01-04 21:00:00+03',
        '2021-01-04 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3573,
        '2021-01-04 21:00:00+03',
        '2021-01-04 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3574,
        '2021-01-04 21:00:00+03',
        '2021-01-04 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3575,
        '2021-01-04 18:00:00+03',
        '2021-01-04 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3576,
        '2021-01-04 21:00:00+03',
        '2021-01-04 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3577,
        '2021-01-04 18:00:00+03',
        '2021-01-04 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3578,
        '2021-01-04 21:00:00+03',
        '2021-01-04 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3579,
        '2021-01-04 19:00:00+03',
        '2021-01-04 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3580,
        '2021-01-04 22:00:00+03',
        '2021-01-04 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3581,
        '2021-01-04 19:00:00+03',
        '2021-01-04 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3582,
        '2021-01-04 22:00:00+03',
        '2021-01-04 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3601,
        '2021-01-05 00:00:00+03',
        '2021-01-05 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3602,
        '2021-01-05 00:00:00+03',
        '2021-01-05 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3603,
        '2021-01-05 01:00:00+03',
        '2021-01-05 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3604,
        '2021-01-05 01:00:00+03',
        '2021-01-05 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3605,
        '2021-01-05 01:00:00+03',
        '2021-01-05 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3606,
        '2021-01-05 01:00:00+03',
        '2021-01-05 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3607,
        '2021-01-05 01:00:00+03',
        '2021-01-05 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3608,
        '2021-01-05 01:00:00+03',
        '2021-01-05 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3609,
        '2021-01-05 01:00:00+03',
        '2021-01-05 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3610,
        '2021-01-05 01:00:00+03',
        '2021-01-05 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3611,
        '2021-01-05 01:00:00+03',
        '2021-01-05 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3612,
        '2021-01-05 01:00:00+03',
        '2021-01-05 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        3613,
        '2021-01-05 01:00:00+03',
        '2021-01-05 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3614,
        '2021-01-05 01:00:00+03',
        '2021-01-05 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3615,
        '2021-01-05 01:00:00+03',
        '2021-01-05 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        3616,
        '2021-01-05 05:00:00+03',
        '2021-01-05 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3617,
        '2021-01-05 04:00:00+03',
        '2021-01-05 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3618,
        '2021-01-05 06:00:00+03',
        '2021-01-05 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3619,
        '2021-01-05 05:00:00+03',
        '2021-01-05 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3620,
        '2021-01-05 06:00:00+03',
        '2021-01-05 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3621,
        '2021-01-05 05:00:00+03',
        '2021-01-05 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3622,
        '2021-01-05 08:00:00+03',
        '2021-01-05 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3623,
        '2021-01-05 09:00:00+03',
        '2021-01-05 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3624,
        '2021-01-05 04:00:00+03',
        '2021-01-05 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3625,
        '2021-01-05 05:00:00+03',
        '2021-01-05 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3626,
        '2021-01-05 08:00:00+03',
        '2021-01-05 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3627,
        '2021-01-05 08:00:00+03',
        '2021-01-05 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3628,
        '2021-01-05 05:00:00+03',
        '2021-01-05 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3629,
        '2021-01-05 06:00:00+03',
        '2021-01-05 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        3630,
        '2021-01-05 05:00:00+03',
        '2021-01-05 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3631,
        '2021-01-05 05:00:00+03',
        '2021-01-05 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3632,
        '2021-01-05 06:00:00+03',
        '2021-01-05 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3633,
        '2021-01-05 09:00:00+03',
        '2021-01-05 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3634,
        '2021-01-05 10:00:00+03',
        '2021-01-05 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3635,
        '2021-01-05 10:00:00+03',
        '2021-01-05 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3636,
        '2021-01-05 12:00:00+03',
        '2021-01-05 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3637,
        '2021-01-05 11:00:00+03',
        '2021-01-05 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3638,
        '2021-01-05 12:00:00+03',
        '2021-01-05 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3639,
        '2021-01-05 11:00:00+03',
        '2021-01-05 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3640,
        '2021-01-05 12:00:00+03',
        '2021-01-05 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3641,
        '2021-01-05 09:00:00+03',
        '2021-01-05 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3642,
        '2021-01-05 10:00:00+03',
        '2021-01-05 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3643,
        '2021-01-05 12:00:00+03',
        '2021-01-05 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3644,
        '2021-01-05 12:00:00+03',
        '2021-01-05 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3645,
        '2021-01-05 10:00:00+03',
        '2021-01-05 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3646,
        '2021-01-05 11:00:00+03',
        '2021-01-05 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3647,
        '2021-01-05 14:00:00+03',
        '2021-01-05 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3648,
        '2021-01-05 12:00:00+03',
        '2021-01-05 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3649,
        '2021-01-05 12:00:00+03',
        '2021-01-05 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3650,
        '2021-01-05 13:00:00+03',
        '2021-01-05 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3651,
        '2021-01-05 15:00:00+03',
        '2021-01-05 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3652,
        '2021-01-05 16:00:00+03',
        '2021-01-05 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3653,
        '2021-01-05 16:00:00+03',
        '2021-01-05 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3654,
        '2021-01-05 15:00:00+03',
        '2021-01-05 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3655,
        '2021-01-05 15:00:00+03',
        '2021-01-05 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3656,
        '2021-01-05 19:00:00+03',
        '2021-01-05 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3657,
        '2021-01-05 17:00:00+03',
        '2021-01-05 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3658,
        '2021-01-05 17:00:00+03',
        '2021-01-05 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3659,
        '2021-01-05 15:00:00+03',
        '2021-01-05 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3660,
        '2021-01-05 15:00:00+03',
        '2021-01-05 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3661,
        '2021-01-05 17:00:00+03',
        '2021-01-05 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3662,
        '2021-01-05 16:00:00+03',
        '2021-01-05 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3663,
        '2021-01-05 17:00:00+03',
        '2021-01-05 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3664,
        '2021-01-05 16:00:00+03',
        '2021-01-05 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3665,
        '2021-01-05 17:00:00+03',
        '2021-01-05 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        3666,
        '2021-01-05 19:00:00+03',
        '2021-01-05 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3667,
        '2021-01-05 20:00:00+03',
        '2021-01-05 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3668,
        '2021-01-05 20:00:00+03',
        '2021-01-05 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3669,
        '2021-01-05 22:00:00+03',
        '2021-01-05 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3670,
        '2021-01-05 19:00:00+03',
        '2021-01-05 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3671,
        '2021-01-05 18:00:00+03',
        '2021-01-05 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3672,
        '2021-01-05 21:00:00+03',
        '2021-01-05 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3673,
        '2021-01-05 21:00:00+03',
        '2021-01-05 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3674,
        '2021-01-05 21:00:00+03',
        '2021-01-05 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3675,
        '2021-01-05 18:00:00+03',
        '2021-01-05 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3676,
        '2021-01-05 21:00:00+03',
        '2021-01-05 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3677,
        '2021-01-05 18:00:00+03',
        '2021-01-05 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3678,
        '2021-01-05 21:00:00+03',
        '2021-01-05 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3679,
        '2021-01-05 19:00:00+03',
        '2021-01-05 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3680,
        '2021-01-05 22:00:00+03',
        '2021-01-05 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3681,
        '2021-01-05 19:00:00+03',
        '2021-01-05 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3682,
        '2021-01-05 22:00:00+03',
        '2021-01-05 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3701,
        '2021-01-06 00:00:00+03',
        '2021-01-06 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3702,
        '2021-01-06 00:00:00+03',
        '2021-01-06 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3703,
        '2021-01-06 01:00:00+03',
        '2021-01-06 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3704,
        '2021-01-06 01:00:00+03',
        '2021-01-06 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3705,
        '2021-01-06 01:00:00+03',
        '2021-01-06 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3706,
        '2021-01-06 01:00:00+03',
        '2021-01-06 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3707,
        '2021-01-06 01:00:00+03',
        '2021-01-06 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3708,
        '2021-01-06 01:00:00+03',
        '2021-01-06 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3709,
        '2021-01-06 01:00:00+03',
        '2021-01-06 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3710,
        '2021-01-06 01:00:00+03',
        '2021-01-06 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3711,
        '2021-01-06 01:00:00+03',
        '2021-01-06 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3712,
        '2021-01-06 01:00:00+03',
        '2021-01-06 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        3713,
        '2021-01-06 01:00:00+03',
        '2021-01-06 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3714,
        '2021-01-06 01:00:00+03',
        '2021-01-06 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3715,
        '2021-01-06 01:00:00+03',
        '2021-01-06 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        3716,
        '2021-01-06 05:00:00+03',
        '2021-01-06 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3717,
        '2021-01-06 04:00:00+03',
        '2021-01-06 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3718,
        '2021-01-06 06:00:00+03',
        '2021-01-06 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3719,
        '2021-01-06 05:00:00+03',
        '2021-01-06 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3720,
        '2021-01-06 06:00:00+03',
        '2021-01-06 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3721,
        '2021-01-06 05:00:00+03',
        '2021-01-06 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3722,
        '2021-01-06 08:00:00+03',
        '2021-01-06 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3723,
        '2021-01-06 09:00:00+03',
        '2021-01-06 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3724,
        '2021-01-06 04:00:00+03',
        '2021-01-06 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3725,
        '2021-01-06 05:00:00+03',
        '2021-01-06 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3726,
        '2021-01-06 08:00:00+03',
        '2021-01-06 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3727,
        '2021-01-06 08:00:00+03',
        '2021-01-06 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3728,
        '2021-01-06 05:00:00+03',
        '2021-01-06 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3729,
        '2021-01-06 06:00:00+03',
        '2021-01-06 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        3730,
        '2021-01-06 05:00:00+03',
        '2021-01-06 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3731,
        '2021-01-06 05:00:00+03',
        '2021-01-06 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3732,
        '2021-01-06 06:00:00+03',
        '2021-01-06 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3733,
        '2021-01-06 09:00:00+03',
        '2021-01-06 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3734,
        '2021-01-06 10:00:00+03',
        '2021-01-06 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3735,
        '2021-01-06 10:00:00+03',
        '2021-01-06 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3736,
        '2021-01-06 12:00:00+03',
        '2021-01-06 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3737,
        '2021-01-06 11:00:00+03',
        '2021-01-06 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3738,
        '2021-01-06 12:00:00+03',
        '2021-01-06 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3739,
        '2021-01-06 11:00:00+03',
        '2021-01-06 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3740,
        '2021-01-06 12:00:00+03',
        '2021-01-06 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3741,
        '2021-01-06 09:00:00+03',
        '2021-01-06 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3742,
        '2021-01-06 10:00:00+03',
        '2021-01-06 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3743,
        '2021-01-06 12:00:00+03',
        '2021-01-06 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3744,
        '2021-01-06 12:00:00+03',
        '2021-01-06 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3745,
        '2021-01-06 10:00:00+03',
        '2021-01-06 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3746,
        '2021-01-06 11:00:00+03',
        '2021-01-06 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3747,
        '2021-01-06 14:00:00+03',
        '2021-01-06 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3748,
        '2021-01-06 12:00:00+03',
        '2021-01-06 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3749,
        '2021-01-06 12:00:00+03',
        '2021-01-06 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3750,
        '2021-01-06 13:00:00+03',
        '2021-01-06 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3751,
        '2021-01-06 15:00:00+03',
        '2021-01-06 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3752,
        '2021-01-06 16:00:00+03',
        '2021-01-06 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3753,
        '2021-01-06 16:00:00+03',
        '2021-01-06 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3754,
        '2021-01-06 15:00:00+03',
        '2021-01-06 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3755,
        '2021-01-06 15:00:00+03',
        '2021-01-06 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3756,
        '2021-01-06 19:00:00+03',
        '2021-01-06 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3757,
        '2021-01-06 17:00:00+03',
        '2021-01-06 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3758,
        '2021-01-06 17:00:00+03',
        '2021-01-06 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3759,
        '2021-01-06 15:00:00+03',
        '2021-01-06 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3760,
        '2021-01-06 15:00:00+03',
        '2021-01-06 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3761,
        '2021-01-06 17:00:00+03',
        '2021-01-06 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3762,
        '2021-01-06 16:00:00+03',
        '2021-01-06 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3763,
        '2021-01-06 17:00:00+03',
        '2021-01-06 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3764,
        '2021-01-06 16:00:00+03',
        '2021-01-06 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3765,
        '2021-01-06 17:00:00+03',
        '2021-01-06 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        3766,
        '2021-01-06 19:00:00+03',
        '2021-01-06 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3767,
        '2021-01-06 20:00:00+03',
        '2021-01-06 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3768,
        '2021-01-06 20:00:00+03',
        '2021-01-06 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3769,
        '2021-01-06 22:00:00+03',
        '2021-01-06 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3770,
        '2021-01-06 19:00:00+03',
        '2021-01-06 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3771,
        '2021-01-06 18:00:00+03',
        '2021-01-06 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3772,
        '2021-01-06 21:00:00+03',
        '2021-01-06 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3773,
        '2021-01-06 21:00:00+03',
        '2021-01-06 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3774,
        '2021-01-06 21:00:00+03',
        '2021-01-06 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3775,
        '2021-01-06 18:00:00+03',
        '2021-01-06 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3776,
        '2021-01-06 21:00:00+03',
        '2021-01-06 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3777,
        '2021-01-06 18:00:00+03',
        '2021-01-06 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3778,
        '2021-01-06 21:00:00+03',
        '2021-01-06 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3779,
        '2021-01-06 19:00:00+03',
        '2021-01-06 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3780,
        '2021-01-06 22:00:00+03',
        '2021-01-06 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3781,
        '2021-01-06 19:00:00+03',
        '2021-01-06 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3782,
        '2021-01-06 22:00:00+03',
        '2021-01-06 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  
INSERT INTO MTAMJQ.flights
VALUES (
        3801,
        '2021-01-07 00:00:00+03',
        '2021-01-07 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3802,
        '2021-01-07 00:00:00+03',
        '2021-01-07 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3803,
        '2021-01-07 01:00:00+03',
        '2021-01-07 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3804,
        '2021-01-07 01:00:00+03',
        '2021-01-07 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3805,
        '2021-01-07 01:00:00+03',
        '2021-01-07 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3806,
        '2021-01-07 01:00:00+03',
        '2021-01-07 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3807,
        '2021-01-07 01:00:00+03',
        '2021-01-07 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3808,
        '2021-01-07 01:00:00+03',
        '2021-01-07 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3809,
        '2021-01-07 01:00:00+03',
        '2021-01-07 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3810,
        '2021-01-07 01:00:00+03',
        '2021-01-07 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3811,
        '2021-01-07 01:00:00+03',
        '2021-01-07 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3812,
        '2021-01-07 01:00:00+03',
        '2021-01-07 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        3813,
        '2021-01-07 01:00:00+03',
        '2021-01-07 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3814,
        '2021-01-07 01:00:00+03',
        '2021-01-07 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3815,
        '2021-01-07 01:00:00+03',
        '2021-01-07 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        3816,
        '2021-01-07 05:00:00+03',
        '2021-01-07 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3817,
        '2021-01-07 04:00:00+03',
        '2021-01-07 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3818,
        '2021-01-07 06:00:00+03',
        '2021-01-07 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3819,
        '2021-01-07 05:00:00+03',
        '2021-01-07 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3820,
        '2021-01-07 06:00:00+03',
        '2021-01-07 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3821,
        '2021-01-07 05:00:00+03',
        '2021-01-07 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3822,
        '2021-01-07 08:00:00+03',
        '2021-01-07 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3823,
        '2021-01-07 09:00:00+03',
        '2021-01-07 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3824,
        '2021-01-07 04:00:00+03',
        '2021-01-07 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3825,
        '2021-01-07 05:00:00+03',
        '2021-01-07 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3826,
        '2021-01-07 08:00:00+03',
        '2021-01-07 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3827,
        '2021-01-07 08:00:00+03',
        '2021-01-07 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3828,
        '2021-01-07 05:00:00+03',
        '2021-01-07 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3829,
        '2021-01-07 06:00:00+03',
        '2021-01-07 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        3830,
        '2021-01-07 05:00:00+03',
        '2021-01-07 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3831,
        '2021-01-07 05:00:00+03',
        '2021-01-07 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3832,
        '2021-01-07 06:00:00+03',
        '2021-01-07 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3833,
        '2021-01-07 09:00:00+03',
        '2021-01-07 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3834,
        '2021-01-07 10:00:00+03',
        '2021-01-07 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3835,
        '2021-01-07 10:00:00+03',
        '2021-01-07 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3836,
        '2021-01-07 12:00:00+03',
        '2021-01-07 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3837,
        '2021-01-07 11:00:00+03',
        '2021-01-07 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3838,
        '2021-01-07 12:00:00+03',
        '2021-01-07 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3839,
        '2021-01-07 11:00:00+03',
        '2021-01-07 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3840,
        '2021-01-07 12:00:00+03',
        '2021-01-07 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3841,
        '2021-01-07 09:00:00+03',
        '2021-01-07 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3842,
        '2021-01-07 10:00:00+03',
        '2021-01-07 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3843,
        '2021-01-07 12:00:00+03',
        '2021-01-07 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3844,
        '2021-01-07 12:00:00+03',
        '2021-01-07 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3845,
        '2021-01-07 10:00:00+03',
        '2021-01-07 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3846,
        '2021-01-07 11:00:00+03',
        '2021-01-07 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3847,
        '2021-01-07 14:00:00+03',
        '2021-01-07 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3848,
        '2021-01-07 12:00:00+03',
        '2021-01-07 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3849,
        '2021-01-07 12:00:00+03',
        '2021-01-07 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3850,
        '2021-01-07 13:00:00+03',
        '2021-01-07 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3851,
        '2021-01-07 15:00:00+03',
        '2021-01-07 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3852,
        '2021-01-07 16:00:00+03',
        '2021-01-07 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3853,
        '2021-01-07 16:00:00+03',
        '2021-01-07 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3854,
        '2021-01-07 15:00:00+03',
        '2021-01-07 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3855,
        '2021-01-07 15:00:00+03',
        '2021-01-07 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3856,
        '2021-01-07 19:00:00+03',
        '2021-01-07 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3857,
        '2021-01-07 17:00:00+03',
        '2021-01-07 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3858,
        '2021-01-07 17:00:00+03',
        '2021-01-07 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3859,
        '2021-01-07 15:00:00+03',
        '2021-01-07 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3860,
        '2021-01-07 15:00:00+03',
        '2021-01-07 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3861,
        '2021-01-07 17:00:00+03',
        '2021-01-07 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3862,
        '2021-01-07 16:00:00+03',
        '2021-01-07 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3863,
        '2021-01-07 17:00:00+03',
        '2021-01-07 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3864,
        '2021-01-07 16:00:00+03',
        '2021-01-07 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3865,
        '2021-01-07 17:00:00+03',
        '2021-01-07 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        3866,
        '2021-01-07 19:00:00+03',
        '2021-01-07 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3867,
        '2021-01-07 20:00:00+03',
        '2021-01-07 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3868,
        '2021-01-07 20:00:00+03',
        '2021-01-07 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3869,
        '2021-01-07 22:00:00+03',
        '2021-01-07 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3870,
        '2021-01-07 19:00:00+03',
        '2021-01-07 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3871,
        '2021-01-07 18:00:00+03',
        '2021-01-07 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3872,
        '2021-01-07 21:00:00+03',
        '2021-01-07 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3873,
        '2021-01-07 21:00:00+03',
        '2021-01-07 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3874,
        '2021-01-07 21:00:00+03',
        '2021-01-07 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3875,
        '2021-01-07 18:00:00+03',
        '2021-01-07 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3876,
        '2021-01-07 21:00:00+03',
        '2021-01-07 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3877,
        '2021-01-07 18:00:00+03',
        '2021-01-07 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3878,
        '2021-01-07 21:00:00+03',
        '2021-01-07 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3879,
        '2021-01-07 19:00:00+03',
        '2021-01-07 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3880,
        '2021-01-07 22:00:00+03',
        '2021-01-07 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3881,
        '2021-01-07 19:00:00+03',
        '2021-01-07 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3882,
        '2021-01-07 22:00:00+03',
        '2021-01-07 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3901,
        '2021-01-08 00:00:00+03',
        '2021-01-08 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3902,
        '2021-01-08 00:00:00+03',
        '2021-01-08 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3903,
        '2021-01-08 01:00:00+03',
        '2021-01-08 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3904,
        '2021-01-08 01:00:00+03',
        '2021-01-08 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3905,
        '2021-01-08 01:00:00+03',
        '2021-01-08 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3906,
        '2021-01-08 01:00:00+03',
        '2021-01-08 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3907,
        '2021-01-08 01:00:00+03',
        '2021-01-08 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3908,
        '2021-01-08 01:00:00+03',
        '2021-01-08 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3909,
        '2021-01-08 01:00:00+03',
        '2021-01-08 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3910,
        '2021-01-08 01:00:00+03',
        '2021-01-08 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3911,
        '2021-01-08 01:00:00+03',
        '2021-01-08 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3912,
        '2021-01-08 01:00:00+03',
        '2021-01-08 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        3913,
        '2021-01-08 01:00:00+03',
        '2021-01-08 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3914,
        '2021-01-08 01:00:00+03',
        '2021-01-08 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3915,
        '2021-01-08 01:00:00+03',
        '2021-01-08 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        3916,
        '2021-01-08 05:00:00+03',
        '2021-01-08 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3917,
        '2021-01-08 04:00:00+03',
        '2021-01-08 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3918,
        '2021-01-08 06:00:00+03',
        '2021-01-08 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3919,
        '2021-01-08 05:00:00+03',
        '2021-01-08 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3920,
        '2021-01-08 06:00:00+03',
        '2021-01-08 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3921,
        '2021-01-08 05:00:00+03',
        '2021-01-08 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3922,
        '2021-01-08 08:00:00+03',
        '2021-01-08 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3923,
        '2021-01-08 09:00:00+03',
        '2021-01-08 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3924,
        '2021-01-08 04:00:00+03',
        '2021-01-08 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3925,
        '2021-01-08 05:00:00+03',
        '2021-01-08 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3926,
        '2021-01-08 08:00:00+03',
        '2021-01-08 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3927,
        '2021-01-08 08:00:00+03',
        '2021-01-08 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3928,
        '2021-01-08 05:00:00+03',
        '2021-01-08 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3929,
        '2021-01-08 06:00:00+03',
        '2021-01-08 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        3930,
        '2021-01-08 05:00:00+03',
        '2021-01-08 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3931,
        '2021-01-08 05:00:00+03',
        '2021-01-08 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3932,
        '2021-01-08 06:00:00+03',
        '2021-01-08 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3933,
        '2021-01-08 09:00:00+03',
        '2021-01-08 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3934,
        '2021-01-08 10:00:00+03',
        '2021-01-08 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3935,
        '2021-01-08 10:00:00+03',
        '2021-01-08 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3936,
        '2021-01-08 12:00:00+03',
        '2021-01-08 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3937,
        '2021-01-08 11:00:00+03',
        '2021-01-08 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3938,
        '2021-01-08 12:00:00+03',
        '2021-01-08 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3939,
        '2021-01-08 11:00:00+03',
        '2021-01-08 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3940,
        '2021-01-08 12:00:00+03',
        '2021-01-08 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3941,
        '2021-01-08 09:00:00+03',
        '2021-01-08 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3942,
        '2021-01-08 10:00:00+03',
        '2021-01-08 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3943,
        '2021-01-08 12:00:00+03',
        '2021-01-08 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3944,
        '2021-01-08 12:00:00+03',
        '2021-01-08 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        3945,
        '2021-01-08 10:00:00+03',
        '2021-01-08 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3946,
        '2021-01-08 11:00:00+03',
        '2021-01-08 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3947,
        '2021-01-08 14:00:00+03',
        '2021-01-08 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3948,
        '2021-01-08 12:00:00+03',
        '2021-01-08 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3949,
        '2021-01-08 12:00:00+03',
        '2021-01-08 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3950,
        '2021-01-08 13:00:00+03',
        '2021-01-08 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3951,
        '2021-01-08 15:00:00+03',
        '2021-01-08 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3952,
        '2021-01-08 16:00:00+03',
        '2021-01-08 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3953,
        '2021-01-08 16:00:00+03',
        '2021-01-08 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3954,
        '2021-01-08 15:00:00+03',
        '2021-01-08 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3955,
        '2021-01-08 15:00:00+03',
        '2021-01-08 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3956,
        '2021-01-08 19:00:00+03',
        '2021-01-08 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3957,
        '2021-01-08 17:00:00+03',
        '2021-01-08 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3958,
        '2021-01-08 17:00:00+03',
        '2021-01-08 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3959,
        '2021-01-08 15:00:00+03',
        '2021-01-08 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3960,
        '2021-01-08 15:00:00+03',
        '2021-01-08 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3961,
        '2021-01-08 17:00:00+03',
        '2021-01-08 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3962,
        '2021-01-08 16:00:00+03',
        '2021-01-08 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3963,
        '2021-01-08 17:00:00+03',
        '2021-01-08 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3964,
        '2021-01-08 16:00:00+03',
        '2021-01-08 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3965,
        '2021-01-08 17:00:00+03',
        '2021-01-08 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        3966,
        '2021-01-08 19:00:00+03',
        '2021-01-08 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3967,
        '2021-01-08 20:00:00+03',
        '2021-01-08 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3968,
        '2021-01-08 20:00:00+03',
        '2021-01-08 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3969,
        '2021-01-08 22:00:00+03',
        '2021-01-08 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        3970,
        '2021-01-08 19:00:00+03',
        '2021-01-08 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3971,
        '2021-01-08 18:00:00+03',
        '2021-01-08 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3972,
        '2021-01-08 21:00:00+03',
        '2021-01-08 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3973,
        '2021-01-08 21:00:00+03',
        '2021-01-08 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3974,
        '2021-01-08 21:00:00+03',
        '2021-01-08 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3975,
        '2021-01-08 18:00:00+03',
        '2021-01-08 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3976,
        '2021-01-08 21:00:00+03',
        '2021-01-08 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3977,
        '2021-01-08 18:00:00+03',
        '2021-01-08 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3978,
        '2021-01-08 21:00:00+03',
        '2021-01-08 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3979,
        '2021-01-08 19:00:00+03',
        '2021-01-08 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        3980,
        '2021-01-08 22:00:00+03',
        '2021-01-08 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3981,
        '2021-01-08 19:00:00+03',
        '2021-01-08 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        3982,
        '2021-01-08 22:00:00+03',
        '2021-01-08 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4001,
        '2021-01-09 00:00:00+03',
        '2021-01-09 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4002,
        '2021-01-09 00:00:00+03',
        '2021-01-09 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4003,
        '2021-01-09 01:00:00+03',
        '2021-01-09 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4004,
        '2021-01-09 01:00:00+03',
        '2021-01-09 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4005,
        '2021-01-09 01:00:00+03',
        '2021-01-09 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4006,
        '2021-01-09 01:00:00+03',
        '2021-01-09 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4007,
        '2021-01-09 01:00:00+03',
        '2021-01-09 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4008,
        '2021-01-09 01:00:00+03',
        '2021-01-09 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4009,
        '2021-01-09 01:00:00+03',
        '2021-01-09 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4010,
        '2021-01-09 01:00:00+03',
        '2021-01-09 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4011,
        '2021-01-09 01:00:00+03',
        '2021-01-09 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4012,
        '2021-01-09 01:00:00+03',
        '2021-01-09 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        4013,
        '2021-01-09 01:00:00+03',
        '2021-01-09 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4014,
        '2021-01-09 01:00:00+03',
        '2021-01-09 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4015,
        '2021-01-09 01:00:00+03',
        '2021-01-09 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        4016,
        '2021-01-09 05:00:00+03',
        '2021-01-09 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4017,
        '2021-01-09 04:00:00+03',
        '2021-01-09 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4018,
        '2021-01-09 06:00:00+03',
        '2021-01-09 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4019,
        '2021-01-09 05:00:00+03',
        '2021-01-09 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4020,
        '2021-01-09 06:00:00+03',
        '2021-01-09 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4021,
        '2021-01-09 05:00:00+03',
        '2021-01-09 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4022,
        '2021-01-09 08:00:00+03',
        '2021-01-09 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4023,
        '2021-01-09 09:00:00+03',
        '2021-01-09 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4024,
        '2021-01-09 04:00:00+03',
        '2021-01-09 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4025,
        '2021-01-09 05:00:00+03',
        '2021-01-09 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4026,
        '2021-01-09 08:00:00+03',
        '2021-01-09 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4027,
        '2021-01-09 08:00:00+03',
        '2021-01-09 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4028,
        '2021-01-09 05:00:00+03',
        '2021-01-09 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4029,
        '2021-01-09 06:00:00+03',
        '2021-01-09 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        4030,
        '2021-01-09 05:00:00+03',
        '2021-01-09 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4031,
        '2021-01-09 05:00:00+03',
        '2021-01-09 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4032,
        '2021-01-09 06:00:00+03',
        '2021-01-09 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4033,
        '2021-01-09 09:00:00+03',
        '2021-01-09 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4034,
        '2021-01-09 10:00:00+03',
        '2021-01-09 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4035,
        '2021-01-09 10:00:00+03',
        '2021-01-09 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4036,
        '2021-01-09 12:00:00+03',
        '2021-01-09 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4037,
        '2021-01-09 11:00:00+03',
        '2021-01-09 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4038,
        '2021-01-09 12:00:00+03',
        '2021-01-09 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4039,
        '2021-01-09 11:00:00+03',
        '2021-01-09 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4040,
        '2021-01-09 12:00:00+03',
        '2021-01-09 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4041,
        '2021-01-09 09:00:00+03',
        '2021-01-09 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4042,
        '2021-01-09 10:00:00+03',
        '2021-01-09 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4043,
        '2021-01-09 12:00:00+03',
        '2021-01-09 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4044,
        '2021-01-09 12:00:00+03',
        '2021-01-09 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4045,
        '2021-01-09 10:00:00+03',
        '2021-01-09 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4046,
        '2021-01-09 11:00:00+03',
        '2021-01-09 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4047,
        '2021-01-09 14:00:00+03',
        '2021-01-09 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4048,
        '2021-01-09 12:00:00+03',
        '2021-01-09 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4049,
        '2021-01-09 12:00:00+03',
        '2021-01-09 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4050,
        '2021-01-09 13:00:00+03',
        '2021-01-09 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4051,
        '2021-01-09 15:00:00+03',
        '2021-01-09 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4052,
        '2021-01-09 16:00:00+03',
        '2021-01-09 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4053,
        '2021-01-09 16:00:00+03',
        '2021-01-09 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4054,
        '2021-01-09 15:00:00+03',
        '2021-01-09 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4055,
        '2021-01-09 15:00:00+03',
        '2021-01-09 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4056,
        '2021-01-09 19:00:00+03',
        '2021-01-09 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4057,
        '2021-01-09 17:00:00+03',
        '2021-01-09 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4058,
        '2021-01-09 17:00:00+03',
        '2021-01-09 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4059,
        '2021-01-09 15:00:00+03',
        '2021-01-09 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4060,
        '2021-01-09 15:00:00+03',
        '2021-01-09 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4061,
        '2021-01-09 17:00:00+03',
        '2021-01-09 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4062,
        '2021-01-09 16:00:00+03',
        '2021-01-09 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4063,
        '2021-01-09 17:00:00+03',
        '2021-01-09 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4064,
        '2021-01-09 16:00:00+03',
        '2021-01-09 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4065,
        '2021-01-09 17:00:00+03',
        '2021-01-09 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        4066,
        '2021-01-09 19:00:00+03',
        '2021-01-09 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4067,
        '2021-01-09 20:00:00+03',
        '2021-01-09 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4068,
        '2021-01-09 20:00:00+03',
        '2021-01-09 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4069,
        '2021-01-09 22:00:00+03',
        '2021-01-09 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4070,
        '2021-01-09 19:00:00+03',
        '2021-01-09 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4071,
        '2021-01-09 18:00:00+03',
        '2021-01-09 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4072,
        '2021-01-09 21:00:00+03',
        '2021-01-09 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4073,
        '2021-01-09 21:00:00+03',
        '2021-01-09 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4074,
        '2021-01-09 21:00:00+03',
        '2021-01-09 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4075,
        '2021-01-09 18:00:00+03',
        '2021-01-09 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4076,
        '2021-01-09 21:00:00+03',
        '2021-01-09 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4077,
        '2021-01-09 18:00:00+03',
        '2021-01-09 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4078,
        '2021-01-09 21:00:00+03',
        '2021-01-09 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4079,
        '2021-01-09 19:00:00+03',
        '2021-01-09 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4080,
        '2021-01-09 22:00:00+03',
        '2021-01-09 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4081,
        '2021-01-09 19:00:00+03',
        '2021-01-09 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4082,
        '2021-01-09 22:00:00+03',
        '2021-01-09 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4101,
        '2021-01-10 00:00:00+03',
        '2021-01-10 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4102,
        '2021-01-10 00:00:00+03',
        '2021-01-10 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4103,
        '2021-01-10 01:00:00+03',
        '2021-01-10 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4104,
        '2021-01-10 01:00:00+03',
        '2021-01-10 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4105,
        '2021-01-10 01:00:00+03',
        '2021-01-10 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4106,
        '2021-01-10 01:00:00+03',
        '2021-01-10 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4107,
        '2021-01-10 01:00:00+03',
        '2021-01-10 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4108,
        '2021-01-10 01:00:00+03',
        '2021-01-10 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4109,
        '2021-01-10 01:00:00+03',
        '2021-01-10 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4110,
        '2021-01-10 01:00:00+03',
        '2021-01-10 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4111,
        '2021-01-10 01:00:00+03',
        '2021-01-10 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4112,
        '2021-01-10 01:00:00+03',
        '2021-01-10 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        4113,
        '2021-01-10 01:00:00+03',
        '2021-01-10 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4114,
        '2021-01-10 01:00:00+03',
        '2021-01-10 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4115,
        '2021-01-10 01:00:00+03',
        '2021-01-10 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        4116,
        '2021-01-10 05:00:00+03',
        '2021-01-10 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4117,
        '2021-01-10 04:00:00+03',
        '2021-01-10 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4118,
        '2021-01-10 06:00:00+03',
        '2021-01-10 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4119,
        '2021-01-10 05:00:00+03',
        '2021-01-10 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4120,
        '2021-01-10 06:00:00+03',
        '2021-01-10 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4121,
        '2021-01-10 05:00:00+03',
        '2021-01-10 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4122,
        '2021-01-10 08:00:00+03',
        '2021-01-10 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4123,
        '2021-01-10 09:00:00+03',
        '2021-01-10 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4124,
        '2021-01-10 04:00:00+03',
        '2021-01-10 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4125,
        '2021-01-10 05:00:00+03',
        '2021-01-10 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4126,
        '2021-01-10 08:00:00+03',
        '2021-01-10 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4127,
        '2021-01-10 08:00:00+03',
        '2021-01-10 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4128,
        '2021-01-10 05:00:00+03',
        '2021-01-10 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4129,
        '2021-01-10 06:00:00+03',
        '2021-01-10 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        4130,
        '2021-01-10 05:00:00+03',
        '2021-01-10 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4131,
        '2021-01-10 05:00:00+03',
        '2021-01-10 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4132,
        '2021-01-10 06:00:00+03',
        '2021-01-10 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4133,
        '2021-01-10 09:00:00+03',
        '2021-01-10 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4134,
        '2021-01-10 10:00:00+03',
        '2021-01-10 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4135,
        '2021-01-10 10:00:00+03',
        '2021-01-10 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4136,
        '2021-01-10 12:00:00+03',
        '2021-01-10 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4137,
        '2021-01-10 11:00:00+03',
        '2021-01-10 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4138,
        '2021-01-10 12:00:00+03',
        '2021-01-10 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4139,
        '2021-01-10 11:00:00+03',
        '2021-01-10 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4140,
        '2021-01-10 12:00:00+03',
        '2021-01-10 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4141,
        '2021-01-10 09:00:00+03',
        '2021-01-10 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4142,
        '2021-01-10 10:00:00+03',
        '2021-01-10 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4143,
        '2021-01-10 12:00:00+03',
        '2021-01-10 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4144,
        '2021-01-10 12:00:00+03',
        '2021-01-10 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4145,
        '2021-01-10 10:00:00+03',
        '2021-01-10 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4146,
        '2021-01-10 11:00:00+03',
        '2021-01-10 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4147,
        '2021-01-10 14:00:00+03',
        '2021-01-10 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4148,
        '2021-01-10 12:00:00+03',
        '2021-01-10 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4149,
        '2021-01-10 12:00:00+03',
        '2021-01-10 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4150,
        '2021-01-10 13:00:00+03',
        '2021-01-10 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4151,
        '2021-01-10 15:00:00+03',
        '2021-01-10 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4152,
        '2021-01-10 16:00:00+03',
        '2021-01-10 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4153,
        '2021-01-10 16:00:00+03',
        '2021-01-10 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4154,
        '2021-01-10 15:00:00+03',
        '2021-01-10 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4155,
        '2021-01-10 15:00:00+03',
        '2021-01-10 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4156,
        '2021-01-10 19:00:00+03',
        '2021-01-10 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4157,
        '2021-01-10 17:00:00+03',
        '2021-01-10 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4158,
        '2021-01-10 17:00:00+03',
        '2021-01-10 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4159,
        '2021-01-10 15:00:00+03',
        '2021-01-10 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4160,
        '2021-01-10 15:00:00+03',
        '2021-01-10 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4161,
        '2021-01-10 17:00:00+03',
        '2021-01-10 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4162,
        '2021-01-10 16:00:00+03',
        '2021-01-10 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4163,
        '2021-01-10 17:00:00+03',
        '2021-01-10 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4164,
        '2021-01-10 16:00:00+03',
        '2021-01-10 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4165,
        '2021-01-10 17:00:00+03',
        '2021-01-10 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        4166,
        '2021-01-10 19:00:00+03',
        '2021-01-10 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4167,
        '2021-01-10 20:00:00+03',
        '2021-01-10 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4168,
        '2021-01-10 20:00:00+03',
        '2021-01-10 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4169,
        '2021-01-10 22:00:00+03',
        '2021-01-10 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4170,
        '2021-01-10 19:00:00+03',
        '2021-01-10 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4171,
        '2021-01-10 18:00:00+03',
        '2021-01-10 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4172,
        '2021-01-10 21:00:00+03',
        '2021-01-10 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4173,
        '2021-01-10 21:00:00+03',
        '2021-01-10 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4174,
        '2021-01-10 21:00:00+03',
        '2021-01-10 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4175,
        '2021-01-10 18:00:00+03',
        '2021-01-10 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4176,
        '2021-01-10 21:00:00+03',
        '2021-01-10 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4177,
        '2021-01-10 18:00:00+03',
        '2021-01-10 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4178,
        '2021-01-10 21:00:00+03',
        '2021-01-10 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4179,
        '2021-01-10 19:00:00+03',
        '2021-01-10 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4180,
        '2021-01-10 22:00:00+03',
        '2021-01-10 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4181,
        '2021-01-10 19:00:00+03',
        '2021-01-10 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4182,
        '2021-01-10 22:00:00+03',
        '2021-01-10 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4201,
        '2021-01-11 00:00:00+03',
        '2021-01-11 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4202,
        '2021-01-11 00:00:00+03',
        '2021-01-11 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4203,
        '2021-01-11 01:00:00+03',
        '2021-01-11 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4204,
        '2021-01-11 01:00:00+03',
        '2021-01-11 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4205,
        '2021-01-11 01:00:00+03',
        '2021-01-11 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4206,
        '2021-01-11 01:00:00+03',
        '2021-01-11 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4207,
        '2021-01-11 01:00:00+03',
        '2021-01-11 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4208,
        '2021-01-11 01:00:00+03',
        '2021-01-11 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4209,
        '2021-01-11 01:00:00+03',
        '2021-01-11 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4210,
        '2021-01-11 01:00:00+03',
        '2021-01-11 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4211,
        '2021-01-11 01:00:00+03',
        '2021-01-11 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4212,
        '2021-01-11 01:00:00+03',
        '2021-01-11 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        4213,
        '2021-01-11 01:00:00+03',
        '2021-01-11 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4214,
        '2021-01-11 01:00:00+03',
        '2021-01-11 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4215,
        '2021-01-11 01:00:00+03',
        '2021-01-11 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        4216,
        '2021-01-11 05:00:00+03',
        '2021-01-11 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4217,
        '2021-01-11 04:00:00+03',
        '2021-01-11 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4218,
        '2021-01-11 06:00:00+03',
        '2021-01-11 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4219,
        '2021-01-11 05:00:00+03',
        '2021-01-11 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4220,
        '2021-01-11 06:00:00+03',
        '2021-01-11 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4221,
        '2021-01-11 05:00:00+03',
        '2021-01-11 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4222,
        '2021-01-11 08:00:00+03',
        '2021-01-11 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4223,
        '2021-01-11 09:00:00+03',
        '2021-01-11 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4224,
        '2021-01-11 04:00:00+03',
        '2021-01-11 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4225,
        '2021-01-11 05:00:00+03',
        '2021-01-11 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4226,
        '2021-01-11 08:00:00+03',
        '2021-01-11 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4227,
        '2021-01-11 08:00:00+03',
        '2021-01-11 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4228,
        '2021-01-11 05:00:00+03',
        '2021-01-11 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4229,
        '2021-01-11 06:00:00+03',
        '2021-01-11 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        4230,
        '2021-01-11 05:00:00+03',
        '2021-01-11 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4231,
        '2021-01-11 05:00:00+03',
        '2021-01-11 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4232,
        '2021-01-11 06:00:00+03',
        '2021-01-11 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4233,
        '2021-01-11 09:00:00+03',
        '2021-01-11 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4234,
        '2021-01-11 10:00:00+03',
        '2021-01-11 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4235,
        '2021-01-11 10:00:00+03',
        '2021-01-11 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4236,
        '2021-01-11 12:00:00+03',
        '2021-01-11 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4237,
        '2021-01-11 11:00:00+03',
        '2021-01-11 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4238,
        '2021-01-11 12:00:00+03',
        '2021-01-11 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4239,
        '2021-01-11 11:00:00+03',
        '2021-01-11 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4240,
        '2021-01-11 12:00:00+03',
        '2021-01-11 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4241,
        '2021-01-11 09:00:00+03',
        '2021-01-11 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4242,
        '2021-01-11 10:00:00+03',
        '2021-01-11 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4243,
        '2021-01-11 12:00:00+03',
        '2021-01-11 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4244,
        '2021-01-11 12:00:00+03',
        '2021-01-11 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4245,
        '2021-01-11 10:00:00+03',
        '2021-01-11 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4246,
        '2021-01-11 11:00:00+03',
        '2021-01-11 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4247,
        '2021-01-11 14:00:00+03',
        '2021-01-11 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4248,
        '2021-01-11 12:00:00+03',
        '2021-01-11 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4249,
        '2021-01-11 12:00:00+03',
        '2021-01-11 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4250,
        '2021-01-11 13:00:00+03',
        '2021-01-11 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4251,
        '2021-01-11 15:00:00+03',
        '2021-01-11 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4252,
        '2021-01-11 16:00:00+03',
        '2021-01-11 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4253,
        '2021-01-11 16:00:00+03',
        '2021-01-11 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4254,
        '2021-01-11 15:00:00+03',
        '2021-01-11 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4255,
        '2021-01-11 15:00:00+03',
        '2021-01-11 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4256,
        '2021-01-11 19:00:00+03',
        '2021-01-11 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4257,
        '2021-01-11 17:00:00+03',
        '2021-01-11 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4258,
        '2021-01-11 17:00:00+03',
        '2021-01-11 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4259,
        '2021-01-11 15:00:00+03',
        '2021-01-11 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4260,
        '2021-01-11 15:00:00+03',
        '2021-01-11 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4261,
        '2021-01-11 17:00:00+03',
        '2021-01-11 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4262,
        '2021-01-11 16:00:00+03',
        '2021-01-11 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4263,
        '2021-01-11 17:00:00+03',
        '2021-01-11 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4264,
        '2021-01-11 16:00:00+03',
        '2021-01-11 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4265,
        '2021-01-11 17:00:00+03',
        '2021-01-11 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        4266,
        '2021-01-11 19:00:00+03',
        '2021-01-11 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4267,
        '2021-01-11 20:00:00+03',
        '2021-01-11 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4268,
        '2021-01-11 20:00:00+03',
        '2021-01-11 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4269,
        '2021-01-11 22:00:00+03',
        '2021-01-11 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4270,
        '2021-01-11 19:00:00+03',
        '2021-01-11 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4271,
        '2021-01-11 18:00:00+03',
        '2021-01-11 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4272,
        '2021-01-11 21:00:00+03',
        '2021-01-11 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4273,
        '2021-01-11 21:00:00+03',
        '2021-01-11 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4274,
        '2021-01-11 21:00:00+03',
        '2021-01-11 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4275,
        '2021-01-11 18:00:00+03',
        '2021-01-11 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4276,
        '2021-01-11 21:00:00+03',
        '2021-01-11 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4277,
        '2021-01-11 18:00:00+03',
        '2021-01-11 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4278,
        '2021-01-11 21:00:00+03',
        '2021-01-11 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4279,
        '2021-01-11 19:00:00+03',
        '2021-01-11 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4280,
        '2021-01-11 22:00:00+03',
        '2021-01-11 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4281,
        '2021-01-11 19:00:00+03',
        '2021-01-11 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4282,
        '2021-01-11 22:00:00+03',
        '2021-01-11 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4301,
        '2021-01-12 00:00:00+03',
        '2021-01-12 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4302,
        '2021-01-12 00:00:00+03',
        '2021-01-12 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4303,
        '2021-01-12 01:00:00+03',
        '2021-01-12 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4304,
        '2021-01-12 01:00:00+03',
        '2021-01-12 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4305,
        '2021-01-12 01:00:00+03',
        '2021-01-12 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4306,
        '2021-01-12 01:00:00+03',
        '2021-01-12 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4307,
        '2021-01-12 01:00:00+03',
        '2021-01-12 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4308,
        '2021-01-12 01:00:00+03',
        '2021-01-12 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4309,
        '2021-01-12 01:00:00+03',
        '2021-01-12 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4310,
        '2021-01-12 01:00:00+03',
        '2021-01-12 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4311,
        '2021-01-12 01:00:00+03',
        '2021-01-12 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4312,
        '2021-01-12 01:00:00+03',
        '2021-01-12 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        4313,
        '2021-01-12 01:00:00+03',
        '2021-01-12 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4314,
        '2021-01-12 01:00:00+03',
        '2021-01-12 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4315,
        '2021-01-12 01:00:00+03',
        '2021-01-12 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        4316,
        '2021-01-12 05:00:00+03',
        '2021-01-12 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4317,
        '2021-01-12 04:00:00+03',
        '2021-01-12 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4318,
        '2021-01-12 06:00:00+03',
        '2021-01-12 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4319,
        '2021-01-12 05:00:00+03',
        '2021-01-12 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4320,
        '2021-01-12 06:00:00+03',
        '2021-01-12 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4321,
        '2021-01-12 05:00:00+03',
        '2021-01-12 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4322,
        '2021-01-12 08:00:00+03',
        '2021-01-12 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4323,
        '2021-01-12 09:00:00+03',
        '2021-01-12 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4324,
        '2021-01-12 04:00:00+03',
        '2021-01-12 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4325,
        '2021-01-12 05:00:00+03',
        '2021-01-12 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4326,
        '2021-01-12 08:00:00+03',
        '2021-01-12 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4327,
        '2021-01-12 08:00:00+03',
        '2021-01-12 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4328,
        '2021-01-12 05:00:00+03',
        '2021-01-12 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4329,
        '2021-01-12 06:00:00+03',
        '2021-01-12 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        4330,
        '2021-01-12 05:00:00+03',
        '2021-01-12 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4331,
        '2021-01-12 05:00:00+03',
        '2021-01-12 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4332,
        '2021-01-12 06:00:00+03',
        '2021-01-12 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4333,
        '2021-01-12 09:00:00+03',
        '2021-01-12 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4334,
        '2021-01-12 10:00:00+03',
        '2021-01-12 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4335,
        '2021-01-12 10:00:00+03',
        '2021-01-12 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4336,
        '2021-01-12 12:00:00+03',
        '2021-01-12 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4337,
        '2021-01-12 11:00:00+03',
        '2021-01-12 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4338,
        '2021-01-12 12:00:00+03',
        '2021-01-12 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4339,
        '2021-01-12 11:00:00+03',
        '2021-01-12 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4340,
        '2021-01-12 12:00:00+03',
        '2021-01-12 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4341,
        '2021-01-12 09:00:00+03',
        '2021-01-12 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4342,
        '2021-01-12 10:00:00+03',
        '2021-01-12 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4343,
        '2021-01-12 12:00:00+03',
        '2021-01-12 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4344,
        '2021-01-12 12:00:00+03',
        '2021-01-12 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4345,
        '2021-01-12 10:00:00+03',
        '2021-01-12 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4346,
        '2021-01-12 11:00:00+03',
        '2021-01-12 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4347,
        '2021-01-12 14:00:00+03',
        '2021-01-12 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4348,
        '2021-01-12 12:00:00+03',
        '2021-01-12 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4349,
        '2021-01-12 12:00:00+03',
        '2021-01-12 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4350,
        '2021-01-12 13:00:00+03',
        '2021-01-12 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4351,
        '2021-01-12 15:00:00+03',
        '2021-01-12 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4352,
        '2021-01-12 16:00:00+03',
        '2021-01-12 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4353,
        '2021-01-12 16:00:00+03',
        '2021-01-12 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4354,
        '2021-01-12 15:00:00+03',
        '2021-01-12 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4355,
        '2021-01-12 15:00:00+03',
        '2021-01-12 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4356,
        '2021-01-12 19:00:00+03',
        '2021-01-12 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4357,
        '2021-01-12 17:00:00+03',
        '2021-01-12 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4358,
        '2021-01-12 17:00:00+03',
        '2021-01-12 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4359,
        '2021-01-12 15:00:00+03',
        '2021-01-12 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4360,
        '2021-01-12 15:00:00+03',
        '2021-01-12 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4361,
        '2021-01-12 17:00:00+03',
        '2021-01-12 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4362,
        '2021-01-12 16:00:00+03',
        '2021-01-12 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4363,
        '2021-01-12 17:00:00+03',
        '2021-01-12 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4364,
        '2021-01-12 16:00:00+03',
        '2021-01-12 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4365,
        '2021-01-12 17:00:00+03',
        '2021-01-12 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        4366,
        '2021-01-12 19:00:00+03',
        '2021-01-12 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4367,
        '2021-01-12 20:00:00+03',
        '2021-01-12 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4368,
        '2021-01-12 20:00:00+03',
        '2021-01-12 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4369,
        '2021-01-12 22:00:00+03',
        '2021-01-12 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4370,
        '2021-01-12 19:00:00+03',
        '2021-01-12 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4371,
        '2021-01-12 18:00:00+03',
        '2021-01-12 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4372,
        '2021-01-12 21:00:00+03',
        '2021-01-12 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4373,
        '2021-01-12 21:00:00+03',
        '2021-01-12 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4374,
        '2021-01-12 21:00:00+03',
        '2021-01-12 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4375,
        '2021-01-12 18:00:00+03',
        '2021-01-12 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4376,
        '2021-01-12 21:00:00+03',
        '2021-01-12 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4377,
        '2021-01-12 18:00:00+03',
        '2021-01-12 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4378,
        '2021-01-12 21:00:00+03',
        '2021-01-12 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4379,
        '2021-01-12 19:00:00+03',
        '2021-01-12 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4380,
        '2021-01-12 22:00:00+03',
        '2021-01-12 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4381,
        '2021-01-12 19:00:00+03',
        '2021-01-12 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4382,
        '2021-01-12 22:00:00+03',
        '2021-01-12 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4401,
        '2021-01-13 00:00:00+03',
        '2021-01-13 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4402,
        '2021-01-13 00:00:00+03',
        '2021-01-13 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4403,
        '2021-01-13 01:00:00+03',
        '2021-01-13 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4404,
        '2021-01-13 01:00:00+03',
        '2021-01-13 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4405,
        '2021-01-13 01:00:00+03',
        '2021-01-13 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4406,
        '2021-01-13 01:00:00+03',
        '2021-01-13 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4407,
        '2021-01-13 01:00:00+03',
        '2021-01-13 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4408,
        '2021-01-13 01:00:00+03',
        '2021-01-13 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4409,
        '2021-01-13 01:00:00+03',
        '2021-01-13 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4410,
        '2021-01-13 01:00:00+03',
        '2021-01-13 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4411,
        '2021-01-13 01:00:00+03',
        '2021-01-13 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4412,
        '2021-01-13 01:00:00+03',
        '2021-01-13 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        4413,
        '2021-01-13 01:00:00+03',
        '2021-01-13 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4414,
        '2021-01-13 01:00:00+03',
        '2021-01-13 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4415,
        '2021-01-13 01:00:00+03',
        '2021-01-13 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        4416,
        '2021-01-13 05:00:00+03',
        '2021-01-13 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4417,
        '2021-01-13 04:00:00+03',
        '2021-01-13 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4418,
        '2021-01-13 06:00:00+03',
        '2021-01-13 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4419,
        '2021-01-13 05:00:00+03',
        '2021-01-13 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4420,
        '2021-01-13 06:00:00+03',
        '2021-01-13 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4421,
        '2021-01-13 05:00:00+03',
        '2021-01-13 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4422,
        '2021-01-13 08:00:00+03',
        '2021-01-13 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4423,
        '2021-01-13 09:00:00+03',
        '2021-01-13 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4424,
        '2021-01-13 04:00:00+03',
        '2021-01-13 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4425,
        '2021-01-13 05:00:00+03',
        '2021-01-13 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4426,
        '2021-01-13 08:00:00+03',
        '2021-01-13 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4427,
        '2021-01-13 08:00:00+03',
        '2021-01-13 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4428,
        '2021-01-13 05:00:00+03',
        '2021-01-13 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4429,
        '2021-01-13 06:00:00+03',
        '2021-01-13 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        4430,
        '2021-01-13 05:00:00+03',
        '2021-01-13 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4431,
        '2021-01-13 05:00:00+03',
        '2021-01-13 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4432,
        '2021-01-13 06:00:00+03',
        '2021-01-13 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4433,
        '2021-01-13 09:00:00+03',
        '2021-01-13 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4434,
        '2021-01-13 10:00:00+03',
        '2021-01-13 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4435,
        '2021-01-13 10:00:00+03',
        '2021-01-13 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4436,
        '2021-01-13 12:00:00+03',
        '2021-01-13 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4437,
        '2021-01-13 11:00:00+03',
        '2021-01-13 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4438,
        '2021-01-13 12:00:00+03',
        '2021-01-13 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4439,
        '2021-01-13 11:00:00+03',
        '2021-01-13 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4440,
        '2021-01-13 12:00:00+03',
        '2021-01-13 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4441,
        '2021-01-13 09:00:00+03',
        '2021-01-13 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4442,
        '2021-01-13 10:00:00+03',
        '2021-01-13 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4443,
        '2021-01-13 12:00:00+03',
        '2021-01-13 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4444,
        '2021-01-13 12:00:00+03',
        '2021-01-13 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4445,
        '2021-01-13 10:00:00+03',
        '2021-01-13 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4446,
        '2021-01-13 11:00:00+03',
        '2021-01-13 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4447,
        '2021-01-13 14:00:00+03',
        '2021-01-13 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4448,
        '2021-01-13 12:00:00+03',
        '2021-01-13 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4449,
        '2021-01-13 12:00:00+03',
        '2021-01-13 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4450,
        '2021-01-13 13:00:00+03',
        '2021-01-13 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4451,
        '2021-01-13 15:00:00+03',
        '2021-01-13 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4452,
        '2021-01-13 16:00:00+03',
        '2021-01-13 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4453,
        '2021-01-13 16:00:00+03',
        '2021-01-13 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4454,
        '2021-01-13 15:00:00+03',
        '2021-01-13 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4455,
        '2021-01-13 15:00:00+03',
        '2021-01-13 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4456,
        '2021-01-13 19:00:00+03',
        '2021-01-13 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4457,
        '2021-01-13 17:00:00+03',
        '2021-01-13 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4458,
        '2021-01-13 17:00:00+03',
        '2021-01-13 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4459,
        '2021-01-13 15:00:00+03',
        '2021-01-13 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4460,
        '2021-01-13 15:00:00+03',
        '2021-01-13 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4461,
        '2021-01-13 17:00:00+03',
        '2021-01-13 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4462,
        '2021-01-13 16:00:00+03',
        '2021-01-13 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4463,
        '2021-01-13 17:00:00+03',
        '2021-01-13 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4464,
        '2021-01-13 16:00:00+03',
        '2021-01-13 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4465,
        '2021-01-13 17:00:00+03',
        '2021-01-13 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        4466,
        '2021-01-13 19:00:00+03',
        '2021-01-13 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4467,
        '2021-01-13 20:00:00+03',
        '2021-01-13 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4468,
        '2021-01-13 20:00:00+03',
        '2021-01-13 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4469,
        '2021-01-13 22:00:00+03',
        '2021-01-13 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4470,
        '2021-01-13 19:00:00+03',
        '2021-01-13 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4471,
        '2021-01-13 18:00:00+03',
        '2021-01-13 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4472,
        '2021-01-13 21:00:00+03',
        '2021-01-13 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4473,
        '2021-01-13 21:00:00+03',
        '2021-01-13 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4474,
        '2021-01-13 21:00:00+03',
        '2021-01-13 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4475,
        '2021-01-13 18:00:00+03',
        '2021-01-13 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4476,
        '2021-01-13 21:00:00+03',
        '2021-01-13 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4477,
        '2021-01-13 18:00:00+03',
        '2021-01-13 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4478,
        '2021-01-13 21:00:00+03',
        '2021-01-13 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4479,
        '2021-01-13 19:00:00+03',
        '2021-01-13 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4480,
        '2021-01-13 22:00:00+03',
        '2021-01-13 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4481,
        '2021-01-13 19:00:00+03',
        '2021-01-13 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4482,
        '2021-01-13 22:00:00+03',
        '2021-01-13 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4501,
        '2021-01-14 00:00:00+03',
        '2021-01-14 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4502,
        '2021-01-14 00:00:00+03',
        '2021-01-14 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4503,
        '2021-01-14 01:00:00+03',
        '2021-01-14 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4504,
        '2021-01-14 01:00:00+03',
        '2021-01-14 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4505,
        '2021-01-14 01:00:00+03',
        '2021-01-14 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4506,
        '2021-01-14 01:00:00+03',
        '2021-01-14 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4507,
        '2021-01-14 01:00:00+03',
        '2021-01-14 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4508,
        '2021-01-14 01:00:00+03',
        '2021-01-14 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4509,
        '2021-01-14 01:00:00+03',
        '2021-01-14 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4510,
        '2021-01-14 01:00:00+03',
        '2021-01-14 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4511,
        '2021-01-14 01:00:00+03',
        '2021-01-14 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4512,
        '2021-01-14 01:00:00+03',
        '2021-01-14 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        4513,
        '2021-01-14 01:00:00+03',
        '2021-01-14 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4514,
        '2021-01-14 01:00:00+03',
        '2021-01-14 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4515,
        '2021-01-14 01:00:00+03',
        '2021-01-14 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        4516,
        '2021-01-14 05:00:00+03',
        '2021-01-14 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4517,
        '2021-01-14 04:00:00+03',
        '2021-01-14 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4518,
        '2021-01-14 06:00:00+03',
        '2021-01-14 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4519,
        '2021-01-14 05:00:00+03',
        '2021-01-14 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4520,
        '2021-01-14 06:00:00+03',
        '2021-01-14 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4521,
        '2021-01-14 05:00:00+03',
        '2021-01-14 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4522,
        '2021-01-14 08:00:00+03',
        '2021-01-14 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4523,
        '2021-01-14 09:00:00+03',
        '2021-01-14 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4524,
        '2021-01-14 04:00:00+03',
        '2021-01-14 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4525,
        '2021-01-14 05:00:00+03',
        '2021-01-14 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4526,
        '2021-01-14 08:00:00+03',
        '2021-01-14 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4527,
        '2021-01-14 08:00:00+03',
        '2021-01-14 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4528,
        '2021-01-14 05:00:00+03',
        '2021-01-14 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4529,
        '2021-01-14 06:00:00+03',
        '2021-01-14 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        4530,
        '2021-01-14 05:00:00+03',
        '2021-01-14 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4531,
        '2021-01-14 05:00:00+03',
        '2021-01-14 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4532,
        '2021-01-14 06:00:00+03',
        '2021-01-14 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4533,
        '2021-01-14 09:00:00+03',
        '2021-01-14 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4534,
        '2021-01-14 10:00:00+03',
        '2021-01-14 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4535,
        '2021-01-14 10:00:00+03',
        '2021-01-14 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4536,
        '2021-01-14 12:00:00+03',
        '2021-01-14 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4537,
        '2021-01-14 11:00:00+03',
        '2021-01-14 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4538,
        '2021-01-14 12:00:00+03',
        '2021-01-14 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4539,
        '2021-01-14 11:00:00+03',
        '2021-01-14 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4540,
        '2021-01-14 12:00:00+03',
        '2021-01-14 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4541,
        '2021-01-14 09:00:00+03',
        '2021-01-14 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4542,
        '2021-01-14 10:00:00+03',
        '2021-01-14 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4543,
        '2021-01-14 12:00:00+03',
        '2021-01-14 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4544,
        '2021-01-14 12:00:00+03',
        '2021-01-14 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4545,
        '2021-01-14 10:00:00+03',
        '2021-01-14 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4546,
        '2021-01-14 11:00:00+03',
        '2021-01-14 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4547,
        '2021-01-14 14:00:00+03',
        '2021-01-14 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4548,
        '2021-01-14 12:00:00+03',
        '2021-01-14 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4549,
        '2021-01-14 12:00:00+03',
        '2021-01-14 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4550,
        '2021-01-14 13:00:00+03',
        '2021-01-14 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4551,
        '2021-01-14 15:00:00+03',
        '2021-01-14 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4552,
        '2021-01-14 16:00:00+03',
        '2021-01-14 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4553,
        '2021-01-14 16:00:00+03',
        '2021-01-14 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4554,
        '2021-01-14 15:00:00+03',
        '2021-01-14 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4555,
        '2021-01-14 15:00:00+03',
        '2021-01-14 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4556,
        '2021-01-14 19:00:00+03',
        '2021-01-14 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4557,
        '2021-01-14 17:00:00+03',
        '2021-01-14 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4558,
        '2021-01-14 17:00:00+03',
        '2021-01-14 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4559,
        '2021-01-14 15:00:00+03',
        '2021-01-14 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4560,
        '2021-01-14 15:00:00+03',
        '2021-01-14 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4561,
        '2021-01-14 17:00:00+03',
        '2021-01-14 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4562,
        '2021-01-14 16:00:00+03',
        '2021-01-14 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4563,
        '2021-01-14 17:00:00+03',
        '2021-01-14 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4564,
        '2021-01-14 16:00:00+03',
        '2021-01-14 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4565,
        '2021-01-14 17:00:00+03',
        '2021-01-14 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        4566,
        '2021-01-14 19:00:00+03',
        '2021-01-14 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4567,
        '2021-01-14 20:00:00+03',
        '2021-01-14 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4568,
        '2021-01-14 20:00:00+03',
        '2021-01-14 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4569,
        '2021-01-14 22:00:00+03',
        '2021-01-14 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4570,
        '2021-01-14 19:00:00+03',
        '2021-01-14 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4571,
        '2021-01-14 18:00:00+03',
        '2021-01-14 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4572,
        '2021-01-14 21:00:00+03',
        '2021-01-14 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4573,
        '2021-01-14 21:00:00+03',
        '2021-01-14 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4574,
        '2021-01-14 21:00:00+03',
        '2021-01-14 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4575,
        '2021-01-14 18:00:00+03',
        '2021-01-14 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4576,
        '2021-01-14 21:00:00+03',
        '2021-01-14 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4577,
        '2021-01-14 18:00:00+03',
        '2021-01-14 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4578,
        '2021-01-14 21:00:00+03',
        '2021-01-14 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4579,
        '2021-01-14 19:00:00+03',
        '2021-01-14 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4580,
        '2021-01-14 22:00:00+03',
        '2021-01-14 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4581,
        '2021-01-14 19:00:00+03',
        '2021-01-14 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4582,
        '2021-01-14 22:00:00+03',
        '2021-01-14 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4601,
        '2021-01-15 00:00:00+03',
        '2021-01-15 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4602,
        '2021-01-15 00:00:00+03',
        '2021-01-15 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4603,
        '2021-01-15 01:00:00+03',
        '2021-01-15 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4604,
        '2021-01-15 01:00:00+03',
        '2021-01-15 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4605,
        '2021-01-15 01:00:00+03',
        '2021-01-15 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4606,
        '2021-01-15 01:00:00+03',
        '2021-01-15 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4607,
        '2021-01-15 01:00:00+03',
        '2021-01-15 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4608,
        '2021-01-15 01:00:00+03',
        '2021-01-15 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4609,
        '2021-01-15 01:00:00+03',
        '2021-01-15 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4610,
        '2021-01-15 01:00:00+03',
        '2021-01-15 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4611,
        '2021-01-15 01:00:00+03',
        '2021-01-15 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4612,
        '2021-01-15 01:00:00+03',
        '2021-01-15 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        4613,
        '2021-01-15 01:00:00+03',
        '2021-01-15 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4614,
        '2021-01-15 01:00:00+03',
        '2021-01-15 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4615,
        '2021-01-15 01:00:00+03',
        '2021-01-15 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        4616,
        '2021-01-15 05:00:00+03',
        '2021-01-15 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4617,
        '2021-01-15 04:00:00+03',
        '2021-01-15 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4618,
        '2021-01-15 06:00:00+03',
        '2021-01-15 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4619,
        '2021-01-15 05:00:00+03',
        '2021-01-15 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4620,
        '2021-01-15 06:00:00+03',
        '2021-01-15 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4621,
        '2021-01-15 05:00:00+03',
        '2021-01-15 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4622,
        '2021-01-15 08:00:00+03',
        '2021-01-15 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4623,
        '2021-01-15 09:00:00+03',
        '2021-01-15 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4624,
        '2021-01-15 04:00:00+03',
        '2021-01-15 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4625,
        '2021-01-15 05:00:00+03',
        '2021-01-15 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4626,
        '2021-01-15 08:00:00+03',
        '2021-01-15 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4627,
        '2021-01-15 08:00:00+03',
        '2021-01-15 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4628,
        '2021-01-15 05:00:00+03',
        '2021-01-15 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4629,
        '2021-01-15 06:00:00+03',
        '2021-01-15 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        4630,
        '2021-01-15 05:00:00+03',
        '2021-01-15 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4631,
        '2021-01-15 05:00:00+03',
        '2021-01-15 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4632,
        '2021-01-15 06:00:00+03',
        '2021-01-15 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4633,
        '2021-01-15 09:00:00+03',
        '2021-01-15 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4634,
        '2021-01-15 10:00:00+03',
        '2021-01-15 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4635,
        '2021-01-15 10:00:00+03',
        '2021-01-15 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4636,
        '2021-01-15 12:00:00+03',
        '2021-01-15 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4637,
        '2021-01-15 11:00:00+03',
        '2021-01-15 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4638,
        '2021-01-15 12:00:00+03',
        '2021-01-15 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4639,
        '2021-01-15 11:00:00+03',
        '2021-01-15 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4640,
        '2021-01-15 12:00:00+03',
        '2021-01-15 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4641,
        '2021-01-15 09:00:00+03',
        '2021-01-15 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4642,
        '2021-01-15 10:00:00+03',
        '2021-01-15 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4643,
        '2021-01-15 12:00:00+03',
        '2021-01-15 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4644,
        '2021-01-15 12:00:00+03',
        '2021-01-15 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4645,
        '2021-01-15 10:00:00+03',
        '2021-01-15 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4646,
        '2021-01-15 11:00:00+03',
        '2021-01-15 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4647,
        '2021-01-15 14:00:00+03',
        '2021-01-15 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4648,
        '2021-01-15 12:00:00+03',
        '2021-01-15 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4649,
        '2021-01-15 12:00:00+03',
        '2021-01-15 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4650,
        '2021-01-15 13:00:00+03',
        '2021-01-15 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4651,
        '2021-01-15 15:00:00+03',
        '2021-01-15 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4652,
        '2021-01-15 16:00:00+03',
        '2021-01-15 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4653,
        '2021-01-15 16:00:00+03',
        '2021-01-15 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4654,
        '2021-01-15 15:00:00+03',
        '2021-01-15 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4655,
        '2021-01-15 15:00:00+03',
        '2021-01-15 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4656,
        '2021-01-15 19:00:00+03',
        '2021-01-15 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4657,
        '2021-01-15 17:00:00+03',
        '2021-01-15 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4658,
        '2021-01-15 17:00:00+03',
        '2021-01-15 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4659,
        '2021-01-15 15:00:00+03',
        '2021-01-15 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4660,
        '2021-01-15 15:00:00+03',
        '2021-01-15 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4661,
        '2021-01-15 17:00:00+03',
        '2021-01-15 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4662,
        '2021-01-15 16:00:00+03',
        '2021-01-15 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4663,
        '2021-01-15 17:00:00+03',
        '2021-01-15 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4664,
        '2021-01-15 16:00:00+03',
        '2021-01-15 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4665,
        '2021-01-15 17:00:00+03',
        '2021-01-15 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        4666,
        '2021-01-15 19:00:00+03',
        '2021-01-15 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4667,
        '2021-01-15 20:00:00+03',
        '2021-01-15 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4668,
        '2021-01-15 20:00:00+03',
        '2021-01-15 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4669,
        '2021-01-15 22:00:00+03',
        '2021-01-15 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4670,
        '2021-01-15 19:00:00+03',
        '2021-01-15 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4671,
        '2021-01-15 18:00:00+03',
        '2021-01-15 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4672,
        '2021-01-15 21:00:00+03',
        '2021-01-15 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4673,
        '2021-01-15 21:00:00+03',
        '2021-01-15 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4674,
        '2021-01-15 21:00:00+03',
        '2021-01-15 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4675,
        '2021-01-15 18:00:00+03',
        '2021-01-15 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4676,
        '2021-01-15 21:00:00+03',
        '2021-01-15 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4677,
        '2021-01-15 18:00:00+03',
        '2021-01-15 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4678,
        '2021-01-15 21:00:00+03',
        '2021-01-15 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4679,
        '2021-01-15 19:00:00+03',
        '2021-01-15 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4680,
        '2021-01-15 22:00:00+03',
        '2021-01-15 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4681,
        '2021-01-15 19:00:00+03',
        '2021-01-15 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4682,
        '2021-01-15 22:00:00+03',
        '2021-01-15 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4701,
        '2021-01-16 00:00:00+03',
        '2021-01-16 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4702,
        '2021-01-16 00:00:00+03',
        '2021-01-16 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4703,
        '2021-01-16 01:00:00+03',
        '2021-01-16 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4704,
        '2021-01-16 01:00:00+03',
        '2021-01-16 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4705,
        '2021-01-16 01:00:00+03',
        '2021-01-16 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4706,
        '2021-01-16 01:00:00+03',
        '2021-01-16 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4707,
        '2021-01-16 01:00:00+03',
        '2021-01-16 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4708,
        '2021-01-16 01:00:00+03',
        '2021-01-16 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4709,
        '2021-01-16 01:00:00+03',
        '2021-01-16 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4710,
        '2021-01-16 01:00:00+03',
        '2021-01-16 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4711,
        '2021-01-16 01:00:00+03',
        '2021-01-16 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4712,
        '2021-01-16 01:00:00+03',
        '2021-01-16 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        4713,
        '2021-01-16 01:00:00+03',
        '2021-01-16 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4714,
        '2021-01-16 01:00:00+03',
        '2021-01-16 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4715,
        '2021-01-16 01:00:00+03',
        '2021-01-16 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        4716,
        '2021-01-16 05:00:00+03',
        '2021-01-16 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4717,
        '2021-01-16 04:00:00+03',
        '2021-01-16 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4718,
        '2021-01-16 06:00:00+03',
        '2021-01-16 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4719,
        '2021-01-16 05:00:00+03',
        '2021-01-16 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4720,
        '2021-01-16 06:00:00+03',
        '2021-01-16 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4721,
        '2021-01-16 05:00:00+03',
        '2021-01-16 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4722,
        '2021-01-16 08:00:00+03',
        '2021-01-16 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4723,
        '2021-01-16 09:00:00+03',
        '2021-01-16 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4724,
        '2021-01-16 04:00:00+03',
        '2021-01-16 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4725,
        '2021-01-16 05:00:00+03',
        '2021-01-16 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4726,
        '2021-01-16 08:00:00+03',
        '2021-01-16 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4727,
        '2021-01-16 08:00:00+03',
        '2021-01-16 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4728,
        '2021-01-16 05:00:00+03',
        '2021-01-16 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4729,
        '2021-01-16 06:00:00+03',
        '2021-01-16 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        4730,
        '2021-01-16 05:00:00+03',
        '2021-01-16 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4731,
        '2021-01-16 05:00:00+03',
        '2021-01-16 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4732,
        '2021-01-16 06:00:00+03',
        '2021-01-16 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4733,
        '2021-01-16 09:00:00+03',
        '2021-01-16 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4734,
        '2021-01-16 10:00:00+03',
        '2021-01-16 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4735,
        '2021-01-16 10:00:00+03',
        '2021-01-16 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4736,
        '2021-01-16 12:00:00+03',
        '2021-01-16 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4737,
        '2021-01-16 11:00:00+03',
        '2021-01-16 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4738,
        '2021-01-16 12:00:00+03',
        '2021-01-16 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4739,
        '2021-01-16 11:00:00+03',
        '2021-01-16 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4740,
        '2021-01-16 12:00:00+03',
        '2021-01-16 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4741,
        '2021-01-16 09:00:00+03',
        '2021-01-16 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4742,
        '2021-01-16 10:00:00+03',
        '2021-01-16 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4743,
        '2021-01-16 12:00:00+03',
        '2021-01-16 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4744,
        '2021-01-16 12:00:00+03',
        '2021-01-16 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4745,
        '2021-01-16 10:00:00+03',
        '2021-01-16 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4746,
        '2021-01-16 11:00:00+03',
        '2021-01-16 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4747,
        '2021-01-16 14:00:00+03',
        '2021-01-16 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4748,
        '2021-01-16 12:00:00+03',
        '2021-01-16 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4749,
        '2021-01-16 12:00:00+03',
        '2021-01-16 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4750,
        '2021-01-16 13:00:00+03',
        '2021-01-16 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4751,
        '2021-01-16 15:00:00+03',
        '2021-01-16 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4752,
        '2021-01-16 16:00:00+03',
        '2021-01-16 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4753,
        '2021-01-16 16:00:00+03',
        '2021-01-16 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4754,
        '2021-01-16 15:00:00+03',
        '2021-01-16 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4755,
        '2021-01-16 15:00:00+03',
        '2021-01-16 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4756,
        '2021-01-16 19:00:00+03',
        '2021-01-16 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4757,
        '2021-01-16 17:00:00+03',
        '2021-01-16 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4758,
        '2021-01-16 17:00:00+03',
        '2021-01-16 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4759,
        '2021-01-16 15:00:00+03',
        '2021-01-16 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4760,
        '2021-01-16 15:00:00+03',
        '2021-01-16 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4761,
        '2021-01-16 17:00:00+03',
        '2021-01-16 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4762,
        '2021-01-16 16:00:00+03',
        '2021-01-16 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4763,
        '2021-01-16 17:00:00+03',
        '2021-01-16 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4764,
        '2021-01-16 16:00:00+03',
        '2021-01-16 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4765,
        '2021-01-16 17:00:00+03',
        '2021-01-16 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        4766,
        '2021-01-16 19:00:00+03',
        '2021-01-16 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4767,
        '2021-01-16 20:00:00+03',
        '2021-01-16 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4768,
        '2021-01-16 20:00:00+03',
        '2021-01-16 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4769,
        '2021-01-16 22:00:00+03',
        '2021-01-16 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4770,
        '2021-01-16 19:00:00+03',
        '2021-01-16 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4771,
        '2021-01-16 18:00:00+03',
        '2021-01-16 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4772,
        '2021-01-16 21:00:00+03',
        '2021-01-16 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4773,
        '2021-01-16 21:00:00+03',
        '2021-01-16 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4774,
        '2021-01-16 21:00:00+03',
        '2021-01-16 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4775,
        '2021-01-16 18:00:00+03',
        '2021-01-16 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4776,
        '2021-01-16 21:00:00+03',
        '2021-01-16 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4777,
        '2021-01-16 18:00:00+03',
        '2021-01-16 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4778,
        '2021-01-16 21:00:00+03',
        '2021-01-16 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4779,
        '2021-01-16 19:00:00+03',
        '2021-01-16 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4780,
        '2021-01-16 22:00:00+03',
        '2021-01-16 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4781,
        '2021-01-16 19:00:00+03',
        '2021-01-16 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4782,
        '2021-01-16 22:00:00+03',
        '2021-01-16 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4801,
        '2021-01-17 00:00:00+03',
        '2021-01-17 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4802,
        '2021-01-17 00:00:00+03',
        '2021-01-17 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4803,
        '2021-01-17 01:00:00+03',
        '2021-01-17 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4804,
        '2021-01-17 01:00:00+03',
        '2021-01-17 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4805,
        '2021-01-17 01:00:00+03',
        '2021-01-17 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4806,
        '2021-01-17 01:00:00+03',
        '2021-01-17 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4807,
        '2021-01-17 01:00:00+03',
        '2021-01-17 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4808,
        '2021-01-17 01:00:00+03',
        '2021-01-17 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4809,
        '2021-01-17 01:00:00+03',
        '2021-01-17 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4810,
        '2021-01-17 01:00:00+03',
        '2021-01-17 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4811,
        '2021-01-17 01:00:00+03',
        '2021-01-17 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4812,
        '2021-01-17 01:00:00+03',
        '2021-01-17 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        4813,
        '2021-01-17 01:00:00+03',
        '2021-01-17 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4814,
        '2021-01-17 01:00:00+03',
        '2021-01-17 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4815,
        '2021-01-17 01:00:00+03',
        '2021-01-17 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        4816,
        '2021-01-17 05:00:00+03',
        '2021-01-17 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4817,
        '2021-01-17 04:00:00+03',
        '2021-01-17 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4818,
        '2021-01-17 06:00:00+03',
        '2021-01-17 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4819,
        '2021-01-17 05:00:00+03',
        '2021-01-17 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4820,
        '2021-01-17 06:00:00+03',
        '2021-01-17 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4821,
        '2021-01-17 05:00:00+03',
        '2021-01-17 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4822,
        '2021-01-17 08:00:00+03',
        '2021-01-17 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4823,
        '2021-01-17 09:00:00+03',
        '2021-01-17 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4824,
        '2021-01-17 04:00:00+03',
        '2021-01-17 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4825,
        '2021-01-17 05:00:00+03',
        '2021-01-17 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4826,
        '2021-01-17 08:00:00+03',
        '2021-01-17 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4827,
        '2021-01-17 08:00:00+03',
        '2021-01-17 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4828,
        '2021-01-17 05:00:00+03',
        '2021-01-17 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4829,
        '2021-01-17 06:00:00+03',
        '2021-01-17 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        4830,
        '2021-01-17 05:00:00+03',
        '2021-01-17 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4831,
        '2021-01-17 05:00:00+03',
        '2021-01-17 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4832,
        '2021-01-17 06:00:00+03',
        '2021-01-17 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4833,
        '2021-01-17 09:00:00+03',
        '2021-01-17 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4834,
        '2021-01-17 10:00:00+03',
        '2021-01-17 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4835,
        '2021-01-17 10:00:00+03',
        '2021-01-17 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4836,
        '2021-01-17 12:00:00+03',
        '2021-01-17 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4837,
        '2021-01-17 11:00:00+03',
        '2021-01-17 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4838,
        '2021-01-17 12:00:00+03',
        '2021-01-17 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4839,
        '2021-01-17 11:00:00+03',
        '2021-01-17 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4840,
        '2021-01-17 12:00:00+03',
        '2021-01-17 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4841,
        '2021-01-17 09:00:00+03',
        '2021-01-17 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4842,
        '2021-01-17 10:00:00+03',
        '2021-01-17 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4843,
        '2021-01-17 12:00:00+03',
        '2021-01-17 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4844,
        '2021-01-17 12:00:00+03',
        '2021-01-17 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4845,
        '2021-01-17 10:00:00+03',
        '2021-01-17 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4846,
        '2021-01-17 11:00:00+03',
        '2021-01-17 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4847,
        '2021-01-17 14:00:00+03',
        '2021-01-17 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4848,
        '2021-01-17 12:00:00+03',
        '2021-01-17 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4849,
        '2021-01-17 12:00:00+03',
        '2021-01-17 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4850,
        '2021-01-17 13:00:00+03',
        '2021-01-17 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4851,
        '2021-01-17 15:00:00+03',
        '2021-01-17 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4852,
        '2021-01-17 16:00:00+03',
        '2021-01-17 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4853,
        '2021-01-17 16:00:00+03',
        '2021-01-17 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4854,
        '2021-01-17 15:00:00+03',
        '2021-01-17 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4855,
        '2021-01-17 15:00:00+03',
        '2021-01-17 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4856,
        '2021-01-17 19:00:00+03',
        '2021-01-17 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4857,
        '2021-01-17 17:00:00+03',
        '2021-01-17 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4858,
        '2021-01-17 17:00:00+03',
        '2021-01-17 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4859,
        '2021-01-17 15:00:00+03',
        '2021-01-17 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4860,
        '2021-01-17 15:00:00+03',
        '2021-01-17 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4861,
        '2021-01-17 17:00:00+03',
        '2021-01-17 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4862,
        '2021-01-17 16:00:00+03',
        '2021-01-17 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4863,
        '2021-01-17 17:00:00+03',
        '2021-01-17 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4864,
        '2021-01-17 16:00:00+03',
        '2021-01-17 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4865,
        '2021-01-17 17:00:00+03',
        '2021-01-17 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        4866,
        '2021-01-17 19:00:00+03',
        '2021-01-17 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4867,
        '2021-01-17 20:00:00+03',
        '2021-01-17 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4868,
        '2021-01-17 20:00:00+03',
        '2021-01-17 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4869,
        '2021-01-17 22:00:00+03',
        '2021-01-17 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4870,
        '2021-01-17 19:00:00+03',
        '2021-01-17 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4871,
        '2021-01-17 18:00:00+03',
        '2021-01-17 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4872,
        '2021-01-17 21:00:00+03',
        '2021-01-17 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4873,
        '2021-01-17 21:00:00+03',
        '2021-01-17 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4874,
        '2021-01-17 21:00:00+03',
        '2021-01-17 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4875,
        '2021-01-17 18:00:00+03',
        '2021-01-17 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4876,
        '2021-01-17 21:00:00+03',
        '2021-01-17 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4877,
        '2021-01-17 18:00:00+03',
        '2021-01-17 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4878,
        '2021-01-17 21:00:00+03',
        '2021-01-17 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4879,
        '2021-01-17 19:00:00+03',
        '2021-01-17 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4880,
        '2021-01-17 22:00:00+03',
        '2021-01-17 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4881,
        '2021-01-17 19:00:00+03',
        '2021-01-17 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4882,
        '2021-01-17 22:00:00+03',
        '2021-01-17 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4901,
        '2021-01-18 00:00:00+03',
        '2021-01-18 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4902,
        '2021-01-18 00:00:00+03',
        '2021-01-18 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4903,
        '2021-01-18 01:00:00+03',
        '2021-01-18 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4904,
        '2021-01-18 01:00:00+03',
        '2021-01-18 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4905,
        '2021-01-18 01:00:00+03',
        '2021-01-18 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4906,
        '2021-01-18 01:00:00+03',
        '2021-01-18 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4907,
        '2021-01-18 01:00:00+03',
        '2021-01-18 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4908,
        '2021-01-18 01:00:00+03',
        '2021-01-18 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4909,
        '2021-01-18 01:00:00+03',
        '2021-01-18 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4910,
        '2021-01-18 01:00:00+03',
        '2021-01-18 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4911,
        '2021-01-18 01:00:00+03',
        '2021-01-18 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4912,
        '2021-01-18 01:00:00+03',
        '2021-01-18 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        4913,
        '2021-01-18 01:00:00+03',
        '2021-01-18 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4914,
        '2021-01-18 01:00:00+03',
        '2021-01-18 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4915,
        '2021-01-18 01:00:00+03',
        '2021-01-18 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        4916,
        '2021-01-18 05:00:00+03',
        '2021-01-18 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4917,
        '2021-01-18 04:00:00+03',
        '2021-01-18 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4918,
        '2021-01-18 06:00:00+03',
        '2021-01-18 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4919,
        '2021-01-18 05:00:00+03',
        '2021-01-18 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4920,
        '2021-01-18 06:00:00+03',
        '2021-01-18 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4921,
        '2021-01-18 05:00:00+03',
        '2021-01-18 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4922,
        '2021-01-18 08:00:00+03',
        '2021-01-18 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4923,
        '2021-01-18 09:00:00+03',
        '2021-01-18 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4924,
        '2021-01-18 04:00:00+03',
        '2021-01-18 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4925,
        '2021-01-18 05:00:00+03',
        '2021-01-18 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4926,
        '2021-01-18 08:00:00+03',
        '2021-01-18 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4927,
        '2021-01-18 08:00:00+03',
        '2021-01-18 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4928,
        '2021-01-18 05:00:00+03',
        '2021-01-18 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4929,
        '2021-01-18 06:00:00+03',
        '2021-01-18 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        4930,
        '2021-01-18 05:00:00+03',
        '2021-01-18 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4931,
        '2021-01-18 05:00:00+03',
        '2021-01-18 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4932,
        '2021-01-18 06:00:00+03',
        '2021-01-18 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4933,
        '2021-01-18 09:00:00+03',
        '2021-01-18 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4934,
        '2021-01-18 10:00:00+03',
        '2021-01-18 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4935,
        '2021-01-18 10:00:00+03',
        '2021-01-18 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4936,
        '2021-01-18 12:00:00+03',
        '2021-01-18 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4937,
        '2021-01-18 11:00:00+03',
        '2021-01-18 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4938,
        '2021-01-18 12:00:00+03',
        '2021-01-18 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4939,
        '2021-01-18 11:00:00+03',
        '2021-01-18 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4940,
        '2021-01-18 12:00:00+03',
        '2021-01-18 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4941,
        '2021-01-18 09:00:00+03',
        '2021-01-18 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4942,
        '2021-01-18 10:00:00+03',
        '2021-01-18 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4943,
        '2021-01-18 12:00:00+03',
        '2021-01-18 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4944,
        '2021-01-18 12:00:00+03',
        '2021-01-18 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        4945,
        '2021-01-18 10:00:00+03',
        '2021-01-18 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4946,
        '2021-01-18 11:00:00+03',
        '2021-01-18 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4947,
        '2021-01-18 14:00:00+03',
        '2021-01-18 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4948,
        '2021-01-18 12:00:00+03',
        '2021-01-18 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4949,
        '2021-01-18 12:00:00+03',
        '2021-01-18 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4950,
        '2021-01-18 13:00:00+03',
        '2021-01-18 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4951,
        '2021-01-18 15:00:00+03',
        '2021-01-18 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4952,
        '2021-01-18 16:00:00+03',
        '2021-01-18 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4953,
        '2021-01-18 16:00:00+03',
        '2021-01-18 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4954,
        '2021-01-18 15:00:00+03',
        '2021-01-18 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4955,
        '2021-01-18 15:00:00+03',
        '2021-01-18 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4956,
        '2021-01-18 19:00:00+03',
        '2021-01-18 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4957,
        '2021-01-18 17:00:00+03',
        '2021-01-18 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4958,
        '2021-01-18 17:00:00+03',
        '2021-01-18 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4959,
        '2021-01-18 15:00:00+03',
        '2021-01-18 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4960,
        '2021-01-18 15:00:00+03',
        '2021-01-18 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4961,
        '2021-01-18 17:00:00+03',
        '2021-01-18 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4962,
        '2021-01-18 16:00:00+03',
        '2021-01-18 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4963,
        '2021-01-18 17:00:00+03',
        '2021-01-18 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4964,
        '2021-01-18 16:00:00+03',
        '2021-01-18 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4965,
        '2021-01-18 17:00:00+03',
        '2021-01-18 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        4966,
        '2021-01-18 19:00:00+03',
        '2021-01-18 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4967,
        '2021-01-18 20:00:00+03',
        '2021-01-18 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4968,
        '2021-01-18 20:00:00+03',
        '2021-01-18 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4969,
        '2021-01-18 22:00:00+03',
        '2021-01-18 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        4970,
        '2021-01-18 19:00:00+03',
        '2021-01-18 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4971,
        '2021-01-18 18:00:00+03',
        '2021-01-18 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4972,
        '2021-01-18 21:00:00+03',
        '2021-01-18 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4973,
        '2021-01-18 21:00:00+03',
        '2021-01-18 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4974,
        '2021-01-18 21:00:00+03',
        '2021-01-18 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4975,
        '2021-01-18 18:00:00+03',
        '2021-01-18 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4976,
        '2021-01-18 21:00:00+03',
        '2021-01-18 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4977,
        '2021-01-18 18:00:00+03',
        '2021-01-18 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4978,
        '2021-01-18 21:00:00+03',
        '2021-01-18 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4979,
        '2021-01-18 19:00:00+03',
        '2021-01-18 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        4980,
        '2021-01-18 22:00:00+03',
        '2021-01-18 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4981,
        '2021-01-18 19:00:00+03',
        '2021-01-18 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        4982,
        '2021-01-18 22:00:00+03',
        '2021-01-18 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5001,
        '2021-01-19 00:00:00+03',
        '2021-01-19 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5002,
        '2021-01-19 00:00:00+03',
        '2021-01-19 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5003,
        '2021-01-19 01:00:00+03',
        '2021-01-19 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5004,
        '2021-01-19 01:00:00+03',
        '2021-01-19 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5005,
        '2021-01-19 01:00:00+03',
        '2021-01-19 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5006,
        '2021-01-19 01:00:00+03',
        '2021-01-19 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5007,
        '2021-01-19 01:00:00+03',
        '2021-01-19 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5008,
        '2021-01-19 01:00:00+03',
        '2021-01-19 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5009,
        '2021-01-19 01:00:00+03',
        '2021-01-19 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5010,
        '2021-01-19 01:00:00+03',
        '2021-01-19 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5011,
        '2021-01-19 01:00:00+03',
        '2021-01-19 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5012,
        '2021-01-19 01:00:00+03',
        '2021-01-19 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        5013,
        '2021-01-19 01:00:00+03',
        '2021-01-19 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5014,
        '2021-01-19 01:00:00+03',
        '2021-01-19 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5015,
        '2021-01-19 01:00:00+03',
        '2021-01-19 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        5016,
        '2021-01-19 05:00:00+03',
        '2021-01-19 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5017,
        '2021-01-19 04:00:00+03',
        '2021-01-19 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5018,
        '2021-01-19 06:00:00+03',
        '2021-01-19 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5019,
        '2021-01-19 05:00:00+03',
        '2021-01-19 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5020,
        '2021-01-19 06:00:00+03',
        '2021-01-19 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5021,
        '2021-01-19 05:00:00+03',
        '2021-01-19 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5022,
        '2021-01-19 08:00:00+03',
        '2021-01-19 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5023,
        '2021-01-19 09:00:00+03',
        '2021-01-19 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5024,
        '2021-01-19 04:00:00+03',
        '2021-01-19 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5025,
        '2021-01-19 05:00:00+03',
        '2021-01-19 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5026,
        '2021-01-19 08:00:00+03',
        '2021-01-19 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5027,
        '2021-01-19 08:00:00+03',
        '2021-01-19 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5028,
        '2021-01-19 05:00:00+03',
        '2021-01-19 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5029,
        '2021-01-19 06:00:00+03',
        '2021-01-19 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        5030,
        '2021-01-19 05:00:00+03',
        '2021-01-19 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5031,
        '2021-01-19 05:00:00+03',
        '2021-01-19 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5032,
        '2021-01-19 06:00:00+03',
        '2021-01-19 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5033,
        '2021-01-19 09:00:00+03',
        '2021-01-19 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5034,
        '2021-01-19 10:00:00+03',
        '2021-01-19 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5035,
        '2021-01-19 10:00:00+03',
        '2021-01-19 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5036,
        '2021-01-19 12:00:00+03',
        '2021-01-19 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5037,
        '2021-01-19 11:00:00+03',
        '2021-01-19 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5038,
        '2021-01-19 12:00:00+03',
        '2021-01-19 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5039,
        '2021-01-19 11:00:00+03',
        '2021-01-19 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5040,
        '2021-01-19 12:00:00+03',
        '2021-01-19 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5041,
        '2021-01-19 09:00:00+03',
        '2021-01-19 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5042,
        '2021-01-19 10:00:00+03',
        '2021-01-19 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5043,
        '2021-01-19 12:00:00+03',
        '2021-01-19 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5044,
        '2021-01-19 12:00:00+03',
        '2021-01-19 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5045,
        '2021-01-19 10:00:00+03',
        '2021-01-19 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5046,
        '2021-01-19 11:00:00+03',
        '2021-01-19 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5047,
        '2021-01-19 14:00:00+03',
        '2021-01-19 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5048,
        '2021-01-19 12:00:00+03',
        '2021-01-19 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5049,
        '2021-01-19 12:00:00+03',
        '2021-01-19 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5050,
        '2021-01-19 13:00:00+03',
        '2021-01-19 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5051,
        '2021-01-19 15:00:00+03',
        '2021-01-19 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5052,
        '2021-01-19 16:00:00+03',
        '2021-01-19 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5053,
        '2021-01-19 16:00:00+03',
        '2021-01-19 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5054,
        '2021-01-19 15:00:00+03',
        '2021-01-19 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5055,
        '2021-01-19 15:00:00+03',
        '2021-01-19 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5056,
        '2021-01-19 19:00:00+03',
        '2021-01-19 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5057,
        '2021-01-19 17:00:00+03',
        '2021-01-19 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5058,
        '2021-01-19 17:00:00+03',
        '2021-01-19 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5059,
        '2021-01-19 15:00:00+03',
        '2021-01-19 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5060,
        '2021-01-19 15:00:00+03',
        '2021-01-19 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5061,
        '2021-01-19 17:00:00+03',
        '2021-01-19 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5062,
        '2021-01-19 16:00:00+03',
        '2021-01-19 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5063,
        '2021-01-19 17:00:00+03',
        '2021-01-19 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5064,
        '2021-01-19 16:00:00+03',
        '2021-01-19 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5065,
        '2021-01-19 17:00:00+03',
        '2021-01-19 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        5066,
        '2021-01-19 19:00:00+03',
        '2021-01-19 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5067,
        '2021-01-19 20:00:00+03',
        '2021-01-19 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5068,
        '2021-01-19 20:00:00+03',
        '2021-01-19 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5069,
        '2021-01-19 22:00:00+03',
        '2021-01-19 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5070,
        '2021-01-19 19:00:00+03',
        '2021-01-19 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5071,
        '2021-01-19 18:00:00+03',
        '2021-01-19 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5072,
        '2021-01-19 21:00:00+03',
        '2021-01-19 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5073,
        '2021-01-19 21:00:00+03',
        '2021-01-19 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5074,
        '2021-01-19 21:00:00+03',
        '2021-01-19 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5075,
        '2021-01-19 18:00:00+03',
        '2021-01-19 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5076,
        '2021-01-19 21:00:00+03',
        '2021-01-19 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5077,
        '2021-01-19 18:00:00+03',
        '2021-01-19 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5078,
        '2021-01-19 21:00:00+03',
        '2021-01-19 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5079,
        '2021-01-19 19:00:00+03',
        '2021-01-19 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5080,
        '2021-01-19 22:00:00+03',
        '2021-01-19 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5081,
        '2021-01-19 19:00:00+03',
        '2021-01-19 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5082,
        '2021-01-19 22:00:00+03',
        '2021-01-19 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5101,
        '2021-01-20 00:00:00+03',
        '2021-01-20 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5102,
        '2021-01-20 00:00:00+03',
        '2021-01-20 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5103,
        '2021-01-20 01:00:00+03',
        '2021-01-20 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5104,
        '2021-01-20 01:00:00+03',
        '2021-01-20 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5105,
        '2021-01-20 01:00:00+03',
        '2021-01-20 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5106,
        '2021-01-20 01:00:00+03',
        '2021-01-20 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5107,
        '2021-01-20 01:00:00+03',
        '2021-01-20 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5108,
        '2021-01-20 01:00:00+03',
        '2021-01-20 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5109,
        '2021-01-20 01:00:00+03',
        '2021-01-20 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5110,
        '2021-01-20 01:00:00+03',
        '2021-01-20 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5111,
        '2021-01-20 01:00:00+03',
        '2021-01-20 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5112,
        '2021-01-20 01:00:00+03',
        '2021-01-20 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        5113,
        '2021-01-20 01:00:00+03',
        '2021-01-20 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5114,
        '2021-01-20 01:00:00+03',
        '2021-01-20 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5115,
        '2021-01-20 01:00:00+03',
        '2021-01-20 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        5116,
        '2021-01-20 05:00:00+03',
        '2021-01-20 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5117,
        '2021-01-20 04:00:00+03',
        '2021-01-20 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5118,
        '2021-01-20 06:00:00+03',
        '2021-01-20 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5119,
        '2021-01-20 05:00:00+03',
        '2021-01-20 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5120,
        '2021-01-20 06:00:00+03',
        '2021-01-20 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5121,
        '2021-01-20 05:00:00+03',
        '2021-01-20 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5122,
        '2021-01-20 08:00:00+03',
        '2021-01-20 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5123,
        '2021-01-20 09:00:00+03',
        '2021-01-20 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5124,
        '2021-01-20 04:00:00+03',
        '2021-01-20 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5125,
        '2021-01-20 05:00:00+03',
        '2021-01-20 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5126,
        '2021-01-20 08:00:00+03',
        '2021-01-20 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5127,
        '2021-01-20 08:00:00+03',
        '2021-01-20 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5128,
        '2021-01-20 05:00:00+03',
        '2021-01-20 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5129,
        '2021-01-20 06:00:00+03',
        '2021-01-20 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        5130,
        '2021-01-20 05:00:00+03',
        '2021-01-20 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5131,
        '2021-01-20 05:00:00+03',
        '2021-01-20 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5132,
        '2021-01-20 06:00:00+03',
        '2021-01-20 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5133,
        '2021-01-20 09:00:00+03',
        '2021-01-20 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5134,
        '2021-01-20 10:00:00+03',
        '2021-01-20 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5135,
        '2021-01-20 10:00:00+03',
        '2021-01-20 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5136,
        '2021-01-20 12:00:00+03',
        '2021-01-20 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5137,
        '2021-01-20 11:00:00+03',
        '2021-01-20 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5138,
        '2021-01-20 12:00:00+03',
        '2021-01-20 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5139,
        '2021-01-20 11:00:00+03',
        '2021-01-20 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5140,
        '2021-01-20 12:00:00+03',
        '2021-01-20 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5141,
        '2021-01-20 09:00:00+03',
        '2021-01-20 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5142,
        '2021-01-20 10:00:00+03',
        '2021-01-20 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5143,
        '2021-01-20 12:00:00+03',
        '2021-01-20 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5144,
        '2021-01-20 12:00:00+03',
        '2021-01-20 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5145,
        '2021-01-20 10:00:00+03',
        '2021-01-20 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5146,
        '2021-01-20 11:00:00+03',
        '2021-01-20 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5147,
        '2021-01-20 14:00:00+03',
        '2021-01-20 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5148,
        '2021-01-20 12:00:00+03',
        '2021-01-20 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5149,
        '2021-01-20 12:00:00+03',
        '2021-01-20 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5150,
        '2021-01-20 13:00:00+03',
        '2021-01-20 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5151,
        '2021-01-20 15:00:00+03',
        '2021-01-20 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5152,
        '2021-01-20 16:00:00+03',
        '2021-01-20 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5153,
        '2021-01-20 16:00:00+03',
        '2021-01-20 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5154,
        '2021-01-20 15:00:00+03',
        '2021-01-20 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5155,
        '2021-01-20 15:00:00+03',
        '2021-01-20 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5156,
        '2021-01-20 19:00:00+03',
        '2021-01-20 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5157,
        '2021-01-20 17:00:00+03',
        '2021-01-20 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5158,
        '2021-01-20 17:00:00+03',
        '2021-01-20 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5159,
        '2021-01-20 15:00:00+03',
        '2021-01-20 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5160,
        '2021-01-20 15:00:00+03',
        '2021-01-20 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5161,
        '2021-01-20 17:00:00+03',
        '2021-01-20 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5162,
        '2021-01-20 16:00:00+03',
        '2021-01-20 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5163,
        '2021-01-20 17:00:00+03',
        '2021-01-20 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5164,
        '2021-01-20 16:00:00+03',
        '2021-01-20 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5165,
        '2021-01-20 17:00:00+03',
        '2021-01-20 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        5166,
        '2021-01-20 19:00:00+03',
        '2021-01-20 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5167,
        '2021-01-20 20:00:00+03',
        '2021-01-20 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5168,
        '2021-01-20 20:00:00+03',
        '2021-01-20 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5169,
        '2021-01-20 22:00:00+03',
        '2021-01-20 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5170,
        '2021-01-20 19:00:00+03',
        '2021-01-20 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5171,
        '2021-01-20 18:00:00+03',
        '2021-01-20 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5172,
        '2021-01-20 21:00:00+03',
        '2021-01-20 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5173,
        '2021-01-20 21:00:00+03',
        '2021-01-20 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5174,
        '2021-01-20 21:00:00+03',
        '2021-01-20 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5175,
        '2021-01-20 18:00:00+03',
        '2021-01-20 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5176,
        '2021-01-20 21:00:00+03',
        '2021-01-20 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5177,
        '2021-01-20 18:00:00+03',
        '2021-01-20 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5178,
        '2021-01-20 21:00:00+03',
        '2021-01-20 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5179,
        '2021-01-20 19:00:00+03',
        '2021-01-20 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5180,
        '2021-01-20 22:00:00+03',
        '2021-01-20 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5181,
        '2021-01-20 19:00:00+03',
        '2021-01-20 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5182,
        '2021-01-20 22:00:00+03',
        '2021-01-20 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5201,
        '2021-01-21 00:00:00+03',
        '2021-01-21 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5202,
        '2021-01-21 00:00:00+03',
        '2021-01-21 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5203,
        '2021-01-21 01:00:00+03',
        '2021-01-21 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5204,
        '2021-01-21 01:00:00+03',
        '2021-01-21 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5205,
        '2021-01-21 01:00:00+03',
        '2021-01-21 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5206,
        '2021-01-21 01:00:00+03',
        '2021-01-21 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5207,
        '2021-01-21 01:00:00+03',
        '2021-01-21 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5208,
        '2021-01-21 01:00:00+03',
        '2021-01-21 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5209,
        '2021-01-21 01:00:00+03',
        '2021-01-21 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5210,
        '2021-01-21 01:00:00+03',
        '2021-01-21 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5211,
        '2021-01-21 01:00:00+03',
        '2021-01-21 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5212,
        '2021-01-21 01:00:00+03',
        '2021-01-21 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        5213,
        '2021-01-21 01:00:00+03',
        '2021-01-21 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5214,
        '2021-01-21 01:00:00+03',
        '2021-01-21 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5215,
        '2021-01-21 01:00:00+03',
        '2021-01-21 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        5216,
        '2021-01-21 05:00:00+03',
        '2021-01-21 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5217,
        '2021-01-21 04:00:00+03',
        '2021-01-21 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5218,
        '2021-01-21 06:00:00+03',
        '2021-01-21 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5219,
        '2021-01-21 05:00:00+03',
        '2021-01-21 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5220,
        '2021-01-21 06:00:00+03',
        '2021-01-21 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5221,
        '2021-01-21 05:00:00+03',
        '2021-01-21 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5222,
        '2021-01-21 08:00:00+03',
        '2021-01-21 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5223,
        '2021-01-21 09:00:00+03',
        '2021-01-21 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5224,
        '2021-01-21 04:00:00+03',
        '2021-01-21 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5225,
        '2021-01-21 05:00:00+03',
        '2021-01-21 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5226,
        '2021-01-21 08:00:00+03',
        '2021-01-21 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5227,
        '2021-01-21 08:00:00+03',
        '2021-01-21 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5228,
        '2021-01-21 05:00:00+03',
        '2021-01-21 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5229,
        '2021-01-21 06:00:00+03',
        '2021-01-21 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        5230,
        '2021-01-21 05:00:00+03',
        '2021-01-21 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5231,
        '2021-01-21 05:00:00+03',
        '2021-01-21 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5232,
        '2021-01-21 06:00:00+03',
        '2021-01-21 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5233,
        '2021-01-21 09:00:00+03',
        '2021-01-21 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5234,
        '2021-01-21 10:00:00+03',
        '2021-01-21 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5235,
        '2021-01-21 10:00:00+03',
        '2021-01-21 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5236,
        '2021-01-21 12:00:00+03',
        '2021-01-21 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5237,
        '2021-01-21 11:00:00+03',
        '2021-01-21 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5238,
        '2021-01-21 12:00:00+03',
        '2021-01-21 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5239,
        '2021-01-21 11:00:00+03',
        '2021-01-21 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5240,
        '2021-01-21 12:00:00+03',
        '2021-01-21 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5241,
        '2021-01-21 09:00:00+03',
        '2021-01-21 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5242,
        '2021-01-21 10:00:00+03',
        '2021-01-21 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5243,
        '2021-01-21 12:00:00+03',
        '2021-01-21 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5244,
        '2021-01-21 12:00:00+03',
        '2021-01-21 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5245,
        '2021-01-21 10:00:00+03',
        '2021-01-21 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5246,
        '2021-01-21 11:00:00+03',
        '2021-01-21 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5247,
        '2021-01-21 14:00:00+03',
        '2021-01-21 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5248,
        '2021-01-21 12:00:00+03',
        '2021-01-21 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5249,
        '2021-01-21 12:00:00+03',
        '2021-01-21 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5250,
        '2021-01-21 13:00:00+03',
        '2021-01-21 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5251,
        '2021-01-21 15:00:00+03',
        '2021-01-21 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5252,
        '2021-01-21 16:00:00+03',
        '2021-01-21 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5253,
        '2021-01-21 16:00:00+03',
        '2021-01-21 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5254,
        '2021-01-21 15:00:00+03',
        '2021-01-21 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5255,
        '2021-01-21 15:00:00+03',
        '2021-01-21 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5256,
        '2021-01-21 19:00:00+03',
        '2021-01-21 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5257,
        '2021-01-21 17:00:00+03',
        '2021-01-21 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5258,
        '2021-01-21 17:00:00+03',
        '2021-01-21 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5259,
        '2021-01-21 15:00:00+03',
        '2021-01-21 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5260,
        '2021-01-21 15:00:00+03',
        '2021-01-21 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5261,
        '2021-01-21 17:00:00+03',
        '2021-01-21 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5262,
        '2021-01-21 16:00:00+03',
        '2021-01-21 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5263,
        '2021-01-21 17:00:00+03',
        '2021-01-21 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5264,
        '2021-01-21 16:00:00+03',
        '2021-01-21 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5265,
        '2021-01-21 17:00:00+03',
        '2021-01-21 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        5266,
        '2021-01-21 19:00:00+03',
        '2021-01-21 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5267,
        '2021-01-21 20:00:00+03',
        '2021-01-21 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5268,
        '2021-01-21 20:00:00+03',
        '2021-01-21 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5269,
        '2021-01-21 22:00:00+03',
        '2021-01-21 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5270,
        '2021-01-21 19:00:00+03',
        '2021-01-21 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5271,
        '2021-01-21 18:00:00+03',
        '2021-01-21 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5272,
        '2021-01-21 21:00:00+03',
        '2021-01-21 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5273,
        '2021-01-21 21:00:00+03',
        '2021-01-21 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5274,
        '2021-01-21 21:00:00+03',
        '2021-01-21 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5275,
        '2021-01-21 18:00:00+03',
        '2021-01-21 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5276,
        '2021-01-21 21:00:00+03',
        '2021-01-21 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5277,
        '2021-01-21 18:00:00+03',
        '2021-01-21 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5278,
        '2021-01-21 21:00:00+03',
        '2021-01-21 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5279,
        '2021-01-21 19:00:00+03',
        '2021-01-21 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5280,
        '2021-01-21 22:00:00+03',
        '2021-01-21 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5281,
        '2021-01-21 19:00:00+03',
        '2021-01-21 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5282,
        '2021-01-21 22:00:00+03',
        '2021-01-21 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5301,
        '2021-01-22 00:00:00+03',
        '2021-01-22 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5302,
        '2021-01-22 00:00:00+03',
        '2021-01-22 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5303,
        '2021-01-22 01:00:00+03',
        '2021-01-22 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5304,
        '2021-01-22 01:00:00+03',
        '2021-01-22 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5305,
        '2021-01-22 01:00:00+03',
        '2021-01-22 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5306,
        '2021-01-22 01:00:00+03',
        '2021-01-22 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5307,
        '2021-01-22 01:00:00+03',
        '2021-01-22 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5308,
        '2021-01-22 01:00:00+03',
        '2021-01-22 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5309,
        '2021-01-22 01:00:00+03',
        '2021-01-22 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5310,
        '2021-01-22 01:00:00+03',
        '2021-01-22 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5311,
        '2021-01-22 01:00:00+03',
        '2021-01-22 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5312,
        '2021-01-22 01:00:00+03',
        '2021-01-22 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        5313,
        '2021-01-22 01:00:00+03',
        '2021-01-22 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5314,
        '2021-01-22 01:00:00+03',
        '2021-01-22 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5315,
        '2021-01-22 01:00:00+03',
        '2021-01-22 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        5316,
        '2021-01-22 05:00:00+03',
        '2021-01-22 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5317,
        '2021-01-22 04:00:00+03',
        '2021-01-22 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5318,
        '2021-01-22 06:00:00+03',
        '2021-01-22 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5319,
        '2021-01-22 05:00:00+03',
        '2021-01-22 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5320,
        '2021-01-22 06:00:00+03',
        '2021-01-22 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5321,
        '2021-01-22 05:00:00+03',
        '2021-01-22 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5322,
        '2021-01-22 08:00:00+03',
        '2021-01-22 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5323,
        '2021-01-22 09:00:00+03',
        '2021-01-22 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5324,
        '2021-01-22 04:00:00+03',
        '2021-01-22 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5325,
        '2021-01-22 05:00:00+03',
        '2021-01-22 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5326,
        '2021-01-22 08:00:00+03',
        '2021-01-22 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5327,
        '2021-01-22 08:00:00+03',
        '2021-01-22 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5328,
        '2021-01-22 05:00:00+03',
        '2021-01-22 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5329,
        '2021-01-22 06:00:00+03',
        '2021-01-22 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        5330,
        '2021-01-22 05:00:00+03',
        '2021-01-22 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5331,
        '2021-01-22 05:00:00+03',
        '2021-01-22 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5332,
        '2021-01-22 06:00:00+03',
        '2021-01-22 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5333,
        '2021-01-22 09:00:00+03',
        '2021-01-22 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5334,
        '2021-01-22 10:00:00+03',
        '2021-01-22 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5335,
        '2021-01-22 10:00:00+03',
        '2021-01-22 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5336,
        '2021-01-22 12:00:00+03',
        '2021-01-22 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5337,
        '2021-01-22 11:00:00+03',
        '2021-01-22 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5338,
        '2021-01-22 12:00:00+03',
        '2021-01-22 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5339,
        '2021-01-22 11:00:00+03',
        '2021-01-22 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5340,
        '2021-01-22 12:00:00+03',
        '2021-01-22 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5341,
        '2021-01-22 09:00:00+03',
        '2021-01-22 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5342,
        '2021-01-22 10:00:00+03',
        '2021-01-22 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5343,
        '2021-01-22 12:00:00+03',
        '2021-01-22 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5344,
        '2021-01-22 12:00:00+03',
        '2021-01-22 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5345,
        '2021-01-22 10:00:00+03',
        '2021-01-22 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5346,
        '2021-01-22 11:00:00+03',
        '2021-01-22 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5347,
        '2021-01-22 14:00:00+03',
        '2021-01-22 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5348,
        '2021-01-22 12:00:00+03',
        '2021-01-22 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5349,
        '2021-01-22 12:00:00+03',
        '2021-01-22 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5350,
        '2021-01-22 13:00:00+03',
        '2021-01-22 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5351,
        '2021-01-22 15:00:00+03',
        '2021-01-22 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5352,
        '2021-01-22 16:00:00+03',
        '2021-01-22 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5353,
        '2021-01-22 16:00:00+03',
        '2021-01-22 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5354,
        '2021-01-22 15:00:00+03',
        '2021-01-22 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5355,
        '2021-01-22 15:00:00+03',
        '2021-01-22 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5356,
        '2021-01-22 19:00:00+03',
        '2021-01-22 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5357,
        '2021-01-22 17:00:00+03',
        '2021-01-22 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5358,
        '2021-01-22 17:00:00+03',
        '2021-01-22 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5359,
        '2021-01-22 15:00:00+03',
        '2021-01-22 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5360,
        '2021-01-22 15:00:00+03',
        '2021-01-22 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5361,
        '2021-01-22 17:00:00+03',
        '2021-01-22 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5362,
        '2021-01-22 16:00:00+03',
        '2021-01-22 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5363,
        '2021-01-22 17:00:00+03',
        '2021-01-22 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5364,
        '2021-01-22 16:00:00+03',
        '2021-01-22 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5365,
        '2021-01-22 17:00:00+03',
        '2021-01-22 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        5366,
        '2021-01-22 19:00:00+03',
        '2021-01-22 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5367,
        '2021-01-22 20:00:00+03',
        '2021-01-22 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5368,
        '2021-01-22 20:00:00+03',
        '2021-01-22 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5369,
        '2021-01-22 22:00:00+03',
        '2021-01-22 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5370,
        '2021-01-22 19:00:00+03',
        '2021-01-22 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5371,
        '2021-01-22 18:00:00+03',
        '2021-01-22 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5372,
        '2021-01-22 21:00:00+03',
        '2021-01-22 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5373,
        '2021-01-22 21:00:00+03',
        '2021-01-22 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5374,
        '2021-01-22 21:00:00+03',
        '2021-01-22 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5375,
        '2021-01-22 18:00:00+03',
        '2021-01-22 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5376,
        '2021-01-22 21:00:00+03',
        '2021-01-22 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5377,
        '2021-01-22 18:00:00+03',
        '2021-01-22 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5378,
        '2021-01-22 21:00:00+03',
        '2021-01-22 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5379,
        '2021-01-22 19:00:00+03',
        '2021-01-22 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5380,
        '2021-01-22 22:00:00+03',
        '2021-01-22 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5381,
        '2021-01-22 19:00:00+03',
        '2021-01-22 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5382,
        '2021-01-22 22:00:00+03',
        '2021-01-22 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5401,
        '2021-01-23 00:00:00+03',
        '2021-01-23 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5402,
        '2021-01-23 00:00:00+03',
        '2021-01-23 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5403,
        '2021-01-23 01:00:00+03',
        '2021-01-23 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5404,
        '2021-01-23 01:00:00+03',
        '2021-01-23 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5405,
        '2021-01-23 01:00:00+03',
        '2021-01-23 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5406,
        '2021-01-23 01:00:00+03',
        '2021-01-23 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5407,
        '2021-01-23 01:00:00+03',
        '2021-01-23 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5408,
        '2021-01-23 01:00:00+03',
        '2021-01-23 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5409,
        '2021-01-23 01:00:00+03',
        '2021-01-23 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5410,
        '2021-01-23 01:00:00+03',
        '2021-01-23 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5411,
        '2021-01-23 01:00:00+03',
        '2021-01-23 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5412,
        '2021-01-23 01:00:00+03',
        '2021-01-23 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        5413,
        '2021-01-23 01:00:00+03',
        '2021-01-23 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5414,
        '2021-01-23 01:00:00+03',
        '2021-01-23 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5415,
        '2021-01-23 01:00:00+03',
        '2021-01-23 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        5416,
        '2021-01-23 05:00:00+03',
        '2021-01-23 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5417,
        '2021-01-23 04:00:00+03',
        '2021-01-23 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5418,
        '2021-01-23 06:00:00+03',
        '2021-01-23 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5419,
        '2021-01-23 05:00:00+03',
        '2021-01-23 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5420,
        '2021-01-23 06:00:00+03',
        '2021-01-23 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5421,
        '2021-01-23 05:00:00+03',
        '2021-01-23 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5422,
        '2021-01-23 08:00:00+03',
        '2021-01-23 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5423,
        '2021-01-23 09:00:00+03',
        '2021-01-23 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5424,
        '2021-01-23 04:00:00+03',
        '2021-01-23 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5425,
        '2021-01-23 05:00:00+03',
        '2021-01-23 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5426,
        '2021-01-23 08:00:00+03',
        '2021-01-23 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5427,
        '2021-01-23 08:00:00+03',
        '2021-01-23 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5428,
        '2021-01-23 05:00:00+03',
        '2021-01-23 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5429,
        '2021-01-23 06:00:00+03',
        '2021-01-23 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        5430,
        '2021-01-23 05:00:00+03',
        '2021-01-23 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5431,
        '2021-01-23 05:00:00+03',
        '2021-01-23 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5432,
        '2021-01-23 06:00:00+03',
        '2021-01-23 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5433,
        '2021-01-23 09:00:00+03',
        '2021-01-23 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5434,
        '2021-01-23 10:00:00+03',
        '2021-01-23 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5435,
        '2021-01-23 10:00:00+03',
        '2021-01-23 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5436,
        '2021-01-23 12:00:00+03',
        '2021-01-23 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5437,
        '2021-01-23 11:00:00+03',
        '2021-01-23 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5438,
        '2021-01-23 12:00:00+03',
        '2021-01-23 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5439,
        '2021-01-23 11:00:00+03',
        '2021-01-23 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5440,
        '2021-01-23 12:00:00+03',
        '2021-01-23 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5441,
        '2021-01-23 09:00:00+03',
        '2021-01-23 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5442,
        '2021-01-23 10:00:00+03',
        '2021-01-23 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5443,
        '2021-01-23 12:00:00+03',
        '2021-01-23 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5444,
        '2021-01-23 12:00:00+03',
        '2021-01-23 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5445,
        '2021-01-23 10:00:00+03',
        '2021-01-23 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5446,
        '2021-01-23 11:00:00+03',
        '2021-01-23 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5447,
        '2021-01-23 14:00:00+03',
        '2021-01-23 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5448,
        '2021-01-23 12:00:00+03',
        '2021-01-23 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5449,
        '2021-01-23 12:00:00+03',
        '2021-01-23 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5450,
        '2021-01-23 13:00:00+03',
        '2021-01-23 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5451,
        '2021-01-23 15:00:00+03',
        '2021-01-23 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5452,
        '2021-01-23 16:00:00+03',
        '2021-01-23 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5453,
        '2021-01-23 16:00:00+03',
        '2021-01-23 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5454,
        '2021-01-23 15:00:00+03',
        '2021-01-23 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5455,
        '2021-01-23 15:00:00+03',
        '2021-01-23 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5456,
        '2021-01-23 19:00:00+03',
        '2021-01-23 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5457,
        '2021-01-23 17:00:00+03',
        '2021-01-23 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5458,
        '2021-01-23 17:00:00+03',
        '2021-01-23 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5459,
        '2021-01-23 15:00:00+03',
        '2021-01-23 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5460,
        '2021-01-23 15:00:00+03',
        '2021-01-23 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5461,
        '2021-01-23 17:00:00+03',
        '2021-01-23 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5462,
        '2021-01-23 16:00:00+03',
        '2021-01-23 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5463,
        '2021-01-23 17:00:00+03',
        '2021-01-23 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5464,
        '2021-01-23 16:00:00+03',
        '2021-01-23 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5465,
        '2021-01-23 17:00:00+03',
        '2021-01-23 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        5466,
        '2021-01-23 19:00:00+03',
        '2021-01-23 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5467,
        '2021-01-23 20:00:00+03',
        '2021-01-23 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5468,
        '2021-01-23 20:00:00+03',
        '2021-01-23 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5469,
        '2021-01-23 22:00:00+03',
        '2021-01-23 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5470,
        '2021-01-23 19:00:00+03',
        '2021-01-23 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5471,
        '2021-01-23 18:00:00+03',
        '2021-01-23 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5472,
        '2021-01-23 21:00:00+03',
        '2021-01-23 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5473,
        '2021-01-23 21:00:00+03',
        '2021-01-23 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5474,
        '2021-01-23 21:00:00+03',
        '2021-01-23 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5475,
        '2021-01-23 18:00:00+03',
        '2021-01-23 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5476,
        '2021-01-23 21:00:00+03',
        '2021-01-23 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5477,
        '2021-01-23 18:00:00+03',
        '2021-01-23 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5478,
        '2021-01-23 21:00:00+03',
        '2021-01-23 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5479,
        '2021-01-23 19:00:00+03',
        '2021-01-23 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5480,
        '2021-01-23 22:00:00+03',
        '2021-01-23 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5481,
        '2021-01-23 19:00:00+03',
        '2021-01-23 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5482,
        '2021-01-23 22:00:00+03',
        '2021-01-23 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5501,
        '2021-01-24 00:00:00+03',
        '2021-01-24 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5502,
        '2021-01-24 00:00:00+03',
        '2021-01-24 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5503,
        '2021-01-24 01:00:00+03',
        '2021-01-24 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5504,
        '2021-01-24 01:00:00+03',
        '2021-01-24 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5505,
        '2021-01-24 01:00:00+03',
        '2021-01-24 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5506,
        '2021-01-24 01:00:00+03',
        '2021-01-24 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5507,
        '2021-01-24 01:00:00+03',
        '2021-01-24 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5508,
        '2021-01-24 01:00:00+03',
        '2021-01-24 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5509,
        '2021-01-24 01:00:00+03',
        '2021-01-24 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5510,
        '2021-01-24 01:00:00+03',
        '2021-01-24 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5511,
        '2021-01-24 01:00:00+03',
        '2021-01-24 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5512,
        '2021-01-24 01:00:00+03',
        '2021-01-24 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        5513,
        '2021-01-24 01:00:00+03',
        '2021-01-24 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5514,
        '2021-01-24 01:00:00+03',
        '2021-01-24 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5515,
        '2021-01-24 01:00:00+03',
        '2021-01-24 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        5516,
        '2021-01-24 05:00:00+03',
        '2021-01-24 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5517,
        '2021-01-24 04:00:00+03',
        '2021-01-24 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5518,
        '2021-01-24 06:00:00+03',
        '2021-01-24 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5519,
        '2021-01-24 05:00:00+03',
        '2021-01-24 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5520,
        '2021-01-24 06:00:00+03',
        '2021-01-24 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5521,
        '2021-01-24 05:00:00+03',
        '2021-01-24 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5522,
        '2021-01-24 08:00:00+03',
        '2021-01-24 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5523,
        '2021-01-24 09:00:00+03',
        '2021-01-24 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5524,
        '2021-01-24 04:00:00+03',
        '2021-01-24 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5525,
        '2021-01-24 05:00:00+03',
        '2021-01-24 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5526,
        '2021-01-24 08:00:00+03',
        '2021-01-24 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5527,
        '2021-01-24 08:00:00+03',
        '2021-01-24 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5528,
        '2021-01-24 05:00:00+03',
        '2021-01-24 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5529,
        '2021-01-24 06:00:00+03',
        '2021-01-24 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        5530,
        '2021-01-24 05:00:00+03',
        '2021-01-24 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5531,
        '2021-01-24 05:00:00+03',
        '2021-01-24 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5532,
        '2021-01-24 06:00:00+03',
        '2021-01-24 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5533,
        '2021-01-24 09:00:00+03',
        '2021-01-24 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5534,
        '2021-01-24 10:00:00+03',
        '2021-01-24 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5535,
        '2021-01-24 10:00:00+03',
        '2021-01-24 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5536,
        '2021-01-24 12:00:00+03',
        '2021-01-24 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5537,
        '2021-01-24 11:00:00+03',
        '2021-01-24 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5538,
        '2021-01-24 12:00:00+03',
        '2021-01-24 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5539,
        '2021-01-24 11:00:00+03',
        '2021-01-24 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5540,
        '2021-01-24 12:00:00+03',
        '2021-01-24 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5541,
        '2021-01-24 09:00:00+03',
        '2021-01-24 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5542,
        '2021-01-24 10:00:00+03',
        '2021-01-24 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5543,
        '2021-01-24 12:00:00+03',
        '2021-01-24 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5544,
        '2021-01-24 12:00:00+03',
        '2021-01-24 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5545,
        '2021-01-24 10:00:00+03',
        '2021-01-24 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5546,
        '2021-01-24 11:00:00+03',
        '2021-01-24 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5547,
        '2021-01-24 14:00:00+03',
        '2021-01-24 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5548,
        '2021-01-24 12:00:00+03',
        '2021-01-24 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5549,
        '2021-01-24 12:00:00+03',
        '2021-01-24 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5550,
        '2021-01-24 13:00:00+03',
        '2021-01-24 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5551,
        '2021-01-24 15:00:00+03',
        '2021-01-24 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5552,
        '2021-01-24 16:00:00+03',
        '2021-01-24 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5553,
        '2021-01-24 16:00:00+03',
        '2021-01-24 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5554,
        '2021-01-24 15:00:00+03',
        '2021-01-24 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5555,
        '2021-01-24 15:00:00+03',
        '2021-01-24 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5556,
        '2021-01-24 19:00:00+03',
        '2021-01-24 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5557,
        '2021-01-24 17:00:00+03',
        '2021-01-24 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5558,
        '2021-01-24 17:00:00+03',
        '2021-01-24 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5559,
        '2021-01-24 15:00:00+03',
        '2021-01-24 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5560,
        '2021-01-24 15:00:00+03',
        '2021-01-24 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5561,
        '2021-01-24 17:00:00+03',
        '2021-01-24 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5562,
        '2021-01-24 16:00:00+03',
        '2021-01-24 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5563,
        '2021-01-24 17:00:00+03',
        '2021-01-24 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5564,
        '2021-01-24 16:00:00+03',
        '2021-01-24 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5565,
        '2021-01-24 17:00:00+03',
        '2021-01-24 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        5566,
        '2021-01-24 19:00:00+03',
        '2021-01-24 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5567,
        '2021-01-24 20:00:00+03',
        '2021-01-24 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5568,
        '2021-01-24 20:00:00+03',
        '2021-01-24 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5569,
        '2021-01-24 22:00:00+03',
        '2021-01-24 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5570,
        '2021-01-24 19:00:00+03',
        '2021-01-24 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5571,
        '2021-01-24 18:00:00+03',
        '2021-01-24 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5572,
        '2021-01-24 21:00:00+03',
        '2021-01-24 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5573,
        '2021-01-24 21:00:00+03',
        '2021-01-24 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5574,
        '2021-01-24 21:00:00+03',
        '2021-01-24 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5575,
        '2021-01-24 18:00:00+03',
        '2021-01-24 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5576,
        '2021-01-24 21:00:00+03',
        '2021-01-24 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5577,
        '2021-01-24 18:00:00+03',
        '2021-01-24 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5578,
        '2021-01-24 21:00:00+03',
        '2021-01-24 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5579,
        '2021-01-24 19:00:00+03',
        '2021-01-24 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5580,
        '2021-01-24 22:00:00+03',
        '2021-01-24 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5581,
        '2021-01-24 19:00:00+03',
        '2021-01-24 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5582,
        '2021-01-24 22:00:00+03',
        '2021-01-24 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5601,
        '2021-01-25 00:00:00+03',
        '2021-01-25 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5602,
        '2021-01-25 00:00:00+03',
        '2021-01-25 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5603,
        '2021-01-25 01:00:00+03',
        '2021-01-25 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5604,
        '2021-01-25 01:00:00+03',
        '2021-01-25 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5605,
        '2021-01-25 01:00:00+03',
        '2021-01-25 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5606,
        '2021-01-25 01:00:00+03',
        '2021-01-25 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5607,
        '2021-01-25 01:00:00+03',
        '2021-01-25 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5608,
        '2021-01-25 01:00:00+03',
        '2021-01-25 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5609,
        '2021-01-25 01:00:00+03',
        '2021-01-25 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5610,
        '2021-01-25 01:00:00+03',
        '2021-01-25 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5611,
        '2021-01-25 01:00:00+03',
        '2021-01-25 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5612,
        '2021-01-25 01:00:00+03',
        '2021-01-25 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        5613,
        '2021-01-25 01:00:00+03',
        '2021-01-25 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5614,
        '2021-01-25 01:00:00+03',
        '2021-01-25 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5615,
        '2021-01-25 01:00:00+03',
        '2021-01-25 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        5616,
        '2021-01-25 05:00:00+03',
        '2021-01-25 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5617,
        '2021-01-25 04:00:00+03',
        '2021-01-25 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5618,
        '2021-01-25 06:00:00+03',
        '2021-01-25 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5619,
        '2021-01-25 05:00:00+03',
        '2021-01-25 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5620,
        '2021-01-25 06:00:00+03',
        '2021-01-25 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5621,
        '2021-01-25 05:00:00+03',
        '2021-01-25 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5622,
        '2021-01-25 08:00:00+03',
        '2021-01-25 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5623,
        '2021-01-25 09:00:00+03',
        '2021-01-25 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5624,
        '2021-01-25 04:00:00+03',
        '2021-01-25 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5625,
        '2021-01-25 05:00:00+03',
        '2021-01-25 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5626,
        '2021-01-25 08:00:00+03',
        '2021-01-25 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5627,
        '2021-01-25 08:00:00+03',
        '2021-01-25 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5628,
        '2021-01-25 05:00:00+03',
        '2021-01-25 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5629,
        '2021-01-25 06:00:00+03',
        '2021-01-25 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        5630,
        '2021-01-25 05:00:00+03',
        '2021-01-25 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5631,
        '2021-01-25 05:00:00+03',
        '2021-01-25 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5632,
        '2021-01-25 06:00:00+03',
        '2021-01-25 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5633,
        '2021-01-25 09:00:00+03',
        '2021-01-25 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5634,
        '2021-01-25 10:00:00+03',
        '2021-01-25 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5635,
        '2021-01-25 10:00:00+03',
        '2021-01-25 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5636,
        '2021-01-25 12:00:00+03',
        '2021-01-25 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5637,
        '2021-01-25 11:00:00+03',
        '2021-01-25 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5638,
        '2021-01-25 12:00:00+03',
        '2021-01-25 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5639,
        '2021-01-25 11:00:00+03',
        '2021-01-25 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5640,
        '2021-01-25 12:00:00+03',
        '2021-01-25 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5641,
        '2021-01-25 09:00:00+03',
        '2021-01-25 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5642,
        '2021-01-25 10:00:00+03',
        '2021-01-25 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5643,
        '2021-01-25 12:00:00+03',
        '2021-01-25 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5644,
        '2021-01-25 12:00:00+03',
        '2021-01-25 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5645,
        '2021-01-25 10:00:00+03',
        '2021-01-25 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5646,
        '2021-01-25 11:00:00+03',
        '2021-01-25 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5647,
        '2021-01-25 14:00:00+03',
        '2021-01-25 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5648,
        '2021-01-25 12:00:00+03',
        '2021-01-25 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5649,
        '2021-01-25 12:00:00+03',
        '2021-01-25 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5650,
        '2021-01-25 13:00:00+03',
        '2021-01-25 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5651,
        '2021-01-25 15:00:00+03',
        '2021-01-25 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5652,
        '2021-01-25 16:00:00+03',
        '2021-01-25 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5653,
        '2021-01-25 16:00:00+03',
        '2021-01-25 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5654,
        '2021-01-25 15:00:00+03',
        '2021-01-25 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5655,
        '2021-01-25 15:00:00+03',
        '2021-01-25 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5656,
        '2021-01-25 19:00:00+03',
        '2021-01-25 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5657,
        '2021-01-25 17:00:00+03',
        '2021-01-25 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5658,
        '2021-01-25 17:00:00+03',
        '2021-01-25 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5659,
        '2021-01-25 15:00:00+03',
        '2021-01-25 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5660,
        '2021-01-25 15:00:00+03',
        '2021-01-25 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5661,
        '2021-01-25 17:00:00+03',
        '2021-01-25 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5662,
        '2021-01-25 16:00:00+03',
        '2021-01-25 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5663,
        '2021-01-25 17:00:00+03',
        '2021-01-25 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5664,
        '2021-01-25 16:00:00+03',
        '2021-01-25 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5665,
        '2021-01-25 17:00:00+03',
        '2021-01-25 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        5666,
        '2021-01-25 19:00:00+03',
        '2021-01-25 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5667,
        '2021-01-25 20:00:00+03',
        '2021-01-25 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5668,
        '2021-01-25 20:00:00+03',
        '2021-01-25 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5669,
        '2021-01-25 22:00:00+03',
        '2021-01-25 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5670,
        '2021-01-25 19:00:00+03',
        '2021-01-25 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5671,
        '2021-01-25 18:00:00+03',
        '2021-01-25 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5672,
        '2021-01-25 21:00:00+03',
        '2021-01-25 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5673,
        '2021-01-25 21:00:00+03',
        '2021-01-25 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5674,
        '2021-01-25 21:00:00+03',
        '2021-01-25 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5675,
        '2021-01-25 18:00:00+03',
        '2021-01-25 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5676,
        '2021-01-25 21:00:00+03',
        '2021-01-25 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5677,
        '2021-01-25 18:00:00+03',
        '2021-01-25 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5678,
        '2021-01-25 21:00:00+03',
        '2021-01-25 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5679,
        '2021-01-25 19:00:00+03',
        '2021-01-25 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5680,
        '2021-01-25 22:00:00+03',
        '2021-01-25 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5681,
        '2021-01-25 19:00:00+03',
        '2021-01-25 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5682,
        '2021-01-25 22:00:00+03',
        '2021-01-25 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5701,
        '2021-01-26 00:00:00+03',
        '2021-01-26 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5702,
        '2021-01-26 00:00:00+03',
        '2021-01-26 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5703,
        '2021-01-26 01:00:00+03',
        '2021-01-26 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5704,
        '2021-01-26 01:00:00+03',
        '2021-01-26 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5705,
        '2021-01-26 01:00:00+03',
        '2021-01-26 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5706,
        '2021-01-26 01:00:00+03',
        '2021-01-26 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5707,
        '2021-01-26 01:00:00+03',
        '2021-01-26 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5708,
        '2021-01-26 01:00:00+03',
        '2021-01-26 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5709,
        '2021-01-26 01:00:00+03',
        '2021-01-26 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5710,
        '2021-01-26 01:00:00+03',
        '2021-01-26 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5711,
        '2021-01-26 01:00:00+03',
        '2021-01-26 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5712,
        '2021-01-26 01:00:00+03',
        '2021-01-26 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        5713,
        '2021-01-26 01:00:00+03',
        '2021-01-26 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5714,
        '2021-01-26 01:00:00+03',
        '2021-01-26 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5715,
        '2021-01-26 01:00:00+03',
        '2021-01-26 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        5716,
        '2021-01-26 05:00:00+03',
        '2021-01-26 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5717,
        '2021-01-26 04:00:00+03',
        '2021-01-26 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5718,
        '2021-01-26 06:00:00+03',
        '2021-01-26 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5719,
        '2021-01-26 05:00:00+03',
        '2021-01-26 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5720,
        '2021-01-26 06:00:00+03',
        '2021-01-26 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5721,
        '2021-01-26 05:00:00+03',
        '2021-01-26 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5722,
        '2021-01-26 08:00:00+03',
        '2021-01-26 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5723,
        '2021-01-26 09:00:00+03',
        '2021-01-26 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5724,
        '2021-01-26 04:00:00+03',
        '2021-01-26 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5725,
        '2021-01-26 05:00:00+03',
        '2021-01-26 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5726,
        '2021-01-26 08:00:00+03',
        '2021-01-26 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5727,
        '2021-01-26 08:00:00+03',
        '2021-01-26 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5728,
        '2021-01-26 05:00:00+03',
        '2021-01-26 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5729,
        '2021-01-26 06:00:00+03',
        '2021-01-26 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        5730,
        '2021-01-26 05:00:00+03',
        '2021-01-26 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5731,
        '2021-01-26 05:00:00+03',
        '2021-01-26 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5732,
        '2021-01-26 06:00:00+03',
        '2021-01-26 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5733,
        '2021-01-26 09:00:00+03',
        '2021-01-26 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5734,
        '2021-01-26 10:00:00+03',
        '2021-01-26 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5735,
        '2021-01-26 10:00:00+03',
        '2021-01-26 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5736,
        '2021-01-26 12:00:00+03',
        '2021-01-26 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5737,
        '2021-01-26 11:00:00+03',
        '2021-01-26 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5738,
        '2021-01-26 12:00:00+03',
        '2021-01-26 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5739,
        '2021-01-26 11:00:00+03',
        '2021-01-26 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5740,
        '2021-01-26 12:00:00+03',
        '2021-01-26 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5741,
        '2021-01-26 09:00:00+03',
        '2021-01-26 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5742,
        '2021-01-26 10:00:00+03',
        '2021-01-26 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5743,
        '2021-01-26 12:00:00+03',
        '2021-01-26 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5744,
        '2021-01-26 12:00:00+03',
        '2021-01-26 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5745,
        '2021-01-26 10:00:00+03',
        '2021-01-26 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5746,
        '2021-01-26 11:00:00+03',
        '2021-01-26 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5747,
        '2021-01-26 14:00:00+03',
        '2021-01-26 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5748,
        '2021-01-26 12:00:00+03',
        '2021-01-26 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5749,
        '2021-01-26 12:00:00+03',
        '2021-01-26 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5750,
        '2021-01-26 13:00:00+03',
        '2021-01-26 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5751,
        '2021-01-26 15:00:00+03',
        '2021-01-26 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5752,
        '2021-01-26 16:00:00+03',
        '2021-01-26 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5753,
        '2021-01-26 16:00:00+03',
        '2021-01-26 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5754,
        '2021-01-26 15:00:00+03',
        '2021-01-26 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5755,
        '2021-01-26 15:00:00+03',
        '2021-01-26 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5756,
        '2021-01-26 19:00:00+03',
        '2021-01-26 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5757,
        '2021-01-26 17:00:00+03',
        '2021-01-26 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5758,
        '2021-01-26 17:00:00+03',
        '2021-01-26 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5759,
        '2021-01-26 15:00:00+03',
        '2021-01-26 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5760,
        '2021-01-26 15:00:00+03',
        '2021-01-26 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5761,
        '2021-01-26 17:00:00+03',
        '2021-01-26 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5762,
        '2021-01-26 16:00:00+03',
        '2021-01-26 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5763,
        '2021-01-26 17:00:00+03',
        '2021-01-26 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5764,
        '2021-01-26 16:00:00+03',
        '2021-01-26 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5765,
        '2021-01-26 17:00:00+03',
        '2021-01-26 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        5766,
        '2021-01-26 19:00:00+03',
        '2021-01-26 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5767,
        '2021-01-26 20:00:00+03',
        '2021-01-26 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5768,
        '2021-01-26 20:00:00+03',
        '2021-01-26 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5769,
        '2021-01-26 22:00:00+03',
        '2021-01-26 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5770,
        '2021-01-26 19:00:00+03',
        '2021-01-26 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5771,
        '2021-01-26 18:00:00+03',
        '2021-01-26 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5772,
        '2021-01-26 21:00:00+03',
        '2021-01-26 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5773,
        '2021-01-26 21:00:00+03',
        '2021-01-26 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5774,
        '2021-01-26 21:00:00+03',
        '2021-01-26 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5775,
        '2021-01-26 18:00:00+03',
        '2021-01-26 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5776,
        '2021-01-26 21:00:00+03',
        '2021-01-26 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5777,
        '2021-01-26 18:00:00+03',
        '2021-01-26 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5778,
        '2021-01-26 21:00:00+03',
        '2021-01-26 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5779,
        '2021-01-26 19:00:00+03',
        '2021-01-26 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5780,
        '2021-01-26 22:00:00+03',
        '2021-01-26 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5781,
        '2021-01-26 19:00:00+03',
        '2021-01-26 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5782,
        '2021-01-26 22:00:00+03',
        '2021-01-26 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5801,
        '2021-01-27 00:00:00+03',
        '2021-01-27 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5802,
        '2021-01-27 00:00:00+03',
        '2021-01-27 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5803,
        '2021-01-27 01:00:00+03',
        '2021-01-27 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5804,
        '2021-01-27 01:00:00+03',
        '2021-01-27 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5805,
        '2021-01-27 01:00:00+03',
        '2021-01-27 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5806,
        '2021-01-27 01:00:00+03',
        '2021-01-27 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5807,
        '2021-01-27 01:00:00+03',
        '2021-01-27 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5808,
        '2021-01-27 01:00:00+03',
        '2021-01-27 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5809,
        '2021-01-27 01:00:00+03',
        '2021-01-27 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5810,
        '2021-01-27 01:00:00+03',
        '2021-01-27 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5811,
        '2021-01-27 01:00:00+03',
        '2021-01-27 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5812,
        '2021-01-27 01:00:00+03',
        '2021-01-27 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        5813,
        '2021-01-27 01:00:00+03',
        '2021-01-27 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5814,
        '2021-01-27 01:00:00+03',
        '2021-01-27 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5815,
        '2021-01-27 01:00:00+03',
        '2021-01-27 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        5816,
        '2021-01-27 05:00:00+03',
        '2021-01-27 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5817,
        '2021-01-27 04:00:00+03',
        '2021-01-27 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5818,
        '2021-01-27 06:00:00+03',
        '2021-01-27 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5819,
        '2021-01-27 05:00:00+03',
        '2021-01-27 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5820,
        '2021-01-27 06:00:00+03',
        '2021-01-27 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5821,
        '2021-01-27 05:00:00+03',
        '2021-01-27 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5822,
        '2021-01-27 08:00:00+03',
        '2021-01-27 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5823,
        '2021-01-27 09:00:00+03',
        '2021-01-27 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5824,
        '2021-01-27 04:00:00+03',
        '2021-01-27 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5825,
        '2021-01-27 05:00:00+03',
        '2021-01-27 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5826,
        '2021-01-27 08:00:00+03',
        '2021-01-27 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5827,
        '2021-01-27 08:00:00+03',
        '2021-01-27 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5828,
        '2021-01-27 05:00:00+03',
        '2021-01-27 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5829,
        '2021-01-27 06:00:00+03',
        '2021-01-27 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        5830,
        '2021-01-27 05:00:00+03',
        '2021-01-27 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5831,
        '2021-01-27 05:00:00+03',
        '2021-01-27 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5832,
        '2021-01-27 06:00:00+03',
        '2021-01-27 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5833,
        '2021-01-27 09:00:00+03',
        '2021-01-27 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5834,
        '2021-01-27 10:00:00+03',
        '2021-01-27 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5835,
        '2021-01-27 10:00:00+03',
        '2021-01-27 14:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5836,
        '2021-01-27 12:00:00+03',
        '2021-01-27 15:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5837,
        '2021-01-27 11:00:00+03',
        '2021-01-27 15:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5838,
        '2021-01-27 12:00:00+03',
        '2021-01-27 14:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5839,
        '2021-01-27 11:00:00+03',
        '2021-01-27 14:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5840,
        '2021-01-27 12:00:00+03',
        '2021-01-27 18:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5841,
        '2021-01-27 09:00:00+03',
        '2021-01-27 13:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5842,
        '2021-01-27 10:00:00+03',
        '2021-01-27 16:00:00+03',
        'LAX',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5843,
        '2021-01-27 12:00:00+03',
        '2021-01-27 14:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5844,
        '2021-01-27 12:00:00+03',
        '2021-01-27 14:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5845,
        '2021-01-27 10:00:00+03',
        '2021-01-27 16:00:00+03',
        'JFK',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5846,
        '2021-01-27 11:00:00+03',
        '2021-01-27 15:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5847,
        '2021-01-27 14:00:00+03',
        '2021-01-27 16:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5848,
        '2021-01-27 12:00:00+03',
        '2021-01-27 16:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5849,
        '2021-01-27 12:00:00+03',
        '2021-01-27 15:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5850,
        '2021-01-27 13:00:00+03',
        '2021-01-27 16:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5851,
        '2021-01-27 15:00:00+03',
        '2021-01-27 18:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5852,
        '2021-01-27 16:00:00+03',
        '2021-01-27 19:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5853,
        '2021-01-27 16:00:00+03',
        '2021-01-27 19:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5854,
        '2021-01-27 15:00:00+03',
        '2021-01-27 18:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5855,
        '2021-01-27 15:00:00+03',
        '2021-01-27 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5856,
        '2021-01-27 19:00:00+03',
        '2021-01-27 22:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5857,
        '2021-01-27 17:00:00+03',
        '2021-01-27 20:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5858,
        '2021-01-27 17:00:00+03',
        '2021-01-27 20:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5859,
        '2021-01-27 15:00:00+03',
        '2021-01-27 17:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5860,
        '2021-01-27 15:00:00+03',
        '2021-01-27 17:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5861,
        '2021-01-27 17:00:00+03',
        '2021-01-27 20:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5862,
        '2021-01-27 16:00:00+03',
        '2021-01-27 18:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5863,
        '2021-01-27 17:00:00+03',
        '2021-01-27 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5864,
        '2021-01-27 16:00:00+03',
        '2021-01-27 18:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5865,
        '2021-01-27 17:00:00+03',
        '2021-01-27 21:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  


INSERT INTO MTAMJQ.flights
VALUES (
        5866,
        '2021-01-27 19:00:00+03',
        '2021-01-27 21:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5867,
        '2021-01-27 20:00:00+03',
        '2021-01-27 23:45:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5868,
        '2021-01-27 20:00:00+03',
        '2021-01-27 23:45:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5869,
        '2021-01-27 22:00:00+03',
        '2021-01-27 23:45:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '773',
        150,
        0,
        'N',
        'Y'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5870,
        '2021-01-27 19:00:00+03',
        '2021-01-27 22:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5871,
        '2021-01-27 18:00:00+03',
        '2021-01-27 20:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5872,
        '2021-01-27 21:00:00+03',
        '2021-01-27 23:45:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5873,
        '2021-01-27 21:00:00+03',
        '2021-01-27 23:45:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5874,
        '2021-01-27 21:00:00+03',
        '2021-01-27 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5875,
        '2021-01-27 18:00:00+03',
        '2021-01-27 20:00:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5876,
        '2021-01-27 21:00:00+03',
        '2021-01-27 23:45:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '322',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5877,
        '2021-01-27 18:00:00+03',
        '2021-01-27 22:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5878,
        '2021-01-27 21:00:00+03',
        '2021-01-27 23:45:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5879,
        '2021-01-27 19:00:00+03',
        '2021-01-27 23:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5880,
        '2021-01-27 22:00:00+03',
        '2021-01-27 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5881,
        '2021-01-27 19:00:00+03',
        '2021-01-27 22:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '550',
        150,
        0,
        'N',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5882,
        '2021-01-27 22:00:00+03',
        '2021-01-27 23:45:00+03',
        'HOU',
        'ORD',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );  

INSERT INTO MTAMJQ.flights
VALUES (
        5901,
        '2021-01-28 00:00:00+03',
        '2021-01-28 03:00:00+03',
        'HOU',
        'LAX',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5902,
        '2021-01-28 00:00:00+03',
        '2021-01-28 02:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5903,
        '2021-01-28 01:00:00+03',
        '2021-01-28 05:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5904,
        '2021-01-28 01:00:00+03',
        '2021-01-28 04:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5905,
        '2021-01-28 01:00:00+03',
        '2021-01-28 05:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5906,
        '2021-01-28 01:00:00+03',
        '2021-01-28 04:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5907,
        '2021-01-28 01:00:00+03',
        '2021-01-28 03:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5908,
        '2021-01-28 01:00:00+03',
        '2021-01-28 04:00:00+03',
        'MIA',
        'ORD',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5909,
        '2021-01-28 01:00:00+03',
        '2021-01-28 07:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5910,
        '2021-01-28 01:00:00+03',
        '2021-01-28 07:00:00+03',
        'LAX',
        'JFK',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5911,
        '2021-01-28 01:00:00+03',
        '2021-01-28 04:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5912,
        '2021-01-28 01:00:00+03',
        '2021-01-28 06:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      

INSERT INTO MTAMJQ.flights
VALUES (
        5913,
        '2021-01-28 01:00:00+03',
        '2021-01-28 04:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5914,
        '2021-01-28 01:00:00+03',
        '2021-01-28 04:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5915,
        '2021-01-28 01:00:00+03',
        '2021-01-28 05:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   
   
INSERT INTO MTAMJQ.flights
VALUES (
        5916,
        '2021-01-28 05:00:00+03',
        '2021-01-28 09:00:00+03',
        'LAX',
        'ORD',
        'Scheduled',
        '773',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5917,
        '2021-01-28 04:00:00+03',
        '2021-01-28 07:00:00+03',
        'MIA',
        'JFK',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5918,
        '2021-01-28 06:00:00+03',
        '2021-01-28 10:00:00+03',
        'JFK',
        'HOU',
        'Scheduled',
        '753',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5919,
        '2021-01-28 05:00:00+03',
        '2021-01-28 08:00:00+03',
        'ORD',
        'MIA',
        'Scheduled',
        'SU7',
        150,
        0,
        'N',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5920,
        '2021-01-28 06:00:00+03',
        '2021-01-28 10:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'SU8',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5921,
        '2021-01-28 05:00:00+03',
        '2021-01-28 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        'SU9',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5922,
        '2021-01-28 08:00:00+03',
        '2021-01-28 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        '763',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5923,
        '2021-01-28 09:00:00+03',
        '2021-01-28 11:00:00+03',
        'MIA',
        'HOU',
        'Scheduled',
        'SU7',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5924,
        '2021-01-28 04:00:00+03',
        '2021-01-28 08:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        '320',
        150,
        0,
        'Y',
        'Y'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5925,
        '2021-01-28 05:00:00+03',
        '2021-01-28 09:00:00+03',
        'ORD',
        'LAX',
        'Scheduled',
        '321',
        150,
        0,
        'Y',
        'N'
    );

INSERT INTO MTAMJQ.flights
VALUES (
        5926,
        '2021-01-28 08:00:00+03',
        '2021-01-28 11:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '322',
        150,
        0,
        'Y',
        'N'
    );


INSERT INTO MTAMJQ.flights
VALUES (
        5927,
        '2021-01-28 08:00:00+03',
        '2021-01-28 11:00:00+03',
        'JFK',
        'MIA',
        'Scheduled',
        'AS1',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5928,
        '2021-01-28 05:00:00+03',
        '2021-01-28 09:00:00+03',
        'HOU',
        'JFK',
        'Scheduled',
        'AS2',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5929,
        '2021-01-28 06:00:00+03',
        '2021-01-28 10:00:00+03',
        'ORD',
        'JFK',
        'Scheduled',
        'AS3',
        150,
        0,
        'Y',
        'N'
    );      



INSERT INTO MTAMJQ.flights
VALUES (
        5930,
        '2021-01-28 05:00:00+03',
        '2021-01-28 08:00:00+03',
        'JFK',
        'ORD',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5931,
        '2021-01-28 05:00:00+03',
        '2021-01-28 11:00:00+03',
        'MIA',
        'LAX',
        'Scheduled',
        '550',
        150,
        0,
        'Y',
        'Y'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5932,
        '2021-01-28 06:00:00+03',
        '2021-01-28 09:00:00+03',
        'LAX',
        'HOU',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5933,
        '2021-01-28 09:00:00+03',
        '2021-01-28 11:00:00+03',
        'ORD',
        'HOU',
        'Scheduled',
        '540',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5934,
        '2021-01-28 10:00:00+03',
        '2021-01-28 12:00:00+03',
        'HOU',
        'MIA',
        'Scheduled',
        '560',
        150,
        0,
        'Y',
        'N'
    );   

INSERT INTO MTAMJQ.flights
VALUES (
        5935,
        '2021-01-28 10:00:00+03',


