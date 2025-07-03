DROP TABLE IF EXISTS studentstable;

CREATE TABLE studentstable (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(50),
    email VARCHAR(100),
    signup_date DATE,
    last_login TIMESTAMP,
    is_active BOOLEAN,
    gpa NUMERIC(3,2),
    enrolled_classes TEXT,
    scholarships TEXT
);


insert into studentstable (id, full_name, email, signup_date, last_login, is_active, gpa, enrolled_classes, scholarships)
values
    (1, 'Alice Johnson', 'alice.j@example.com',	'2024-09-01', '2025-06-28 14:30:00', TRUE, 3.85, '{CS101,MATH202,ENG150}', '{Merit Scholarship}'),
    (2, 'Bob Smith', 'bob.smith@example.com', '2024-09-03',	'2025-06-30 09:10:00', FALSE, 2.95,	'{HIST110,PHIL101}', '{}'),
    (3, 'Carlos Nguyen', 'carlos.n@example.com', '2024-10-15', '2025-06-20 19:45:00', TRUE, 3.45, '{CS101,STAT200,PHYS105}', '{STEM Grant}'),
    (4, 'Diana Petrova', 'diana.p@example.com',	'2024-11-01', NULL, NULL, 4, '{ART101,DES202}',	'{Dean''s List}'),
    (5, 'Evan Lee',	'evan.l@example.com', '2025-01-20',	'2025-06-25 08:00:00', TRUE, 3,	'{MATH101,CS101}', '{}'),
    (6, 'Fatima Ali', 'fatima.a@example.com', '2025-02-10',	'2025-06-27 11:22:00', TRUE, 3.75, '{ECON101,BUS200}', '{Leadership Award,Women in Business}'),
    (7, 'George Novak',	'george.n@example.com',	'2025-03-01', '2025-06-29 15:00:00', TRUE, 2.65, '{BIO101}', '{Athletic Scholarship}');


-- Імена активних студентів у нижньому регістрі
SELECT LOWER(full_name) FROM studentstable WHERE is_active;

-- Email та округлене значення GPA (до 1 знаку), де GPA більше 3.5
SELECT email, ROUND(gpa, 1) FROM studentstable WHERE gpa > 3.5;

-- Ім’я та дата реєстрації у форматі"dd.mm.yyyy', для студентів, що зареєструвалися після '2025-01-01'
SELECT full_name, TO_CHAR(signup_date, 'DD.MM.YYYY') FROM studentstable WHERE signup_date > '2025-01-01';


-- Ім’я та кількість стипендій для тих студентів, у яких є стипендії
SELECT
    full_name,
    scholarships,
    CARDINALITY(string_to_array(trim(both '{}' FROM scholarships), ',')) AS scholarship_count
FROM
    studentstable
WHERE
    CARDINALITY(string_to_array(trim(both '{}' FROM scholarships), ',')) > 0;


-- Ім’я та кількість курсів, для студентів, які записані на курс 'CS101'
SELECT
    full_name,
    CARDINALITY(string_to_array(trim(both '{}' FROM enrolled_classes), ',')) AS courses_count
FROM
    studentstable
WHERE
    'CS101' = ANY(string_to_array(trim(both '{}' FROM enrolled_classes), ','));
