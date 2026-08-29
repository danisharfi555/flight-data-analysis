/*=============================================================================
  Project: Airline & Flight Data Analysis
  Platform: Microsoft SQL Server
  Focus: Joins, Aggregations, CTEs, CASE, Window Functions, Ranking
=============================================================================*/

/* Q1. Find the busiest airport by the number of departing flights. */
SELECT TOP 1
    a.Name AS AirportName,
    COUNT(*) AS TotalFlights
FROM Flights AS f
INNER JOIN Airports AS a
    ON f.Origin = a.AirportID
GROUP BY a.AirportID, a.Name
ORDER BY TotalFlights DESC;


/* Q2. Find the total number of tickets sold per airline. */
SELECT
    a.Name AS AirlineName,
    COUNT(t.TicketID) AS TicketsSold
FROM Tickets AS t
INNER JOIN Flights AS f
    ON t.FlightID = f.FlightID
INNER JOIN Airlines AS a
    ON f.AirlineID = a.AirlineID
GROUP BY a.AirlineID, a.Name
ORDER BY TicketsSold DESC;


/* Q3. List all IndiGo flights with origin and destination airport names. */
SELECT
    f.FlightID,
    origin_airport.Name AS OriginAirport,
    destination_airport.Name AS DestinationAirport
FROM Flights AS f
INNER JOIN Airlines AS a
    ON f.AirlineID = a.AirlineID
INNER JOIN Airports AS origin_airport
    ON f.Origin = origin_airport.AirportID
INNER JOIN Airports AS destination_airport
    ON f.Destination = destination_airport.AirportID
WHERE LOWER(a.Name) = 'indigo'
ORDER BY f.FlightID;


/* Q4. For each airport, show the top airline(s) by number of departing flights. */
;WITH FlightCounts AS (
    SELECT
        f.Origin,
        f.AirlineID,
        COUNT(*) AS FlightCount
    FROM Flights AS f
    GROUP BY f.Origin, f.AirlineID
),
RankedAirlines AS (
    SELECT
        Origin,
        AirlineID,
        FlightCount,
        RANK() OVER (
            PARTITION BY Origin
            ORDER BY FlightCount DESC
        ) AS AirlineRank
    FROM FlightCounts
)
SELECT
    ap.Name AS AirportName,
    al.Name AS AirlineName,
    r.FlightCount
FROM RankedAirlines AS r
INNER JOIN Airports AS ap
    ON r.Origin = ap.AirportID
INNER JOIN Airlines AS al
    ON r.AirlineID = al.AirlineID
WHERE r.AirlineRank = 1
ORDER BY ap.Name, al.Name;


/* Q5. Calculate flight duration in hours and classify each flight as
       Short (<2 hours), Medium (2-5 hours), or Long (>5 hours). */
SELECT
    FlightID,
    DepartureTime,
    ArrivalTime,
    CAST(
        DATEDIFF(MINUTE, DepartureTime, ArrivalTime) / 60.0
        AS DECIMAL(10, 2)
    ) AS DurationHours,
    CASE
        WHEN DATEDIFF(MINUTE, DepartureTime, ArrivalTime) < 120 THEN 'Short'
        WHEN DATEDIFF(MINUTE, DepartureTime, ArrivalTime) <= 300 THEN 'Medium'
        ELSE 'Long'
    END AS FlightCategory
FROM Flights
ORDER BY FlightID;


/* Q6. Show each passenger's first flight date, last flight date,
       and total number of flights. */
;WITH PassengerFlightSummary AS (
    SELECT
        t.PassengerID,
        MIN(f.DepartureTime) AS FirstFlight,
        MAX(f.DepartureTime) AS LastFlight,
        COUNT(*) AS TotalFlights
    FROM Tickets AS t
    INNER JOIN Flights AS f
        ON t.FlightID = f.FlightID
    GROUP BY t.PassengerID
)
SELECT
    p.PassengerID,
    p.Name AS PassengerName,
    s.FirstFlight,
    s.LastFlight,
    s.TotalFlights
FROM PassengerFlightSummary AS s
INNER JOIN Passengers AS p
    ON s.PassengerID = p.PassengerID
ORDER BY s.TotalFlights DESC, p.PassengerID;


