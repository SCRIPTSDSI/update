SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE     procedure [dbo].[Isd_TestMgFiro]
(
  @pWhereMg   Varchar(Max),
  @pWhereFt   Varchar(Max),
  @PTipTest   Varchar(20)
 )

AS

-- Teste per firot, sidomos mbas rivleresimit te magazines:
-- Test per sasite dhe Tipet vlen kurdohere (1 dhe 2)

-- EXEC dbo.Isd_TestMgFiro ' (KMAG=''PG1'') AND (DATEDOK >= DBO.DATEVALUE(''31.01.2014'')) ',' (DATEDOK >= DBO.DATEVALUE(''31.01.2014'')) ','HDS'



     DECLARE @sSql             NVARCHAR(MAX),
             @sSql1            NVARCHAR(MAX),
             @sSql2            NVARCHAR(MAX),
             @sSql3            NVARCHAR(MAX),
             @sSql4            NVARCHAR(MAX);
             

         SET NOCOUNT ON;


         SET @sSql           = '
         
         
-- 1.        Test Sasi me SasiFr

      SELECT DOKUMENT        = ''FD'',
      
             B.KMAG,
             B.NRDOK,
             B.NRFRAKS,
             B.DATEDOK,
             B.SHENIM1,
             B.SHENIM2,
             B.DST,
             
             KOD             = A.KARTLLG,
             A.PERSHKRIM,
             A.TIPFR,
             A.SASI,
             A.SASIFR,
             DIFER_SASI      = ROUND(A.SASI    -  A.SASIFR,2),
             A.VLERAM,
             A.VLERAFR,
             DIFER_VLERE     = ROUND(A.VLERAM  -  A.VLERAFR,2),
             DIFVL_MG_FRCALC = ROUND(A.VLERAM  - (A.CMIMM*A.SASIFR),2),
             DIFVL_FR_FRCALC = ROUND(A.VLERAFR - (A.CMIMM*A.SASIFR),2),
             A.NRD,
             B.NRRENDOR,
             ERRORORDER      = 1,
             ERRORMSG        = ''Gabim Sasi''
        FROM FDSCR A INNER JOIN FD B ON A.NRD=B.NRRENDOR
       WHERE B.DOK_JB=0 AND ISNULL(A.SASIFR,0)<>0 AND 
            (SIGN(A.SASI)<>SIGN(A.SASIFR) OR ABS(ROUND(A.SASI-A.SASIFR,2))>=0.01) AND 
            (1=1) 
            
            
   UNION ALL         


