-- 1. Які альбоми достатньо великі, щоб виправдати вищу ціну?
--    Перелічіть назви альбомів з 5 або більше треками — вони можуть бути кандидатами на преміальну ціну.

-- SELECT
--     ar.name AS artist_name,
--     a.title AS album_title,
--     a.album_id,
--     COUNT(t.track_id) AS track_count
-- FROM album a
-- JOIN artist ar ON a.artist_id = ar.artist_id
-- LEFT JOIN track t ON a.album_id = t.album_id
-- GROUP BY a.album_id, a.title, ar.name
-- HAVING COUNT(t.track_id) > 5
-- ORDER BY track_count DESC;


-- 2. Як географічно розподілена наша клієнтська база?
--    Порахуйте кількість клієнтів у кожній країні. Додайте поле для позначення типу країни в залежності від кількості
--    клієнтів (Мала, Середня, Цільова)

-- SELECT
--     country,
--     COUNT(*) AS client_count,
--     CASE
--         WHEN COUNT(*) < FLOOR(0.33 * MAX(COUNT(*)) OVER ()) THEN 'small'
--         WHEN COUNT(*) < FLOOR(0.66 * MAX(COUNT(*)) OVER ()) THEN 'middle'
--         ELSE 'large'
--     END AS client_category
-- FROM customer
-- GROUP BY country
-- ORDER BY client_count DESC;


-- 3. Які музичні жанри мають найдовшу середню тривалість треків?
--    Визначте жанри, де середня тривалість треків перевищує 250 000 мс — корисно для планування списків відтворення
--    або ліцензування.

-- SELECT
--     g.genre_id,
--     g.name AS genre_name,
--     ROUND(AVG(t.milliseconds)) AS avg_track_length
-- FROM track t
-- JOIN genre g ON t.genre_id = g.genre_id
-- GROUP BY g.genre_id, g.name
-- HAVING AVG(t.milliseconds) > 250000
-- ORDER BY avg_track_length DESC;


--  4. Які представники служби підтримки мають найбільше клієнтів?
--     Використовуючи таблицю Клієнти, підрахуйте, скільки клієнтів призначено кожному представнику служби підтримки
--     (за допомогою поля «SupportRepId»). Це допомагає визначити розподіл робочого навантаження між співробітниками.

-- SELECT
--     c.support_rep_id AS support_id,
--     e.last_name,
--     e.first_name,
--     e.title AS employee_position,
--     COUNT(c.support_rep_id) AS customer_amount
-- FROM customer c
-- JOIN employee e ON e.employee_id = c.support_rep_id
-- GROUP BY c.support_rep_id, e.last_name, e.first_name, e.title
-- ORDER BY customer_amount DESC;


-- 5. Хто наші найцінніші клієнти?
--    Для кожного клієнта вкажіть його загальні витрати та кількість покупок. Відфільтруйте, щоб отримати тих, хто
--    витратив понад 20 (понад 40 в моєму прикладі) доларів.

-- SELECT
--     i.customer_id,
--     c.first_name,
--     c.last_name,
--     COUNT(i.customer_id) AS purchase_amount,
--     SUM(i.total) AS total_costs
-- FROM invoice i
-- JOIN customer c ON c.customer_id = i.customer_id
-- GROUP BY i.customer_id, c.first_name, c.last_name
-- HAVING SUM(i.total) > 40
-- ORDER BY total_costs DESC;
