use sqlproject;
/* 1 update */

SELECT pt.name AS pizza_name,
 p.size,
 SUM(od.quantity * p.price) AS total_revenue
FROM orderdetails od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizzatypes pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name, p.size
ORDER BY total_revenue DESC
LIMIT 5;



/* 1 */
SELECT
    pt.name AS pizza_type,
    SUM(p.price) AS total_revenue
FROM
    pizzas p
JOIN
    pizzatypes pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY
    pt.name
ORDER BY
    total_revenue DESC
LIMIT 1;


    /* 2  updates */

SELECT
    AVG(orderdetails.quantity) AS average_quantity_ordered,
    AVG(orderdetails.quantity * pizzas.price) AS average_sales_value
FROM
    orders
JOIN
    orderdetails ON orders.order_id = orderdetails.order_id
JOIN
    pizzas ON orderdetails.pizza_id = pizzas.pizza_id
WHERE
    TIME(time) BETWEEN '18:00:00' AND '21:00:00';


    /* 3  updates */


SELECT pt.name AS pizza_type,
       SUM(od.quantity) AS total_ordered
FROM orders o
JOIN orderdetails od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizzatypes pt ON p.pizza_type_id = pt.pizza_type_id
WHERE TIME(o.time) BETWEEN '00:00:00' AND '11:59:59' -- Morning time frame (adjust as needed)
GROUP BY pt.name
ORDER BY total_ordered DESC
LIMIT 3;

/* 4  updates */
SELECT
    pt.name AS pizza_name,
    p.size AS pizza_size,
    COUNT(*) AS order_count
FROM
    orderdetails od
JOIN
    pizzas p ON od.pizza_id = p.pizza_id
JOIN
    pizzatypes pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY
     p.size
ORDER BY
    order_count DESC
LIMIT 1;



/* 6  updates */

SELECT
    pt.name AS pizza_name,
    pt.category AS pizza_category,
    p.size AS pizza_size,
    AVG(p.price) AS average_price,
    SUM(od.quantity) AS total_sales_volume
FROM
    pizzas p
JOIN
    pizzatypes pt ON p.pizza_type_id = pt.pizza_type_id
JOIN
    orderdetails od ON p.pizza_id = od.pizza_id
GROUP BY
    pt.name, pt.category, p.size
ORDER BY
    pt.category, p.size;



/* 7 */

SELECT
    pt.category,
    SUM(p.price * od.quantity) AS total_sales
FROM
    orders o
JOIN
    orderdetails od ON o.order_id = od.order_id
JOIN
    pizzas p ON od.pizza_id = p.pizza_id
JOIN
    pizzatypes pt ON p.pizza_type_id = pt.pizza_type_id
WHERE
    TIME(o.time) BETWEEN '12:00:00' AND '14:00:00' -- Assuming lunch hours are between 12 PM and 2 PM
GROUP BY
    pt.category
ORDER BY
    total_sales DESC;


/* 8 */

SELECT
    p.size,
    SUM(CASE WHEN pt.category = 'Veggie' THEN p.price * od.quantity ELSE 0 END) AS veggie_sales,
    SUM(CASE WHEN pt.category != 'Veggie' THEN p.price * od.quantity ELSE 0 END) AS non_veggie_sales,
    (SUM(CASE WHEN pt.category = 'Veggie' THEN p.price * od.quantity ELSE 0 END) / SUM(p.price * od.quantity)) * 100 AS veggie_percentage,
    (SUM(CASE WHEN pt.category != 'Veggie' THEN p.price * od.quantity ELSE 0 END) / SUM(p.price * od.quantity)) * 100 AS non_veggie_percentage
FROM
    orders o
JOIN
    orderdetails od ON o.order_id = od.order_id
JOIN
    pizzas p ON od.pizza_id = p.pizza_id
JOIN
    pizzatypes pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY
    p.size
ORDER BY
    p.size;
    
    
    /* 9 */
    
    SELECT
    DATE_FORMAT(o.date, '%Y-%m') AS month,
    SUM(p.price * od.quantity) AS total_sales
FROM
    orders o
JOIN
    orderdetails od ON o.order_id = od.order_id
JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY
    month
ORDER BY
    month;




  /* 10 */
  
SELECT
    pt.name AS pizza_flavor,
    SUM(od.quantity) AS total_quantity_sold
FROM
    orderdetails od
JOIN
    pizzas p ON od.pizza_id = p.pizza_id
JOIN
    pizzatypes pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY
    pt.name
ORDER BY
    total_quantity_sold DESC
LIMIT 1;

  /* 11 */

WITH HighestSelling AS (
    SELECT
        pt.name AS highest_selling_pizza,
        p.price AS highest_selling_price,
        pt.ingredients AS highest_selling_ingredients
    FROM
        orderdetails od
    JOIN
        pizzas p ON od.pizza_id = p.pizza_id
    JOIN
        pizzatypes pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY
        pt.name
    ORDER BY
        SUM(od.quantity) DESC
    LIMIT 1
),

LowestSelling AS (
    SELECT
        pt.name AS lowest_selling_pizza,
        p.price AS lowest_selling_price,
        pt.ingredients AS lowest_selling_ingredients
    FROM
        orderdetails od
    JOIN
        pizzas p ON od.pizza_id = p.pizza_id
    JOIN
        pizzatypes pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY
        pt.name
    ORDER BY
        SUM(od.quantity) ASC
    LIMIT 1
)

SELECT
    H.highest_selling_pizza,
    H.highest_selling_price,
    H.highest_selling_ingredients,
    L.lowest_selling_pizza,
    L.lowest_selling_price,
    L.lowest_selling_ingredients
FROM
    HighestSelling H
CROSS JOIN
    LowestSelling L;
    
    


/* 5 */



WITH MonthlyOrderCounts AS (
    SELECT
        p.pizza_type_id,
        pt.name AS pizza_name, -- Using pizzatypes table to get pizza names
        DATE_FORMAT(o.date, '%Y-%m-%d') AS order_month,
        SUM(od.quantity) AS total_quantity
    FROM
        pizzatypes pt
    JOIN
        pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN
        orderdetails od ON p.pizza_id = od.pizza_id
    JOIN
        orders o ON od.order_id = o.order_id
    WHERE
        o.date >= DATE_SUB("2015-12-01", INTERVAL  12 month) -- Data for the past quarter
    GROUP BY
        p.pizza_type_id, pt.name, order_month
),
AverageMonthlyOrderCounts AS (
    SELECT
        pizza_type_id,
        pizza_name,
        order_month,
        AVG(total_quantity) AS avg_quantity
       
    FROM
        MonthlyOrderCounts
    GROUP BY
        pizza_type_id, pizza_name
)
SELECT
    pizza_type_id,
    pizza_name,
    order_month,
	avg_quantity
FROM
    AverageMonthlyOrderCounts
ORDER BY
    avg_quantity DESC;





/* new */
SELECT
        pt.name AS pizza_name,
       p.size AS pizza_size,
    EXTRACT(MONTH FROM o.date) AS month,
    SUM(od.quantity * p.price) AS total_revenue

FROM
    orders o
JOIN
    orderdetails od ON o.order_id = od.order_id
JOIN
    pizzas p ON od.pizza_id = p.pizza_id
JOIN
    pizzatypes pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY
    EXTRACT(MONTH FROM o.date),
        pt.name,
        p.size
ORDER BY
    month, pizza_name, pizza_size;





