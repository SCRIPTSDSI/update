SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[test1]
as
SELECT TOP 100 PERCENT MIN(SCR.KARTLLG) AS KOD,SM.Kase as Kase,
SCR.KODAF AS [Kod Artikull], min(SCR.PERSHKRIM) AS ARTIKULLI,sum(SCR.Sasi) as sasi,
min(SCR.Njesi) as njesi,min(SCR.Cmimm) as Cmim,sum(SCR.VLERABS) as Vlera,
sum(SM.VLERTOT) as [Vlera Totale],sum(distinct sm.karte) as karte FROM SM AS SM 
RIGHT JOIN SMSCR AS SCR ON SCR.NRD = SM.NRRENDOR 
group by sm.kase,scr.kodaf

union all

SELECT TOP 100 PERCENT MIN(SCR.KARTLLG) AS KOD,SM.Kase as Kase,
SCR.KODAF AS [Kod Artikull], min(SCR.PERSHKRIM) AS ARTIKULLI,sum(SCR.Sasi) as sasi,
min(SCR.Njesi) as njesi,min(SCR.Cmimm) as Cmim,sum(SCR.VLERABS) as Vlera,
sum(SM.VLERTOT) as [Vlera Totale],sum(distinct sm.karte) as karte FROM SMbak AS SM 
RIGHT JOIN SMbakSCR AS SCR ON SCR.NRD = SM.NRRENDOR 
group by sm.kase,scr.kodaf
GO
