TRUNCATE TABLE dbo.ConcatTest;
GO

INSERT INTO dbo.ConcatTest (FKId, Country)
VALUES
(1, 'UK'),
(1, 'France'),
(2, 'US'),
(3, 'Germany'),
(3, 'France'),
(3, 'UK');
GO