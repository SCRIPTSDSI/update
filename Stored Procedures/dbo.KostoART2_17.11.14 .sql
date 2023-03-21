SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE      PROCEDURE [dbo].[KostoART2_17.11.14 ]
(
  @PKMagKp  As Varchar(30),
  @PKMagKs  As Varchar(30),
  @PDateKp  As DateTime,
  @PDateKs  As DateTime,
  @PKodKp   As Varchar(30),
  @PKodKs   As Varchar(30)
)
AS

   SELECT NRRENDOR    = 0,
          TIP         = 'H',
          KODAF       = A.KARTLLG,
          A.KARTLLG, 
          KMAG        = Max(A.KMAG),
          KMAGGR      = '1', 
          NRDOK       = 0, 
          DTDOK       = Max(A.DATEDOK),
          NRFRAKS     = 0, 
          SASI        = Round(Sum(Case When   A.TIP='H' 
                                       Then   A.SASIH
                                       Else 0-A.SASID  End),3),
          VLERAM      = Round(Sum(Case When   A.TIP='H' 
                                       Then   A.VLERAH
                                       Else 0-A.VLERAD End),3),
          CMIMM       = Round(Case When (Sum(Case When   A.TIP='H' 
                                                  Then   A.SASIH
                                                  Else 0-A.SASID End)) * 
                                        (Sum(Case When   A.TIP='H' 
                                                  Then   A.VLERAH
                                                  Else 0-A.VLERAD End))<=0 
                                   Then 0
                                   Else (Sum(Case When   A.TIP='H' 
                                                  Then   A.VLERAH
                                                  Else 0-A.VLERAD End)) / 
                                         Sum(Case When   A.TIP='H' 
                                                  Then   A.SASIH
                                                  Else 0-A.SASID End) End,3), 
          NRD         = 0,
          FAT         = 'F',
          DST         = '  ',
          BC          = Max(B.BC),
          NRRENDORFAT = Max(A.NRRENDORFAT), 
          TIPART      = Max(B.TIP),
          TROW        = -1
     FROM LEVIZJEHD A LEFT JOIN ARTIKUJ B ON A.KARTLLG=B.KOD
                      LEFT JOIN FJ C      ON A.NRRENDORFAT=C.NRRENDOR
    WHERE (A.KMAG    >= @PKMagKp AND A.KMAG    <= @PKMagKs) AND 
          (A.DATEDOK <  @PDateKp AND A.DATEDOK <  @PDateKs) AND 
          (A.KARTLLG >= @PKodKp  AND A.KARTLLG <= @PKodKs)
 GROUP BY A.KARTLLG

UNION ALL 

   SELECT A.NRRENDOR,
          A.TIP,
          A.KODAF, 
          A.KARTLLG, 
          A.KMAG,
          KAGGR       ='1', 
          A.NRDOK, 
          A.DATEDOK, 
          A.NRFRAKS, 
          Round(Case When A.TIP='H' Then SASIH  Else SASID  End,3) , 
          Round(Case When A.TIP='H' Then VLERAH Else VLERAD End,3),
          Round(A.CMIMM,3), NRD, 
          FAT         = Case When A.DOK_JB=1 Then 'F' Else ' ' End,
          A.DST,
          B.BC,
          A.NRRENDORFAT, 
          TIPARTIKULL = B.TIP,
          TROW        = 0
     FROM LEVIZJEHD A LEFT JOIN ARTIKUJ B ON A.KARTLLG=B.KOD
                      LEFT JOIN FJ C      ON A.NRRENDORFAT=C.NRRENDOR
    WHERE (A.KMAG    >= @PKMagKp AND A.KMAG    <= @PKMagKs) AND 
          (A.DATEDOK >= @PDateKp AND A.DATEDOK <= @PDateKs) AND
          (A.KARTLLG >= @PKodKp  AND A.KARTLLG <= @PKodKs)

 ORDER BY KARTLLG, DTDOK, TIP Desc, NRDOK, NRRENDOR







GO
