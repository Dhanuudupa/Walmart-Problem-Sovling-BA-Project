create database walmart_db;
use walmart_db;
select count(*) from walmart;
select * from walmart; 

-- 1. What are the different payment methods, and how many transactions and items were sold with each method?

select payment_method ,sum(quantity) as goods_sold ,count(*) as Transactions from walmart
group by payment_method
order by payment_method desc;

select count(distinct branch) Unique_brnach from walmart;

-- 2. Which category received the highest average rating in each branch?

select * from
(
select distinct branch, category,avg(rating) as rating,
rank() over(partition by branch order by avg(rating) desc) as ranks
 from walmart
group by branch,category
) w1
where ranks =1 ;



-- 3 : What is the busiest day of the week for each branch based on transaction volume?

 
 SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranks
    FROM walmart
    GROUP BY branch, day_name
) AS ranked
WHERE ranks = 1;




-- 4 How many items were sold through each payment method?


select payment_method,sum(quantity) from walmart
group by payment_method
order by payment_method desc;

-- 5 : What are the average, minimum, and maximum ratings for each category in each city?
select city,category,
max(rating) as Max_rating,
avg(rating) as Avg_rating,
min(rating) as Min_rating
from walmart
group by 1,2;


-- 6 What is the total profit for each category, ranked from highest to lowest?

select category ,sum(total), sum(total * profit_margin) as Profit from walmart 
group by 1
order by 1 desc;

-- 7 : What is the most frequently used payment method in each branch?

with cte as
(
select branch, payment_method,count(*) as total_transaction,
rank() over(partition by branch order by count(payment_method)desc ) as rnk
from walmart
group by 1,2
) 
select * from cte
where rnk = 1;

-- 8 How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- 9 Which branches experienced the largest decrease in revenue compared to the previous year?


WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS year_2022_revenue,
    r2023.revenue AS year_2023_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;






