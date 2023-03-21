SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE     PROCEDURE [dbo].[Isd_AQHistoriTestRow]
(
   @pKod            Varchar(60),           -- Test per nje resht AQHistoriScr perpara postimit
   @pKodOper        Varchar(10),           
   @pDateOper       Varchar(20),           
   @pDateDoc        Varchar(20),           -- Nuk ka nevoje
   @pTableDoc       Varchar(50),           -- Nuk ka nevoje
   @pTableScr       Varchar(50),
   @pNrD            BigInt,
   @pNrRendorScr    BigInt
)

AS

BEGIN      
           -- u referua tek Isd_AQDitariTestDoc
           
           -- EXEC dbo.Isd_AQHistoriTestRow 'X01000003','BL','31/12/2016','','','#AQSCR',7,7319;
     

         SET NOCOUNT ON;

     DECLARE @sKod             Varchar(60),
             @sKodOper         Varchar(10),
             @DateOper         DateTime,
             @sTableScr        Varchar(50),
             @sNrRendorScr     Varchar(50),

             @DateDitarFill    Datetime,
             @DateDitarCE      Datetime,
             @DateLastBL       DateTime,
             @DateMinBlok      Datetime,
             @DateFirstAll     Datetime,
             @DateLastHis2     Datetime,

             @DateFirstSH      Datetime,
             @DateLastAM       Datetime,
             @DateBlokCE       Datetime,
             @DateBlokFund     Datetime,
          -- @DateDoc          DateTime,
          -- @sTableDoc        Varchar(50),
          -- @Nrd              BigInt,
          -- @DateLastCe       DateTime,
          -- @DateLastHis      Datetime,
          -- @DateMinDit       Datetime,
          -- @DateMaxDit       Datetime,
          -- @DateMaxDitCr     Datetime,
             @sSql             nVarchar(MAX),
             @Result           Varchar(200),
             @sOper            Varchar(10);

         SET @sKod           = @pKod;
         IF  CHARINDEX('.',@sKod)>0
             SET @sKod       = SUBSTRING(@sKod,1,CHARINDEX('.',@sKod)-1);
             
         SET @sKodOper       = UPPER(RTRIM(LTRIM(ISNULL(@pKodOper,''))));
         SET @DateOper       = dbo.DateValue(@pDateOper);
      -- SET @DateDoc        = dbo.DateValue(@pDateDoc);
      -- SET @sTableDoc      = @pTableDoc;
      -- SET @NrD            = @pNrD;
         SET @sTableScr      = @pTableScr;
         SET @sNrRendorScr   = CAST(CAST(@pNrRendorScr AS BIGINT) AS VARCHAR); 

         SET @Result         = '';



         IF  ISNULL(@sKod,'')='' OR (NOT EXISTS (SELECT KOD FROM AQKARTELA WHERE KOD=@sKod))
             SET @Result     = @sKod+': Kod kartele aktivi i panjohur '
         ELSE
                                                                                                      -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
         IF  CHARINDEX(','+@sKodOper+',',',BL,RK,RV,SR,CE,SH,AM,NP,SI,CR,JP,')=0
             SET @Result     = @sKod+': Kod veprimi me aktivin jo i sakte : '''+@sKodOper+''' '
         ELSE
          
         IF  ISNULL(@DateOper,0)=0
             SET @Result     = @sKod+', veprimi '+@sKodOper+': Date veprimi me aktivin jo e sakte ';
             

/*       IF  @Result=''
             BEGIN
               SELECT @DateMinDit    = MIN(CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END), 
                      @DateMaxDit    = MAX(CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END),
                      @DateMaxDitCr  = MAX(CASE WHEN ISNULL(B.KODOPER,'') IN ('SH','JP','CR')
                                                THEN CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END
                                           END)
                 FROM AQ A INNER JOIN AQScr B ON A.NRRENDOR=B.NRD
                WHERE B.KARTLLG=@sKod

--                   Veprimi 'Ndryshim Perdorues' ose 'Sherbim aktivi' nuk ka pse kufizohen nga veprimi i pare ne ditar

                  IF (ISNULL(@sKodOper,'') IN ('NP','SR')) 
                     BEGIN
                       IF (NOT (@DateMaxDitCr IS NULL)) AND (@DateOper>@DateMaxDitCr) 
                          SET @Result = @sKod+', veprimi '+@sKodOper+': Date veprimi pas dates se perfundimit ne ditar: dt veprimi ' + CONVERT(VARCHAR,@DateOper,     103)+', '+
                                                                                                              'dt perfundimi ditar ' + CONVERT(VARCHAR,@DateMaxDitCr, 103)
                     END                                                                                    
                  ELSE
                  IF (NOT (@DateMinDit IS NULL)) AND (@DateOper>@DateMinDit) 
                     BEGIN
                          SET @Result = @sKod+', veprimi '+@sKodOper+': Date veprimi pas dateve veprimi ne ditar: dt veprimi '       + CONVERT(VARCHAR,@DateOper,     103)+', '+
                                                                                                           'dt fillimi ditar '       + CONVERT(VARCHAR,@DateMinDit,   103)
                     END                                                                                  
             END; */

          IF @Result<>''
             BEGIN
               SELECT Result = @Result+' ..!';
               RETURN;
             END; 
                    
    


-- Tabela #AqHistoriTest ka veprimet ne ditarin historik (AQHistoriScr) te aktivit pa reshtin konkret. 
-- Ditar historik eshte tabela @sTableScr qe po ndertohet me program.

          IF OBJECT_ID('TEMPDB..#AQHistoriTest') IS NOT NULL
             DROP TABLE #AQHistoriTest;
             
      SELECT NRRENDOR=CAST(0 AS BIGINT),KOD,KODAF,KARTLLG,PERSHKRIM,DATEOPER,KODOPER,DATEDOK,TIPROW=CAST(3 AS INT)
        INTO #AQHistoriTest
        FROM AQHistoriScr
       WHERE 1=2;
       

         SET @sSql = '
      INSERT INTO #AQHistoriTest
            (NRRENDOR,KOD,KODAF,KARTLLG,PERSHKRIM,KODOPER,DATEOPER,DATEDOK, TIPROW)
      SELECT NRRENDOR, ISNULL(KOD,''''), ISNULL(KODAF,''''), ISNULL(KARTLLG,''''), ISNULL(PERSHKRIM,''''), 
             ISNULL(KODOPER,''''), ISNULL(DATEOPER,0), ISNULL(DATEOPER,0),0
        FROM '+@sTableScr+' 
       WHERE 1=1 AND NRRENDOR<>'+@sNrRendorScr+'
    ORDER BY NRRENDOR;';
    
          IF @sKod<>''
             SET @sSql = REPLACE(@sSql,'1=1','KARTLLG='+QuoteName(@sKod,''''));

        EXEC (@sSql);

        
        
      INSERT INTO #AQHistoriTest
            (NRRENDOR,KOD,KODAF,KARTLLG,PERSHKRIM,DATEOPER,KODOPER,DATEDOK,TIPROW)
            
      SELECT ISNULL(NRRENDOR,0),ISNULL(KOD,''),ISNULL(KODAF,''),ISNULL(KARTLLG,''),ISNULL(PERSHKRIM,''),ISNULL(DATEOPER,0),ISNULL(KODOPER,''),ISNULL(DATEDOK,0),TIPROW
        FROM dbo.LevizjeAQAll A 
       WHERE KARTLLG=@sKod AND TIPROW=2                                              -- te gjithe reshtat e ditarit AQSCR
    ORDER BY TIPROW,DATEOPER; 
            

                                                                                     -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
         IF  CHARINDEX(','+ISNULL(@sKodOper,'')+',',',BL,CE,SH,CR,JP,')>0            -- Vetem 'RK','RV','SR','AM','SI','NP' lejojne perseritje
             BEGIN
               IF EXISTS ( SELECT * FROM #AQHistoriTest B WHERE KODOPER=@sKodOper )  -- per celjen ndoshta lejohen ne historik disa celje ..? 
                  SET @Result = @sKod+': Kod veprimi '''+@sKodOper+''' perseritura disa here '
             END;


          IF @Result<>''
             BEGIN
               SELECT Result=@Result+' ..!';
               RETURN;
             END;         



                                                                                     -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
      SELECT @DateFirstAll  = MIN(A.DATEOPER),
      
             @DateDitarFill = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('BL','CE','AM') AND TIPROW=2      THEN  A.DATEOPER END),

             @DateDitarCE   = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('CE') AND TIPROW=2                THEN  A.DATEOPER END),
             @DateBlokCE    = MIN(CASE WHEN ISNULL(A.KODOPER,'') IN ('RK','RV','SI','AM') AND TIPROW=2 THEN  A.DATEOPER 
                                       WHEN ISNULL(A.KODOPER,'') IN ('SH','JP','CR')                   THEN  A.DATEOPER END),
          
             @DateBlokFund  = MIN(CASE WHEN ISNULL(A.KODOPER,'') IN ('SH','JP','CR')                   THEN  A.DATEOPER END),

             @DateFirstSH   = MIN(CASE WHEN ISNULL(A.KODOPER,'') IN ('SH')                             THEN  A.DATEOPER END),
             @DateLastAM    = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('AM')                             THEN  A.DATEOPER END),
              
             @DateLastBL    = MAX(CASE WHEN      ISNULL(A.KODOPER,'') IN ('BL')                        THEN  A.DATEOPER END),
             @DateMinBlok   = MIN(CASE WHEN      ISNULL(A.KODOPER,'') IN ('SH','JP','CR')              THEN  A.DATEOPER END),
             @DateLastHis2  = MAX(CASE WHEN NOT (ISNULL(A.KODOPER,'') IN ('SH','JP','CR'))             THEN  A.DATEOPER END)
          -- @DateLastCE    = MAX(CASE WHEN      ISNULL(A.KODOPER,'') IN ('CE')                        THEN  A.DATEOPER END),
          -- @DateDitarBL   = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('BL') AND TIPROW=2                THEN  A.DATEOPER END),    
             
        FROM #AQHistoriTest A; 
        

          IF OBJECT_ID('TEMPDB..#AQDitarTest') IS NOT NULL
             DROP TABLE #AQHistoriTest;


          IF @Result=''
             BEGIN
                                                                           -- Asnje veprim para blerjes

               IF  (NOT (@DateLastBL IS NULL)) AND (@DateOper<@DateLastBL) 
                    SET @Result = 'Date veprimi para date blerje : dt veprimi '                                       + CONVERT(VARCHAR,@DateOper,     103)+
                                                                ', dt blerje '                                        + CONVERT(VARCHAR,@DateLastBL,   103)
               ELSE  
            
                                                                           -- Veprim NP (Ndryshim perdorues, vend) apo Sherbimi nuk kane limit vecse >='BL' dhe <='SH' 
                                                                           -- Nuk quhet gabim qe mund te perdoret para 'CE' ose pas 'JP','CR'
               IF  @sKodOper IN ('NP','SR')                                -- Bile dhe shitja nuk ka pse te jete kufizim (teorikisht)
                   BEGIN
                  -- IF  (NOT (@DateLastBL IS NULL)) AND (@DateOper<@DateLastBL) 
                  --      SET @Result = 'Date veprimi nuk mund te jete para veprimit te blerjes : dt veprim blerje '  + CONVERT(VARCHAR,@DateLastBL,   103)
                  -- ELSE
                     IF  (NOT (@DateFirstSH IS NULL)) AND (@DateOper>@DateFirstSH) 
                          SET @Result = 'Date veprimi nuk mund te jete pas veprimit te shitjes : dt veprimi '         + CONVERT(VARCHAR,@DateOper,     103)+
                                                                                              ', dt shitje '          + CONVERT(VARCHAR,@DateFirstSH,  103)
                   END
               ELSE
                                                                           -- Asnje veprim pas shitje,cregjistrim,jashte perdorim por qe nuk eshte (shitje,cregjistrim,jashte perdorim)
                                                                           -- Perjashtohet 'NP','SR'
                                                                           
               IF  CHARINDEX(','+@sKodOper+',',',SH,JP,CR,')=0 AND (NOT (@DateMinBlok IS NULL)) AND (@DateOper>@DateMinBlok)
                   SET @Result = 'Date veprimi pas dates perfundimit te aktivit : dt veprimi '                        + CONVERT(VARCHAR,@DateOper,      103)+
                                                                               ', dt perfundimi '                     + CONVERT(VARCHAR,@DateMinBlok,   103);
               ELSE
              
                                                                           -- Asnje veprim (pervec ndryshim perdoruesi/sherbim) para amortizimit 
                                                                           -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
               IF  CHARINDEX(','+@sKodOper+',',',BL,CE,RK,RV,SI,AM,')>0 AND (NOT (@DateDitarFill IS NULL)) AND (@DateOper>=@DateDitarFill)
                   SET @Result = 'Date veprimi duhet para dates veprime ne ditar : dt veprimi '                       + CONVERT(VARCHAR,@DateOper,      103)+
                                                                                ', dt ne ditar '                      + CONVERT(VARCHAR,@DateDitarFill, 103)

               ELSE
             
                                                                           -- Veprim blerje duhet me date me perpara se te gjitha veprimet
               IF  @sKodOper='BL' 
                   BEGIN
                     IF  (NOT (@DateFirstAll IS NULL)) AND (@DateOper>@DateFirstAll) 
                          SET @Result = 'Date veprimi nuk mund te jete pas veprimit te pare : dt veprimi '            + CONVERT(VARCHAR,@DateOper,      103)+
                                                                                           ', dt veprimi pare '       + CONVERT(VARCHAR,@DateFirstAll,  103)
                   END
               ELSE
               
                                                                           -- Veprim blerje duhet me date me perpara se te gjitha veprimet
               IF  @sKodOper='CE' 
                   BEGIN
                   --IF  (NOT (@DateLastBL IS NULL)) AND (@DateOper<@DateLastBL) 
                   --     SET @Result = 'Date veprimi nuk mund te jete para blerjes : dt blerje '                     + CONVERT(VARCHAR,@DateLastBL,    103)
                   --ELSE    
                     IF  (NOT (@DateBlokCE IS NULL)) AND (@DateOper<@DateBlokCE) 
                          SET @Result = 'Date veprimi nuk mund te jete para dates : '                                 + CONVERT(VARCHAR,@DateBlokCE,    103)
                        
                     ELSE    
                     IF  (NOT (@DateBlokFund IS NULL)) AND (@DateOper>@DateBlokFund) 
                          SET @Result = 'Date veprimi nuk mund te jete pas dates : '                                  + CONVERT(VARCHAR,@DateBlokFund,  103)
                   END
               ELSE
               
                                                                           -- Veprim amortizim duhet me date me pas se BL,CE,NN,RV,AM fundit
               IF  @sKodOper='AM' 
                   BEGIN
                     IF  (NOT (@DateDitarCE IS NULL))    AND (@DateOper>=@DateDitarCE)   
                          SET  @Result = 'Date veprimi para veprimit te celjes ne ditar: dt celje ditar '             + CONVERT(VARCHAR,@DateDitarCE,   103)
                     ELSE 
                     IF  (NOT (@DateBlokFund IS NULL)) AND (@DateOper>@DateBlokFund) 
                          SET  @Result = 'Date veprimi pas date perfundim asetit : dt perfundim aseti '               + CONVERT(VARCHAR,@DateBlokFund,  103)
                     ELSE 
                     IF  (NOT (@DateLastAM IS NULL))    AND (@DateOper<@DateLastAM)   
                          SET  @Result = 'Date veprimi para AM fundit: dt AM fundit '                                 + CONVERT(VARCHAR,@DateLastAM,    103)
                   END      
               ELSE
                                                                           -- Veprim shitje,jashte perdorimit,cregjistrim duhen me date pas te gjitha veprimeve
                                                                          
               IF  CHARINDEX(','+@sKodOper+',',',SH,JP,CR,')>0 AND (NOT (@DateLastHis2 IS NULL)) AND (@DateOper<@DateLastHis2) 
                   SET @Result = 'Veprimet SH,JP,CR duhet te jene veprimet e fundit, por rezulton dt veprim fundit '  + CONVERT(VARCHAR,@DateLastHis2,  103)
--             ELSE
               
                                                                            -- Asnje veprim para blerjes
--             IF  (NOT (@DateLastBL IS NULL)) AND (@DateOper<@DateLastBL) 
--                  SET @Result = 'Date veprimi para date blerje : dt veprimi '                                       + CONVERT(VARCHAR,@DateOper,      103)+
--                                                              ', dt blerje '                                        + CONVERT(VARCHAR,@DateLastBL,    103)
--             ELSE  

                                                                            -- Asnje veprim para celjes ..?    -- Celje kujdes: Mos duhet lejuar disa celje ne Ditar historik ....!
                                                                            -- Ndoshta Blerja para Celjes ne se ka dhe blerje dhe celje.
                                                                            -- Kujdes: Asnje veprim para Celjes ne AQSCR
              
--             IF  @sKodOper<>'BL' AND (NOT (@DateLastCe IS NULL)) AND (@DateOper<@DateLastCe) 
--                 SET @Result = 'Date veprimi para date Celje : dt veprimi '                                         + CONVERT(VARCHAR,@DateOper,      103)+
--                                                            ', dt celje '                                           + CONVERT(VARCHAR,@DateLastCe,    103)
--             ELSE


                                                                            -- Asnje veprim (pervec ndryshim perdoruesi) para amortizimit 

--             IF  @sKodOper<>'NP' AND (NOT (@DateLastAM IS NULL)) AND (@DateOper<=@DateLastAM)
--                 SET @Result = ' Date veprimi para date amrtizimi te fundit : dt amortizimi '                       + CONVERT(VARCHAR,@DateLastAM,    103)
              

               --  Veprimet [cregjistrim,jashte perdorim, shitje] duhet te jene ne fund te veprimeve por ne cfaredo radhe ...


            -- IF @Result<>''
            --   SET @Result = REPLACE(@Result,' : ',' : dt veprimi '+CONVERT(VARCHAR,@DateOper, 103)+', ');

             END;  
         


          IF ISNULL(@Result,'')<>''
             SET @Result = @sKod+', veprimi '+@sKodOper+':     '+@Result+' ..!';

      SELECT RESULT=@Result;
       

END
GO
