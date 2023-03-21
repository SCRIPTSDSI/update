SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   Procedure [dbo].[Isd_Transactions_LM]
( 
  @pTableName Varchar(50),  
  @pKod1      Varchar(30),
  @pKod2      Varchar(30),
  @pKMon1     Varchar(30),
  @pKMon2     Varchar(30),
  @pKMag1     Varchar(30),  
  @pKMag2     Varchar(30),
  @pKDep1     Varchar(30),  
  @pKDep2     Varchar(30),
  @pKList1    Varchar(30),  
  @pKList2    Varchar(30),
  @pDate1     Varchar(30),
  @pDate2     Varchar(30)
 )
AS
-- Declare @pTableName   Varchar(30),
--         @pKod1        Varchar(30),
--         @pKod2        Varchar(30),
--         @pKMon1       Varchar(30),
--         @pKMon2       Varchar(30),
--         @pKMag1       Varchar(30),  
--         @pKMag2       Varchar(30),
--         @pKDep1       Varchar(30),  
--         @pKDep2       Varchar(30),
--         @pDate1       Varchar(20),
--         @pDate2       Varchar(20)
--     SET @pTableName = ''
--     SET @pKod1      = '608'
--     SET @pKod2      = '608z'
--     SET @pKMon1     = ''
--     SET @pKMon2     = ' A'  -- Vetem Mb
--     SET @pKMag1     = ''
--     SET @pKMag2     = ''
--     SET @pKDep1     = ''
--     SET @pKDep2     = ''
--     SET @pKList1    = ''
--     SET @pKList2    = ''
--     SET @pDate1     = '01/01/2013'
--     SET @pDate2     = '30/06/2013'
--EXEC [dbo].[Isd_Transactions_LM]   @pTableName,@pKod1,@pKod2,@pKMon1,@pKMon2,@pKMag1,@pKMag2,@pKDep1,@pKDep2,@pKMag1,@pKMag2,@pDate1,@pDate2


