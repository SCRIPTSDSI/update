SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE        procedure [dbo].[Isd_AQAMTestDisplay]
(
  @pWhere     Varchar(Max),
  @pTest      Varchar(20),
  @pUser      Varchar(30)
--@pTableTmp  Varchar(30)
)

AS   -- EXEC dbo.Isd_AQAMTestDisplay '3=3','T','ADMIN';
     

--           Testimi per kategori jo te sakte, grupim, norme AM, skeme LM per amortizimin,Departament,Liste etj.... 
--           Test vlen shume per amortizimin prandaj teston dhe radhen e veprimeve te aktiveve

--           Perdoret tek forma e Amortizimit





         SET NOCOUNT ON

     DECLARE @sSql         VARCHAR(MAX),
             @sWhere       VARCHAR(MAX),
			 @sTest        VARCHAR(20),
             @DateMin      DATETIME,
             @DateMax      DATETIME;
   
   
         SET @DateMax    = CONVERT(DATETIME,'2200/12/31',121);
         SET @DateMin    = 0;
         SET @sWhere     = @pWhere;
		 SET @sTest      = @pTest;
   
         
          IF OBJECT_ID('TEMPDB..#AQTempTest')     IS NOT NULL
             DROP TABLE #AQTempTest;
             
          IF OBJECT_ID('TEMPDB..#AQTempMsgTest')  IS NOT NULL
             DROP TABLE #AQTempMsgTest;
             
          IF OBJECT_ID('TEMPDB..#AQTempDisplay')  IS NOT NULL
             DROP TABLE #AQTempDisplay;

          IF OBJECT_ID('TEMPDB..#AQTempMsgTest2') IS NOT NULL
		     DROP TABLE #AQTempMsgTest2;


      SELECT KOD=KARTLLG                     INTO #AQTempTest     FROM AQSCR WHERE 1=2;
      SELECT KOD=KARTLLG,MsgError=Space(300) INTO #AQTempMsgTest  FROM AQSCR WHERE 1=2;
      
      



--           0. Gjenerimi i listes se zgjedhur sipas filterit


         SET @sSql = '
                                                                     
             INSERT INTO #AQTempTest                                   
                   (KOD)
             SELECT B.KARTLLG
               FROM AQ A LEFT JOIN AQSCR      B  ON A.NRRENDOR=B.NRD
                         LEFT JOIN AQKARTELA  R1 ON B.KARTLLG=R1.KOD
                         LEFT JOIN AQKATEGORI R2 ON R2.KOD=R1.KATEGORI
              WHERE (1=1) --AND B.KARTLLG=''AS000004''
           GROUP BY B.KARTLLG
           ORDER BY B.KARTLLG;';          

          IF @sWhere<>''
             SET @sSql = REPLACE(@sSql,'1=1',@sWhere);
           
        EXEC (@sSql);     --PRINT @sSql





--           1. Testi per referencat e aktiveve 


      INSERT INTO #AQTempMsgTest                                   
            (KOD,MsgError)
      SELECT A.Kod, MsgError
        FROM
           (
                    SELECT R1.KOD,   --R1.KATEGORI,R1.GRUP,R1.KODLM,A=R2.KOD,R2.ACTIVAM2,
                           MsgError = CASE WHEN ISNULL(R2.KOD,'')='' THEN 'Kategori,' ELSE '' END+
                                      CASE WHEN ISNULL(R3.KOD,'')='' THEN 'Grupi,'    ELSE '' END+
                                      CASE WHEN ISNULL(R4.KOD,'')='' THEN 'Skeme LM,' ELSE '' END+
                                      CASE WHEN ISNULL(R1.DEP,'') <>'' AND ISNULL(R5.KOD,'')=''                                                                  THEN 'Dep,'          ELSE '' END+
                                      CASE WHEN ISNULL(R1.LIST,'')<>'' AND ISNULL(R6.KOD,'')=''                                                                  THEN 'Liste,'        ELSE '' END+
                                                                            
                                      CASE WHEN ISNULL(R2.KOD,'') <>'' AND                             (ISNULL(R2.NORMEAM,0)  <=0 OR ISNULL(R2.NORMEAM,0)  >100) THEN 'Norma AM,'     ELSE '' END+
                                      CASE WHEN ISNULL(R2.KOD,'') <>'' AND                             (ISNULL(R2.NRTIMEAM,0) <=0 OR ISNULL(R2.NRTIMEAM,0) >12 ) THEN 'Periudhe AM,'  ELSE '' END+
                                      CASE WHEN ISNULL(R2.KOD,'') <>'' AND ISNULL(R2.ACTIVAM2,0)=1 AND (ISNULL(R2.NORMEAM2,0) <=0 OR ISNULL(R2.NORMEAM2,0) >100) THEN 'Norma2 AM,'    ELSE '' END+
                                      CASE WHEN ISNULL(R2.KOD,'') <>'' AND ISNULL(R2.ACTIVAM2,0)=1 AND (ISNULL(R2.NRTIMEAM2,0)<=0 OR ISNULL(R2.NRTIMEAM2,0)>12 ) THEN 'Periudhe2 AM,' ELSE '' END

                      FROM AQKARTELA  R1   INNER JOIN #AQTempTest  T  ON R1.KOD=T.KOD
                                           LEFT  JOIN AQKATEGORI   R2 ON R2.KOD=R1.KATEGORI
                                           LEFT  JOIN AQGRUP       R3 ON R3.KOD=R1.GRUP
                                           LEFT  JOIN AQSKEMELM    R4 ON R4.KOD=R1.KODLM
                                           LEFT  JOIN DEPARTAMENT  R5 ON R5.KOD=R1.DEP
                                           LEFT  JOIN LISTE        R6 ON R6.KOD=R1.LIST
             ) A
       WHERE MsgError<>''
    ORDER BY A.KOD; 





