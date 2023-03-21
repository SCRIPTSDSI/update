SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_TestFkDitarTot]
(
  @PDateKp    Varchar(20),
  @PDateKs    Varchar(20),
  @PKodKp     Varchar(30),
  @PKodKs     Varchar(30),
  @PTip       Varchar(10)
)
As


          if CharIndex(@PTip,'ABSF')<=0
             Return;


          if Object_Id('TempDB..#TMP1') is not null
             DROP TABLE #TMP1;  
          if Object_Id('TempDB..#TMP2') is not null
             DROP TABLE #TMP2;  

     Declare @DateKp      Varchar(30),
             @DateKs      Varchar(30),
             @KodKp       Varchar(30),
             @KodKs       Varchar(30),
             @Ditar       Varchar(30),
             @Reference   Varchar(30),
             @Koment      Varchar(100),
             @Sql         Varchar(Max);

         Set @DateKp    = Dbo.DateValue(@PDateKp);
         Set @DateKs    = Dbo.DateValue(@PDateKs);
         Set @KodKp     = @PKodKp;
         Set @KodKs     = @PKodKs;

    if @PTip='A'
       begin
         Set @Ditar     = 'DAR'
         Set @Reference = 'ARKAT'
         Set @Koment    = QuoteName('Ditar AR','''')
       end;
    if @PTip='B'
       begin
         Set @Ditar     = 'DBA'
         Set @Reference = 'BANKAT'
         Set @Koment    = QuoteName('Ditar BA','''')
       end;
    if @PTip='S'
       begin
         Set @Ditar     = 'DKL'
         Set @Reference = 'KLIENT'
         Set @Koment    = QuoteName('Ditar KL','''')
       end;
    if @PTip='F'
       begin
         Set @Ditar     = 'DFU'
         Set @Reference = 'FURNITOR'
         Set @Koment    = QuoteName('Ditar FU','''')
       end;


      SELECT KOMENT    = Space(20),
             VITI      = Cast(0 As Int),
             LLOGARI   = Space(30),
             PERSHKRIM = Space(100),
             DATEDOK   = GetDate(),
             DATEKOD   = Cast(0 As BigInt),
             DB        = Cast(0 As Float),
             KR        = Cast(0 As Float),
             DK        = Cast(0 As Float)
        INTO #TMP2
       WHERE 1=2

      SELECT KOMENT    = 'Kontabilizime',
             VITI      = YEAR(DATEDOK),
             LLOGARI   = LLOGARIPK,
             PERSHKRIM = MAX(C.PERSHKRIM),
             DATEDOK, 
             DATEKOD   = Cast(A.DATEDOK As BigInt),
             DB        = SUM(CASE WHEN TREGDK='D' THEN   DBKRMV ELSE 0 END),
             KR        = SUM(CASE WHEN TREGDK='K' THEN 0-DBKRMV ELSE 0 END),
             DK        = SUM(DBKRMV) 
        INTO #TMP1
        FROM FK A INNER JOIN FKSCR   B ON A.NRRENDOR=B.NRD
                  LEFT  JOIN LLOGARI C ON B.LLOGARIPK=C.KOD 
       WHERE A.DATEDOK  >=@DateKp And A.DATEDOK  <=@DateKs And 
             B.LLOGARIPK>=@PKodKp And B.LLOGARIPK<=@PKodKs
    GROUP BY YEAR(DATEDOK),DATEDOK,LLOGARIPK
    ORDER BY VITI,LLOGARI,DATEKOD


/*
-- Grupuar sipas LLOGARI ne ARKAT,BANKAT - Global sipas skemes
   if @PTip='A'
      begin
          INSERT INTO #TMP2
                 (KOMENT,VITI,LLOGARI,PERSHKRIM,DATEDOK,DATEKOD,DB,KR,DK)
          SELECT KOMENT    = 'Ditar AR',
                 VITI      = YEAR(A.DATEDOK),
                 B.LLOGARI,
                 PERSHKRIM = MAX(C.PERSHKRIM),
                 A.DATEDOK,
                 DATEKOD   = Cast(A.DATEDOK As BigInt),
                 DB        = SUM(CASE WHEN A.TREGDK='D' THEN A.VLEFTAMV ELSE 0 END),
                 KR        = SUM(CASE WHEN A.TREGDK='K' THEN A.VLEFTAMV ELSE 0 END),
                 DK        = SUM(CASE WHEN A.TREGDK='D' THEN A.VLEFTAMV ELSE 0-A.VLEFTAMV END)
          --INTO #TMP2
            FROM DAR A LEFT JOIN  ARKAT B ON B.KOD = CASE WHEN CharIndex('.',A.KOD)>0 
                                                          THEN Left(A.KOD,CharIndex('.',A.KOD)-1) 
                                                          ELSE A.KOD END
                       LEFT JOIN LLOGARI C ON B.LLOGARI=C.KOD 
           WHERE A.DATEDOK >=@DateKp And A.DATEDOK <=@DateKs And 
                 B.LLOGARI >=@PKodKp And B.LLOGARI <=@PKodKs
        GROUP BY YEAR(A.DATEDOK),B.LLOGARI, A.DATEDOK
      end;

   if @PTip='B'
      begin
          INSERT INTO #TMP2
                 (KOMENT,VITI,LLOGARI,PERSHKRIM,DATEDOK,DATEKOD,DB,KR,DK)
          SELECT KOMENT    = 'Ditar BA',
                 VITI      = YEAR(A.DATEDOK),
                 B.LLOGARI,
                 PERSHKRIM = MAX(C.PERSHKRIM),
                 A.DATEDOK,
                 DATEKOD   = Cast(A.DATEDOK As BigInt),
                 DB        = SUM(CASE WHEN A.TREGDK='D' THEN A.VLEFTAMV ELSE 0 END),
                 KR        = SUM(CASE WHEN A.TREGDK='K' THEN A.VLEFTAMV ELSE 0 END),
                 DK        = SUM(CASE WHEN A.TREGDK='D' THEN A.VLEFTAMV ELSE 0-A.VLEFTAMV END)
          --INTO #TMP2
            FROM DBA A LEFT JOIN BANKAT B ON B.KOD = CASE WHEN CharIndex('.',A.KOD)>0 
                                                          THEN Left(A.KOD,CharIndex('.',A.KOD)-1) 
                                                          ELSE A.KOD END
                       LEFT JOIN LLOGARI C ON B.LLOGARI=C.KOD 
           WHERE A.DATEDOK >=@DateKp And A.DATEDOK <=@DateKs And 
                 B.LLOGARI >=@PKodKp And B.LLOGARI <=@PKodKs
        GROUP BY YEAR(A.DATEDOK),B.LLOGARI, A.DATEDOK
        ORDER BY VITI,LLOGARI,DATEKOD
      end;

   if @PTip='S'
      begin
          INSERT INTO #TMP2
                 (KOMENT,VITI,LLOGARI,PERSHKRIM,DATEDOK,DATEKOD,DB,KR,DK)
          SELECT KOMENT    = 'Ditar KL',
                 VITI      = YEAR(A.DATEDOK),
                 B.LLOGARI,
                 PERSHKRIM = MAX(C.PERSHKRIM),
                 A.DATEDOK,
                 DATEKOD   = Cast(A.DATEDOK As BigInt),
                 DB        = SUM(CASE WHEN A.TREGDK='D' THEN A.VLEFTAMV ELSE 0 END),
                 KR        = SUM(CASE WHEN A.TREGDK='K' THEN A.VLEFTAMV ELSE 0 END),
                 DK        = SUM(CASE WHEN A.TREGDK='D' THEN A.VLEFTAMV ELSE 0-A.VLEFTAMV END)
          --INTO #TMP2
            FROM DKL A LEFT JOIN KLIENT B ON B.KOD = CASE WHEN CharIndex('.',A.KOD)>0 
                                                          THEN Left(A.KOD,CharIndex('.',A.KOD)-1) 
                                                          ELSE A.KOD END
                   LEFT JOIN LLOGARI C ON B.LLOGARI=C.KOD 
           WHERE A.DATEDOK >=@DateKp And A.DATEDOK <=@DateKs And 
                 B.LLOGARI >=@PKodKp And B.LLOGARI <=@PKodKs
        GROUP BY YEAR(A.DATEDOK),B.LLOGARI, A.DATEDOK
        ORDER BY VITI,LLOGARI,DATEKOD
      end;


   if @PTip='F'
      begin
          INSERT INTO #TMP2
                 (KOMENT,VITI,LLOGARI,PERSHKRIM,DATEDOK,DATEKOD,DB,KR,DK)
          SELECT KOMENT    = 'Ditar FU',
                 VITI      = YEAR(A.DATEDOK),
                 B.LLOGARI,
                 PERSHKRIM = MAX(C.PERSHKRIM),
                 A.DATEDOK,
                 DATEKOD   = Cast(A.DATEDOK As BigInt),
                 DB        = SUM(CASE WHEN A.TREGDK='D' THEN A.VLEFTAMV ELSE 0 END),
                 KR        = SUM(CASE WHEN A.TREGDK='K' THEN A.VLEFTAMV ELSE 0 END),
                 DK        = SUM(CASE WHEN A.TREGDK='D' THEN A.VLEFTAMV ELSE 0-A.VLEFTAMV END)
          --INTO #TMP2
            FROM DFU A LEFT JOIN FURNITOR B ON B.KOD = CASE WHEN CharIndex('.',A.KOD)>0 
                                                            THEN Left(A.KOD,CharIndex('.',A.KOD)-1) 
                                                            ELSE A.KOD END
                       LEFT JOIN LLOGARI C ON B.LLOGARI=C.KOD 
           WHERE 1=1 AND B.LLOGARI='401' 
        GROUP BY YEAR(A.DATEDOK),B.LLOGARI, A.DATEDOK
        ORDER BY VITI,LLOGARI,DATEKOD
      end;

          SELECT A.*, B.*
            FROM #TMP1 A LEFT JOIN #TMP2 B ON A.VITI=B.VITI AND A.LLOGARI=B.LLOGARI AND A.DATEKOD=B.DATEKOD
           WHERE ABS(A.DB-B.DB)>0.01 OR ABS(A.KR-B.KR)>0.01 OR ABS(A.DK-B.DK)>0.01
        ORDER BY A.VITI,A.LLOGARI,A.DATEKOD


          if Object_Id('TempDB..#TMP1') is not null
             DROP TABLE #TMP1;  
          if Object_Id('TempDB..#TMP2') is not null
             DROP TABLE #TMP2;  

*/
         Set @DateKp    = 'dbo.DateValue('+QuoteName(@PDateKp,'''')+')';
         Set @DateKs    = 'dbo.DateValue('+QuoteName(@PDateKs,'''')+')';
         Set @KodKp     = QuoteName(@PKodKp, '''');
         Set @KodKs     = QuoteName(@PKodKs, '''');

         Set @Sql = '
          INSERT INTO #TMP2
                 (KOMENT,VITI,LLOGARI,PERSHKRIM,DATEDOK,DATEKOD,DB,KR,DK)
          SELECT KOMENT    = '+@Koment+',
                 VITI      = YEAR(A.DATEDOK),
                 B.LLOGARI,
                 PERSHKRIM = MAX(C.PERSHKRIM),
                 A.DATEDOK,
                 DATEKOD   = Cast(A.DATEDOK As BigInt),
                 DB        = SUM(CASE WHEN A.TREGDK=''D'' THEN A.VLEFTAMV ELSE 0 END),
                 KR        = SUM(CASE WHEN A.TREGDK=''K'' THEN A.VLEFTAMV ELSE 0 END),
                 DK        = SUM(CASE WHEN A.TREGDK=''D'' THEN A.VLEFTAMV ELSE 0-A.VLEFTAMV END)
            FROM '+@Ditar+' A LEFT JOIN  '+@Reference+' B 
                                             ON B.KOD = CASE WHEN CharIndex(''.'',A.KOD)>0 
                                                             THEN Left(A.KOD,CharIndex(''.'',A.KOD)-1) 
                                                             ELSE A.KOD END
                       LEFT JOIN LLOGARI C ON B.LLOGARI=C.KOD 
           WHERE A.DATEDOK >='+@DateKp+' And A.DATEDOK <='+@DateKs+' And 
                 B.LLOGARI >='+@KodKp +' And B.LLOGARI <='+@KodKs+'
        GROUP BY YEAR(A.DATEDOK),B.LLOGARI, A.DATEDOK '
         --WHERE A.DATEDOK >=dbo.DateValue('+@DateKp+') And A.DATEDOK <=dbo.DateValue('+@DateKs+') And 

Print @Sql
Exec (@Sql);

--Select * From #TMP2



          SELECT A.VITI,A.LLOGARI,A.PERSHKRIM,A.DATEDOK,
                 FK_DB  = A.DB,
                 FK_KR  = A.KR,
                 FK_DK  = A.DK,
                 DT_DB  = B.DB,
                 DT_KR  = B.KR,
                 DT_DK  = B.DK,
                 MESAZH = CASE WHEN ABS(A.DB-B.DB)>0.01 THEN 'Vlerat DB'
                               WHEN ABS(A.KR-B.KR)>0.01 THEN 'Vlerat KR'
                               WHEN ABS(A.DK-B.DK)>0.01 THEN 'Vlerat Db-Kr'
                               ELSE '?' END,
               --A.*, B.*,
                 TAGNR    = CAST(0 AS INT),
                 TROW     = CAST(0 AS BIT),
                 NRRENDOR = 0
            FROM #TMP1 A LEFT JOIN #TMP2 B ON A.VITI=B.VITI AND A.LLOGARI=B.LLOGARI AND A.DATEKOD=B.DATEKOD
           WHERE ABS(A.DB-B.DB)>0.01 OR ABS(A.KR-B.KR)>0.01 OR ABS(A.DK-B.DK)>0.01
        ORDER BY A.VITI,A.LLOGARI,A.DATEKOD


          if Object_Id('TempDB..#TMP1') is not null
             DROP TABLE #TMP1;  
          if Object_Id('TempDB..#TMP2') is not null
             DROP TABLE #TMP2;  

GO
