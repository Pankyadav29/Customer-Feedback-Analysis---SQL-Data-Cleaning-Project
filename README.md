# Customer_Feedback_Analysis - SQL_Data_Cleaning_Project
## Project Overview
**Project Title:** Customer Feedback Analysis <br>
**Level:** Beginner <br>
**Database:** feedback_analysis_db <br>

This project focuses on cleaning and preparing customer feedback data to ensure accuracy and usability for further analysis. The goal is to identify common issues, improve data quality, and gain insights into customer sentiment.

## Objectives

1. Remove duplicate rows based on the review_id column.
2. Fill missing feedback_text values with "No feedback provided".
3. Fill missing rating values with the median rating.
4. Remove HTML tags from the feedback_text column.
5. Convert timestamp values to a consistent datetime format.
6. Remove rows with invalid dates.

## Project Structure

### 1. Database Setup
- **Database Creation:** The project starts by creating a database named customer_feedback_db.<br>
- **Table Creation:** A table named customer_feedback is created to store the feedback data. The table structure includes columns for review_id, customer_id, feedback_source, feedback_text, rating,  timestamp.<br>
```
CREATE DATABASE feedback_analysis_db;
```
```
CREATE TABLE customer_feedback 
(
    review_id INT PRIMARY KEY,
    customer_id INT,
    feedback_source VARCHAR(50),
    feedback_text TEXT,
    rating INT,
    timestamp VARCHAR(50)
);
```

### 2. Data Cleaning
1️⃣ **Remove duplicate rows based on the review_id column.**
```
WITH delete_duplicates AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY review_id ORDER BY review_id) AS rwn
    FROM customer_feedback
)

DELETE FROM customer_feedback WHERE review_id IN (
    SELECT review_id FROM delete_duplicates WHERE rwn > 1
);
```

2️⃣ **Fill missing feedback_text values with "No feedback provided".**
```
UPDATE customer_feedback
SET feedback_text = 'No feedback provided'
WHERE feedback_text = '';
```

3️⃣ **Removing HTML Tags from Feedback**
```
UPDATE customer_feedback
SET rating = (SELECT ROUND(AVG(rating), 0) FROM customer_feedback WHERE rating IS NOT NULL)
WHERE rating IS NULL;
```
```
SET @avg_rating = (SELECT AVG(rating) FROM customer_feedback WHERE rating IS NOT NULL);
UPDATE customer_feedback
SET rating = @avg_rating
WHERE rating IS NULL;
```

4️⃣ **Remove HTML tags from the feedback_text column.**
```
UPDATE customer_feedback 
SET 
    feedback_text = REPLACE(feedback_text,
        '<b>Bad service</b>',
        'Bad service')
WHERE
    feedback_text = '<b>Bad service</b>';
```
```
UPDATE customer_feedback 
SET 
    feedback_text = REPLACE(feedback_text,
        'Terrible! <a href=\'http://example.com\'>Read more</a>',
        'Terrible!')
WHERE
    feedback_text = 'Terrible! <a href=\'http://example.com\'>Read more</a>';
```

5️⃣ **Convert timestamp values to a consistent datetime format.**
```
UPDATE customer_feedback 
SET 
    timestamps = STR_TO_DATE(timestamps, '%m/%d/%Y %H:%i')
WHERE
    timestamps LIKE '%/%/% %:%';
```
```
SELECT 
    timestamps
FROM
    customer_feedback
WHERE
    timestamps LIKE '%-%-% %:%:%'
        AND (timestamps REGEXP '^[0-9]{4}-(02)-(30|31)'
        OR timestamps REGEXP '^[0-9]{4}-(04|06|09|11)-(31)');
```
```
UPDATE customer_feedback 
SET 
    timestamps = REPLACE(timestamps,
        '2024-02-30',
        '2024-02-28')
WHERE
    timestamps LIKE '2024-02-30%';
```
```
UPDATE customer_feedback 
SET 
    timestamps = STR_TO_DATE(timestamps, '%Y-%m-%d %H:%i:%s')
WHERE
    timestamps LIKE '%-%-% %:%:%';
```
```
ALTER TABLE customer_feedback
MODIFY COLUMN timestamps DATETIME;
```
6. **Remove rows with invalid dates.**
```
DELETE FROM customer_feedback 
WHERE
    timestamps = '2024-05-15 10:00:00';
```

### 3. Key Findings

**✅ Most common feedback sources -** Online reviews and surveys contributed the most data.

**✅ Data inconsistencies found -** Several reviews had duplicate entries or missing ratings.

**✅ Standardized dataset -** Cleaning steps ensure accurate and structured data for future analysis.


### 📌 Conclusion

By cleaning and standardizing the customer feedback data, this project ensures high-quality data for further analysis. Businesses can use this cleaned dataset to analyze customer sentiment, improve service, and make data-driven decisions.
