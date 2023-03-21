SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE   VIEW [dbo].[AR_KALIMLM] 

AS

       

      SELECT --TOP 100 PERCENT 
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
             LLOGARIPK=B.LLOGARI
        FROM ARKASCR A  LEFT JOIN KLIENT B   ON A.LLOGARIPK = B.KOD, CONFIGLM C
       WHERE A.TIPKLL='S'

   UNION ALL

      SELECT --TOP 100 PERCENT 
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
        FROM ARKASCR A  LEFT JOIN FURNITOR B ON A.LLOGARIPK = B.KOD, CONFIGLM C
       WHERE A.TIPKLL='F'

   UNION ALL 

      SELECT A.NRRENDOR,
             A.NRD,
             KOD  = CASE WHEN A.KalimLM=0      -- A.RRAB='K' Or 
                         THEN A.KOD
                         ELSE LLOGARIPK+'.'+
                              CASE WHEN DEP  <>'' THEN DEP   ELSE CASE WHEN DEPRF<>''   THEN DEPRF   ELSE '' END END + '.'  +
                              CASE WHEN LISTE<>'' THEN LISTE ELSE CASE WHEN LISTERF<>'' THEN LISTERF ELSE '' END END + '.'  + 
                              ISNULL(KMAG,'') + '.' + ISNULL(KMON,'')
                    END,
             A.LLOGARI,
             A.LLOGARIPK
        FROM
          (
             SELECT --TOP 100 PERCENT 
                    A.NRRENDOR,
                    A.NRD,
                    A.KOD,
                    LLOGARI   = B.KOD,
                    A.LLOGARIPK,

                    A.RRAB,
                    DEP       = CASE WHEN ISNULL(R3.KALIMARLMDEPLIST,0)=0          -- RRAB='K' Or 
                                     THEN ''
                                     ELSE ISNULL(dbo.Isd_SegmentFind(A.KOD,0,2),'')
                                END,
                    LISTE     = CASE WHEN ISNULL(R3.KALIMARLMDEPLIST,0)=0          -- RRAB='K' Or 
                                     THEN ''
                                     ELSE ISNULL(dbo.Isd_SegmentFind(A.KOD,0,3),'')
                                END,
                    KMAG      = CASE WHEN ISNULL(R3.KALIMARLMDEPLIST,0)=0          -- RRAB='K' Or  
                                     THEN ''
                                     ELSE ISNULL(dbo.Isd_SegmentFind(A.KOD,0,4),'')
                                END,
                    KMON      = ISNULL(A.KMON,''),
                    DEPRF     = ISNULL(R2.DEP,''),
                    LISTERF   = ISNULL(R2.LISTE,''),
                    KalimLM   = CASE WHEN  ISNULL(R3.KALIMARLMDEPLIST,0)=0                                              THEN 0
                                     WHEN  ISNULL(R3.KALIMABLM67DEPLIST,0)=1 AND  CHARINDEX(LEFT(A.LLOGARIPK,1),'67')=0 THEN 0
                                     ELSE                                                                                    ISNULL(R3.KALIMARLMDEPLIST,0)
                                END
                 -- R1.KODAB
               FROM ARKASCR A  LEFT JOIN LLOGARI B  ON A.LLOGARIPK = B.KOD
                               LEFT JOIN ARKA    R1 ON A.NRD=R1.NRRENDOR
                               LEFT JOIN ARKAT   R2 ON R2.KOD=R1.KODAB,CONFIGLM R3
              WHERE A.TIPKLL='T') A

-- UNION ALL

--    SELECT --TOP 100 PERCENT 
--           A.NRRENDOR,
--           A.NRD,
--           A.KOD,
--           LLOGARI = B.KOD,
--           A.LLOGARIPK
--      FROM ARKASCR A  LEFT JOIN LLOGARI B ON A.LLOGARIPK = B.KOD
--     WHERE A.TIPKLL='T'
  --ORDER BY A.NRRENDOR


GO
