/*
Task 4 Submission 
User ID : CT_CSI_SQ_3376
*/

CREATE TABLE StudentDetails (
    StudentId VARCHAR(20) PRIMARY KEY,
    StudentName VARCHAR(100),
    GPA FLOAT,
    Branch VARCHAR(50),
    Section VARCHAR(10)
);
CREATE TABLE SubjectDetails (
    SubjectId VARCHAR(20) PRIMARY KEY,
    SubjectName VARCHAR(100),
    MaxSeats INT,
    RemainingSeats INT
);
CREATE TABLE StudentPreference (
    StudentId VARCHAR(20),
    SubjectId VARCHAR(20),
    Preference INT,
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId)
);
CREATE TABLE Allotments (
    SubjectId VARCHAR(20),
    StudentId VARCHAR(20),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);
CREATE TABLE UnallotedStudents (
    StudentId VARCHAR(20),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);

INSERT INTO SubjectDetails (SubjectId, SubjectName, MaxSeats, RemainingSeats) VALUES
('PO1491', 'Basics of Political Science', 60, 2),
('PO1492', 'Basics of Accounting', 120, 119),
('PO1493', 'Basics of Financial Markets', 90, 90),
('PO1494', 'Eco philosophy', 60, 50),
('PO1495', 'Automotive Trends', 60, 60);

INSERT INTO StudentDetails (StudentId, StudentName, GPA, Branch, Section) VALUES
('159103036', 'Mohit Agarwal', 8.9, 'CCE', 'A'),
('159103037', 'Rohit Agarwal', 5.2, 'CCE', 'A'),
('159103038', 'Shohit Garg', 7.1, 'CCE', 'B'),
('159103039', 'Mrinal Malhotra', 7.9, 'CCE', 'A'),
('159103040', 'Mehreet Singh', 5.6, 'CCE', 'A'),
('159103041', 'Arjun Tehlan', 9.2, 'CCE', 'B');
-- Preferences for Mohit

INSERT INTO StudentPreference (StudentId, SubjectId, Preference) VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 2),
('159103036', 'PO1493', 3),
('159103036', 'PO1494', 4),
('159103036', 'PO1495', 5);

-- Preferences for Arjun Tehlan
INSERT INTO StudentPreference (StudentId, SubjectId, Preference) VALUES
('159103041', 'PO1491', 1),
('159103041', 'PO1492', 2),
('159103041', 'PO1493', 3),
('159103041', 'PO1494', 4),
('159103041', 'PO1495', 5);


CREATE PROCEDURE AllocateSubjects
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StudentId VARCHAR(20);
    DECLARE @SubjectId VARCHAR(20);
    DECLARE @Preference INT;
    DECLARE @RemainingSeats INT;
    DECLARE @Allotted BIT;

    -- Clear previous data
    DELETE FROM Allotments;
    DELETE FROM UnallotedStudents;

    -- Cursor to loop over students ordered by GPA descending
    DECLARE student_cursor CURSOR FOR
        SELECT StudentId FROM StudentDetails ORDER BY GPA DESC;

    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @StudentId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Allotted = 0;
        SET @Preference = 1;

        WHILE @Preference <= 5 AND @Allotted = 0
        BEGIN
            -- Get subject of current preference
            SELECT @SubjectId = SubjectId
            FROM StudentPreference
            WHERE StudentId = @StudentId AND Preference = @Preference;

            IF @SubjectId IS NOT NULL
            BEGIN
                -- Get remaining seats
                SELECT @RemainingSeats = RemainingSeats
                FROM SubjectDetails
                WHERE SubjectId = @SubjectId;

                IF @RemainingSeats IS NOT NULL AND @RemainingSeats > 0
                BEGIN
                    -- Allot the subject
                    INSERT INTO Allotments (SubjectId, StudentId)
                    VALUES (@SubjectId, @StudentId);

                    -- Decrease the seat count
                    UPDATE SubjectDetails
                    SET RemainingSeats = RemainingSeats - 1
                    WHERE SubjectId = @SubjectId;

                    SET @Allotted = 1;
                END
            END

            SET @Preference = @Preference + 1;
        END

        -- If not allotted to any subject
        IF @Allotted = 0
        BEGIN
            INSERT INTO UnallotedStudents (StudentId)
            VALUES (@StudentId);
        END

        FETCH NEXT FROM student_cursor INTO @StudentId;
    END

    CLOSE student_cursor;
    DEALLOCATE student_cursor;
END;


EXEC AllocateSubjects;

SELECT * FROM Allotments;

SELECT * FROM UnallotedStudents;
