SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




--     EXEC Isd_ShkarkimProdukt 'H',13041;
--     Kujdes ka ndryshime me dy procedura nga Erialdi (Shiko komentet me fjalen: Eriald)

--     Kujdes - Shiko me poshte tek shenimi:  -- Tek EHW duhet GJENROWAUTPRD=0 ndryshimi u be 21.05.2020

--     Kujdes - Per rastin kur behet shkarkimi i lendeve te para sipas dep/liste te produktit. Shiko shenimin 24.07.2020

CREATE         Procedure [dbo].[Isd_ShkarkimProdukt]
(
  @Tip        VARCHAR(10),
  @PNrRendor  INT 
 )
AS

         SET NOCOUNT ON

     DECLARE @Sgn            INT,
             @ShkarkimPg     BIT,
             @DokJB          BIT,
             @CmCalcul       BIT,
             @GrupMg         VARCHAR(10),
             @TableMgScr     VARCHAR(30),
             @Decimal        Int;

         SET @ShkarkimPg   = 1; 
         SET @DokJB        = 0;  
         SET @Sgn          = 1;
         SET @CmCalcul     = 0;
         SET @TableMgScr   = 'F'+@Tip+'SCR';
         SET @Decimal      = 7;



		  IF @Tip='H'
             BEGIN
             
			    SELECT @DokJB    = ISNULL(DOK_JB,0),
				       @GrupMg   = (SELECT CASE WHEN CHARINDEX(LEFT(LTRIM(RTRIM(ISNULL(GRUP,'A'))),1),'ABCDEFGHIJ')>0 
										        THEN           LEFT(LTRIM(RTRIM(ISNULL(GRUP,'A'))),1) 
										        ELSE 'A' 
										   END 
								      FROM MAGAZINA B
							         WHERE B.KOD=A.KMAG),
                       @CmCalcul = CMPRODCALCUL
			      FROM FH A
			     WHERE NRRENDOR=@PNrRendor 
             END
             
		 ELSE
		 
             BEGIN
			    SELECT @DokJB    = ISNULL(DOK_JB,0),
				       @GrupMg   = (SELECT CASE WHEN CHARINDEX(LEFT(LTRIM(RTRIM(ISNULL(GRUP,'A'))),1),'ABCDEFGHIJ')>0 
										        THEN           LEFT(LTRIM(RTRIM(ISNULL(GRUP,'A'))),1) 
										        ELSE 'A' 
										   END 
								      FROM MAGAZINA B
							         WHERE B.KOD=A.KMAG)
			      FROM FD A
			     WHERE NRRENDOR=@PNrRendor 
             END;



          IF @DokJB = 0                -- @Tip='H' 
             SELECT @Sgn = -1,    @ShkarkimPg = 0;


          IF @Tip<>'H'
             SELECT @Sgn = 1;          --, @ShkarkimPg = 0 





-- AutoShkarkim      


          IF @Tip='H' 

             BEGIN
              
               IF  @DokJB=1
                
                   RETURN

               ELSE

               IF (SELECT ISNULL(COUNT(''),0)  
                     FROM FHSCR A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD 
                    WHERE A.NRD=@PNrRendor AND B.TIP='P')<=0

                   RETURN

             END


          ELSE


          IF @DokJB=0 

             BEGIN
             
			   IF (SELECT ISNULL(COUNT(''),0)  
				     FROM FDSCR A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD 
				    WHERE A.NRD=@PNrRendor AND B.TIP='P' AND B.AUTOSHKLPFDBR=1)<=0

				   RETURN
				   
			 END
			 

          ELSE
          

             BEGIN
             
               IF (SELECT ISNULL(COUNT(''),0)  
                     FROM FDSCR A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD 
                    WHERE A.NRD=@PNrRendor AND B.TIP='P' AND B.AUTOSHKLPFJ=1)<=0

                   RETURN

             END;





-- 1. Inicializim Variabla dhe struktura

      SELECT * INTO #PrdScr FROM FHSCR WHERE 1=2;





