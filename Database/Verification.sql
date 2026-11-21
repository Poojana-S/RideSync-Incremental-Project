-- VERIFY DATABASE SCHEMA

-- 1. TEST UNIQUE CONSTRAINT
-- Test 1A: Valid unique plate number
BEGIN TRANSACTION

INSERT INTO Vehicles (PlateNumber, Model)
VALUES ('TN99ZZ9999', 'Test Vehicle')
SELECT * FROM Vehicles
WHERE PlateNumber='TN99ZZ9999'

ROLLBACK TRANSACTION

-- Test 1B: Duplicate plate number
BEGIN TRY
    INSERT INTO Vehicles (PlateNumber, Model)
    VALUES ('TN38AB1234', 'Duplicate Vehicle') -- ALREADY EXISTS
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ExpectedError
END CATCH

-- 2. TEST CHECK CONSTRAINTS
-- Test 2A: Valid driver status
BEGIN TRANSACTION

INSERT INTO Drivers (FirstName, LastName, VehicleId, Status)
VALUES ('Test', 'Driver', NULL, 'Online')
SELECT * FROM Drivers
WHERE FirstName = 'Test'

ROLLBACK TRANSACTION

-- Test 2B: Invalid driver status
BEGIN TRY
    INSERT INTO Drivers (FirstName, LastName, VehicleId, Status)
    VALUES ('Invalid', 'Driver', NULL, 'Busy')
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ExpectedError
END CATCH

-- Test 2C: Invalid rating stars
BEGIN TRY
    INSERT INTO Ratings (TripId, Stars, Comment)
    VALUES (1, 6, 'Invalid rating')
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ExpectedError
END CATCH

-- Test 2D: Invalid latitude
BEGIN TRY
    INSERT INTO LocationPing
        (DriverId, Latitude, Longitude)
    VALUES
        (1, 100.000000, 76.000000)
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ExpectedError
END CATCH

-- 3. TEST DEFAULT CONSTRAINTS
-- Test 3A: Omit the Status column
BEGIN TRANSACTION

INSERT INTO Drivers (FirstName, LastName, VehicleId)
VALUES ('Default', 'Test', NULL)
SELECT DriverId, FirstName, Status
FROM Drivers
WHERE FirstName = 'Default'

ROLLBACK TRANSACTION

-- Test 3A: Omit the Status column
BEGIN TRANSACTION

INSERT INTO Drivers (FirstName, LastName, VehicleId)
VALUES ('Default', 'Test', NULL)
SELECT DriverId, FirstName, Status
FROM Drivers
WHERE FirstName = 'Default'

ROLLBACK TRANSACTION

-- Test 3B: Test the Trip default
BEGIN TRANSACTION

INSERT INTO Trips (RiderId)
VALUES (1)
SELECT TOP 1 TripId, RiderId, Status
FROM Trips
ORDER BY TripId DESC

ROLLBACK TRANSACTION

-- 4. TEST FOREIGN KEY CONSTRAINTS
-- Test 4A: Valid foreign key
BEGIN TRANSACTION

INSERT INTO LocationPing(DriverId, Latitude, Longitude)
VALUES (1, 11.000000, 76.000000)
SELECT * FROM LocationPing
WHERE DriverId = 1

ROLLBACK TRANSACTION

-- Test 4B: Invalid foreign key
BEGIN TRY
    INSERT INTO LocationPing (DriverId, Latitude, Longitude)
    VALUES (9999, 11.000000, 76.000000)
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ExpectedError
END CATCH

-- Driver → Vehicle
BEGIN TRY
    INSERT INTO Drivers (FirstName, LastName, VehicleId)
    VALUES ('Test', 'Driver', 9999)
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ExpectedError
END CATCH

-- Trip → Rider
BEGIN TRY
    INSERT INTO Trips (RiderId)
    VALUES (9999)
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ExpectedError
END CATCH

-- Trip → Driver
BEGIN TRY
    INSERT INTO Trips (RiderId, DriverId)
    VALUES (1, 9999);
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ExpectedError;
END CATCH;

-- Rating → Trip
BEGIN TRY
    INSERT INTO Ratings (TripId, Stars)
    VALUES (9999, 5);
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ExpectedError;
END CATCH;
