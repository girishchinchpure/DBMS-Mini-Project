CREATE DATABASE IF NOT EXISTS sams_db;
USE sams_db;

DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS exams;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS faculty;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_code VARCHAR(10) NOT NULL UNIQUE,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    hod_name VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dob DATE,
    gender ENUM('Male','Female','Other'),
    email VARCHAR(120) NOT NULL UNIQUE,
    phone VARCHAR(15),
    address VARCHAR(255),
    admission_year YEAR NOT NULL,
    department_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_student_department FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE faculty (
    faculty_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone VARCHAR(15),
    department_id INT NOT NULL,
    CONSTRAINT fk_faculty_department FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(120) NOT NULL,
    credits DECIMAL(3,1) NOT NULL,
    semester TINYINT NOT NULL,
    department_id INT NOT NULL,
    faculty_id INT,
    CONSTRAINT chk_course_credits CHECK (credits > 0 AND credits <= 10),
    CONSTRAINT chk_course_semester CHECK (semester BETWEEN 1 AND 8),
    CONSTRAINT fk_course_department FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_course_faculty FOREIGN KEY (faculty_id)
        REFERENCES faculty(faculty_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    academic_year VARCHAR(9) NOT NULL,
    semester TINYINT NOT NULL,
    enrollment_date DATE NOT NULL,
    CONSTRAINT uq_enrollment UNIQUE (student_id, course_id, academic_year, semester),
    CONSTRAINT chk_enrollment_semester CHECK (semester BETWEEN 1 AND 8),
    CONSTRAINT fk_enrollment_student FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_enrollment_course FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id INT NOT NULL UNIQUE,
    classes_held INT NOT NULL,
    classes_attended INT NOT NULL,
    attendance_percentage DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE WHEN classes_held = 0 THEN 0 ELSE (classes_attended / classes_held) * 100 END
    ) STORED,
    CONSTRAINT chk_attendance_held CHECK (classes_held >= 0),
    CONSTRAINT chk_attendance_attended CHECK (classes_attended >= 0 AND classes_attended <= classes_held),
    CONSTRAINT fk_attendance_enrollment FOREIGN KEY (enrollment_id)
        REFERENCES enrollments(enrollment_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE exams (
    exam_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    exam_type ENUM('Unit Test','Mid Semester','End Semester','Practical','Viva') NOT NULL,
    exam_date DATE NOT NULL,
    total_marks DECIMAL(5,2) NOT NULL DEFAULT 100,
    CONSTRAINT chk_exam_total CHECK (total_marks > 0),
    CONSTRAINT fk_exam_course FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    exam_id INT NOT NULL,
    marks_obtained DECIMAL(5,2) NOT NULL,
    grade VARCHAR(2),
    grade_point DECIMAL(3,2),
    CONSTRAINT uq_student_exam UNIQUE (student_id, exam_id),
    CONSTRAINT chk_marks CHECK (marks_obtained >= 0),
    CONSTRAINT fk_result_student FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_result_exam FOREIGN KEY (exam_id)
        REFERENCES exams(exam_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

DELIMITER //
CREATE TRIGGER trg_results_grade_insert
BEFORE INSERT ON results
FOR EACH ROW
BEGIN
    DECLARE percentage DECIMAL(7,2);
    DECLARE max_marks DECIMAL(5,2);
    SELECT total_marks INTO max_marks FROM exams WHERE exam_id = NEW.exam_id;
    IF NEW.marks_obtained > max_marks THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Marks obtained cannot exceed total marks';
    END IF;
    SET percentage = (NEW.marks_obtained / max_marks) * 100;

    IF percentage >= 90 THEN SET NEW.grade = 'A+'; SET NEW.grade_point = 10.00;
    ELSEIF percentage >= 80 THEN SET NEW.grade = 'A'; SET NEW.grade_point = 9.00;
    ELSEIF percentage >= 70 THEN SET NEW.grade = 'B+'; SET NEW.grade_point = 8.00;
    ELSEIF percentage >= 60 THEN SET NEW.grade = 'B'; SET NEW.grade_point = 7.00;
    ELSEIF percentage >= 50 THEN SET NEW.grade = 'C'; SET NEW.grade_point = 6.00;
    ELSEIF percentage >= 40 THEN SET NEW.grade = 'D'; SET NEW.grade_point = 5.00;
    ELSE SET NEW.grade = 'F'; SET NEW.grade_point = 0.00;
    END IF;
END//

CREATE TRIGGER trg_results_grade_update
BEFORE UPDATE ON results
FOR EACH ROW
BEGIN
    DECLARE percentage DECIMAL(7,2);
    DECLARE max_marks DECIMAL(5,2);
    SELECT total_marks INTO max_marks FROM exams WHERE exam_id = NEW.exam_id;
    IF NEW.marks_obtained > max_marks THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Marks obtained cannot exceed total marks';
    END IF;
    SET percentage = (NEW.marks_obtained / max_marks) * 100;

    IF percentage >= 90 THEN SET NEW.grade = 'A+'; SET NEW.grade_point = 10.00;
    ELSEIF percentage >= 80 THEN SET NEW.grade = 'A'; SET NEW.grade_point = 9.00;
    ELSEIF percentage >= 70 THEN SET NEW.grade = 'B+'; SET NEW.grade_point = 8.00;
    ELSEIF percentage >= 60 THEN SET NEW.grade = 'B'; SET NEW.grade_point = 7.00;
    ELSEIF percentage >= 50 THEN SET NEW.grade = 'C'; SET NEW.grade_point = 6.00;
    ELSEIF percentage >= 40 THEN SET NEW.grade = 'D'; SET NEW.grade_point = 5.00;
    ELSE SET NEW.grade = 'F'; SET NEW.grade_point = 0.00;
    END IF;
END//
DELIMITER ;
