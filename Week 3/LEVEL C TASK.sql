-- TASK 1

/*

You are given a table, Projects, containing three columns: Task_ID, Start Date and End Date. It is guaranteed that the difference between the End Date and the Start Date is equal to 1 day for each row in the table.
Colum Type
Task_ID Integer
Start Date Date
End Date Date
If the End Date of the tasks are consecutive, then they are part of the same project. Samantha is interested in finding the total number of different projects completed.
Write a query to output the start and end dates of projects listed by the number of days it took to complete the project in ascending order. If there is more than one project that have the same number of completion days, then order by the start date of the project.


Sample Input
Task_ID Start Date End Date
1 2015-10-01 2015-10-02
2 2015-10-02 2015-10-03
3 2015-10-03 2015-10-04
4 2015-10-13 2015-10-14
5 2015-10-14 2015-10-15
6 2015-10-28 2015-10-29
7 2015-10-30 2015-10-31

Sample Output
2015-10-28 2015-10-29
2015-10-30 2015-10-31
2015-10-13 2015-10-15
2015-10-01 2015-10-04

*/

-- Create the table
CREATE TABLE PROJECTS (
    TASK_ID INT,
    START_DATE DATE,
    END_DATE DATE
);

-- Insert sample input
INSERT INTO PROJECTS (TASK_ID, START_DATE, END_DATE) VALUES
(1, '2015-10-01', '2015-10-02'),
(2, '2015-10-02', '2015-10-03'),
(3, '2015-10-03', '2015-10-04'),
(4, '2015-10-13', '2015-10-14'),
(5, '2015-10-14', '2015-10-15'),
(6, '2015-10-28', '2015-10-29'),
(7, '2015-10-30', '2015-10-31');

-- Query to find the start and end dates of projects
WITH PROJECTS_CTE AS (
    SELECT
        TASK_ID,
        START_DATE,
        END_DATE,
        DATEADD(DAY, -ROW_NUMBER() OVER (ORDER BY START_DATE), START_DATE) AS PROJECT_GROUP
    FROM
        PROJECTS
),
PROJECT_GROUPS AS (
    SELECT
        PROJECT_GROUP,
        MIN(START_DATE) AS PROJECT_START_DATE,
        MAX(END_DATE) AS PROJECT_END_DATE,
        DATEDIFF(DAY, MIN(START_DATE), MAX(END_DATE)) + 1 AS DURATION
    FROM
        PROJECTS_CTE
    GROUP BY
        PROJECT_GROUP
)
SELECT
    PROJECT_START_DATE,
    PROJECT_END_DATE
FROM
    PROJECT_GROUPS
ORDER BY
    DURATION ASC,
    PROJECT_START_DATE ASC;

-----------------------------------------------------------------------------------------------

-- TASK 2
/*

You are given three tables: Students, Friends and Packages. Students contains two
columns: ID and Name. Friends contains two columns: ID and Friend ID (ID of the ONLY best
friend). Packages contains two columns: ID and Salary (offered salary in $ thousands per month).
Students Table
Column Type
ID Integer
Name String

Friends Table
Column Туре
ID Integer
Friend_ID Integer

Packages Table
Column Туре
ID Integer
Salary Float

Write a query to output the names of those students whose best friends got offered a higher
salary than them. Names must be ordered by the salary amount offered to the best friends. It is guaranteed that no two students got same salary offer.

Sample Input

Friends Table
ID Friend_ID
1 2
2 3
3 4
4 1

Students Table
ID Name
1 Ashley
2 Samantha
3 Julia
4 Scarlet

Packages Table
ID Salary
1 15.20
2 10.06
3 11.55
4 12.12

Sample Output
Samantha
Julia
Scarlet

*/

-- Create the tables
CREATE TABLE STUDENTS (
    ID INT,
    NAME VARCHAR(255)
);

CREATE TABLE FRIENDS (
    ID INT,
    FRIEND_ID INT
);

CREATE TABLE PACKAGES (
    ID INT,
    SALARY FLOAT
);

-- Insert sample data
INSERT INTO STUDENTS (ID, NAME) VALUES
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');

INSERT INTO FRIENDS (ID, FRIEND_ID) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);

INSERT INTO PACKAGES (ID, SALARY) VALUES
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);

-- Query to find students whose best friends got offered a higher salary
SELECT
    S.NAME
FROM
    STUDENTS S
