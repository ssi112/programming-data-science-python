/* ---------------------------------------------------------------------
   p1_qset2.sql

   Question set #2
   Set of questions to include in project submission
 ---------------------------------------------------------------------*/

SET SCHEMA 'sakila';

/* ---------------------------------------------------------------------
Question 1
We want to find out how the two stores compare in their count of rental
orders during every month for all the years we have data for.

Write a query that returns the store ID for the store, the year and
month and the number of rental orders each store has fulfilled for
that month.

Include a column for each of the following:
    year
    month
    store ID
    count - rental orders fulfilled during the month
*/
WITH rental_data AS
(
---- 15861 rows
SELECT s.store_id,
       st.staff_id,
       r.rental_id, r.rental_date, r.return_date,
       DATE_PART('month', r.return_date) AS return_month,
       DATE_PART('year', r.return_date) AS return_year
FROM store s
JOIN staff st
  ON s.store_id = st.store_id
JOIN rental r
  ON st.staff_id = r.staff_id
WHERE r.return_date IS NOT NULL
)
SELECT return_month, return_year, store_id,
       COUNT(return_date)
FROM rental_data
GROUP BY 1, 2, 3
ORDER BY 3, 2, 1;


/* ---------------------------------------------------------------------
Additional Questions

4a) What is the average rental duration and rental rate for each
    film category?

Include the following columns:
    film category
    average rental duration
    average rental rate
*/
SELECT c.name as film_category,
       AVG(f.rental_rate) as avg_rental_rate,
       AVG(f.rental_duration) as avg_rental_duration
FROM category c
JOIN film_category fc
  ON c.category_id = fc.category_id
JOIN film f
  ON fc.film_id = f.film_id
GROUP BY 1
ORDER BY 3 DESC, 2 DESC, 1;


-- https://www.freecodecamp.org/news/project-1-analyzing-dvd-rentals-with-sql-fd12dd674a64/

/* ---------------------------------------------------------------------
Additional Questions

4b) How many films were returned on time and how many were late?

Include the following columns:

*/
WITH t1 AS (
            SELECT *,
                   DATE_PART('day', return_date - rental_date) AS days_out
                   FROM rental
),
     t2 AS (
            SELECT rental_duration, days_out,
                   CASE
                     WHEN rental_duration > days_out THEN 'returned early'
                     WHEN rental_duration = days_out THEN 'returned ontime'
                   ELSE 'returned late'
                   END AS return_status
            FROM film f
            JOIN inventory i
              ON f.film_id = i.film_id
            JOIN t1
              ON i.inventory_id = t1.inventory_id
)
SELECT return_status, COUNT(*) AS cnt_recs
FROM t2
GROUP BY 1
ORDER BY 2 DESC;


/* ---------------------------------------------------------------------
Additional Questions

4c) Which customers are the most delinquent returning movies?

Include the following columns:
  customer last name,
  customer first name,
  number of times returned rental late
*/
WITH t1 AS (
            SELECT rental_date, return_date, inventory_id,
                   DATE_PART('day', return_date - rental_date) AS days_out,
                   c.first_name, c.last_name
                   FROM rental r
                   JOIN customer c
                    ON r.customer_id = c.customer_id
                   WHERE r.return_date IS NOT NULL
),
     t2 AS (
            SELECT first_name, last_name,
                   rental_date, return_date, rental_duration, days_out,
                   CASE
                     --WHEN rental_duration > days_out THEN 'returned early'
                     --WHEN rental_duration = days_out THEN 'returned ontime'
                     WHEN rental_duration < days_out THEN 1
                   --ELSE 'returned late'
                   ELSE 0
                   END AS returned_late
            FROM film f
            JOIN inventory i
              ON f.film_id = i.film_id
            JOIN t1
              ON i.inventory_id = t1.inventory_id
)
SELECT last_name, first_name,
       --return_status,
       COUNT(*) AS number_times_late
FROM t2
WHERE returned_late != 0
GROUP BY 1, 2
ORDER BY 3 DESC, 1, 2;


/* ---------------------------------------------------------------------
  calculate the cumulative revenue of all stores
*/
SELECT payment_date, amount, sum(amount) OVER (ORDER BY payment_date)
FROM (
  SELECT CAST(payment_date AS DATE) AS payment_date, SUM(amount) AS amount
  FROM payment
  GROUP BY CAST(payment_date AS DATE)
) p
ORDER BY payment_date;
