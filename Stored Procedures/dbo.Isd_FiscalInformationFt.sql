SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--        Exec [dbo].[Isd_FiscalInformationFt] 'SM',4 --1723205 -- 'FJ',1406094


CREATE Procedure [dbo].[Isd_FiscalInformationFt]
(
  @pTableName     Varchar(20),
  @pNrRendor      Int
 )
As
     DECLARE @NrRendor        Int,
             @TableName       Varchar(20),
			 @iLength         Int;

         SET @TableName     = @pTableName;   -- 'FJ';
         SET @NrRendor      = @pNrRendor;    -- 443250;
		 SET @iLength       = 150;
		 

          IF CHARINDEX(','+@TableName+',',',FJ,FF,FD,SM,')=0
             BEGIN
               SELECT NrOrder = '', Pershkrim = '', Koment = '', PromptDok = '', 
			          ISDOCFISCAL=CAST(0 AS BIT), FISSTATUS='', FISPROCES='', FISMENPAGESE='', FISTIPDOK='', FISKODOPERATOR='', FISBUSINESSUNIT='', 
					  FISTCR='', FISFIC='', FISEIC='', FISPDF='', FISUUID='', NRFISKALIZIM=0,
					  NrRendor = 0, DisplayValue = '', FieldValue = '', TipRow = '', TRow = CAST(0 AS BIT);
               RETURN;
             END;




