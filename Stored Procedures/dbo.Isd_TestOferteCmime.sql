SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE     procedure [dbo].[Isd_TestOferteCmime]

(
 @pGrupTest    Varchar(10),
 @pWhere       Varchar(MAX),
 @pNrd         BigInt,
 @pIndTest     Int,
 @pAnalitik    Int
)

AS


--      EXEC Isd_TestOferteCmime 'ALL','',0,1,1;


         SET NOCOUNT ON;

     DECLARE @Sql VARCHAR(MAX);



   IF @pGrupTest='KL'                     --  KLIENTE

      BEGIN

   --   Referenca me shume se nje here

        IF @pIndTest=1
		    SELECT KOD,PERSHKRIM=MAX(PERSHKRIM),NRPERSERITUR=COUNT(*),NRRENDOR=MAX(NRRENDOR),TROW=CAST(0 AS BIT)
			  FROM KLIENTCMIMKL
		     WHERE NRD=@pNrd
		  GROUP BY KOD
		    HAVING COUNT(*)>1
		  ORDER BY NRPERSERITUR,KOD;


   --   Referenca qe Mungojne (Kode gabim)....

        IF @pIndTest=2
		    SELECT KOD,PERSHKRIM,NRRENDOR,TROW=CAST(0 AS BIT)
			  FROM KLIENTCMIMKL A
		     WHERE A.NRD=@pNrd AND (NOT (EXISTS (SELECT KOD FROM KLIENT  B WHERE A.KOD=B.KOD)))
		  ORDER BY KOD;


	--   Referenca qe nuk jane ne Oferte

	     IF @pIndTest=3
            BEGIN
              SET @Sql = '
				SELECT KOD,PERSHKRIM,NRRENDOR,TROW=CAST(0 AS BIT)
				  FROM KLIENT 
				 WHERE 1=1 AND (NOT (EXISTS (SELECT KOD 
											   FROM KLIENTCMIMKL B 
											  WHERE B.NRD='+Cast(@pNrd AS VARCHAR)+' AND KLIENT.KOD=B.KOD)))
			  ORDER BY KOD '
              IF @pWhere<>''
                 SET @Sql = REPLACE(@Sql,'1=1',@pWhere);
              EXEC ( @Sql );

            END;

        RETURN;  

      END;



   IF @pGrupTest='ART'                    --  ARTIKUJ

      BEGIN

   --   Referenca me shume se nje here

	     IF @pIndTest=1
		    SELECT KOD,PERSHKRIM=MAX(PERSHKRIM),NRPERSERITUR=COUNT(*),NRRENDOR=MAX(NRRENDOR),TROW=CAST(0 AS BIT)
			  FROM KLIENTCMIMART
		     WHERE NRD=@pNrd
		  GROUP BY KOD
		    HAVING COUNT(*)>1
		  ORDER BY NRPERSERITUR,KOD;


   --   Referenca qe Mungojne (Kode gabim)....

         IF @pIndTest=2
		    SELECT KOD,PERSHKRIM,NRRENDOR,TROW=CAST(0 AS BIT)
			  FROM KLIENTCMIMART A
		     WHERE A.NRD=@pNrd AND (NOT (EXISTS (SELECT KOD FROM ARTIKUJ B WHERE A.KOD=B.KOD)))
		  ORDER BY KOD;


	--   Referenca qe nuk jane ne Oferte

	     IF @pIndTest=3
            BEGIN
              SET @Sql = '
				SELECT KOD,PERSHKRIM,NRRENDOR,TROW=CAST(0 AS BIT)
				  FROM ARTIKUJ 
				 WHERE 1=1 AND (NOT (EXISTS (SELECT KOD 
                                               FROM KLIENTCMIMART B 
                                              WHERE B.NRD='+Cast(@pNrd AS VARCHAR)+' AND ARTIKUJ.KOD=B.KOD)))
			  ORDER BY KOD ';
              IF @pWhere<>''
                 SET @Sql = REPLACE(@Sql,'1=1',@pWhere);
              EXEC ( @Sql );

            END;

         RETURN;

      END;
      
      -- te perfundohet 
      
      
      
      
      
