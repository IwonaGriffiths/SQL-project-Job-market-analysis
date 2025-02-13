/* ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
Database Load Issues (follow if receiving permission denied when running SQL code below)

NOTE: If you are having issues with permissions. And you get error: 

'could not open file "[your file path]\job_postings_fact.csv" for reading: Permission denied.'

1. Open pgAdmin
2. In Object Explorer (left-hand pane), navigate to `sql_course` database
3. Right-click `sql_course` and select `PSQL Tool`
    - This opens a terminal window to write the following code
4. Get the absolute file path of your csv files
    1. Find path by right-clicking a CSV file in VS Code and selecting “Copy Path”
5. Paste the following into `PSQL Tool`, (with the CORRECT file path)

\copy company_dim FROM '[Insert File Path]/company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_dim FROM '[Insert File Path]/skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy job_postings_fact FROM '[Insert File Path]/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_job_dim FROM '[Insert File Path]/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

*/

-- NOTE: This has been updated from the video to fix issues with encoding

COPY company_dim
FROM 'C:\SQL luke Borousse project\csv_files\company_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_dim
FROM 'C:\SQL luke Borousse project\csv_files\skills_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY job_postings_fact
FROM 'C:\SQL luke Borousse project\csv_files/job_postings_fact.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_job_dim
FROM 'C:\SQL luke Borousse project\csv_files\skills_job_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

SELECT * 
FROM job_postings_fact
LIMIT 10

SELECT '2023-02-19' :: DATE;

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST',
    EXTRACT (MONTH FROM job_posted_date) AS date_month
FROM
    job_postings_fact
    LIMIT 5;

SELECT AVG(salary_year_avg) AS yearly_average_salary,
    AVG(salary_hour_avg) AS hourly_average_salary,
    job_schedule_type

FROM
    job_postings_fact
WHERE 
    job_posted_date > '2023-06-01'
GROUP by
    job_schedule_type
;



SELECT
    comp.name,
    COUNT(jpf.job_id) AS job_count
    
FROM
    job_postings_fact as JPF
LEFT JOIN company_dim AS comp ON comp.company_id = jpf.company_id
WHERE
    EXTRACT (QUARTER FROM jpf.job_posted_date ) = 2
GROUP by
    comp.name
;

CREATE TABLE January_jobs AS
    SELECT * 
    FROM job_postings_fact
    WHERE EXTRACT (MONTH FROM job_posted_date) = 1
;
CREATE TABLE February_jobs AS
    SELECT * 
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2
;

CREATE TABLE March_jobs AS
    SELECT * 
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3
;


SELECT
   AVG(salary_year_avg),
    CASE
        WHEN salary_year_avg < 100000 THEN 'Low_salary'
        WHEN salary_year_avg BETWEEN 100000 AND 150000 THEN 'Mid_salary'
        ELSE 'high_salary'
    END AS salary_levels
FROM
    job_postings_fact 
WHERE
    job_title_short = 'Data Analyst'
GROUP by
    salary_levels;

    -- CTE common table exppression
WITH january_jobs AS (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(month from job_posted_date) = 1
    )
SELECT *
FROm january_jobs;

-- subquery

SELECT *
FROM 
    (SELECT *
    FROM job_postings_fact
    WHERE EXtract(month from job_posted_date) = 1)
AS jan_jobs;


SELECT name
FROM company_dim
WHERE company_id IN (
    SELECT
        company_id
    FROM
        job_postings_fact
    WHERE
        job_no_degree_mention = true
)


WITH company_job_count AS (
SELECT company_id,
COUNT(*) AS total_jobs
    FROM
        job_postings_fact
    GROUP by
    company_id
)


SELECt 
    company_dim.name as company_name,
    company_job_count.total_jobs
FROM company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER by
    total_jobs DESC


WITH Skills_count AS (
    SELECT COUNT(skill_id) as skill_count,
    skill_id
FROM skills_job_dim
GROUP BY skill_id
)
SELECT skills_count.skill_count,
    skills_count.skill_id,
    skills_dim.skills
From Skills_count
LEFT JOIN skills_dim ON skills_count.skill_id = skills_dim.skill_id
order by skills_count.skill_count DESC;


SELECT COUNT(job_id) AS jobs_count,
company_id
From job_postings_fact
group by company_id
order by jobs_count DESC;
    
SELECT
    company_id,
   jobs_count,
    CASE
        WHEN jobs_count < 200 THEN 'small'
        WHEN jobs_count BETWEEN 200 AND 1000 THEN 'medium'
        ELSE 'high'
    END AS jobscount_levels
FROM
    (SELECT COUNT(job_id) AS jobs_count,
company_id
From job_postings_fact
group by company_id
order by jobs_count DESC) AS job_count
GROUP by
   company_id,
   jobs_count 
ORDER BY
    jobs_count DESC;

WITH remote_job_skills AS (
    SELECT 
    skill_id,
    COUNT(*) AS skill_count
FROM
    skills_job_dim AS skills_to_job
INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
WHERE
    job_postings.job_work_from_home = True AND
    job_postings.job_title_short = 'Data Analyst'
GROUP BY 
    skill_id
    )
SELECT 
remote_job_skills.skill_id,
skills.skills as skill_name,
remote_job_skills.skill_count
FROM remote_job_skills
INNER JOIN skills_dim AS Skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY
skill_count DESC
LIMIT 5;


-- UNION does not bring duplicated rows so it is better to use UNION ALL


SELECT 
    qtr_job_postings.job_title_short,
    qtr_job_postings.job_via,
    qtr_job_postings.job_posted_date :: Date,
    qtr_job_postings.salary_year_avg
FROM (
SELECT
    *
FROM january_jobs
UNION ALL
SELECT
     *
FROM february_jobs
UNION ALL
SELECT
     *
FROM march_jobs
) as qtr_job_postings
WHERE salary_year_avg > 70000 AND
    job_title_short = 'Data Analyst'
ORDER BY
salary_year_avg DESC;