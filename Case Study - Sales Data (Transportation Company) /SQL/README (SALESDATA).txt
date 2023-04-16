1. Started by inspecting the data in the SalesData table.

2. Checked for unique values in the status, year_id, PRODUCTLINE, COUNTRY, DEALSIZE, and MONTH_ID columns using the SELECT DISTINCT statement.

3. Performed some analysis by grouping the sales by product line using the GROUP BY statement and calculating the sum of sales for each product line using the SUM function. You ordered the results in descending order using the ORDER BY statement.

4. Grouped the sales by year and calculated the sum of sales for each year using the GROUP BY statement. You ordered the results in descending order using the ORDER BY statement.

5. Grouped the sales by deal size and calculated the sum of sales for each deal size using the GROUP BY statement. You ordered the results in descending order using the ORDER BY statement.

6. Looked for the best month for sales in a specific year and how much was earned that month using the WHERE clause to filter the data for a specific year, then grouped the sales by month and calculated the sum of sales and the frequency of orders for each month using the GROUP BY statement. You ordered the results in descending order using the ORDER BY statement.

7. Looked for information on what product was sold the most in the best sales month (November in this case) using the WHERE clause to filter the data for November of a specific year, then grouped the sales by month and product line and calculated the sum of sales and the frequency of orders for each month and product line using the GROUP BY statement. You ordered the results in descending order using the ORDER BY statement.

8. Used RFM analysis to find the best customer. You first created a Common Table Expression (CTE) to calculate the recency, frequency, and monetary value for each customer. Then you used another CTE to calculate the RFM scores for each customer. Finally, you used a CASE statement to segment the customers based on their RFM scores.

9. Found the city with the highest number of sales in a specific country using the WHERE clause to filter the data for a specific country, then grouped the sales by city and calculated the sum of sales for each city using the GROUP BY statement. You ordered the results in descending order using the ORDER BY statement.

10. Found the best selling product in the United States by filtering the data for the USA, then grouped the sales by country, year, and product line and calculated the sum of sales for each country, year, and product line using the GROUP BY statement. 

11. Ordered the results in descending order using the ORDER BY statement.
