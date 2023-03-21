SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[nrdok] (@field varchar(20),@data as datetime)
RETURNS bit
AS
BEGIN
declare @ret as bit;
declare @count as int;
set @count = (select count(1) from sm where nrdok=@field and year(datedok)=year(@data))
    if @count>=1
		set @ret = 0
	else
		set @ret = 1
return @ret
END
GO