-- Cifti (ARTIKUJ, KLIENTE) perseritur ne te gjithe ofertat, 
-- ose Thjesht artikull, ose thejesht Klient, secili test ne dy formate: Analitik ose Permbledhur.

   IF @pGrupTest='ALL'                    
      BEGIN

               IF OBJECT_ID('TEMPDB..#TMPOFERTE') IS NOT NULL
                  DROP TABLE #TMPOFERTE;
               IF OBJECT_ID('TEMPDB..#TMPCMIME')  IS NOT NULL
                  DROP TABLE #TMPCMIME;
                  

           SELECT NRRENDOR=0                      INTO #TMPOFERTE FROM KLIENTCMIM   WHERE 1=2;
           SELECT NRD=0,CMIMMIN=CMIM,CMIMMAX=CMIM INTO #TMPCMIME  FROM KLIENTCMIMCM WHERE 1=2;
           
           
              SET @Sql = '
                    INSERT INTO #TMPOFERTE (NRRENDOR)
				    SELECT DISTINCT A.NRRENDOR
				      FROM KLIENTCMIM A INNER JOIN KLIENTCMIMART A1 ON A.NRRENDOR=A1.NRD
		                                INNER JOIN KLIENTCMIMKL  A2 ON A.NRRENDOR=A2.NRD 
		                                INNER JOIN ARTIKUJ       R1 ON A1.KOD=R1.KOD
		                                INNER JOIN KLIENT        R2 ON A2.KOD=R2.KOD
				     WHERE 1=1 
			      ORDER BY 1; 

              
                    INSERT INTO #TMPCMIME (NRD,CMIMMIN,CMIMMAX)
				    SELECT A1.NRRENDOR, MIN(ISNULL(CMIM,0)), MAX(ISNULL(CMIM,0))
				      FROM KLIENTCMIM A INNER JOIN KLIENTCMIMART A1 ON A.NRRENDOR =A1.NRD
		                                INNER JOIN KLIENTCMIMKL  A2 ON A.NRRENDOR =A2.NRD 
		                                INNER JOIN KLIENTCMIMCM  A3 ON A1.NRRENDOR=A3.NRD
		                                INNER JOIN ARTIKUJ       R1 ON A1.KOD=R1.KOD
		                                INNER JOIN KLIENT        R2 ON A2.KOD=R2.KOD
				     WHERE 1=1 
				  GROUP BY A1.NRRENDOR   
			      ORDER BY 1; ';

               IF @pWhere<>''
                  SET @Sql = REPLACE(@Sql,'1=1',@pWhere);
         -- PRINT @Sql;
             EXEC (@Sql);
             