/* Q7. Find the highest-priced ticket(s) sold for each route. */
;WITH RankedRouteTickets AS (
    SELECT
        f.FlightID,
        f.Origin,
        f.Destination,
        t.TicketID,
        t.Price,
        RANK() OVER (
            PARTITION BY f.Origin, f.Destination
            ORDER BY t.Price DESC
        ) AS PriceRank
    FROM Tickets AS t
    INNER JOIN Flights AS f
        ON t.FlightID = f.FlightID
)
SELECT
    origin_airport.Name AS OriginAirport,
    destination_airport.Name AS DestinationAirport,
    r.FlightID,
    r.TicketID,
    CAST(r.Price AS DECIMAL(12, 2)) AS TicketPrice
FROM RankedRouteTickets AS r
INNER JOIN Airports AS origin_airport
    ON r.Origin = origin_airport.AirportID
INNER JOIN Airports AS destination_airport
    ON r.Destination = destination_airport.AirportID
WHERE r.PriceRank = 1
ORDER BY origin_airport.Name, destination_airport.Name;


/* Q8. Find the highest-spending passenger(s) in each frequent flyer status group. */
;WITH PassengerSpending AS (
    SELECT
        p.PassengerID,
        p.Name AS PassengerName,
        p.FrequentFlyerStatus,
        SUM(t.Price) AS TotalSpent
    FROM Passengers AS p
    INNER JOIN Tickets AS t
        ON p.PassengerID = t.PassengerID
    GROUP BY
        p.PassengerID,
        p.Name,
        p.FrequentFlyerStatus
),
RankedPassengerSpending AS (
    SELECT
        PassengerID,
        PassengerName,
        FrequentFlyerStatus,
        TotalSpent,
        RANK() OVER (
            PARTITION BY FrequentFlyerStatus
            ORDER BY TotalSpent DESC
        ) AS SpendingRank
    FROM PassengerSpending
)
SELECT
    PassengerID,
    PassengerName,
    FrequentFlyerStatus,
    CAST(TotalSpent AS DECIMAL(12, 2)) AS TotalSpent
FROM RankedPassengerSpending
WHERE SpendingRank = 1
ORDER BY FrequentFlyerStatus, PassengerName;


/* Q9. Calculate total revenue and tickets sold for each airline,
       then rank airlines by total revenue. */
;WITH AirlineRevenue AS (
    SELECT
        a.AirlineID,
        a.Name AS AirlineName,
        COUNT(t.TicketID) AS TicketsSold,
        SUM(t.Price) AS TotalRevenue
    FROM Airlines AS a
    INNER JOIN Flights AS f
        ON a.AirlineID = f.AirlineID
    INNER JOIN Tickets AS t
        ON f.FlightID = t.FlightID
    GROUP BY a.AirlineID, a.Name
)
SELECT
    AirlineName,
    TicketsSold,
    CAST(TotalRevenue AS DECIMAL(12, 2)) AS TotalRevenue,
    RANK() OVER (
        ORDER BY TotalRevenue DESC
    ) AS RevenueRank
FROM AirlineRevenue
ORDER BY RevenueRank, AirlineName;


/* Q10. For each passenger, identify the airline(s) they use most frequently.
        If multiple airlines have the same highest usage, show all tied airlines. */
;WITH PassengerAirlineUsage AS (
    SELECT
        p.PassengerID,
        p.Name AS PassengerName,
        a.AirlineID,
        a.Name AS AirlineName,
        COUNT(*) AS TicketsWithAirline
    FROM Passengers AS p
    INNER JOIN Tickets AS t
        ON p.PassengerID = t.PassengerID
    INNER JOIN Flights AS f
        ON t.FlightID = f.FlightID
    INNER JOIN Airlines AS a
        ON f.AirlineID = a.AirlineID
    GROUP BY
        p.PassengerID,
        p.Name,
        a.AirlineID,
        a.Name
),
RankedPassengerAirlines AS (
    SELECT
        PassengerID,
        PassengerName,
        AirlineID,
        AirlineName,
        TicketsWithAirline,
        RANK() OVER (
            PARTITION BY PassengerID
            ORDER BY TicketsWithAirline DESC
        ) AS AirlineRank
    FROM PassengerAirlineUsage
)
SELECT
    PassengerID,
    PassengerName,
    AirlineName,
    TicketsWithAirline
FROM RankedPassengerAirlines
WHERE AirlineRank = 1
ORDER BY PassengerID, AirlineName;










		










		


       
			















