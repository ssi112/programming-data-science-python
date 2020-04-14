# Programming for Data Science with Python

### Parch-Posey-SQLite-DB

**Parch and Posey database used in the Udacity Programming for Data Science with Python Nanodegree and Other Courses.**

Parch and Posey is a fictional paper-selling company used in SQL lessons. The course uses PostgreSQL to store the data. Scripts to load the data are contained in the `\parch-posey-db` directory.

As the data already contains primary and foreign key entries, as opposed to having them organically created by the DB, you may run into errors when attempting to import the data. Run the insert scripts in the following sequence will allow the data to import and avoid foreign key errors.

 1. region
 2. sales_reps
 3. accounts
 4. web_events
 5. orders
 
 &#9745; Note on SQL code in \sql folder. Only code for the final two lessons is included: window functions and advanced joins and performance.

--- 
### Project 1

Use SQL to explore the Sakila database related to movie rentals. As part of the project submission, write and run SQL queries and build visualizations to showcase the output of your queries in a presentation. 

Check the project #1 readme [here](projects/project1.md).

---
### Project 2

Use Python to explore data related to bike share systems for three major cities in the United States—Chicago, New York City, and Washington. You will write code to import the data and answer interesting questions about it by computing descriptive statistics. You will also write a script that takes in raw input to create an interactive experience in the terminal to present these statistics. 

Check the project #2 readme [here](projects/project2.md).

---
### Project 3

