CREATE DATABASE feedback_analysis_db;

USE feedback_analysis_db;

SELECT * FROM original_customer_feedback;

-- 

DESCRIBE customer_feedback;

-- 1. Remove duplicate rows based on the review_id column.

WITH delete_duplicates AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY review_id ORDER BY review_id) AS rwn
FROM customer_feedback
)
DELETE FROM customer_feedback
WHERE review_id IN (
    SELECT review_id FROM delete_duplicates WHERE rwn > 1
);

-- 2. Fill missing feedback_text values with "No feedback provided".

UPDATE customer_feedback 
SET 
    feedback_text = 'No feedback provided'
WHERE
    feedback_text = '';

-- 3. Fill missing rating values with the median rating.

UPDATE customer_feedback
SET rating = (SELECT ROUND(AVG(rating), 0) FROM customer_feedback WHERE rating IS NOT NULL)
WHERE rating IS NULL;

--     OR

SET @avg_rating = (SELECT AVG(rating) FROM customer_feedback WHERE rating IS NOT NULL);

UPDATE customer_feedback 
SET 
    rating = @avg_rating
WHERE
    rating IS NULL;

-- 4. Remove HTML tags from the feedback_text column.

UPDATE customer_feedback 
SET 
    feedback_text = REPLACE(feedback_text,
        '<b>Bad service</b>',
        'Bad service')
WHERE
    feedback_text = '<b>Bad service</b>';

UPDATE customer_feedback 
SET 
    feedback_text = REPLACE(feedback_text,
        'Terrible! <a href=\'http://example.com\'>Read more</a>',
        'Terrible!')
WHERE
    feedback_text = 'Terrible! <a href=\'http://example.com\'>Read more</a>';

-- 5. Convert timestamp values to a consistent datetime format.

UPDATE customer_feedback 
SET 
    timestamps = STR_TO_DATE(timestamps, '%m/%d/%Y %H:%i')
WHERE
    timestamps LIKE '%/%/% %:%';

--

SELECT 
    timestamps
FROM
    customer_feedback
WHERE
    timestamps LIKE '%-%-% %:%:%'
        AND (timestamps REGEXP '^[0-9]{4}-(02)-(30|31)'
        OR timestamps REGEXP '^[0-9]{4}-(04|06|09|11)-(31)');

--

UPDATE customer_feedback 
SET 
    timestamps = REPLACE(timestamps,
        '2024-02-30',
        '2024-02-28')
WHERE
    timestamps LIKE '2024-02-30%';

--

UPDATE customer_feedback 
SET 
    timestamps = STR_TO_DATE(timestamps, '%Y-%m-%d %H:%i:%s')
WHERE
    timestamps LIKE '%-%-% %:%:%';

--

ALTER TABLE customer_feedback
MODIFY COLUMN timestamps DATETIME;

-- 6. Remove rows with invalid dates.

DELETE FROM customer_feedback 
WHERE
    timestamps = '2024-05-15 10:00:00';
