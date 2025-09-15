CREATE OR REPLACE VIEW v_daily_agg AS
SELECT
    d.date,
    u.group_id,
    g.group_label,
    COUNT(DISTINCT d.user_id) AS total_users,
    COUNT(DISTINCT CASE WHEN d.converted = 1 THEN d.user_id END) AS converted_users,
    ROUND(
        COUNT(DISTINCT CASE WHEN d.converted = 1 THEN d.user_id END)::numeric /
        NULLIF(COUNT(DISTINCT d.user_id), 0), 4
    ) AS conversion_rate
FROM
    daily d
JOIN
    "user" u ON d.user_id = u.user_id
JOIN
    "group" g ON u.group_id = g.group_id
GROUP BY
    d.date, u.group_id, g.group_label
ORDER BY
    d.date, u.group_id;


CREATE OR REPLACE VIEW v_group_summary AS
SELECT
    u.group_id,
    g.group_label,
    COUNT(DISTINCT u.user_id) AS users_count,
    ROUND(AVG(u.days_on_product), 2) AS avg_days_on_product,
    ROUND(
        COUNT(DISTINCT CASE WHEN d.converted = 1 THEN d.user_id END)::numeric /
        NULLIF(COUNT(DISTINCT d.user_id), 0), 4
    ) AS conversion_rate
FROM "user" u
JOIN "group" g ON u.group_id = g.group_id
LEFT JOIN daily d ON u.user_id = d.user_id
GROUP BY u.group_id, g.group_label;


CREATE OR REPLACE VIEW v_users_summary AS
WITH daily_agg AS (
    SELECT
        user_id,
        COUNT(date) AS active_days,
        SUM(converted) AS total_converted
    FROM daily
    GROUP BY user_id
)
SELECT
    u.user_id,
    u.device_id,
    d.device_name,
    u.country_id,
    c.country_code,
    u.group_id,
    g.group_label,
    u.days_on_product,
    COALESCE(da.active_days, 0) AS active_days,
    COALESCE(da.total_converted, 0) AS total_converted
FROM "user" u
LEFT JOIN daily_agg da ON u.user_id = da.user_id
LEFT JOIN device d ON u.device_id = d.device_id
LEFT JOIN country c ON u.country_id = c.country_id
LEFT JOIN "group" g ON u.group_id = g.group_id;


-- 1.Рассчитать конверсию для каждой группы
SELECT
    group_label,
    users_count,
    conversion_rate
FROM v_group_summary;


-- 2.Рассчитать разницу (lift) между группами
WITH conv AS (
    SELECT
        group_label,
        conversion_rate
    FROM v_group_summary
)
SELECT
    ROUND((b.conversion_rate - a.conversion_rate)::numeric, 4) AS absolute_lift,
    ROUND(((b.conversion_rate - a.conversion_rate) / a.conversion_rate * 100)::numeric, 2) AS relative_lift_percent
FROM
    conv a
JOIN
    conv b ON a.group_label = 'A' AND b.group_label = 'B';
