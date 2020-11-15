# !/usr/bin/env python
# Bach Hoang
# ID:1852211
# Ryan Beerwinkle
# ID: 1858538

import psycopg2
import sys
import threading
from itertools import islice

bookRef = 0
ticketNum = 0
un = 0
update = 0
with open('password.txt') as f:
    lines = [line.rstrip() for line in f]
    username = lines[0]
    pg_password = lines[1]
connection = psycopg2.connect(database="COSC3380", user=username, password=pg_password)
sqlfile = open('transaction-bookings.sql', 'w')


def getArgs():
    arglist = sys.argv[1].split(";")
    txtfile = arglist[0].split("=")
    transaction = arglist[1].split("=")
    if (transaction[1] == "y"):
        useTransaction = True
    else:
        useTransaction = False
    threadCount = arglist[2].split("=")
    return txtfile[1], useTransaction, int(threadCount[1])


def readFile(fileName, threadCount):
    passengerList = []
    length_to_split = []
    remainder = 0

    file = open(fileName, "r")
    passengers = file.readlines()
    size = (len(passengers) - 1) / threadCount
    if int(size) < size:
        remainder = (size - int(size)) * 10;
    size = int(size)
    for i in range(0, threadCount):
        if remainder == 0:
            length_to_split.append(size)
        else:
            length_to_split.append(size + 1)
            remainder -= 1

    for i in range(1, len(passengers)):
        passengerList.append(passengers[i].rstrip('\n'))

    Inputt = iter(passengerList)
    Output = [list(islice(Inputt, elem))
              for elem in length_to_split]
    return Output


# transaction query
# check for errors

def transaction(bookings, lock):
    global bookRef
    global ticketNum
    global un
    global update
    cursor = connection.cursor()

    for i in range(0, len(bookings)):
        passengerID, flightID = bookings[i].split(",")

        lock.acquire()
        bookRef += 1
        ticketNum += 1
        lock.release()

        check_flight_ID = "SELECT flight_id FROM flights WHERE flight_id = %s" % (flightID)
        cursor.execute(check_flight_ID)
        check_flight = cursor.fetchone()

        if passengerID != '' and check_flight != None:
            update += 1
            booking_query = "INSERT INTO bookings (book_ref, book_date, total_amount) VALUES (%d, " % (
                bookRef) + "current_timestamp, 500)"
            cursor.execute(booking_query)
            sqlfile.write(booking_query + '\n')

            check_available_seats = "SELECT COUNT(seats_available) FROM flights" + \
                                    "\n WHERE flight_id = %s and seats_available <> 0;" % (flightID)
            cursor.execute(check_available_seats)
            check_ok = cursor.fetchone()

            if check_ok[0] > 0:
                ticket_query = "INSERT INTO ticket" + \
                               "\nVALUES (%d, %d, %s, 'passenger', NULL, NULL)" % (ticketNum, bookRef, passengerID)
                cursor.execute(ticket_query)

                ticket_flights_query = "INSERT INTO ticket_flights (ticket_no, flight_id, fare_conditions, amount) VALUES (%d, %s," % (
                    ticketNum, flightID) + "'Economy', 500)"
                cursor.execute(ticket_flights_query)

                flights_query = "UPDATE flights" + \
                                "\n SET seats_available = seats_available - 1, seats_booked = seats_booked + 1" + \
                                "\n WHERE flights.flight_id = %s AND flights.seats_available <> 0;" % (flightID)
                cursor.execute(flights_query)

                sqlfile.write(ticket_query + '\n')
                sqlfile.write(ticket_flights_query + '\n')
                sqlfile.write(flights_query + '\n')

            elif check_ok[0] == 0:
                un += 1

        connection.commit()


# no transaction
# no error checking
def nonTransaction(passengerList, lock):
    global bookRef
    global ticketNum
    cursor = connection.cursor()

    for i in range(0, len(passengerList)):
        passengerID, flightID = passengerList[i].split(",")

        lock.acquire()
        bookRef += 1
        ticketNum += 1
        lock.release()

        booking_query = "INSERT INTO bookings" + \
                        "\nVALUES(%s, current_timestamp, 500);" % (bookRef)
        cursor.execute(booking_query)
        sqlfile.write(booking_query + '\n')

        ticket_query = "INSERT INTO ticket" + \
                       "\nSELECT %d, %d, %s, 'passenger', NULL, NULL FROM flights" % (ticketNum, bookRef, passengerID) + \
                       "\nWHERE flight_id = %s AND seats_available <> 0;" % (flightID)
        cursor.execute(ticket_query)
        sqlfile.write(ticket_query + '\n')

        ticket_flights_query = "INSERT INTO ticket_flights" + \
                               "\nSELECT %d, %s, 'Economy', 500 FROM flights" % (ticketNum, flightID) + \
                               "\nWHERE flight_id = %s AND seats_available <> 0;" % (flightID)
        cursor.execute(ticket_flights_query)
        sqlfile.write(ticket_flights_query + '\n')

        flights_query = "UPDATE flights" + \
                        "\n SET seats_available = seats_available - 1, seats_booked = seats_booked + 1" + \
                        "\n WHERE flights.flight_id = %s AND flights.seats_available <> 0;" % (flightID)
        cursor.execute(flights_query)
        sqlfile.write(flights_query + '\n')


def createThreads(passengerList, threadCount, useTransaction):
    threads = []
    lock = threading.Lock()
    for i in range(0, threadCount):
        if useTransaction:
            threads.append(threading.Thread(target=transaction, args=(passengerList[i], lock)))
        else:
            threads.append(threading.Thread(target=nonTransaction, args=(passengerList[i], lock)))
        threads[i].start()
        threads[i].join()


def print_text():
    cursor = connection.cursor()
    cursor.execute("SELECT COUNT(book_ref) FROM bookings")
    number_of_bookings = cursor.fetchone()
    cursor.execute("SELECT COUNT(ticket_no) FROM ticket_flights")
    number_of_ticket_flights = cursor.fetchone()
    cursor.execute("SELECT COUNT(ticket_no) FROM ticket")
    number_of_ticket = cursor.fetchone()
    cursor.execute("SELECT SUM(flights.seats_booked) FROM flights")
    number_of_flights = cursor.fetchone()
    good = update - un
    print("Successful Trans: %d" % (good))
    print("Unsuccessful Trans: %d" % (un))
    print("# records update for table bookings: %d" % (number_of_bookings[0]))
    print("# records update for table ticket_flights: %d" % (number_of_ticket[0]))
    print("# records update for table ticket: %d" % (number_of_ticket_flights[0]))
    print("# records update for table flights: %d" % (number_of_flights[0]))


def main():
    connection.autocommit = False
    fileName, useTransaction, threadCount = getArgs()
    passengerList = readFile(fileName, threadCount)
    try:
        createThreads(passengerList, threadCount, useTransaction)
    except(KeyboardInterrupt, SystemExit):
        # print("You killed me at booking.book_ref %d") %bookRef
        print_text()
        sys.exit(0)
    else:
        print_text()
        sqlfile.close()


if __name__ == "__main__":
    main()