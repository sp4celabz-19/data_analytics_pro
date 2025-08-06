DROP TABLE IF EXISTS anna_events CASCADE;


-- Create table
CREATE TABLE anna_events (
    event_id SERIAL PRIMARY KEY,
    event_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    priority INTEGER
);

-- Insert data
INSERT INTO anna_events (event_name, start_date, end_date, priority) VALUES
('Teaching Course', '2025-07-01', '2025-07-07', 2),
('Online Bootcamp', '2025-07-05', '2025-07-16', 3),
('Vacation', '2025-07-12', '2025-07-18', 4),
('Work Trip', '2025-07-16', '2025-07-21', 1),
('Mom’s Birthday Week', '2025-07-23', '2025-07-25', 1),
('Teaching Course 2', '2025-07-27', '2025-08-01', 2),
('Language Workshop', '2025-07-30', '2025-08-04', 3),
('Conference', '2025-08-06', '2025-08-15', 2),
('Weekend Getaway', '2025-08-10', '2025-08-14', 4),
('Hobby Workshop', '2025-08-20', '2025-08-26', 5);


-- Рівень 1: "Без конфліктів"
-- Мета: Виведіть лише ті події, які не перекриваються з жодною іншою.

SELECT *
FROM anna_events ae1
WHERE NOT EXISTS (
    SELECT 1
    FROM anna_events ae2
    WHERE ae1.event_id <> ae2.event_id
    AND ae1.start_date < ae2.end_date
    AND ae1.end_date > ae2.start_date
);


-- Рівень 2: "Підрізка по часу"
-- Мета: Якщо події перекриваються, обрізайте кінець першої події до початку наступної (у день перед початком наступної).

UPDATE anna_events ae1
SET end_date = (
    SELECT MIN(ae2.start_date) - INTERVAL '1 day'
    FROM anna_events ae2
    WHERE ae1.event_id <> ae2.event_id
      AND ae1.start_date < ae2.start_date
      AND ae1.end_date > ae2.start_date
)
WHERE EXISTS (
    SELECT 1
    FROM anna_events ae2
    WHERE ae1.event_id <> ae2.event_id
      AND ae1.start_date < ae2.start_date
      AND ae1.end_date > ae2.start_date
);

-- SELECT * FROM anna_events
-- ORDER BY event_id ASC;


-- Рівень 3: "Перевага пріоритету"
-- Мета: Залишити події з вищим пріоритетом, а нижчі обрізати або повністю видалити, якщо вони повністю перекриті.

DELETE FROM anna_events ae1
WHERE EXISTS (
    SELECT 1
    FROM anna_events ae2
    WHERE ae1.event_id <> ae2.event_id
      AND ae1.priority > ae2.priority
      AND ae1.start_date >= ae2.start_date
      AND ae1.end_date <= ae2.end_date
);

UPDATE anna_events ae1
SET start_date = ae2.end_date + INTERVAL '1 day'
FROM anna_events ae2
WHERE ae1.event_id <> ae2.event_id
  AND ae1.priority > ae2.priority
  AND ae1.start_date < ae2.end_date
  AND ae1.end_date > ae2.end_date
  AND ae1.start_date >= ae2.start_date;

UPDATE anna_events ae1
SET end_date = ae2.start_date - INTERVAL '1 day'
FROM anna_events ae2
WHERE ae1.event_id <> ae2.event_id
  AND ae1.priority > ae2.priority
  AND ae1.end_date >= ae2.start_date
  AND ae1.start_date < ae2.start_date;


-- SELECT * FROM anna_events ORDER BY event_id;
