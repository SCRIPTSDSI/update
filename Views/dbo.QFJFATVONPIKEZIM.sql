SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO







CREATE     VIEW [dbo].[QFJFATVONPIKEZIM] AS 

      SELECT NRRENDOR    = MAX(CASE WHEN A.ORG='S' THEN A.NRRENDORDOK ELSE 0 END),
             KOD         = B.KOD,
             KODRF       = MAX(LEFT(A.KOD, CASE WHEN CHARINDEX ('.',A.KOD )>0 THEN CHARINDEX ('.',A.KOD)-1 ELSE LEN(A.KOD) END)),
             EMERTIM     = MAX(A.PERSHKRIM), 
             KATEGORI    = MAX(B.KATEGORI),
             AGJENTSHITJE= MAX(B.AGJENTSHITJE),
             VENDNDODHJE = MAX(B.VENDNDODHJE),
             NIPT        = MAX(B.NIPT),
             KLASIFIKIM1 = MAX(B.KLASIFIKIM1),
             KLASIFIKIM2 = MAX(B.KLASIFIKIM2),
             KLASIFIKIM3 = MAX(B.KLASIFIKIM3),
             VL          = MAX(A.VLEFTA), 
             VLMV        = MAX(A.VLEFTAMV),
             DIF         = MAX(A.VLEFTA)   - SUM(ISNULL(C.VLEFTA,0)),   -- SUM(ISNULL(C.VLEFTAMV,0)/A.KURS2)
             DIFMV       = MAX(A.VLEFTAMV) - SUM(ISNULL(C.VLEFTAMV,0)),
             DATEDOK     = MAX(A.DATEDOK),
             TIPDOK      = MAX(A.TIPDOK),
             NRDOK       = MAX(A.NRDOK),
             KMON        = A.KMON,
             KMAG        = MAX(ISNULL(D.KMAG,'')),
             TREGDK      = MAX(A.TREGDK),
             A.NRFAT,
             A.DTFAT,
             DTFAT1      = MIN(C.DATEDOK),
             DITEVON     = MAX(ISNULL(D.DTAF,0)),
             DTPAGESE    = A.DTFAT + MAX(ISNULL(D.DTAF,ISNULL(B.AFAT,0)))
        FROM DKL A LEFT  JOIN KLIENT B ON  B.KOD=LEFT(A.KOD, CASE WHEN CHARINDEX ('.',A.KOD )>0 THEN CHARINDEX ('.',A.KOD)-1 ELSE LEN(A.KOD) END)
                   LEFT  JOIN DKL    C ON (A.NRFAT  =C.NRFAT) AND (A.DTFAT  =C.DTFAT) AND (C.DATEDOK<=DBO.DATEVALUE('01/01/1955')) AND
                                          (LEFT(A.KOD, CASE WHEN CHARINDEX ('.',A.KOD )>0 THEN CHARINDEX ('.',A.KOD)-1 ELSE LEN(A.KOD) END)=
                                           LEFT(C.KOD, CASE WHEN CHARINDEX ('.',C.KOD )>0 THEN CHARINDEX ('.',C.KOD)-1 ELSE LEN(C.KOD) END)) AND 
                                          (A.NRRENDOR<>C.NRRENDOR) AND (A.TREGDK='D') AND (A.TIPDOK IN ('FJ','SP'))
                   LEFT  JOIN FJ      D ON A.NRRENDOR=D.NRDITAR
       WHERE A.TREGDK='D'
    GROUP BY B.KOD,A.KMON,A.NRFAT,A.DTFAT
      HAVING ABS(MAX(A.VLEFTAMV)-SUM(ISNULL(C.VLEFTAMV,0)))>0.001







GO
