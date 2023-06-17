USE superstore_db;

SELECT * FROM superstore;


-- Q1) What percentage of total orders were shipped on the same date?


SELECT
    ROUND((COUNT(DISTINCT Order_ID) / (SELECT COUNT(DISTINCT Order_ID) AS total_orders FROM superstore)) * 100, 2) AS Same_Day_Shipping_Percentage
FROM
    superstore
WHERE
    Order_Date = Ship_Date;


-- Q2) Name top 3 customers with highest total value of orders?


SELECT
    Customer_Name,
    ROUND(SUM(sales), 3) AS TotalOrderValue
FROM
    superstore
GROUP BY
    Customer_Name
ORDER BY
    SUM(sales) DESC
LIMIT 3;


-- Q3) Find the top 5 items with the highest average sales per day?


SELECT
    Product_ID,
    ROUND(AVG(sales), 3) AS Average_Sales
FROM
    superstore
GROUP BY
    Product_ID
ORDER BY
    Average_Sales DESC
LIMIT 5;


-- Q4) Write a query to find the average order value for each customer, and rank the customers by their average order value? 


 SELECT
    Customer_Name,
    ROUND(AVG(sales), 3) AS avg_order_value,
    DENSE_RANK() OVER (ORDER BY AVG(sales) DESC) AS sales_rank
FROM
    superstore
GROUP BY
    Customer_Name;


-- Q5) Give the name of customers who ordered highest and lowest orders from each city?


 WITH cte AS (
    SELECT
        City,
        ROUND(MAX(sales), 4) AS highest_order,
        ROUND(MIN(sales), 4) AS lowest_order
    FROM
        superstore
    GROUP BY
        City
),
highest_orders AS (
    SELECT
        s.City,
        cte.highest_order,
        cte.lowest_order,
        s.Customer_Name
    FROM
        superstore s
    INNER JOIN
        cte ON s.City = cte.City
    WHERE
        s.Sales = cte.highest_order
),
lowest_orders AS (
    SELECT
        s.City,
        cte.highest_order,
        cte.lowest_order,
        s.Customer_Name
    FROM
        superstore s
    INNER JOIN
        cte ON s.City = cte.City
    WHERE
        s.Sales = cte.lowest_order
)
SELECT
    h.City,
    h.highest_order,
    h.Customer_Name AS highest_order_customer,
    l.lowest_order,
    l.Customer_Name AS lowest_order_customer
FROM
    highest_orders h
INNER JOIN
    lowest_orders l ON h.City = l.City
ORDER BY
    h.City;


-- Q6) What is the most demanded sub-category in the west region?


SELECT
    Sub_Category,
    ROUND(SUM(sales), 3) AS total_quantity
FROM
    superstore
WHERE
    Region = 'West'
GROUP BY
    Sub_Category
ORDER BY
    total_quantity DESC
LIMIT 1;


-- Q7) Which order has the highest number of items? 


SELECT
    order_id,
    COUNT(order_id) AS num_item
FROM
    superstore
GROUP BY
    order_id
ORDER BY
    num_item DESC
LIMIT 1;


-- Q8) Which order has the highest cumulative value?


SELECT
    order_id,
    ROUND(SUM(sales), 3) AS order_value
FROM
    superstore
GROUP BY
    order_id
ORDER BY
    order_value DESC
LIMIT 1;


-- Q9) Which segment’s order is more likely to be shipped via first class?


SELECT
    segment,
    COUNT(order_id) AS num_of_ordr
FROM
    superstore
WHERE
    ship_mode = 'First Class'
GROUP BY
    segment
ORDER BY
    num_of_ordr DESC;


-- Q10) Which city is least contributing to total revenue?


SELECT
    city,
    ROUND(SUM(sales), 3) AS TotalSales
FROM
    superstore
GROUP BY
    city
ORDER BY
    TotalSales ASC
LIMIT 1;


-- Q11) What is the average time for orders to get shipped after order is placed?


SELECT
    AVG(DATEDIFF(ship_date, order_date)) AS avg_ship_time
FROM
    superstore;


/* Q12) Which segment places the highest number of orders from each state 
		and which segment places the largest individual orders from each state? */

        
WITH cte AS (
    SELECT
        state,
        segment,
        COUNT(order_id) AS num_orders,
        RANK() OVER (PARTITION BY state ORDER BY COUNT(order_id) DESC) AS state_rank
    FROM
        superstore
    GROUP BY
        state,
        segment
)
SELECT
    state,
    segment
FROM
    cte
WHERE
    state_rank = 1;



/* Q13) Find all the customers who individually ordered on 3 consecutive days 
		where each day’s total order was more than 50 in value?*/


WITH cte AS (
    SELECT
        Customer_ID,
        Customer_Name,
        Order_ID,
        Order_Date,
        ROUND(SUM(sales), 3) AS order_value,
        DATEDIFF(Order_Date, LAG(Order_Date) OVER (PARTITION BY Customer_ID ORDER BY Order_Date ASC)) AS date_diff
    FROM
        superstore
    GROUP BY
        Customer_ID,
        Customer_Name,
        Order_ID,
        Order_Date
    HAVING
        SUM(sales) > 50
)
SELECT
    Customer_ID,
    Customer_Name
FROM
    cte
WHERE
    date_diff = 1;


-- Q14) Find the maximum number of days for which total sales on each day kept rising?


 WITH sales_sequence AS (
    SELECT
        Order_Date,
        SUM(Sales) AS TotalSales,
        ROW_NUMBER() OVER (ORDER BY Order_Date) AS rn
    FROM
        superstore
    GROUP BY
        Order_Date
),
rising_days AS (
    SELECT
        s1.Order_Date,
        COUNT(*) AS rising_day_count
    FROM
        sales_sequence s1
    INNER JOIN
        sales_sequence s2 ON s1.TotalSales < s2.TotalSales AND s1.rn < s2.rn
    GROUP BY
        s1.Order_Date
)
SELECT
    MAX(rising_day_count) AS max_rising_days
FROM
    rising_days;