-- 2. Fshihen ato qe sjane Produkt per rastin e Levizjeve te brendeshme....

          IF @DokJB=0                        -- AND @Tip='H'   -- Dalje ?????
             BEGIN
             
               IF @Tip='H'

                  BEGIN
                    DELETE A
                      FROM FHSCR A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD 
                     WHERE A.NRD=@PNrRendor AND TIP<>'P' --AND ISNULL(A.GJENROWAUT,0)=0 
                  END

                  
               ELSE           --             1.1 Eriald Fillim

                 BEGIN
                   DELETE A
                     FROM FDSCR A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD 
                    WHERE A.NRD=@PNrRendor AND TIP<>'P' AND ISNULL(A.GJENROWAUT,0)=1 
                 END
                 
                              --             1.2 Eriald Fund

             END;





-- 3.  Krijimi i tabeles Temporare


-- 3.1 Produktet

  
	 	  IF @Tip='H' AND @DokJB=0
 
			 INSERT INTO #PrdScr
				   (A.KOD,   A.KODAF, A.KARTLLG, NRRENDKLLG,   A.PERSHKRIM, A.NJESI, 
				    VLERAFT, SASI,    VLERAM,    CMIMM, KMON,  CMIMOR,      VLERAOR, CMIMBS, VLERABS, 
				    KOEFSHB, NJESINV, TIPKLL,    SASIKONV,     GJENROWAUT,  A.TROW,  TAGNR,  SERI, DTSKADENCE) 

			 SELECT A.KOD,   A.KODAF, A.KARTLLG, NRRENDKLLG,   A.PERSHKRIM, A.NJESI, 
				    VLERAFT, SASI,    VLERAM,    CMIMM, KMON,  CMIMOR,      VLERAOR, CMIMBS, VLERABS, 
				    KOEFSHB, NJESINV, TIPKLL,    SASIKONV,     0,           0,     	 
				    TAGNR = CASE WHEN TIP='P' THEN 100 ELSE 0 END,                           SERI, DTSKADENCE
			   FROM FHSCR A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD 
			  WHERE A.NRD=@PNrRendor AND TIP='P'  AND ISNULL(A.GJENROWAUT,0)=0 


		  ELSE


          IF @DokJB=0

			 INSERT INTO #PrdScr
				   (A.KOD,   A.KODAF, A.KARTLLG, NRRENDKLLG,   A.PERSHKRIM, A.NJESI, 
				    VLERAFT, SASI,    VLERAM,    CMIMM, KMON,  CMIMOR,      VLERAOR, CMIMBS, VLERABS, 
				    KOEFSHB, NJESINV, TIPKLL,    SASIKONV,     GJENROWAUT,  A.TROW,  TAGNR,  SERI, DTSKADENCE) 

			 SELECT A.KOD,   A.KODAF, A.KARTLLG, NRRENDKLLG,   A.PERSHKRIM, A.NJESI, 
				    VLERAFT, SASI,    VLERAM,    CMIMM, KMON,  CMIMOR,      VLERAOR, CMIMBS, VLERABS, 
				    KOEFSHB, NJESINV, TIPKLL,    SASIKONV,     0,           0,     	 
				    TAGNR = CASE WHEN TIP='P' THEN 100 ELSE 0 END,                           SERI, DTSKADENCE
			   FROM FDSCR A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD 
			  WHERE A.NRD=@PNrRendor AND TIP='P'  AND ISNULL(A.GJENROWAUT,0)=0 


          ELSE


			 INSERT INTO #PrdScr
				   (A.KOD,   A.KODAF, A.KARTLLG, NRRENDKLLG,   A.PERSHKRIM, A.NJESI, 
				    VLERAFT, SASI,    VLERAM,    CMIMM, KMON,  CMIMOR,      VLERAOR, CMIMBS, VLERABS, 
				    KOEFSHB, NJESINV, TIPKLL,    SASIKONV,     GJENROWAUT,  A.TROW,  TAGNR,  SERI, DTSKADENCE) 

			 SELECT A.KOD,   A.KODAF, A.KARTLLG, NRRENDKLLG,   A.PERSHKRIM, A.NJESI, 
				    VLERAFT, SASI,    VLERAM,    CMIMM, KMON,  CMIMOR,      VLERAOR, CMIMBS, VLERABS, 
				    KOEFSHB, NJESINV, TIPKLL,    SASIKONV,     0,           1,    	 
				    TAGNR = CASE WHEN TIP='P' THEN 100 ELSE 0 END,                           SERI, DTSKADENCE
			   FROM FDSCR A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD 
			  WHERE A.NRD=@PNrRendor AND TIP='P' AND B.AUTOSHKLPFJ=1;





-- 3.2 Perberesit e produkteve (PARA DATES 24.07.2020 ISHTE SITUATE TJETER QE ESHTE KOMENTUAR ME POSHTE)