JOIN
    FRIENDS F ON S.ID = F.ID
JOIN
    PACKAGES PS ON S.ID = PS.ID
JOIN
    PACKAGES PF ON F.FRIEND_ID = PF.ID
WHERE
    PF.SALARY > PS.SALARY
ORDER BY
    PF.SALARY ASC;
	
---------------------------------------------------------------------------------------------------

-- TASK 3

/*

You are given a table, Functions, containing two columns: X and Y.
Column Туре
X Integer
Y Integer

Two pairs (X1, Y1) and (X2, Y2) are said to be symmetric pairs if X1 = Y2 and X2 = Y1.
Write a query to output all such symmetric pairs in ascending order by the value of X.

Sample Input
X Y
20 20
20 20
20 21
23 22
22 23
21 20

Sample Output
20 20
20 21
22 23

*/

-- Create the table
CREATE TABLE FUNCTIONS (
    X INT,
    Y INT
);

-- Insert sample data
INSERT INTO FUNCTIONS (X, Y) VALUES
(20, 20),
(20, 20),
(20, 21),
(23, 22),
(22, 23),
(21, 20);

-- Query to find symmetric pairs
SELECT DISTINCT
    F1.X, F1.Y
FROM
    FUNCTIONS F1
JOIN
    FUNCTIONS F2 ON F1.X = F2.Y AND F1.Y = F2.X
WHERE
    F1.X <= F1.Y
ORDER BY
    F1.X ASC, F1.Y ASC;
	
-----------------------------------------------------------------------------------------------------

-- TASK 4

/*

Samantha interviews many candidates from different colleges using coding challenges and contests. Write a query to print the contest_id, hacker_id, name, and the sums of total submissions, total_accepted submissions, total views, and total_unique_views for each contest sorted by contest_id. Exclude the contest from the result if all four sums are.
Note: A specific contest can be used to screen candidates at more than one college, but each college only holds screening contest.

Input Format
The following tables hold interview data:

Contests: The contest_id is the id of the contest, hacker_id is the id of the hacker who created the
Column Type
contest_id Integer
hacker_id Integer
name String
contest, and name is the name of the hacker.

Colleges: The college_id is the id of the college, and contest_id is the id of the contest that Samantha used to screen the candidates.
Column Type
college_id Integer
contest_id Integer

Challenges: The challenge_id is the id of the challenge that belongs to one of the contests whose contest_id Samantha forgot, and college_id is the id of the college where the
challenge was given to candidates.
Column Type
challenge_id Integer
college_id Integer

View_Stats: The challenge_id is the id of the challenge, total_views is the number of times the challenge was viewed by candidates, and total_unique_views is the number of times the challenge was viewed by unique candidates.
Column Туре
challenge_id Integer
total_views Integer
total_unique_views Integer

Submission_Stats: The challenge_id is the id of the challenge, total_submissions is the number of submissions for the challenge, and total_accepted submission is the number of submissions that achieved full scores.
Column Type
challenge_id Integer
total_submissions Integer
total_accepted_submissions Integer

Sample Input

Contests Table:
contest_id hacker_id name
66406 17973 Rose
66556 79153 Angela
94828 80275 Frank

Colleges Table:
college_id contest_id
11219 66406
32473 66556
56685 94828 

Challenges Table:
challenge_id contest_id
18765 11219
47127 11219
60292 32473
72974 56685

View_Stats

challenge_id total_views total_unique_views
47127 26 19
47127 15 14
18765 43 10
18765 72 13
75516 35 17
60292 11 10
72974 41 15
75516 75 11


Submission_Stats Table:
challenge_id total_submissions total_accepted_submissions
75516 34 12
47127 27 10
47127 56 18
75516 74 12
75516 83 8
72974 68 24
72974 82 14
47127 28 11

Sample Output
66406 17973 Rose 111 39 156 56 
66556 79153 Angela 0 0 11 10
94828 80275 Frank 150 38 41 15

*/

-- Create Contests table
CREATE TABLE CONTESTS (
    CONTEST_ID INT,
    HACKER_ID INT,
    NAME VARCHAR(255)
);

-- Create Colleges table
CREATE TABLE COLLEGES (
    COLLEGE_ID INT,
    CONTEST_ID INT
);

-- Create Challenges table
CREATE TABLE CHALLENGES (
    CHALLENGE_ID INT,
    COLLEGE_ID INT
);

