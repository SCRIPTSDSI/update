SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE        PROCEDURE [dbo].[KostoMG2_17.11.14 ]
(
  @PKMagKp  As Varchar(30),
  @PKMagKs  As Varchar(30),
  @PDateKp  AS DateTime,
  @PDateKs  As DateTime,
  @PKodKp   As Varchar(30),
  @PKodKs   As Varchar(30)
)
AS


         Set NoCount On

     Declare @KMagKp  As Varchar(30),
             @KMagKs  As Varchar(30),
             @DateKp  AS DateTime,
             @DateKs  As DateTime,
             @KodKp   As Varchar(30),
             @KodKs   As Varchar(30);


         Set @KMagKp = @PKMagKp;
         Set @KMagKs = @PKMagKs;
         Set @DateKp = @PDateKp;
         Set @DateKs = @PDateKs;
         Set @KodKp  = @PKodKp;
         Set @KodKs  = @PKodKs;


      SELECT NRRENDOR    = 0,
             TIP         = 'H',
             KODAF       = A.KARTLLG,
             A.KARTLLG,  
             A.KMAG,
             KMAGGR      = A.KMAG, 
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
                                                     Else 0-A.SASID  End) End,3), 
             NRD         = 0,
             FAT         = 'F',
             DST         = '  ',
             BC          = Max(B.BC),
             NRRENDORFAT = Max(A.NRRENDORFAT), 
             TIPART      = Max(B.TIP),
             TROW        = -1
        FROM LEVIZJEHD A LEFT JOIN ARTIKUJ B On A.KARTLLG=B.KOD
                         LEFT JOIN FJ C     On A.NRRENDORFAT=C.NRRENDOR
       WHERE (A.KMAG    >= @KMagKp And A.KMAG    <= @KMagKs) And 
             (A.DATEDOK >= @DateKp And A.DATEDOK <  @DateKs) And 
             (A.KARTLLG >= @KodKp  And A.KARTLLG <= @KodKs) 

  GROUP BY A.KARTLLG, A.KMAG

 UNION ALL 
    SELECT A.NRRENDOR,
           A.TIP,
           A.KODAF, 
           A.KARTLLG, 
           A.KMAG,
           KMAGGR      = A.KMAG, 
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
      FROM LEVIZJEHD A LEFT JOIN ARTIKUJ B On A.KARTLLG=B.KOD
                       LEFT JOIN FJ C      On A.NRRENDORFAT=C.NRRENDOR
     WHERE (A.KMAG    >= @KMagKp And A.KMAG    <= @KMagKs) And 
           (A.DATEDOK >= @DateKp And A.DATEDOK <= @DateKs) And
           (A.KARTLLG >= @KodKp  And A.KARTLLG <= @KodKs) 
  ORDER BY A.KMAG, KARTLLG, DTDOK, TIP Desc, NRDOK, NRRENDOR










GO
