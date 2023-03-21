SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE          procedure [dbo].[Isd_FiroDetajUpdate]
(
  @pTipDok         Varchar(10),
  @pTableScrName   Varchar(50),
  @pDst            Varchar(20),
  @pNrRendor       BigInt
)
AS
-- Exec Isd_FiroDetajUpdate 'FJ','FJSCR', '',  1
-- Exec Isd_FiroDetajUpdate 'FD','#FDSCR','KA',0
          
/*

D	FR	Firo Malli			D20 +
D	KM	Kthim malli			D21
D	DM	Demtime - Kthime	D22
D	KA	Kthim amballazhi	D23 +
D	MB	Mbeturina			D24 +
D	LA	Larje produkt		D25 +
D	RP	Dalje Riprodhim		D26 +
D	RK	Riprodhim Paketimi	D27 +


H	FR	Firo malli			H20 +
H	KM	Kthim Malli			H21
H	DM	Demtime - Kthime	H22
H	KA	Kthim amballazhi	H23 +
H	MB	Mbeturina			H24 +
H	LA	Larje produkti		H25 +

*/
             
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
             UPDATE '+@sTableScrName+' 
                SET TIPFR   = CASE WHEN ISNULL(TIPFR,'''') <> ''TIPFR''        THEN ''TIPFR''        ELSE TIPFR              END,
                    SASIFR  = CASE WHEN ISNULL(SASIFR,0)   <> ISNULL(SASI,0)   THEN ISNULL(SASI,0)   ELSE ISNULL(SASIFR,0)   END,
                    VLERAFR = CASE WHEN ISNULL(VLERAFR,0)  <> ISNULL(VLERAM,0) THEN ISNULL(VLERAM,0) ELSE ISNULL(VLERAFR,0)  END 
              WHERE NRRENDOR>0;';




         --  Aktiviteti tregetar ska firo te asnje klase, por kontabilizohet me ndryshim gjendje ....
         --  cdo artikull qe ska te percaktuar firo dhe eshte e tipit ''MB'',(MBeturina - tek FH,FD brendeshme) atehere kontabilizohet me ndryshim gjendje  

         IF  @sDst='MB'                                     
             SET @sSql = @sSql+'
             
             UPDATE A  
                SET TIPFR   = ''''
               FROM '+@sTableScrName+' A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD
              WHERE A.NRRENDOR>0 AND (ISNULL(A.TIPFR,'''')=''H'' OR ISNULL(A.SASIFR,0)<>0 OR ISNULL(A.VLERAFR,0)<>0) 
                    AND 
                   (NOT EXISTS (SELECT NRRENDOR FROM ARTIKUJFIR FR WHERE B.NRRENDOR=FR.NRD))';

-- FJ

          IF @sTipDok='FJ' 
             BEGIN

               IF @sDst='FR'
                  BEGIN
                    SET @sSql = REPLACE(REPLACE(@sSql,'''TIPFR''','''A'''),'VLERAM','VLERABS')
                  END
               ELSE  
               
                  BEGIN     -- @sDst<>'FR'
                    SET @sSql = '
                        UPDATE '+@sTableScrName+' 
                           SET TIPFR   = '''',
                               SASIFR  = 0,
                               VLERAFR = 0 
                         WHERE NRRENDOR>0 AND (ISNULL(TIPFR,'''')<>'''' OR ISNULL(SASIFR,0)<>0 OR ISNULL(VLERAFR,0)<>0); ';
                  END
                  
               GOTO UpdateDetajFiro;
             
             END;   



          IF CHARINDEX(Upper(','+@sTipDok+','),',FD,FH,')=0
             RETURN;


-- FH ose FD

          IF @sDst='LA'
             BEGIN
               SET @sSql = REPLACE(@sSql,'''TIPFR''','''I''')
             END
          ELSE  
           
          IF @sDst='MB'
             BEGIN
               SET @sSql = REPLACE(@sSql,'''TIPFR''','''H''')
             END  
          ELSE
          
--        IF @sDst='KA' AND @sTipDok='FD'
--           BEGIN
--             SET @sSql = REPLACE(@sSql,'''TIPFR''','''G''')
--           END  
--        ELSE
          
          IF @sDst='RP' OR @sDst='RK' OR @sDst='KA'
             BEGIN
             --SET @sSql = REPLACE(@sSql,'''TIPFR''','''''')   -- Korigjuar me 16.04.2018
               SET @sSql = '
                   UPDATE '+@sTableScrName+' SET TIPFR='''', SASIFR=0, VLERAFR=0 WHERE NRRENDOR>0;';               
             END
          ELSE
          
          IF (@sDst='FR') OR (@sDst='FIR')
             BEGIN
               SET @sSql = '
                          
                   UPDATE '+@sTableScrName+' 
                      SET TIPFR   = CASE WHEN CHARINDEX(ISNULL(TIPFR,''''),''ABCDEFG'')=0 THEN ''B''            ELSE ISNULL(TIPFR,'''') END,
                          SASIFR  = CASE WHEN ISNULL(SASIFR,0)   <> ISNULL(SASI,0)        THEN ISNULL(SASI,0)   ELSE ISNULL(SASIFR,0)   END,
                          VLERAFR = CASE WHEN ISNULL(VLERAFR,0)  <> ISNULL(VLERAM,0)      THEN ISNULL(VLERAM,0) ELSE ISNULL(VLERAFR,0)  END 
                    WHERE NRRENDOR>0; ';
             END
          ELSE
          
             BEGIN
               SET @sSql = '
                   UPDATE '+@sTableScrName+' 
                      SET TIPFR   = '''',
                          SASIFR  = 0,
                          VLERAFR = 0 
                    WHERE NRRENDOR>0 AND (ISNULL(TIPFR,'''')<>'''' OR ISNULL(SASIFR,0)<>0 OR ISNULL(VLERAFR,0)<>0); ';
             END;
             
             
             
          SET @sSql = @sSql+'
          
                   UPDATE '+@sTableScrName+'
                      SET TIPFR   = '''',
                          SASIFR  = 0,
                          VLERAFR = 0
                    WHERE NRRENDOR>0 AND ISNULL(ISNOTFIRO,0)=1 AND (ISNULL(SASIFR,0)<>0 OR ISNULL(TIPFR,'''')<>'''' OR ISNULL(VLERAFR,0)<>0); ';
             
             
             
             
             
  UpdateDetajFiro:                         

             
          IF @NrRendor>0
             BEGIN
               SET @sSql = REPLACE(@sSql,'NRRENDOR>0','NRD='+CAST(@NrRendor As Varchar))
             END;           
             
--    PRINT  @sDst
--    PRINT  @sSql;
      
       EXEC (@sSql);
      
GO
