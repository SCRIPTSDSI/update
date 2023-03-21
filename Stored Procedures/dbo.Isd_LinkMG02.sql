SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- declare @PWhere1     Varchar(Max),
--         @PWhere2     Varchar(Max),
--         @PDistinct   Bit 
--     Set @PWhere1   = ' (  DATEDOK>=DBO.DATEVALUE(''01/01/2012'') And   DATEDOK<=DBO.DATEVALUE(''21/09/2012'')) '
--     Set @PWhere2   = ''
--     Set @PDistinct = 1
--    Exec dbo.Isd_LinkMG02 @PWhere1,@PWhere2,@PDistinct


CREATE Procedure [dbo].[Isd_LinkMG02]
(
  @PWhere1       Varchar(MAX),
  @PWhere2       Varchar(MAX),  -- nuk perdoret
  @PDistinct     Bit
 )

AS

         SET NOCOUNT ON


     DECLARE @Sql          nVarchar(MAX),
             @SqlUn        nVarchar(MAX),
             @Distinct      Varchar(20);


          IF OBJECT_ID('TempDB..#FdFhLidhje01') IS NOT NULL
             DROP TABLE #FdFhLidhje01;
          IF OBJECT_ID('TempDB..#FdFhLidhje03') IS NOT NULL
             DROP TABLE #FdFhLidhje03;

      SELECT DOKTEST     = SPACE(10),
             KMAGLNKD    = KMAGLNK,
             NRDOKLNKD   = NRDOKLNK,
             NRFRAKSLNKD = NRFRAKSLNK,
             DATEDOKLNKD = DATEDOKLNK,
             NRCOUNT     = 0
        INTO #FdFhLidhje03
        FROM FD 
       WHERE 1=2;

         SET @Distinct   = '';
         
          IF @PWhere1    = ''
             SET @PWhere1 = ' 1=1 ';
             
          IF @PDistinct  =1
             SET @Distinct = 'DISTINCT';

  SET @Sql = '

-- View 01  -- FdFhLidhje01

