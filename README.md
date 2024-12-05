# t2195_assignment_3
SQL, R, Python Queries on Data Expo 2009 Harvard Data Set

Practice assignment 3
Download the Data Expo 2009 data from the Harvard Dataverse and construct an
SQLite Database called airline2.db with the following tables:
1. ontime (with the data from 2000 to 2005 – including 2000 and 2005)
2. airports (with the data in airports.csv)
3. carriers (with the data in carriers.csv)
4. planes (with the data in plane-data.csv)
Create a GitHub repository called “st2195_assignment_3” that includes:
1. a README.md file with a short markdown description of this assignment and a
reference to the Data Expo 2009 data, and the Harvard Dataverse [1 point]
2. a folder called “r_sql” with a R code for constructing the database (from the csv
inputs) and replicating the queries in the practice quiz. The latter should be done
both using DBI and dplyr notation [1.75 points each]
3. a folder called “python_sql” with a Python version of the code in point 2, based
on sqlite3 [1.75 points]
4. A simplified solution for the query in Q4 in either R or Python (placed either in
the R or Python *_sql folder) [1.75 points]
Note that the database file should not be placed in the GitHub repository (it is quite
large). Also, the R and Python scripts should save the output of the queries in csv within
their respective folders [1 point each].