-- Testi (Artikull, Klient) i perseritur. (Testi ne dy formate: analitik ose permbledhur)

	           IF @pIndTest=1 
	                          
                  BEGIN
            
                    IF @pAnalitik=1 
                       BEGIN
		                   SELECT Artikull     = A1.KOD, PershkrimArt = A1.PERSHKRIM,
		                          Klient       = A2.KOD, PershkrimKl  = A2.PERSHKRIM, 
		                          CmimMin      = TC.CmimMin, CmimMax  = TC.CmimMax,  T.NrTime,
		                          Oferte       = A.KOD,	 PershkrimOf  = A.PERSHKRIM, DateFillim=A.DateStart, DateFund=A.DateEnd, Aktive=A.ACTIV,
		                          Koment       = '(Artikuj,Klient) perseritur '+CAST(T.NrTime AS VARCHAR), 
		                          A.NrRendor 
		                     FROM KLIENTCMIM A INNER JOIN #TMPOFERTE    TM ON A.NRRENDOR=TM.NRRENDOR
		                                       INNER JOIN KLIENTCMIMART A1 ON A.NRRENDOR=A1.NRD
		                                       INNER JOIN KLIENTCMIMKL  A2 ON A.NRRENDOR=A2.NRD
		                                       INNER JOIN 
		                                     (
		                                       SELECT KODART=A1.KOD, KODKL=A2.KOD, NRTIME = COUNT(*)
		                                         FROM KLIENTCMIM A INNER JOIN #TMPOFERTE    TM ON A.NRRENDOR=TM.NRRENDOR
		                                                           INNER JOIN KLIENTCMIMART A1 ON A.NRRENDOR=A1.NRD
		                                                           INNER JOIN KLIENTCMIMKL  A2 ON A.NRRENDOR=A2.NRD
                                             GROUP BY A1.KOD,A2.KOD
                                               HAVING COUNT(*)>1
                                                    ) T ON A1.KOD=T.KODART AND A2.KOD=T.KODKL
                                                    
                                               LEFT  JOIN #TMPCMIME     TC ON A1.NRRENDOR=TC.NRD     

                         ORDER BY NRTIME DESC,KODART,KODKL;
                       END;
                   
	                IF @pAnalitik<>1
                       BEGIN

		                   SELECT Artikull     = A1.KOD, PershkrimArt = MAX(A1.PERSHKRIM),
		                          Klient       = A2.KOD, PershkrimKl  = MAX(A2.PERSHKRIM), 
		                          NrTime       = MAX(T.NrTime),
		                          Koment       = '(Artikuj,Klient) perseritur '+CAST(MAX(T.NrTime) AS VARCHAR)
		                     FROM KLIENTCMIM A INNER JOIN #TMPOFERTE    TM ON A.NRRENDOR=TM.NRRENDOR
		                                       INNER JOIN KLIENTCMIMART A1 ON A.NRRENDOR=A1.NRD
		                                       INNER JOIN KLIENTCMIMKL  A2 ON A.NRRENDOR=A2.NRD
		                                       INNER JOIN 
		                                     (
		                                       SELECT KODART=A1.KOD, KODKL=A2.KOD, NRTIME = COUNT(*)
		                                         FROM KLIENTCMIM A INNER JOIN #TMPOFERTE    TM ON A.NRRENDOR=TM.NRRENDOR
		                                                      INNER JOIN KLIENTCMIMART A1 ON A.NRRENDOR=A1.NRD
		                                                      INNER JOIN KLIENTCMIMKL  A2 ON A.NRRENDOR=A2.NRD
                                             GROUP BY A1.KOD,A2.KOD
                                               HAVING COUNT(*)>1
                                               )    T ON A1.KOD=T.KODART AND A2.KOD=T.KODKL

                         GROUP BY A1.KOD,A2.KOD                           
                         ORDER BY NRTIME DESC,Artikull,Klient;
                       END;
                   
                  END;
            
-- Fund testi (Artikull, Klient) i perseritur.




-- Testi (Artikull) i perseritur. (Testi ne dy formate: analitik ose permbledhur)

	           IF @pIndTest=2 
                  BEGIN
            
                    IF @pAnalitik=1
                       BEGIN

		                   SELECT Artikull     = A1.KOD, PershkrimArt = A1.PERSHKRIM, 
                          		  CmimMin      = TC.CmimMin, CmimMax  = TC.CmimMax,   T.NrTime,
		                          Oferte       = A.KOD,  PershkrimOf  = A.PERSHKRIM,  DateFillim=A.DateStart, DateFund=A.DateEnd, Aktive=A.ACTIV,
		                          Koment       = 'Artikuj perseritur '+CAST(T.NrTime AS VARCHAR), 
		                          A.NrRendor 
		                     FROM KLIENTCMIM A INNER JOIN #TMPOFERTE    TM ON A.NRRENDOR=TM.NRRENDOR
		                                       INNER JOIN KLIENTCMIMART A1 ON A.NRRENDOR=A1.NRD                           
		                                       INNER JOIN 
		                                     (
		                                       SELECT KODART=A1.KOD, NRTIME = COUNT(*)                                    
		                                         FROM KLIENTCMIM A INNER JOIN #TMPOFERTE    TM ON A.NRRENDOR=TM.NRRENDOR
		                                                           INNER JOIN KLIENTCMIMART A1 ON A.NRRENDOR=A1.NRD       
                                             GROUP BY A1.KOD                                                              
                                               HAVING COUNT(*)>1
                                               )    T ON A1.KOD=T.KODART
                                               
                                               LEFT  JOIN #TMPCMIME     TC ON A1.NRRENDOR=TC.NRD                                                  
                                               
                         ORDER BY NRTIME DESC,KODART                                                                      
              
                       END;

                    IF @pAnalitik<>1
                       BEGIN

		                   SELECT Artikull     = A1.KOD, PershkrimArt = MAX(A1.PERSHKRIM), 
		                          NrTime       = MAX(T.NrTime),
		                          Koment       = 'Artikuj perseritur '+CAST(MAX(T.NrTime) AS VARCHAR)
		                     FROM KLIENTCMIM A INNER JOIN #TMPOFERTE    TM ON A.NRRENDOR=TM.NRRENDOR
		                                       INNER JOIN KLIENTCMIMART A1 ON A.NRRENDOR=A1.NRD                           
		                                       INNER JOIN 
		                                     (
		                                       SELECT KODART=A1.KOD, NRTIME = COUNT(*)                                    
		                                         FROM KLIENTCMIM A INNER JOIN #TMPOFERTE    TM ON A.NRRENDOR=TM.NRRENDOR
		                                                           INNER JOIN KLIENTCMIMART A1 ON A.NRRENDOR=A1.NRD       
                                             GROUP BY A1.KOD                                                              
                                               HAVING COUNT(*)>1
                                               )    T ON A1.KOD=T.KODART                                                  
                         GROUP BY A1.KOD 
                         ORDER BY NRTIME DESC,Artikull                                                                    
              
                       END;

                  END;    

