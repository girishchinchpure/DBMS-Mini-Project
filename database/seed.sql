USE sams_db;

INSERT INTO departments (department_code, department_name, hod_name) VALUES
('CSBS','Computer Science and Business Systems','Dr. A. Kulkarni'),
('CSE','Computer Science and Engineering','Dr. S. Patil'),
('ENTC','Electronics and Telecommunication','Dr. R. Joshi');

INSERT INTO faculty (first_name, last_name, email, phone, department_id) VALUES
('Amit','Deshmukh','amit.deshmukh@college.edu','9876543201',1),
('Neha','Sharma','neha.sharma@college.edu','9876543202',1),
('Rohan','Patil','rohan.patil@college.edu','9876543203',2),
('Priya','Joshi','priya.joshi@college.edu','9876543204',3);

INSERT INTO courses (course_code, course_name, credits, semester, department_id, faculty_id) VALUES
('DBMS','Database Management Systems',4.0,3,1,1),
('OOP','Object Oriented Programming',4.0,3,1,2),
('DS','Data Structures',4.0,3,1,2),
('FMBS','Fundamentals of Management and Business Strategy',3.0,3,1,1),
('CN','Computer Networks',4.0,4,2,3),
('DE','Digital Electronics',3.0,3,3,4);

INSERT INTO students (first_name, last_name, dob, gender, email, phone, address, admission_year, department_id) VALUES
('Girish','Kulkarni','2008-01-10','Male','girish.kulkarni@example.com','9000000001','Pune, Maharashtra',2025,1),
('Aarav','Shinde','2007-08-15','Male','aarav.shinde@example.com','9000000002','Pune, Maharashtra',2025,1),
('Ananya','Jadhav','2008-03-21','Female','ananya.jadhav@example.com','9000000003','Nashik, Maharashtra',2025,2),
('Vedant','Pawar','2007-12-02','Male','vedant.pawar@example.com','9000000004','Satara, Maharashtra',2025,2),
('Sana','Shaikh','2008-05-17','Female','sana.shaikh@example.com','9000000005','Pune, Maharashtra',2026,3),
('Riya','Mane','2008-09-12','Female','riya.mane@example.com','9000000006','Kolhapur, Maharashtra',2025,1),
('Atharva','More','2007-11-08','Male','atharva.more@example.com','9000000007','Pune, Maharashtra',2025,1),
('Isha','Desai','2008-02-25','Female','isha.desai@example.com','9000000008','Mumbai, Maharashtra',2025,2);

INSERT INTO enrollments (student_id, course_id, academic_year, semester, enrollment_date) VALUES
(1,1,'2026-27',3,'2026-07-01'),
(1,2,'2026-27',3,'2026-07-01'),
(1,3,'2026-27',3,'2026-07-01'),
(2,1,'2026-27',3,'2026-07-01'),
(2,2,'2026-27',3,'2026-07-01'),
(3,5,'2026-27',4,'2026-07-01'),
(4,5,'2026-27',4,'2026-07-01'),
(5,6,'2026-27',3,'2026-07-01'),
(6,1,'2026-27',3,'2026-07-01'),
(6,4,'2026-27',3,'2026-07-01'),
(7,2,'2026-27',3,'2026-07-01'),
(7,3,'2026-27',3,'2026-07-01'),
(8,5,'2026-27',4,'2026-07-01');

INSERT INTO attendance (enrollment_id, classes_held, classes_attended) VALUES
(1,40,36),(2,42,38),(3,45,41),(4,40,28),(5,42,35),(6,44,40),(7,44,32),
(8,38,35),(9,40,34),(10,40,37),(11,42,39),(12,45,43),(13,44,31);

INSERT INTO exams (course_id, exam_type, exam_date, total_marks) VALUES
(1,'Mid Semester','2026-08-20',100),
(2,'Mid Semester','2026-08-22',100),
(3,'Mid Semester','2026-08-24',100),
(5,'Mid Semester','2026-08-21',100),
(6,'Mid Semester','2026-08-23',100);

INSERT INTO results (student_id, exam_id, marks_obtained) VALUES
(1,1,86),(1,2,91),(1,3,78),(2,1,73),(2,2,82),(3,4,88),(4,4,69),(5,5,94),(6,1,81),(7,2,67),(7,3,75),(8,4,90);
