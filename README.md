# Student Academic Management System (SAMS)

A DBMS mini-project for managing student academic records using MySQL and a lightweight Flask web interface.

## Features

- Student records and department mapping
- Faculty and course management
- Student course enrollment
- Attendance tracking with database-generated percentage
- Examination and marks storage
- Automatic grade and grade-point calculation using MySQL triggers
- Student profile with academic summary
- Searchable student list
- Dashboard showing core counts
- 18 SQL practice/report queries covering joins, aggregation, subqueries, views, transactions and indexes

## Technology Stack

- Database: MySQL 8.x
- Backend: Python 3.11+ / Flask
- Driver: mysql-connector-python
- Templates: Jinja2 + HTML/CSS

## Database Design

Main entities:
`departments`, `students`, `faculty`, `courses`, `enrollments`, `attendance`, `exams`, `results`

Relationships include:

- Department 1:N Student
- Department 1:N Faculty
- Department 1:N Course
- Student M:N Course through Enrollment
- Enrollment 1:1 Attendance
- Course 1:N Exam
- Student M:N Exam through Result

## Setup

### 1. Create the database

Open MySQL Workbench or the MySQL command line and run:

```sql
SOURCE database/schema.sql;
SOURCE database/seed.sql;
```

### 2. Create the Python environment

Windows PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### 3. Configure the database

Copy `.env.example` to `.env` and put your local MySQL password in `DB_PASSWORD`.

### 4. Start the application

```powershell
python run.py
```

Then open `http://127.0.0.1:5000`.

## Grade Logic

| Percentage | Grade | Grade Point |
|---:|:---:|---:|
| 90–100 | A+ | 10 |
| 80–89.99 | A | 9 |
| 70–79.99 | B+ | 8 |
| 60–69.99 | B | 7 |
| 50–59.99 | C | 6 |
| 40–49.99 | D | 5 |
| Below 40 | F | 0 |

## Suggested Viva Topics

Be prepared to explain primary keys, foreign keys, normalization, many-to-many relationships, joins, aggregate functions, subqueries, views, transactions, indexes, constraints, and triggers.

## Project Files

```text
student-academic-management-system/
├── app/
│   ├── __init__.py
│   ├── db.py
│   ├── routes.py
│   ├── static/style.css
│   └── templates/
├── database/
│   ├── schema.sql
│   ├── seed.sql
│   └── queries.sql
├── .env.example
├── requirements.txt
├── run.py
└── README.md
```