--           2. Gjenerim Errore per Celjen tek tabela #AQTempMsgTest2, e cila inseryohet tek #AQTempMsgTest


	  SELECT T.KOD,
	         MsgError = CASE WHEN ISNULL(B.DATEOPER,0)=0                                                                   THEN 'Date celje gabuar,'              ELSE '' END + 
			            CASE WHEN ISNULL(Ce.NRRENDOR,0)=0                                                                  THEN 'Mungon kosto historike,'         ELSE '' END + 
			            CASE WHEN ISNULL((SELECT COUNT(*) FROM AQCelje Ce WHERE Ce.KARTLLG=B.KOD GROUP BY Ce.KARTLLG),0)>1 THEN 'Kosto historike disa here,'      ELSE '' END + 
			            CASE WHEN ISNULL(Ce.NRRENDOR,0)>0 
						     THEN CASE WHEN ABS(ISNULL(B.VLERABS,0)+ISNULL(B.VLERAAM,0)-ISNULL(Ce.VLERAFATMV,0))>1		   THEN 'Gabim vl.celje/kosto historike,' ELSE '' END
							 ELSE                                                                                                                                      ''
						END
	    INTO #AQTempMsgTest2
	    FROM AQSCR B INNER JOIN #AQTempMsgTest T  ON T.KOD=B.KARTLLG AND B.KODOPER='CE'
		             LEFT  JOIN AQCelje        Ce ON B.KARTLLG=Ce.KARTLLG;


      UPDATE T                                                                                -- Update per ato qe egzistojne ne #AQTempMsgTest
         SET T.MsgError = T.MsgError + T2.MsgError
        FROM #AQTempMsgTest T INNER JOIN #AQTempMsgTest2 T2 ON T.KOD=T2.KOD;

      INSERT INTO #AQTempMsgTest                                                              -- Insert per ato qe mungojne   ne #AQTempMsgTest
	        (KOD,MsgError)
      SELECT KOD,MsgError
	    FROM #AQTempMsgTest2 T2
       WHERE NOT EXISTS (SELECT KOD FROM #AQTempMsgTest T WHERE T.KOD=T2.KOD)
    ORDER BY T2.KOD;


	      IF OBJECT_ID('TEMPDB..#AQTempMsgTest2') IS NOT NULL
		     DROP TABLE #AQTempMsgTest2;

--    SELECT * FROM #AQTempTest ORDER BY KOD; SELECT * FROM #AQTempMsgTest ORDER BY KOD;   RETURN;
        


--           3. Testi per datat e veprimeve te aktiveve 


      SELECT A.*,
             KATEGORI    = R1.KATEGORI+' - '+ISNULL(R2.PERSHKRIM,''),
             GRUPIM      = R1.GRUP    +' - '+ISNULL(R3.PERSHKRIM,''),
             R1.PERSHKRIM,
             MsgError    = CASE WHEN NrTimeCelje=0   AND NrTimeBlerje=0                    THEN 'Pa Celje ose blerje,'               ELSE '' END +
                           CASE WHEN NrTimeCelje>1                                         THEN 'Celje disa here,'                   ELSE '' END +
                           CASE WHEN NrTimeBlerje>1                                        THEN 'Blerje disa here,'                  ELSE '' END +
                           CASE WHEN NrTimeCelje>=1  AND NrTimeBlerje>=1                   THEN 'Celje dhe Blerje,'                  ELSE '' END +                       
                           CASE WHEN DateTjeraMin<DateCelje OR DateTjeraMin<DateBlerje     THEN 'Veprime para celje-blerje,'         ELSE '' END +

						/* CASE WHEN ISNULL(NrTimeCelje,0)=0 
						        THEN ''
						        ELSE CASE WHEN ISNULL((SELECT COUNT(*) FROM AQCelje Ce WHERE Ce.KARTLLG=R1.KOD GROUP BY Ce.KARTLLG),0)=0
						                       THEN 'mungon kosto historike,'
										  WHEN ISNULL((SELECT COUNT(*) FROM AQCelje Ce WHERE Ce.KARTLLG=R1.KOD GROUP BY Ce.KARTLLG),0)>1
										       THEN 'kosto historike disa here,'
										  ELSE      ''
                                     END
						   END+ */

                           CASE WHEN NrTimeShitje>1                                        THEN 'Shitje disa here,'                  ELSE '' END +
                           CASE WHEN NrTimeJashtPerd>1                                     THEN 'Jashte perdorim disa here,'         ELSE '' END +
                           CASE WHEN NrTimeCRegjistrim>1                                   THEN 'CRegjistrim disa here,'             ELSE '' END +
                           CASE WHEN NrTimeShitje>=1 AND NrTimeJashtPerd>=1                THEN 'Shitje dhe JashtePerdorim,'         ELSE '' END +
                           CASE WHEN DateTjeraMax>DateShitje OR DateTjeraMax>DateJashtPerd OR DatetjeraMax>DateCRegjistrim
                                                                                           THEN 'Veprime pas CRegjistrimit'          ELSE '' END +
                           CASE WHEN ISNULL(T.MsgError,'')<>''                             THEN T.MsgError                           ELSE '' END,
             R1.NRRENDOR
                        
        INTO #AQTempDisplay     
        
        FROM
          (
           
               SELECT KOD                = B.KARTLLG,
                      DateCelje          = MAX(CASE WHEN B.KODOPER='CE' 
                                                    THEN CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END 
                                                    ELSE 0 
                                               END),
                      DateBlerje         = MAX(CASE WHEN B.KODOPER='BL' 
                                                    THEN CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END 
                                                    ELSE 0 
                                               END),
                      DateShitje         = MIN(CASE WHEN CHARINDEX(','+B.KODOPER+',',',SH,,')>0
                                                    THEN CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END 
                                                    ELSE @DateMax
                                               END),
                      DateJashtPerd      = MIN(CASE WHEN CHARINDEX(','+B.KODOPER+',',',JP,')>0
                                                    THEN CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END 
                                                    ELSE @DateMax 
                                               END),
                      DateCregjistrim    = MIN(CASE WHEN CHARINDEX(','+B.KODOPER+',',',CR,')>0
                                                    THEN CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END 
                                                    ELSE @DateMax 
                                               END),
                      DateTjeraMin       = MIN(CASE WHEN CHARINDEX(','+B.KODOPER+',',',CE,BL,')=0
                                                    THEN CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END 
                                                    ELSE @DateMax 
                                               END),
                      DateTjeraMax       = MAX(CASE WHEN CHARINDEX(','+B.KODOPER+',',',SH,JP,CR')=0
                                                    THEN CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END 
                                                    ELSE 0
                                               END),
                      NrTimeBlerje       = SUM(CASE WHEN B.KODOPER='BL' THEN 1 ELSE 0 END),
                      NrTimeCElje        = SUM(CASE WHEN B.KODOPER='CE' THEN 1 ELSE 0 END),
                      NrTimeSHitje       = SUM(CASE WHEN CHARINDEX(','+B.KODOPER+',',',SH,')>0 THEN 1 ELSE 0 END),
                      NrTimeJashtPerd    = SUM(CASE WHEN CHARINDEX(','+B.KODOPER+',',',JP,')>0 THEN 1 ELSE 0 END),
                      NrTimeCRegjistrim  = SUM(CASE WHEN CHARINDEX(','+B.KODOPER+',',',CR,')>0 THEN 1 ELSE 0 END)
                    
                 FROM AQ A INNER JOIN AQSCR        B  ON A.NRRENDOR=B.NRD
                           INNER JOIN #AQTempTest  T  ON B.KARTLLG=T.KOD
             -- WHERE (1=1)
             GROUP BY B.KARTLLG   
           
             ) A         LEFT  JOIN AQKARTELA       R1 ON A.KOD=R1.KOD
                         LEFT  JOIN #AQTempMsgTest  T  ON T.KOD=R1.KOD
                         LEFT  JOIN AQKATEGORI      R2 ON R2.KOD=R1.KATEGORI   
                         LEFT  JOIN AQGRUP          R3 ON R3.KOD=R1.GRUP
            
    ORDER BY A.KOD;
    




--           4. Plotesimi i #AQTempDisplay me te dhenat e #AQTempMsgTest (per ato qe mungojne)


      INSERT INTO #AQTempDisplay
	        (KOD, PERSHKRIM, KATEGORI, GRUPIM, MsgError)

	  SELECT R1.KOD,R1.PERSHKRIM,R1.KATEGORI,R1.GRUP,T.MsgError
	    FROM #AQTempMsgTest T INNER JOIN AQKARTELA R1 ON T.KOD=R1.KOD
       WHERE NOT EXISTS (SELECT KOD FROM #AQTempDisplay T2 WHERE T2.KOD=R1.KOD)
    ORDER BY R1.KOD;





--           5. Kur hidhet procedura vetem per test gabime (jo afishim). Perdoret perpara amortizimit


	      IF @sTest='TESTONLY'            
		     BEGIN
			   SELECT TOP 1 MsgError=ISNULL(A.MsgError,'') FROM #AQTempDisplay A WHERE ISNULL(A.MsgError,'')<>'';
			   RETURN;
			 END;





--           Afishimi


      SELECT Kod              = A.KOD,
             Emertim          = A.PERSHKRIM,
             Mesazh_gabimi    = MsgError,
             Kategori         = A.KATEGORI,
             Grupim           = A.GRUPIM,
             DateCelje        = CASE WHEN A.DateCelje =@DateMin    OR A.DateCelje =@DateMax    THEN '' ELSE CONVERT(VARCHAR(20),A.DateCelje, 104)    END,
             DateBlerje       = CASE WHEN A.DateBlerje=@DateMin    OR A.DateBlerje=@DateMax    THEN '' ELSE CONVERT(VARCHAR(20),A.DateBlerje,104)    END,
             DateShitje       = CASE WHEN A.DateShitje=@DateMin    OR A.DateShitje=@DateMax    THEN '' ELSE CONVERT(VARCHAR(20),A.DateShitje,104)    END,
             DateJashtPerd    = CASE WHEN A.DateJashtPerd=@DateMin OR A.DateJashtPerd=@DateMax THEN '' ELSE CONVERT(VARCHAR(20),A.DateJashtPerd,104) END,
             DateTjeraMin     = CASE WHEN A.DateTjeraMin=@DateMin  OR A.DateTjeraMin=@DateMax  THEN '' ELSE CONVERT(VARCHAR(20),A.DateTjeraMin,104)  END,
             DateTjeraMax     = CASE WHEN A.DateTjeraMax=@DateMin  OR A.DateTjeraMax=@DateMax  THEN '' ELSE CONVERT(VARCHAR(20),A.DateTjeraMax,104)  END,
             NrBlerje         = A.NrTimeBlerje,
             NrShitje         = A.NrTimeShitje,
             NrCelje          = A.NrTimeCelje,
             NrJashtePerd     = A.NrTimeJashtPerd,
             NrRendor         = A.NRRENDOR,
             TRow             = CAST(0 AS BIT),
             TagNr            = CAST(0 AS INT)
        FROM #AQTempDisplay A
       WHERE ISNULL(MsgError,'')<>'' 
    ORDER BY A.KOD;    
           

          IF OBJECT_ID('TEMPDB..#AQTempTest')    IS NOT NULL
             DROP TABLE #AQTempTest;

          IF OBJECT_ID('TEMPDB..#AQTempMsgTest') IS NOT NULL
             DROP TABLE #AQTempMsgTest;

          IF OBJECT_ID('TEMPDB..#AQTempDisplay') IS NOT NULL
             DROP TABLE #AQTempDisplay;
           
           
GO
