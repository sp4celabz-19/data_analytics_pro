-- 1.У які музичні жанри нам слід більше інвестувати? Порахувати прибуток по кожному жанру та визначити
--   найприбутковіші.

-- SELECT
--     t.genre_id,
--     g.name,
--     SUM(i.unit_price) AS profit
-- FROM track t
-- JOIN invoice_line i ON i.track_id = t.track_id
-- JOIN genre g ON g.genre_id = t.genre_id
-- GROUP BY t.genre_id, g.name
-- ORDER BY profit DESC;


--  2.Які країни приносять найбільше доходу, і чи маємо ми там достатню кількість клієнтів? Порівняти дохід з кожної
--    країни та кількість клієнтів у ній.

-- SELECT
--     c.country,
--     COUNT(c.customer_id) AS customers_amount,
--     SUM(il.unit_price) AS profit
-- FROM customer c
-- JOIN invoice i ON i.customer_id = c.customer_id
-- JOIN invoice_line il ON il.invoice_id = i.invoice_id
-- GROUP BY c.country
-- ORDER BY profit DESC;


--  3.Які клієнти не роблять покупки, хоч і були активні раніше? Знайти клієнтів, які більше не роблять покупок — тобто
--    остання покупка була давно (наприклад, до початку 2025 року).

-- SELECT
--     i.customer_id,
--     c.first_name,
--     c.last_name,
--     MAX(i.invoice_date) AS last_invoice_date
-- FROM invoice i
-- JOIN customer c ON c.customer_id = i.customer_id
-- GROUP BY i.customer_id, c.first_name, c.last_name
-- HAVING MAX(i.invoice_date) < '2025-01-01'
-- ORDER BY last_invoice_date DESC;


--  4.Які треки ніколи не продавалися? Визначити треки, які не з’являються в жодному продажі.

-- SELECT t.track_id, t.name
-- FROM track t
-- LEFT JOIN invoice_line il ON t.track_id = il.track_id
-- WHERE il.track_id IS NULL;


--  5.Який артист має найбільше треків у магазині? Порахувати кількість треків у кожного артиста.

-- SELECT
--     ar.artist_id,
--     ar.name AS artist,
--     COUNT(tr.track_id) AS track_amount
-- FROM artist ar
-- JOIN album al ON al.artist_id = ar.artist_id
-- JOIN track tr ON tr.album_id = al.album_id
-- GROUP BY ar.artist_id, ar.name
-- ORDER BY track_amount DESC;


-- 6.Які жанри приносять найбільший середній дохід на одного клієнта в кожній країні? Поєднати жанри, треки, покупки
--   клієнтів і країни, щоб оцінити, які жанри є найвигіднішими з урахуванням розподілу клієнтів по країнах.
--   Відсортувати по країнах та прибутку на користувача.

-- SELECT
--     c.country,
--     g.name AS genre_name,
--     ROUND(SUM(il.unit_price) / COUNT(DISTINCT c.customer_id), 2) AS avg_profit_per_customer
-- FROM genre g
-- JOIN track t ON g.genre_id = t.genre_id
-- JOIN invoice_line il ON t.track_id = il.track_id
-- JOIN invoice i ON il.invoice_id = i.invoice_id
-- JOIN customer c ON i.customer_id = c.customer_id
-- GROUP BY c.country, g.name
-- ORDER BY c.country ASC, avg_profit_per_customer DESC;
