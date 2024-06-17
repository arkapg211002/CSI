/*

Problem Statement:
A college needs to develop a system that tracksthe Open Elective Subjectsof their students. During the start of the year a lot of students changetheirsubjectsand college wants to preserve that entire timeline of the data.
For example, Mohit had selected“Eco philosophy”as his Open Elective subject but laterhewished to switch to “Basics of Accounting”in this scenariothe college wants the visibilityof Mohit’s previous choice as well instead of just the active one:
There is one table that holdsthe record of this change,and it is called SubjectAllotments
The below table has the subject to student mapping with the preference
Note: The details of the columns are as following:
•StudentIDvarchar
•SubjectID varchar
•Is_Valid  bit

(Table Name: SubjectAllotments)
StudentId SubjectId Is_valid 
159103036 PO1491 1 
159103036 PO1492 0 
159103036 PO1493 0
159103036 PO1494 0
159103036 PO1495 0
In the above example we can see the student’s active subject is “PO1491”but at some pointthe student was allotted other subjects.
When a student requests an allotment the request details are stored in a table called“SubjectRequest”

(Table Name: SubjectRequest)
StudentId SubjectId
159103036 PO1496
We can see that the student has requested a change.
Here we have to check thecurrent subject of the student(where is_valid=1)is different from the request or not, if the subject is different we insert another record inthe table making thenew record valid and changing the previously validrecord to invalid, the output is indicated in the below table:

(Table Name: SubjectAlottments)
StudentId SubjectId Is_valid
159103036 PO1496 1 
159103036 PO1491 0 
159103036 PO1492 0
159103036 PO1493 0
159103036 PO1494 0
159103036 PO1495 0 
If the student idthat is presentin the SubjectRequest Table doesnot exist in the SubjectAlottments table then we simply insert the requested subject as avalid recordin the SubjectAllotments Table
Your Task is to write a Stored Procedure to implement the above stated workflow.

*/

-- CREATE TABLES
CREATE TABLE SUBJECTALLOTMENTS (
    STUDENTID VARCHAR(50),
    SUBJECTID VARCHAR(50),
    IS_VALID BIT
);

CREATE TABLE SUBJECTREQUEST (
    STUDENTID VARCHAR(50),
    SUBJECTID VARCHAR(50)
);

-- INSERT VALUES
INSERT INTO SUBJECTALLOTMENTS (STUDENTID, SUBJECTID, IS_VALID)
VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 0),
('159103036', 'PO1493', 0),
('159103036', 'PO1494', 0),
('159103036', 'PO1495', 0);

INSERT INTO SUBJECTREQUEST (STUDENTID, SUBJECTID)
VALUES
('159103036', 'PO1496');

-- STORED PROCEDURE
CREATE PROCEDURE UPDATE_SUBJECT_ALLOTMENTS
AS
BEGIN
    DECLARE @STUDENTID VARCHAR(50);
    DECLARE @SUBJECTID VARCHAR(50);
    DECLARE SUBJECT_REQUEST_CURSOR CURSOR FOR
    SELECT STUDENTID, SUBJECTID FROM SUBJECTREQUEST;
    OPEN SUBJECT_REQUEST_CURSOR;
    FETCH NEXT FROM SUBJECT_REQUEST_CURSOR INTO @STUDENTID, @SUBJECTID;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM SUBJECTALLOTMENTS WHERE STUDENTID = @STUDENTID AND IS_VALID = 1)
        BEGIN
            DECLARE @CURRENT_SUBJECTID VARCHAR(50);
            SELECT @CURRENT_SUBJECTID = SUBJECTID FROM SUBJECTALLOTMENTS WHERE STUDENTID = @STUDENTID AND IS_VALID = 1;
            IF @CURRENT_SUBJECTID != @SUBJECTID
            BEGIN
                UPDATE SUBJECTALLOTMENTS
                SET IS_VALID = 0
                WHERE STUDENTID = @STUDENTID AND IS_VALID = 1;
                INSERT INTO SUBJECTALLOTMENTS (STUDENTID, SUBJECTID, IS_VALID)
                VALUES (@STUDENTID, @SUBJECTID, 1);
            END
        END
        ELSE
        BEGIN
            INSERT INTO SUBJECTALLOTMENTS (STUDENTID, SUBJECTID, IS_VALID)
            VALUES (@STUDENTID, @SUBJECTID, 1);
        END
        FETCH NEXT FROM SUBJECT_REQUEST_CURSOR INTO @STUDENTID, @SUBJECTID;
    END

    CLOSE SUBJECT_REQUEST_CURSOR;
    DEALLOCATE SUBJECT_REQUEST_CURSOR;
    DELETE FROM SUBJECTREQUEST;
END;

-- EXECUTE THE STORED PROCEDURE
EXEC UPDATE_SUBJECT_ALLOTMENTS;