-- Create View_Stats table
CREATE TABLE VIEW_STATS (
    CHALLENGE_ID INT,
    TOTAL_VIEWS INT,
    TOTAL_UNIQUE_VIEWS INT
);

-- Create Submission_Stats table
CREATE TABLE SUBMISSION_STATS (
    CHALLENGE_ID INT,
    TOTAL_SUBMISSIONS INT,
    TOTAL_ACCEPTED_SUBMISSIONS INT
);

-- Insert sample data into Contests table
INSERT INTO CONTESTS (CONTEST_ID, HACKER_ID, NAME) VALUES
(66406, 17973, 'Rose'),
(66556, 79153, 'Angela'),
(94828, 80275, 'Frank');

-- Insert sample data into Colleges table
INSERT INTO COLLEGES (COLLEGE_ID, CONTEST_ID) VALUES
(11219, 66406),
(32473, 66556),
(56685, 94828);

-- Insert sample data into Challenges table
INSERT INTO CHALLENGES (CHALLENGE_ID, COLLEGE_ID) VALUES
(18765, 11219),
(47127, 11219),
(60292, 32473),
(72974, 56685);

-- Insert sample data into View_Stats table
INSERT INTO VIEW_STATS (CHALLENGE_ID, TOTAL_VIEWS, TOTAL_UNIQUE_VIEWS) VALUES
(47127, 26, 19),
(47127, 15, 14),
(18765, 43, 10),
(18765, 72, 13),
(75516, 35, 17),
(60292, 11, 10),
(72974, 41, 15),
(75516, 75, 11);

-- Insert sample data into Submission_Stats table
INSERT INTO SUBMISSION_STATS (CHALLENGE_ID, TOTAL_SUBMISSIONS, TOTAL_ACCEPTED_SUBMISSIONS) VALUES
(75516, 34, 12),
(47127, 27, 10),
(47127, 56, 18),
(75516, 74, 12),
(75516, 83, 8),
(72974, 68, 24),
(72974, 82, 14),
(47127, 28, 11);

-- Query to find contest information with required aggregates
SELECT
    C.CONTEST_ID,
    C.HACKER_ID,
    C.NAME,
    COALESCE(SUM(S.TOTAL_SUBMISSIONS), 0) AS TOTAL_SUBMISSIONS,
    COALESCE(SUM(S.TOTAL_ACCEPTED_SUBMISSIONS), 0) AS TOTAL_ACCEPTED_SUBMISSIONS,
    COALESCE(SUM(V.TOTAL_VIEWS), 0) AS TOTAL_VIEWS,
    COALESCE(SUM(V.TOTAL_UNIQUE_VIEWS), 0) AS TOTAL_UNIQUE_VIEWS
FROM
    CONTESTS C
JOIN
    COLLEGES CO ON C.CONTEST_ID = CO.CONTEST_ID
JOIN
    CHALLENGES CH ON CO.COLLEGE_ID = CH.COLLEGE_ID
LEFT JOIN
    VIEW_STATS V ON CH.CHALLENGE_ID = V.CHALLENGE_ID
LEFT JOIN
    SUBMISSION_STATS S ON CH.CHALLENGE_ID = S.CHALLENGE_ID
GROUP BY
    C.CONTEST_ID, C.HACKER_ID, C.NAME
HAVING
    SUM(S.TOTAL_SUBMISSIONS) + SUM(S.TOTAL_ACCEPTED_SUBMISSIONS) + SUM(V.TOTAL_VIEWS) + SUM(V.TOTAL_UNIQUE_VIEWS) > 0
ORDER BY
    C.CONTEST_ID;

------------------------------------------------------------------------------------------------------

-- TASK 5

