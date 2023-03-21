SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[f_string_to_table]
(
    @string VARCHAR(255),
    @delimiter CHAR(1)
)
RETURNS @output TABLE(
    Vlera VARCHAR(256)
)
BEGIN
    DECLARE @start INT, @end INT
    SELECT @start = 1, @end = CHARINDEX(@delimiter, @string)

    WHILE @start < LEN(@string) + 1 
    BEGIN
        IF @end = 0 
            SET @end = LEN(@string) + 1

        INSERT INTO @output (Vlera) 
        VALUES(SUBSTRING(@string, @start, @end - @start))
        SET @start = @end + 1
        SET @end = CHARINDEX(@delimiter, @string, @start)
    END

    RETURN

END
GO
