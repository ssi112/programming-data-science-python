/* -----------------------------------------------------------------
   Advanced joins

   Full Outer Join - include unmatched rows from both tables
   To show only unmatched rows include this in query:

   WHERE Table_A.column_name IS NULL OR Table_B.column_name IS NULL

   full outer joins when attempting to find mismatched or
   orphaned data - exception reports or ETL

*/

-- none returned, all rows match
SELECT a.*,
       s.*
FROM accounts a
FULL OUTER JOIN sales_reps s
ON a.sales_rep_id = s.id
WHERE a.sales_rep_id IS NULL OR s.id IS NULL;


-- aggregate in WHERE must be contained in SELECT
SELECT o.id,
       o.occurred_at AS order_date,
       w.*
FROM parch_and_posey.orders o
LEFT JOIN parch_and_posey.web_events w
ON w.account_id = o.account_id
AND w.occurred_at = o.occurred_at
WHERE DATE_TRUNC('month', o.occurred_at) =
    (SELECT DATE_TRUNC('month', MIN(o1.occurred_at))
        FROM parch_and_posey.orders o1)
ORDER BY o.account_id, o.occurred_at;

/* -----------------------------------------------------------------
    Inequality joins
*/
SELECT a.name AS account_name,
       a.primary_poc,
       s.name AS sales_rep_name
FROM parch_and_posey.accounts a
LEFT JOIN parch_and_posey.sales_reps s
ON a.sales_rep_id = s.id
AND a.primary_poc < s.name
ORDER BY a.name;

/* -----------------------------------------------------------------
    Self joins - find two events occurring one after each other

    INTERVAL
    Ref: https://www.postgresqltutorial.com/postgresql-interval/
         https://www.postgresql.org/docs/9.1/functions-datetime.html

    Find events that occurred within a perdiod of time

*/
SELECT o1.id AS o1_id,
       o1.account_id AS o1_account_id,
       o1.occurred_at AS o1_occurred_at,

       o2.id AS o2_id,
       o2.account_id AS o2_account_id,
       o2.occurred_at AS o2_occurred_at

FROM parch_and_posey.orders o1
LEFT JOIN parch_and_posey.orders o2
  -- join accounts
  ON o1.account_id = o2.account_id
  -- find orders that happened AFTER original order took place
 AND o2.occurred_at > o1.occurred_at
  -- and within given time frame (time bound the records)
 AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at;

/* -----------------------------------------------------------------
Perform same interval analysis except for the web_events table

change the interval to 1 day to find those web events that occurred
after, but not more than 1 day after, another web event

add a column for the channel variable in both instances of the table
in your query

*/
SELECT w1.id AS w1_id,
       w1.account_id AS w1_account_id,
       w1.occurred_at AS w1_occurred_at,
       w1.channel AS w2_channel,

       w2.id AS w2_id,
       w2.account_id AS w2_account_id,
       w2.occurred_at AS w2_occurred_at,
       w2.channel AS w2_channel

FROM parch_and_posey.web_events w1
LEFT JOIN parch_and_posey.web_events w2
  -- join accounts
  ON w1.account_id = w2.account_id
  -- find events that happened AFTER original event
 AND w1.occurred_at > w2.occurred_at
  -- and within given time frame (time bound the records)
 AND w1.occurred_at <= w2.occurred_at + INTERVAL '1 day'
ORDER BY w1.account_id, w2.occurred_at;


/* -----------------------------------------------------------------
UNION

1) Both tables must have the same number of columns.
2) Those columns must have the same data types in the same order
   as the first table.

   * Columns do NOT have to have the same name *

   * Union only appends distinct values *
     >> identical rows are dropped <<
     >> use UNION ALL to keep those rows <<
*/

-- Write a query that uses UNION ALL on two instances
-- (and selecting all columns) of the accounts table.
SELECT *
FROM parch_and_posey.accounts a1
WHERE a1.name = 'Disney'

UNION ALL

SELECT *
FROM parch_and_posey.accounts a2
WHERE a2.name = 'Walmart';


