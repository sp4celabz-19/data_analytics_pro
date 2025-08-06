-- 1.Создаётся таблица results_comparison с необходимыми полями. С помощью процедуры metrics_comparison происходит
--   заполнение созданной таблицы данными из таблиц metrics_a и metrics_b, рассчитывается на сколько процентов
--   произошло изменение каждой метрики по каждому id, результат данного расчёта заносится в столбец diff_pct,
--   далее результат сравнивается с допустимым отклонением, данные по которому взяты из таблицы thresholds, в столбце
--   exceeds_limit указывается 'yes' в случае достижения лимита, и 'no' если лимит не достигнут или равен значению
--   полученного изменения.


DROP TABLE IF EXISTS results_comparison CASCADE;


CREATE TABLE results_comparison (
    id INTEGER,
    metric TEXT,
    value_a DECIMAL(10, 2),
    value_b DECIMAL(10, 2),
    diff_pct DECIMAL(10, 2),
    threshold INTEGER,
    exceeds_limit TEXT
);


CREATE OR REPLACE PROCEDURE metrics_comparison()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE results_comparison;

  INSERT INTO results_comparison
  SELECT
      id,
      'revenue',
      a.revenue,
      b.revenue,
      ROUND(ABS(a.revenue - b.revenue) / GREATEST(a.revenue, b.revenue) * 100, 2),
      t.max_diff_pct,
      CASE
          WHEN ROUND(ABS(a.revenue - b.revenue) / GREATEST(a.revenue, b.revenue) * 100, 2) > t.max_diff_pct THEN 'yes'
          ELSE 'no'
      END
  FROM metrics_a a
  JOIN metrics_b b USING (id)
  JOIN thresholds t ON t.metric = 'revenue'

  UNION ALL

  SELECT
      id,
      'clicks',
      a.clicks,
      b.clicks,
      ROUND(ABS(a.clicks - b.clicks) / GREATEST(a.clicks, b.clicks)::NUMERIC * 100, 2),
      t.max_diff_pct,
      CASE
          WHEN ROUND(ABS(a.clicks - b.clicks) / GREATEST(a.clicks, b.clicks)::NUMERIC * 100, 2) > t.max_diff_pct THEN 'yes'
          ELSE 'no'
      END
  FROM metrics_a a
  JOIN metrics_b b USING (id)
  JOIN thresholds t ON t.metric = 'clicks'

  UNION ALL

  SELECT
      id,
      'impressions',
      a.impressions,
      b.impressions,
      ROUND(ABS(a.impressions - b.impressions) / GREATEST(a.impressions, b.impressions)::NUMERIC * 100, 2),
      t.max_diff_pct,
      CASE
          WHEN ROUND(ABS(a.impressions - b.impressions) / GREATEST(a.impressions, b.impressions)::NUMERIC * 100, 2) > t.max_diff_pct THEN 'yes'
          ELSE 'no'
      END
  FROM metrics_a a
  JOIN metrics_b b USING (id)
  JOIN thresholds t ON t.metric = 'impressions'

  UNION ALL

  SELECT
      id,
      'avg_position',
      a.avg_position,
      b.avg_position,
      ROUND(ABS(a.avg_position - b.avg_position) / GREATEST(a.avg_position, b.avg_position) * 100, 2),
      t.max_diff_pct,
      CASE
          WHEN ROUND(ABS(a.avg_position - b.avg_position) / GREATEST(a.avg_position, b.avg_position) * 100, 2) > t.max_diff_pct THEN 'yes'
          ELSE 'no'
      END
  FROM metrics_a a
  JOIN metrics_b b USING (id)
  JOIN thresholds t ON t.metric = 'avg_position';
END;
$$;

CALL metrics_comparison();

-- SELECT * FROM results_comparison ORDER BY id, metric;


-- 2.Сколько строк имеют хоть одно превышение.

SELECT COUNT(DISTINCT id)
FROM results_comparison
WHERE exceeds_limit = 'yes';


-- 3.У скольких строк какая именно метрика превысила допустимое значение.

SELECT
  metric,
  COUNT(*) AS times_exceeded
FROM results_comparison
WHERE exceeds_limit = 'no'
GROUP BY metric
ORDER BY times_exceeded DESC;


-- 4.Итоговый отчёт. В столбце rows_with_diff указано количество строк с изменёнными данными по каждой метрике,
--   изменение которой достигло критического отклонения. В столбце prc_rows_with_diff указано, сколько процентов
--   от общего количества строк с измененными метриками составляют строки, в которых достигнут критический лимит.

SELECT
  metric,
  COUNT(*) FILTER (WHERE exceeds_limit = 'yes') AS rows_with_diff,
  ROUND(
    COUNT(*) FILTER (WHERE exceeds_limit = 'yes') * 100.0 /
    (SELECT COUNT(*) FROM results_comparison WHERE exceeds_limit IN ('yes', 'no')),
    1
  ) AS prc_rows_with_diff
FROM results_comparison
WHERE exceeds_limit = 'yes'
GROUP BY metric
ORDER BY metric;


-- 5.Проверка на наличие ID, которые есть в metrics_a, но отсутствуют в metrics_b, или наоборот. Критическая разница.

-- 1. ID, которые есть в metrics_a, но нет в metrics_b
INSERT INTO results_comparison (id, metric, exceeds_limit)
SELECT a.id, 'missing_in_b', 'yes'
FROM metrics_a a
LEFT JOIN metrics_b b ON a.id = b.id
WHERE b.id IS NULL;

-- 2. ID, которые есть в metrics_b, но нет в metrics_a
INSERT INTO results_comparison (id, metric, exceeds_limit)
SELECT b.id, 'missing_in_a', 'yes'
FROM metrics_b b
LEFT JOIN metrics_a a ON a.id = b.id
WHERE a.id IS NULL;

SELECT
    id,
    metric,
    exceeds_limit AS critical_divergence
FROM results_comparison
WHERE metric IN ('missing_in_a', 'missing_in_b');
