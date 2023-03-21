SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE       VIEW [dbo].[FU_FFifo] AS

-- E perdor Raporti Furnitor Furnitor pa Shlyerje / Likujdim Total
  SELECT A.KMON,
         A.KURS1,
         A.KURS2,
         KODKF = A.KOD,
         KOD   = CASE WHEN CHARINDEX('.',A.KOD)>0 
                      THEN LEFT(A.KOD,CHARINDEX('.',A.KOD)-1)
                      ELSE A.KOD END,
         A.VLEFTA,
         A.VLEFTAMV,
         TOTALFATURA = (   SELECT ISNULL(SUM(VLEFTA),0) 
                             FROM DFU B 
                            WHERE (B.KMON=A.KMON AND B.KOD=A.KOD) AND TREGDK='K' AND
                                  (B.DATEDOK<A.DATEDOK OR (B.DATEDOK=A.DATEDOK AND B.NRRENDOR<A.NRRENDOR))),
 
         TOTALSHLYER = (   SELECT ISNULL(SUM(VLEFTA),0) FROM DFU B WHERE (B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK='D')),

         PJESASHLYER = CASE WHEN (SELECT ISNULL(SUM(VLEFTA),0)           
                                    FROM DFU B 
                                   WHERE (B.KMON=A.KMON AND B.KOD=A.KOD) AND TREGDK='K' AND
                                         (B.DATEDOK<A.DATEDOK OR (B.DATEDOK=A.DATEDOK AND B.NRRENDOR<A.NRRENDOR)))
                                 - 
                                 (SELECT ISNULL(SUM(VLEFTA),0) 
                                    FROM DFU B 
                                   WHERE (B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK='D'))>=0 
                            THEN 0

                            WHEN  (SELECT ISNULL(SUM(VLEFTA),0)          
                                     FROM DFU B 
                                    WHERE (B.KMON=A.KMON AND B.KOD=A.KOD) AND TREGDK='K' AND
                                          (B.DATEDOK<A.DATEDOK OR (B.DATEDOK=A.DATEDOK AND B.NRRENDOR<A.NRRENDOR)))
                                  - 
                                  (SELECT ISNULL(SUM(VLEFTA),0) 
                                     FROM DFU B 
                                    WHERE (B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK='D'))<=-VLEFTA 
                            THEN VLEFTA

                            ELSE  -((SELECT ISNULL(SUM(VLEFTA),0)        
                                       FROM DFU B 
                                      WHERE (B.KMON=A.KMON AND B.KOD=A.KOD) AND TREGDK='K' AND
                                            (B.DATEDOK<A.DATEDOK OR (B.DATEDOK=A.DATEDOK AND B.NRRENDOR<A.NRRENDOR)))
                                    - 
                                   (SELECT ISNULL(SUM(VLEFTA),0) 
                                      FROM DFU B 
                                     WHERE (B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK='D')))
                            END,

         PJESASHLYERMV = CASE WHEN (SELECT ISNULL(SUM(VLEFTA),0)           
                                      FROM DFU B 
                                     WHERE (B.KMON=A.KMON AND B.KOD=A.KOD) AND TREGDK='K' AND
                                           (B.DATEDOK<A.DATEDOK OR (B.DATEDOK=A.DATEDOK AND B.NRRENDOR<A.NRRENDOR)))
                                 - 
                                 (SELECT ISNULL(SUM(VLEFTA),0) 
                                    FROM DFU B 
                                   WHERE (B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK='D'))>=0 
                            THEN 0

                            WHEN  (SELECT ISNULL(SUM(VLEFTA),0)          
                                     FROM DFU B 
                                    WHERE (B.KMON=A.KMON AND B.KOD=A.KOD) AND TREGDK='K' AND
                                          (B.DATEDOK<A.DATEDOK OR (B.DATEDOK=A.DATEDOK AND B.NRRENDOR<A.NRRENDOR)))
                                  - 
                                  (SELECT ISNULL(SUM(VLEFTA),0) 
                                     FROM DFU B 
                                    WHERE (B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK='D'))<=-VLEFTA 
                            THEN VLEFTAMV

                            ELSE  -((SELECT ISNULL(SUM(VLEFTAMV),0)        
                                       FROM DFU B 
                                      WHERE (B.KMON=A.KMON AND B.KOD=A.KOD) AND TREGDK='K' AND
                                            (B.DATEDOK<A.DATEDOK OR (B.DATEDOK=A.DATEDOK AND B.NRRENDOR<A.NRRENDOR)))
                                    - 
                                   (SELECT ISNULL(SUM(VLEFTAMV),0) 
                                      FROM DFU B 
                                     WHERE (B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK='D')))
                            END,

         A.NRFAT,
         A.DTFAT, 
         A.DATEDOK,
         A.TIPDOK,
         A.NRDOK,
         A.KOMENT,
         A.NRRENDOR,
         NIPT         = ISNULL(A1.NIPT,''),
         NRFATURE     = CASE WHEN A.TIPDOK='FF' THEN ISNULL(A1.NRDSHOQ, '')
                             WHEN A.TIPDOK='SP' THEN ISNULL(A2.NRDOKREF,'') 
                             ELSE '' END,

         DATEFATURE   = ISNULL(A1.DTDSHOQ,ISNULL(A2.DATEDOKREF,A.DATEDOK)),
         AFATPAGESE   = CASE WHEN A.TIPDOK='FF' THEN ISNULL(A1.DTAF,0)
                             WHEN A.TIPDOK='SP' THEN ISNULL(A2.OPERNR,0) 
                             ELSE 0 END,

         DITENGADOK   = DATEDIFF(DAY,ISNULL(A1.DTDSHOQ,ISNULL(A2.DATEDOKREF,A.DATEDOK)),GETDATE()),
         DITENGAAFAT  = DATEDIFF(DAY,DATEADD(DAY,CASE WHEN A.TIPDOK='FF' THEN ISNULL(A1.DTAF,0)
                                                      WHEN A.TIPDOK='SP' THEN ISNULL(A2.OPERNR,0) 
                                                      ELSE 0 END,
                                                 ISNULL(A1.DTDSHOQ,ISNULL(A2.DATEDOKREF,A.DATEDOK))),
                                     GETDATE()),
         A1.NRSERIAL
    FROM DFU A LEFT JOIN FF       A1 ON (A.NRRENDOR=A1.NRDITAR AND A.TIPDOK ='FF')
               LEFT JOIN VSSCR    A2 ON (A.NRRENDOR=A2.NRDITAR AND A.TIPDOK ='SP' AND A2.TIPKLL='F')

   WHERE A.TREGDK='K' And 1=1
GO
