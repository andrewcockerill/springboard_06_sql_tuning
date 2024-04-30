## SQL Tuning Mini-Project

### Overview

In this project, a sampling of the DBLP (computer science bibliography dataset) is obtained in .csv format using a premade Python script. From here, custom code is written to ingest these files into a PostgreSQL database. Next, a series of provided questions about the data are answered via SQL queries. We lastly explore the effect that buliding indexes on underlying tables has on query performance.

### Structure

- <tt>src</tt>: Scripts for downloading .csv files and ingesting them as PostgresSQL tables. Also houses all SQL code needed to answer provided questions and build indexes.

- <tt>notebooks</tt>: Contains a report notebook that comments on the indexes used and the performance gains observed.

### Additional Links

DBLP Website: https://dblp.org/