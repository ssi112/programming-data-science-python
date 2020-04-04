
/* ---------------------------------------------------------------------
   p1_quiz.sql

   Project 1 Investigate a Relational Database
   Quiz Practice
 ---------------------------------------------------------------------*/

-- set the schema so we don't have to prepend it to table names
SET schema 'sakila';

/* ---------------------------------------------------------------------
creating a table that provides the following details:
actor's first and last name combined as full_name,
film title, film description and length of the movie

query result: 5462 rows
*/
SELECT a.first_name || ' ' || a.last_name AS full_name,
       f.title, f.description, f.length
FROM sakila.actor a
JOIN sakila.film_actor fa
ON a.actor_id = fa.actor_id
JOIN sakila.film f
ON f.film_id = fa.film_id;


/* ---------------------------------------------------------------------
Write a query that creates a list of actors and movies where
the movie length was more than 60 minutes.

query result: 4900 rows
*/
SELECT a.first_name || ' ' || a.last_name AS full_name,
       f.title, f.description, f.length
FROM sakila.actor a
JOIN sakila.film_actor fa
ON a.actor_id = fa.actor_id
JOIN sakila.film f
ON f.film_id = fa.film_id
WHERE f.length > 60;


/* ---------------------------------------------------------------------
Write a query that captures the actor id, full name of the actor,
and counts the number of movies each actor has made.
(HINT: Think about whether you should group by actor id or the
full name of the actor.)

Identify the actor who has made the maximum number movies.
*/
SELECT a.actor_id,
       a.first_name || ' ' || a.last_name AS full_name,
       COUNT(f.film_id)
FROM sakila.actor a
JOIN sakila.film_actor fa
ON a.actor_id = fa.actor_id
JOIN sakila.film f
ON f.film_id = fa.film_id
GROUP BY 1, 2
ORDER BY 3 DESC;


/* ---------------------------------------------------------------------
Write a query that displays a table with 4 columns:
   actor's full name, film title, length of movie,
   and a column name "filmlen_groups" that classifies
   movies based on their length.

Filmlen_groups should include 4 categories:
   1 hour or less, Between 1-2 hours, Between 2-3 hours, More than 3 hours
*/
SELECT a.first_name || ' ' || a.last_name AS full_name,
       f.title, f.length,
       CASE
       WHEN f.length <= 60 THEN
          'Cat 1: 1 hour or less'
       WHEN f.length <= 120 THEN
          'CAT 2: Between 1-2 hours'
       WHEN f.length <= 180 THEN
          'CAT 3: Between 2-3 hours'
       ELSE
          'CAT 4: More than 3 hours'
       END AS  filmlen_groups
FROM actor a
JOIN film_actor fa
ON a.actor_id = fa.actor_id
JOIN film f
ON f.film_id = fa.film_id
ORDER BY 2;


/* ---------------------------------------------------------------------
 Revise the query you wrote above to create a count of movies in each
 of the 4 filmlen_groups
*/
WITH filmlen_groups AS (
SELECT f.length,
       CASE WHEN f.length <= 60 THEN 1 ELSE 0 END AS cat1,
       CASE WHEN f.length BETWEEN 61 AND 120 THEN 1 ELSE 0 END AS cat2,
       CASE WHEN f.length BETWEEN 121 AND 180 THEN 1 ELSE 0 END AS cat3,
       CASE WHEN f.length > 180 THEN 1 ELSE 0 END AS cat4
FROM film f
)
SELECT COUNT(cat1) AS cnt_cat, 'Cat 1: 1 hour or less'
FROM filmlen_groups
GROUP BY cat1
HAVING cat1 > 0
    UNION
SELECT COUNT(cat2) AS cnt_cat, 'CAT 2: Between 1-2 hours'
FROM filmlen_groups
GROUP BY cat2
HAVING cat2 > 0
    UNION
SELECT COUNT(cat3) AS cnt_cat, 'CAT 3: Between 2-3 hours'
FROM filmlen_groups
GROUP BY cat3
HAVING cat3 > 0
    UNION
SELECT COUNT(cat4) AS cnt_cat, 'CAT 4: More than 3 hours'
FROM filmlen_groups
GROUP BY cat4
HAVING cat4 > 0;

-- ALTERNATIVE
SELECT DISTINCT(filmlen_groups),
       COUNT(title) OVER (PARTITION BY filmlen_groups)
       AS filmcount_bylencat
FROM
    (SELECT title, length,
            CASE
              WHEN length <= 60 THEN '1 hour or less'
              WHEN length > 60 AND length <= 120 THEN 'Between 1-2 hours'
              WHEN length > 120 AND length <= 180 THEN 'Between 2-3 hours'
              ELSE 'More than 3 hours'
            END AS filmlen_groups
     FROM film ) t1
ORDER BY  filmlen_groups

