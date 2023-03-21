SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_TestFkSipasOrg]
(
  @PDateKp    Varchar(20),
  @PDateKs    Varchar(20),
  @PKodKp     Varchar(30),
  @PKodKs     Varchar(30),
  @POrgKp     Varchar(10),
  @POrgKs     Varchar(10),
  @PTipKp     Varchar(10),
  @PTipKs     Varchar(10),
  @PRefFkKp   Varchar(30),
  @PRefFkKs   Varchar(30),
  @PModel     Varchar(10)
)
As

--Print @PModel

     Declare @DateKp      Varchar(30),
             @DateKs      Varchar(30),
             @KodKp       Varchar(30),
             @KodKs       Varchar(30),
             @OrgKp       Varchar(10),
             @OrgKs       Varchar(10),
             @TipKp       Varchar(10),
             @TipKs       Varchar(10),
             @RefFkKp     Varchar(30),
             @RefFkKs     Varchar(30),
             @Koment      Varchar(100)

         Set @DateKp    = Dbo.DateValue(@PDateKp);
         Set @DateKs    = Dbo.DateValue(@PDateKs);
         Set @KodKp     = @PKodKp;
         Set @KodKs     = @PKodKs;
         Set @OrgKp     = @POrgKp;
         Set @OrgKs     = @POrgKs;
         Set @TipKp     = @PTipKp;
         Set @TipKs     = @PTipKs;
         Set @RefFkKp   = @PRefFkKp;
         Set @RefFkKs   = @PRefFkKs;

         if  @KodKs   = ''
             Set @KodKs   = 'zzzz';
         if  @OrgKs   = ''
             Set @OrgKs   = 'zzzz';
         if  @TipKs   = ''
             Set @TipKs   = 'zzzz';
         if  @RefFkKs = ''
             Set @RefFkKs = 'zzzz';
     


