-- CREATE DATABASE
CREATE DATABASE RideSyncDB

-- SELECT THE DATABASE TO USE
USE RideSyncDB

-- VERIFY THE DATABASE IS CREATED
SELECT name
FROM sys.databases
WHERE name = 'RideSyncDB'

-- CREATE TABLES

-- 1. CREATE RIDER TABLE
CREATE TABLE Riders(
	RiderId INT IDENTITY(1,1) PRIMARY KEY,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Phone VARCHAR(20) NOT NULL
)

-- 2. CREATE VEHICLE TABLE
CREATE TABLE Vehicles(
	VehicleId INT IDENTITY(1,1) PRIMARY KEY,
	PlateNumber VARCHAR(20) NOT NULL UNIQUE,
	Model VARCHAR(30) NOT NULL
)

-- 3. CREATE DRIVER TABLE
CREATE TABLE Drivers(
	DriverId INT IDENTITY(1,1) PRIMARY KEY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	VehicleId INT, -- NULLABLE
	Status VARCHAR(20) NOT NULL DEFAULT 'Offline',
	CONSTRAINT FK_Driver_Vehicle
	FOREIGN KEY(VehicleId) REFERENCES Vehicles(VehicleId),
	CONSTRAINT CK_Driver_Status CHECK (STATUS IN('Online', 'Offline', 'OnTrip'))
)

-- 4. CREATE LOCATION PING TABLE
CREATE TABLE LocationPing(
	PingId BIGINT IDENTITY(1,1) PRIMARY KEY,
	DriverId INT NOT NULL,
	Latitude DECIMAL(9,6) NOT NULL,
	Longitude DECIMAL(9,6) NOT NULL,
	RecordedAt DATETIME2(6) NOT NULL DEFAULT SYSDATETIME(),
	CONSTRAINT FK_LocationPing_Driver 
	FOREIGN KEY(DriverId) REFERENCES Drivers(DriverId),
	CONSTRAINT CK_LocationPing_Latitude
	CHECK (Latitude BETWEEN -90 AND 90),
	CONSTRAINT CK_LocationPing_Longitude
	CHECK (Longitude BETWEEN -180 AND 180)
)

-- 5. CREATE TRIP TABLE
CREATE TABLE Trips(
	TripId INT IDENTITY(1,1) PRIMARY KEY,
	RiderId INT NOT NULL,
	DriverId INT NULL, -- NULLABLE
	RequestedAt DATETIME2(6) NOT NULL DEFAULT SYSDATETIME(),
	MatchedAt DATETIME2(6) NULL, -- NULLABLE
	Status VARCHAR(20) NOT NULL DEFAULT 'Requested',
	Fare DECIMAL(10,2) NULL,
	CONSTRAINT FK_Trip_Rider
	FOREIGN KEY(RiderId) REFERENCES Riders(RiderId),
	CONSTRAINT FK_Trip_Driver
	FOREIGN KEY(DriverId) REFERENCES Drivers(DriverId),
	CONSTRAINT CK_Trip_Fare
	CHECK (Fare IS NULL OR Fare>=0)
)


-- 6. CREATE RATING TABLE
CREATE TABLE Ratings(
	RatingId INT IDENTITY(1,1) PRIMARY KEY,
	TripId INT NOT NULL,
	Stars INT NOT NULL,
	Comment VARCHAR(200) NULL,
	CONSTRAINT FK_Rating_Trip
	FOREIGN KEY(TripId) REFERENCES Trips(TripId),
	CONSTRAINT CK_Rating_Stars
	CHECK (Stars BETWEEN 1 AND 5)
)

-- CREATE THE LOCATION PING INDEX
CREATE INDEX IX_LocationPing_DriverId_RecordedAt
ON LocationPing(DriverId, RecordedAt)

-- VERIFY TABLES
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE='BASE TABLE'
ORDER BY TABLE_NAME

-- VERIFY FOREIGN KEY AND CONSTRAINTS
SELECT t.name [Table Name], c.name [Constraint Name], c.type_desc AS [Constraint Type]
FROM sys.objects c
JOIN sys.tables t
ON c.parent_object_id=t.object_id
WHERE c.type IN ('PK','F','C','UQ')
ORDER BY t.name, c.type_desc

-- VERIFY INDEX
EXEC sp_helpindex 'LocationPing'

-- INSERT VALUES

-- 1. INSERT INTO VEHICLES TABLE
INSERT INTO Vehicles(PlateNumber, Model)
VALUES
('TN38AB1234', 'Hyundai i20'),
('TN38CD2345', 'Maruti Swift'),
('TN38EF3456', 'Honda City'),
('TN38GH4567', 'Toyota Innova'),
('TN38IJ5678', 'Tata Nexon'),
('TN38KL6789', 'Kia Seltos'),
('TN38MN7890', 'Maruti Baleno'),
('TN38OP8901', 'Hyundai Creta'),
('TN38QR9012', 'Tata Punch'),
('TN38ST0123', 'Honda Amaze')

