/*
Week 8 Assignment Submission 
User ID : CT_CSI_SQ_3376
*/

-- Create the date dimension table
CREATE TABLE DimDate (
    SKDate INT PRIMARY KEY, -- Format: YYYYMMDD
    KeyDate DATE,
    [Date] DATE,
    CalendarDay INT,
    CalendarMonth INT,
    CalendarQuarter INT,
    CalendarYear INT,
    DayNameLong VARCHAR(10),
    DayNameShort VARCHAR(3),
    DayNumberOfWeek INT,
    DayNumberOfYear INT,
    DaySuffix VARCHAR(4),
    FiscalWeek INT,
    FiscalPeriod INT,
    FiscalQuarter INT,
    FiscalYear INT,
    FiscalYearPeriod VARCHAR(7)
);

-- Create the stored procedure
CREATE PROCEDURE usp_PopulateDateDimension
    @StartDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Year INT = YEAR(@StartDate);
    DECLARE @StartOfYear DATE = DATEFROMPARTS(@Year, 1, 1);
    DECLARE @EndOfYear DATE = DATEFROMPARTS(@Year, 12, 31);
    
    -- Fiscal year configuration (assuming April is start of fiscal year)
    DECLARE @FiscalYearStartMonth INT = 4;
    
    -- Clear existing data for the year if any
    DELETE FROM DimDate 
    WHERE CalendarYear = @Year;
    
    -- Insert all dates for the year in a single statement
    INSERT INTO DimDate (
        SKDate,
        KeyDate,
        [Date],
        CalendarDay,
        CalendarMonth,
        CalendarQuarter,
        CalendarYear,
        DayNameLong,
        DayNameShort,
        DayNumberOfWeek,
        DayNumberOfYear,
        DaySuffix,
        FiscalWeek,
        FiscalPeriod,
        FiscalQuarter,
        FiscalYear,
        FiscalYearPeriod
    )
    SELECT 
        -- SKDate as YYYYMMDD integer
        CONVERT(INT, CONVERT(VARCHAR(8), d.DateValue, 112)) AS SKDate,
        
        -- Date in various formats
        d.DateValue AS KeyDate,
        d.DateValue AS [Date],
        
        -- Calendar components
        DAY(d.DateValue) AS CalendarDay,
        MONTH(d.DateValue) AS CalendarMonth,
        DATEPART(QUARTER, d.DateValue) AS CalendarQuarter,
        YEAR(d.DateValue) AS CalendarYear,
        
        -- Day names
        DATENAME(WEEKDAY, d.DateValue) AS DayNameLong,
        LEFT(DATENAME(WEEKDAY, d.DateValue), 3) AS DayNameShort,
        
        -- Day numbers
        DATEPART(WEEKDAY, d.DateValue) AS DayNumberOfWeek,
        DATEPART(DAYOFYEAR, d.DateValue) AS DayNumberOfYear,
        
        -- Day suffix (1st, 2nd, 3rd, etc.)
        CASE 
            WHEN DAY(d.DateValue) % 100 IN (11, 12, 13) THEN CAST(DAY(d.DateValue) AS VARCHAR) + 'th'
            WHEN DAY(d.DateValue) % 10 = 1 THEN CAST(DAY(d.DateValue) AS VARCHAR) + 'st'
            WHEN DAY(d.DateValue) % 10 = 2 THEN CAST(DAY(d.DateValue) AS VARCHAR) + 'nd'
            WHEN DAY(d.DateValue) % 10 = 3 THEN CAST(DAY(d.DateValue) AS VARCHAR) + 'rd'
            ELSE CAST(DAY(d.DateValue) AS VARCHAR) + 'th'
        END AS DaySuffix,
        
        -- Fiscal components (assuming fiscal weeks start on Monday)
        DATEDIFF(WEEK, 
            CASE 
                WHEN MONTH(d.DateValue) >= @FiscalYearStartMonth 
                THEN DATEFROMPARTS(YEAR(d.DateValue), @FiscalYearStartMonth, 1)
                ELSE DATEFROMPARTS(YEAR(d.DateValue) - 1, @FiscalYearStartMonth, 1)
            END, 
            d.DateValue) + 1 AS FiscalWeek,
            
        -- Fiscal period (month in fiscal year)
        CASE 
            WHEN MONTH(d.DateValue) >= @FiscalYearStartMonth 
            THEN MONTH(d.DateValue) - @FiscalYearStartMonth + 1
            ELSE MONTH(d.DateValue) + (12 - @FiscalYearStartMonth + 1)
        END AS FiscalPeriod,
        
        -- Fiscal quarter
        CASE 
            WHEN MONTH(d.DateValue) >= @FiscalYearStartMonth 
            THEN DATEPART(QUARTER, DATEADD(MONTH, -(@FiscalYearStartMonth-1), d.DateValue))
            ELSE DATEPART(QUARTER, DATEADD(MONTH, (12 - @FiscalYearStartMonth + 1), d.DateValue))
        END AS FiscalQuarter,
        
        -- Fiscal year
        CASE 
            WHEN MONTH(d.DateValue) >= @FiscalYearStartMonth 
            THEN YEAR(d.DateValue)
            ELSE YEAR(d.DateValue) - 1
        END AS FiscalYear,
        
        -- Fiscal year/period
        CONCAT(
            CASE 
                WHEN MONTH(d.DateValue) >= @FiscalYearStartMonth 
                THEN YEAR(d.DateValue)
                ELSE YEAR(d.DateValue) - 1
            END,
            CASE 
                WHEN MONTH(d.DateValue) >= @FiscalYearStartMonth 
                THEN MONTH(d.DateValue) - @FiscalYearStartMonth + 1
                ELSE MONTH(d.DateValue) + (12 - @FiscalYearStartMonth + 1)
            END
        ) AS FiscalYearPeriod
    FROM (
        -- Generate all dates for the year
        SELECT DATEADD(DAY, number, @StartOfYear) AS DateValue
        FROM master.dbo.spt_values
        WHERE type = 'P' 
        AND number BETWEEN 0 AND DATEDIFF(DAY, @StartOfYear, @EndOfYear)
    ) d;
    
    PRINT 'Successfully populated date dimension for year ' + CAST(@Year AS VARCHAR);
END;
GO

-- Execute the procedure for a specific date (e.g., July 14, 2020)
EXEC usp_PopulateDateDimension '2020-07-14';

-- Verify the results
SELECT * FROM DimDate ORDER BY [Date];