-- will result in named accounts being counted twice
WITH double_accounts AS (
  SELECT *
  FROM parch_and_posey.accounts a1

  UNION ALL

  SELECT *
  FROM parch_and_posey.accounts a2
)
SELECT name, COUNT(*)
FROM double_accounts
GROUP BY name
ORDER BY name;

/* -----------------------------------------------------------------
OPTIMIZATIONS

Some things that can affect performance:
    1) table size
    2) joins
    3) agregations
    4) multiple queries running concurrently
    5) database design and optimizations done by DBA

What to do?

 * Limit rows to include only the data you need
 * Do analysis on a subset of the data until query is refined
     ! remember aggregations occur first !
   Can use LIMIT in a subquery first then do aggs in outter query
 * Time series data, limit to a small time window for speed

What to do about joins?

 * Try to simplify joins & reduce number of rows being evaluated
 * Reduce table results before join is executed
     ! see example below !

     !!! ACCURACY FIRST THEN SPEED !!!
*/
SELECT a.name,
       sub.web_events_cnt
FROM(SELECT account_id,
     COUNT(*) AS web_events_cnt
     FROM parch_and_posey.web_events
     GROUP BY 1
    ) sub
JOIN parch_and_posey.accounts a
ON a.id = sub.account_id
ORDER BY 2 DESC

/* -----------------------------------------------------------------
   add keyword EXPLAIN at start of query to see the costs
   modify parts that are expensive then run it again to see
   if costs reduced
*/
EXPLAIN
SELECT a.name,
       sub.web_events_cnt
FROM(SELECT account_id,
     COUNT(*) AS web_events_cnt
     FROM parch_and_posey.web_events
     GROUP BY 1
    ) sub
JOIN parch_and_posey.accounts a
ON a.id = sub.account_id
ORDER BY 2 DESC

/* -----------------------------------------------------------------
   JOINing subqueries

   matching day to day rows = data explosion
*/
SELECT DATE_TRUNC('day', o.occurred_at) AS day_date,
       COUNT(DISTINCT a.sales_rep_id) AS active_sales_reps,
       COUNT(DISTINCT o.id) AS orders,
       COUNT(DISTINCT we.id) AS web_visits
FROM parch_and_posey.accounts a
JOIN parch_and_posey.orders o
  ON o.account_id = a.id
JOIN parch_and_posey.web_events we
  ON DATE_TRUNC('day', we.occurred_at) = DATE_TRUNC('day', o.occurred_at)
GROUP BY 1
ORDER BY 1 DESC;

-- aggreate counts separately
-- first subquery, 1060 rows
SELECT DATE_TRUNC('day', o.occurred_at) AS day_date,
       COUNT(a.sales_rep_id) AS active_sales_reps,
       COUNT(o.id) AS orders
FROM parch_and_posey.accounts a
JOIN parch_and_posey.orders o
  ON o.account_id = a.id
GROUP BY 1

-- second subquery, 1119 rows
SELECT DATE_TRUNC('day', we.occurred_at) AS day_date,
       COUNT(we.id) AS web_visits
FROM parch_and_posey.web_events we
GROUP BY 1

-- now combine these
--EXPLAIN
SELECT COALESCE(orders.day_date, web_events.day_date) AS day_date,
       orders.active_sales_reps,
       orders.orders,
       web_events.web_visits
FROM (
    SELECT DATE_TRUNC('day', o.occurred_at) AS day_date,
           COUNT(a.sales_rep_id) AS active_sales_reps,
           COUNT(o.id) AS orders
    FROM parch_and_posey.accounts a
    JOIN parch_and_posey.orders o
      ON o.account_id = a.id
    GROUP BY 1
) orders
-- full join just in case a row is missing from one of the tables
FULL JOIN
(
    SELECT DATE_TRUNC('day', we.occurred_at) AS day_date,
       COUNT(we.id) AS web_visits
    FROM parch_and_posey.web_events we
    GROUP BY 1
) web_events
ON web_events.day_date = orders.day_date
ORDER BY 1 DESC;