/*

Julia conducted a days of learning SQL contest. The start date of the contest was March 01,
2016 and the end date was March 15, 2016.
Write a query to print total number of unique hackers who made at least submission each day (starting on the first day of the contest), and find the hacker_id and name of the hacker who made maximum number of submissions each day. If more than one such hacker has a maximum number of submissions, print the lowest hacker_id. The query should print this information for each day of the contest, sorted by the date.
Input Format
The following tables hold contest data:
Hackers: The hacker_id is the id of the hacker, and name is the name of the hacker.
Column Type
hacker_id Integer
name String

Submissions: The submission_date is the date of the submission, submission_id is the id of the submission, hacker_id is the id of the hacker who made the submission, and score is the score of the submission.
Column Type
submission_date Date
submission_id Integer
hacker_id Integer
Score Integer

Sample Input

Hackers Table
hacker_id name
15758 Rose
20703 Angela
36396 Frank
38289 Patrick
44065 Lisa
53473 Kimberly
62529 Bonnie
79722 Michael

Submissions Table
submission_date submission_id hacker_id score
2016-03-01 8494 20703 0 
2016-03-01 22403 53473 15
2016-03-01 23965 79722 60
2016-03-01 30173 36396 70
2016-03-02 34928 20703 0
2016-03-02 38740 15758 60
2016-03-02 42769 79722 25
2016-03-02 44364 79722 60
2016-03-03 45440 20703 0
2016-03-03 49050 36396 70
2016-03-03 50273 79722 5
2016-03-04 50344 20703 0
2016-03-04 51360 44065 90
2016-03-04 54404 53473 65
2016-03-04 61533 79722 45
2016-03-05 72852 20703 0
2016-03-05 74546 38289 0
2016-03-05 76487 62529 0
2016-03-05 82439 36396 10
2016-03-05 90006 36396 40
2016-03-06 90404 20703 0

Sample Output
2016-03-01 4 20703 Angela 
2016-03-02 2 79722 Michael 
2016-03-03 2 20703 Angela
2016-03-04 2 20703 Angela 
2016-03-05 1 36396 Frank
2016-03-06 1 20703 Angela

*/

-- Create Hackers table
CREATE TABLE Hackers (
    hacker_id INT,
    name VARCHAR(255)
);

-- Create Submissions table
CREATE TABLE Submissions (
    submission_date DATE,
    submission_id INT,
    hacker_id INT,
    score INT
);

-- Insert sample data into Hackers table
INSERT INTO Hackers (hacker_id, name) VALUES
(15758, 'Rose'),
(20703, 'Angela'),
(36396, 'Frank'),
(38289, 'Patrick'),
(44065, 'Lisa'),
(53473, 'Kimberly'),
(62529, 'Bonnie'),
(79722, 'Michael');

-- Insert sample data into Submissions table
INSERT INTO Submissions (submission_date, submission_id, hacker_id, score) VALUES
('2016-03-01', 8494, 20703, 0),
('2016-03-01', 22403, 53473, 15),
('2016-03-01', 23965, 79722, 60),
('2016-03-01', 30173, 36396, 70),
('2016-03-02', 34928, 20703, 0),
('2016-03-02', 38740, 15758, 60),
('2016-03-02', 42769, 79722, 25),
('2016-03-02', 44364, 79722, 60),
('2016-03-03', 45440, 20703, 0),
('2016-03-03', 49050, 36396, 70),
('2016-03-03', 50273, 79722, 5),
('2016-03-04', 50344, 20703, 0),
('2016-03-04', 51360, 44065, 90),
('2016-03-04', 54404, 53473, 65),
('2016-03-04', 61533, 79722, 45),
('2016-03-05', 72852, 20703, 0),
('2016-03-05', 74546, 38289, 0),
('2016-03-05', 76487, 62529, 0),
('2016-03-05', 82439, 36396, 10),
('2016-03-05', 90006, 36396, 40),
('2016-03-06', 90404, 20703, 0);

-- Query to find the total number of unique hackers and the hacker who made the maximum number of submissions each day
WITH Dates AS (
    SELECT 
        CAST('2016-03-01' AS DATE) AS Date
    UNION ALL
    SELECT 
        DATEADD(DAY, 1, Date)
    FROM 
        Dates
    WHERE 
        Date < '2016-03-15'
),
SubmissionCounts AS (
    SELECT
        S.submission_date,
        COUNT(DISTINCT S.hacker_id) AS TotalUniqueHackers,
        H.hacker_id,
        H.name,
        ROW_NUMBER() OVER (PARTITION BY S.submission_date ORDER BY COUNT(S.hacker_id) DESC, H.hacker_id ASC) AS HackerRank
    FROM
        Dates D
    LEFT JOIN
        Submissions S ON D.Date = S.submission_date
    JOIN
        Hackers H ON S.hacker_id = H.hacker_id
    GROUP BY
        S.submission_date,
        H.hacker_id,
        H.name
)
SELECT
    submission_date,
    TotalUniqueHackers,
    hacker_id,
    name
