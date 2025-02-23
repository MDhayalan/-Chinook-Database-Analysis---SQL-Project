/****************************************************
1. Time range between which the orders were placed
*****************************************************/
create view time_range as 
select min(InvoiceDate) as Firstday,
		max(InvoiceDate) as Lastday
from Invoice;

select Firstday, Lastday
from time_range;

/**************************************
2. Data type
***************************************/
select *
from Chinook.INFORMATION_SCHEMA.columns;

/****************************************************
3. Number of cities, states and countries
*****************************************************/
SELECT 
    count (distinct City) as Number_of_cities,
    count (distinct State) as Number_of_states, 
    count (distinct Country) as Number_of_countries
FROM Customer;

/****************************************************
4. Number of customers per city, state and country
*****************************************************/
SELECT 
    Country, 
    COALESCE(State, 'Unknown') AS State, 
    City, 
    COUNT(DISTINCT CustomerId) AS No_of_customers
FROM Customer
GROUP BY Country, State, City
ORDER BY Country, State, City;

/****************************************************
5. Database Integrity & Cleaning
*****************************************************/
select FirstName, LastName, Phone, COUNT(*) AS Count
from Customer
group by FirstName, LastName, Phone
having COUNT(*) > 1;

/****************************************************
6. Customer and sales analysis
*****************************************************/
select c.CustomerId, c.FirstName, c.LastName, sum(i.Total) AS TotalSpent,
       rank() over (order by sum(i.Total) DESC) AS Rank,
	   ntile(4) over (order by sum(Total) desc) as Spending_Quartile
from Customer c
join Invoice i ON c.CustomerId = i.CustomerId
group by c.CustomerId, c.FirstName, c.LastName;

/***********************************************************
7. Employee Performance Analysis
************************************************************/
select e.EmployeeId, e.FirstName, e.LastName, sum(i.Total) AS TotalSales,
       dense_rank() over (order by sum(i.Total) desc) AS Rank
from Employee e
join Customer c on e.EmployeeId = c.SupportRepId
join Invoice i on c.CustomerId = i.CustomerId
group by e.EmployeeId, e.FirstName, e.LastName;

/***********************************************************
8. Music Genre & Track Popularity Analysis
************************************************************/
Select top 5 g.Name AS Genre, COUNT(il.InvoiceLineId) AS TrackCount
from Genre g
join Track t ON g.GenreId = t.GenreId
join InvoiceLine il ON t.TrackId = il.TrackId
group by g.Name
order by TrackCount DESC;

select top 5 a.Title AS Album, ar.Name AS Artist, COUNT(il.InvoiceLineId) AS Sales
from Album a
join Artist ar ON a.ArtistId = ar.ArtistId
join Track t ON a.AlbumId = t.AlbumId
join InvoiceLine il ON t.TrackId = il.TrackId
group by a.Title, ar.Name
order BY Sales DESC;

/***********************************************************
9. Business Revenue & Pricing Strategy
************************************************************/
select avg(Total) AS AvgOrderValue, sum(Total) as TotalOrderValue
from Invoice;

select top 5 Name, UnitPrice
from Track
order by UnitPrice asc;

/***********************************************************
10. Customer Behavior & Retention Analysis
************************************************************/
select top 10 c.CustomerId, c.FirstName, c.LastName, COUNT(il.InvoiceLineId) AS TracksPurchased
from Customer c
join Invoice i ON c.CustomerId = i.CustomerId
join InvoiceLine il ON i.InvoiceId = il.InvoiceId
group by c.CustomerId, c.FirstName, c.LastName
order by TracksPurchased DESC;

select c.CustomerId, c.FirstName, c.LastName, max(InvoiceDate) AS LastPurchaseDate
from Customer c 
join Invoice i on c.CustomerId = i.CustomerId
Group by c.CustomerId, c.FirstName, c.LastName
having max(InvoiceDate) < DATEADD(year, -1, (select LastDay from time_range)) 
order by LastPurchaseDate ASC;

/***********************************************************
11. Monthly Sales Trends
************************************************************/
with MonthlyData as (
    select 
        format(InvoiceDate, 'yyyy-MM') AS Month,
        datepart(YEAR, InvoiceDate) AS Year,
        datepart(MONTH, InvoiceDate) AS MonthNum,
        Total
    from Invoice
)
select distinct Month,
    sum(Total) over (partition by Year, MonthNum) as Monthly_revenue,
    sum(Total) over (order by Year, MonthNum) as Running_Total
from MonthlyData
order by Month;

/***********************************************************
12. Day of the Week with the Most Sales
************************************************************/
select datename(WEEKDAY, InvoiceDate) AS DayOfWeek, SUM(Total) AS TotalSales
from Invoice
group by datename(WEEKDAY, InvoiceDate)
order by TotalSales DESC;

/***********************************************************
13. Tracks with Missing Prices
************************************************************/
select * from Track where UnitPrice IS NULL;

/************************************************************/
