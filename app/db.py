import os
import mysql.connector
from mysql.connector import Error


def get_connection():
    return mysql.connector.connect(
        host=os.getenv('DB_HOST', 'localhost'),
        port=int(os.getenv('DB_PORT', '3306')),
        database=os.getenv('DB_NAME', 'sams_db'),
        user=os.getenv('DB_USER', 'root'),
        password=os.getenv('DB_PASSWORD', ''),
    )


def fetch_all(query, params=None):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(query, params or ())
        return cursor.fetchall()
    finally:
        cursor.close()
        conn.close()


def fetch_one(query, params=None):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(query, params or ())
        return cursor.fetchone()
    finally:
        cursor.close()
        conn.close()


def execute(query, params=None):
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(query, params or ())
        conn.commit()
        return cursor.lastrowid
    except Error:
        conn.rollback()
        raise
    finally:
        cursor.close()
        conn.close()
