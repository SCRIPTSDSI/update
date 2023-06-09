SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[T_DOKDIT_FU] AS 
SELECT TOP 100 PERCENT NRRENDOR,NRDITAR,'F' AS TIPD
  FROM FF
 UNION ALL 
SELECT TOP 100 PERCENT VSSCR.NRRENDOR,VSSCR.NRDITAR,'E' AS TIPD
  FROM VS INNER JOIN VSSCR ON VS.NRRENDOR=VSSCR.NRD
 WHERE TIPKLL='F'
 UNION ALL
SELECT TOP 100 PERCENT ARKASCR.NRRENDOR,ARKASCR.NRDITAR,'A' AS TIPD
  FROM ARKA INNER JOIN ARKASCR ON ARKA.NRRENDOR=ARKASCR.NRD
 WHERE TIPKLL='F'
 UNION ALL 
SELECT TOP 100 PERCENT BANKASCR.NRRENDOR,NRDITAR=BANKASCR.NRDITAR,'B' AS TIPD
  FROM BANKA INNER JOIN BANKASCR ON BANKA.NRRENDOR=BANKASCR.NRD
 WHERE TIPKLL='F'
ORDER BY NRDITAR


GO
