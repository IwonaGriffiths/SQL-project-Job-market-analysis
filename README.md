# SQL Project Job data analysis
This project focuses on data job market. With main goal on analysing Data Analyst roles, this project explores top paying jobs, in-demand skills, where high demand meers high salary.
There are several SQL querties that I used that can be found here: [project_sql_folder](/link)

# Questions that I wanted to answer through my SQL queries were:
1) What are top paying data analyst jobs?
2) What skills are required for these top paying jobs?
3) What skills are most in demand for data analysts?
4) Which skills are associated with higher salaries?
5) What are the most optimal skills to learn?
I also focused only of 'Data Analyst' role with option to work remotely.

# Tools I used:
- SQL allowed me to query the database so that i could answer project questions
- PostreSQL database management system ideal for job postings data
- Visual Studio Code for running SQL queries

# The Analysis
1) What are top paying data analyst jobs? 

```
SQL query:
SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name as company_name
FROM
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE job_title_short = 'Data Analyst' AND
job_location = 'Anywhere'
AND salary_year_avg IS NOT NULL
ORDER BY 
    salary_year_avg DESC
LIMIT 10;
```
Findings: 
There is a high diversity of job titles in the field of data analytics, ranging from Data Analyst to Director of Analytics, reflecting the varied roles and specializations within the industry. Additionally, data analysts are hired across various industries, with top employers including SmartAsset, Meta, and AT&T.

Among the top 10 highest-paying jobs, salaries range from $184K to $650K, indicating significant earning potential in this field.

![image](https://github.com/user-attachments/assets/53ec270c-5e78-411b-95f3-c09b16404ff7)

2) What skills are required for these top paying jobs?
 ```
   SQL:
   WITH top_paying_jobs AS (
SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name as company_name
FROM
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE job_title_short = 'Data Analyst' AND
job_location = 'Anywhere'
AND salary_year_avg IS NOT NULL
ORDER BY 
    salary_year_avg DESC
LIMIT 10
)
SELECT 
    top_paying_jobs.*,
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC;
```

Findings: Programming skills like SQL, Python, R and also cluod data mangement systems like GCP, Azure etc. are among the most required skills.

3) What skills are most in demand for data analysts?

```
SELECT 
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count
   
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
    job_title_short = 'Data Analyst' AND
    job_work_from_home = TRUE
GROUP BY
    skills_dim.skills
ORDER BY
    demand_count DESC
LIMIT 5;
```
Findings: Below are listed top in demand skills for Data Analyst role

![image](https://github.com/user-attachments/assets/b4c099b0-f650-4723-9ee6-270a056ad45d)

4) Which skills are associated with higher salaries?

```
SQL query:
SELECT 
    skills_dim.skills,
    ROUND(AVG(salary_year_avg),0) AS average_salary
   
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL AND
    job_work_from_home = TRUE
GROUP BY
    skills_dim.skills
ORDER BY
    average_salary DESC
LIMIT 25;
```

Findings: 
Below are listed most paid skills for Data Analyst roles:

![image](https://github.com/user-attachments/assets/95d6976c-fd3f-4f41-9dbd-4526202286c5)

5) What are the most optimal skills to learn?

```
SQL query:
WITH skills_demand AS (
    SELECT 
        skills_dim.skill_id,
        skills_dim.skills,
        COUNT(skills_job_dim.job_id) AS demand_count
    
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE 
        job_title_short = 'Data Analyst' AND
        job_work_from_home = TRUE AND
        salary_year_avg IS NOT NULL
    GROUP BY
        skills_dim.skill_id
 
),
average_salary AS (
    SELECT 
    skills_dim.skill_id,
    skills_dim.skills,
    ROUND(AVG(salary_year_avg),0) AS average_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE 
        job_title_short = 'Data Analyst' AND
        salary_year_avg IS NOT NULL AND
        job_work_from_home = TRUE
    GROUP BY
        skills_dim.skill_id
       
)
SELECT
    skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    average_salary
FROM
    skills_demand
INNER JOIN average_salary ON skills_demand.skill_id=average_salary.skill_id
WHERE
    demand_count > 10
ORDER BY 
    average_salary DESC,
    demand_count DESC
LIMIT 25;


-- SIMPLER WAY TO WRITE SAME QUERY

SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(salary_year_avg),0) AS average_salary
FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL AND
    job_work_from_home = TRUE
GROUP BY
    skills_dim.skill_id    
HAVING
    COUNT(skills_job_dim.job_id) > 10
ORDER BY
    average_salary DESC,
    demand_count DESC
LIMIT 25;
```

Findings: Below table lists the skills that are among best paid roles and also are in high demand. Few programming languages are among them (java, python, c++) and some visualisations softwares like tableau or Looker.

![image](https://github.com/user-attachments/assets/a7161411-54a4-40fc-92a9-094e992f481f)

# What I learned:
Throughout this project, I used popular SQL queries and practiced advanced SQL techniques such as merging tables and using WITH clauses. I also utilized data aggregation commands to count and summarize numeric data. 


