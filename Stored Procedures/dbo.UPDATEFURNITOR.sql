SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[UPDATEFURNITOR]
AS

UPDATE ARTIKUJ
SET FURNKOD = (SELECT TOP 1 KODFKL FROM FF
INNER JOIN FFSCR ON FFSCR.NRD = FF.NRRENDOR
WHERE FFSCR.KARTLLG = ARTIKUJ.KOD
ORDER BY DATEDOK DESC)
WHERE KOD IN (SELECT DISTINCT KARTLLG FROM FFSCR)
GO