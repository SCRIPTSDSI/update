SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE          procedure [dbo].[Isd_FiroDetajTest]
(
  @pTipDok         Varchar(10),
  @pTableScrName   Varchar(50),
  @pDst            Varchar(20),
  @pNrRendor       BigInt
)
AS
-- Exec Isd_FiroDetajTest 'FJ','FJSCR', '',  1
-- Exec Isd_FiroDetajTest 'FD','#FDSCR','KA',0
             
         SET NOCOUNT ON;


     DECLARE @sTipDok         Varchar(20),
             @sTableScrName   Varchar(50),
             @sDst            Varchar(20),
             @NrRendor        BigInt,
             @sSql            nVarchar(MAX);

         SET @sTipDok       = @pTipDok;
         SET @sDst          = @pDst;
         SET @NrRendor      = @pNrRendor;
         SET @sTableScrName = @pTableScrName;    -- Mund te jete dhe Temporare
         

          IF CHARINDEX('#',@sTableScrName)>0
             SET @NrRendor  = 0;
             

         SET @sSql = '         
                   SELECT MsgError = ''''; ';


     
          IF (CHARINDEX(Upper(','+@sTipDok+','),',FJ,')>0    AND (CHARINDEX(Upper(','+@sDst+','),',FR,')      >0))     
              OR   
             (CHARINDEX(Upper(','+@sTipDok+','),',FD,FH,')>0 AND (CHARINDEX(Upper(','+@sDst+','),',FR,KA,MB,')>0))   
             BEGIN      
               SET @sSql = '
                  DECLARE @sError    VARCHAR(MAX); 
                      SET @sError  = '''';

                   SELECT @sError  = @sError + '','' + A.KARTLLG
                     FROM
                  (
                   SELECT KARTLLG,          
                          LLOGARIFR = CASE WHEN '''+@sTipDok+'''<>''FJ'' AND '''+@sDst+'''=''MB'' AND ISNULL(A.TIPFR,'''')=''H'' AND MAX(ISNULL(R2.NRD,0))=0
                                                                  THEN ''''
                                                                  
                                        -- Aktiviteti tregetar ska firo te asnje klase, por kontabilizohet me ndryshim gjendje ....
                                        -- cdo artikull qe ska te percaktuar firo dhe eshte e tipit ''MB'',(MBeturina - tek FH,FD brendeshme) atehere kontabilizohet me ndryshim gjendje  
                                          
                                          
                                           WHEN ''TIPDOK''=''FJ'' THEN MAX(ISNULL(R2.LLOGARIA,''''))
                          
                                           WHEN A.TIPFR = ''''    THEN ''''
                                           WHEN A.TIPFR = ''B''   THEN MAX(ISNULL(R2.LLOGARIB,''''))
                                           WHEN A.TIPFR = ''C''   THEN MAX(ISNULL(R2.LLOGARIC,''''))
                                           WHEN A.TIPFR = ''D''   THEN MAX(ISNULL(R2.LLOGARID,''''))
                                           WHEN A.TIPFR = ''E''   THEN MAX(ISNULL(R2.LLOGARIE,''''))
                                           WHEN A.TIPFR = ''F''   THEN MAX(ISNULL(R2.LLOGARIF,''''))
                                           WHEN A.TIPFR = ''H''   THEN MAX(ISNULL(R2.LLOGARIH,''''))
                                           WHEN A.TIPFR = ''G''   THEN MAX(ISNULL(R2.LLOGARIG,''''))
                                           WHEN A.TIPFR = ''H''   THEN MAX(ISNULL(R2.LLOGARIH,''''))
                                           WHEN A.TIPFR = ''I''   THEN MAX(ISNULL(R2.LLOGARII,''''))
                                           WHEN A.TIPFR = ''J''   THEN MAX(ISNULL(R2.LLOGARIJ,''''))

                                           ELSE ''''
                                      END     
                                           
                     FROM '+@sTableScrName+' A LEFT JOIN  ARTIKUJ     R1 ON A.KARTLLG=R1.KOD 
                                               LEFT JOIN  ARTIKUJFIR  R2 ON R1.NRRENDOR=R2.NRD 
                                  
                    WHERE A.NRRENDOR>0 AND VLERAFR<>0 AND ISNULL(A.TIPFR,'''')<>''''
                 GROUP BY A.KARTLLG, A.TIPFR
                 
                   ) A LEFT JOIN  LLOGARI  R3 ON A.LLOGARIFR=R3.KOD AND R3.POZIC=1

                    WHERE ISNULL(R3.KOD,'''')=''''   

                 ORDER BY A.KARTLLG; 


                      SET @sError  = SUBSTRING(@sError,2,LEN(@sError));
                      IF  ISNULL(@sError,'''')<>''''
                          SET @sError = ''Kujdes: Gabim skeme LM firo per artikujt: (''+@sError+'')'';            
                   SELECT MsgError = LEFT(@sError,150);    
                 -- PRINT @sError; ';
                 
             END;
             



               SET @sSql = REPLACE(@sSql,'''TIPDOK''',''''+@sTipDok+'''');

             
          IF @NrRendor>0
             BEGIN
               SET @sSql = REPLACE(@sSql,'A.NRRENDOR>0','A.NRD='+CAST(@NrRendor As Varchar))
             END;           

      PRINT  @sSql;
       EXEC (@sSql);
      
GO
