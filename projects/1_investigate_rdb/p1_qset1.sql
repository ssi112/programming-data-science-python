/* ---------------------------------------------------------------------
   p1_qset1.sql

   Question set #1
   Set of questions to include in project submission
 ---------------------------------------------------------------------*/

SET SCHEMA 'sakila';

/* ---------------------------------------------------------------------
Question 1
The following categories are considered family movies:
Animation, Children, Classics, Comedy, Family and Music.

Create a query that lists each movie, the film category it is classified
in, and the number of times it has been rented out.
*/
SELECT f.title,
       c.name,
       COUNT(r.rental_date)
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
GROUP BY 1,2
ORDER BY 1;


/* ---------------------------------------------------------------------
Question 2
Now we need to know how the length of rental duration of these
family-friendly movies compares to the duration that all movies are
rented for.

Provide a result with the movie titles and divide them into 4 levels
(first_quarter, second_quarter, third_quarter, and final_quarter)
based on the quartiles (25%, 50%, 75%) of the rental duration for
movies across all categories?

Make sure to also indicate the category that these family-friendly
movies fall into.

***** Notes on NTILE(4) *****
The results show some movies with a duration of 4 in quartile 2,
some in 1. Some movies with a duration of 5 end up in quartile 2 while
some are in quartile 3. Same thing happens with duration of 6 - some
are in 3 and some are in 4.

NTILE distributes rows of an ordered partition into a specified number
of approximately equal groups, or buckets.

Rental duration ranges from 1 to 7, so the function does not specify
that particular durations must fall in the same quartile.

Instead using PERCENT_RANK() to calculate the relative rank of the
duration within the set of all durations.
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
SELECT title, g.name, film_cat, rental_duration,
       PERCENT_RANK() OVER (ORDER BY rental_duration) AS percentile_rank
       -- NTILE(4) OVER (ORDER BY rental_duration) AS quartile
FROM film_groups g
ORDER BY 4, 2;

/* =====================================================================
   Additional query provided by mentor Bravo A.

   PRECENTILE_CONT
   Ref: https://www.postgresql.org/docs/current/functions-aggregate.html
   =====================================================================
*/
WITH rdur_pctiles AS (
  SELECT
    PERCENTILE_CONT(.25) WITHIN GROUP(ORDER BY rental_duration)
        AS rdur_25pct,
    PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY   rental_duration)
        AS rdur_50pct,
    PERCENTILE_CONT(.75) WITHIN GROUP(ORDER BY rental_duration)
        AS rdur_75pct
  FROM film
),
approved_category AS (
   SELECT c.name
  FROM category AS c
  WHERE name IN ('Animation','Children','Classics','Comedy','Family','Music')
)
SELECT f.title AS film_title,c.name AS categ_name, rental_duration,
      CASE
        WHEN rental_duration <= (SELECT rdur_pctiles.rdur_25pct FROM rdur_pctiles)
          THEN 'Short'
        WHEN rental_duration >= (SELECT rdur_pctiles.rdur_50pct FROM rdur_pctiles) AND
rental_duration < (SELECT rdur_pctiles.rdur_75pct FROM rdur_pctiles)
          THEN 'Medium'
        WHEN rental_duration >= (SELECT rdur_pctiles.rdur_75pct FROM rdur_pctiles)
          THEN 'Long' END AS rental_length
FROM film AS f
JOIN film_category AS fc
  ON f.film_id = fc.film_id
JOIN category AS c
  ON c.category_id = fc.category_id
WHERE c.name IN (SELECT name FROM approved_category)
ORDER BY rental_duration
/* ================================================================== */


/* ---------------------------------------------------------------------
Question 3
Provide a table with the family-friendly film category, each of the
quartiles, and the corresponding count of movies within each combination
of film category for each corresponding rental duration category.

The resulting table should have three columns:
    Category
    Rental length category
    Count
*/
WITH film_quart AS
(SELECT f.title, c.name , f.rental_duration,
        NTILE(4) OVER (ORDER BY f.rental_duration) AS quartiles
 FROM film_category fc
 JOIN category c
 ON c.category_id = fc.category_id
 JOIN film f
 ON f.film_id = fc.film_id
 WHERE LOWER(c.name) IN
      ('animation', 'children', 'classics', 'comedy', 'family', 'music')
)
SELECT name, quartiles, COUNT(quartiles)
FROM film_quart
GROUP BY 1, 2
ORDER BY 1, 2