-- 1.  ------------------------------------------------  Fature Shitje  ------------------------------------------------


      IF @TableName='FJ'
         BEGIN
		 PRINT 'AAAA'
                 IF OBJECT_ID('Tempdb..#TMP_FJ ') IS NOT NULL
                    DROP TABLE #TMP_FJ;

             SELECT A.*, M.Transportues, M.Mjet, M.Targe
			   INTO #TMP_FJ 
			   FROM FJ A LEFT JOIN FJSHOQERUES M ON A.NRRENDOR = M.NRD 
			  WHERE A.NRRENDOR=@NrRendor;


             SELECT A.NrOrder, A.Pershkrim, A.Koment,
                    PromptDok='Fature shitje Nr '+CONVERT(VARCHAR,B.NRDOK)+', date '+CONVERT(VARCHAR,B.DATEDOK,104),
                    B.ISDOCFISCAL,    B.FISSTATUS,	     B.FISPROCES, B.FISMENPAGESE, B.FISTIPDOK,
					B.FISKODOPERATOR, B.FISBUSINESSUNIT, B.FISTCR,    B.FISFIC,       B.FISEIC,    B.FISPDF, B.FISUUID, B.NRFISKALIZIM,
					B.NRRENDOR,
                    A.TipRow,A.TRow

               FROM

              (

			 SELECT NrOrder = '01', Pershkrim = 'Status'+Space(50),           Koment = CASE WHEN ISNULL(FISKALIZUAR,0)=1 
			                                                                                THEN 'Fiskalizuar' 
																				            ELSE 'Pa Fiskalizuar' 
																			           END +Space(@iLength), TipRow = 'B', TRow = CAST(1 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '02', Pershkrim = 'Dokument fiskal '+Space(50), Koment = CASE WHEN ISNULL(ISDOCFISCAL,0)=1 THEN 'Po' ELSE 'Jo' END +Space(@iLength), 
			                                                                                                 TipRow = 'B', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '03', Pershkrim = 'Status e-fatura ',           Koment = [FISSTATUS],          TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '04', Pershkrim = 'Procesi ',	                  Koment = [FISPROCES],          TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '05', Pershkrim = 'Menyra e pageses',	          Koment = [FISMENPAGESE],       TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '06', Pershkrim = 'Tipi dokumentit', 	          Koment = [FISTIPDOK],          TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '07', Pershkrim = 'Operatori ',	              Koment = [FISKODOPERATOR],     TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '08', Pershkrim = 'Njesi biznesi',	          Koment = [FISBUSINESSUNIT],    TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '09', Pershkrim = 'TCR ',	                      Koment = [FISTCR],             TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '10', Pershkrim = 'Dokument PDF ',              Koment = CASE WHEN LTRIM(RTRIM(ISNULL(FISPDF,'')))<>'' 
			                                                                                THEN 'Gjeneruar PDF' 
																					        ELSE 'Nuk ka' 
																			           END,                  TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
	         SELECT NrOrder = '11', Pershkrim = 'UUID ',                      Koment = CAST(LTRIM(RTRIM(ISNULL([FISUUID],'')))              AS Varchar(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ 

		  UNION ALL
			 SELECT NrOrder = '12', Pershkrim = 'NIVF ',	                  Koment = CAST(LTRIM(RTRIM(ISNULL([FISFIC],'')))               AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ

		  UNION ALL
		     SELECT NrOrder = '13', Pershkrim = 'QRCODELINK ',                Koment = CAST(LTRIM(RTRIM(ISNULL([FISQRCODELINK],'')))        AS VARCHAR(250)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ

		  UNION ALL
		     SELECT NrOrder = '14', Pershkrim = 'RELATEDFIC ',                Koment = CAST(LTRIM(RTRIM(ISNULL([FISRELATEDFIC],'')))        AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ

		  UNION ALL
		     SELECT NrOrder = '15', Pershkrim = 'EIC ',	                      Koment = CAST(LTRIM(RTRIM(ISNULL([FISEIC],'')))               AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ

		  UNION ALL
		     SELECT NrOrder = '16', Pershkrim = 'LASTERRORTEXTFIC ',          Koment = CAST(LTRIM(RTRIM(ISNULL([FISLASTERRORTEXTFIC],'')))  AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ

		  UNION ALL
		     SELECT NrOrder = '17', Pershkrim = 'LASTERRORTEXTEIC ',          Koment = CAST(LTRIM(RTRIM(ISNULL([FISLASTERRORTEXTEIC],'')))  AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ

          UNION ALL
             SELECT NrOrder = '18', Pershkrim = 'Transprtues: ',	          Koment = ISNULL(Transportues,'') + CASE WHEN ISNULL(Transportues,'')<>'' AND (ISNULL(Mjet,'')<>'' OR ISNULL(Targe,'')<>'') THEN ',  ' ELSE '' END+
				                                                                       ISNULL(Mjet,'')         + CASE WHEN ISNULL(Mjet,'')<>'' AND ISNULL(Targe,'')<>''	                                 THEN ',  ' ELSE '' END+
				                                                                       ISNULL(Targe,''),                                                      TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '19', Pershkrim = 'Nr fiskalizimi: ',	          Koment = CAST([NRFISKALIZIM] AS VARCHAR),                                       TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ


                    ) A,  FJ B 
		 
		      WHERE B.NRRENDOR=@NrRendor
           ORDER BY NrOrder

		   
         END;




-- 2.  ------------------------------------------------  Fature Blerje  ------------------------------------------------


      IF @TableName='FF'
         BEGIN

                 IF OBJECT_ID('Tempdb..#TMP_FF ') IS NOT NULL
                    DROP TABLE #TMP_FF;

             SELECT * INTO #TMP_FF FROM FF WHERE NRRENDOR=@NrRendor;


             SELECT A.NrOrder, A.Pershkrim, A.Koment,
                    PromptDok='Fature shitje Nr '+CONVERT(VARCHAR,B.NRDOK)+', date '+CONVERT(VARCHAR,B.DATEDOK,104),
                    B.ISDOCFISCAL,    B.FISSTATUS,	     B.FISPROCES, B.FISMENPAGESE, B.FISTIPDOK,
					B.FISKODOPERATOR, B.FISBUSINESSUNIT, B.FISTCR,    B.FISFIC,       B.FISEIC,    B.FISPDF, B.FISUUID,
					B.NRRENDOR,
                    A.TipRow,A.TRow

               FROM

              (

			 SELECT NrOrder = '01', Pershkrim = 'Status'+Space(50),           Koment = CASE WHEN ISNULL(FISKALIZUAR,0)=1 
			                                                                                THEN 'Fiskalizuar' 
																							ELSE 'Pa Fiskalizuar' 
																					   END +Space(@iLength), TipRow = 'B', TRow = CAST(1 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '02', Pershkrim = 'Dokument fiskal '+Space(50), Koment = CASE WHEN ISNULL(ISDOCFISCAL,0)=1 THEN 'Po' ELSE 'Jo' END +Space(@iLength), 
			                                                                                                 TipRow = 'B', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '03', Pershkrim = 'Status e-fatura ',           Koment = [FISSTATUS],          TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '04', Pershkrim = 'Procesi ',	                  Koment = [FISPROCES],          TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '05', Pershkrim = 'Menyra e pageses',	          Koment = [FISMENPAGESE],       TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '06', Pershkrim = 'Tipi dokumentit', 	          Koment = [FISTIPDOK],          TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '07', Pershkrim = 'Operatori ',	              Koment = [FISKODOPERATOR],     TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '08', Pershkrim = 'Njesi biznesi',	          Koment = [FISBUSINESSUNIT],    TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '09', Pershkrim = 'TCR ',	                      Koment = [FISTCR],             TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '10', Pershkrim = 'Dokument PDF ',              Koment = CASE WHEN LTRIM(RTRIM(ISNULL(FISPDF,'')))<>'' 
			                                                                                THEN 'Gjeneruar PDF' 
																					        ELSE 'Nuk ka' 
																			           END,                  TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
	         SELECT NrOrder = '11', Pershkrim = 'UUID ',                      Koment = CAST(LTRIM(RTRIM(ISNULL([FISUUID],'')))              AS Varchar(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF 

		  UNION ALL
			 SELECT NrOrder = '12', Pershkrim = 'NIVF ',	                  Koment = CAST(LTRIM(RTRIM(ISNULL([FISFIC],'')))               AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF

		  UNION ALL
		     SELECT NrOrder = '13', Pershkrim = 'QRCODELINK ',                Koment = CAST(LTRIM(RTRIM(ISNULL([FISQRCODELINK],'')))        AS VARCHAR(250)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF

		  UNION ALL
		     SELECT NrOrder = '14', Pershkrim = 'RELATEDFIC ',                Koment = CAST(LTRIM(RTRIM(ISNULL([FISRELATEDFIC],'')))        AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF

		  UNION ALL
		     SELECT NrOrder = '15', Pershkrim = 'EIC ',	                      Koment = CAST(LTRIM(RTRIM(ISNULL([FISEIC],'')))               AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF

		  UNION ALL
		     SELECT NrOrder = '16', Pershkrim = 'LASTERRORTEXTFIC ',          Koment = CAST(LTRIM(RTRIM(ISNULL([FISLASTERRORTEXTFIC],'')))  AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF

		  UNION ALL
		     SELECT NrOrder = '17', Pershkrim = 'LASTERRORTEXTEIC ',          Koment = CAST(LTRIM(RTRIM(ISNULL([FISLASTERRORTEXTEIC],'')))  AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF

          UNION ALL
             SELECT NrOrder = '18', Pershkrim = 'Nr fiskalizimi: ',	          Koment = CAST([NRFISKALIZIM] AS VARCHAR),                                       TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF


                    ) A,  FF B 
		 
		      WHERE B.NRRENDOR=@NrRendor
           ORDER BY NrOrder

		   
         END;




-- 3.  ------------------------------------------------  Flete Dalje  ------------------------------------------------


      IF @TableName='FD'
         BEGIN

                 IF OBJECT_ID('Tempdb..#TMP_FD ') IS NOT NULL
                    DROP TABLE #TMP_FD;


             SELECT A.*, M.Transportues, M.Mjet, M.Targe        --FISKALIZUAR, NRDOK, QRCODELINK, NIVFSH 
			   INTO #TMP_FD 
			   FROM FD A LEFT JOIN MGSHOQERUES M ON A.NRRENDOR = M.NRD 
			  WHERE A.NRRENDOR=@NrRendor;


             SELECT A.NrOrder, A.Pershkrim, A.Koment,
                    PromptDok='WTN Nr '+CONVERT(VARCHAR,B.NRDOK)+', date '+CONVERT(VARCHAR,B.DATEDOK,104)+', mag '+B.KMAG,
                    B.FISKALIZUAR, B.ISDOCFISCAL, B.FISKODOPERATOR, B.FISBUSINESSUNIT,
--			        B.FISSTATUS, B.FISPROCES, B.FISMENPAGESE, B.FISTIPDOK,B.FISTCR,B.FISFIC,B.FISEIC,B.FISPDF,B.FISUUID,
				    B.NRRENDOR,  A.TipRow,    A.TRow

               FROM

              (

             SELECT NrOrder = '01', Pershkrim = 'Status'+Space(50),           Koment = CASE WHEN ISNULL(FISKALIZUAR,0)=1 
			                                                                                THEN 'Fiskalizuar' 
																						    ELSE 'Pa Fiskalizuar' 
																					   END +Space(@iLength),                                        TipRow = 'B', TRow = CAST(1 AS BIT) FROM #TMP_FD
          UNION ALL
		     SELECT NrOrder = '02', Pershkrim = 'QRCODELINK ',                Koment = CAST(LTRIM(RTRIM(ISNULL([QRCODELINK],''))) AS VARCHAR(250)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD

		  UNION ALL
	         SELECT NrOrder = '03', Pershkrim = 'NIVFSH ',                    Koment = CAST(LTRIM(RTRIM(ISNULL(NIVFSH,''))) AS VARCHAR(150)),       TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD

		  UNION ALL
             SELECT NrOrder = '04', Pershkrim = 'Dokument fiskal '+Space(50), Koment = CASE WHEN ISNULL(ISDOCFISCAL,0)=1 THEN 'Po' ELSE 'Jo' END +Space(@iLength),
			                                                                                                                                        TipRow = 'B', TRow = CAST(0 AS BIT) FROM #TMP_FD
          UNION ALL
             SELECT NrOrder = '05', Pershkrim = 'Status fiskalizimi ',        Koment = [FISSTATUS],                                                 TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD
          UNION ALL
             SELECT NrOrder = '06', Pershkrim = 'Procesi ',	                  Koment = [FISPROCES],                                                 TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD
          UNION ALL
             SELECT NrOrder = '07', Pershkrim = 'Tipi dokumentit', 	          Koment = [FISTIPDOK],                                                 TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD
          UNION ALL
             SELECT NrOrder = '08', Pershkrim = 'Operatori ',	              Koment = [FISKODOPERATOR],                                            TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD
          UNION ALL
             SELECT NrOrder = '09', Pershkrim = 'Njesi biznesi',	          Koment = [FISBUSINESSUNIT],                                           TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD

          UNION ALL
             SELECT NrOrder = '10', Pershkrim = 'Transprtues: ',	          Koment = ISNULL(Transportues,'') + CASE WHEN ISNULL(Transportues,'')<>'' AND (ISNULL(Mjet,'')<>'' OR ISNULL(Targe,'')<>'') THEN ',  ' ELSE '' END+
				                                                                       ISNULL(Mjet,'')         + CASE WHEN ISNULL(Mjet,'')<>'' AND ISNULL(Targe,'')<>''	                                 THEN ',  ' ELSE '' END+
				                                                                       ISNULL(Targe,''),                                            TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD
          UNION ALL
             SELECT NrOrder = '11', Pershkrim = 'Nr fiskalizimi: ',	          Koment = CAST([NRFISKALIZIM] AS VARCHAR),                             TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD


                    ) A,  FD B 

		      WHERE B.NRRENDOR=@NrRendor

           ORDER BY NrOrder


         END;




-- 4.  ------------------------------------------------  Pike Shitje  ------------------------------------------------

	 
      IF @TableName='SM'
         BEGIN
	
                 IF OBJECT_ID('Tempdb..#TMP_SM ') IS NOT NULL
                    DROP TABLE #TMP_SM;


             SELECT A.* INTO #TMP_SM FROM SM A WHERE A.NRRENDOR=@NrRendor;


             SELECT A.NrOrder, A.Pershkrim, A.Koment,
                    PromptDok='Pike shitje Nr '+CONVERT(VARCHAR,B.NRDOK)+', date '+CONVERT(VARCHAR,B.DATEDOK,104)+', kasa '+ISNULL(B.KASE,''),
                    B.FISKALIZUAR, B.ISDOCFISCAL, B.FISPROCES, B.FISMENPAGESE, B.FISTIPDOK, B.FISKODOPERATOR, B.FISBUSINESSUNIT,B.NRFISKALIZIM,
			     -- B.FISSTATUS, B.FISTCR,B.FISFIC,B.FISEIC,B.FISPDF,B.FISUUID,
                    B.FISQRCODELINK,
				    B.NRRENDOR,  A.TipRow,    A.TRow

               FROM

              (

             SELECT NrOrder = '01', Pershkrim = 'Status'+Space(50),           Koment = CASE WHEN ISNULL(FISKALIZUAR,0)=1 THEN 'Fiskalizuar' ELSE 'Pa Fiskalizuar' END +Space(@iLength),
	                                                                                                                                                   TipRow = 'B', TRow = CAST(1 AS BIT) FROM #TMP_SM
          UNION ALL
		     SELECT NrOrder = '02', Pershkrim = 'QRCODELINK ',                Koment = CAST(LTRIM(RTRIM(ISNULL([FISQRCODELINK],''))) AS VARCHAR(250)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM
		  UNION ALL
             SELECT NrOrder = '03', Pershkrim = 'Dokument fiskal '+Space(50), Koment = CASE WHEN ISNULL(ISDOCFISCAL,0)=1 THEN 'Po' ELSE 'Jo' END +Space(@iLength),
			                                                                                                                                           TipRow = 'B', TRow = CAST(0 AS BIT) FROM #TMP_SM
          UNION ALL
             SELECT NrOrder = '04', Pershkrim = 'Procesi ',	                  Koment = [FISPROCES],                                                    TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM
          UNION ALL
             SELECT NrOrder = '05', Pershkrim = 'Tipi dokumentit', 	          Koment = [FISTIPDOK],                                                    TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM
          UNION ALL
             SELECT NrOrder = '06', Pershkrim = 'Operatori ',	              Koment = [FISKODOPERATOR],                                               TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM
          UNION ALL
             SELECT NrOrder = '07', Pershkrim = 'Njesi biznesi',	          Koment = [FISBUSINESSUNIT],                                              TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM
          UNION ALL
             SELECT NrOrder = '08', Pershkrim = 'Nr fiskalizimi: ',	          Koment = CAST([NRFISKALIZIM] AS VARCHAR),                                TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM

          
                    ) A,  SM B 

		      WHERE B.NRRENDOR=@NrRendor

           ORDER BY NrOrder


         END;
GO
