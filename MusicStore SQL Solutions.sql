
/* Query 1 Most Popular Music Genres (by Percentage of Sales) */
WITH RankedGenres AS (
    SELECT Genre.Name AS MusicGenre,
           SUM(InvoiceLine.Quantity) AS TotalPurchase,
           RANK() OVER (ORDER BY SUM(InvoiceLine.Quantity) DESC) AS OverallRank
    FROM Customer
    JOIN Invoice ON Customer.CustomerID = Invoice.CustomerID
    JOIN InvoiceLine ON Invoice.InvoiceID = InvoiceLine.InvoiceID
    JOIN Track ON InvoiceLine.TrackID = Track.TrackID
    JOIN Genre ON Track.GenreID = Genre.GenreID
    GROUP BY Genre.Name
),

TotalPurchases AS (
    SELECT SUM(TotalPurchase) AS OverallPurchases
    FROM RankedGenres
)

SELECT OverallRank,
	     MusicGenre,
       ROUND(TotalPurchase * 100.0 / TotalPurchases.OverallPurchases, 2) AS PercentageOfSale
FROM RankedGenres
CROSS JOIN TotalPurchases
WHERE OverallRank <= 10
ORDER BY PercentageOfSale DESC;


/* Query 2 Top 10 Spending By Country*/
WITH CountryStats AS (
    SELECT c.Country,
           COUNT(DISTINCT i.InvoiceId) AS TotalOrders,
           SUM(i.Total) AS TotalSales,
           RANK() OVER (ORDER BY SUM(i.Total) DESC) AS SalesRank
    FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.Country
)

SELECT Country, TotalOrders, TotalSales
FROM CountryStats
WHERE SalesRank <= 10
ORDER BY SalesRank;


/* Query 3 Top Highest Earnings Artists */
WITH RankedArtists AS (
    SELECT a.Name AS ArtistName,
           SUM(il.UnitPrice) AS TotalEarned,
           ROW_NUMBER() OVER (ORDER BY SUM(il.UnitPrice) DESC) AS OverallRank
    FROM Artist a
    JOIN Album al ON a.ArtistId = al.ArtistId
    JOIN Track t ON al.AlbumId = t.AlbumId
    JOIN InvoiceLine il ON t.TrackId = il.TrackId
    GROUP BY a.Name
)
SELECT ArtistName, TotalEarned, OverallRank
FROM RankedArtists
WHERE OverallRank <= 10
ORDER BY TotalEarned DESC;


/* Query 4 Top Sales Performance */
WITH EmployeeSales AS (
    SELECT e.EmployeeId,
           e.FirstName || ' ' || e.LastName AS EmployeeName,
           COUNT(DISTINCT i.InvoiceId) AS TotalOrders,
           SUM(i.Total) AS TotalSales
    FROM Employee e
    JOIN Customer c ON e.EmployeeId = c.SupportRepId
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY e.EmployeeId, EmployeeName
)

SELECT es.EmployeeId, 
       es.EmployeeName, 
       es.TotalOrders,
       es.TotalSales,
       AVG(es.TotalSales) OVER () AS AverageTotalSales,
       AVG(es.TotalOrders) OVER () AS AverageTotalOrders
FROM EmployeeSales es
ORDER BY es.TotalSales DESC;
