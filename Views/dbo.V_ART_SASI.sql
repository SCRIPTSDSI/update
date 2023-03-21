SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[V_ART_SASI] AS
SELECT
   L.KARTLLG    AS Kod,
   SUM(L.SASIH) AS SASIH,
   SUM(L.SASID) AS SASID,
   SUM(L.SASIH) - SUM(L.SASID) AS SASI_GJENDJE,
   SASI_PERIODIKE = SUM(CASE WHEN L.TIP='D' AND L.DOK_JB=1
           --FILLIM MUAJI PARAPRAK
           AND  L.DATEDOK>= DATEADD(dd,-(DAY(DATEADD(mm,-1,GETDATE()))-1),DATEADD(mm,-1,GETDATE()))
           --FUND MUAJI PARAPRAK
           AND  L.DATEDOK<= DATEADD(dd, - DAY(DATEADD(m,0,GETDATE())), DATEADD(m,0,GETDATE()))  
   THEN SASID ELSE 0 END),
   SasiDitore	  = SUM(CASE WHEN L.TIP='D' AND L.DOK_JB=1 AND L.DATEDOK=Convert(Datetime,CONVERT(VARCHAR(10),GETDATE(),103),103)-1 THEN L.SASID ELSE 0 END),
   SasiJavore	  = SUM(CASE WHEN L.TIP='D' AND L.DOK_JB=1 
						AND (L.DATEDOK>=GETDATE()-7 AND L.DATEDOK<=GETDATE()) THEN L.SASID ELSE 0 END)					
  
  ,MINI=MAX(ISNULL(A.MINI,0))
  ,MAKS=MAX(ISNULL(A.MAKS,0))
  ,DTFILLBL=MIN(CASE WHEN L.tip = 'H' THEN L.DATEDOK ELSE NULL END)
  ,DTFUNDBL=MAX(CASE WHEN L.tip = 'H' THEN L.DATEDOK ELSE NULL END) 
  ,DTFUNDSH=MAX(CASE WHEN L.tip = 'D' THEN L.DATEDOK ELSE NULL END) 
  ,POROSI  = CASE WHEN (SUM(L.SASIH) - SUM(L.SASID))  <  MAX(ISNULL(A.MINI,0)) 
				  THEN MAX(ISNULL(A.MAKS,0))  -  (SUM(L.SASIH) - SUM(L.SASID))
				  ELSE MAX(ISNULL(A.MAKS,0))  -  MAX(ISNULL(A.MINI,0)) END
 FROM      LEVIZJEHDSM L INNER JOIN ARTIKUJ A ON L.KARTLLG=A.KOD
 GROUP BY KARTLLG




GO
