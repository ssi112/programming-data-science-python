/*
   Parch and Posey is a fictional paper-selling company
   used in Udacity's SQL lessons.

   The course uses PostgreSQL to store the data.

*/

-- CREATE SCHEMA IF NOT EXISTS parch_and_posey;

CREATE TABLE IF NOT EXISTS parch_and_posey.accounts (
    id integer NOT NULL,
    name character varying NOT NULL,
    website character varying,
    lat numeric,
    long numeric,
    primary_poc character varying,
    sales_rep_id integer
);

CREATE TABLE IF NOT EXISTS parch_and_posey.orders (
    id integer NOT NULL,
    account_id integer NOT NULL,
    occurred_at timestamp without time zone NOT NULL,
    standard_qty integer,
    gloss_qty integer,
    poster_qty integer,
    total integer,
    standard_amt_usd numeric,
    gloss_amt_usd numeric,
    poster_amt_usd numeric,
    total_amt_usd numeric
);

CREATE TABLE IF NOT EXISTS parch_and_posey.region (
    id integer NOT NULL,
    name character varying NOT NULL
);

CREATE TABLE IF NOT EXISTS parch_and_posey.sales_reps (
    id integer NOT NULL,
    name character varying NOT NULL,
    region_id integer NOT NULL
);

CREATE TABLE IF NOT EXISTS parch_and_posey.web_events (
    id integer NOT NULL,
    account_id integer NOT NULL,
    occurred_at timestamp without time zone NOT NULL,
    channel character varying NOT NULL
);

/* ---------------------------------------------------------------------
   Add primary & foreign key references
   Below could be modified to avoid raising an error to this:

    ALTER TABLE foo DROP CONSTRAINT IF EXISTS bar;
    ALTER TABLE foo ADD CONSTRAINT bar ...;
*/
ALTER TABLE ONLY parch_and_posey.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);

ALTER TABLE ONLY parch_and_posey.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);

ALTER TABLE ONLY parch_and_posey.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);

ALTER TABLE ONLY parch_and_posey.sales_reps
    ADD CONSTRAINT sales_reps_pkey PRIMARY KEY (id);

ALTER TABLE ONLY parch_and_posey.web_events
    ADD CONSTRAINT web_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY parch_and_posey.accounts
    ADD CONSTRAINT accounts_sales_rep_id_fkey FOREIGN KEY (sales_rep_id) REFERENCES parch_and_posey.sales_reps(id) ON DELETE CASCADE;

ALTER TABLE ONLY parch_and_posey.orders
    ADD CONSTRAINT orders_account_id_fkey FOREIGN KEY (account_id) REFERENCES parch_and_posey.accounts(id) ON DELETE CASCADE;

ALTER TABLE ONLY parch_and_posey.sales_reps
    ADD CONSTRAINT sales_reps_region_id_fkey FOREIGN KEY (region_id) REFERENCES parch_and_posey.region(id) ON DELETE CASCADE;

ALTER TABLE ONLY parch_and_posey.web_events
    ADD CONSTRAINT web_events_account_id_fkey FOREIGN KEY (account_id) REFERENCES parch_and_posey.accounts(id) ON DELETE CASCADE;