FROM
    SubmissionCounts
WHERE
    HackerRank = 1
ORDER BY
    submission_date;
	
--------------------------------------------------------------------------------------------------------

-- TASK 6

/*

Consider P1 (a,b) and P2(c,d) to be two points on a 2D plane.
happens to equal the minimum value in Northern Latitude (LAT_N in STATION).
happens to equal the minimum value in Western Longitude (LONG_W in STATION).
happens to equal the maximum value in Northern Latitude (LAT_N in STATION).
happens to equal the maximum value in Western Longitude (LONG_W in STATION).
Query the Manhattan Distance between points P1 and P2 and round it to a scale of decimal places.

Input Format
The STATION table is described as follows:

Field Type 
ID NUMBER
CITY VARCHAR2(21)
STATE VARCHAR2(2)
LAT_N NUMBER
LONG_W NUMBER

where LAT_N is the northern latitude and LONG_W is the western longitude.

*/

SELECT ROUND(
        ABS(MAX(LAT_N) - MIN(LAT_N)) +
        ABS(MAX(LONG_W) - MIN(LONG_W)),
        4
    ) AS MANHATTAN_DISTANCE
FROM STATION;

-------------------------------------------------------------------------------------------------------

-- TASK 7

/*

Write a query to print all prime numbers less than or equal to 1000. Print your result on a single line, and use the ampersand (&) character as your separator (instead of a space).
For example, the output for all prime numbers <=10 would be:

*/

SELECT LISTAGG(PRIME, '&') WITHIN GROUP (ORDER BY PRIME) AS PRIME_NUMBERS
FROM (
    SELECT LEVEL AS PRIME
    FROM DUAL
    CONNECT BY LEVEL <= 1000
    MINUS
    SELECT LEVEL AS NOT_PRIME
    FROM DUAL
    CONNECT BY LEVEL <= 1000
    AND MOD(LEVEL, 2) = 0
    AND LEVEL > 2
    UNION ALL
    SELECT 2 AS PRIME FROM DUAL
    UNION ALL
    SELECT 3 AS PRIME FROM DUAL
    UNION ALL
    SELECT 5 AS PRIME FROM DUAL
    UNION ALL
    SELECT 7 AS PRIME FROM DUAL
    UNION ALL
    SELECT 11 AS PRIME FROM DUAL
)

--------------------------------------------------------------------------------------------------------

-- TASK 8

/*

Pivot the Occupation column in OCCUPATIONS so that each Name is sorted alphabetically and displayed underneath its corresponding Occupation. The output column headers should be Doctor, Professor, Singer, and Actor, respectively.
Note: Print NULL when there are no more names corresponding to an occupation.


Note: Print NULL when there are no more names corresponding to an occupation.
Input Format
The OCCUPATIONS table is described as follows:
Column Туре
Name String
Occupation String
Occupation will only contain one of the following values: Doctor, Professor, Singer or Actor.

Sample Input
Name Occupation
Samantha Doctor
Julia Actor
Maria Actor
Meera Singer
Ashely Professor
Ketty Professor
Christeen Professor
Jane Actor
Jenny Doctor
Priya Singer

Sample Output
Jenny Ashley Meera Jane 
Samantha Christeen Priya Julia 
NULL Ketty NULL Maria

*/

-- Create OCCUPATIONS table
CREATE TABLE OCCUPATIONS (
    Name VARCHAR(255),
    Occupation VARCHAR(255)
);

-- Insert sample data into OCCUPATIONS table
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES
('Samantha', 'Doctor'),
('Julia', 'Actor'),
('Maria', 'Actor'),
('Meera', 'Singer'),
('Ashley', 'Professor'),
('Ketty', 'Professor'),
('Christeen', 'Professor'),
('Jane', 'Actor'),
('Jenny', 'Doctor'),
('Priya', 'Singer');

SELECT
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor
FROM
    OCCUPATIONS
GROUP BY
    Name
ORDER BY
    Name;

--------------------------------------------------------------------------------------------------------
-- TASK 9
 
/*

You are given a table, BST, containing two columns: N and P, where N represents the
value of a node in Binary Tree, and P is the parent of N.
Column Туре
N Integer
P Integer
Write a query to find the node type of Binary Tree ordered by the value of the node. Output one of
the following for each node:
Root: If node is root node.
Leaf: If node is leaf node.
Inner: If node is neither root nor leaf node.

Sample Input
N P
1 2
3 2
6 8
9 8
2 5
8 5
5 null

Sample Output
1 Leaf
2 Inner
3 Leaf
5 Root
6 Leaf
8 Inner
9 Leaf

*/