-- Shkarkon lendet e para ose ndihmese ne menyre analitike sipas Dep/Liste te produktit


          IF @Tip='H'			             -- Rasti FH

             BEGIN
             
                 INSERT INTO #PrdScr         
                       (KOD, KODAF, KARTLLG, PERSHKRIM, KOMENT, SASI, VLERAM, SASIKONV, GJENROWAUT, TROW, TAGNR)      

                 SELECT KOD        = dbo.Isd_SegmentNewInsert(B.KOD,C.KOD,2),  --MIN(A.KMAG)+'.'+C.KOD+C.QKOSTO+'.',   -- C.KOD + CASE WHEN C.QKOSTO='.' OR C.QKOSTO='..' THEN '' ELSE C.QKOSTO END,           
                        KODAF      = dbo.Isd_SegmentNewInsert(B.KODAF,C.KOD,1),--C.KOD + MAX(C.QKODAF),           
                        KARTLLG    = C.KOD, 
                        PERSHKRIM  = MIN(C.PERSHKRIM), 
                        KOMENT     = MAX(CASE WHEN ISNULL(B.KARTLLG,'')<>''  THEN 'Shkarkim per '+ISNULL(B.KARTLLG,'')                  ELSE '' END+
                                         CASE WHEN ISNULL(C.KOEFICIENT,0)<>0 THEN ', koeficent ' +CONVERT(VARCHAR(20),C.KOEFICIENT,128) ELSE '' END),
                        SASIRE     = @Sgn * ROUND(CASE WHEN SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) =0 THEN 0.001 ELSE SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) END,@Decimal),
                        VLERARE    = @Sgn * ROUND(CASE WHEN SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) =0 THEN 0.001 ELSE SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) END * MIN(C.KOSTMES),@Decimal), 
                        SASIKONV   = @Sgn * 0, --ROUND(SUM(ISNULL(SASIKONV,0)),@Decimal),
                        GJENROWAUT = 1,
                        TAGNR      = 0,
                        TAGNR      = 10
                   FROM FH A LEFT JOIN FHSCR B       ON A.NRRENDOR=B.NRD
                             LEFT JOIN QARTIKUJSCR C ON B.KARTLLG =C.KODPR  
                  WHERE A.NRRENDOR=@PNrRendor AND ISNULL(B.GJENROWAUT,0)=0 
               GROUP BY B.KOD,B.KODAF,C.KOD   
                 HAVING ROUND(SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB),@Decimal)<>0 

             END


          ELSE


          IF @Tip='D' AND @DokJB=1           -- Rasti FD nga Fatura

             BEGIN

                 INSERT INTO #PrdScr         
                       (KOD, KODAF, KARTLLG, PERSHKRIM, KOMENT, SASI, VLERAM, SASIKONV, GJENROWAUT, TROW, TAGNR)      

                 SELECT KOD        = dbo.Isd_SegmentNewInsert(B.KOD,C.KOD,2),  --MIN(A.KMAG)+'.'+C.KOD+C.QKOSTO+'.',   -- C.KOD + CASE WHEN C.QKOSTO='.' OR C.QKOSTO='..' THEN '' ELSE C.QKOSTO END,           
                        KODAF      = dbo.Isd_SegmentNewInsert(B.KODAF,C.KOD,1),--C.KOD + MAX(C.QKODAF),           
                        KARTLLG    = C.KOD,  
                        PERSHKRIM  = MIN(C.PERSHKRIM), 
                        KOMENT     = MAX(CASE WHEN ISNULL(B.KARTLLG,'')<>''  THEN 'Shkarkim per '+ISNULL(B.KARTLLG,'')                  ELSE '' END +
                                         CASE WHEN ISNULL(C.KOEFICIENT,0)<>0 THEN ', koeficent ' +CONVERT(VARCHAR(20),C.KOEFICIENT,128) ELSE '' END),
                        SASIRE     = @Sgn * ROUND(CASE WHEN SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) =0 THEN 0 ELSE SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) END,@Decimal),
                        VLERARE    = @Sgn * ROUND(CASE WHEN SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) =0 THEN 0 ELSE SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) END * MIN(C.KOSTMES),@Decimal), 
                        SASIKONV   = @Sgn * 0, --ROUND(SUM(ISNULL(SASIKONV,0)),@Decimal),
                        GJENROWAUT = 1,
                        TAGNR      = 0,
                        TROW       = 10
                   FROM FD A LEFT JOIN FDSCR B       ON A.NRRENDOR=B.NRD
                             LEFT JOIN QARTIKUJSCR C ON B.KARTLLG =C.KODPR
                  WHERE A.NRRENDOR=@PNrRendor AND ISNULL(B.GJENROWAUT,0)=0 AND C.AUTOSHKLPFJ=1 -- AND C.AUTOSHKLPFDBR=1
               GROUP BY B.KOD,B.KODAF,C.KOD
                 HAVING ROUND(SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB),@Decimal)<>0 


             END

          ELSE


          IF @Tip='D'                         -- Rasti FD brendeshme

             BEGIN
             
                 INSERT INTO #PrdScr         
                       (KOD, KODAF, KARTLLG, PERSHKRIM, KOMENT, SASI, VLERAM, SASIKONV, GJENROWAUT, TROW, TAGNR)      

                 SELECT KOD        = dbo.Isd_SegmentNewInsert(B.KOD,C.KOD,2),  --MIN(A.KMAG)+'.'+C.KOD+C.QKOSTO+'.',   -- C.KOD + CASE WHEN C.QKOSTO='.' OR C.QKOSTO='..' THEN '' ELSE C.QKOSTO END,
                        KODAF      = dbo.Isd_SegmentNewInsert(B.KODAF,C.KOD,1),--C.KOD + MAX(C.QKODAF),           
                        KARTLLG    = C.KOD, 
                        PERSHKRIM  = MIN(C.PERSHKRIM), --+' '+LTRIM(RTRIM(STR(C.KOEFICIENT,20,3)))
                        KOMENT     = MAX(CASE WHEN ISNULL(B.KARTLLG,'')<>''  THEN 'Shkarkim per '+ISNULL(B.KARTLLG,'')                  ELSE '' END +
                                         CASE WHEN ISNULL(C.KOEFICIENT,0)<>0 THEN ', koeficent ' +CONVERT(VARCHAR(20),C.KOEFICIENT,128) ELSE '' END),
                        SASIRE     = @Sgn * ROUND(CASE WHEN SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) =0 THEN 0.001 ELSE SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) END,@Decimal),
                        VLERARE    = @Sgn * ROUND(CASE WHEN SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) =0 THEN 0.001 ELSE SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) END * MIN(C.KOSTMES),@Decimal), 
                        SASIKONV   = @Sgn * 0, --ROUND(SUM(ISNULL(SASIKONV,0)),@Decimal),
                        GJENROWAUT = 1,
                        TROW       = 0,
                        TAGNR      = 10
                   FROM FD A LEFT JOIN FDSCR B       ON A.NRRENDOR=B.NRD
                             LEFT JOIN QARTIKUJSCR C ON B.KARTLLG =C.KODPR
                  WHERE A.NRRENDOR=@PNrRendor AND ISNULL(B.GJENROWAUT,0)=0 AND C.AUTOSHKLPFDBR=1
               GROUP BY B.KOD,B.KODAF,C.KOD--,C.QKOSTO   
                 HAVING ROUND(SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB),@Decimal)<>0 
 

