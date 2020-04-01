# Programming for Data Science with Python

Programming for Data Science with Python

## Parch-Posey-SQLite-DB

**Parch and Posey database used in the Udacity Programming for Data Science with Python Nanodegree and Other Courses.**

Parch and Posey is a fictional paper-selling company used in SQL lessons. The course uses PostgreSQL to store the data. Scripts to load the data are contained in the `\parch-posey-db` directory.

As the data already contains primary and foreign key entries, as opposed to having them organically created by the DB, you may run into errors when attempting to import the data. Run the insert scripts in the following sequence will allow the data to import and avoid foreign key errors.

 1. region
 2. sales_reps
 3. accounts
 4. web_events
 5. orders
 
 