----   Ditore

    if @PModel='D'
       begin
             if Object_Id('TempDB..#TMP1D') is not null
                DROP TABLE #TMP1D;  
             if Object_Id('TempDB..#TMP2D') is not null
                DROP TABLE #TMP2D;  
             if Object_Id('TempDB..#TMP3D') is not null
                DROP TABLE #TMP3D;  





         SELECT VITI,DATEDOK,MUAJ,LLOGARIPK,
                ARDB = ISNULL(A,0),
                BADB = ISNULL(B,0),
                VSDB = ISNULL(E,0),
                FKDB = ISNULL(T,0),
                FHDB = ISNULL(H,0),
                FDDB = ISNULL(D,0),
                FJDB = ISNULL(S,0),
                FFDB = ISNULL(F,0),
                DGDB = ISNULL(G,0)
           INTO #TMP1D
           FROM
        (
         SELECT DATEDOK, ORG,
                LLOGARIPK,
                VITI = YEAR(DATEDOK),
                MUAJ = MONTH(DATEDOK),
                DB   = SUM(CASE WHEN TREGDK='D' THEN DBKRMV ELSE 0 END)
           FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR= B.NRD
          WHERE LLOGARIPK >= @KodKp   And LLOGARIPK <= @KodKs  And 
                DATEDOK   >= @DateKp  And DATEDOK   <= @DateKs And
                ORG       >= @OrgKp   And ORG       <= @OrgKs  And
                TIPDOK    >= @TipKp   And TIPDOK    <= @TipKs  And
                REFERDOK  >= @RefFkKp And REFERDOK  <= @RefFkKs
       GROUP BY YEAR(DATEDOK),MONTH(DATEDOK),DATEDOK,ORG,LLOGARIPK

         ) Pv1

        Pivot
                (SUM(DB) For ORG IN ([A],[B],[E],[T],[H],[D],[S],[F],[G])) As Pv2; 


         SELECT VITI,DATEDOK,MUAJ,LLOGARIPK,
                ARKR = ISNULL(A,0),
                BAKR = ISNULL(B,0),
                VSKR = ISNULL(E,0),
                FKKR = ISNULL(T,0),
                FHKR = ISNULL(H,0),
                FDKR = ISNULL(D,0),
                FJKR = ISNULL(S,0),
                FFKR = ISNULL(F,0),
                DGKR = ISNULL(G,0)
           INTO #TMP2D
           FROM
        (
         SELECT DATEDOK, ORG,
                LLOGARIPK,
                VITI = YEAR(DATEDOK),
                MUAJ = MONTH(DATEDOK),
                KR   = SUM(CASE WHEN TREGDK='K' THEN DBKRMV ELSE 0 END)
           FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR=B.NRD
          WHERE LLOGARIPK >= @KodKp   And LLOGARIPK <= @KodKs  And 
                DATEDOK   >= @DateKp  And DATEDOK   <= @DateKs And
                ORG       >= @OrgKp   And ORG       <= @OrgKs  And
                TIPDOK    >= @TipKp   And TIPDOK    <= @TipKs  And
                REFERDOK  >= @RefFkKp And REFERDOK  <= @RefFkKs
       GROUP BY YEAR(DATEDOK),MONTH(DATEDOK),DATEDOK,ORG,LLOGARIPK

         ) Pv1

        Pivot
                (SUM(KR) For ORG IN ([A],[B],[E],[T],[H],[D],[S],[F],[G])) As Pv2; 


         SELECT DATEDOK,
                LLOGARIPK,
                VITI = YEAR(DATEDOK),
                MUAJ = MONTH(DATEDOK),
                DK   = SUM(DBKRMV) 
           INTO #TMP3D
           FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR=B.NRD
          WHERE LLOGARIPK >= @KodKp   And LLOGARIPK <= @KodKs  And 
                DATEDOK   >= @DateKp  And DATEDOK   <= @DateKs And
                ORG       >= @OrgKp   And ORG       <= @OrgKs  And
                TIPDOK    >= @TipKp   And TIPDOK    <= @TipKs  And
                REFERDOK  >= @RefFkKp And REFERDOK  <= @RefFkKs
       GROUP BY YEAR(DATEDOK),MONTH(DATEDOK),DATEDOK,LLOGARIPK;


         SELECT KOMENT  = 'Kontabilitet',
                A.VITI,
                A.DATEDOK,
                A.MUAJ,
                LLOGARI=A.LLOGARIPK,
                C.PERSHKRIM,
                AR_DB  = ARDB, AR_KR  = ARKR,
                BA_DB  = BADB, BA_KR  = BAKR,
                VS_DB  = VSDB, VS_KR  = VSKR,
                FK_DB  = FKDB, FK_KR  = FKKR,
                FH_DB  = FHDB, FH_KR  = FHKR,
                FD_DB  = FDDB, FD_KR  = FDKR,
                FJ_DB  = FJDB, FJ_KR  = FJKR,
                FF_DB  = FFDB, FF_KR  = FFKR,
                DG_DB  = DGDB, DG_KR  = DGKR,
                TOT_DK = A.DK,
                TOT_DB = ARDB + BADB + VSDB + FKDB + FHDB + FDDB + FJDB + FFDB + DGDB,
                TOT_KR = ARKR + BAKR + VSKR + FKKR + FHKR + FDKR + FJKR + FFKR + DGKR,
                TAGNR    = 0,
                TROW     = CAST(0 As Bit),
                NRRENDOR = 0
           FROM #TMP3D A LEFT JOIN #TMP1D  T1 ON A.VITI=T1.VITI AND A.MUAJ=T1.MUAJ AND A.DATEDOK=T1.DATEDOK AND A.LLOGARIPK=T1.LLOGARIPK
                         LEFT JOIN #TMP2D  T2 ON A.VITI=T2.VITI AND A.MUAJ=T2.MUAJ AND A.DATEDOK=T2.DATEDOK AND A.LLOGARIPK=T2.LLOGARIPK
                         LEFT JOIN LLOGARI C  ON A.LLOGARIPK=C.KOD
       ORDER BY A.VITI,A.LLOGARIPK,A.MUAJ,A.DATEDOK;

       end;