--             2. Eriald Fillim

			     INSERT INTO #PrdScr
				       (KOD,       KODAF,     KARTLLG,   NRRENDKLLG,    PERSHKRIM,  NJESI, 
				        VLERAFT,   SASI,      VLERAM,    CMIMM,         KMON,       CMIMOR,   VLERAOR,    CMIMBS,   VLERABS, 
				        KOEFSHB,   NJESINV,   TIPKLL,    SASIKONV,      GJENROWAUT, TROW,     TAGNR) 
				        
			     SELECT A.KOD,     A.KODAF,   A.KARTLLG, A.NRRENDKLLG,  A.PERSHKRIM, A.NJESI, 
				        A.VLERAFT, A.SASI,    A.VLERAM,  A.CMIMM,       A.KMON,      A.CMIMOR, A.VLERAOR, A.CMIMBS, A.VLERABS, 
				        A.KOEFSHB, A.NJESINV, A.TIPKLL,  A.SASIKONV,    0,           0,        TAGNR = CASE WHEN B.TIP='P' THEN 100 ELSE 0 END
			       FROM FDSCR A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD 
			      WHERE A.NRD=@PNrRendor AND TIP='M'

--             2. Eriald Fund

             END;
             

/*  

// SITUATA DERI DATEN 24.07.2020 e cila u zevendesua nga procedura me siper. 
// Shkarkon lendet e para ose ndihmese ne menyre analitike sipas Dep/Liste te produktit


-- 3.2 Perberesit e produkteve

          IF @Tip='H'			             -- Rasti FH

             BEGIN
             
                 INSERT INTO #PrdScr         
                       (KOD, KODAF, KARTLLG, PERSHKRIM, SASI, VLERAM, SASIKONV, GJENROWAUT, TROW, TAGNR)      

                 SELECT KOD        = MIN(A.KMAG)+'.'+C.KOD+C.QKOSTO+'.',   -- C.KOD + CASE WHEN C.QKOSTO='.' OR C.QKOSTO='..' THEN '' ELSE C.QKOSTO END,           
                        KODAF      = C.KOD + MAX(C.QKODAF),           
                        KARTLLG    = C.KOD, 
                        PERSHKRIM  = MIN(C.PERSHKRIM), 
                        SASIRE     = @Sgn * ROUND(CASE WHEN SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) =0 THEN 0.001 ELSE SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) END,@Decimal),
                        VLERARE    = @Sgn * ROUND(CASE WHEN SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) =0 THEN 0.001 ELSE SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) END * MIN(C.KOSTMES),@Decimal), 
                        SASIKONV   = @Sgn * 0, --ROUND(SUM(ISNULL(SASIKONV,0)),@Decimal),
                        GJENROWAUT = 1,
                        TAGNR      = 0,
                        TAGNR      = 10
                   FROM FH A LEFT JOIN FHSCR B       ON A.NRRENDOR=B.NRD
                             LEFT JOIN QARTIKUJSCR C ON B.KARTLLG =C.KODPR  
                  WHERE A.NRRENDOR=@PNrRendor AND ISNULL(B.GJENROWAUT,0)=0 
               GROUP BY C.KOD,C.QKOSTO   
                 HAVING ROUND(SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB),@Decimal)<>0 

             END


          ELSE


          IF @Tip='D' AND @DokJB=1           -- Rasti FD nga Fatura

             BEGIN

                 INSERT INTO #PrdScr         
                       (KOD, KODAF, KARTLLG, PERSHKRIM, SASI, VLERAM, SASIKONV, GJENROWAUT, TROW, TAGNR)      

                 SELECT KOD        = MIN(A.KMAG)+'.'+C.KOD+C.QKOSTO+'.',   -- C.KOD + CASE WHEN C.QKOSTO='.' OR C.QKOSTO='..' THEN '' ELSE C.QKOSTO END,           
                        KODAF      = C.KOD + MAX(C.QKODAF),           
                        KARTLLG    = C.KOD,  
                        PERSHKRIM  = MIN(C.PERSHKRIM), 
                        SASIRE     = @Sgn * ROUND(CASE WHEN SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) =0 THEN 0 ELSE SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) END,@Decimal),
                        VLERARE    = @Sgn * ROUND(CASE WHEN SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) =0 THEN 0 ELSE SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) END * MIN(C.KOSTMES),@Decimal), 
                        SASIKONV   = @Sgn * 0, --ROUND(SUM(ISNULL(SASIKONV,0)),@Decimal),
                        GJENROWAUT = 1,
                        TAGNR      = 0,
                        TROW       = 10
                   FROM FD A LEFT JOIN FDSCR B       ON A.NRRENDOR=B.NRD
                             LEFT JOIN QARTIKUJSCR C ON B.KARTLLG =C.KODPR
                  WHERE A.NRRENDOR=@PNrRendor AND ISNULL(B.GJENROWAUT,0)=0 AND C.AUTOSHKLPFJ=1 -- AND C.AUTOSHKLPFDBR=1
               GROUP BY C.KOD,C.QKOSTO   
                 HAVING ROUND(SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB),@Decimal)<>0 



             END

          ELSE


          IF @Tip='D'                         -- Rasti FD brendeshme

             BEGIN
             
                 INSERT INTO #PrdScr         
                       (KOD, KODAF, KARTLLG, PERSHKRIM, SASI, VLERAM, SASIKONV, GJENROWAUT, TROW, TAGNR)      

                 SELECT KOD        = MIN(A.KMAG)+'.'+C.KOD+C.QKOSTO+'.',   -- C.KOD + CASE WHEN C.QKOSTO='.' OR C.QKOSTO='..' THEN '' ELSE C.QKOSTO END,
                        KODAF      = C.KOD + MAX(C.QKODAF),           
                        KARTLLG    = C.KOD, 
                        PERSHKRIM  = MIN(C.PERSHKRIM), 
                        SASIRE     = @Sgn * ROUND(CASE WHEN SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) =0 THEN 0.001 ELSE SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) END,@Decimal),
                        VLERARE    = @Sgn * ROUND(CASE WHEN SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) =0 THEN 0.001 ELSE SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) END * MIN(C.KOSTMES),@Decimal), 
                        SASIKONV   = @Sgn * 0, --ROUND(SUM(ISNULL(SASIKONV,0)),@Decimal),
                        GJENROWAUT = 1,
                        TROW       = 0,
                        TAGNR      = 10
                   FROM FD A LEFT JOIN FDSCR B       ON A.NRRENDOR=B.NRD
                             LEFT JOIN QARTIKUJSCR C ON B.KARTLLG =C.KODPR
                  WHERE A.NRRENDOR=@PNrRendor AND ISNULL(B.GJENROWAUT,0)=0 AND C.AUTOSHKLPFDBR=1
               GROUP BY C.KOD,C.QKOSTO   
                 HAVING ROUND(SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB),@Decimal)<>0 


--             2. Eriald Fillim

			     INSERT INTO #PrdScr
				       (A.KOD, A.KODAF,  A.KARTLLG, NRRENDKLLG,  A.PERSHKRIM, A.NJESI, 
				        VLERAFT, SASI,    VLERAM,   CMIMM,       KMON,        CMIMOR,  VLERAOR, CMIMBS, VLERABS, 
				        KOEFSHB, NJESINV, TIPKLL,   SASIKONV,    GJENROWAUT,  A.TROW,  TAGNR) 
				        
			     SELECT A.KOD, A.KODAF,  A.KARTLLG, NRRENDKLLG,  A.PERSHKRIM, A.NJESI, 
				        VLERAFT, SASI,    VLERAM,   CMIMM,       KMON,        CMIMOR,  VLERAOR, CMIMBS, VLERABS, 
				        KOEFSHB, NJESINV, TIPKLL,   SASIKONV,    0,           0,       TAGNR = CASE WHEN TIP='P' THEN 100 ELSE 0 END
			       FROM FDSCR A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD 
			      WHERE A.NRD=@PNrRendor AND TIP='M'

--             2. Eriald Fund

             END;

   


*/



   



      UPDATE #PrdScr
      
         SET CMIMM     = CASE WHEN VLERAM*SASI<=0 THEN 0 ELSE VLERAM/SASI END, 
             CMIMOR    = CASE WHEN VLERAM*SASI<=0 THEN 0 ELSE VLERAM/SASI END,
             VLERAOR   = VLERAM, 
             CMIMBS    = CASE WHEN VLERAM*SASI<=0 THEN 0 ELSE VLERAM/SASI END, 
             VLERABS   = VLERAM

       WHERE TAGNR=10;





