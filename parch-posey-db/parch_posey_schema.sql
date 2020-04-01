/*
   Parch and Posey is a fictional paper-selling company
   used in Udacity's SQL lessons.

   The course uses PostgreSQL to store the data.

*/

-- CREATE SCHEMA IF NOT EXISTS parch_and_posey AUTHORIZATION ssi112;

CREATE TABLE parch_and_posey.accounts (
    id integer NOT NULL,
    name character varying NOT NULL,
    website character varying,
    lat numeric,
    long numeric,
    primary_poc character varying,
    sales_rep_id integer
);


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE parch_and_posey.orders (
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


--
-- Name: region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE parch_and_posey.region (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- Name: sales_reps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE parch_and_posey.sales_reps (
    id integer NOT NULL,
    name character varying NOT NULL,
    region_id integer NOT NULL
);


--
-- Name: web_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE parch_and_posey.web_events (
    id integer NOT NULL,
    account_id integer NOT NULL,
    occurred_at timestamp without time zone NOT NULL,
    channel character varying NOT NULL
);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parch_and_posey.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parch_and_posey.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parch_and_posey.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: sales_reps sales_reps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parch_and_posey.sales_reps
    ADD CONSTRAINT sales_reps_pkey PRIMARY KEY (id);


--
-- Name: web_events web_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parch_and_posey.web_events
    ADD CONSTRAINT web_events_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_sales_rep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parch_and_posey.accounts
    ADD CONSTRAINT accounts_sales_rep_id_fkey FOREIGN KEY (sales_rep_id) REFERENCES parch_and_posey.sales_reps(id) ON DELETE CASCADE;


--
-- Name: orders orders_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parch_and_posey.orders
    ADD CONSTRAINT orders_account_id_fkey FOREIGN KEY (account_id) REFERENCES parch_and_posey.accounts(id) ON DELETE CASCADE;


--
-- Name: sales_reps sales_reps_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parch_and_posey.sales_reps
    ADD CONSTRAINT sales_reps_region_id_fkey FOREIGN KEY (region_id) REFERENCES parch_and_posey.region(id) ON DELETE CASCADE;


--
-- Name: web_events web_events_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parch_and_posey.web_events
    ADD CONSTRAINT web_events_account_id_fkey FOREIGN KEY (account_id) REFERENCES parch_and_posey.accounts(id) ON DELETE CASCADE;

