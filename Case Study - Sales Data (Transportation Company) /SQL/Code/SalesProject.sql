-- Inspecting Data 

SELECT *
FROM SalesData sd 

-- Checking for unique values 

SELECT DISTINCT status FROM SalesData sd 

SELECT DISTINCT year_id FROM SalesData sd 

SELECT DISTINCT PRODUCTLINE FROM SalesData sd 

SELECT DISTINCT COUNTRY FROM SalesData sd 

SELECT DISTINCT DEALSIZE FROM SalesData sd 

SELECT DISTINCT TERRITORY FROM SalesData sd 

SELECT DISTINCT MONTH_ID 
FROM SalesData sd 
WHERE YEAR_ID = 2005

-- Analysis - Grouping by sales by productline 

SELECT PRODUCTLINE, SUM(sales) AS Revenue 
FROM SalesData 
GROUP BY PRODUCTLINE 
ORDER BY 2 DESC

SELECT YEAR_ID, SUM(SALES) AS Revenue 
FROM SalesData sd 
GROUP BY YEAR_ID 
ORDER BY 2 DESC 

SELECT DEALSIZE, SUM(SALES) AS Revenue 
FROM SalesData sd 
GROUP BY DEALSIZE 
ORDER BY 2 DESC

-- Looking for the best month for sales in specific year and how much was earned that month 

SELECT MONTH_ID, SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS Frequency 
FROM SalesData sd 
WHERE YEAR_ID = 2004 -- Change the year to see the rest. We can't use 2005 becuase in 2005 they operate just until may 
GROUP BY MONTH_ID 
ORDER BY 2 DESC

-- November looks like the most profitable month. So we are looking for information on what product do the sell in November

SELECT MONTH_ID, PRODUCTLINE, SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS Frequency 
FROM SalesData sd 
WHERE YEAR_ID = 2004 AND MONTH_ID = 11 -- Change the year to see the rest. We can't use 2005 becuase in 2005 they operate just until may 
GROUP BY MONTH_ID, PRODUCTLINE 
ORDER BY 3 DESC



-- Who is the best customer. I will use RFM analysis for this part. (Recency-Frequency-Monetary)

WITH rfm AS (
  SELECT 
    CUSTOMERNAME, 
    SUM(sales) MonetaryValue,
    AVG(sales) AvgMonetaryValue,
    COUNT(DISTINCT ORDERNUMBER) Frequency,
    DATEDIFF(day, MAX(ORDERDATE), GETDATE()) Recency
  FROM SalesData
  GROUP BY CUSTOMERNAME
),
rfm_calc AS (
  SELECT 
    r.*, 
    NTILE(4) OVER (ORDER BY Recency DESC) rfm_recency,
    NTILE(4) OVER (ORDER BY Frequency) rfm_frequency,
    NTILE(4) OVER (ORDER BY MonetaryValue) rfm_monetary
  FROM rfm r
)
SELECT 
  CUSTOMERNAME,
  rfm_recency,
  rfm_frequency,
  rfm_monetary,
  CASE 
    WHEN rfm_recency <= 2 AND rfm_frequency <= 2 AND rfm_monetary <= 2 THEN 'lost_customers'
    WHEN rfm_recency >= 3 AND rfm_frequency <= 2 AND rfm_monetary >= 3 THEN 'slipping away, cannot lose'
    WHEN rfm_recency <= 2 AND rfm_frequency <= 2 AND rfm_monetary >= 3 THEN 'new customers'
    WHEN rfm_recency >= 3 AND rfm_frequency >= 3 AND rfm_monetary >= 3 THEN 'loyal'
    WHEN rfm_recency <= 2 AND rfm_frequency >= 3 AND rfm_monetary >= 3 THEN 'potential churners'
    ELSE 'active'
  END rfm_segment
FROM rfm_calc;


-- What city has the highest number of sales in a specific country

SELECT city, SUM(SALES) AS Revenue 
FROM SalesData
WHERE country = 'UK'
GROUP BY city
ORDER BY 2 DESC 

-- What is the best selling product in the United States? 

SELECT country, YEAR_ID, PRODUCTLINE, SUM(SALES) AS Revenue
FROM SalesData
WHERE country IN ('USA')
GROUP BY country, YEAR_ID, PRODUCTLINE
ORDER BY 4 DESC 



