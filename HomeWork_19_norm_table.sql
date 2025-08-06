DROP TABLE IF EXISTS grades CASCADE;
DROP TABLE IF EXISTS enrollments CASCADE;
DROP TABLE IF EXISTS course_instructors CASCADE;
DROP TABLE IF EXISTS instructors CASCADE;
DROP TABLE IF EXISTS homeworks CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS hw_table_1nf CASCADE;


CREATE TABLE hw_table_1nf AS
SELECT
    student_id,
    student_name,
    student_email,
    course_id,
    course_name,
    instructor_1_name AS instructor_name,
    instructor_1_email AS instructor_email,
    class_date,
    REGEXP_REPLACE(homework_id, '[^0-9]', '', 'g')::INT AS homework_id,
    homework_description,
    grade
FROM hw_19_table
WHERE instructor_1_name IS NOT NULL

UNION ALL

SELECT
    student_id,
    student_name,
    student_email,
    course_id,
    course_name,
    instructor_2_name AS instructor_name,
    instructor_2_email AS instructor_email,
    class_date,
    REGEXP_REPLACE(homework_id, '[^0-9]', '', 'g')::INT AS homework_id,
    homework_description,
    grade
FROM hw_19_table
WHERE instructor_2_name IS NOT NULL;


CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name TEXT NOT NULL,
    student_email TEXT NOT NULL
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name TEXT NOT NULL
);

CREATE TABLE instructors (
    instructor_id SERIAL PRIMARY KEY,
    instructor_name TEXT NOT NULL,
    instructor_email TEXT NOT NULL
);

CREATE TABLE course_instructors (
    course_id INT NOT NULL REFERENCES courses(course_id),
    instructor_id INT NOT NULL REFERENCES instructors(instructor_id),
    PRIMARY KEY (course_id, instructor_id)
);

CREATE TABLE enrollments (
    student_id INT NOT NULL REFERENCES students(student_id),
    course_id INT NOT NULL REFERENCES courses(course_id),
    PRIMARY KEY (student_id, course_id)
);

CREATE TABLE homeworks (
    homework_id INT PRIMARY KEY,
    homework_description TEXT NOT NULL
);

CREATE TABLE grades (
    student_id INT NOT NULL REFERENCES students(student_id),
    course_id INT NOT NULL REFERENCES courses(course_id),
    class_date DATE NOT NULL,
    homework_id INT NOT NULL REFERENCES homeworks(homework_id),
    grade NUMERIC(5,2) NOT NULL CHECK (grade >= 0 AND grade <= 100),
    PRIMARY KEY (student_id, course_id, homework_id)
);


INSERT INTO students (student_id, student_name, student_email)
SELECT DISTINCT student_id, student_name, student_email
FROM hw_table_1nf;

INSERT INTO courses (course_id, course_name)
SELECT DISTINCT course_id, course_name
FROM hw_table_1nf;

INSERT INTO instructors (instructor_name, instructor_email)
SELECT DISTINCT instructor_name, instructor_email
FROM hw_table_1nf;

INSERT INTO course_instructors (course_id, instructor_id)
SELECT DISTINCT h.course_id, i.instructor_id
FROM hw_table_1nf h
JOIN instructors i ON h.instructor_name = i.instructor_name AND h.instructor_email = i.instructor_email;

INSERT INTO enrollments (student_id, course_id)
SELECT DISTINCT student_id, course_id
FROM hw_table_1nf;

INSERT INTO homeworks (homework_id, homework_description)
SELECT DISTINCT
    homework_id,
    homework_description
FROM hw_table_1nf
WHERE homework_description IS NOT NULL;

INSERT INTO grades (student_id, course_id, class_date, homework_id, grade)
SELECT
    student_id,
    course_id,
    MIN(class_date::date) AS class_date,
    homework_id,
    MAX(REPLACE(grade, ',', '.')::NUMERIC(5,2)) AS grade
FROM hw_table_1nf
WHERE class_date IS NOT NULL AND grade IS NOT NULL
GROUP BY student_id, course_id, homework_id;


--------------------------------
-- Первая нормальная форма (1NF)
-- В исходной таблице были две колонки для преподавателей: instructor_1 и instructor_2, а это повторяющаяся группа.
-- Также в поле homework_id встречались разные форматы.
-- Чтобы привести таблицу к 1NF, я разделил преподавателей на отдельные строки (через UNION ALL), а также преобразовал
-- homework_id, убрав из него символы, оставив только цифры.


--------------------------------
-- Вторая нормальная форма (2NF)
-- Дальше я заметил, что некоторые поля (например, student_name, course_name, homework_description) зависят только
-- от части ключа, а не от всей строки.
-- Для того чтобы это исправить, я вынес студентов в отдельную таблицу students, курсы - в таблицу courses, и домашние
-- задания - в homeworks. Данные с преподавателями также вынес отдельно в таблицу instructors, и связал их с курсами
-- при помощи таблицы course_instructors. Также на этом этапе создаётся таблица enrollments, для того чтобы показать,
-- какие студенты на какие курсы записаны.
-- В результате каждая таблица теперь будет содержать данные, которые будут зависеть только от своего ключа.


--------------------------------
-- Третья нормальная форма (3NF)
-- На этом этапе я убрал транзитивные зависимости.
-- Поле homework_description зависит не от всей строки (student_id, course_id, homework_id), а только от homework_id.
-- Это и есть транзитивная зависимость. Её я устранил, когда вынес домашки в отдельную таблицу homeworks,
-- а в таблице grades оставил только внешнюю ссылку (FOREIGN KEY) на homework_id.
-- В результате таблица grades содержит только факты (кто, по какому курсу, какую домашку сдал и какую оценку получил),
-- и структура теперь соответствует третьей нормальной форме.
