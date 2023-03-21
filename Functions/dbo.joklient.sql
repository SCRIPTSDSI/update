SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[joklient] (@NRD varchar(20),@KARTLLG AS VARCHAR(30))
RETURNS bit
AS
BEGIN
DECLARE @field varchar(20),@data as datetime;
SET @field =(SELECT KODFKL FROM FJ WHERE NRRENDOR = @NRD)
SET @data =(SELECT DATEDOK FROM FJ WHERE NRRENDOR = @NRD)
declare @ret as bit;
declare @count as int;
set @count = (select count(1) from FJ 
			INNER JOIN FJSCR ON FJSCR.NRD = FJ.NRRENDOR
				where KODFKL=@field and MONTH(datedok)=MONTH(@data)and YEAR(datedok)=YEAR(@data)
				AND KARTLLG=@KARTLLG)
    if @count>=2
		set @ret = 0
	else
		set @ret = 1
return @ret
END
--([dbo].[joklient]([nrd], [kartllg]) = 1)
GO