-- 2. INSERT INTO RIDERS TABLE
INSERT INTO Riders(FirstName, LastName, Phone)
VALUES
('Arun', 'Kumar', '9876543210'),
('Priya', 'Sharma', '9876543211'),
('Karthik', 'Rajan', '9876543212'),
('Divya', 'Suresh', '9876543213'),
('Vijay', 'Kumar', '9876543214'),
('Anitha', 'Devi', '9876543215'),
('Rahul', 'Verma', '9876543216'),
('Sneha', 'Ravi', '9876543217'),
('Santhosh', 'M', '9876543218'),
('Meena', 'Lakshmi', '9876543219')

-- 3. INSERT INTO DRIVERS TABLE
INSERT INTO Drivers(FirstName, LastName, VehicleId, Status)
VALUES
('Ramesh', 'Kumar', 1, 'Online'),
('Suresh', 'Raj', 2, 'Offline'),
('Manoj', 'Kumar', 3, 'Online'),
('Prakash', 'R', 4, 'OnTrip'),
('Gokul', 'Krishnan', 5, 'Online'),
('Dinesh', 'Babu', 6, 'Offline'),
('Naveen', 'Raj', 7, 'Online'),
('Ashok', 'Kumar', 8, 'OnTrip'),
('Bala', 'Murugan', 9, 'Online'),
('Saravanan', 'M', 10, 'Offline')

-- 4. INSERT INTO TRIPS TABLE
INSERT INTO Trips(RiderId, DriverId, RequestedAt, MatchedAt, Status, Fare)
VALUES
(1, 1, DATEADD(MINUTE, -60, SYSDATETIME()), DATEADD(MINUTE, -58, SYSDATETIME()), 'Completed', 150.00),
(2, 2, DATEADD(MINUTE, -55, SYSDATETIME()), NULL, 'Requested', NULL),
(3, 3, DATEADD(MINUTE, -50, SYSDATETIME()), DATEADD(MINUTE, -48, SYSDATETIME()), 'Completed', 220.00),
(4, 4, DATEADD(MINUTE, -45, SYSDATETIME()), DATEADD(MINUTE, -43, SYSDATETIME()), 'Completed', 180.00),
(5, 5, DATEADD(MINUTE, -40, SYSDATETIME()), NULL, 'Cancelled', NULL),
(6, 6, DATEADD(MINUTE, -35, SYSDATETIME()), DATEADD(MINUTE, -33, SYSDATETIME()), 'Completed', 300.00),
(7, 7, DATEADD(MINUTE, -30, SYSDATETIME()), DATEADD(MINUTE, -28, SYSDATETIME()), 'Completed', 125.00),
(8, 8, DATEADD(MINUTE, -25, SYSDATETIME()), NULL, 'Requested', NULL),
(9, 9, DATEADD(MINUTE, -20, SYSDATETIME()), DATEADD(MINUTE, -18, SYSDATETIME()), 'Completed', 275.00),
(10, 10, DATEADD(MINUTE, -15, SYSDATETIME()), DATEADD(MINUTE, -13, SYSDATETIME()), 'Completed', 190.00)

-- 5. INSERT INTO RATINGS TABLE
INSERT INTO Ratings(TripId, Stars, Comment)
VALUES
(1, 5, 'Excellent service'),
(2, 4, 'Good experience'),
(3, 5, 'Very comfortable ride'),
(4, 3, 'Average service'),
(5, 4, 'Good driver'),
(6, 5, 'Excellent driving'),
(7, 4, 'Smooth journey'),
(8, 3, 'Could be better'),
(9, 5, 'Very punctual'),
(10, 4, 'Nice experience')

-- 6. INSERT INTO LOCATION PING TABLE
DECLARE @N INT=1
WHILE @N<=20
BEGIN
    INSERT INTO LocationPing(DriverId, Latitude, Longitude, RecordedAt)
    SELECT
        D.DriverId,
        CAST(11.000000 + (D.DriverId * 0.010000) + (@N * 0.000100) AS DECIMAL(9,6)),
        CAST(76.000000 + (D.DriverId * 0.010000) + (@N * 0.000100) AS DECIMAL(9,6)),
        DATEADD(SECOND, -@N, SYSDATETIME())
    FROM Drivers D
    SET @N=@N+1
END

-- VERIFY THE INSERTED TABLES
SELECT 'Riders' [TABLE NAME], COUNT(*) [NO. OF ROWS] FROM Riders
SELECT 'Vehicles' [TABLE NAME], COUNT(*) [NO. OF ROWS] FROM Vehicles
SELECT 'Drivers' [TABLE NAME], COUNT(*) [NO. OF ROWS] FROM Drivers
SELECT 'LocationPing' [TABLE NAME], COUNT(*) [NO. OF ROWS] FROM LocationPing
SELECT 'Trips' [TABLE NAME], COUNT(*) [NO. OF ROWS] FROM Trips
SELECT 'Ratings' [TABLE NAME], COUNT(*) [NO. OF ROWS] FROM Ratings

-- VIEW THE INSERTED DATA
SELECT * FROM Riders
SELECT * FROM Vehicles
SELECT * FROM Drivers
SELECT * FROM LocationPing
SELECT * FROM Trips
SELECT * FROM Ratings

-- ONLY ONE RATING PER TRIP
ALTER TABLE Ratings
ADD CONSTRAINT UQ_Rating_Trip
UNIQUE (TripId)