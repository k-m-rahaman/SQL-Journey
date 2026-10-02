# 🗄️ SQL Journey

<div align="center">

<img src="https://img.shields.io/badge/SQL-Journey-336791?style=for-the-badge&logo=postgresql&logoColor=white" alt="SQL Journey">

<h3>From SQL Fundamentals to Advanced Database Development</h3>

<p>
A structured and practical SQL learning repository covering database fundamentals,
queries, relationships, advanced SQL, database design, and real-world problem solving.
</p>

<br>

<img src="https://img.shields.io/badge/Database-MySQL%208.0-4479A1?style=flat-square&logo=mysql&logoColor=white">
<img src="https://img.shields.io/badge/Language-SQL-336791?style=flat-square">
<img src="https://img.shields.io/badge/Level-Beginner%20→%20Advanced-6C63FF?style=flat-square">
<img src="https://img.shields.io/badge/Status-Complete-2EA44F?style=flat-square">

</div>

---

## 📌 About

**SQL Journey** is a structured collection of SQL concepts, examples, exercises, and practical database problems.

The repository is designed to build SQL knowledge progressively—from writing basic queries to working with complex joins, subqueries, CTEs, window functions, transactions, database design, and real-world SQL challenges.

Instead of learning SQL as isolated commands, the repository focuses on understanding:

* How relational databases work
* How data is structured
* How tables are connected
* How information is queried and analyzed
* How databases are optimized
* How SQL is used to solve practical problems

---

## 🎯 Learning Objectives

This repository focuses on developing a strong understanding of:

* Database fundamentals
* SQL syntax and query structure
* Data manipulation
* Data filtering and sorting
* Constraints and relationships
* SQL functions
* Aggregate operations
* Table joins
* Subqueries
* Common Table Expressions
* Window functions
* Views and indexes
* Transactions
* Stored procedures
* Triggers
* Database normalization
* SQL problem solving
* Interview-oriented SQL

---

## 🧭 SQL Learning Roadmap

```text
SQL Fundamentals
       │
       ▼
Operators & Constraints
       │
       ▼
Functions & Aggregation
       │
       ▼
Joins
       │
       ▼
Subqueries & Set Operations
       │
       ▼
Advanced SQL
       │
       ▼
CTEs & Window Functions
       │
       ▼
Database Design & Normalization
       │
       ▼
SQL Interview Problems
       │
       ▼
Practical SQL Project
```

---

## 📂 Repository Structure

```text
SQL-Journey/
│
├── 01_SQL_Basics/
│   ├── 01_create_database.sql
│   ├── 02_create_table.sql
│   ├── 03_insert_data.sql
│   ├── 04_select.sql
│   ├── 05_where.sql
│   ├── 06_order_by.sql
│   ├── 07_distinct.sql
│   └── 08_limit.sql
│
├── 02_SQL_Operators/
│   ├── 01_arithmetic_operators.sql
│   ├── 02_comparison_operators.sql
│   ├── 03_logical_operators.sql
│   ├── 04_between.sql
│   ├── 05_in.sql
│   ├── 06_like.sql
│   └── 07_is_null.sql
│
├── 03_SQL_Constraints/
│   ├── 01_primary_key.sql
│   ├── 02_foreign_key.sql
│   ├── 03_unique.sql
│   ├── 04_not_null.sql
│   ├── 05_check.sql
│   └── 06_default.sql
│
├── 04_SQL_Functions/
│   ├── 01_string_functions.sql
│   ├── 02_numeric_functions.sql
│   ├── 03_date_functions.sql
│   └── 04_null_functions.sql
│
├── 05_Aggregation/
│   ├── 01_count.sql
│   ├── 02_sum.sql
│   ├── 03_avg.sql
│   ├── 04_min_max.sql
│   └── 05_group_by_having.sql
│
├── 06_Joins/
│   ├── 01_inner_join.sql
│   ├── 02_left_join.sql
│   ├── 03_right_join.sql
│   ├── 04_full_join.sql
│   ├── 05_self_join.sql
│   └── 06_cross_join.sql
│
├── 07_Subqueries/
│   ├── 01_single_row.sql
│   ├── 02_multiple_row.sql
│   ├── 03_correlated_subquery.sql
│   └── 04_nested_subquery.sql
│
├── 08_Set_Operations/
│   ├── 01_union.sql
│   ├── 02_union_all.sql
│   ├── 03_intersect.sql
│   └── 04_except.sql
│
├── 09_Advanced_SQL/
│   ├── 01_views.sql
│   ├── 02_indexes.sql
│   ├── 03_stored_procedures.sql
│   ├── 04_triggers.sql
│   └── 05_transactions.sql
│
├── 10_CTEs_and_Window_Functions/
│   ├── 01_cte.sql
│   ├── 02_recursive_cte.sql
│   ├── 03_row_number.sql
│   ├── 04_rank_dense_rank.sql
│   ├── 05_lag_lead.sql
│   └── 06_partition_by.sql
│
├── 11_Database_Design/
│   ├── normalization.sql
│   ├── denormalization.sql
│   ├── 01NF.sql
│   ├── 02NF.sql
│   └── 03NF.sql
│
├── 12_SQL_Interview_Problems/
│   ├── 01_second_highest_salary.sql
│   ├── 02_duplicate_records.sql
│   ├── 03_nth_highest_salary.sql
│   ├── 04_employees_above_average.sql
│   ├── 05_consecutive_dates.sql
│   └── 06_top_n_per_group.sql
│
└── 13_Mini_Project/
    ├── README.md
    ├── 01_database.sql
    ├── 02_tables.sql
    ├── 03_sample_data.sql
    ├── 04_queries.sql
    ├── 05_views.sql
    ├── 06_indexes.sql
    └── 07_analysis.sql
```

