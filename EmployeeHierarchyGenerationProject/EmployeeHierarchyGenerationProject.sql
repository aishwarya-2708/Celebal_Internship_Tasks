/*
Employee Hierarchy Generation Project Submission
User ID : CT_CSI_SQ_3376
*/

DROP TABLE IF EXISTS EMPLOYEE_MASTER;
CREATE TABLE EMPLOYEE_MASTER (
    EmployeeID VARCHAR(20),
    ReportingTo NVARCHAR(MAX),
    EmailID NVARCHAR(MAX)
);

-- Sample insertion --
INSERT INTO EMPLOYEE_MASTER VALUES
('H1', NULL, 'john.doe@example.com'),
('H2', NULL, 'jane.smith@example.com'),
('H3', 'John Smith H1', 'alice.jones@example.com'),
('H4', 'Jane Doe H1', 'bob.white@example.com'),
('H5', 'John Smith H3', 'charlie.brown@example.com'),
('H6', 'Jane Doe H3', 'david.green@example.com'),
('H7', 'John Smith H4', 'emily.gray@example.com'),
('H8', 'Jane Doe H4', 'frank.wilson@example.com'),
('H9', 'John Smith H5', 'george.harris@example.com'),
('H10', 'Jane Doe H5', 'hannah.taylor@example.com'),
('H11', 'John Smith H6', 'irene.martin@example.com'),
('H12', 'Jane Doe H6', 'jack.roberts@example.com'),
('H13', 'John Smith H7', 'kate.evans@example.com'),
('H14', 'Jane Doe H7', 'laura.hall@example.com'),
('H15', 'John Smith H8', 'mike.anderson@example.com'),
('H16', 'Jane Doe H8', 'natalie.clark@example.com'),
('H17', 'John Smith H9', 'oliver.davis@example.com'),
('H18', 'Jane Doe H9', 'peter.edwards@example.com'),
('H19', 'John Smith H10', 'quinn.fisher@example.com'),
('H20', 'Jane Doe H10', 'rachel.garcia@example.com'),
('H21', 'John Smith H11', 'sarah.hernandez@example.com'),
('H22', 'Jane Doe H11', 'thomas.lee@example.com'),
('H23', 'John Smith H12', 'ursula.lopez@example.com'),
('H24', 'Jane Doe H12', 'victor.martinez@example.com'),
('H25', 'John Smith H13', 'william.nguven@example.com'),
('H26', 'Jane Doe H13', 'xavier.ortiz@example.com'),
('H27', 'John Smith H14', 'yvonne.perez@example.com'),
('H28', 'Jane Doe H14', 'zoe.quinn@example.com'),
('H29', 'John Smith H15', 'adam.robinson@example.com'),
('H30', 'Jane Doe H15', 'barbara.smith@example.com');


DROP FUNCTION IF EXISTS dbo.LAST_NAME;
GO

CREATE FUNCTION dbo.LAST_NAME (@email NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN SUBSTRING(
        @email,
        CHARINDEX('.', @email) + 1,
        CHARINDEX('@', @email) - CHARINDEX('.', @email) - 1
    )
END
GO

DROP FUNCTION IF EXISTS dbo.FIRST_NAME;
GO

CREATE FUNCTION dbo.FIRST_NAME (@email NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN LEFT(@email, CHARINDEX('.', @email) - 1)
END
GO

DROP TABLE IF EXISTS Employee_Hierarchy;
CREATE TABLE Employee_Hierarchy (
    EMPLOYEEID VARCHAR(20),
    REPORTINGTO NVARCHAR(MAX),
    EMAILID NVARCHAR(MAX),
    LEVEL INT,
    FIRSTNAME NVARCHAR(MAX),
    LASTNAME NVARCHAR(MAX)
);

CREATE OR ALTER PROCEDURE SP_hierarchy
AS
BEGIN
    -- Clear the target table
    TRUNCATE TABLE Employee_Hierarchy;

    -- Recursive CTE to build the hierarchy
    WITH EmployeeCTE AS (
        -- Base Case: Top-level employees
        SELECT 
            EmployeeID,
            ReportingTo,
            EmailID,
            1 AS Level
        FROM EMPLOYEE_MASTER
        WHERE ReportingTo IS NULL

        UNION ALL

        -- Recursive Case: Match by EmployeeID from ReportingTo string
        SELECT 
            em.EmployeeID,
            em.ReportingTo,
            em.EmailID,
            ec.Level + 1
        FROM EMPLOYEE_MASTER em
        JOIN EmployeeCTE ec 
            ON RIGHT(LTRIM(RTRIM(em.ReportingTo)), LEN(ec.EmployeeID)) = ec.EmployeeID
    )

    -- Insert final result
    INSERT INTO Employee_Hierarchy (EMPLOYEEID, REPORTINGTO, EMAILID, LEVEL, FIRSTNAME, LASTNAME)
    SELECT 
        EmployeeID,
        ReportingTo,
        EmailID,
        Level,
        dbo.FIRST_NAME(EmailID),
        dbo.LAST_NAME(EmailID)
    FROM EmployeeCTE;
END
GO

EXEC SP_hierarchy;

SELECT * FROM Employee_Hierarchy ORDER BY LEVEL, EMPLOYEEID;
