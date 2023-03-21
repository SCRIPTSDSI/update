SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE           VIEW [dbo].[S_DKLFAT] AS

  SELECT TOP 100 PERCENT 
         NRRENDOR     = CASE WHEN A.ORG='S' THEN A.NRRENDORDOK ELSE 0 END,
         A.KOD,
         A.PERSHKRIM,
         KMON         = ISNULL(A.KMON,''),
         KURS         = CASE WHEN KURS1*KURS2>0 THEN KURS2/KURS1 ELSE 0 END,
         KODFKL       = LEFT(A.KOD, CASE WHEN CHARINDEX ('.',A.KOD )>0 THEN CHARINDEX ('.',A.KOD)-1 ELSE LEN(A.KOD) END),--LEFT(A.KOD,CHARINDEX('.',A.KOD)-1)
         NRDOK        = ISNULL(A.NRDOK,0),
         DATEDOK      = CASE WHEN A.TIPDOK='SP' THEN ISNULL(A.DTFAT,A.DATEDOK) ELSE A.DATEDOK END,
         TREGDK,
         NRFAT        = ISNULL(A.NRFAT,''),
         DTFAT        = ISNULL(A.DTFAT,0),
         TIPDOK       = ISNULL(A.TIPDOK,''),
         KATEGORI     = ISNULL(C.KATEGORI,''),
         AGJENTSHITJE = ISNULL(C.AGJENTSHITJE,''),
         VENDNDODHJE  = ISNULL(C.VENDNDODHJE,''),
         NIPT         = ISNULL(C.NIPT,''),
         KLASIFIKIM1  = ISNULL(C.KLASIFIKIM1,''),
         KLASIFIKIM2  = ISNULL(C.KLASIFIKIM2,''),
         KLASIFIKIM3  = ISNULL(C.KLASIFIKIM3,''),
         KLASIFIKIM4  = ISNULL(C.KLASIFIKIM4,''),
         KLASIFIKIM5  = ISNULL(C.KLASIFIKIM5,''),
         KLASIFIKIM6  = ISNULL(C.KLASIFIKIM6,''),
         
         VLEFTA,
         VLEFTAMV,
/*       VLEFTAPROG   = (SELECT SUM(B.VLEFTA)   
                           FROM DKL B 
                          WHERE  LEFT(B.KOD,CASE WHEN CHARINDEX ('.',B.KOD )>0 THEN CHARINDEX ('.',B.KOD)-1 ELSE LEN(B.KOD) END)=LEFT(A.KOD,CASE WHEN CHARINDEX ('.',A.KOD )>0 THEN CHARINDEX ('.',A.KOD)-1 ELSE LEN(A.KOD) END)
                                 AND 
                                (
                                  ISNULL(B.DTFAT,0)<ISNULL(A.DTFAT,0) OR (ISNULL(B.DTFAT,0)=ISNULL(A.DTFAT,0) AND B.NRRENDOR<=A.NRRENDOR))                         
                                  AND 
                                 ((B.TREGDK='D' AND (B.VLEFTA>0 OR (B.VLEFTA=0 AND B.VLEFTAMV>0))) OR (B.TREGDK='K' AND (B.VLEFTA<0 OR (B.VLEFTA=0 AND B.VLEFTAMV<0))))
                                 ),*/
         VLEFTAPROGMV = (SELECT SUM(B.VLEFTAMV) 
                           FROM DKL B 
                          WHERE  LEFT(B.KOD,CASE WHEN CHARINDEX ('.',B.KOD )>0 THEN CHARINDEX ('.',B.KOD)-1 ELSE LEN(B.KOD) END)=LEFT(A.KOD,CASE WHEN CHARINDEX ('.',A.KOD )>0 THEN CHARINDEX ('.',A.KOD)-1 ELSE LEN(A.KOD) END)
                                 AND 
                                (
                                  ISNULL(B.DTFAT,0)<ISNULL(A.DTFAT,0) OR (ISNULL(B.DTFAT,0)=ISNULL(A.DTFAT,0) AND B.NRRENDOR<=A.NRRENDOR))                         
                                  AND 
                                 ((B.TREGDK='D' AND (B.VLEFTA>0 OR (B.VLEFTA=0 AND B.VLEFTAMV>0))) OR (B.TREGDK='K' AND (B.VLEFTA<0 OR (B.VLEFTA=0 AND B.VLEFTAMV<0))))
                                 )
    FROM DKL A LEFT JOIN KLIENT C ON LEFT(A.KOD, CASE WHEN CHARINDEX ('.',A.KOD )>0 THEN CHARINDEX ('.',A.KOD)-1 ELSE LEN(A.KOD) END)=C.KOD
   WHERE ((A.TREGDK='D' AND (A.VLEFTA>0 OR (A.VLEFTA=0 AND A.VLEFTAMV>0))) OR (A.TREGDK='K' AND (A.VLEFTA<0 OR (A.VLEFTA=0 AND A.VLEFTAMV<0))))
--ORDER BY A.KOD,DTFAT,KMON,A.NRRENDOR

--SELECT * FROM DKL








GO
