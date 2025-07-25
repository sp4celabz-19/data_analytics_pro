-- 1. Які клієнти витратили більше середнього значення витрат усіх клієнтів?
--    - Використовує підзапит у WHERE.

CREATE OR REPLACE VIEW total_customer_costs AS
SELECT
    i.customer_id,
    SUM(il.unit_price) AS total_cost
FROM invoice i
JOIN invoice_line il ON il.invoice_id = i.invoice_id
GROUP BY i.customer_id;

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    v.total_cost
FROM customer c
JOIN total_customer_costs v ON c.customer_id = v.customer_id
WHERE v.total_cost > (
    SELECT AVG(total_cost) FROM total_customer_costs
)
ORDER BY v.total_cost DESC;


-- 2. Які клієнти приносять найбільше доходу, і які серед них улюблені жанри?
--    - Визначити топ 10 клієнтів за загальною сумою покупок
--    - Для цих клієнтів — з’ясувати, які жанри вони купують
--    - Отримати топ 5 жанрів по кількості топ клієнтів, які слухають цей жанр.

CREATE OR REPLACE VIEW top10_customer_costs AS
SELECT
    c.customer_id,
    v.total_cost,
    c.first_name,
    c.last_name
FROM customer c
JOIN total_customer_costs v ON c.customer_id = v.customer_id
ORDER BY total_cost DESC LIMIT 10;

-- SELECT * FROM top10_customer_costs;

CREATE OR REPLACE VIEW top10_customer_genres AS
SELECT
    tcc.customer_id,
    tcc.total_cost,
    tcc.first_name,
    tcc.last_name,
    g.name AS genre_name
FROM invoice_line il
JOIN invoice i ON i.invoice_id = il.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN genre g ON g.genre_id = t.genre_id
JOIN top10_customer_costs tcc ON tcc.customer_id = i.customer_id
GROUP BY
    tcc.customer_id,
    tcc.first_name,
    tcc.last_name,
    g.name,
    tcc.total_cost
ORDER BY tcc.total_cost DESC;

SELECT
    customer_id,
    first_name,
    last_name,
    genre_name
FROM top10_customer_genres;

SELECT
    genre_name,
    COUNT(DISTINCT customer_id) AS genre_count
FROM top10_customer_genres
GROUP BY genre_name
ORDER BY genre_count DESC LIMIT 5;


-- 3. Які альбоми купують найчастіше, і чи залежить це від жанру?
--    - Знайти альбоми (10) з найбільшою кількістю продажів.
--    - Перевірити, які жанри представлені серед цих альбомів.
--    - Зрозуміти, чи деякі з цих жанри частіше зустрічаються.

-- Популярность, уровень спроса на альбом зависит от жанра. Чаще всего встречаются альбомы в жанрах Rock и Latin.

CREATE OR REPLACE VIEW top10_albums AS
SELECT
    t.album_id,
    al.title AS album_title,
    ar.name AS artist,
    COUNT(il.unit_price) AS album_sales_numb
FROM track t
JOIN invoice_line il ON il.track_id = t.track_id
JOIN album al ON al.album_id = t.album_id
JOIN artist ar ON ar.artist_id = al.artist_id
GROUP BY t.album_id, al.title, ar.name
ORDER BY album_sales_numb DESC LIMIT 10;

SELECT * FROM top10_albums;

SELECT
    g.name AS genre_name,
    COUNT(*) AS genre_count
FROM track t
JOIN genre g ON g.genre_id = t.genre_id
JOIN top10_albums ta ON ta.album_id = t.album_id
GROUP BY g.name
ORDER BY genre_count DESC;


-- 4. Чи приносять альбоми з треками кількох жанрів більше доходу, ніж альбоми з треками лише одного жанру?
--    - Визначте, скільки різних жанрів має кожен альбом
--    - Обчисліть дохід, отриманий від кожного альбому
--    - Порівняйте середній дохід між альбомами з 1, 2, 3,... жанрами.

-- Альбомы с количеством треков больше одного жанра приносят больше дохода, чем альбомы с треками только одного жанра.
-- Исходя из наблюдений ниже, видно что альбомы с треками одного жанра имеют самый низкий средний уровень дохода (6 %
-- от общего среднего дохода) по сравнению с альбомами, в которых присутствуют 2 и 3 жанра (31 % и 62 % соответственно).

CREATE OR REPLACE VIEW albums_genres AS
SELECT
    t.album_id,
    ar.name AS artist,
    al.title AS album_title,
    g.name AS album_genre
FROM track t
JOIN album al ON al.album_id = t.album_id
JOIN artist ar ON ar.artist_id = al.artist_id
JOIN genre g ON g.genre_id = t.genre_id
GROUP BY t.album_id, ar.name, al.title, g.name;

-- SELECT * FROM albums_genres;

CREATE OR REPLACE VIEW genres_sales_quantity AS
SELECT
    ag.album_id,
    ag.artist,
    ag.album_title,
    COUNT(DISTINCT ag.album_genre) AS genres_amount,
    SUM(il.unit_price) AS album_sales_number
FROM albums_genres ag
JOIN track t ON t.album_id = ag.album_id
JOIN invoice_line il ON il.track_id = t.track_id
GROUP BY ag.album_id, ag.artist, ag.album_title
ORDER BY album_sales_number DESC;

-- SELECT * FROM genres_sales_quantity;

SELECT
    genres_amount,
    ROUND(AVG(album_sales_number), 2) AS avg_album_sales,
    ROUND(AVG(album_sales_number) * 100.0 / SUM(AVG(album_sales_number))OVER ()) AS percent_of_total
FROM genres_sales_quantity
GROUP BY genres_amount
ORDER BY genres_amount ASC;