-- 3.3 Produkt i Rivleresuar ne Cmim 
-- Me Konfigurim ne ConfigMG
-- Me mire te konfigurohet ne dokument sepse ka kerkesa te ndryshme sipas magazinave..


          IF @CmCalcul=1     -- IF (SELECT ISNULL(ISAPLEHW,0) FROM CONFND) = 0
             BEGIN
             
               UPDATE A       --Ndryshuar nga Genti 09/01/2012 per Aiba
                  SET VLERAM = (  SELECT ROUND(SUM((C.KOEFICIENT*C.KOSTMES*B.SASI)/C.KOEFICPERB),@Decimal)
                                    FROM #PrdScr B INNER JOIN QARTIKUJSCR C ON B.KARTLLG = C.KODPR
                                   WHERE B.KARTLLG=A.KARTLLG
                                GROUP BY B.KARTLLG
                                  HAVING ROUND(SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB),@Decimal)<>0
                                )

                 FROM #PrdScr A -- INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD  
                WHERE A.TAGNR=100
                
             END;





-- 3.4 Shkarkim i vete Produkteve Ne se duhet te shkarkohen dhe vete produkti
 
          IF @Tip='D' 
	         BEGIN
	         
	           IF @ShkarkimPg=0
                  BEGIN

                    INSERT INTO #PrdScr
                          (NRD,        KOD,        KODAF,     KARTLLG,    NRRENDKLLG, PERSHKRIM,   NJESI,      KMON,  
                           SASI,       VLERAM,     CMIMM,     VLERAOR,    CMIMOR,
                           VLERAFT,    CMIMBS,     VLERABS,   KOEFSHB,    NJESINV,    TIPKLL,      SASIKONV,   GJENROWAUT, TROW)     

                    SELECT @PNrRendor, A.KOD,      A.KODAF,   A.KARTLLG,  A.NRRENDOR, A.PERSHKRIM, A.NJESI,    A.KMON, 
                           0-A.SASI,   0-A.VLERAM, CMIMM,     0-A.VLERAM, CMIMM, 
                           VLERAFT,    CMIMBS,     0-VLERABS, KOEFSHB,    NJESINV,    TIPKLL,      0-SASIKONV, 1,          0
                      FROM #PrdScr A
                     WHERE A.TAGNR=100 

                  END

             END;

          IF @ShkarkimPg=1

             BEGIN

               INSERT INTO #PrdScr
                     (NRD,        KOD,        KODAF,     KARTLLG,    NRRENDKLLG, PERSHKRIM,   NJESI,      KMON,  
                      SASI,       VLERAM,     CMIMM,     VLERAOR,    CMIMOR,
                      VLERAFT,    CMIMBS,     VLERABS,   KOEFSHB,    NJESINV,    TIPKLL,      SASIKONV,   GJENROWAUT, GJENROWAUTPRD, TROW)     

               SELECT @PNrRendor, A.KOD,      A.KODAF,   A.KARTLLG,  A.NRRENDOR, A.PERSHKRIM, A.NJESI,    A.KMON, 
                      0-A.SASI,   0-A.VLERAM, CMIMM,     0-A.VLERAM, CMIMM, 
                      VLERAFT,    CMIMBS,     0-VLERABS, KOEFSHB,    NJESINV,    TIPKLL,      0-SASIKONV, 1,          1,             0
                 FROM #PrdScr A                                                                               -- Tek EHW duhet GJENROWAUTPRD=0 ndryshimi u be 21.05.2020
                WHERE A.TAGNR=100 

             END;
             

   

             
