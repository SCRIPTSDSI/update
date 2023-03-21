SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



-- DECLARE @pError Varchar(Max);
-- EXEC dbo.zzTransportTestData 'ROUTE',2,0,@pError Output




CREATE  PROCEDURE [dbo].[zzTransportTestData] 
(
 @pGrupi      Varchar(60),
 @pTipTest    Int,
 @pNrRendor   Int,
 @pListError  Varchar(Max) OUTPUT
)

AS
 


         SET NOCOUNT ON;
   
--    SELECT * FROM [EHW19].[dbo].[zzTransportListeShpenzime]


     DECLARE @sList        Varchar(Max),
             @sListErr     Varchar(Max),
             @sListErr2    Varchar(Max),
             @sGrupi       Varchar(50),
             @TipTest      Int,
             @NrRendor     Int;
             
         SET @sList      = '';
         SET @sListErr   = '';
         SET @sListErr2  = '';
         SET @sGrupi     = @pGrupi;
         SET @TipTest    = @pTipTest;
         SET @pListError = '';
         SET @NrRendor   = ISNULL(@pNrRendor,0);




-- Testi 1 - Test per fushat A egziston Fusha tek tabela zzTransportData01
       
          IF @TipTest=1
             BEGIN
             

                  SET @sListErr  = '';

               SELECT @sListErr=@sListErr+','+ISNULL(A.FIELDNAME,'')
                 FROM zzTransportListeShpenzime A
                WHERE GRUPI=@sGrupi AND -- parameter
                     (NOT EXISTS (SELECT * FROM Sys.Columns B WHERE OBJECT_ID('zzTransportData01')=OBJECT_ID AND A.FIELDNAME=B.[NAME]))
             ORDER BY A.FIELDNAME;  

   
                  IF SUBSTRING(@sListErr,1,1)=','
                     SET @sListErr = SUBSTRING(@sListErr,2,LEN(@sListErr));
   
   
                GOTO FUND;
                

             END;
             
             
             


--   Test 2 - Test per llogarite 

          IF @TipTest=2
             BEGIN


                   IF OBJECT_ID('TEMPDB..#TblKodLlogari') IS NOT NULL
                      DROP TABLE #TblKodLlogari;
                      

                   IF @NrRendor > 0             -- Vetem nje resht
                      BEGIN
                      
                        SELECT @sList = ISNULL(A.LISTELLOGARI ,'') 
                          FROM zzTransportListeShpenzime A
                         WHERE GRUPI=@sGrupi AND NRRENDOR=@NrRendor;  
                         
                      END
                      
                   ELSE
                   
                      BEGIN
                      
                        SELECT @sList = @sList+','+ISNULL(A.LISTELLOGARI ,'') 
                          FROM zzTransportListeShpenzime A
                         WHERE GRUPI=@sGrupi;  
                      
                      END;
                      
                      

                WHILE CHARINDEX(',,',@sList)>0
                  BEGIN
                      SET @sList = REPLACE(@sList,',,',',')
                  END;
   
                   IF SUBSTRING(@sList,1,1)=','
                      SET @sList = SUBSTRING(@sList,2,LEN(@sList));
      
    
               SELECT KOD=A.Splitet                             
                 INTO #TblKodLlogari 
                 FROM dbo.Split(@sList,',') A
                WHERE NOT EXISTS (SELECT * FROM LLOGARI B WHERE A.Splitet=B.KOD)
             ORDER BY 1;

               SELECT @sListErr = @sListErr + ',' + ISNULL(KOD,'') 
                 FROM #TblKodLlogari 
             ORDER BY KOD;

    
               SELECT @sListErr2 = @sListErr2+','+ISNULL(A.KOD ,'') 
             --SELECT KOD,Nr=COUNT(*)
                 FROM #TblKodLlogari A
             GROUP BY KOD
               HAVING COUNT(*)>1
             ORDER BY 1;
             
                  SET @sListErr2=ISNULL(@sListErr2,'');
                WHILE CHARINDEX(',,',@sListErr2)>0
                  BEGIN
                      SET @sListErr2 = REPLACE(@sListErr2,',,',',')
                  END;
                   IF SUBSTRING(@sListErr2,1,1)=','
                      SET @sListErr2 = SUBSTRING(@sListErr2,2,LEN(@sListErr2));


           --  SELECT @sListErr = @sListErr+','+ISNULL(A.KOD,'') 
           --    FROM  ( SELECT *
           --              FROM dbo.Split(@sList,',') A
           --             WHERE NOT EXISTS (SELECT * FROM LLOGARI B WHERE A.KOD=B.KOD)   ) A
           --ORDER BY 1;

                WHILE CHARINDEX(',,',@sListErr)>0
                  BEGIN
                      SET @sListErr = REPLACE(@sListErr,',,',',')
                  END;
   

                   IF SUBSTRING(@sListErr,1,1)=','
                      SET @sListErr = SUBSTRING(@sListErr,2,LEN(@sListErr));


                   IF OBJECT_ID('TEMPDB..#TblKodLlogari') IS NOT NULL
                      DROP TABLE #TblKodLlogari;

                 GOTO FUND;
                 
             END;
       
       
       
FUND:       
       
         SET @pListError = ISNULL(@sListErr,'');

         IF (@pListError<>'') AND (@sListErr2<>'')
            SET @pListError = @pListError+',    (Figurojne disa here: '+@sListErr2+')'
         ELSE
         IF (@sListErr2<>'')
            SET @pListError = 'Figurojne disa here: '+@sListErr2;

         
GO