---

# 📚 Topics Covered

## 01. SQL Basics

Fundamental SQL commands used to interact with relational databases.

* Database creation
* Table creation
* Inserting records
* `SELECT`
* `WHERE`
* `ORDER BY`
* `DISTINCT`
* `LIMIT`

---

## 02. SQL Operators

Understanding how conditions and calculations are performed in SQL.

* Arithmetic operators
* Comparison operators
* Logical operators
* `BETWEEN`
* `IN`
* `LIKE`
* `IS NULL`

---

## 03. SQL Constraints

Rules used to maintain data integrity and consistency.

* `PRIMARY KEY`
* `FOREIGN KEY`
* `UNIQUE`
* `NOT NULL`
* `CHECK`
* `DEFAULT`

---

## 04. SQL Functions

Built-in functions used for manipulating and processing data.

### String Functions

```sql
UPPER()
LOWER()
LENGTH()
CONCAT()
SUBSTRING()
```

### Numeric Functions

```sql
ROUND()
CEIL()
FLOOR()
ABS()
```

### Date Functions

```sql
CURRENT_DATE()
CURRENT_TIMESTAMP()
YEAR()
MONTH()
DAY()
```

### NULL Functions

```sql
COALESCE()
NULLIF()
```

---

## 05. Aggregation

Working with groups of records and calculating meaningful results.

```sql
COUNT()
SUM()
AVG()
MIN()
MAX()
```

Along with:

```sql
GROUP BY
HAVING
```

---

## 06. Joins

Understanding relationships between multiple tables.

```text
INNER JOIN
LEFT JOIN
RIGHT JOIN
FULL JOIN
SELF JOIN
CROSS JOIN
```

Example:

```sql
SELECT
    employees.name,
    departments.department_name
FROM employees
INNER JOIN departments
    ON employees.department_id = departments.department_id;
```

---

## 07. Subqueries

Queries inside other queries.

* Single-row subqueries
* Multiple-row subqueries
* Nested subqueries
* Correlated subqueries

Example:

```sql
SELECT name, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

---

## 08. Set Operations

Combining results from multiple queries.

```sql
UNION
UNION ALL
INTERSECT
EXCEPT
```

---

## 09. Advanced SQL

Advanced database functionality including:

* Views
* Indexes
* Stored procedures
* Triggers
* Transactions

Example:

```sql
CREATE VIEW employee_details AS
SELECT
    e.name,
    e.salary,
    d.department_name
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id;
```

---

## 10. CTEs & Window Functions

Advanced techniques for writing readable and powerful analytical queries.

### Common Table Expressions

```sql
WITH department_salary AS (
    SELECT
        department_id,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department_id
)
SELECT *
FROM department_salary;
```

### Window Functions

```sql
ROW_NUMBER()
RANK()
DENSE_RANK()
LAG()
LEAD()
```

Along with:

```sql
PARTITION BY
ORDER BY
```

Example:

```sql
SELECT
    name,
    department_id,
    salary,
    RANK() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;