-- 3.5 Update te ndryshme

      UPDATE A 
         SET A.NRD        = @PNrRendor,
             A.NRRENDKLLG = B.NRRENDOR,
             A.KONVERTART = ISNULL(KONV2,1) / CASE WHEN ISNULL(KONV1,1)=0 THEN 1 ELSE ISNULL(KONV1,1) END, 
             A.CMIMM      = ROUND(CASE WHEN VLERAM*SASI>0 THEN VLERAM/SASI ELSE 1 END,3),
             A.NJESI      = B.NJESI,
             A.NJESINV    = B.NJESI,
             A.TIPKLL     = 'K',
             A.KMON       = '',
             A.KOEFSHB    = 1,
             CMIMSH       = CASE WHEN @GrupMg='' or @GrupMg='A' THEN CMSH
                                 WHEN @GrupMg='B' THEN CMSH1 
                                 WHEN @GrupMg='C' THEN CMSH2 
                                 WHEN @GrupMg='D' THEN CMSH3 
                                 WHEN @GrupMg='E' THEN CMSH4 
                                 WHEN @GrupMg='F' THEN CMSH5 
                                 WHEN @GrupMg='G' THEN CMSH6 
                                 WHEN @GrupMg='H' THEN CMSH7 
                                 WHEN @GrupMg='I' THEN CMSH8 
                                 WHEN @GrupMg='J' THEN CMSH9 
                                 WHEN @GrupMg='K' THEN CMSH10 
                                 WHEN @GrupMg='L' THEN CMSH11 
                                 WHEN @GrupMg='M' THEN CMSH12 
                                 WHEN @GrupMg='N' THEN CMSH13 
                                 WHEN @GrupMg='O' THEN CMSH14 
                                 WHEN @GrupMg='P' THEN CMSH15 
                                 WHEN @GrupMg='Q' THEN CMSH16 
                                 WHEN @GrupMg='R' THEN CMSH17 
                                 WHEN @GrupMg='S' THEN CMSH18 
                                 WHEN @GrupMg='T' THEN CMSH19 
                                 ELSE                  CMSH 
                            END,

             VLERASH      = ROUND(SASI * CASE WHEN @GrupMg='' or @GrupMg='A' THEN CMSH
                                              WHEN @GrupMg='B' THEN CMSH1 
                                              WHEN @GrupMg='C' THEN CMSH2 
                                              WHEN @GrupMg='D' THEN CMSH3 
                                              WHEN @GrupMg='E' THEN CMSH4 
                                              WHEN @GrupMg='F' THEN CMSH5 
                                              WHEN @GrupMg='G' THEN CMSH6 
                                              WHEN @GrupMg='H' THEN CMSH7 
                                              WHEN @GrupMg='I' THEN CMSH8 
                                              WHEN @GrupMg='J' THEN CMSH9 
                                              WHEN @GrupMg='K' THEN CMSH10 
                                              WHEN @GrupMg='L' THEN CMSH11 
                                              WHEN @GrupMg='M' THEN CMSH12 
                                              WHEN @GrupMg='N' THEN CMSH13 
                                              WHEN @GrupMg='O' THEN CMSH14 
                                              WHEN @GrupMg='P' THEN CMSH15 
                                              WHEN @GrupMg='Q' THEN CMSH16 
                                              WHEN @GrupMg='R' THEN CMSH17 
                                              WHEN @GrupMg='S' THEN CMSH18 
                                              WHEN @GrupMg='T' THEN CMSH19 
                                              ELSE                  CMSH 
                                         END,3),
                                         
             A.TAGNR      = 0  --,A.TROW    = 0
             
        FROM #PrdScr A LEFT JOIN ARTIKUJ B ON A.KARTLLG=B.KOD;



