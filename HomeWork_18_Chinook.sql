-- 1.Створіть функцію f_safe_divide(numerator INT, denominator INT), яка повертає результат ділення, але повертає NULL,
--   якщо знаменник дорівнює нулю (помилок не виникає).

DROP FUNCTION IF EXISTS f_safe_divide;
CREATE FUNCTION f_safe_divide(numerator NUMERIC, denominator NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    IF denominator = 0 THEN
        RETURN NULL;
    ELSE
        RETURN ROUND(numerator / denominator, 2);
    END IF;
END;
$$;

SELECT f_safe_divide(14, 7);


-- 2.Створіть функцію f_total_customer_spent(customer_id INT), яка повертає загальну суму витрат клієнта, використовуючи
--   таблицю Invoice.

DROP FUNCTION IF EXISTS f_total_customer_spent;
CREATE FUNCTION f_total_customer_spent(cust_id INT)
RETURNS TABLE (customer_id INTEGER, client_name VARCHAR, total_costs NUMERIC)
AS $$
BEGIN
  RETURN QUERY
    SELECT
        i.customer_id,
        (c.first_name || ' ' || c.last_name)::VARCHAR AS client_name,
        SUM(i.total) AS total_costs
    FROM invoice i
    JOIN customer c ON c.customer_id = i.customer_id
    WHERE i.customer_id = cust_id
    GROUP BY i.customer_id, c.first_name, c.last_name;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM f_total_customer_spent(9);


-- 3.Створіть процедуру pr_update_employee_title(employee_id INT, new_title TEXT), яка оновлює посаду співробітника
--   в таблиці Employee.

DROP PROCEDURE IF EXISTS pr_update_employee_title;
CREATE PROCEDURE pr_update_employee_title(
    emp_id INT,
    new_title TEXT,
    OUT result_message TEXT
)
AS $$
BEGIN
    UPDATE employee
    SET title = new_title
    WHERE employee_id = emp_id;

    IF FOUND THEN
        result_message := 'Table data has been updated';
    ELSE
        result_message := 'The specified employee id was not found';
    END IF;
END;
$$ LANGUAGE plpgsql;

CALL pr_update_employee_title(77, 'IT Manager', '');


-- 4.Створіть тригер у таблиці Invoice, який реєструватиме створення нового рахунку-фактури, вставивши в нову таблицю
--   invoice_audit(invoice_id INT, created_at TIMESTAMP, created_by TEXT). Продемонструйте, що тригер працює - спробуйте
--   щось вставити в Invoice, після чого перевірте invoice_audit.

DROP TRIGGER IF EXISTS trg_invoice_insert ON invoice;
DROP FUNCTION IF EXISTS log_invoice_insert();
DROP TABLE IF EXISTS invoice_audit;

CREATE TABLE invoice_audit (
    invoice_id INT,
    created_at TIMESTAMP,
    created_by TEXT
);

CREATE OR REPLACE FUNCTION log_invoice_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO invoice_audit (invoice_id, created_at, created_by)
    VALUES (NEW.invoice_id, NOW(), current_user);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_invoice_insert
AFTER INSERT ON invoice
FOR EACH ROW
EXECUTE FUNCTION log_invoice_insert();


INSERT INTO invoice (
    customer_id,
    invoice_date,
    billing_address,
    billing_city,
    billing_state,
    billing_country,
    billing_postal_code,
    total
)
VALUES (
    7,
    '2025-07-26',
    'Primrose Lane 548',
    'Detroit',
    'Michigan',
    'USA',
    '1010',
    1.99
);


SELECT * FROM invoice_audit ORDER BY created_at DESC;
