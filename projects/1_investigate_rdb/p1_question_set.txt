/* ---------------------------------------------------------------------
   p1_qset1.sql

   Question set #1
   Set of questions to include in project submission
 ---------------------------------------------------------------------*/

SET SCHEMA 'sakila';

/* ---------------------------------------------------------------------
Set 1 - Question 1
The following categories are considered family movies:
Animation, Children, Classics, Comedy, Family and Music.

Create a query that lists each film category and the number of rentals
*/
SELECT c.name AS film_category_name,
       COUNT(r.rental_date) AS number_of_rentals
FROM category c
JOIN film_category fc
  ON c.category_id = fc.category_id
JOIN film f
  ON fc.film_id = f.film_id
JOIN inventory i
  ON f.film_id = i.film_id
JOIN rental r
  ON i.inventory_id = r.inventory_id
WHERE lower(c.name) IN
      ('animation', 'children', 'classics', 'comedy', 'family', 'music')
GROUP BY 1
ORDER BY 2;


/* ---------------------------------------------------------------------
Set 1 - Question 2

What is the rental duration of family friendly film categories ranked
within quartiles to the set of all family friendly durations

***** Notes on NTILE(4) *****
NTILE distributes rows of an ordered partition into a specified number
of approximately equal groups, or buckets.

*/
-- all film titles grouped into 2 categories
-- 1000 rows returned
WITH film_groups AS
(
SELECT f.title, c.name,
       CASE
       WHEN LOWER(c.name) IN
      ('animation', 'children', 'classics', 'comedy', 'family', 'music')
       THEN 'Family Friendly'
       ELSE
          'All Other Categories'
       END AS  film_cat,
       f.rental_duration
FROM category c
JOIN film_category fc
  ON c.category_id = fc.category_id
JOIN film f
  ON fc.film_id = f.film_id
--WHERE f.film_id IN (214, 363, 753, 916, 953)
)
SELECT film_cat AS film_group, g.name AS film_category, rental_duration,
       --PERCENT_RANK() OVER (ORDER BY rental_duration) AS percentile_rank
       NTILE(4) OVER (ORDER BY rental_duration) AS quartile
FROM film_groups g
WHERE film_cat = 'Family Friendly'
GROUP BY 1, 2, 3
ORDER BY 2,3;


/* ---------------------------------------------------------------------
   Question set #2
   Set of questions to include in project submission
 ---------------------------------------------------------------------*/

/* ---------------------------------------------------------------------
Set 2 - Question 1
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
),
year_mth_data AS
(
SELECT return_month, return_year, store_id,
       return_year || ' ' ||
       TO_CHAR(TO_TIMESTAMP(TO_CHAR(return_month, '999'), 'MM'), 'Mon') AS year_month,
       COUNT(return_date) AS cnt_ret_date
FROM rental_data
GROUP BY 1, 2, 3, 4
ORDER BY 3, 2, 1
)
SELECT store_id, year_month, cnt_ret_date
FROM year_mth_data;


/* ---------------------------------------------------------------------
Set 2 - Question 4c
Additional Questions

4c) Who are the top 10 customers being the most delinquent
    returning movies?

Include the following columns:
  customer last name,
  customer first name,
  number of times returned rental late - ranked descending
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
                     WHEN rental_duration < days_out THEN 1
                   ELSE 0
                   END AS returned_late
            FROM film f
            JOIN inventory i
              ON f.film_id = i.film_id
            JOIN t1
              ON i.inventory_id = t1.inventory_id
)
SELECT last_name, first_name, first_name || ' ' || last_name AS full_name,
       --return_status,
       COUNT(*) AS number_times_late
FROM t2
WHERE returned_late != 0
GROUP BY 1, 2, 3
ORDER BY 4 DESC, 1, 2
LIMIT 10;