-- u shtua per vleftat e vogla si dhe per te mos pasur shumke pas presjeve dhjetore .... 10.06.2019

      UPDATE #PrdScr
         SET SASI    = dbo.Isd_FloatRound(SASI,4),    VLERAM   = dbo.Isd_FloatRound(VLERAM,4), CMIMM=dbo.Isd_FloatRound(CMIMM,4),
             CMIMBS  = dbo.Isd_FloatRound(CMIMBS,4),  VLERABS  = dbo.Isd_FloatRound(VLERABS,4),
             CMIMOR  = dbo.Isd_FloatRound(CMIMOR,4),  VLERAOR  = dbo.Isd_FloatRound(VLERAOR,4),
             CMIMSH  = dbo.Isd_FloatRound(CMIMSH,4),  VLERASH  = dbo.Isd_FloatRound(VLERASH,4),
             VLERAFT = dbo.Isd_FloatRound(VLERAFT,4), SASIKONV = dbo.Isd_FloatRound(SASIKONV,4);



-- 4  Kalimi ne DbFin

          IF @Tip='D' AND @DokJB=1
             DELETE FROM #PrdScr WHERE TROW=1;

          IF @DokJB=0     -- Fshirje i vjetri
             EXEC (' DELETE FROM '+@TableMgScr+' WHERE NRD='+@PNrRendor );


                         -- Shtim Scr te reja ne Bazen reale
        EXEC ('

             INSERT INTO '+@TableMgScr+'
                   (NRD,     KOD,     KODAF,  KARTLLG,  NRRENDKLLG, PERSHKRIM,  NJESI,         KOMENT, 
                    VLERAFT, SASI,    VLERAM, CMIMM,    KMON,       CMIMOR,     VLERAOR,       CMIMBS,     VLERABS, 
                    KOEFSHB, NJESINV, TIPKLL, SASIKONV, TROW,       GJENROWAUT, GJENROWAUTPRD, KONVERTART, TAGNR,  SERI, DTSKADENCE) 
             SELECT NRD,     KOD,     KODAF,  KARTLLG,  NRRENDKLLG, PERSHKRIM,  NJESI,         KOMENT,
                    VLERAFT, SASI,    VLERAM, CMIMM,    KMON,       CMIMOR,     VLERAOR,       CMIMBS,     VLERABS, 
                    KOEFSHB, NJESINV, TIPKLL, SASIKONV, TROW,       GJENROWAUT, GJENROWAUTPRD, KONVERTART, 0,      SERI, DTSKADENCE
               FROM #PrdScr; ');





 -- 5  Fshirja e tabeles temporare

        EXEC('
        
            USE TempDB;
            
            IF EXISTS (SELECT NAME FROM SYS.OBJECTS WHERE OBJECT_ID=Object_Id(''#PrdScr''))
               DROP TABLE #PrdScr; ');
GO
