/* ----------------------------------------------------------------------
WINDOW FUNCTIONS:

Ref: https://www.postgresql.org/docs/8.4/functions-window.html


OVER & ORDER BY
create a running total of standard_amt_usd (in the orders table)
over order time with no date truncation
*/
SELECT standard_amt_usd,
       SUM(standard_amt_usd) OVER (ORDER BY occurred_at) AS run_tot
FROM parch_and_posey.orders;

/* ----------------------------------------------------------------------
create a running total of standard_amt_usd (in the orders table)
over order time, but this time, date truncate occurred_at by year
and partition by that same year-truncated occurred_at variable.
Your final table should have three columns:
One with the amount being added for each row,
one for the truncated date,
and a final column with the running total within each year
*/

SELECT DATE_TRUNC('year', occurred_at) AS year,
       standard_qty,
       -- running total for each year
       SUM(standard_qty) OVER
        (PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at)
        AS tear_total
FROM parch_and_posey.orders;

/* ----------------------------------------------------------------------
ROW_NUMBER
RANK
DENSE_RANK
*/
SELECT id, account_id, occurred_at,
       ROW_NUMBER()
       OVER (PARTITION BY account_id ORDER BY occurred_at) AS row_num
FROM parch_and_posey.orders;

SELECT id, account_id,
       DATE_TRUNC('month', occurred_at) AS mth,
       RANK()
       OVER (PARTITION BY account_id
        ORDER BY DATE_TRUNC('month', occurred_at)) AS row_num
FROM parch_and_posey.orders;

SELECT id, account_id,
       DATE_TRUNC('month', occurred_at) AS mth,
       DENSE_RANK()
       OVER (PARTITION BY account_id
        ORDER BY DATE_TRUNC('month', occurred_at)) AS row_num
FROM parch_and_posey.orders;

/* ----------------------------------------------------------------------
Select the id, account_id, and total variable from the orders table,
then create a column called total_rank that ranks this total amount of
paper ordered (from highest to lowest) for each account using a partition
*/
SELECT id, account_id, total,
       RANK()
       OVER (PARTITION BY account_id
        ORDER BY total DESC) AS tot_amt
FROM parch_and_posey.orders;

/* ----------------------------------------------------------------------
 All together now!
*/
SELECT id, account_id, standard_qty,
       DATE_TRUNC('month', occurred_at) AS mth,
       DENSE_RANK() OVER (PARTITION BY account_id
            ORDER BY DATE_TRUNC('month', occurred_at)) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id
            ORDER BY DATE_TRUNC('month', occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id
            ORDER BY DATE_TRUNC('month', occurred_at)) AS cnt_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id
            ORDER BY DATE_TRUNC('month', occurred_at)) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id
            ORDER BY DATE_TRUNC('month', occurred_at)) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id
            ORDER BY DATE_TRUNC('month', occurred_at)) AS max_std_qty
FROM parch_and_posey.orders;

/* ----------------------------------------------------------------------
Compared to above which uses the ORDER BY on the month.
The partitioning occurring on the account_id column causes all
aggregate functions to update only when the account number changes.

The ORDER and PARTITION define what is referred to as the “window” -
the ordered subset of data over which calculations are made.

Removing ORDER BY just leaves an unordered partition.
*/
SELECT id, account_id, standard_qty,
       DATE_TRUNC('month', occurred_at) AS mth,
       DENSE_RANK() OVER (PARTITION BY account_id) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id) AS cnt_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id) AS max_std_qty
FROM parch_and_posey.orders;

/* ----------------------------------------------------------------------
Save some typing and use a Window Alias clause (easier to read too)
results will be the same as previous query
*/
SELECT id, account_id, standard_qty,
       DATE_TRUNC('month', occurred_at) AS mth,
       DENSE_RANK() OVER main_win AS dense_rank,
       SUM(standard_qty) OVER main_win AS sum_std_qty,
       COUNT(standard_qty) OVER main_win AS cnt_std_qty,
       AVG(standard_qty) OVER main_win AS avg_std_qty,
       MIN(standard_qty) OVER main_win AS min_std_qty,
       MAX(standard_qty) OVER main_win AS max_std_qty
