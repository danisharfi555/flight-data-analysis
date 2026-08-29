# ✈️ Airline & Flight Data Analysis using SQL

## 📌 Project Overview

This project analyzes airline and flight data using Microsoft SQL Server to uncover insights related to airport traffic, airline performance, passenger behavior, ticket sales, and revenue.

The project demonstrates how SQL can be used to transform relational data into meaningful business insights and answer real-world analytical questions.

---

## 🎯 Project Objectives

The main objectives of this project are to:

- Analyze airport traffic and flight activity
- Evaluate airline ticket sales and revenue
- Identify passenger travel preferences
- Analyze flight routes and ticket pricing
- Rank airlines based on performance
- Identify high-value passengers
- Practice advanced SQL techniques on relational data

---

## 🗂️ Database Schema

The database contains five main tables:

- **Passengers** – Passenger information
- **Tickets** – Ticket purchases and pricing
- **Flights** – Flight schedules and routes
- **Airlines** – Airline information
- **Airports** – Airport information

These tables are connected through primary and foreign keys to support multi-table analysis.

---

## 🛠️ Tools & Technologies

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL

---

## 📚 SQL Concepts Demonstrated

This project uses:

- SELECT, WHERE and ORDER BY
- INNER JOIN
- Multiple-table JOINs
- GROUP BY
- Aggregate Functions
- CASE Statements
- Subqueries
- Common Table Expressions (CTEs)
- Window Functions
- RANK()
- PARTITION BY
- Date and Time Functions
- DATEDIFF()

---

## 🔍 Business Questions Answered

The SQL analysis answers 10 business questions:

1. Which airport has the highest number of departing flights?
2. How many tickets were sold by each airline?
3. Which flights are operated by IndiGo and what are their routes?
4. Which airline operates the most flights from each airport?
5. How can flights be categorized based on flight duration?
6. What are the earliest and latest flight dates for each airline?
7. Which routes have the highest ticket prices?
8. Which passengers have spent the most on tickets?
9. How do airlines rank by revenue for different flight statuses?
10. Which airline is used most frequently by each passenger?

---

## 💡 Analysis Highlights

The project demonstrates the ability to:

- Join multiple relational tables to create meaningful datasets
- Calculate airline-level revenue and ticket metrics
- Analyze passenger purchasing behavior
- Rank results within different groups using window functions
- Identify top-performing airlines and passengers
- Analyze airport and route-level performance
- Convert raw flight data into business-focused insights

---

## 🧠 Advanced SQL Example

One of the key techniques used in this project is ranking results within groups:

```sql
RANK() OVER (
    PARTITION BY PassengerID
    ORDER BY TicketsWithAirline DESC
)

