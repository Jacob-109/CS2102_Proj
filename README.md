# CS2102_Proj

## General
---
* ER.pdf (ER diagram for schema)
* schema.txt (Table definitions)
* db.sql (PostgresSQL dump to set up tables)
* data.sql (PostgresSQL dump to populate tables)

## IMPORT DATABASE DUMP
---
1. Create db\ 
sudo -u postgres createdb `db name`
2. psql -d `db name` -f `file path`