----   Mujore

    if @PModel='M'
       begin
             if Object_Id('TempDB..#TMP1M') is not null
                DROP TABLE #TMP1M;  
             if Object_Id('TempDB..#TMP2M') is not null
                DROP TABLE #TMP2M;  
             if Object_Id('TempDB..#TMP3M') is not null
                DROP TABLE #TMP3M;  



         SELECT VITI,MUAJ,LLOGARIPK,
                ARDB = ISNULL(A,0),
                BADB = ISNULL(B,0),
                VSDB = ISNULL(E,0),
                FKDB = ISNULL(T,0),
                FHDB = ISNULL(H,0),
                FDDB = ISNULL(D,0),
                FJDB = ISNULL(S,0),
                FFDB = ISNULL(F,0),
                DGDB = ISNULL(G,0)
           INTO #TMP1M
           FROM
        (
         SELECT ORG,LLOGARIPK,
                VITI = YEAR(DATEDOK),
                MUAJ = MONTH(DATEDOK),
                DB   = SUM(CASE WHEN TREGDK='D' THEN DBKRMV ELSE 0 END)
           FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR=B.NRD
          WHERE LLOGARIPK >= @KodKp   And LLOGARIPK <= @KodKs  And 
                DATEDOK   >= @DateKp  And DATEDOK   <= @DateKs And
                ORG       >= @OrgKp   And ORG       <= @OrgKs  And
                TIPDOK    >= @TipKp   And TIPDOK    <= @TipKs  And
                REFERDOK  >= @RefFkKp And REFERDOK  <= @RefFkKs
       GROUP BY YEAR(DATEDOK),MONTH(DATEDOK),ORG,LLOGARIPK

         ) Pv1

        Pivot
                (SUM(DB) For ORG IN ([A],[B],[E],[T],[H],[D],[S],[F],[G])) As Pv2; 


         SELECT VITI,MUAJ,LLOGARIPK,
                ARKR = ISNULL(A,0),
                BAKR = ISNULL(B,0),
                VSKR = ISNULL(E,0),
                FKKR = ISNULL(T,0),
                FHKR = ISNULL(H,0),
                FDKR = ISNULL(D,0),
                FJKR = ISNULL(S,0),
                FFKR = ISNULL(F,0),
                DGKR = ISNULL(G,0)
           INTO #TMP2M
           FROM
        (
         SELECT ORG,LLOGARIPK,
                VITI = YEAR(DATEDOK),
                MUAJ = MONTH(DATEDOK),
                KR   = SUM(CASE WHEN TREGDK='K' THEN DBKRMV ELSE 0 END)
           FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR=B.NRD
          WHERE LLOGARIPK >= @KodKp   And LLOGARIPK <= @KodKs  And 
                DATEDOK   >= @DateKp  And DATEDOK   <= @DateKs And
                ORG       >= @OrgKp   And ORG       <= @OrgKs  And
                TIPDOK    >= @TipKp   And TIPDOK    <= @TipKs  And
                REFERDOK  >= @RefFkKp And REFERDOK  <= @RefFkKs
       GROUP BY YEAR(DATEDOK),MONTH(DATEDOK),ORG,LLOGARIPK

         ) Pv1

        Pivot
                (SUM(KR) For ORG IN ([A],[B],[E],[T],[H],[D],[S],[F],[G])) As Pv2; 


         SELECT LLOGARIPK,
                VITI = YEAR(DATEDOK),
                MUAJ = MONTH(DATEDOK),
                DK   = SUM(DBKRMV) 
           INTO #TMP3M
           FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR=B.NRD
          WHERE LLOGARIPK >= @KodKp   And LLOGARIPK <= @KodKs  And 
                DATEDOK   >= @DateKp  And DATEDOK   <= @DateKs And
                ORG       >= @OrgKp   And ORG       <= @OrgKs  And
                TIPDOK    >= @TipKp   And TIPDOK    <= @TipKs  And
                REFERDOK  >= @RefFkKp And REFERDOK  <= @RefFkKs
       GROUP BY YEAR(DATEDOK),MONTH(DATEDOK),LLOGARIPK;


         SELECT KOMENT  = 'Kontabilitet',
                A.VITI,
                A.MUAJ,
                LLOGARI=A.LLOGARIPK,
                C.PERSHKRIM,
                AR_DB  = ARDB, AR_KR  = ARKR,
                BA_DB  = BADB, BA_KR  = BAKR,
                VS_DB  = VSDB, VS_KR  = VSKR,
                FK_DB  = FKDB, FK_KR  = FKKR,
                FH_DB  = FHDB, FH_KR  = FHKR,
                FD_DB  = FDDB, FD_KR  = FDKR,
                FJ_DB  = FJDB, FJ_KR  = FJKR,
                FF_DB  = FFDB, FF_KR  = FFKR,
                DG_DB  = DGDB, DG_KR  = DGKR,
                TOT_DK = A.DK,
                TOT_DB = ARDB + BADB + VSDB + FKDB + FHDB + FDDB + FJDB + FFDB + DGDB,
                TOT_KR = ARKR + BAKR + VSKR + FKKR + FHKR + FDKR + FJKR + FFKR + DGKR,
                TAGNR    = 0,
                TROW     = Cast(0 As Bit),
                NRRENDOR = 0
           FROM #TMP3M A LEFT JOIN #TMP1M  T1 ON A.VITI=T1.VITI AND A.MUAJ=T1.MUAJ AND A.LLOGARIPK=T1.LLOGARIPK
                         LEFT JOIN #TMP2M  T2 ON A.VITI=T2.VITI AND A.MUAJ=T2.MUAJ AND A.LLOGARIPK=T2.LLOGARIPK
                         LEFT JOIN LLOGARI C  ON A.LLOGARIPK=C.KOD
       ORDER BY A.VITI,A.LLOGARIPK,A.MUAJ;

       end;

