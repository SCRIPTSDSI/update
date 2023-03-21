SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE    PROCEDURE [dbo].[PIKEKLIENT] 
@kod nvarchar(20) = NULL 
AS
select
pike=floor(sum(vlertot)/(select kufi from KARTA.dbo.pike)-((select isnull(sum(pike),0) from KARTA.dbo.blerjet where barcode=fin_karta.klientid)))
from fin_karta
where klientid=@kod 
group by klientid
GO
