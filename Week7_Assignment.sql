/*
Task 7 Submission
User ID : CT_CSI_SQ_3376
*/

-- Main Dimension Table
CREATE TABLE dim_customer (
    surrogate_key INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    name VARCHAR(100),
    email VARCHAR(100),
    address VARCHAR(200),
    previous_address VARCHAR(200) NULL,        -- For SCD3/SCD6
    valid_from DATETIME NULL,                  -- For SCD2/SCD6
    valid_to DATETIME NULL,
    is_current BIT DEFAULT 1                   -- For SCD2/SCD6
);

-- Staging Table (new/updated records from source)
CREATE TABLE stg_customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    address VARCHAR(200)
);

-- History Table (for SCD4)
CREATE TABLE dim_customer_history (
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    name VARCHAR(100),
    email VARCHAR(100),
    address VARCHAR(200),
    changed_date DATETIME
);




-- Initial Data in Dimension Table
INSERT INTO dim_customer (customer_id, name, email, address, valid_from, valid_to, is_current)
VALUES 
(1, 'John Doe', 'john@example.com', 'New York', GETDATE(), NULL, 1),
(2, 'Jane Smith', 'jane@example.com', 'Los Angeles', GETDATE(), NULL, 1);

-- New/Updated Data in Staging Table
-- John moved from New York to Chicago
-- Jane's email updated
-- New customer added
INSERT INTO stg_customer (customer_id, name, email, address)
VALUES 
(1, 'John Doe', 'john@example.com', 'Chicago'),
(2, 'Jane Smith', 'jane_new@example.com', 'Los Angeles'),
(3, 'Alice Brown', 'alice@example.com', 'Boston');


CREATE PROCEDURE sp_scd_type_0
AS
BEGIN
    PRINT 'SCD Type 0 - No changes applied.';
END;

CREATE PROCEDURE sp_scd_type_1
AS
BEGIN
    MERGE INTO dim_customer AS target
    USING stg_customer AS source
    ON target.customer_id = source.customer_id
    WHEN MATCHED AND (
        ISNULL(target.name, '') <> ISNULL(source.name, '') OR
        ISNULL(target.email, '') <> ISNULL(source.email, '') OR
        ISNULL(target.address, '') <> ISNULL(source.address, '')
    )
    THEN UPDATE SET
        name = source.name,
        email = source.email,
        address = source.address
    WHEN NOT MATCHED BY TARGET THEN
    INSERT (customer_id, name, email, address)
    VALUES (source.customer_id, source.name, source.email, source.address);
END;

CREATE PROCEDURE sp_scd_type_2
AS
BEGIN
    DECLARE @now DATETIME = GETDATE();

    -- Expire current version
    UPDATE dim_customer
    SET valid_to = @now, is_current = 0
    FROM dim_customer d
    JOIN stg_customer s ON d.customer_id = s.customer_id
    WHERE d.is_current = 1 AND (
        ISNULL(d.name, '') <> ISNULL(s.name, '') OR
        ISNULL(d.email, '') <> ISNULL(s.email, '') OR
        ISNULL(d.address, '') <> ISNULL(s.address, '')
    );

    -- Insert new version
    INSERT INTO dim_customer (customer_id, name, email, address, valid_from, valid_to, is_current)
    SELECT s.customer_id, s.name, s.email, s.address, @now, NULL, 1
    FROM stg_customer s
    WHERE NOT EXISTS (
        SELECT 1 FROM dim_customer d
        WHERE d.customer_id = s.customer_id AND d.is_current = 1 AND
        ISNULL(d.name, '') = ISNULL(s.name, '') AND
        ISNULL(d.email, '') = ISNULL(s.email, '') AND
        ISNULL(d.address, '') = ISNULL(s.address, '')
    );
END;

CREATE PROCEDURE sp_scd_type_3
AS
BEGIN
    MERGE INTO dim_customer AS target
    USING stg_customer AS source
    ON target.customer_id = source.customer_id
    WHEN MATCHED AND target.address <> source.address
    THEN UPDATE SET 
        previous_address = target.address,
        address = source.address
    WHEN NOT MATCHED BY TARGET THEN
    INSERT (customer_id, name, email, address)
    VALUES (source.customer_id, source.name, source.email, source.address);
END;


CREATE PROCEDURE sp_scd_type_4
AS
BEGIN
    -- Archive old data
    INSERT INTO dim_customer_history (customer_id, name, email, address, changed_date)
    SELECT d.customer_id, d.name, d.email, d.address, GETDATE()
    FROM dim_customer d
    JOIN stg_customer s ON d.customer_id = s.customer_id
    WHERE d.address <> s.address;

    -- Update main dim table
    UPDATE d
    SET d.name = s.name,
        d.email = s.email,
        d.address = s.address
    FROM dim_customer d
    JOIN stg_customer s ON d.customer_id = s.customer_id;

    -- Insert new customers
    INSERT INTO dim_customer (customer_id, name, email, address)
    SELECT s.customer_id, s.name, s.email, s.address
    FROM stg_customer s
    WHERE NOT EXISTS (
        SELECT 1 FROM dim_customer d WHERE d.customer_id = s.customer_id
    );
END;

CREATE PROCEDURE sp_scd_type_6
AS
BEGIN
    DECLARE @now DATETIME = GETDATE();

    -- Expire current rows
    UPDATE dim_customer
    SET valid_to = @now, is_current = 0
    FROM dim_customer d
    JOIN stg_customer s ON d.customer_id = s.customer_id
    WHERE d.is_current = 1 AND d.address <> s.address;

    -- Insert new row with updated address, and store previous address
    INSERT INTO dim_customer (customer_id, name, email, address, previous_address, valid_from, valid_to, is_current)
    SELECT s.customer_id, s.name, s.email, s.address, d.address, @now, NULL, 1
    FROM stg_customer s
    JOIN dim_customer d ON s.customer_id = d.customer_id
    WHERE d.is_current = 0 AND d.valid_to = @now;

    -- Insert new customers
    INSERT INTO dim_customer (customer_id, name, email, address, previous_address, valid_from, valid_to, is_current)
    SELECT s.customer_id, s.name, s.email, s.address, NULL, @now, NULL, 1
    FROM stg_customer s
    WHERE NOT EXISTS (
        SELECT 1 FROM dim_customer d WHERE d.customer_id = s.customer_id
    );
END;


EXEC sp_scd_type_1;
EXEC sp_scd_type_2;
EXEC sp_scd_type_3;