CREATE TABLE BST (
    N INT,
    P INT
);

INSERT INTO BST (N, P) VALUES
(1, 2),
(3, 2),
(6, 8),
(9, 8),
(2, 5),
(8, 5),
(5, NULL);

SELECT N,
    CASE
        WHEN P IS NULL THEN 'Root'
        WHEN N IN (SELECT DISTINCT P FROM BST) THEN 'Inner'
        ELSE 'Leaf'
    END AS NodeType
FROM BST
ORDER BY N;

--------------------------------------------------------------------------------------------------------

-- TASK 10
/*

Amber's conglomerate corporation just acquired some new companies. Each of the companies follows this hierarchy:
Founder -> Lead Manager -> Senior Manager -> Manager -> Employee

Given the table schemas below, write a query to print the company_code, founder name, total number of lead managers, total number of senior managers, total number of managers, and total number of employees. Order your output by ascending company_code.
Note:
The tables may contain duplicate records.
The company_code is string, so the sorting should not be numeric. For example, if the company_codes are C_1, C_2, and C_10, then the ascending company_codes will be C_1, C_10, and C_2.

Input Format
The following tables contain company data:
Company: The company_code is the code of the company and founder is the founder of the company. 
Column Туре
company_code String
founder String

Lead Manager: The lead_manager_code is the code of the lead manager, and the company_code is the code of the working company.
Column Type
lead_manager_code String
company_code String

Senior Manager: The senior_manager_code is the code of the senior manager, the lead_manager_code is the code of its lead manager, and the company_code is the code of the working company.
Column Type
senior_manager_code String
lead_manager_code String
company_code String

Manager: The manager_code is the code of the manager, the senior_manager_code is the code of its senior manager, the lead_manager_code is the code of its lead manager, and the company_code is the code of the working company.
Column Type
manager_code String
senior_manager_code String
lead_manager_code String
company_code String

Employee: The employee_code is the code of the employee, the manager_code is the code of its manager, the senior_manager_code is the code of its senior manager, the lead_manager_code is the code of its lead manager, and the company_code is the code of the working company.
Column Type
employee_code String
manager_code String
senior_manager_code String
lead_manager_code String
company_code String

Sample Input

Company Table:
company_code founder
C1 Monika
C2 Samantha

Lead Manager Table:
lead_manager_code company_code
LM1 C1
LM2 C2

Senior Manager Table:
senior_manager_code lead_manager_code company_code 
SM1 LM1 C1
SM2 LM1 C1
SM3 LM2 C2

Manager Table:
manager_code senior_manager_code lead_manager_code company_code
M1 SM1 LM1 C1
M2 SM3 LM2 C2
M3 SM3 LM2 C2

Employee Table:
employee_code manager_code senior_manager_code lead_manager_code company_code
E1 M1 SM1 LM1 C1
E2 M1 SM1 LM1 C1
E3 M2 SM3 LM2 C2
E4 M3 SM3 LM2 C2

Sample Output
C1 Monika 1 2 1 2
C2 Samantha 1 1 2 2

*/ 

CREATE TABLE COMPANY (
    COMPANY_CODE VARCHAR(255),
    FOUNDER VARCHAR(255)
);

CREATE TABLE LEAD_MANAGER (
    LEAD_MANAGER_CODE VARCHAR(255),
    COMPANY_CODE VARCHAR(255)
);

CREATE TABLE SENIOR_MANAGER (
    SENIOR_MANAGER_CODE VARCHAR(255),
    LEAD_MANAGER_CODE VARCHAR(255),
    COMPANY_CODE VARCHAR(255)
);

CREATE TABLE MANAGER (
    MANAGER_CODE VARCHAR(255),
    SENIOR_MANAGER_CODE VARCHAR(255),
    LEAD_MANAGER_CODE VARCHAR(255),
    COMPANY_CODE VARCHAR(255)
);

CREATE TABLE EMPLOYEE (
    EMPLOYEE_CODE VARCHAR(255),
    MANAGER_CODE VARCHAR(255),
    SENIOR_MANAGER_CODE VARCHAR(255),
    LEAD_MANAGER_CODE VARCHAR(255),
    COMPANY_CODE VARCHAR(255)
);

