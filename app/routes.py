from flask import Blueprint, flash, redirect, render_template, request, url_for
from mysql.connector import Error

from .db import execute, fetch_all, fetch_one

main = Blueprint('main', __name__)


@main.route('/')
def dashboard():
    stats = {
        'students': fetch_one('SELECT COUNT(*) AS n FROM students')['n'],
        'courses': fetch_one('SELECT COUNT(*) AS n FROM courses')['n'],
        'faculty': fetch_one('SELECT COUNT(*) AS n FROM faculty')['n'],
        'departments': fetch_one('SELECT COUNT(*) AS n FROM departments')['n'],
    }
    recent = fetch_all('''
        SELECT s.student_id, CONCAT(s.first_name, ' ', s.last_name) AS name,
               d.department_name, s.admission_year
        FROM students s
        JOIN departments d ON d.department_id = s.department_id
        ORDER BY s.student_id DESC
        LIMIT 5
    ''')
    return render_template('dashboard.html', stats=stats, recent=recent)


@main.route('/students')
def students():
    q = request.args.get('q', '').strip()
    if q:
        students = fetch_all('''
            SELECT s.*, d.department_name
            FROM students s
            JOIN departments d ON d.department_id = s.department_id
            WHERE s.first_name LIKE %s OR s.last_name LIKE %s OR s.email LIKE %s
            ORDER BY s.student_id DESC
        ''', (f'%{q}%', f'%{q}%', f'%{q}%'))
    else:
        students = fetch_all('''
            SELECT s.*, d.department_name
            FROM students s
            JOIN departments d ON d.department_id = s.department_id
            ORDER BY s.student_id DESC
        ''')
    return render_template('students.html', students=students, q=q)


@main.route('/students/new', methods=['GET', 'POST'])
def student_new():
    departments = fetch_all('SELECT * FROM departments ORDER BY department_name')
    if request.method == 'POST':
        try:
            student_id = execute('''
                INSERT INTO students
                (first_name, last_name, dob, gender, email, phone, address, admission_year, department_id)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
            ''', (
                request.form['first_name'], request.form['last_name'], request.form['dob'],
                request.form['gender'], request.form['email'], request.form['phone'],
                request.form['address'], request.form['admission_year'], request.form['department_id']
            ))
            flash('Student added successfully.', 'success')
            return redirect(url_for('main.student_detail', student_id=student_id))
        except Error as exc:
            flash(f'Could not add student: {exc}', 'error')
    return render_template('student_form.html', departments=departments)


@main.route('/students/<int:student_id>')
def student_detail(student_id):
    student = fetch_one('''
        SELECT s.*, d.department_name
        FROM students s JOIN departments d ON d.department_id=s.department_id
        WHERE s.student_id=%s
    ''', (student_id,))
    if not student:
        flash('Student not found.', 'error')
        return redirect(url_for('main.students'))

    academic = fetch_all('''
        SELECT c.course_code, c.course_name, e.academic_year, e.semester,
               a.attendance_percentage, r.marks_obtained, ex.total_marks, r.grade, r.grade_point
        FROM enrollments e
        JOIN courses c ON c.course_id=e.course_id
        LEFT JOIN attendance a ON a.enrollment_id=e.enrollment_id
        LEFT JOIN exams ex ON ex.course_id=c.course_id
        LEFT JOIN results r ON r.exam_id=ex.exam_id AND r.student_id=e.student_id
        WHERE e.student_id=%s
        ORDER BY e.academic_year DESC, e.semester DESC, c.course_code
    ''', (student_id,))
    return render_template('student_detail.html', student=student, academic=academic)


@main.route('/courses')
def courses():
    courses = fetch_all('''
        SELECT c.*, d.department_name, CONCAT(f.first_name, ' ', f.last_name) AS faculty_name
        FROM courses c
        JOIN departments d ON d.department_id=c.department_id
        LEFT JOIN faculty f ON f.faculty_id=c.faculty_id
        ORDER BY c.course_code
    ''')
    return render_template('courses.html', courses=courses)


@main.route('/attendance')
def attendance():
    rows = fetch_all('''
        SELECT a.attendance_id, s.student_id,
               CONCAT(s.first_name, ' ', s.last_name) AS student_name,
               c.course_code, c.course_name, a.classes_held, a.classes_attended,
               a.attendance_percentage
        FROM attendance a
        JOIN enrollments e ON e.enrollment_id=a.enrollment_id
        JOIN students s ON s.student_id=e.student_id
        JOIN courses c ON c.course_id=e.course_id
        ORDER BY a.attendance_percentage ASC, s.student_id
    ''')
    return render_template('attendance.html', rows=rows)


@main.route('/results')
def results():
    rows = fetch_all('''
        SELECT r.result_id, s.student_id,
               CONCAT(s.first_name, ' ', s.last_name) AS student_name,
               c.course_code, c.course_name, ex.exam_type,
               r.marks_obtained, ex.total_marks, r.grade, r.grade_point
        FROM results r
        JOIN students s ON s.student_id=r.student_id
        JOIN exams ex ON ex.exam_id=r.exam_id
        JOIN courses c ON c.course_id=ex.course_id
        ORDER BY r.grade_point DESC, s.student_id
    ''')
    return render_template('results.html', rows=rows)
