SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--SELECT DBO.CheckFnctn1('HALLVASI2')

CREATE FUNCTION [dbo].[CheckFnctn](
@kod nvarchar(50),
@BC NVARCHAR(50))
RETURNS int
AS 
BEGIN
   DECLARE @retval int
if(@kod = @bc)
begin 
set @retval = 0
end 
else 
begin 
   SELECT @retval = (SELECT COUNT('') FROM ARTIKUJ WHERE kod = @BC) 
+ (SELECT COUNT('') FROM ARTIKUJ WHERE Bc = @kod)
--select kod, bc from artikuj a
--where exists(select 1 from artikuj b where a.kod = b.bc and a.nrrendor <> b.nrrendor)
end
   RETURN @retval
END;
GO
