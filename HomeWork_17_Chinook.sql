-- 1. Які треки були куплені найчастіше в кожному жанрі (по 1 треку на жанр)? Це допомагає зрозуміти «хіти» жанру —
--    хороші кандидати для плейлистів, реклами або рекомендацій.
--    - об'єднуємо таблиці треків, жанрів та продажів і підсумовуємо кількість куплених копій (SUM(il.Quantity)) для
--      кожного треку
--    - застосовуємо ROW_NUMBER()  або DISTINCT ON

CREATE OR REPLACE VIEW purchased_tracks_number AS
SELECT
    t.track_id,
    t.name AS track_name,
    t.genre_id,
    g.name AS genre_name,
    COUNT(il.unit_price) AS copies_purchased
FROM track t
JOIN invoice_line il ON il.track_id = t.track_id
JOIN genre g ON g.genre_id = t.genre_id
GROUP BY t.track_id, t.name, t.genre_id, g.name
ORDER BY copies_purchased DESC;

SELECT
    genre_name,
    track_name,
    copies_purchased
FROM (
    SELECT
        genre_name,
        track_name,
        copies_purchased,
        ROW_NUMBER() OVER (PARTITION BY genre_name ORDER BY copies_purchased DESC) AS row_num
    FROM purchased_tracks_number
) top_tracks
WHERE row_num = 1
ORDER BY copies_purchased DESC;


-- 2. Знайди артистів, чиї альбоми не містять жодного треку, який було куплено хоча б один раз. Які артисти
--    "не приносять грошей взагалі"
--    - Для кожного артиста перевіряємо, чи існує хоч один куплений трек цього артиста
--    - Використовуємо NOT EXISTS з корельованим підзапитом або JOIN

CREATE OR REPLACE VIEW music_sales AS
SELECT
    ar.artist_id,
    ar.name AS artist_name
FROM artist ar
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY ar.artist_id, ar.name;

SELECT
    ar.artist_id,
    ar.name AS artist_name
FROM artist ar
WHERE ar.artist_id NOT IN (
    SELECT artist_id FROM music_sales
)
ORDER BY ar.name ASC;


-- 3. Аналіз витрат клієнтів у часі. Для кожного клієнта показати, як змінювались його витрати з кожною покупкою:
--    - Послідовний номер інвойсу
--    - Загальна сума кожного інвойсу
--    - Кумулятивна сума витрат клієнта на кожну дату
--    - Рухоме середнє витрат за останні 3 інвойси
--    - Дата інвойсу
--
--   3.2 Об’єднай клієнтів з інвойсами та рядками інвойсів
--   3.3 Обчисли загальну суму кожного інвойсу
--   3.4 Застосуй кумулятивну суму, рухоме середнє та ранжування

CREATE VIEW invoice_totals AS
SELECT
    i.invoice_id,
    i.customer_id,
    i.invoice_date,
    SUM(il.unit_price * il.quantity) AS invoice_total
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY i.invoice_id, i.customer_id, i.invoice_date;

SELECT
    it.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    it.invoice_id,
    it.invoice_date,
    ROW_NUMBER() OVER (
        PARTITION BY it.customer_id
        ORDER BY it.invoice_date
    ) AS invoice_number,
    it.invoice_total,
    SUM(it.invoice_total) OVER (
        PARTITION BY it.customer_id
        ORDER BY it.invoice_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sum,
    ROUND(AVG(it.invoice_total) OVER (
        PARTITION BY it.customer_id
        ORDER BY it.invoice_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_costs
FROM invoice_totals it
JOIN customer c ON it.customer_id = c.customer_id
ORDER BY it.customer_id, it.invoice_date;


-- 4. Для кожного менеджера: як змінювались середні витрати клієнтів по кварталах — чи зростали/падали?
--   4.1 Почни з базового з'єднання таблиць employee, customer, invoice та invoice_line, щоб зв’язати менеджера з
--       транзакціями клієнтів.
--   4.2 Використай DATE_TRUNC('quarter', invoice_date) для визначення кварталу кожної покупки.
--   4.3 Згрупуй дані за employee_id та кварталом. Обчисли:
--       - загальну суму продажів
--       - кількість клієнтів
--       - середню суму витрат на клієнта
--   4.4 Використай цей результат як CTE щоб ізольовано працювати з агрегованими даними.
--   4.5 У другому CTE, застосуй віконну функцію LAG() до середньої суми витрат на клієнта, щоб отримати значення за
--       попередній квартал для кожного працівника.
--   4.6 Обчисли зміну (change) як різницю між поточним і попереднім значенням.
--   4.7 За допомогою CASE класифікуй кожен квартал за трендом: зростання, спад чи без змін. Виведи результат з
--       відформатованою назвою кварталу (TO_CHAR) та відсортуй за працівником і часом.

CREATE OR REPLACE VIEW manager_client_transactions AS
SELECT
    e.employee_id AS manager_id,
    e.first_name || ' ' || e.last_name AS manager_name,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    i.invoice_id,
    i.invoice_date,
    i.total AS invoice_total,
    il.invoice_line_id,
    il.track_id,
    il.unit_price,
    il.quantity,
    (il.unit_price * il.quantity) AS line_total
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id;

CREATE OR REPLACE VIEW invoices_quarters AS
SELECT
    mct.manager_id AS manager_id,
    mct.manager_name AS manager_name,
    mct.customer_name AS customer_name,
    DATE_TRUNC('quarter', mct.invoice_date) AS purchase_quarter,
    SUM(line_total) AS total_sales
FROM manager_client_transactions mct
GROUP BY manager_id, manager_name, customer_name, purchase_quarter
ORDER BY manager_name, customer_name, purchase_quarter ASC;

SELECT
    manager_id,
    manager_name,
    purchase_quarter,
    COUNT(DISTINCT customer_name) AS customers_number,
    SUM(total_sales) AS quarterly_sales,
    ROUND((SUM(total_sales) / COUNT(DISTINCT customer_name)), 2) AS avg_cost_per_client
FROM invoices_quarters
GROUP BY manager_id, manager_name, purchase_quarter
ORDER BY manager_id, purchase_quarter;

WITH aggregated_sales AS (
    SELECT
        manager_id,
        manager_name,
        purchase_quarter,
        COUNT(DISTINCT customer_name) AS customers_number,
        SUM(total_sales) AS quarterly_sales,
        ROUND(SUM(total_sales) / COUNT(DISTINCT customer_name), 2) AS avg_cost_per_client
    FROM invoices_quarters
    GROUP BY manager_id, manager_name, purchase_quarter
)
SELECT
    *,
    CASE
        WHEN change IS NULL THEN 'no data'
        WHEN change < -0.01 THEN 'decline'
        WHEN change BETWEEN -0.01 AND 0.1 THEN 'no change'
        ELSE 'growth'
    END AS trend
FROM (
    SELECT
        manager_id,
        manager_name,
        TO_CHAR(purchase_quarter, '"Q"Q YYYY') AS formatted_quarter,
        purchase_quarter,
        customers_number,
        quarterly_sales,
        avg_cost_per_client,
        ROUND(avg_cost_per_client - LAG(avg_cost_per_client) OVER (
            PARTITION BY manager_id
            ORDER BY purchase_quarter
        ), 2) AS change
    FROM aggregated_sales
) sub
ORDER BY manager_id, purchase_quarter;
