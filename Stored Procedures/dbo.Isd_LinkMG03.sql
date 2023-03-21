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
--    Exec dbo.Isd_LinkMG03 @PWhere1,@PWhere2,@PDistinct


CREATE Procedure [dbo].[Isd_LinkMG03]
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


          IF OBJECT_ID('TempDB..#FdFhLidhje02') IS NOT NULL
             DROP TABLE #FdFhLidhje02;
          IF OBJECT_ID('TempDB..#FdFhLidhje04') IS NOT NULL
             DROP TABLE #FdFhLidhje04;
             

      SELECT KMAGLNKD    = KMAGLNK,
             NRDOKLNKD   = NRDOKLNK,
             NRFRAKSLNKD = NRFRAKSLNK,
             DATEDOKLNKD = DATEDOKLNK,
             KARTLLG     = SPACE(30),
             NRCOUNT     = 0, 
             SASI        = CAST(0 As Float)
        INTO #FdFhLidhje04
        FROM FD 
       WHERE 1=2;

         Set @Distinct   = '';

          IF @PWhere1   = ''
             SET @PWhere1  = ' 1=1 ';
             
          IF @PDistinct = 1
             SET @Distinct = 'DISTINCT';



  Set @Sql = '

-- View 01  -- FdFhLidhje02

