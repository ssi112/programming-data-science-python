SELECT AVG(standard_amt_usd) AS avg_std_usd, 
       AVG(standard_qty) AS avg_std_qty,
       AVG(gloss_amt_usd) AS avg_gloss_usd,
       AVG(gloss_qty) AS avg_gloss_qty,
       AVG(poster_amt_usd) AS avg_poster_usd,
       AVG(poster_qty) AS avg_poster_qty
FROM parch_and_posey.orders o;

SELECT o.occurred_at, a.name, o.total, o.total_amt_usd
FROM parch_and_posey.orders o
LEFT JOIN parch_and_posey.accounts a
  ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '2015-01-01' AND '2016-01-01'
ORDER BY o.occurred_at;

SELECT r.name AS "Region Name", a.name AS "Account Name",
       o.total_amt_usd / (o.total + 0.01) AS "Unit Price"
FROM parch_and_posey.region r
  JOIN parch_and_posey.sales_reps s
  ON r.id = s.region_id
    JOIN parch_and_posey.accounts a
    ON s.id = a.sales_rep_id
      JOIN parch_and_posey.orders o
      ON a.id = o.account_id
WHERE o.standard_qty > 100 AND poster_qty > 50
ORDER BY "Unit Price" DESC;