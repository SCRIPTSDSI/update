SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 CREATE VIEW [dbo].[GjendjeArtikujND] AS 
 select Kod=kartllg,BC,sum(sasiH) SASIH,SUM(SASID) SASID,Sasi=Sum(Case when tip='H' then sasih else -sasid end) ,
 DTFILLBL = MIN(Case when tip='H' then DATEDOK else NULL end),
 DTFUNDBL = MAX(Case when tip='H' then DATEDOK else NULL end),
 DTFUNDSH = MAX(Case when tip='D' then DATEDOK else NULL end),
 CMBLMADH = MAX(Case when tip='H' then CMIMM else NULL end),
 CMBLVOGEL = MIN(Case when tip='H' then CMIMM else NULL end),
 ( SELECT TOP 1 FFSCR.CMIMBS FROM FFSCR INNER JOIN FF ON FF.NRRENDOR=FFSCR.NRD WHERE FFSCR.KARTLLG=A.KARTLLG  ORDER BY FF.DATEDOK DESC) AS CMFUNDBLERE  from levizjehdsm A  group by kartllg,BC 
GO