INSERT INTO COMPANY (COMPANY_CODE, FOUNDER) VALUES
('C1', 'Monika'),
('C2', 'Samantha');

INSERT INTO LEAD_MANAGER (LEAD_MANAGER_CODE, COMPANY_CODE) VALUES
('LM1', 'C1'),
('LM2', 'C2');

INSERT INTO SENIOR_MANAGER (SENIOR_MANAGER_CODE, LEAD_MANAGER_CODE, COMPANY_CODE) VALUES
('SM1', 'LM1', 'C1'),
('SM2', 'LM1', 'C1'),
('SM3', 'LM2', 'C2');

INSERT INTO MANAGER (MANAGER_CODE, SENIOR_MANAGER_CODE, LEAD_MANAGER_CODE, COMPANY_CODE) VALUES
('M1', 'SM1', 'LM1', 'C1'),
('M2', 'SM3', 'LM2', 'C2'),
('M3', 'SM3', 'LM2', 'C2');

INSERT INTO EMPLOYEE (EMPLOYEE_CODE, MANAGER_CODE, SENIOR_MANAGER_CODE, LEAD_MANAGER_CODE, COMPANY_CODE) VALUES
('E1', 'M1', 'SM1', 'LM1', 'C1'),
('E2', 'M1', 'SM1', 'LM1', 'C1'),
('E3', 'M2', 'SM3', 'LM2', 'C2'),
('E4', 'M3', 'SM3', 'LM2', 'C2');

SELECT 
    C.COMPANY_CODE,
    C.FOUNDER,
    COUNT(DISTINCT LM.LEAD_MANAGER_CODE) AS TOTAL_LEAD_MANAGERS,
    COUNT(DISTINCT SM.SENIOR_MANAGER_CODE) AS TOTAL_SENIOR_MANAGERS,
    COUNT(DISTINCT M.MANAGER_CODE) AS TOTAL_MANAGERS,
    COUNT(DISTINCT E.EMPLOYEE_CODE) AS TOTAL_EMPLOYEES
FROM 
    COMPANY C
LEFT JOIN 
    LEAD_MANAGER LM ON C.COMPANY_CODE = LM.COMPANY_CODE
LEFT JOIN 
    SENIOR_MANAGER SM ON LM.LEAD_MANAGER_CODE = SM.LEAD_MANAGER_CODE AND LM.COMPANY_CODE = SM.COMPANY_CODE
LEFT JOIN 
    MANAGER M ON SM.SENIOR_MANAGER_CODE = M.SENIOR_MANAGER_CODE AND SM.LEAD_MANAGER_CODE = M.LEAD_MANAGER_CODE AND SM.COMPANY_CODE = M.COMPANY_CODE
LEFT JOIN 
    EMPLOYEE E ON M.MANAGER_CODE = E.MANAGER_CODE AND M.SENIOR_MANAGER_CODE = E.SENIOR_MANAGER_CODE AND M.LEAD_MANAGER_CODE = E.LEAD_MANAGER_CODE AND M.COMPANY_CODE = E.COMPANY_CODE
GROUP BY 
    C.COMPANY_CODE, C.FOUNDER
ORDER BY 
    C.COMPANY_CODE;

--------------------------------------------------------------------------------------------------------

-- TASK 11
/*

Task 11. You are given three tables: Students, Friends and Packages. Students contains two
columns: ID and Name. Friends contains two columns: ID and Friend ID (ID of the ONLY best friend). Packages contains two columns: ID and Salary (offered salary in $ thousands per month).

Students
Column Туре
ID Integer
Name String

Friends
Column Туре
ID Integer
Friend_ID Integer

Packages
Column Туре
ID Integer
Salary Float

Write a query to output the names of those students whose best friends got offered a higher salary than them. Names must be ordered by the salary amount offered to the best friends. It is guaranteed that no two students got same salary offer.
Sample Input

Friends
ID Friend_ID
1 2
2 3
3 4
4 1

Students
ID Name
1 Ashley
2 Samantha
3 Julia
4 Scarlet

Packages
ID Salary
1 15.20
2 10.06
3 11.55
4 12.12

Sample Output
Samantha
Julia
Scarlet

*/

CREATE TABLE STUDENTS (
    ID INT,
    NAME VARCHAR(255)
);