```

---

# 🏗️ Database Design

The repository also covers relational database design principles.

### Normalization

```text
Unnormalized Form
       ↓
     1NF
       ↓
     2NF
       ↓
     3NF
```

Concepts include:

* Functional dependencies
* Redundancy
* Data integrity
* Normal forms
* Denormalization
* Relational design

---

# 🧠 SQL Problem Solving

The repository contains practical SQL problems commonly encountered while learning SQL and preparing for technical interviews.

Examples include:

* Finding the second-highest salary
* Finding duplicate records
* Finding the Nth-highest salary
* Finding employees above average salary
* Finding consecutive dates
* Finding top N records per group
* Ranking employees within departments
* Comparing current and previous records

Example:

```sql
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
);
```

---

# 🛠️ Technologies

<div align="center">

<img src="https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white">

<img src="https://img.shields.io/badge/SQL-336791?style=for-the-badge&logo=postgresql&logoColor=white">

<img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white">

<img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white">

</div>

---

# 💻 Requirements

To execute the SQL files, you can use any MySQL-compatible environment.

Recommended:

* MySQL 8.0+
* MySQL Workbench
* MySQL Command Line
* VS Code with a SQL extension

---

# 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/k-m-rahaman/SQL-Journey.git
```

### 2. Enter the directory

```bash
cd SQL-Journey
```

### 3. Open MySQL

```bash
mysql -u root -p
```

### 4. Create the database

```sql
CREATE DATABASE sql_journey;
```

### 5. Select the database

```sql
USE sql_journey;
```

### 6. Execute the SQL files

Run the files in numerical order to follow the learning structure.

---

# 📖 How to Use This Repository

Each SQL file is designed to focus on a specific concept.

A typical learning flow is:

```text
Read the concept
      ↓
Understand the syntax
      ↓
Study the example
      ↓
Run the query
      ↓
Modify the query
      ↓
Experiment with different inputs
      ↓
Solve the related problem
```

The goal is not simply to memorize SQL commands, but to understand **why a query works and how the database processes it**.

---

# 🧩 Example Database

Most examples use an **Employee Management System** consisting of related tables such as:

```text
Employees
    │
    ├──────── Departments
    │
    ├──────── Jobs
    │
    └──────── Salaries
```

This allows concepts such as:

* Primary keys
* Foreign keys
* Relationships
* Joins
* Aggregation
* Subqueries
* CTEs
* Window functions
* Indexing

to be demonstrated using a consistent database structure.

---

# 📊 Skills Developed

| Area              | Skills                                 |
| ----------------- | -------------------------------------- |
| Fundamentals      | SQL syntax, SELECT, filtering, sorting |
| Data Manipulation | INSERT, UPDATE, DELETE                 |
| Constraints       | PK, FK, UNIQUE, CHECK, NOT NULL        |
| Analysis          | GROUP BY, HAVING, aggregate functions  |
| Relationships     | SQL joins                              |
| Advanced Queries  | Subqueries and CTEs                    |
| Analytics         | Window functions                       |
| Database Design   | Normalization and relationships        |
| Performance       | Indexes                                |
| Automation        | Procedures and triggers                |
| Reliability       | Transactions                           |
| Problem Solving   | Interview-style SQL challenges         |

---

# 🏆 Practical Project

The repository concludes with a practical **Employee Management System** database that combines multiple SQL concepts into a single structured project.

The project demonstrates:

```text
Database Creation
       ↓
Table Design
       ↓
Relationships
       ↓
Sample Data
       ↓
Complex Queries
       ↓
Views
       ↓
Indexes
       ↓
Data Analysis
```

---

# 📌 SQL Philosophy

> **Don't memorize queries. Understand the data, understand the relationship between tables, and then build the query.**

SQL becomes powerful when you stop thinking only in terms of commands and start thinking in terms of **data relationships and questions**.

---

# 👨‍💻 Author

<div align="center">

### Kazi Mustafijur Rahaman

B.Tech CSE — Artificial Intelligence & Machine Learning

[![GitHub](https://img.shields.io/badge/GitHub-k--m--rahaman-181717?style=for-the-badge\&logo=github)](https://github.com/k-m-rahaman)

</div>

---

<div align="center">

### 🗄️ SQL • Databases • Problem Solving

**Learn → Query → Analyze → Build**

</div>