-- Fund testi (Artikull) i perseritur.




-- Testi (Klient) i perseritur. (Testi ne dy formate: analitik ose permbledhur)

	           IF @pIndTest=3 
                  BEGIN
             
                    IF @pAnalitik=1
                       BEGIN
		                   SELECT Klient       = A2.KOD, PershkrimKl  = A2.PERSHKRIM, T.NrTime,                           
		                          Oferte       = A.KOD,  PershkrimOf  = A.PERSHKRIM,  DateFillim=A.DateStart, DateFund=A.DateEnd, Aktive=A.ACTIV,
		                          Koment       = 'Kliente perseritur '+CAST(T.NrTime AS VARCHAR), A.NrRendor 
		                     FROM KLIENTCMIM A INNER JOIN #TMPOFERTE    TM ON A.NRRENDOR=TM.NRRENDOR                      
		                                       INNER JOIN KLIENTCMIMKL  A2 ON A.NRRENDOR=A2.NRD
		                                       INNER JOIN 
		                                     (
		                                        SELECT KODKL=A2.KOD, NRTIME = COUNT(*)                                    
		                                          FROM KLIENTCMIM A INNER JOIN #TMPOFERTE    TM ON A.NRRENDOR=TM.NRRENDOR  
		                                                            INNER JOIN KLIENTCMIMKL  A2 ON A.NRRENDOR=A2.NRD      
                                              GROUP BY A2.KOD                                                             
                                                HAVING COUNT(*)>1
                                                     ) T ON A2.KOD=T.KODKL                                                
                         ORDER BY NrTime DESC,KODKL;                                                                      
                   
                       END;
                 
                    IF @pAnalitik<>1
                       BEGIN
		                   SELECT Klient       = A2.KOD, PershkrimKl  = MAX(A2.PERSHKRIM), 
		                          NrTime       = MAX(T.NrTime),                                                           
		                          Koment       = 'Kliente perseritur '+CAST(MAX(T.NrTime) AS VARCHAR) 
		                     FROM KLIENTCMIM A INNER JOIN #TMPOFERTE    TM ON A.NRRENDOR=TM.NRRENDOR                      
		                                       INNER JOIN KLIENTCMIMKL  A2 ON A.NRRENDOR=A2.NRD
		                                       INNER JOIN 
		                                     (
		                                        SELECT KODKL=A2.KOD, NRTIME = COUNT(*)                                    
		                                          FROM KLIENTCMIM A INNER JOIN #TMPOFERTE    TM ON A.NRRENDOR=TM.NRRENDOR  
		                                                            INNER JOIN KLIENTCMIMKL  A2 ON A.NRRENDOR=A2.NRD      
                                              GROUP BY A2.KOD                                                                   
                                                HAVING COUNT(*)>1
                                                     ) T ON A2.KOD=T.KODKL                                                      
                         GROUP BY A2.KOD 
                         ORDER BY NrTime DESC,Klient;                                                                      

                       END;
                 
             END;

-- Fund testi (Klient) i perseritur. (Testi ne dy formate: analitik ose permbledhur)

             
               IF OBJECT_ID('TEMPDB..#TMPOFERTE') IS NOT NULL
                  DROP TABLE #TMPOFERTE;
               IF OBJECT_ID('TEMPDB..#TMPCMIME')  IS NOT NULL
                  DROP TABLE #TMPCMIME;


      END;
      
      
      
GO