-- Filtrim i dokumentave ne nje tabele temporare:    mbushja e FdFhLidhje01

      SELECT * 
        INTO #FdFhLidhje01
        FROM
        
    (

      SELECT DOKUMENT     = ''FD'',
             NRRENDOR, 
             KMAG, 
             NRDOK, 
             NRFRAKS      = ISNULL(NRFRAKS,0),
             DATEDOK,
             KMAGRF       = ISNULL(KMAGRF,''''),
             SHENIM1,
             SHENIM2,
             
             KMAGLNK      = ISNULL(KMAGLNK,''''),
             NRDOKLNK     = ISNULL(NRDOKLNK,0),
             NRFRAKSLNK   = ISNULL(NRFRAKSLNK,0),
             DATEDOKLNK   = ISNULL(DATEDOKLNK,DATEDOK),
             
             KMAGLNK1     = ISNULL(KMAGLNK,''''),
             NRDOKLNK1    = ISNULL(NRDOKLNK,0),
             NRFRAKSLNK1  = ISNULL(NRFRAKSLNK,0),
             DATEDOKLNK1  = ISNULL(DATEDOKLNK,DATEDOK),
             
             KMAGLNK2     = KMAG,
             NRDOKLNK2    = NRDOK,
             NRFRAKSLNK2  = ISNULL(NRFRAKS,0),
             DATEDOKLNK2  = DATEDOK
             
        FROM FD 
       WHERE ISNULL(DOK_JB,0)=0 AND        (ISNULL(DST,'''') IN (''LB'',''KM'',''DM'',''FU'',''KA'')) AND
             '+@PWhere1+'
   UNION ALL

      SELECT DOKUMENT     = ''FH'',
             NRRENDOR,
             KMAG,
             NRDOK,
             NRFRAKS      = ISNULL(NRFRAKS,0),
             DATEDOK,
             KMAGRF       = ISNULL(KMAGRF,''''),
             SHENIM1,
             SHENIM2,
             
             KMAGLNK      = ISNULL(KMAGLNK,''''),
             NRDOKLNK     = ISNULL(NRDOKLNK,0),
             NRFRAKSLNK   = ISNULL(NRFRAKSLNK,0),
             DATEDOKLNK   = ISNULL(DATEDOKLNK,DATEDOK),
             
             KMAGLNK1     = KMAG,
             NRDOKLNK1    = NRDOK,
             NRFRAKSLNK1  = ISNULL(NRFRAKS,0),
             DATEDOKLNK1  = DATEDOK,
             
             KMAGLNK2     = ISNULL(KMAGLNK,''''),
             NRDOKLNK2    = ISNULL(NRDOKLNK,0),
             NRFRAKSLNK2  = ISNULL(NRFRAKSLNK,0),
             DATEDOKLNK2  = ISNULL(DATEDOKLNK,DATEDOK)
             
        FROM FH 
       WHERE ISNULL(DOK_JB,0)=0 AND        (ISNULL(DST,'''') IN (''LB'',''KM'',''DM'',''FU'',''KA'')) AND
             '+@PWhere1+'

     ) A; 
     

-- View 02  -- FdFhLidhje03

-- Filtrim i dokumentave ne nje tabele temporare:    mbushja e #FdFhLidhje03

      INSERT INTO #FdFhLidhje03
            (DOKTEST,KMAGLNKD,NRDOKLNKD,NRFRAKSLNKD,DATEDOKLNKD,NRCOUNT)

      SELECT DOKTEST,KMAGLNKD,NRDOKLNKD,NRFRAKSLNKD,DATEDOKLNKD,NRCOUNT
        FROM

    (
      SELECT DOKTEST     = ''FD'',
             KMAGLNKD    = KMAGLNK1,
             NRDOKLNKD   = NRDOKLNK1,
             NRFRAKSLNKD = NRFRAKSLNK1,
             DATEDOKLNKD = DATEDOKLNK1,
             NRCOUNT     = COUNT(*)
        FROM #FdFhLidhje01 
    GROUP BY KMAGLNK1,NRDOKLNK1,NRFRAKSLNK1,DATEDOKLNK1
      HAVING SUM(1)<>2

   UNION ALL

      SELECT DOKTEST     = ''FH'',
             KMAGLNKD    = KMAGLNK2,
             NRDOKLNKD   = NRDOKLNK2,
             NRFRAKSLNKD = NRFRAKSLNK2,
             DATEDOKLNKD = DATEDOKLNK2,
             NRCOUNT     = COUNT(*)
        FROM #FdFhLidhje01 
    GROUP BY KMAGLNK2,NRDOKLNK2,NRFRAKSLNK2,DATEDOKLNK2
      HAVING SUM(1)<>2

    ) A ;';
    

      PRINT  @Sql;
       EXEC (@Sql);


-- Afishimi i tabeles temporare:   afishimi i #FdFhLidhje03

         SET @SqlUn    = '

      SELECT '+@Distinct+' 
             DOKUMENT  = ''TABLENAME'',
             KMAG,
             NRDOK, 
             NRFRAKS, 
             DATEDOK,
             KMAGRF,
             SHENIM1,
             SHENIM2, 
             DST,
             
             KMAGLNKD,
             NRDOKLNKD,
             NRFRAKSLNKD,
             DATEDOKLNKD,
             
             A.NRRENDOR,
             NRLIDHJE  = NRCOUNT,
             CODEERROR = 00,
             MSGERROR  = CASE WHEN NRCOUNT<=1 
                              THEN ''Mungese Lidhje dokumenti'' 
                              ELSE ''Lidhja figuron disa here'' 
                         END 
        FROM TABLENAME A INNER JOIN #FdFhLidhje03 ON KMAGLNK              = KMAGLNKD              AND 
                                                     ISNULL(NRDOKLNK,0)   = ISNULL(NRDOKLNKD,0)   AND 
                                                     ISNULL(NRFRAKSLNK,0) = ISNULL(NRFRAKSLNKD,0) AND 
                                                     DATEDOKLNK           = DATEDOKLNKD 
       WHERE '+@PWhere1;




         SET @Sql   = REPLACE(REPLACE(@SqlUn,'TABLENAME','FD'),'00','01')+'
 
   UNION ALL '      + REPLACE(REPLACE(@SqlUn,'TABLENAME','FH'),'00','02')+'
   
    ORDER BY CODEERROR,KMAG,NRDOK,NRFRAKS,DATEDOK; ';

       PRINT @Sql;
       EXEC (@Sql);



          IF OBJECT_ID('TempDB..#FdFhLidhje01') IS NOT NULL
             DROP TABLE #FdFhLidhje01;
          IF OBJECT_ID('TempDB..#FdFhLidhje03') IS NOT NULL
             DROP TABLE #FdFhLidhje03;
GO
