CREATE PROCEDURE [dbo].[ExecuteConcatMagic]
	AS
DECLARE @Delimiter VARCHAR(10) = ' '; -- this is the delimiter we will use when we concatenate the values
SELECT FKId, dbo.ConcatMagic(Country, @Delimiter)
FROM dbo.ConcatTest
GROUP BY FKId