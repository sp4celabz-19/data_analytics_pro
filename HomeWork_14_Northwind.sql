-- 1. Які категорії товарів є найрізноманітнішими?
--    Перелічіть категорії з більш ніж 10 різними товарами — це може вимагати цілеспрямованого управління запасами.

-- SELECT
--     c.category_name AS category_name,
--     COUNT(*) AS product_amount
-- FROM products p
-- JOIN categories c ON c.category_id = p.category_id
-- GROUP BY p.category_id, c.category_name
-- HAVING COUNT(*) > 10
-- ORDER BY product_amount DESC;


-- 2. Як наші постачальники порівнюються у ціновій стратегії?
--    Для кожного постачальника розрахуйте середню ціну на продукцію та класифікуйте їх як «Бюджетний», «Стандартний»
--    або «Преміальний».

-- SELECT
--     s.company_name AS supplier_name,
--     ROUND(AVG(p.unit_price)) AS average_price,
--     CASE
--         WHEN AVG(p.unit_price) < FLOOR(0.33 * MAX(AVG(p.unit_price)) OVER ()) THEN 'budget'
--         WHEN AVG(p.unit_price) < FLOOR(0.66 * MAX(AVG(p.unit_price)) OVER ()) THEN 'standard'
--         ELSE 'premium'
--     END AS price_category
-- FROM products p
-- JOIN suppliers s ON s.supplier_id = p.supplier_id
-- GROUP BY s.supplier_id, s.company_name
-- ORDER BY average_price DESC;


-- 3. Які співробітники обробляють найбільше замовлень?
--    Перелічіть співробітників, які обробили понад 100 замовлень — це ключовий фактор для оцінки ефективності роботи
--    або виплати бонусів.

-- SELECT
--     e.last_name,
--     e.first_name,
--     COUNT(o.order_id) AS order_amount
-- FROM employees e
-- JOIN orders o ON o.employee_id = e.employee_id
-- GROUP BY e.employee_id, e.last_name, e.first_name
-- HAVING COUNT(o.order_id) > 100
-- ORDER BY order_amount DESC;


-- 4. Які регіони клієнтів є найприбутковішими?
--    Показати загальну кількість замовлень та загальну вартість перевезення по країнах — це допомагає визначити
--    сильні регіональні ринки.

-- SELECT
--     ship_country AS country,
--     COUNT(*) AS orders_amount,
--     ROUND(SUM(freight)) AS total_freight
-- FROM orders
-- GROUP BY ship_country
-- ORDER BY orders_amount DESC;


-- 5. Чи достатньо у нас запасів для кожного товару?
--    Розподіліть товари за рівнем запасів на категорії «Низький», «Середній» або «Високий».

-- SELECT
--     product_name,
--     units_in_stock,
--     CASE
--         WHEN units_in_stock < FLOOR(0.33 * MAX(units_in_stock) OVER ()) THEN 'low'
--         WHEN units_in_stock < FLOOR(0.66 * MAX(units_in_stock) OVER ()) THEN 'standard'
--         ELSE 'high'
--     END AS stock_level
-- FROM products
-- ORDER BY units_in_stock DESC;