-- 2.        Test Tip Firo

      SELECT DOKUMENT        = ''FD'',
      
             B.KMAG,
             B.NRDOK,
             B.NRFRAKS,
             B.DATEDOK,
             B.SHENIM1,
             B.SHENIM2,
             B.DST,
             
             KOD             = A.KARTLLG,
             A.PERSHKRIM,
             A.TIPFR,
             A.SASI,
             A.SASIFR,
             DIFER_SASI      = ROUND(A.SASI    -  A.SASIFR,2),
             A.VLERAM,
             A.VLERAFR,
             DIFER_VLERE     = ROUND(A.VLERAM  -  A.VLERAFR,2),
             DIFVL_MG_FRCALC = ROUND(A.VLERAM  - (A.CMIMM*A.SASIFR),2),
             DIFVL_FR_FRCALC = ROUND(A.VLERAFR - (A.CMIMM*A.SASIFR),2),
             A.NRD,
             B.NRRENDOR,
             ERRORORDER      = 2,
             ERRORMSG        = ''Firo pa klasifikim''
        FROM FDSCR A INNER JOIN FD B ON A.NRD=B.NRRENDOR
       WHERE B.DOK_JB=0 AND (A.SASIFR<>0 OR A.VLERAFR<>0) AND 
            (ISNULL(A.TIPFR,'''')='''' OR CHARINDEX(ISNULL(A.TIPFR,''''),''BCDEFGHIJ'')=0) AND 
            (1=1) 


   UNION ALL


-- 3.        Test a. Sasi=SasiFr Por vleftat ndryshojne
--                b. VleraFr<> SasiFr*CmimM

      SELECT DOKUMENT        = ''FD'',
      
             B.KMAG,
             B.NRDOK,
             B.NRFRAKS,
             B.DATEDOK,
             B.SHENIM1,
             B.SHENIM2,
             B.DST,
             
             KOD             = A.KARTLLG,
             A.PERSHKRIM,
             A.TIPFR,
             A.SASI,
             A.SASIFR,
             DIFER_SASI      = ROUND(A.SASI    -  A.SASIFR,2),
             A.VLERAM,
             A.VLERAFR,
             DIFER_VLERE     = ROUND(A.VLERAM  -  A.VLERAFR,2),
             DIFVL_MG_FRCALC = ROUND(A.VLERAM  - (A.CMIMM*A.SASIFR),2),
             DIFVL_FR_FRCALC = ROUND(A.VLERAFR - (A.CMIMM*A.SASIFR),2),
             A.NRD,
             B.NRRENDOR,
             ERRORORDER      = 3,
             ERRORMSG        = ''VleraFr<>Sasi*CmimM''
        FROM FDSCR A INNER JOIN FD B ON A.NRD=B.NRRENDOR
       WHERE B.DOK_JB=0 AND ISNULL(A.SASIFR,0)<>0 AND          -- ISNULL(A.TIPFR,'''')<>'''' AND 
            (CASE WHEN ABS(ROUND(A.SASI-A.SASIFR,2))>=0.01 
                  THEN ABS(ROUND((A.CMIMM*A.SASIFR) - A.VLERAFR,2)) 
                  ELSE ABS(ROUND( A.VLERAM          - A.VLERAFR,2))
             END > 0.1 ) AND 
            (1=1)
';

         --  Fd
         SET @sSql1      = @sSql;    

         --  Fh
         SET @sSql2      = Replace(Replace(Replace(@sSql,' FD ',' FH '),' FDSCR ',' FHSCR '),'''FD''','''FH''');   

         --  Fj

         SET @sSql3 = '
         

-- 4.        Test Llogari LM sipas klase firo e gabuar

      SELECT DOKUMENT        = '''',
      
             KMAG            = '''',
             NRDOK           = 0,
             NRFRAKS         = 0,
             DATEDOK         = NULL,
             SHENIM1         = '''',
             SHENIM2         = '''',
             DST             = '''',             

             KOD             = A1.KOD,
             PERSHKRIM       = R1.PERSHKRIM,
             TIPFR           = A1.TIPFR,
             
             SASI            = 0,
             SASIFR          = 0,
             DIFER_SASI      = 0,
             VLERAM          = 0,
             VLERAFR         = 0,
             DIFER_VLERE     = 0,
             
             DIFVL_MG_FRCALC = 0,
             DIFVL_FR_FRCALC = 0,
             NRD             = 0,
             NRRENDOR        = R1.NRRENDOR,
             ERRORORDER      = 4,
             ERRORMSG        = A1.ERRORMSG
        FROM 
      ( 
             SELECT A.KOD,
                    A.TIPFR,
                    ERRORMSG = CASE WHEN MAX(ISNULL(R2.NRD,0))=0
                                         THEN ''Skeme LM per firo e parcaktuar'' 
                                         
                                    WHEN A.TIPFR='''' OR CHARINDEX(A.TIPFR,''ABCDEFGHIJ'')=0 
                                         THEN ''Klase firo jo e regullt'' 
             
                                    WHEN (A.TIPFR=''A'' AND ISNULL((SELECT ISNULL(POZIC,0) FROM LLOGARI R3 WHERE MAX(ISNULL(R2.LLOGARIA,''''))=R3.KOD),0)<>1) OR
                                         (A.TIPFR=''B'' AND ISNULL((SELECT ISNULL(POZIC,0) FROM LLOGARI R3 WHERE MAX(ISNULL(R2.LLOGARIB,''''))=R3.KOD),0)<>1) OR 
                                         (A.TIPFR=''C'' AND ISNULL((SELECT ISNULL(POZIC,0) FROM LLOGARI R3 WHERE MAX(ISNULL(R2.LLOGARIC,''''))=R3.KOD),0)<>1) OR 
                                         (A.TIPFR=''D'' AND ISNULL((SELECT ISNULL(POZIC,0) FROM LLOGARI R3 WHERE MAX(ISNULL(R2.LLOGARID,''''))=R3.KOD),0)<>1) OR 
                                         (A.TIPFR=''E'' AND ISNULL((SELECT ISNULL(POZIC,0) FROM LLOGARI R3 WHERE MAX(ISNULL(R2.LLOGARIE,''''))=R3.KOD),0)<>1) OR 
                                         (A.TIPFR=''F'' AND ISNULL((SELECT ISNULL(POZIC,0) FROM LLOGARI R3 WHERE MAX(ISNULL(R2.LLOGARIF,''''))=R3.KOD),0)<>1) OR 
                                         (A.TIPFR=''G'' AND ISNULL((SELECT ISNULL(POZIC,0) FROM LLOGARI R3 WHERE MAX(ISNULL(R2.LLOGARIG,''''))=R3.KOD),0)<>1) OR 
                                         (A.TIPFR=''H'' AND ISNULL((SELECT ISNULL(POZIC,0) FROM LLOGARI R3 WHERE MAX(ISNULL(R2.LLOGARIH,''''))=R3.KOD),0)<>1) OR 
                                         (A.TIPFR=''I'' AND ISNULL((SELECT ISNULL(POZIC,0) FROM LLOGARI R3 WHERE MAX(ISNULL(R2.LLOGARII,''''))=R3.KOD),0)<>1) OR              
                                         (A.TIPFR=''J'' AND ISNULL((SELECT ISNULL(POZIC,0) FROM LLOGARI R3 WHERE MAX(ISNULL(R2.LLOGARIJ,''''))=R3.KOD),0)<>1)
                                         THEN ''Llogari firo ''+A.TIPFR+'' jo e sakte'' 
                                   ELSE ''''     
                               END
               FROM
               
                 (
                    SELECT KOD = A.KARTLLG, TIPFR = ISNULL(A.TIPFR,'''')
                      FROM FDSCR A INNER JOIN FD      B  ON A.NRD=B.NRRENDOR
                                   LEFT  JOIN ARTIKUJ R1 ON A.KARTLLG=R1.KOD
                     WHERE CHARINDEX(''D'','''+@PTipTest+''')>0 AND
                           B.DOK_JB=0 AND (A.SASIFR<>0 OR A.VLERAFR<>0) AND 
                          (1=1)
                  GROUP BY A.KARTLLG,A.TIPFR 
    
                 UNION ALL
   
                    SELECT KOD = A.KARTLLG, TIPFR = ISNULL(A.TIPFR,'''')
                      FROM FHSCR A INNER JOIN FH      B  ON A.NRD=B.NRRENDOR
                                   LEFT  JOIN ARTIKUJ R1 ON A.KARTLLG=R1.KOD
                     WHERE CHARINDEX(''H'','''+@PTipTest+''')>0 AND
                           B.DOK_JB=0 AND (A.SASIFR<>0 OR A.VLERAFR<>0) AND 
                          (1=1)
                  GROUP BY A.KARTLLG,A.TIPFR 
    
                 UNION ALL   

                    SELECT KOD = A.KARTLLG, TIPFR = ISNULL(A.TIPFR,'''')
                      FROM FJSCR A INNER JOIN FJ      B  ON A.NRD=B.NRRENDOR
                                   LEFT  JOIN ARTIKUJ R1 ON A.KARTLLG=R1.KOD
                     WHERE CHARINDEX(''S'','''+@PTipTest+''')>0 AND 
                          (A.SASIFR<>0 OR A.VLERAFR<>0) AND 
                          (2=2)
                  GROUP BY A.KARTLLG,ISNULL(A.TIPFR,'''') 
    
                         ) A   LEFT  JOIN ARTIKUJ    R1 ON A.KOD=R1.KOD
                               LEFT  JOIN ARTIKUJFIR R2 ON R1.NRRENDOR=R2.NRD

           GROUP BY A.KOD,A.TIPFR  
           
                 ) A1  LEFT  JOIN ARTIKUJ    R1 ON A1.KOD=R1.KOD
                 
       WHERE ERRORMSG<>''''
       
    ORDER BY ERRORORDER,KMAG,DATEDOK,NRDOK,KOD,TIPFR; '

          IF CHARINDEX('D',@PTipTest)=0
             SET @sSql1      = Replace(@sSql1,'(1=1)','1=2');
             
          IF CHARINDEX('H',@PTipTest)=0
             SET @sSql2      = Replace(@sSql2,'(1=1)','1=2');

          IF CHARINDEX('S',@PTipTest)=0
             SET @sSql3      = Replace(@sSql3,'(2=2)','1=2');
             
         SET @sSql = @sSql1 + '
               
   UNION ALL '     + @sSql2 + '
   
   UNION ALL '     + @sSql3;
             

          IF @pWhereMg<>''
             SET @sSql = Replace(@sSql,'(1=1)',@pWhereMg);

          IF @pWhereFt<>''   
             SET @sSql = Replace(@sSql,'(2=2)',@pWhereFt);

             

  PRINT @sSql;
       EXEC (@sSql);


/*

   UNION ALL


-- 4.        Test Skeme LM per Firo te brendeshme

      SELECT DOKUMENT        = ''FD'',
      
             KMAG            = '''',
             NRDOK           = 0,
             NRFRAKS         = 0,
             DATEDOK         = NULL,
             SHENIM1         = '''',
             SHENIM2         = '''',
             DST             = '''',
             
             KOD             = A.KARTLLG,
             PERSHKRIM       = MAX(A.PERSHKRIM),
             TIPFR           = '''',
             SASI            = 0,
             SASIFR          = 0,
             DIFER_SASI      = 0,
             VLERAM          = 0,
             VLERAFR         = 0,
             DIFER_VLERE     = 0,
             DIFVL_MG_FRCALC = 0,
             DIFVL_FR_FRCALC = 0,
             NRD             = 0,
             NRRENDOR        = 0,
             ERRORORDER      = 4,
             ERRORMSG        = ''Skeme LM per firo brendeshme''
        FROM FDSCR A INNER JOIN FD         B  ON A.NRD=B.NRRENDOR
                     LEFT  JOIN ARTIKUJ    R1 ON A.KARTLLG=R1.KOD
                     LEFT  JOIN ARTIKUJFIR R2 ON R1.NRRENDOR=R2.NRD
       WHERE B.DOK_JB=0 AND (A.SASIFR<>0 OR A.VLERAFR<>0) AND (ISNULL(R2.NRD,0)=0) AND 
            (1=1)
    GROUP BY A.KARTLLG 

*/


/*
         SET @sSql3      = '
         
         
-- 5.        Test Skeme LM per Firo te jashtme (shitje)

      SELECT DOKUMENT        = ''FJ'',
      
             KMAG            = '''',
             NRDOK           = 0,
             NRFRAKS         = 0,
             DATEDOK         = NULL,
             SHENIM1         = '''',
             SHENIM2         = '''',
             DST             = '''',
             
             KOD             = A.KARTLLG,
             PERSHKRIM       = MAX(A.PERSHKRIM),
             TIPFR           = ''A'',
             SASI            = 0,
             SASIFR          = 0,
             DIFER_SASI      = 0,
             VLERAM          = 0,
             VLERAFR         = 0,
             DIFER_VLERE     = 0,
             DIFVL_MG_FRCALC = 0,
             DIFVL_FR_FRCALC = 0,
             NRD             = 0,
             NRRENDOR        = 0,
             ERRORORDER      = 5,
             ERRORMSG        = ''Skeme LM per firo shitje''
        FROM FJSCR A INNER JOIN FJ         B  ON A.NRD=B.NRRENDOR
                     LEFT  JOIN ARTIKUJ    R1 ON A.KARTLLG=R1.KOD
                     LEFT  JOIN ARTIKUJFIR R2 ON R1.NRRENDOR=R2.NRD
       WHERE (A.SASIFR<>0 OR A.VLERAFR<>0) AND (ISNULL(R2.NRD,0)=0) AND 
             (2=2)
    GROUP BY A.KARTLLG   
';

*/
GO
