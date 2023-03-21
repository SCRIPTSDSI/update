SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE view [dbo].[KASAFISKALE] 
AS
select TOP 100 PERCENT scr.sasi,
                                                                cmshzb0=CMIMM,
                                                                left(dbo.RemoveSpecialChars(scr.pershkrim),20) as artikulli,
                                                                zbritjeart=0,
                                                                scr.perqtvsh,
                                                                sm.vlerzbr as zbritjefat,
                                                                kodkase = CASE WHEN A.KODTVSH='2' THEN '1' WHEN A.KODTVSH='0' THEN '2' WHEN A.KODTVSH='3' THEN '4' END,
                                                                CONVERT(NVARCHAR(20),SM.NRRENDOR)+'SM' AS NRRENDOR
                                                                ,A.NRRENDOR AS NRRENDORART
                                                                ,VOUCHER=0,
                                                                KARTE=0,
                                                                PIKE = 0,
                                                                CASH = ceiling(SM.VLERTOT),
                                                                SM.VLERTOT-SM.VOUCHER-SM.PIKE-SM.KARTE AS CASHPARESTO,
                                                                karteklienti=SM.KLIENTID
from SMSCR AS SCR 
INNER JOIN SM ON SM.NRRENDOR = SCR.NRD
INNER JOIN ARTIKUJ AS A ON A.KOD = SCR.KARTLLG
ORDER BY SCR.SASI














GO