-- Filtrim i dokumentave ne nje tabele temporare:    mbushja e FdFhLidhje02

      SELECT * 
        INTO #FdFhLidhje02
        FROM
        
    (
    
      SELECT DOKUMENT    = ''FD'',
             FD.NRRENDOR,
             KMAG,
             NRDOK,
             NRFRAKS     = ISNULL(NRFRAKS,0),
             DATEDOK,
             KMAGRF      = ISNULL(KMAGRF,''''),
             SHENIM1,
             SHENIM2,
             
             KMAGLNK     = ISNULL(KMAGLNK,''''),
             NRDOKLNK    = ISNULL(NRDOKLNK,0),
             NRFRAKSLNK  = ISNULL(NRFRAKSLNK,0),
             DATEDOKLNK  = ISNULL(DATEDOKLNK,DATEDOK),
             
             KMAGLNK1    = ISNULL(KMAGLNK,''''),
             NRDOKLNK1   = ISNULL(NRDOKLNK,0),
             NRFRAKSLNK1 = ISNULL(NRFRAKSLNK,0),
             DATEDOKLNK1 = ISNULL(DATEDOKLNK,DATEDOK),
             
             KMAGLNK2    = KMAG,
             NRDOKLNK2   = NRDOK,
             NRFRAKSLNK2 = ISNULL(NRFRAKS,0),
             DATEDOKLNK2 = DATEDOK,  
             
             KARTLLG,
             PERSHKRIM   = FDSCR.PERSHKRIM,
             SASI,
             TIP         = ''D''
        FROM FD INNER JOIN FDSCR ON FD.NRRENDOR=FDSCR.NRD
       WHERE ISNULL(DOK_JB,0)=0 AND (ISNULL(DST,'''') IN (''LB'',''KM'',''DM'',''FU'',''KA'')) AND
             '+@PWhere1+'    

   UNION ALL

      SELECT DOKUMENT    = ''FH'',
             FH.NRRENDOR,
             KMAG,
             NRDOK,
             NRFRAKS     = ISNULL(NRFRAKS,0),
             DATEDOK,
             KMAGRF      = ISNULL(KMAGRF,''''),
             SHENIM1,
             SHENIM2,
             
             KMAGLNK     = ISNULL(KMAGLNK,''''),
             NRDOKLNK    = ISNULL(NRDOKLNK,0),
             NRFRAKSLNK  = ISNULL(NRFRAKSLNK,0),
             DATEDOKLNK  = ISNULL(DATEDOKLNK,DATEDOK),
             
             KMAGLNK1    = KMAG,
             NRDOKLNK1   = NRDOK,
             NRFRAKSLNK1 = ISNULL(NRFRAKS,0),
             DATEDOKLNK1 = DATEDOK,
             
             KMAGLNK2    = ISNULL(KMAGLNK,''''),
             NRDOKLNK2   = ISNULL(NRDOKLNK,0),
             NRFRAKSLNK2 = ISNULL(NRFRAKSLNK,0), 
             DATEDOKLNK2 = ISNULL(DATEDOKLNK,DATEDOK),
             
             KARTLLG,
             PERSHKRIM   = FHSCR.PERSHKRIM,
             SASI,
             TIP         = ''H''
        FROM FH INNER JOIN FHSCR ON FH.NRRENDOR=FHSCR.NRD
       WHERE ISNULL(DOK_JB,0)=0 AND (ISNULL(DST,'''') IN (''LB'',''KM'',''DM'',''FU'',''KA'')) AND
             '+@PWhere1+'    
             
     ) A; 


-- View 02  -- FdFhLidhje04

-- Filtrim i dokumentave ne nje tabele temporare:    mbushja e #FdFhLidhje04

      INSERT INTO #FdFhLidhje04
            (KMAGLNKD,NRDOKLNKD,NRFRAKSLNKD,DATEDOKLNKD,NRCOUNT,KARTLLG,SASI)

      SELECT KMAGLNKD,NRDOKLNKD,NRFRAKSLNKD,DATEDOKLNKD,NRCOUNT,KARTLLG,SASI
        FROM

    (
    
      SELECT KMAGLNKD    = KMAGLNK1,
             NRDOKLNKD   = NRDOKLNK1,
             NRFRAKSLNKD = NRFRAKSLNK1,
             DATEDOKLNKD = DATEDOKLNK1,
             
             KARTLLG,
             NRCOUNT     = COUNT(*), 
             SASI        = SUM(CASE WHEN TIP=''H'' THEN SASI ELSE 0-SASI END)
        FROM #FdFhLidhje02 
    GROUP BY KMAGLNK1,NRDOKLNK1,NRFRAKSLNK1,DATEDOKLNK1,KARTLLG
      HAVING (NOT ((COUNT(*)=2) AND SUM(CASE WHEN TIP=''H'' THEN SASI ELSE 0-SASI END)=0))

   UNION ALL

      SELECT KMAGLNKD    = KMAGLNK2,
             NRDOKLNKD   = NRDOKLNK2,
             NRFRAKSLNKD = NRFRAKSLNK2,
             DATEDOKLNKD = DATEDOKLNK2,
             
             KARTLLG,
             NRCOUNT     = COUNT(*), 
             SASI        = SUM(CASE WHEN TIP=''H'' THEN SASI ELSE 0-SASI END)
        FROM #FdFhLidhje02 
    GROUP BY KMAGLNK2,NRDOKLNK2,NRFRAKSLNK2,DATEDOKLNK2,KARTLLG
      HAVING (NOT ((COUNT(*)=2) AND SUM(CASE WHEN TIP=''H'' THEN SASI ELSE 0-SASI END)=0))
      
     ) A ';
     

      PRINT  @Sql;
       EXEC (@Sql);



-- Afishimi i tabeles temporare:   afishimi i #FdFhLidhje03

-- Kujdes mos duhet ne Filter ABS(B.SASI)>=0.01 AND ISNULL(KMAGLNK,'''')<>'''' AND
-- pra te shtohet ISNULL(KMAGLNK,'')<>''    ...???
-- sepse gabon rastet kur ISNULL(KMAGLNK,'')='' dhe DATELNK<>null(DATELNK ka vlere)
-- Shiko dhe testin Isd_LinkMG02 ne se duhet 31.03.2017



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
             KARTLLG,
             SASI      = ROUND(SASI,3),
             KMAGLNKD,
             NRDOKLNKD,
             NRFRAKSLNKD,
             DATEDOKLNKD,
             NRLINK    = NRCOUNT, 
             CODEERROR = 00,
             MSGERROR  = CASE WHEN ABS(B.SASI)>=0.01 
                              THEN ''Mosperputhje ne Sasi per Artikujt'' 
                              ELSE ''Mosperputhje Artikujt ne Lidhja'' 
                         END,
             A.NRRENDOR
        FROM TABLENAME A INNER JOIN #FdFhLidhje04 B ON KMAGLNK              = KMAGLNKD              AND 
                                                       ISNULL(NRDOKLNK,0)   = ISNULL(NRDOKLNKD,0)   AND 
                                                       ISNULL(NRFRAKSLNK,0) = ISNULL(NRFRAKSLNKD,0) AND 
                                                       DATEDOKLNK           = DATEDOKLNKD 
       WHERE ABS(B.SASI)>=0.01 AND 
           '+@PWhere1;




         SET @Sql   =  REPLACE(REPLACE(@SqlUn,'TABLENAME','FD'),'00','01')+'
 
   UNION ALL '       + REPLACE(REPLACE(@SqlUn,'TABLENAME','FH'),'00','02')+'
   
    ORDER BY CODEERROR,KMAG,NRDOK,NRFRAKS,DATEDOK; ';

      PRINT  @Sql;
      EXEC  (@Sql);



          IF OBJECT_ID('TempDB..#FdFhLidhje02') IS NOT NULL
             DROP TABLE #FdFhLidhje02;
          IF OBJECT_ID('TempDB..#FdFhLidhje04') IS NOT NULL
             DROP TABLE #FdFhLidhje04;

GO
