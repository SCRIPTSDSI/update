SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE     FUNCTION [dbo].[Isd_AQTestDateOper]
(
 @pKod            Varchar(60),           -- Test per nje resht AQSCR perpara postimit
 @pDateDoc        Varchar(20),
 @pOper           Varchar(10),           -- Shiko dhe StoreProcedure Isd_AQStatistics
 @pVleraDoc       Float,
 @pVleraAMDoc     Float,
 @pTestOper       Varchar(50)            -- ',BL,SH,'  ??
)

RETURNS           Varchar(150) 

AS

BEGIN


-- Ku perdoret ..!!!!!
-- Ne se duhet te futet edhe rasti per KODOPER='SR' sherbimet vlera e te cilave buk futet ne aset.
-- shiko funksionet,view,procedurat e tjera per kete pune.


     -- SELECT MsgError = dbo.Isd_AQTestDateOper('X01000003','31/12/2019','BL',0,0,'')
     
     DECLARE @DtMin           DateTime     -- ????
         SET @DtMin         = GetDate();



     DECLARE @sKod            Varchar(60),
             @sOper           Varchar(10),
             @sTestOper       Varchar(50),
             @VleraDoc        Float,
             @VleraAMDoc      Float,
          -- @VleraDocMv      Float,
          -- @VleraAMDocMv    Float,
             @DateDoc         DateTime,
             @Result          Varchar(200),
          -- @DateFirstCE     DateTime,
             @DateLastCE      DateTime,
             @DateFirstBL     DateTime,
             @DateLastBL      DateTime,
             @DateFirstPR     DateTime,
             @DateFirstSH     DateTime,
             @DateLastSH      DateTime,
             @DateFirstAM     DateTime,
             @DateLastAM      DateTime,
             @DateFirstCr     Datetime,
             @DateLastCr      Datetime,
             @Vlera           Float,
             @VleraMv         Float,
             @VleraAM         Float,
             @VleraAMMv       Float,
             @Gjendje         Float,
             @GjendjeMv       Float;

         SET @sKod          = @pKod;
         IF  CHARINDEX('.',@sKod)>0
             SET @sKod      = SUBSTRING(@sKod,1,CHARINDEX('.',@sKod)-1);
             
         SET @sOper         = UPPER(RTRIM(LTRIM(ISNULL(@pOper,''))));
      -- SET @sTestOper     = UPPER(LTRIM(RTRIM(ISNULL(@sTestOper,''))));
         SET @DateDoc       = dbo.DateValue(@pDateDoc);
         SET @VleraDoc      = ISNULL(@pVleraDoc,0);
         SET @VleraAMDoc    = ISNULL(@pVleraAMDoc,0);
         SET @Result        = '';


          IF ISNULL(@sKod,'')='' OR (NOT EXISTS (SELECT KOD FROM AQKARTELA WHERE KOD=@sKod))
             BEGIN
               SET @Result = 'Kujdes,  kartele aktivi i panjohur : '''+@sKod+'''   !';
	           RETURN (@Result);
	         END;  

          IF @sOper=''
             BEGIN
               SET @Result = 'Kujdes, tipi i veprimit per aktivin i pa njohur : '''+@sOper+'''   !';
	           RETURN (@Result);
	         END;  

       -- IF SUBSTRING(@sTestOper,1,1)<>','
       --    BEGIN
       --      SET @sTestOper = ','+@sTestOper;
       --    END;  
       -- IF SUBSTRING(@sTestOper,LEN(@sTestOper),1)<>','
       --    BEGIN
       --      SET @sTestOper = @sTestOper+',';
       --    END;  

         
                                                                            -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020

      SELECT 
          -- @DateFirstCE   = MIN(CASE WHEN ISNULL(A.KODOPER,'') IN ('CE')                 THEN  A.DATEOPER END),
             @DateLastCE    = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('CE')                 THEN  A.DATEOPER END),
             
             @DateFirstBL   = MIN(CASE WHEN ISNULL(A.KODOPER,'') IN ('BL','RK','RV')       THEN  A.DATEOPER END),
             @DateLastBL    = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('BL','RK','RV')       THEN  A.DATEOPER END),
             @DateFirstPR   = MIN(CASE WHEN ISNULL(A.KODOPER,'') IN ('BL','RK','RV','PR')  THEN  A.DATEOPER END),
             
             @DateFirstSH   = MIN(CASE WHEN ISNULL(A.KODOPER,'') IN ('SH','JP')            THEN  A.DATEOPER END),
             @DateLastSH    = MIN(CASE WHEN ISNULL(A.KODOPER,'') IN ('SH','JP')            THEN  A.DATEOPER END),
             @DateFirstAM   = MIN(CASE WHEN ISNULL(A.KODOPER,'')='AM'                      THEN  A.DATEOPER END),
             @DateLastAM    = MAX(CASE WHEN ISNULL(A.KODOPER,'')='AM'                      THEN  A.DATEOPER END),
             
             @DateFirstCr   = MIN(CASE WHEN ISNULL(A.KODOPER,'') IN ('CR','JP')            THEN  A.DATEOPER END),
             @DateLastCr    = MAX(CASE WHEN ISNULL(A.KODOPER,'') IN ('CR','JP')            THEN  A.DATEOPER END),
             
             @Vlera         = SUM(CASE WHEN A.KODOPER IN ('CE','BL','RK','RV,''SI','ST')   THEN  1
                                       WHEN A.KODOPER IN ('SH','JP')                       THEN -1
                                       ELSE                                                      0
                                  END * A.VLERABS),
             @VleraMv       = SUM(CASE WHEN A.KODOPER IN ('CE','BL','RK','RV','SI','ST')   THEN  1
                                       WHEN A.KODOPER IN ('SH','JP')                       THEN -1
                                       ELSE                                                      0
                                  END * A.VLERABS * ISNULL(A.KURS2,1) / ISNULL(A.KURS1,1)),
             @VleraAM       = SUM(CASE WHEN A.KODOPER IN ('CE','AM','SI','ST')             THEN  1 ELSE 0 END * A.VLERAAM),
             @VleraAMMv     = SUM(CASE WHEN A.KODOPER IN ('CE','AM','SI','ST')             THEN  1 ELSE 0 END * A.VLERAAM * ISNULL(A.KURS2,1) / ISNULL(A.KURS1,1)),
             @Gjendje       = SUM(CASE WHEN A.KODOPER IN ('CE','BL','RK','RV','SI','ST')   THEN  1
                                       WHEN A.KODOPER IN ('SH','JP')                       THEN -1
                                       ELSE                                                      0
                                  END * A.VLERABS)
                              -
                              SUM(CASE WHEN A.KODOPER IN ('CE','AM','SI','ST')             THEN  1 ELSE 0 END * A.VLERAAM),
             @GjendjeMv     = SUM(CASE WHEN A.KODOPER IN ('CE','BL','RK','RV','SI','ST')   THEN  1
                                       WHEN A.KODOPER IN ('SH','JP')                       THEN -1
                                       ELSE                                                      0
                                  END * A.VLERABS * ISNULL(A.KURS2,1) / ISNULL(A.KURS1,1))
                              -
                              SUM(CASE WHEN A.KODOPER IN ('CE','AM','SI','ST')             THEN  1 ELSE 0 END * A.VLERAAM * ISNULL(A.KURS2,1) / ISNULL(A.KURS1,1))--B.*
        FROM dbo.LevizjeAQAll A --INNER JOIN AQSCR B ON A.NRRENDOR=B.NRD
       WHERE KARTLLG=@sKod;
       
/*
      SELECT @DateFirstCE   = MIN(CASE WHEN ISNULL(B.KODOPER,'') IN ('CE')                 THEN  B.DATEOPER END),
      
             @DateFirstBL   = MIN(CASE WHEN ISNULL(B.KODOPER,'') IN ('BL','RK','RV')       THEN  B.DATEOPER END),
             @DateLastBL    = MAX(CASE WHEN ISNULL(B.KODOPER,'') IN ('BL','RK','RV')       THEN  B.DATEOPER END),
             @DateFirstPR   = MIN(CASE WHEN ISNULL(B.KODOPER,'') IN ('BL','RK','RV','PR')  THEN  B.DATEOPER END),
             
             @DateFirstSH   = MIN(CASE WHEN ISNULL(B.KODOPER,'') IN ('SH','JP')            THEN  B.DATEOPER END),
             @DateLastSH    = MIN(CASE WHEN ISNULL(B.KODOPER,'') IN ('SH','JP')            THEN  B.DATEOPER END),
             @DateFirstAM   = MIN(CASE WHEN ISNULL(B.KODOPER,'')='AM'                      THEN  B.DATEOPER END),
             @DateLastAM    = MAX(CASE WHEN ISNULL(B.KODOPER,'')='AM'                      THEN  B.DATEOPER END),
             
             @Vlera         = SUM(CASE WHEN B.KODOPER IN ('CE','BL','RK','RV','SI','ST')   THEN  1
                                       WHEN B.KODOPER IN ('SH','JP')                       THEN -1
                                       ELSE                                                      0
                                  END * B.VLERABS),
             @VleraMv       = SUM(CASE WHEN B.KODOPER IN ('CE','BL','RK','RV','SI','ST')   THEN  1
                                       WHEN B.KODOPER IN ('SH','JP')                       THEN -1
                                       ELSE                                                      0
                                  END * B.VLERABS * ISNULL(A.KURS2,1) / ISNULL(A.KURS1,1)),
             @VleraAM       = SUM(CASE WHEN B.KODOPER IN ('CE','AM','SI','ST')             THEN  1 ELSE 0 END * B.VLERAAM),
             @VleraAMMv     = SUM(CASE WHEN B.KODOPER IN ('CE','AM','SI','ST')             THEN  1 ELSE 0 END * B.VLERAAM * ISNULL(A.KURS2,1) / ISNULL(A.KURS1,1)),
             @Gjendje       = SUM(CASE WHEN B.KODOPER IN ('CE','BL','RK','RV','SI','ST')   THEN  1
                                       WHEN B.KODOPER IN ('SH','JP')                       THEN -1
                                       ELSE                                                      0
                                  END * B.VLERABS)
                              -
                              SUM(CASE WHEN B.KODOPER IN ('CE','AM','SI','ST')             THEN  1 ELSE 0 END * B.VLERAAM),
             @GjendjeMv     = SUM(CASE WHEN B.KODOPER IN ('CE','BL','RK','RV','SI','ST')   THEN  1
                                       WHEN B.KODOPER IN ('SH','JP')                       THEN -1
                                       ELSE                                                      0
                                  END * B.VLERABS * ISNULL(A.KURS2,1) / ISNULL(A.KURS1,1))
                              -
                              SUM(CASE WHEN B.KODOPER IN ('CE','AM','SI','ST')             THEN  1 ELSE 0 END * B.VLERAAM * ISNULL(A.KURS2,1) / ISNULL(A.KURS1,1))--B.*
        FROM AQ A INNER JOIN AQSCR B ON A.NRRENDOR=B.NRD
       WHERE KARTLLG=@sKod;
*/


             IF (NOT (@DateLastBl IS NULL)) AND (@DateDoc<@DateLastBl) 
                 SET @Result = ' Date veprimi para date blerje : dt blerje '                    + CONVERT(VARCHAR,@DateLastBl,  103)
             ELSE
             IF (NOT (@DateLastCe IS NULL)) AND (@DateDoc<@DateLastCe)
                 SET @Result = ' Date veprimi para date celje : dt celje '                      + CONVERT(VARCHAR,@DateLastCe,  103)
             ELSE
             IF (NOT (@DateLastAm IS NULL)) AND (@DateDoc<@DateLastAm) AND @sOper<>'JP'
                 SET @Result = ' Date veprimi para date amortizimi te fundit : dt amortizimi '  + CONVERT(VARCHAR,@DateLastAm,  103)
             ELSE    
             
             IF (NOT (@DateFirstSh IS NULL)) AND (@DateDoc<@DateFirstSh) 
                 SET @Result = ' Date veprimi pas date shitje : dt shitje '                     + CONVERT(VARCHAR,@DateFirstsh, 103)
             ELSE
             IF (NOT (@DateFirstCr IS NULL)) AND (@DateDoc<@DateFirstCr)
                 SET @Result = ' Date veprimi pas date cregjistrim / jashte perdorim : dt cregjistrim / jashte perdorim '  + CONVERT(VARCHAR,@DateFirstCr, 103);
                 



        IF @sOper='SH' AND @Result=''
           BEGIN

             IF (NOT (@DateLastSh IS NULL)) AND (@DateFirstSh<>@DateLastSh)
                 SET @Result = ' Aktivi tashme i shitur disa here : ' + CONVERT(VARCHAR,@DateFirstSh,103)+', '+CONVERT(VARCHAR,@DateLastSh,103)
             ELSE   
             IF (NOT (@DateLastSh IS NULL)) -- Ne kete rast jane njesoj @DateFirstSh dhe @DateLastSh
                 SET @Result = ' Aktivi tashme i shitur me pare dt '                   + CONVERT(VARCHAR,@DateLastSh,103)                 
             ELSE
             IF (NOT (@DateLastAM IS NULL)) AND @DateDoc<@DateLastAM
                 SET @Result = ' Date veprimi para date rivleresimi : dt rivleresimi ' + CONVERT(VARCHAR,@DateLastAM,103)
             ELSE   
             IF (NOT (@DateLastBl IS NULL)) AND @DateDoc<@DateLastBl 
                 SET @Result = ' Date shitje para dates se blerjes : dt blerje '       + CONVERT(VARCHAR,@DateLastBl,103);                 

           END;
       
       

        IF @sOper='BL' AND @Result='' 
           BEGIN

-- Duhet pyetur: 1 brenda Tempit
-- Perdoren Count(*) for KODORDER='BL' dhe NRD<>parameter
             IF (NOT (@DateLastBl IS NULL)) AND (@DateFirstBl<>@DateLastBl)
                 SET @Result = ' Aktivi tashme i blere disa here : ' + CONVERT(VARCHAR,@DateFirstBl,103)+', '+CONVERT(VARCHAR,@DateLastBl,103)
             ELSE   
             IF (NOT (@DateLastBl IS NULL)) -- Ne kete rast jane njesoj @DateFirstBl dhe @DateLastBl
                 SET @Result = ' Aktivi tashme i blere me pare dt '                    + CONVERT(VARCHAR,@DateLastBl,103) 
             ELSE       
             IF (NOT (@DateLastAM IS NULL)) AND (@DateDoc<@DateLastAM)
                 SET @Result = ' Date veprimi para date rivleresimi : dt rivleresimi ' + CONVERT(VARCHAR,@DateLastAM,103)
             ELSE   
             IF (NOT (@DateLastBl IS NULL)) AND (@DateDoc<@DateLastSh)
                 SET @Result = ' Date blerje para dates se shitjes : dt shitje '       + CONVERT(VARCHAR,@DateLastSh,103); 

           END;       
       
        
        
        IF @sOper='AM' AND @Result=''
           BEGIN

             IF (NOT (@DateLastAM IS NULL)) AND @DateDoc<@DateLastAM
                 SET @Result = ' Date veprimi para date rivleresimi te fundit : dt rivleresimi ' + CONVERT(VARCHAR,@DateLastAM, 103)
             ELSE   
             IF (NOT (@DateLastBl IS NULL)) AND @DateDoc<@DateLastBl 
                 SET @Result = ' Date veprimi para dates se blerjes : dt blerje '                + CONVERT(VARCHAR,@DateLastBl, 103);                 
                 
           END;

        

        IF (@sOper='RK' OR @sOper='RV') AND @Result='' 
           BEGIN

             IF (NOT (@DateLastBl IS NULL)) AND (@DateDoc<@DateLastBl)
                 SET @Result = ' Date veprimi para date blerje : dt blerje '           + CONVERT(VARCHAR,@DateLastBl, 103)
             ELSE   
             IF (NOT (@DateLastCe IS NULL)) AND (@DateDoc<@DateLastCe)
                 SET @Result = ' Date veprimi para date celje  : dt celje '            + CONVERT(VARCHAR,@DateLastCe,103)
             ELSE   
             IF (NOT (@DateLastSh IS NULL)) AND (@DateDoc>@DateLastSh)
                 SET @Result = ' Date veprimi pas  date shitje : dt shitje '           + CONVERT(VARCHAR,@DateLastSh, 103)
             ELSE   
             IF (NOT (@DateLastAm IS NULL)) AND (@DateDoc>@DateLastAm)
                 SET @Result = ' Date veprimi pas  date rivleresimi : dt rivleresimi ' + CONVERT(VARCHAR,@DateLastAM, 103); 
                 
           END;       



          IF ISNULL(@Result,'')<>''
             SET @Result = @sKod+':     '+@Result;


       
	RETURN (@Result)

END
GO
