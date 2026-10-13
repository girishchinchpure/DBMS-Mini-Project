USE sams_db;

-- 1. Display all students with departments
SELECT s.student_id, CONCAT(s.first_name,' ',s.last_name) AS student_name,
       d.department_name, s.admission_year
FROM students s JOIN departments d ON d.department_id=s.department_id;

-- 2. Find students with attendance below 75%
SELECT s.student_id, CONCAT(s.first_name,' ',s.last_name) AS student_name,
       c.course_code, a.attendance_percentage
FROM attendance a
JOIN enrollments e ON e.enrollment_id=a.enrollment_id
JOIN students s ON s.student_id=e.student_id
JOIN courses c ON c.course_id=e.course_id
WHERE a.attendance_percentage < 75;

-- 3. Courses with their assigned faculty
SELECT c.course_code, c.course_name,
       COALESCE(CONCAT(f.first_name,' ',f.last_name),'Unassigned') AS faculty
FROM courses c LEFT JOIN faculty f ON f.faculty_id=c.faculty_id;

-- 4. Student result report
SELECT s.student_id, CONCAT(s.first_name,' ',s.last_name) AS student_name,
       c.course_code, r.marks_obtained, ex.total_marks, r.grade, r.grade_point
FROM results r
JOIN students s ON s.student_id=r.student_id
JOIN exams ex ON ex.exam_id=r.exam_id
JOIN courses c ON c.course_id=ex.course_id
ORDER BY student_name;

-- 5. Average marks per course
SELECT c.course_code, c.course_name, ROUND(AVG(r.marks_obtained),2) AS average_marks
FROM results r JOIN exams ex ON ex.exam_id=r.exam_id
JOIN courses c ON c.course_id=ex.course_id
GROUP BY c.course_id;

-- 6. Highest scorer in each exam
SELECT ex.exam_id, c.course_code, MAX(r.marks_obtained) AS highest_marks
FROM exams ex JOIN courses c ON c.course_id=ex.course_id
JOIN results r ON r.exam_id=ex.exam_id
GROUP BY ex.exam_id, c.course_code;

-- 7. Students who scored above 80
SELECT DISTINCT s.student_id, CONCAT(s.first_name,' ',s.last_name) AS student_name
FROM results r JOIN students s ON s.student_id=r.student_id
WHERE r.marks_obtained > 80;

-- 8. Number of students in each department
SELECT d.department_name, COUNT(s.student_id) AS student_count
FROM departments d LEFT JOIN students s ON s.department_id=d.department_id
GROUP BY d.department_id;

-- 9. Course enrollment count
SELECT c.course_code, c.course_name, COUNT(e.enrollment_id) AS enrolled_students
FROM courses c LEFT JOIN enrollments e ON e.course_id=c.course_id
GROUP BY c.course_id;

-- 10. Students not enrolled in any course
SELECT s.student_id, CONCAT(s.first_name,' ',s.last_name) AS student_name
FROM students s LEFT JOIN enrollments e ON e.student_id=s.student_id
WHERE e.enrollment_id IS NULL;

-- 11. Failed results
SELECT s.student_id, CONCAT(s.first_name,' ',s.last_name) AS student_name,
       c.course_code, r.marks_obtained, r.grade
FROM results r JOIN students s ON s.student_id=r.student_id
JOIN exams ex ON ex.exam_id=r.exam_id JOIN courses c ON c.course_id=ex.course_id
WHERE r.grade='F';

-- 12. Department-wise average marks
SELECT d.department_name, ROUND(AVG(r.marks_obtained),2) AS avg_marks
FROM results r JOIN students s ON s.student_id=r.student_id
JOIN departments d ON d.department_id=s.department_id
GROUP BY d.department_id;

-- 13. Students with 90+ marks
SELECT s.student_id, CONCAT(s.first_name,' ',s.last_name) AS student_name,
       c.course_code, r.marks_obtained
FROM results r JOIN students s ON s.student_id=r.student_id
JOIN exams ex ON ex.exam_id=r.exam_id JOIN courses c ON c.course_id=ex.course_id
WHERE r.marks_obtained >= 90;

-- 14. Attendance summary by student
SELECT s.student_id, CONCAT(s.first_name,' ',s.last_name) AS student_name,
       ROUND(AVG(a.attendance_percentage),2) AS avg_attendance
FROM attendance a JOIN enrollments e ON e.enrollment_id=a.enrollment_id
JOIN students s ON s.student_id=e.student_id
GROUP BY s.student_id;

-- 15. Use a subquery to find students above overall average marks
SELECT DISTINCT s.student_id, CONCAT(s.first_name,' ',s.last_name) AS student_name
FROM students s JOIN results r ON r.student_id=s.student_id
WHERE r.marks_obtained > (SELECT AVG(marks_obtained) FROM results);

-- 16. View: student academic summary
CREATE OR REPLACE VIEW student_academic_summary AS
SELECT s.student_id, CONCAT(s.first_name,' ',s.last_name) AS student_name,
       d.department_name, ROUND(AVG(r.grade_point),2) AS average_grade_point
FROM students s JOIN departments d ON d.department_id=s.department_id
LEFT JOIN results r ON r.student_id=s.student_id
GROUP BY s.student_id, student_name, d.department_name;

SELECT * FROM student_academic_summary ORDER BY average_grade_point DESC;

-- 17. Transaction example: update attendance safely
START TRANSACTION;
UPDATE attendance SET classes_attended = classes_attended + 1 WHERE attendance_id=1;
COMMIT;

-- 18. Index examples for common searches
CREATE INDEX idx_student_department ON students(department_id);
CREATE INDEX idx_enrollment_student ON enrollments(student_id);
CREATE INDEX idx_result_student ON results(student_id);
