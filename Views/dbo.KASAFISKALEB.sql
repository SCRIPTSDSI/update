SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create view [dbo].[KASAFISKALEB] 
AS
select TOP 100 PERCENT scr.sasi,
				scr.cmshzb0,
				left(replace(replace(replace(replace(REPLACE(scr.pershkrim,'.',''),'”',' '),'“',' '),';',' '),'’',' '),20) as artikulli,
				scr.sasi*(scr.cmshzb0-scr.cmimm) as zbritjeart,
				scr.perqtvsh,
				sm.vlerzbr as zbritjefat,
				kodkase = CASE WHEN A.TATIM=1 THEN '1' ELSE '2' END,
				CONVERT(NVARCHAR(20),SM.NRRENDOR)+'SM' AS NRRENDOR
				,A.NRRENDOR AS NRRENDORART
				,SM.VOUCHER,
				SM.KARTE,
				SM.PIKE,
				SM.VLERTOT-SM.VOUCHER-SM.PIKE-SM.KARTE AS CASHPARESTO
from SMBAKSCR AS SCR 
INNER JOIN SMBAK SM ON SM.NRRENDOR = SCR.NRD
INNER JOIN ARTIKUJ AS A ON A.KOD = SCR.KARTLLG
ORDER BY SCR.SASI







GO