----   Vjetore
    if @PModel = 'V'
       begin

          if Object_Id('TempDB..#TMP1V') is not null
             DROP TABLE #TMP1V;  
          if Object_Id('TempDB..#TMP2V') is not null
             DROP TABLE #TMP2V;  
          if Object_Id('TempDB..#TMP3V') is not null
             DROP TABLE #TMP3V;  



         SELECT VITI,LLOGARIPK,
                ARDB = ISNULL(A,0),
                BADB = ISNULL(B,0),
                VSDB = ISNULL(E,0),
                FKDB = ISNULL(T,0),
                FHDB = ISNULL(H,0),
                FDDB = ISNULL(D,0),
                FJDB = ISNULL(S,0),
                FFDB = ISNULL(F,0),
                DGDB = ISNULL(G,0)
           INTO #TMP1V
           FROM
        (
         SELECT ORG,LLOGARIPK,
                VITI = YEAR(DATEDOK),
                DB   = SUM(CASE WHEN TREGDK='D' THEN DBKRMV ELSE 0 END)
           FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR=B.NRD
          WHERE LLOGARIPK >= @KodKp   And LLOGARIPK <= @KodKs  And 
                DATEDOK   >= @DateKp  And DATEDOK   <= @DateKs And
                ORG       >= @OrgKp   And ORG       <= @OrgKs  And
                TIPDOK    >= @TipKp   And TIPDOK    <= @TipKs  And
                REFERDOK  >= @RefFkKp And REFERDOK  <= @RefFkKs
       GROUP BY YEAR(DATEDOK),ORG,LLOGARIPK

         ) Pv1

        Pivot
                (SUM(DB) For ORG IN ([A],[B],[E],[T],[H],[D],[S],[F],[G])) As Pv2; 


         SELECT VITI,LLOGARIPK,
                ARKR = ISNULL(A,0),
                BAKR = ISNULL(B,0),
                VSKR = ISNULL(E,0),
                FKKR = ISNULL(T,0),
                FHKR = ISNULL(H,0),
                FDKR = ISNULL(D,0),
                FJKR = ISNULL(S,0),
                FFKR = ISNULL(F,0),
                DGKR = ISNULL(G,0)
           INTO #TMP2V
           FROM
        (
         SELECT ORG,LLOGARIPK,
                VITI = YEAR(DATEDOK),
                KR   = SUM(CASE WHEN TREGDK='K' THEN DBKRMV ELSE 0 END)
           FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR=B.NRD
          WHERE LLOGARIPK >= @KodKp   And LLOGARIPK <= @KodKs  And 
                DATEDOK   >= @DateKp  And DATEDOK   <= @DateKs And
                ORG       >= @OrgKp   And ORG       <= @OrgKs  And
                TIPDOK    >= @TipKp   And TIPDOK    <= @TipKs  And
                REFERDOK  >= @RefFkKp And REFERDOK  <= @RefFkKs
       GROUP BY YEAR(DATEDOK),ORG,LLOGARIPK

         ) Pv1

        Pivot
                (SUM(KR) For ORG IN ([A],[B],[E],[T],[H],[D],[S],[F],[G])) As Pv2; 


         SELECT LLOGARIPK,
                VITI = YEAR(DATEDOK),
                DK   = SUM(DBKRMV) 
           INTO #TMP3V
           FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR=B.NRD
          WHERE LLOGARIPK >= @KodKp   And LLOGARIPK <= @KodKs  And 
                DATEDOK   >= @DateKp  And DATEDOK   <= @DateKs And
                ORG       >= @OrgKp   And ORG       <= @OrgKs  And
                TIPDOK    >= @TipKp   And TIPDOK    <= @TipKs  And
                REFERDOK  >= @RefFkKp And REFERDOK  <= @RefFkKs
       GROUP BY YEAR(DATEDOK),LLOGARIPK;


         SELECT KOMENT  = 'Kontabilitet',
                A.VITI,
                LLOGARI=A.LLOGARIPK,
                C.PERSHKRIM,
                AR_DB  = ARDB, AR_KR  = ARKR,
                BA_DB  = BADB, BA_KR  = BAKR,
                VS_DB  = VSDB, VS_KR  = VSKR,
                FK_DB  = FKDB, FK_KR  = FKKR,
                FH_DB  = FHDB, FH_KR  = FHKR,
                FD_DB  = FDDB, FD_KR  = FDKR,
                FJ_DB  = FJDB, FJ_KR  = FJKR,
                FF_DB  = FFDB, FF_KR  = FFKR,
                DG_DB  = DGDB, DG_KR  = DGKR,
                TOT_DK = A.DK,
                TOT_DB = ARDB + BADB + VSDB + FKDB + FHDB + FDDB + FJDB + FFDB + DGDB,
                TOT_KR = ARKR + BAKR + VSKR + FKKR + FHKR + FDKR + FJKR + FFKR + DGKR,
                TAGNR    = 0,
                TROW     = Cast(0 As Bit),
                NRRENDOR = 0
           FROM #TMP3V A LEFT JOIN #TMP1V  T1 ON A.VITI=T1.VITI AND A.LLOGARIPK=T1.LLOGARIPK
                         LEFT JOIN #TMP2V  T2 ON A.VITI=T2.VITI AND A.LLOGARIPK=T2.LLOGARIPK
                         LEFT JOIN LLOGARI C  ON A.LLOGARIPK=C.KOD
       ORDER BY A.VITI,A.LLOGARIPK;

       end;
GO
