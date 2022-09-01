-- Delete a DB
USE master;
GO
ALTER DATABASE SCHEDULE 
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE SCHEDULE;

-- Create a DB
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'SCHEDULE')
CREATE DATABASE SCHEDULE
GO
USE SCHEDULE;
GO

-- Making SA an owner
USE SCHEDULE 
GO 
ALTER DATABASE SCHEDULE set TRUSTWORTHY ON; 
GO 
EXEC dbo.sp_changedbowner @loginame = N'sa', @map = false 
GO 
sp_configure 'show advanced options', 1; 
GO 
RECONFIGURE; 
GO 
sp_configure 'clr enabled', 1; 
GO 
RECONFIGURE; 
GO

-- Table Users
CREATE TABLE Users(
	Id INT PRIMARY KEY,
	ClientId INT,
	SpecialistId INT,
	Email NVARCHAR(100) NOT NULL UNIQUE,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	[Password] NVARCHAR(100) NOT NULL,
	ProfilePic NVARCHAR(120),
	Age INT CHECK(Age > 18) NOT NULL,
	Gender NVARCHAR(7) CHECK(Gender IN ('M', 'F', 'Other'))
)

-- Table Specialists
CREATE TABLE Specialists(
	Id INT PRIMARY KEY,
	UserId INT UNIQUE, 
	Domain NVARCHAR(30) NOT NULL,
	WorkExperience DECIMAL(10, 2) NOT NULL DEFAULT(0.0),
	AvgWorkSessionsPerMonth INT NOT NULL,
	CONSTRAINT FK_Specialist_Users FOREIGN KEY (UserId) REFERENCES Users(Id),
	CONSTRAINT AK_UserId_1 UNIQUE(UserId)
)

-- Table Clients
CREATE TABLE Clients(
	Id INT PRIMARY KEY,
	UserId INT UNIQUE,
	Interests NVARCHAR(40),
	CONSTRAINT FK_Client_Users FOREIGN KEY (UserId) REFERENCES Users(Id),
	CONSTRAINT AK_UserId_2 UNIQUE(UserId)
)

-- Table Schedules
CREATE TABLE Schedules(
	ClientId INT FOREIGN KEY REFERENCES Clients(Id),
	SpecialistId INT FOREIGN KEY REFERENCES Specialists(Id),
	ScheduleId INT UNIQUE NOT NULL,
	MeetingDate DATE NOT NULL,
	MeettingTime TIME NOT NULL,
	CONSTRAINT PK_ClientId_SpecialistId PRIMARY KEY (ClientId, SpecialistId)
)

-- Table Reviews
CREATE TABLE Reviews(
	ClientId INT FOREIGN KEY REFERENCES Clients(Id),
	SpecialistId INT FOREIGN KEY REFERENCES Specialists(Id),
	ReviewText NVARCHAR(400) DEFAULT(''),
	Stars INT NOT NULL,
	[Date] DATE NOT NULL,
	[Time] TIME NOT NULL DEFAULT('00:00:00'),
	CONSTRAINT PKk_ClientId_SpecialistId PRIMARY KEY (ClientId, SpecialistId)
)

-- Table UsersInfo
CREATE TABLE UsersInfo(
	Id INT FOREIGN KEY REFERENCES Users(Id),
	SignUpDate DATETIME NOT NULL,
	SearchHistory NVARCHAR(100),
	CountOfMeetings INT DEFAULT(0)
)

-- Table Services
CREATE TABLE [Services](
	ServiceId INT PRIMARY KEY,
	SpecialistId INT FOREIGN KEY REFERENCES Specialists(Id),
	ServiceName NVARCHAR(100) NOT NULL,
	Price DECIMAL(10, 2) NOT NULL CHECK(Price > 0) DEFAULT(100.00),
	Duration DECIMAL(10, 2) NOT NULL DEFAULT(1.00)
)

-- Insertions


-- Users
INSERT INTO Users
    (Id, ClientId, SpecialistId, Email, FirstName, LastName, [Password], ProfilePic, Age, Gender)
