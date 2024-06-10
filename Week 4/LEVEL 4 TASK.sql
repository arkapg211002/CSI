/*

Problem Statement:A college needs to develop a system to allocate Open Elective Subjects to its respective students. The way the system would work is that each student is allowed 5 choices with the respective preference, where number 1 indicates the first preference, number 2 indicates second preference and so on,the subjects are supposed tobe allotted on the basis of the Student’s GPA, which means the student with the students with the highest GPAs are allotted the subject they want. Every subject has a limited number of seats so if a subject has 60 seatsand all of them are filled then the student would not be allotted his first preference but instead second would be checked,if the second preference is full as well then the third preference would be checked, this process would be repeated till the student is allotted a subjectof his/her choice. If in case all the preferences that the student has selected are already full, then the student would be considered as unallotted and would be marked so.For example, Mohit has filled his 5 choices with the respective preferences and they are as following:The below table has the subject to student mapping with the preference

Note:StudentId and SubjectId are foreign keys in this table.
Constraints: A single Student cannot select the same subject twice. 

(Table Name: StudentPreference)
StudentId SubjectId Preference
159103036 PO1491 1
159103036 PO1492 2
159103036 PO1493 3
159103036 PO1494 4
159103036 PO1495 5

The below table has the details of subjects such as Subject Id, Subject name,and the maximum number of seats
Note: SubjectId is the primary key for this table

(Table Name: SubjectDetails)
SubjectId SubjectName MaxSeats RemainingSeats
PO1491 Basics of Political Science 60 2
PO1492 Basics of Accounting 120 119
PO1493 Basics of Financial Markets 90 90
PO1494 Eco philosophy 60 50
PO1495 Automotive Trends 60 60

The below table has the student Details such as StudentId, StudentName, GPA and their Branch:
Note: StudentId is the primary key for this table

(Table Name: StudentDetails)
StudentId StudentName GPA Branch Section
159103036 Mohit Agarwal 8.9 CCE A
159103037 Rohit Agarwal 5.2 CCE A
159103038 Shohit Garg 7.1 CCE B
159103039 Mrinal Malhotra 7.9 CCE A
159103040 Mehreet Singh 5.6 CCE A
159103041 Arjun Tehlan 9.2 CCE B

Final Resultant Table if the student has been allotted to a subject:

(Table Name: Allotments)
SubjectId StudentId
PO1491 159103036

Final Resultant Table if the student is unallotted:

(Table Name: UnallotedStudents)
StudentId
159103036

Your Task is to write a Stored Procedure to assign all the studentsto a respective subjectaccording the above stated workflow.

*/

-- Create table for Student Preferences
CREATE TABLE STUDENTPREFERENCE (
    STUDENTID INT,
    SUBJECTID VARCHAR(10),
    PREFERENCE INT,
    CONSTRAINT FK_STUDENT FOREIGN KEY (STUDENTID) REFERENCES STUDENTDETAILS(STUDENTID),
    CONSTRAINT FK_SUBJECT FOREIGN KEY (SUBJECTID) REFERENCES SUBJECTDETAILS(SUBJECTID),
    CONSTRAINT UNIQUE_STUDENT_SUBJECT UNIQUE (STUDENTID, SUBJECTID)
);

-- Create table for Subject Details
CREATE TABLE SUBJECTDETAILS (
    SUBJECTID VARCHAR(10) PRIMARY KEY,
    SUBJECTNAME VARCHAR(100),
    MAXSEATS INT,
    REMAININGSEATS INT
);

-- Create table for Student Details
CREATE TABLE STUDENTDETAILS (
    STUDENTID INT PRIMARY KEY,
    STUDENTNAME VARCHAR(100),
    GPA FLOAT,
    BRANCH VARCHAR(10),
    SECTION CHAR(1)
);

-- Create table for Allotments
CREATE TABLE ALLOTMENTS (
    SUBJECTID VARCHAR(10),
    STUDENTID INT,
    CONSTRAINT FK_ALLOT_SUBJECT FOREIGN KEY (SUBJECTID) REFERENCES SUBJECTDETAILS(SUBJECTID),
    CONSTRAINT FK_ALLOT_STUDENT FOREIGN KEY (STUDENTID) REFERENCES STUDENTDETAILS(STUDENTID)
);

