SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DATAPAKURS](@start_date AS datetime,@end_date AS datetime,@KMON AS VARCHAR(10),@PAKURS AS BIT)
AS
declare @days			int

--declare @start_date		datetime
--declare @end_date		datetime
--DECLARE @DNGA AS VARCHAR(10)
--DECLARE @DDERI AS VARCHAR(10)
--SET @DNGA = '01/01/'+CONVERT(VARCHAR(4),@VITI)
--SET @DDERI = '31/12/'+CONVERT(VARCHAR(4),@VITI)
--SET @start_date	=(select DBO.DATEVALUE(@DNGA))
--SET @end_date	=(select DBO.DATEVALUE(@DDERI))
IF @PAKURS=1
BEGIN
select @days = datediff(dd,@start_date,@end_date) +1

select
	[Data]		= dateadd(dd,number-1,@start_date),
	[Dita e Javes]	= datename(weekday,dateadd(dd,number-1,@start_date))
from
	dbo.F_TABLE_NUMBER_RANGE( 1, @days )
	WHERE  NOT EXISTS
	(SELECT 1 FROM KURSET  WHERE dateadd(dd,number-1,@start_date)=DATA AND KOD=@KMON GROUP BY DATA,KOD)
order by
	number
END
ELSE
BEGIN
	SELECT TOP 100 * FROM KURSET 
	WHERE DATA>=@start_date AND DATA<=@end_date
	ORDER BY NRRENDOR DESC
END
GO
