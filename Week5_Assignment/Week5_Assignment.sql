/*
Week 5 Assignment Submission
User ID : CT_CSI_SQ_3376
*/

-- Create the SubjectAllotments table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='SubjectAllotments' AND xtype='U')
BEGIN
    CREATE TABLE SubjectAllotments (
        StudentID VARCHAR(20),
        SubjectID VARCHAR(20),
        Is_Valid BIT,
        CONSTRAINT PK_SubjectAllotments PRIMARY KEY (StudentID, SubjectID)
    );
END
GO

-- Create the SubjectRequest table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='SubjectRequest' AND xtype='U')
BEGIN
    CREATE TABLE SubjectRequest (
        StudentID VARCHAR(20),
        SubjectID VARCHAR(20),
        CONSTRAINT PK_SubjectRequest PRIMARY KEY (StudentID, SubjectID)
    );
END
GO

-- Create the stored procedure to process subject requests
CREATE OR ALTER PROCEDURE ProcessSubjectRequests
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StudentID VARCHAR(20);
    DECLARE @SubjectID VARCHAR(20);
    DECLARE @CurrentValidSubjectID VARCHAR(20);
    
    -- Cursor to iterate through all subject change requests
    DECLARE request_cursor CURSOR FOR 
    SELECT StudentID, SubjectID FROM SubjectRequest;
    
    OPEN request_cursor;
    FETCH NEXT FROM request_cursor INTO @StudentID, @SubjectID;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if the student exists in SubjectAllotments
        IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentID = @StudentID)
        BEGIN
            -- Get the current valid subject for the student
            SELECT @CurrentValidSubjectID = SubjectID 
            FROM SubjectAllotments 
            WHERE StudentID = @StudentID AND Is_Valid = 1;
            
            -- Only process if the requested subject is different from current valid subject
            IF @CurrentValidSubjectID <> @SubjectID OR @CurrentValidSubjectID IS NULL
            BEGIN
                BEGIN TRANSACTION;
                
                -- Set all existing records for this student to invalid
                UPDATE SubjectAllotments 
                SET Is_Valid = 0 
                WHERE StudentID = @StudentID;
                
                -- Check if the requested subject already exists for this student
                IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentID = @StudentID AND SubjectID = @SubjectID)
                BEGIN
                    -- Update existing record to valid
                    UPDATE SubjectAllotments 
                    SET Is_Valid = 1 
                    WHERE StudentID = @StudentID AND SubjectID = @SubjectID;
                END
                ELSE
                BEGIN
                    -- Insert new record as valid
                    INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
                    VALUES (@StudentID, @SubjectID, 1);
                END
                
                COMMIT TRANSACTION;
            END
        END
        ELSE
        BEGIN
            -- Student doesn't exist in SubjectAllotments, insert new record as valid
            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
            VALUES (@StudentID, @SubjectID, 1);
        END
        
        -- Delete the processed request
        DELETE FROM SubjectRequest WHERE StudentID = @StudentID AND SubjectID = @SubjectID;
        
        FETCH NEXT FROM request_cursor INTO @StudentID, @SubjectID;
    END
    
    CLOSE request_cursor;
    DEALLOCATE request_cursor;
    
    SET NOCOUNT OFF;
END;
GO

-- Clear existing data (if any)
DELETE FROM SubjectAllotments;
DELETE FROM SubjectRequest;

-- Insert initial data
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
VALUES 
    ('159103036', 'PO1491', 1),
    ('159103036', 'PO1492', 0),
    ('159103036', 'PO1493', 0),
    ('159103036', 'PO1494', 0),
    ('159103036', 'PO1495', 0);

-- Add a subject change request
INSERT INTO SubjectRequest (StudentID, SubjectID)
VALUES ('159103036', 'PO1496');

-- Check SubjectAllotments before
SELECT * FROM SubjectAllotments WHERE StudentID = '159103036' ORDER BY Is_Valid DESC;

-- Check SubjectRequest before
SELECT * FROM SubjectRequest;

EXEC ProcessSubjectRequests;

-- Check SubjectAllotments after
SELECT * FROM SubjectAllotments WHERE StudentID = '159103036' ORDER BY Is_Valid DESC;

-- Check SubjectRequest after (should be empty)
SELECT * FROM SubjectRequest;