-- Create table for Unallotted Students
CREATE TABLE UNALLOTEDSTUDENTS (
    STUDENTID INT,
    CONSTRAINT FK_UNALLOT_STUDENT FOREIGN KEY (STUDENTID) REFERENCES STUDENTDETAILS(STUDENTID)
);

-- Insert sample data into Subject Details
INSERT INTO SUBJECTDETAILS (SUBJECTID, SUBJECTNAME, MAXSEATS, REMAININGSEATS) VALUES
('PO1491', 'Basics of Political Science', 60, 2),
('PO1492', 'Basics of Accounting', 120, 119),
('PO1493', 'Basics of Financial Markets', 90, 90),
('PO1494', 'Eco philosophy', 60, 50),
('PO1495', 'Automotive Trends', 60, 60);

-- Insert sample data into Student Details
INSERT INTO STUDENTDETAILS (STUDENTID, STUDENTNAME, GPA, BRANCH, SECTION) VALUES
(159103036, 'Mohit Agarwal', 8.9, 'CCE', 'A'),
(159103037, 'Rohit Agarwal', 5.2, 'CCE', 'A'),
(159103038, 'Shohit Garg', 7.1, 'CCE', 'B'),
(159103039, 'Mrinal Malhotra', 7.9, 'CCE', 'A'),
(159103040, 'Mehreet Singh', 5.6, 'CCE', 'A'),
(159103041, 'Arjun Tehlan', 9.2, 'CCE', 'B');

-- Insert sample data into Student Preferences
INSERT INTO STUDENTPREFERENCE (STUDENTID, SUBJECTID, PREFERENCE) VALUES
(159103036, 'PO1491', 1),
(159103036, 'PO1492', 2),
(159103036, 'PO1493', 3),
(159103036, 'PO1494', 4),
(159103036, 'PO1495', 5);

-- Stored Procedure to allocate subjects based on GPA and preference
CREATE PROCEDURE ALLOCATE_SUBJECTS AS
BEGIN
    DECLARE @STUDENTID INT, @SUBJECTID VARCHAR(10), @PREFERENCE INT, @GPA FLOAT;

    -- Create a cursor to iterate over students ordered by GPA DESC
    DECLARE STUDENT_CURSOR CURSOR FOR
    SELECT STUDENTID, GPA FROM STUDENTDETAILS ORDER BY GPA DESC;

    OPEN STUDENT_CURSOR;
    FETCH NEXT FROM STUDENT_CURSOR INTO @STUDENTID, @GPA;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE PREFERENCE_CURSOR CURSOR FOR
        SELECT SUBJECTID FROM STUDENTPREFERENCE WHERE STUDENTID = @STUDENTID ORDER BY PREFERENCE ASC;

        OPEN PREFERENCE_CURSOR;
        FETCH NEXT FROM PREFERENCE_CURSOR INTO @SUBJECTID;

        DECLARE @ALLOTTED BIT = 0;

        WHILE @@FETCH_STATUS = 0 AND @ALLOTTED = 0
        BEGIN
            DECLARE @REMAININGSEATS INT;
            SELECT @REMAININGSEATS = REMAININGSEATS FROM SUBJECTDETAILS WHERE SUBJECTID = @SUBJECTID;

            IF @REMAININGSEATS > 0
            BEGIN
                -- Allocate the subject to the student
                INSERT INTO ALLOTMENTS (SUBJECTID, STUDENTID) VALUES (@SUBJECTID, @STUDENTID);

                -- Update the remaining seats
                UPDATE SUBJECTDETAILS SET REMAININGSEATS = REMAININGSEATS - 1 WHERE SUBJECTID = @SUBJECTID;

                SET @ALLOTTED = 1;
            END

            FETCH NEXT FROM PREFERENCE_CURSOR INTO @SUBJECTID;
        END

        CLOSE PREFERENCE_CURSOR;
        DEALLOCATE PREFERENCE_CURSOR;

        IF @ALLOTTED = 0
        BEGIN
            -- Mark student as unallotted
            INSERT INTO UNALLOTEDSTUDENTS (STUDENTID) VALUES (@STUDENTID);
        END

        FETCH NEXT FROM STUDENT_CURSOR INTO @STUDENTID, @GPA;
    END

    CLOSE STUDENT_CURSOR;
    DEALLOCATE STUDENT_CURSOR;
END;
