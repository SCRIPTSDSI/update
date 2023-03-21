SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE     PROCEDURE [dbo].[Isd_AQDitarTestRow]
(
   @pKod            Varchar(60),           -- Test per nje resht AQSCR perpara postimit
   @pKodOper        Varchar(10),           
   @pDateOper       Varchar(20),           -- Shiko dhe StoreProcedure Isd_AQStatistics
   @pDateDoc        Varchar(20),  
   @pTableDoc       Varchar(50),
   @pTableScr       Varchar(50),
   @pNrD            BigInt,
   @pNrRendorScr    BigInt
)

AS

BEGIN     -- Kjo procedure zevendesoi funksionin Isd_AQtestDateOper
          -- u referua tek Isd_AQHistoriTestDoc
           
          -- EXEC dbo.Isd_AQDitarTestRow 'X01000003','BL','31/12/2019','31/12/2019','#AQSCR',7,7319;
     

         SET NOCOUNT ON;

     DECLARE @sKod             Varchar(60),
             @sKodOper         Varchar(10),
             @DateOper         DateTime,
             @DateDoc          DateTime,
             @sTableDoc        Varchar(50),
             @sTableScr        Varchar(50),
             @Nrd              BigInt,
             @sNrRendorScr     Varchar(50),

             @DateLastBl       DateTime,
             @DateDitarBL      Datetime,
             @DateDitarCE      Datetime,
             @DateBlokCE       Datetime,
             @DateBlokFill     DateTime,
             @DateLastAm       DateTime,
             @DateFirstSh      DateTime,
             @DateBlokFund     Datetime,
             @DateBlokAM       Datetime,
             @DateFirstAll     Datetime,
             @DateLastAll2     Datetime,
             @sSql             nVarchar(MAX),
             @Result           Varchar(200),
             @sOper            Varchar(10);

         SET @sKod           = @pKod;
         IF  CHARINDEX('.',@sKod)>0
             SET @sKod       = SUBSTRING(@sKod,1,CHARINDEX('.',@sKod)-1);
             
         SET @sKodOper       = UPPER(RTRIM(LTRIM(ISNULL(@pKodOper,''))));
         SET @DateOper       = dbo.DateValue(@pDateOper);
         SET @DateDoc        = dbo.DateValue(@pDateDoc);
         SET @sTableDoc      = @pTableDoc;
         SET @sTableScr      = @pTableScr;
         SET @NrD            = @pNrD;
         SET @sNrRendorScr   = CAST(CAST(@pNrRendorScr AS BIGINT) AS VARCHAR); 

         SET @Result         = '';



         IF  @sTableDoc='FJ'
             SET @sKodOper   = 'SH'
         ELSE
         IF  @sTableDoc='FF'
             BEGIN                                                                                    -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
          -- duhet rregulluar sepse nga FF do vijne tre tipe: 'BL','RK','SR' ('SR' sherbim por qe vlefta nuk hyn ne ate te aktivit)
               IF EXISTS (SELECT KOD FROM LevizjeAQAll WHERE KARTLLG=@sKod AND (KODOPER='BL' OR KODOPER='CE')) 
                  SET @sKodOper = 'RK' 
               ELSE                                                                                                   
                  SET @sKodOper = 'BL';
             END;
             
             
         IF  ISNULL(@sKod,'')='' OR (NOT EXISTS (SELECT KOD FROM AQKARTELA WHERE KOD=@sKod))
             SET @Result     = @sKod+': Kod kartele aktivi i panjohur '
         ELSE
          
         IF  CHARINDEX(','+@sKodOper+',',',BL,RK,RV,SR,CE,SH,AM,NP,SI,CR,JP,')=0                      -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
             SET @Result     = @sKod+': Kod veprimi me aktivin jo i sakte '''+@sKodOper+''' '
         ELSE
          
         IF  ISNULL(@DateOper,0)=0
             SET @Result     = @sKod+': Date veprimi me aktivin jo e sakte ';

          IF @Result<>''
             BEGIN
               SELECT Result = @Result+' ..!';
               RETURN;
             END; 
                     
      

-- Tabela #AqDitarTest ka ditarin e aktivit referuar LevizjeAQAll pa dokumentin konkret qe po ndertohet ose modifikohet. 
-- Ditar historik dhe AqScr por PA DOKUMENTIN KONKRET QE PO NDERTOHET dhe ne vend te tij eshte tabele @sTableScr qe po ndertohet me program.

          IF OBJECT_ID('TEMPDB..#AQDitarTest') IS NOT NULL
             DROP TABLE #AQDitarTest;
             
      SELECT NRRENDOR=CAST(0 AS BIGINT),KOD,KODAF,KARTLLG,PERSHKRIM,DATEOPER,KODOPER,DATEDOK,TIPROW=CAST(3 AS INT)
        INTO #AQDitarTest
        FROM AQHistoriScr
       WHERE 1=2;
       

         SET @sSql = '
      INSERT INTO #AQDitarTest
            (NRRENDOR,KOD,KODAF,KARTLLG,PERSHKRIM,KODOPER,DATEOPER,DATEDOK, TIPROW)
      SELECT NRRENDOR,KOD,KODAF,KARTLLG,PERSHKRIM,KODOPER,DATEOPER,DATEOPER,0
        FROM '+@sTableScr+' 
       WHERE 1=1 AND KARTLLG='''+@sKod+''' AND NRRENDOR<>'+@sNrRendorScr+'
    ORDER BY NRRENDOR;';
    


          IF CHARINDEX('FF',@sTableScr)>0 OR CHARINDEX('FJ',@sTableScr)>0
             BEGIN                                                                                    -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
               SET @sOper = CASE WHEN CHARINDEX('FJ',@sTableScr)>0                                                                 THEN 'SH'     
                                 WHEN EXISTS (SELECT KOD FROM LevizjeAQAll WHERE KARTLLG=@sKod AND (KODOPER='BL' OR KODOPER='CE')) THEN 'RK' -- kujdes edhe tipin 'SR'
                                 ELSE                                                                                                   'BL'
                            END;
                                
               SET @sSql = '
                 INSERT INTO #AQDitarTest
                       (NRRENDOR,KOD,KODAF,KARTLLG,PERSHKRIM,KODOPER,DATEOPER,DATEDOK, TIPROW)
                 SELECT NRRENDOR,KOD,KODAF,KARTLLG,PERSHKRIM,
                        KODOPER  = '''+@sOper+''',
                        DATEOPER = '+CONVERT(VARCHAR,@DateDoc,103)+',
                        DATEODOK = '+CONVERT(VARCHAR,@DateDoc,103)+',0
                   FROM '+@sTableScr+' 
                  WHERE 1=1 AND KARTLLG='''+@sKod+''' AND TIPKLL=''X'' AND NRRENDOR<>'+@sNrRendorScr+'
               ORDER BY NRRENDOR;';
             END;
              
        EXEC (@sSql);

    

      INSERT INTO #AQDitarTest
            (NRRENDOR,KOD,KODAF,KARTLLG,PERSHKRIM,DATEOPER,KODOPER,DATEDOK,TIPROW)
            
      SELECT NRRENDOR,KOD,KODAF,KARTLLG,PERSHKRIM,DATEOPER,KODOPER,DATEDOK,TIPROW
        FROM dbo.LevizjeAQAll A 
       WHERE KARTLLG=@sKod AND (NOT (A.NRD=@pNrD AND TIPROW=2))                            -- perjashtohet dokumenti qe po modifikohet (A.NRD=@pNrD AND TIPROW=2)
    ORDER BY TIPROW,DATEOPER; 
    
    

         IF  @Result='' AND CHARINDEX(','+ISNULL(@sKodOper,'')+',',',BL,CE,SH,CR,JP,')>0   -- Vetem 'RK','RV','SR','AM','SI','NP' lejojne perseritje
             BEGIN
               IF EXISTS ( SELECT * FROM #AQDitarTest B WHERE KODOPER=@sKodOper )          -- per celjen ndoshta lejohen ne historik disa celje ..? 
                  SET @Result = @sKod+': Kod Veprimi '''+@sKodOper+''' perseritura disa here. (Shiko ditar/te dhena historike) '
             END;


          IF @Result<>''
             BEGIN
               SELECT Result=@Result+' ..!';
               RETURN;
             END;         


                                                                                                      -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
      SELECT 
          -- @DateLastCE    = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('CE')                             THEN  A.DATEOPER END),
             @DateLastBL    = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('BL')                             THEN  A.DATEOPER END),    
             
             @DateDitarBL   = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('BL') AND TIPROW=2                THEN  A.DATEOPER END),    
             @DateDitarCE   = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('CE') AND TIPROW=2                THEN  A.DATEOPER END),    
             @DateBlokCE    = MIN(CASE WHEN ISNULL(A.KODOPER,'') IN ('RK','RV','SI','AM') AND TIPROW=2 THEN  A.DATEOPER 
                                       WHEN ISNULL(A.KODOPER,'') IN ('SH','JP','CR')                   THEN  A.DATEOPER END),

             @DateBlokFill  = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('BL','CE','AM')                   THEN  A.DATEOPER END),
             @DateBlokFund  = MIN(CASE WHEN ISNULL(A.KODOPER,'') IN ('SH','JP','CR')                   THEN  A.DATEOPER END),
             @DateBlokAM    = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('BL','CE','RK','RV','SI')         THEN  A.DATEOPER END),
             
             @DateFirstSh   = MIN(CASE WHEN ISNULL(A.KODOPER,'') IN ('SH')                             THEN  A.DATEOPER END),
             @DateLastAM    = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('AM')                             THEN  A.DATEOPER END),
          -- @DateLastCeDit = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('CE') AND TIPROW=2                THEN  A.DATEOPER END),
          -- @DateMaxHis    = MAX(CASE WHEN TIPROW=1                                                   THEN  A.DATEOPER END),
             @DateFirstAll  = MIN(A.DATEOPER),
             @DateLastAll2  = MAX(CASE WHEN NOT (ISNULL(A.KODOPER,'') IN ('SH','JP','CR'))             THEN  A.DATEOPER END)
             
        FROM #AQDitarTest A; 

          IF OBJECT_ID('TEMPDB..#AQDitarTest') IS NOT NULL
             DROP TABLE #AQDitarTest;


         IF @Result=''
            BEGIN
                                                                           -- Asnje veprim para blerjes
            
              IF  (NOT (@DateLastBl IS NULL)) AND (@DateOper<@DateLastBl) 
                  SET @Result = 'Date veprimi perpara date blerje : dt blerje '                                      + CONVERT(VARCHAR,@DateLastBl,   103)
              ELSE  
            
                                                                          -- Veprim NP (Ndryshim perdorues, vend) apo Sherbimi nuk kane limit vecse >='BL' dhe <='SH' 
                                                                          -- Nuk quhet gabim qe mund te perdoret para 'CE' ose pas 'JP','CR'
              IF  @sKodOper IN ('NP','SR')                                -- Bile dhe shitja nuk ka pse te jete kufizim (teorikisht)
                  BEGIN
                  --IF  (NOT (@DateLastBL IS NULL)) AND (@DateOper<@DateLastBL) 
                  --     SET @Result = 'Date veprimi nuk mund te jete para veprimit te blerjes : dt veprim blerje '  + CONVERT(VARCHAR,@DateLastBL,   103)
                  --ELSE
                    IF  (NOT (@DateFirstSH IS NULL)) AND (@DateOper>@DateFirstSH) 
                         SET @Result = 'Date veprimi nuk mund te jete pas veprimit te shitjes : dt veprim shitje '   + CONVERT(VARCHAR,@DateFirstSH,  103)
                  END
              ELSE
                                                                           -- Asnje veprim (pervec ndryshim perdoruesi/sherbim) para amortizimit 
                                                                           -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
              IF  CHARINDEX(','+@sKodOper+',',',BL,CE,RK,RV,SI,AM,')>0 AND (NOT (@DateLastAm IS NULL)) AND (@DateOper<=@DateLastAm)
                  SET @Result = 'Date veprimi para date amortizimi te fundit : dt amortizimi '                       + CONVERT(VARCHAR,@DateLastAm,   103)
              ELSE

              IF  CHARINDEX(','+@sKodOper+',',',SH,JP,CR,')>0 AND (NOT (@DateLastAm IS NULL)) AND (@DateOper<@DateLastAm)
                  SET @Result = 'Date veprimi para date amortizimi te fundit : dt amortizimi '                       + CONVERT(VARCHAR,@DateLastAm,   103)
              ELSE

                                                                          -- Veprim blerje duhet me date me perpara se te gjitha veprimet
              IF  @sKodOper='BL'                                          -- Nuk lejohet BL ne ditar kur ka CE ne ditar
                  BEGIN
                    IF  (NOT (@DateDitarCE IS NULL)) 
                         SET @Result = 'Nuk lejohet ne ditar veprim blerje pas veprimit celje : dt celje ditar '     + CONVERT(VARCHAR,@DateDitarCE,  103)
                    ELSE    
                    IF  (NOT (@DateFirstALL IS NULL)) AND (@DateOper>@DateFirstAll) 
                         SET @Result = 'Date veprimi nuk mund te jete pas veprimit te pare : dt veprim pare '        + CONVERT(VARCHAR,@DateFirstAll, 103)
                  END
              ELSE

                                                                          -- Veprim blerje duhet me date me perpara se te gjitha veprimet
              IF  @sKodOper='CE' 
                  BEGIN
                    IF  (NOT (@DateDitarBL IS NULL)) 
                         SET @Result = 'Nuk lejohet ne ditar veprim celje pas veprimit blerje : dt blerje ditar '    + CONVERT(VARCHAR,@DateDitarBL,  103)
                    ELSE    
                    IF  (NOT (@DateLastBL IS NULL)) AND (@DateOper>@DateLastBL) 
                         SET @Result = 'Date veprimi nuk mund te jete pas veprimit te pare : dt veprim pare '        + CONVERT(VARCHAR,@DateLastBL,   103)
                    ELSE    
                    IF  (NOT (@DateBlokCE IS NULL)) AND (@DateOper<@DateBlokCE) 
                         SET @Result = 'Date veprimi nuk mund te jete para dates : '                                 + CONVERT(VARCHAR,@DateBlokCE,   103)
                    ELSE    
                    IF  (NOT (@DateBlokFund IS NULL)) AND (@DateOper>@DateBlokFund) 
                         SET @Result = 'Date veprimi nuk mund te jete pas dates : '                                  + CONVERT(VARCHAR,@DateBlokFund, 103)
                        
                  END
              ELSE

                                                                          -- Veprim amortizim duhet me date me pas se BL,CE,NN,RV,AM fundit
              IF  @sKodOper='AM'                                          -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
                  BEGIN
                    IF  (NOT (@DateBlokFund IS NULL)) AND (@DateOper>@DateBlokFund) 
                         SET  @Result = 'Date veprimi pas date perfundim asetit : dt perfundim aseti '               + CONVERT(VARCHAR,@DateBlokFund, 103)
                    ELSE 
                    IF  (NOT (@DateBlokAM IS NULL))    AND (@DateOper<@DateBlokAM)   
                         SET  @Result = 'Date veprimi para veprimit te fundit me BL,CE,RK,RV,SI: dt veprim fundit '  + CONVERT(VARCHAR,@DateBlokAM,   103)
                    ELSE 
                    IF  (NOT (@DateLastAM IS NULL))    AND (@DateOper<@DateLastAM)   
                         SET  @Result = 'Date veprimi para AM fundit: dt AM fundit '                                 + CONVERT(VARCHAR,@DateLastAM,   103)
                  END      
              ELSE
               
                                                                          -- Veprim shitje,jashte perdorimit,cregjistrim duhen me date pas te gjitha veprimeve
              IF  CHARINDEX(','+@sKodOper+',',',SH,JP,CR,')>0 
                  BEGIN
                    IF  (NOT (@DateLastAll2 IS NULL)) AND (@DateOper<@DateLastAll2) 
                         SET @Result = 'Date veprimi nuk mund te jete para veprimit te fundit : dt veprim fundit '   + CONVERT(VARCHAR,@DateLastAll2, 103)
                  END      
              ELSE

                                                                           -- Veprimi RK,RV,SI duhet pas dates se BL,CE,AM fundit
              IF  CHARINDEX(','+@sKodOper+',',',RK,RV,SI,')>0              -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020 
                  BEGIN
                    IF  (NOT (@DateBlokFill IS NULL)) AND (@DateOper<@DateBlokFill)
                         SET @Result = 'Date veprimi para dates veprimit CE,BL,AM fundit: dt CE,BL,AM fundit '       + CONVERT(VARCHAR,@DateBlokFill, 103)
                    ELSE
                    IF  (NOT (@DateBlokFund IS NULL)) AND (@DateOper>@DateBlokFund)
                         SET @Result = 'Date veprimi pas dates perfundim aseti : dt perfundim aseti '                + CONVERT(VARCHAR,@DateBlokFund, 103)
                  END
              ELSE    

                                                                           -- Asnje veprim para blerjes
                                                                           
              IF  (NOT (@DateLastBl IS NULL)) AND (@DateOper<@DateLastBl) 
                  SET @Result = 'Date veprimi para date blerje : dt blerje '                                         + CONVERT(VARCHAR,@DateLastBl,   103)
              ELSE 
              

              IF @Result<>''
                 SET @Result = REPLACE(@Result,' : ',' : dt veprimi '+CONVERT(VARCHAR,@DateOper, 103)+', ');
               


/*                                                                         -- Asnje veprim para celjes ..?    -- Celje kujdes: Mos duhet lejuar disa celje ne Ditar historik ....!
                                                                           -- Kujdes: Asnje veprim para Celjes ne AQSCR
              
--            IF  @sKodOper<>'CE' AND (NOT (@DateLastCe IS NULL)) AND (@DateOper<@DateLastCe) 
--                SET @Result = ' Date veprimi para date Celje : dt Celje '                        + CONVERT(VARCHAR,@DateLastCe,  103)
--            ELSE

                                                                           -- Kujdes: Asnje veprim para Celjes ne AQSCR (pavaresisht celjeve ne hitorikut)

              IF  @sKodOper<>'CE' AND (NOT (@DateLastCeDit IS NULL)) AND (@DateOper<@DateLastCeDit) 
                  SET @Result = 'Date veprimi para date Celje ne ditar : dt Celje '               + CONVERT(VARCHAR,@DateLastCeDit,  103)
              ELSE

                                                                           -- Asnje veprim pas shitje,cregjistrim,jashte perdorim por qe nuk eshte (shitje,cregjistrim,jashte perdorim)

              IF  CHARINDEX(','+@sKodOper+',',',SH,JP,CR,')=0 AND (NOT (@DateBlokFund IS NULL)) AND (@DateOper>@DateBlokFund)
                  SET @Result = 'Date veprimi pas dates perfundimit te aktivit : dt perfundimi '  + CONVERT(VARCHAR,@DateBlokFund,  103)
              ELSE
              
                                                                           -- Asnje veprim (pervec ndryshim perdoruesi/sherbim) para amortizimit 
                                                                           -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
              IF  CHARINDEX(','+@sKodOper+',',',BL,CE,RK,RV,')>0 AND (NOT (@DateLastAm IS NULL)) AND (@DateOper<=@DateLastAm)
                  SET @Result = 'Date veprimi para date amortizimi te fundit : dt amortizimi '     + CONVERT(VARCHAR,@DateLastAm,  103)
              ELSE
              IF  CHARINDEX(','+@sKodOper+',',',SH,JP,CR,')>0    AND (NOT (@DateLastAm IS NULL)) AND (@DateOper<@DateLastAm)
                  SET @Result = 'Date veprimi para date amortizimi te fundit : dt amortizimi '     + CONVERT(VARCHAR,@DateLastAm,  103)
              ELSE


           -- Veprimet [cregjistrim,jashte perdorim, shitje] duhet te jene ne fund te veprimeve por ne cfaredo radhe ...

              IF @Result<>''
                 SET @Result = REPLACE(@Result,' : ',' : dt veprimi '+CONVERT(VARCHAR,@DateOper, 103)+', '); */

            END;  
         


          IF ISNULL(@Result,'')<>''
             SET @Result = @sKod+':     '+@Result+' ..!';

      SELECT RESULT=@Result;
       

END
GO
