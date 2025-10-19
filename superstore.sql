SELECT * FROM superstore_sales
LIMIT 15;


SELECT * FROM superstore_sales LIMIT 5;
SELECT "Order ID", COUNT(*) as Dup_count FROM superstore_sales
GROUP BY "Order ID"
HAVING COUNT(*) > 1;

SELECT
SUM(CASE WHEN "Order Date" IS NULL OR TRIM("Order Date")=' ' THEN 1 ELSE 0 END) AS MISSING_ORDER_DATE,
SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS MISSING_SALES,
SUM(CASE WHEN Region IS NULL OR TRIM('Region')=' ' THEN 1 ELSE 0 END) AS MISSING_REGION FROM superstore_sales;

SELECT DISTINCT Region FROM superstore_sales ORDER BY Region;
SELECT DISTINCT Category FROM superstore_sales ORDER BY Category;
SELECT DISTINCT Segment FROM superstore_sales ORDER BY Segment;
SELECT DISTINCT "Ship Mode" FROM superstore_sales ORDER BY "Ship Mode";


DROP VIEW IF EXISTS superstore_sales_enriched;
CREATE VIEW superstore_sales_enriched AS 
SELECT s.*,
--if the date is YY-MM-DD,then use the formula mentioned below.
--strftime('%Y-%m',"Order Date") AS Month

--if the date is MM-DD-YY,
printf(
    '%04d-%02d',
    CAST(substr("Order Date",length("Order Date")-3,4)AS INT),
    CAST(substr("Order Date",1,instr("Order Date",'/')-1)AS INT)
   ) AS Month
FROM superstore_sales s;




--TOTAL SALES BY REGION
SELECT Region,ROUND(SUM(Sales),2) AS Total_sales
FROM superstore_sales
GROUP BY Region
ORDER BY Total_sales DESC;

--Top 10 customer for sales
SELECT "Customer Name" AS Customer,
ROUND(SUM(Sales),2) AS Total_sales
FROM superstore_sales
GROUP BY "Customer Name"
ORDER BY Total_sales DESC
LIMIT 10;

--Top product category by sales
SELECT Category,
ROUND(SUM(Sales),2) AS Total_sales
From superstore_sales
GROUP BY Category
ORDER BY Total_sales DESC 
LIMIT 1;


--Monthly Sales
SELECT Month,
ROUND(SUM(Sales),2) AS Monthly_sales
FROM superstore_sales_enriched
GROUP BY Month
ORDER BY Month;


--Sales by Region
WITH sales_by_region AS(
SELECT Region,SUM(Sales) AS Total_sales
FROM superstore_sales
GROUP BY Region
),
avg_sales AS(
SELECT Region,AVG(Total_sales) AS avg_sales_region
FROM sales_by_region
)

SELECT
r.Region,
r.Total_sales,
CASE WHEN r.Total_sales >= a.avg_sales_region THEN 'High Performer'
ELSE 'Needs Attention'
END AS Region_Status
FROM sales_by_region r
CROSS JOIN avg_sales a
ORDER BY Total_sales DESC;



--Top product by sales
SELECT
"Product Name",
Category,
"Sub-Category",
ROUND(SUM(Sales),2) AS Sales
FROM superstore_sales
GROUP BY "Product Name",Category,"Sub-Category"
ORDER BY Sales DESC
LIMIT 15;

--Top sub-category by sales
SELECT
"Sub-Category",
ROUND(SUM(Sales),2) AS Sales
FROM superstore_sales
GROUP BY "Sub-Category"
ORDER BY Sales DESC
LIMIT 15;

.headers on
.mode csv
.output "monthly_sales.csv"
SELECT Month,
ROUND(SUM(Sales),2) AS Monthly_sales
FROM superstore_sales_enriched
GROUP BY Month
ORDER BY Month;
.output stdout

SELECT * FROM superstore_sales_enriched;