FROM parch_and_posey.orders
WINDOW main_win AS (PARTITION BY account_id
            ORDER BY DATE_TRUNC('month', occurred_at));

SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER account_year_window AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM parch_and_posey.orders
WINDOW account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at));

/* ----------------------------------------------------------------------
LAG returns the value from a previous row to the current row in the table

Each row’s value in lag_sum is pulled from the previous row

To compare the values between the rows, we need to use both columns
(standard_sum and lag_sum). A new column named lag_difference, which
subtracts lag_sum from the value in standard_sum for each row in the table
*/

SELECT account_id, standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_sum,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_diff
FROM (
      SELECT account_id, SUM(standard_qty) AS standard_sum
      FROM parch_and_posey.orders
      GROUP BY 1
     ) sub

/* ----------------------------------------------------------------------
LEAD return the value from the row following the current row

Each row’s value in lead is pulled from the row after it
Compare the values between the rows. add a column named lead_difference,
which subtracts the value in standard_sum from lead for each row
*/
SELECT account_id, standard_sum,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead_sum,
       standard_sum - LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead_diff
FROM (
      SELECT account_id, SUM(standard_qty) AS standard_sum
      FROM parch_and_posey.orders
      GROUP BY 1
     ) sub;


-- combined
SELECT account_id, standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_sum,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_diff,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead_sum,
       standard_sum - LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead_diff
FROM (
      SELECT account_id, SUM(standard_qty) AS standard_sum
      FROM parch_and_posey.orders
      GROUP BY 1
     ) sub;

/* ----------------------------------------------------------------------
determine how the current order's total revenue ("total" meaning from
sales of all types of paper) compares to the next order's total revenue

use occurred_at and total_amt_usd in the orders table along with LEAD.
There should be four columns: occurred_at, total_amt_usd, lead,
and lead_difference
*/
SELECT occurred_at, total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY total_amt_usd) AS lead_amt,
       LEAD(total_amt_usd) OVER (ORDER BY total_amt_usd) - total_amt_usd AS lead_diff
FROM (
      SELECT occurred_at, SUM(total_amt_usd) AS total_amt_usd
      FROM parch_and_posey.orders
      GROUP BY 1
     ) sub;


/* ----------------------------------------------------------------------
NTILE - use to identify what percentile (or quartile, or any other subdivision)
a given row falls into. The syntax is NTILE(# of buckets).
ORDER BY determines which column to use to determine the where the data falls
into which bucket.

When you use a NTILE function but the number of rows in the partition is
less than the NTILE(number of groups), then NTILE will divide the rows into
as many groups as there are members (rows) in the set but then stop short
of the requested number of groups.

If you’re working with very small windows, keep this in mind and consider
using quartiles or similarly small bands.
*/

SELECT id, account_id, occurred_at, standard_qty,
       NTILE(4) OVER (ORDER BY standard_qty) AS quartile,
       NTILE(5) OVER (ORDER BY standard_qty) AS quintile,
       NTILE(100) OVER (ORDER BY standard_qty) AS percentile
FROM parch_and_posey.orders
ORDER BY standard_qty DESC;


/* ----------------------------------------------------------------------
Use the NTILE functionality to divide the accounts into 4 levels in
terms of the amount of standard_qty for their orders
*/
SELECT account_id, occurred_at, standard_qty,
       NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS quartile
FROM parch_and_posey.orders
ORDER BY account_id DESC;

/* ----------------------------------------------------------------------
Use the NTILE functionality to divide the accounts into two levels
in terms of the amount of gloss_qty for their orders
*/
SELECT account_id, occurred_at, gloss_qty,
       NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS gloss_half
FROM parch_and_posey.orders
ORDER BY account_id DESC;

/* ----------------------------------------------------------------------
Use the NTILE functionality to divide the accounts into 100 levels in
terms of the amount of total_amt_usd for their orders
*/
SELECT account_id, occurred_at, total_amt_usd,
       NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
FROM parch_and_posey.orders
ORDER BY account_id DESC;








