SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VLEREFATURE](@FATURA VARCHAR(30) = NULL)
AS
DECLARE @KOMANDA AS NVARCHAR(4000);

--KALKULOHEN VLERAT TEK FJSCR E dbTMP-SE
SET @KOMANDA= 
'UPDATE FJSCR SET 
  VLPATVSH= SASI*CMIMBS,
  VLTVSH  = CASE   WHEN ISNULL(VLTVSH,0)>0 THEN (SASI*CMIMBS)*0.2 ELSE 0 END,
  VLERABS = (SASI*CMIMBS)+(CASE   WHEN ISNULL(VLTVSH,0)>0 THEN (SASI*CMIMBS)*0.2 ELSE 0 END)
WHERE NRD='+@FATURA
EXEC SP_EXECUTESQL @KOMANDA;

--KALKULOHEN VLERAT TEK FJ E dbTMP-SE
SET @KOMANDA= 
'UPDATE FJ SET 
   VLERTOT  = (SELECT ISNULL(SUM(VLERABS),0) FROM FJSCR WHERE NRD='+@FATURA+'),
   VLPATVSH = (SELECT ISNULL(SUM(VLPATVSH),0) FROM FJSCR WHERE NRD='+@FATURA+'), 
   VLTVSH = (SELECT ISNULL(SUM(VLTVSH),0) FROM FJSCR WHERE NRD='+@FATURA+'),
   NRDOK = NRRENDOR
 WHERE NRRENDOR='+@FATURA
EXEC SP_EXECUTESQL @KOMANDA;
GO