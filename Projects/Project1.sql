/*

Create a stored procedure to get the number of hours between two dates having a DateTime format. You should exclude all Sundays and 1st and 2nd Saturdays if it comes within the date range. either of the input dates are Sunday or the 1st or 2nd Saturday, then include that particular date too. Stored procedure will have two input parameters - Start_Date and End_Date.
Execute your stored procedure only for the below dates and store the result in a table named counttotalworkinhours in the below format.
Sample input parameters.
START_DATE END_DATE
2023-07-12 2023-07-13
2023-07-01 2023-07-17

Sample Output
START_DATE END_DATE NO_OF_HOURS
2023-07-01 2023-07-17 288
2023-07-12 2023-07-13 24

*/

CREATE PROCEDURE CalculateWorkingHours
    @Start_Date DATETIME,
    @End_Date DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TotalHours INT;
    SELECT @TotalHours = DATEDIFF(HOUR, @Start_Date, @End_Date);
    SELECT @TotalHours = @TotalHours - (DATEDIFF(WEEK, @Start_Date, @End_Date) * 24 * 1);
    SELECT @TotalHours = @TotalHours - (DATEDIFF(WEEK, @Start_Date, @End_Date) * 24 * 2);
    IF (DATEPART(WEEKDAY, @Start_Date) = 1 OR DATEPART(WEEKDAY, @Start_Date) = 7)
        OR (DATEPART(WEEKDAY, @End_Date) = 1 OR DATEPART(WEEKDAY, @End_Date) = 7)
    BEGIN
        SELECT @TotalHours = @TotalHours + 24;
    END;
    INSERT INTO counttotalworkinhours (START_DATE, END_DATE, NO_OF_HOURS)
    VALUES (@Start_Date, @End_Date, @TotalHours);
END;
