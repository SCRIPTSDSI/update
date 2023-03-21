SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE    VIEW [dbo].[VS_KALIMLM] 

AS


      SELECT -- TOP 100 PERCENT 
             A.NRRENDOR,
             A.NRD, 
             KOD = CASE WHEN ISNULL(A.KODDETAJ,'')<>''
			                 THEN B.LLOGARI+'.'+dbo.Isd_SegmentFind(A.KODDETAJ,0,1)+'.'+
											    dbo.Isd_SegmentFind(A.KODDETAJ,0,2)+'.'+
											    dbo.Isd_SegmentFind(A.KODDETAJ,0,3)+'.'+ISNULL(A.KMON,'')
			            WHEN ISNULL(C.KALIMARLMDEPLIST,0)=1
                             THEN B.LLOGARI+'.'+ISNULL(B.DEP,'')+'.'+ISNULL(B.LISTE,'')+'..'+ISNULL(A.KMON,'')
                        ELSE B.LLOGARI+'....'+ISNULL(A.KMON,'')
                   END,
             B.LLOGARI, 
             LLOGARIPK=B.LLOGARI
        FROM VSSCR A LEFT JOIN ARKAT B ON A.LLOGARIPK = B.KOD, CONFIGLM C 
       WHERE A.TIPKLL='A'

   UNION ALL
      SELECT -- TOP 100 PERCENT 
             A.NRRENDOR,
             A.NRD, 
             KOD = CASE WHEN ISNULL(A.KODDETAJ,'')<>''
			                 THEN B.LLOGARI+'.'+dbo.Isd_SegmentFind(A.KODDETAJ,0,1)+'.'+
											    dbo.Isd_SegmentFind(A.KODDETAJ,0,2)+'.'+
											    dbo.Isd_SegmentFind(A.KODDETAJ,0,3)+'.'+ISNULL(A.KMON,'')
			            WHEN ISNULL(C.KALIMBALMDEPLIST,0)=1
                             THEN B.LLOGARI+'.'+ISNULL(B.DEP,'')+'.'+ISNULL(B.LISTE,'')+'..'+ISNULL(A.KMON,'')
                        ELSE B.LLOGARI+'....'+ISNULL(A.KMON,'')
                   END,
             B.LLOGARI,
             B.LLOGARI
        FROM VSSCR A LEFT JOIN BANKAT B ON A.LLOGARIPK = B.KOD, CONFIGLM C 
       WHERE A.TIPKLL='B'

   UNION ALL
      SELECT -- TOP 100 PERCENT 
             A.NRRENDOR,
             A.NRD,
             KOD = CASE WHEN ISNULL(A.KODDETAJ,'')<>''
			                 THEN B.LLOGARI+'.'+dbo.Isd_SegmentFind(A.KODDETAJ,0,1)+'.'+
											    dbo.Isd_SegmentFind(A.KODDETAJ,0,2)+'.'+
											    dbo.Isd_SegmentFind(A.KODDETAJ,0,3)+'.'+ISNULL(A.KMON,'')
			            WHEN ISNULL(C.LMANALITIKKL,0)=1
                             THEN B.LLOGARI+'.'+ISNULL(B.DEP,'')+'.'+ISNULL(B.LISTE,'')+'..'+ISNULL(A.KMON,'')
                        ELSE B.LLOGARI+'....'+ISNULL(A.KMON,'')
                   END,
             B.LLOGARI,
             B.LLOGARI
        FROM VSSCR A LEFT JOIN KLIENT B ON A.LLOGARIPK = B.KOD, CONFIGLM C
       WHERE A.TIPKLL='S'

   UNION ALL
      SELECT -- TOP 100 PERCENT 
             A.NRRENDOR,
             A.NRD,
             KOD = CASE WHEN ISNULL(A.KODDETAJ,'')<>''
			                 THEN B.LLOGARI+'.'+dbo.Isd_SegmentFind(A.KODDETAJ,0,1)+'.'+
											    dbo.Isd_SegmentFind(A.KODDETAJ,0,2)+'.'+
											    dbo.Isd_SegmentFind(A.KODDETAJ,0,3)+'.'+ISNULL(A.KMON,'')
			            WHEN ISNULL(C.LMANALITIKFU,0)=1
                             THEN B.LLOGARI+'.'+ISNULL(B.DEP,'')+'.'+ISNULL(B.LISTE,'')+'..'+ISNULL(A.KMON,'')
                        ELSE B.LLOGARI+'....'+ISNULL(A.KMON,'')
                   END,
             B.LLOGARI,
             B.LLOGARI
        FROM VSSCR A LEFT JOIN FURNITOR B ON A.LLOGARIPK = B.KOD, CONFIGLM C
       WHERE A.TIPKLL='F'

   UNION ALL 
      SELECT -- TOP 100 PERCENT 
             A.NRRENDOR,
             A.NRD,
             A.KOD,
             B.KOD,
             A.LLOGARIPK
        FROM VSSCR A LEFT JOIN LLOGARI B ON A.LLOGARIPK = B.KOD
       WHERE A.TIPKLL='T'
--  ORDER BY A.NRRENDOR


GO
