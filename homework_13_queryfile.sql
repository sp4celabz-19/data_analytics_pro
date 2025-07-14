-- SELECT
--     title || ' by ' || authors AS full_info
-- FROM books
-- WHERE authors IS NOT NULL;


-- SELECT * FROM books WHERE download_count > 25000;

-- SELECT * FROM books WHERE languages IN ('en', 'es');

-- SELECT * FROM books WHERE copyright = 0;

-- SELECT * FROM books WHERE formats LIKE 'text%';

-- SELECT * FROM books WHERE subjects LIKE '%Gothic fiction%';

-- SELECT * FROM books ORDER BY download_count DESC LIMIT 5;


-- SELECT *
-- FROM books
-- WHERE
--     (languages = 'en' AND copyright = 1)
--     OR
--     (languages = 'es');


-- SELECT DISTINCT
--     TRIM(REPLACE(SUBSTR(authors, 1, INSTR(authors, ' ') - 1), ';', '')) AS first_name
-- FROM books
-- WHERE authors IS NOT NULL
--   AND TRIM(SUBSTR(authors, 1, INSTR(authors, ' ') - 1)) != ''
-- ORDER BY first_name;