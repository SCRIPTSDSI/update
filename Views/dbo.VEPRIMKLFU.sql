SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE   VIEW [dbo].[VEPRIMKLFU] AS 
  SELECT TOP 100 PERCENT 
         A.KOD,  
         A.KMON, 
         KLF           = 'S',
         SG1           = LEFT(A.KOD, CASE WHEN CHARINDEX ('.',A.KOD )>0
                                          THEN CHARINDEX ('.',A.KOD)-1
                                          ELSE LEN(A.KOD) END), 
         PERSHKRIMLIB  = A.PERSHKRIM, 
         PERSHKRIMKLFU = B.PERSHKRIM, 
         A.KOMENT, 
         A.TIPDOK, 
         A.NRDOK, 
         A.FRAKSDOK,
         DATEDOK       = A.DATEDOK,  
         A.KODMASTER,
         A.TIPFAT,
         A.NRFAT,
         A.DTFAT,
         A.VLEFTA, 
         A.VLEFTAMV, 
         A.KURS1, 
         A.KURS2, 
         TREGDK        = A.TREGDK,
         SIMBOLD       = CASE A.TREGDK WHEN 'D' THEN C.SIMBOL ELSE '' END, 
         SIMBOLK       = CASE A.TREGDK WHEN 'K' THEN C.SIMBOL ELSE '' END, 
         PERSHKRIMMN   = C.PERSHKRIM,
         SIMBOL        = C.SIMBOL, 
         KODKLFU       = LEFT(A.KOD, CASE WHEN CHARINDEX ('.',A.KOD )>0
                                          THEN CHARINDEX ('.',A.KOD)-1
                                          ELSE LEN(A.KOD) END)+'.'+IsNull(A.KMON,''),
         KODLINK       = LEFT(A.KOD, CASE WHEN CHARINDEX ('.',A.KOD )>0
                                          THEN CHARINDEX ('.',A.KOD)-1
                                          ELSE LEN(A.KOD) END),
         KODSEC        = (SELECT KOD FROM FURNITOR B WHERE B.KODLINKKF = LEFT(A.KOD, CASE WHEN CHARINDEX ('.',A.KOD )>0
                                                                                          THEN CHARINDEX ('.',A.KOD)-1
                                                                                          ELSE LEN(A.KOD) END))
    FROM DKL A LEFT JOIN KLIENT  B ON B.KOD = LEFT(A.KOD,CASE WHEN CHARINDEX ('.',A.KOD )>0
                                                              THEN CHARINDEX ('.',A.KOD)-1
                                                              ELSE LEN(A.KOD) END)
               LEFT JOIN MONEDHA C ON A.KMON = C.KOD
UNION ALL 
   SELECT TOP 100 PERCENT 
          A.KOD,  
          A.KMON, 
          KLFF         = 'F',
          SG1          = LEFT(A.KOD, CASE WHEN CHARINDEX ('.',A.KOD )>0
                                          THEN CHARINDEX ('.',A.KOD)-1
                                          ELSE LEN(A.KOD) END), 
          PERSHKRIMLB  = B.PERSHKRIM, 
          PERSHKRIM    = B.PERSHKRIM, 
          A.KOMENT, 
          A.TIPDOK, 
          A.NRDOK, 
          A.FRAKSDOK, 
          DATEDOK      = A.DATEDOK,  
          A.KODMASTER,
          A.TIPFAT,
          A.NRFAT,
          A.DTFAT,
          A.VLEFTA, 
          A.VLEFTAMV, 
          A.KURS1, 
          A.KURS2, 
          TREGDK       = A.TREGDK, 
          SIMBOLDB     = CASE A.TREGDK WHEN 'D' THEN C.SIMBOL ELSE '' END, 
          SIMBOLKR     = CASE A.TREGDK WHEN 'K' THEN C.SIMBOL ELSE '' END, 
          PERSHKRIMMON = C.PERSHKRIM, 
          SIMBOL       = C.SIMBOL,
          KODKLFU      = B.KODLINKKF+'.'+CASE WHEN A.KMON IS NULL THEN '' ELSE A.KMON END,
          KODLINK      = B.KODLINKKF,
          KODSEC       = B.KOD
     FROM DFU A LEFT JOIN FURNITOR B ON B.KOD = LEFT(A.KOD, CASE WHEN CHARINDEX ('.',A.KOD )>0
                                                                 THEN CHARINDEX ('.',A.KOD)-1
                                                                 ELSE LEN(A.KOD) END)
                LEFT JOIN MONEDHA  C ON A.KMON = C.KOD
    WHERE IsNull(B.KODLINKKF,'')<>''
 ORDER BY KODKLFU, DATEDOK, TREGDK




GO