VALUES
	(0, 0,	NULL, 'sun@gmail.com',	'George',  'Adams',	'3453353',	 'https://schedule.com/stock/images/45353', 19, 'M'),
	(1, 1, NULL, 'grass@yahoo.com', 'Phill',   'James',	'fe7r78',	 'https://schedule.com/stock/images/56346',	32, 'M'),
	(2, NULL, 0, 'sample@mail.ru',	'Jorja',   'Johnson', '223n2nm',	 'https://schedule.com/stock/images/854',	24, 'F'),
	(3, NULL, 1, 'hill@gmail.com',	'Mike',	   'Smith', 'b0099s9',	 'https://schedule.com/stock/images/28434', 45, 'M'),
	(4, NULL, 2, 'boook@gmail.com', 'Mia',	   'Brown', '22f0sjen',	 'https://schedule.com/stock/images/74373', 61, 'F'),
	(5, 2, NULL, 'glass@gmail.com', 'Veldor',  'Martin', '2kkr778r',  'https://schedule.com/stock/images/84890', 45, 'M'),
	(6, 3, NULL, 'human@mail.ru',	'Selena',  'Wilson', 'x.romdee',  'https://schedule.com/stock/images/7312',	27, 'F'),
	(7, 4, NULL, 'night@yahoo.com', 'Rikki',   'White', 'xmpwpc',	 'https://schedule.com/stock/images/2256',	31, 'F'),
	(8, NULL, 3, 'day@gmail.com',	'Jonh',	   'Taylor', 'zchw221d',	 'https://schedule.com/stock/images/9843',	20, 'M'),
	(9, NULL, 4, 'rest@gmail.com',	'Festa',   'Anderson', 'v9jdms',    'https://schedule.com/stock/images/4256',	29, 'F')


-- Clients
INSERT INTO Clients
    (Id, UserId, Interests)
VALUES
	(0, 0, 'Sport & Hiking'),
	(1, 1, 'Books & Coffee'),
	(5, 2, 'Lord Of The Rings & Walking'),
	(6, 3, 'Music & Dancing'),
	(7, 4, 'Traveling')


-- Specialists
INSERT INTO Specialists
    (Id, UserId, Domain, WorkExperience, AvgWorkSessionsPerMonth)
VALUES
	(2, 0, 'Medicine',			   2.0,   45),
	(3, 1, 'Mechanic',			   6.0,   23),
	(4, 2, 'Hairdresser',		   3.0,   78),
	(8, 3, 'Psychology',		   1.0,   51),
	(9, 4, 'Financial Consultant', 8.0,   85)


-- Schedules
INSERT INTO Schedules
    (ClientId, SpecialistId, ScheduleId, MeetingDate, MeettingTime)
VALUES
	(0, 3, 0, '2000-07-08', '16:30'),
	(5, 2, 1, '2022-01-08', '12:00'),
	(7, 9, 2, '2021-12-12', '18:30'),
	(7, 4, 3, '2022-07-08', '14:45'),
	(1, 8, 4, '2022-09-14', '09:10')
	

-- Reviews
INSERT INTO Reviews
    (ClientId, SpecialistId, ReviewText, Stars, [Date], [Time])
VALUES
	(1, 3, 'It was awesome!',					 5, '2000-07-08', '16:30'),
	(5, 2, 'This person is a real professional', 5,	'2022-01-08', '12:00'),
	(6, 9, 'The service was bad',				 3,	'2021-12-12', '18:30'),
	(7, 4, 'I will definitely come back later',	 4,	'2022-07-08', '14:45'),
	(1, 8, 'Never recommend it to anyone',		 1,	'2022-09-14', '09:10')


-- Services
INSERT INTO [Services]
    (ServiceId, SpecialistId, ServiceName, Price, Duration)
VALUES
	(0, 2, 'Medical Consulting', 800.00, 1.20),
	(1, 3, 'Diagnostics', 750.00, 0.40),
	(2, 4, 'Standart haircut', 650.00, 1.30),
	(3, 8, 'Session', 500.00, 0.50),
	(4, 9, 'Audit Help', 1000.00, 2.50)


-- UsersInfo