CREATE TABLE FRIENDS (
    ID INT,
    FRIEND_ID INT
);

CREATE TABLE PACKAGES (
    ID INT,
    SALARY FLOAT
);

INSERT INTO STUDENTS (ID, NAME) VALUES
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');

INSERT INTO FRIENDS (ID, FRIEND_ID) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);

INSERT INTO PACKAGES (ID, SALARY) VALUES
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);

SELECT S.NAME
FROM STUDENTS S
JOIN FRIENDS F ON S.ID = F.ID
JOIN PACKAGES P1 ON F.FRIEND_ID = P1.ID
JOIN PACKAGES P2 ON S.ID = P2.ID
WHERE P1.SALARY > P2.SALARY
ORDER BY P1.SALARY;

------------------------------------------------------------------------------------------------------

-- Task 12. Display ratio of cost of job family in percentage by India and international (refer simulation data).

SELECT 
    'India' AS REGION,
    SUM(CASE WHEN REGION = 'India' THEN COST ELSE 0 END) / SUM(COST) * 100 AS INDIA_PERCENTAGE,
    'International' AS REGION,
    SUM(CASE WHEN REGION = 'International' THEN COST ELSE 0 END) / SUM(COST) * 100 AS INTERNATIONAL_PERCENTAGE
FROM 
    JOB_FAMILY;

------------------------------------------------------------------------------------------------------

-- Task 13. Find ratio of cost and revenue of a BU month on month.
SELECT 
    MONTH,
    BU,
    SUM(COST) / SUM(REVENUE) AS COST_REVENUE_RATIO
FROM 
    BU_MONTH_DATA
GROUP BY 
    MONTH, BU;
	
------------------------------------------------------------------------------------------------------

-- Task 14. Show headcounts of sub band and percentage of headcount (without join, subquery and inner query).
SELECT 
    SUB_BAND,
    COUNT(*) AS HEADCOUNT,
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM EMPLOYEES) AS PERCENTAGE_HEADCOUNT
FROM 
    EMPLOYEES
GROUP BY 
    SUB_BAND;
	
------------------------------------------------------------------------------------------------------

-- Task 15. Find top 5 employees according to salary (without order by).
SELECT TOP 5 
    EMPLOYEE_ID,
    SALARY
FROM 
    EMPLOYEES
ORDER BY 
    SALARY DESC;

------------------------------------------------------------------------------------------------------

-- Task 16. Swap value of two columns in a table without using third variable or a table.
UPDATE TABLE_NAME
SET COLUMN1 = COLUMN2,
    COLUMN2 = COLUMN1;

------------------------------------------------------------------------------------------------------

-- Task 17. Create a user, create a login for that user provide permissions of DB_owner to the user.
CREATE LOGIN NewLogin WITH PASSWORD = 'YourPassword';
USE YourDatabase;
CREATE USER NewUser FOR LOGIN NewLogin;
EXEC sp_addrolemember 'db_owner', 'NewUser';

------------------------------------------------------------------------------------------------------

-- Task 18. Find Weighted average cost of employees month on month in a BU.
SELECT 
    MONTH,
    BU,
    SUM(WEIGHTED_AVERAGE_COST * EMPLOYEE_COUNT) / SUM(EMPLOYEE_COUNT) AS WEIGHTED_AVERAGE_COST
FROM 
    BU_EMPLOYEE_DATA
GROUP BY 
    MONTH, BU;

------------------------------------------------------------------------------------------------------

/*

Task 19. Samantha was tasked with calculating the average monthly salaries for all employees in the EMPLOYEES table, but did not realize her keyboard's O key was broken until after completing the calculation. She wants your help finding the difference between her miscalculation (using salaries with any zeroes removed), and the actual average salary.
Write a query calculating the amount of error (i.e.: actual - miscalculated average monthly salaries), and round it up to the next integer.

*/

SELECT 
    CEILING(AVG(SALARY) - AVG(NULLIF(REPLACE(CAST(SALARY AS VARCHAR), '0', ''), ''))) AS ERROR_AMOUNT
FROM 
    EMPLOYEES;

------------------------------------------------------------------------------------------------------

/* Task 20. Copy new data of one table to another( you do not have indicator for new data and old data). */
INSERT INTO TARGET_TABLE
SELECT * FROM SOURCE_TABLE;

------------------------------------------------------------------------------------------------------