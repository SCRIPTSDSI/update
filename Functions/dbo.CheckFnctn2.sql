SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[CheckFnctn2](
@kod nvarchar)
RETURNS int
AS 
BEGIN
   DECLARE @retval int
   SELECT @retval = ( select COUNT(1) 
			FROM artikuj a
			where exists(select 1 from artikuj b where a.kod = b.bc and a.nrrendor <> b.nrrendor)
			AND EXISTS(SELECT 1 FROM ARTIKUJ C WHERE C.KOD = A.BC AND A.NRRENDOR <> C.NRRENDOR)
			and a.kod = @kod
)

--select * from artikuj a
--where exists(select 1 from artikuj b where a.kod = b.bc and a.nrrendor <> b.nrrendor)

   RETURN @retval
END;
GO