-- Transaksionet ne vlefte progresive

          IF OBJECT_ID('Tempdb..#Cte') IS NOT NULL
             DROP TABLE #Cte;


      SELECT LLOGARIPK = REPLICATE(' ',60),
             KMON      = REPLICATE(' ',30),
             KMAG      = REPLICATE(' ',30),
             DEP       = REPLICATE(' ',30),
             LIST      = REPLICATE(' ',30),
             VL        = CAST(0 AS FLOAT),
             VLMV      = CAST(0 AS FLOAT),
             RN        = 0,
             NRRENDOR  = 0 
        INTO #Cte 
       WHERE 1=2;

     DECLARE @Sql         Varchar(MAX),
             @Where1      Varchar(MAX),
             @Where2      Varchar(MAX),
             @Where3      Varchar(MAX),
             @Lidhez      Varchar(10);

         SET @Where1   = '';
         SET @Where2   = '';
         SET @Lidhez   = '';

         IF  @pKod1<>'' OR @pKod2<>''
             BEGIN
               IF  @pKod1<>'' 
                   BEGIN
                     SET @Where1 = @Where1 + @Lidhez + 'CASE WHEN CHARINDEX(''.'',B.KOD)>0 THEN LEFT(B.KOD,CHARINDEX(''.'',B.KOD)-1) ELSE B.KOD END>='+QuoteName(@pKod1, '''');
                     SET @Lidhez = ' AND ';
                   END;
               IF  @pKod2<>'' 
                   SET   @Where1 = @Where1 + @Lidhez + 'CASE WHEN CHARINDEX(''.'',B.KOD)>0 THEN LEFT(B.KOD,CHARINDEX(''.'',B.KOD)-1) ELSE B.KOD END<='+QuoteName(@pKod2, '''');
               SET @Lidhez = ' AND ';
             END;

         IF  @pKMon1<>'' OR @pKMon2<>''
             BEGIN
               IF  @pKMon1<>''
                   BEGIN
                     SET @Where1 = @Where1 + @Lidhez + 'B.KMON>='+QuoteName(@pKMon1,'''');
                     SET @Lidhez = ' AND ';
                   END;
               IF  @pKMon2<>''
                   SET   @Where1 = @Where1 + @Lidhez + 'B.KMON<='+QuoteName(@pKMon2,'''');
               SET @Lidhez = ' AND ';
             END;

         IF  @pKMag1<>'' OR @pKMag2<>''
             BEGIN
               IF  @pKMag1<>''
                   BEGIN
                     SET @Where1 = @Where1 + @Lidhez + 'A.KMAG>='+QuoteName(@pKMag1,'''');
                     SET @Lidhez = ' AND ';
                   END
               IF  @pKMag2<>''
                   SET   @Where1 = @Where1 + @Lidhez + 'A.KMAG<='+QuoteName(@pKMag2,'''');
               SET @Lidhez = ' AND ';
             END;

         IF  @pKDep1<>'' OR @pKDep2<>''
             BEGIN
               IF  @pKDep1<>'' 
                   BEGIN
                     SET @Where1 = @Where1 + @Lidhez + 'dbo.Isd_SegmentFind(B.KOD,0,2)>='+QuoteName(@pKDep1,'''');
                     SET @Lidhez = ' AND ';
                   END;
               IF  @pKDep2<>'' 
                   SET   @Where1 = @Where1 + @Lidhez + 'dbo.Isd_SegmentFind(B.KOD,0,2)<='+QuoteName(@pKDep2,'''');
               SET @Lidhez = ' AND ';
             END;

         IF  @pKList1<>'' OR @pKList2<>''
             BEGIN
               IF  @pKList1<>'' 
                   BEGIN
                     SET @Where1 = @Where1 + @Lidhez + 'dbo.Isd_SegmentFind(B.KOD,0,3)>='+QuoteName(@pKList1,'''');
                     SET @Lidhez = ' AND ';
                   END;
               IF  @pKDep2<>'' 
                   SET   @Where1 = @Where1 + @Lidhez + 'dbo.Isd_SegmentFind(B.KOD,0,3)<='+QuoteName(@pKList2,'''');
               SET @Lidhez = ' AND ';
             END;

         SET @Where2 = @Where1;

         IF  @pDate1<>'' OR @pDate2<>''
             BEGIN
               IF  @pDate1<>'' 
                   BEGIN
                     SET @Where1 = @Where1 + @Lidhez + 'A.DATEDOK>=dbo.DATEVALUE('+QuoteName(@pDate1,'''')+')';
                     SET @Where2 = @Where2 + @Lidhez + 'A.DATEDOK< dbo.DATEVALUE('+QuoteName(@pDate1,'''')+')';
                     SET @Lidhez = ' AND ';
                   END;
               IF  @pDate2<>'' 
                   SET   @Where1 = @Where1 + @Lidhez + 'A.DATEDOK<=dbo.DATEVALUE('+QuoteName(@pDate2,'''')+')';
               SET @Lidhez = ' AND ';
             END



         SET @Sql = '

      INSERT INTO #Cte
            (KMON,LLOGARIPK,VL,VLMV,RN,NRRENDOR)
      SELECT B.KMON,
             B.LLOGARIPK,
             VL         = SUM(CASE WHEN TREGDK=''D'' THEN DB   ELSE 0-KR END),
             VLMV       = SUM(DBKRMV),
             Rn         = 0,
             0
        FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR=B.NRD
       WHERE 2=2
    GROUP BY B.KMON,B.LLOGARIPK
    ORDER BY B.KMON,B.LLOGARIPK;

      INSERT INTO #Cte
            (KMON,LLOGARIPK,VL,VLMV,RN,NRRENDOR)
      SELECT B.KMON,
             B.LLOGARIPK,
             VL         = CASE WHEN B.TREGDK=''D'' THEN B.DB   ELSE 0-B.KR END,
             VLMV       = B.DBKRMV,
             Rn         = ROW_NUMBER() OVER(PARTITION By B.KMON,B.LLOGARIPK ORDER BY A.DATEDOK,A.NRRENDOR),
             NRRENDOR   = CAST(B.NRRENDOR AS BigInt)
        FROM FK A INNER JOIN FKSCR B On A.NRRENDOR=B.NRD
       WHERE 1=1
    ORDER BY B.KMON,B.LLOGARIPK,Rn


;WITH Cte AS
(
      SELECT A.DATEDOK,A.NUMDOK,A.TIPDOK,A.ORG,A.REFERDOK,A.DST,
             DEP        = dbo.Isd_SegmentFind(B.KOD,0,2),
             LIST       = dbo.Isd_SegmentFind(B.KOD,0,3),
             KMAG       = dbo.Isd_SegmentFind(B.KOD,0,4),
             B.*,
             Rn         = ROW_NUMBER() OVER(PARTITION By B.KMON,B.LLOGARIPK ORDER BY A.DATEDOK,A.NRRENDOR)
        FROM FK A INNER JOIN FKSCR B On A.NRRENDOR=B.NRD
       WHERE 1=1
)

      SELECT KOD,
             PERSHKRIM,
             KOMENT,
             TIPDOK,
             NUMDOK,
             DATEDOK,
             DEP,
             LIST,
             KMAG,
             KMON,
             DEBI       = CASE WHEN TREGDK=''D'' THEN DB       ELSE 0        END,
             KREDI      = CASE WHEN TREGDK=''K'' THEN KR       ELSE 0        END,
             VLEFTEMV   = CASE WHEN TREGDK=''D'' THEN DBKRMV   ELSE 0-DBKRMV END,
             Rn         = ROW_NUMBER() OVER(PARTITION By KMON,LLOGARIPK ORDER BY DATEDOK,NRRENDOR),
             KURS       = CASE WHEN KURS2=KURS1  THEN ''''     ELSE CAST(KURS1 AS VARCHAR)+'' - ''+CAST(KURS2 AS VARCHAR) END,
             SHUMAPRG   = (SELECT SUM(B.VL)   FROM #Cte B  WHERE A.KMON=B.KMON AND A.LLOGARIPK=B.LLOGARIPK AND B.Rn<=A.Rn),
             SHUMAPRGMV = (SELECT SUM(B.VLMV) FROM #Cte B  WHERE A.KMon=B.KMon AND A.LLOGARIPK=B.LLOGARIPK AND B.Rn<=A.Rn),
             REFERDOK,
             TREGDK,ORG,DST,
             NRRENDOR,
             TAGNR      = 0,
             TROW       = CAST(0 AS BIT) 
                        
        FROM Cte A
    -- WHERE 3=3
    ORDER BY A.KMON,A.LLOGARIPK,A.DATEDOK,A.NRRENDOR; '


         IF  @Where1<>''
             SET @Sql = Replace(@Sql,'1=1',@Where1);
         IF  @Where2<>''
             SET @Sql = Replace(@Sql,'2=2',@Where2);

       PRINT @Sql;
       EXEC (@Sql);

GO
