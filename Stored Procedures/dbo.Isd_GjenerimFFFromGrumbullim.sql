SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--        Exec dbo.Isd_GjenerimFFFromGrumbullim 0,'31/01/2021','PG1','PG1','M',0,'#12345678','ADMIN','1234567890';


CREATE Procedure [dbo].[Isd_GjenerimFFFromGrumbullim]
(
  @pNrRendor      Int,               -- Kjo fushe bie sepse behet nje dokument ditor (me perpara ishte nje dokument per cdo turn)
  @pDateDok       Varchar(20),
  @pKMagKp        Varchar(20),
  @pKMagKs        Varchar(20),
  @pIDMStatus     Varchar(10),
  @pTipFat        Int,               -- Kut TipFat=1 zgjidhen ato me Nipt, kur TipFat=0 zgjidhen ato pa nipt 
  @pTableTmpLm    Varchar(40),
  @pPerdorues     Varchar(30),
  @pLgJob         Varchar(30)
 )

As



-- Procedura u ndryshua duke bere vetem nje dokument per nje dite dhe jo dokumenta sipas turnit te dorezimit ....

-- Procedura e vjeter [dbo.Isd_GjenerimFFFromGrumbullim_Ishte] ndertonte dokumenta fature blerje sipas turneve, 
-- pra nje furnitor ka aq fatura blerje sa turne ka dorezuar. Punohej me parameter NrRendor dokument grumbullimi.

-- Procedura Isd_GjenerimFFFromGrumbullim u modifikua dhe nderton dokumenta ditore, pavaresisht turneve, 
-- pra nje furnitor ka nje fature blerje pavaresisht turnit, parameter ketu eshte DateDok 



     DECLARE @NrD            Int,
             @Kod1           Varchar(30),
             @Kod2           Varchar(30),
             @Kod3           Varchar(30),
             @Kod4           Varchar(30),
             @KMag           Varchar(30),
             @sKMagKp        Varchar(30),
             @sKMagKs        Varchar(30),
             
             @sSql           Varchar(Max),
             @ListCommun     Varchar(MAX),
             @TagRnd         Varchar(30),
--           @NrMaxMg        Int,
             @NrSeri         Int,
             @DateDok        DateTime,
             
             @i              Int,
             @j              Int,
             @NrRendor       Int,
             @sNrRendor      Varchar(30),
             @TipFat         Int,
             @TableTmpLm     Varchar(30),
             @Perdorues      Varchar(30),
             @LgJob          Varchar(60),
			 @bError         Int;
      
      
         SET @TipFat       = @pTipFat;
         SET @TableTmpLm   = @pTableTmpLm;
         SET @Perdorues    = @pPerdorues;
         SET @LgJob        = @pLgJob;
         SET @DateDok      = dbo.DateValue(@pDateDok);
         SET @sKMagKp      = ISNULL(@pKMagKp,'');
         SET @sKMagKs      = ISNULL(@pKMagKs,'');
         SET @bError       = 0;    
        
      SELECT @Kod1         = ArtField01, @Kod2=ArtField02, @Kod3=ArtField03, @Kod4=ArtField04  FROM GrumbullimPrompts;


                                                                                 
-- Ne filter ka rendesi fushat [StNipt] dhe [StNiptJo].
-- Kur gjenerohen fatura per fermere me nipt referehemi fushes [StNipt] dhe per ata pa nipt fushes [StNiptJo].

          IF @TipFat=1                -- Sipas statusit [StNipt]                  -- Algoritmi per statusin e dokumentit u fut 07.04.2021
             BEGIN
               SELECT @KMag         = MAX(ISNULL(KMAG,'')), 
                      @NrD          = MAX(NRRENDOR)
                 FROM Grumbullim A  
                WHERE DATEDOK=@DateDok AND ISNULL([STNIPT],0)=0                   
             END
          ELSE                        -- Sipas statusit [StNiptJo]
             BEGIN                    
               SELECT @KMag         = MAX(ISNULL(KMAG,'')), 
                      @NrD          = MAX(NRRENDOR)
                 FROM Grumbullim A  
                WHERE DATEDOK=@DateDok AND ISNULL([STNIPTJO],0)=0              
             END;

          IF (@@ROWCOUNT<=0) OR ISNULL(@KMag,'')='' OR ISNULL(@NrD,0)=0
		     SET @bError = 1;

	      IF @bError=1
		     RETURN;

/*
      SELECT @KMag         = MAX(ISNULL(KMAG,'')),                                -- Kjo procedure ishte deri 07.04.2021
             @NrD          = MAX(NRRENDOR)
        FROM Grumbullim A  
       WHERE DATEDOK=@DateDok -- AND ISNULL([STATUS],0)=0                         -- Kujdes mos haro [STATUS] sepse duhet ne filter

--    SELECT @NrMaxMg      = MAX(NRDOK) 
--      FROM FH 
--     WHERE KMAG=@KMag AND YEAR(DateDok)=YEAR(@DateDok);  */





-- 0.        Gjenerimi i nr seriale


     DECLARE @pMeNiptNrSeri    Int,
             @pPaNiptNrSeri    Int,
             @pMeNiptNrKufiP   Int,
             @pMeNiptNrKufiS   Int,
             @pPaNiptNrKufiP   Int,
             @pPaNiptNrKufiS   Int;

         SET @bError         = 0;

        Exec dbo.Isd_ERZGetNrSeriFature @pMeNiptNrSeri  Output,@pPaNiptNrSeri  Output,
                                        @pMeNiptNrKufiP Output,@pMeNiptNrKufiS Output,
                                        @pPaNiptNrKufiP Output,@pPaNiptNrKufiS Output, @Perdorues,0;

--    SELECT MeNiptNrSeri   = @pMeNiptNrSeri,     MeNiptNrKufiP = @pMeNiptNrKufiP, MeNiptNrKufiS = @pMeNiptNrKufiS,
--           PaNiptNrSeri   = @pPaNiptNrSeri,     PaNiptNrKufiP = @pPaNiptNrKufiP, PaNiptNrKufiS = @pPaNiptNrKufiS;
             
         
          IF @TipFat=1        -- Me Nipt
             BEGIN
               SET @NrSeri  = ISNULL(@pMeNiptNrSeri,0);
               SET @bError  = CASE WHEN (@NrSeri=@pMeNiptNrKufiS) OR (@pMeNiptNrKufiP>=@pMeNiptNrKufiS) THEN 1 ELSE 0 END;
             END
          ELSE
             BEGIN            -- Pa Nipt
               SET @NrSeri  = ISNULL(@pPaNiptNrSeri,0);
               SET @bError  = CASE WHEN (@NrSeri=@pPaNiptNrKufiS) OR (@pPaNiptNrKufiP>=@pPaNiptNrKufiS) THEN 1 ELSE 0 END;
             END;  

--       SET @NrMaxMg       = ISNULL(@NrMaxMg,0);
--       SET @NrSeri        = ISNULL(@NrSeri,0);
       
       
          IF @bError = 1
             RETURN;
          
-- 0.        Fund Gjenerim seriale




-- A.1       Krijimi i tabelave #TmpFF, #TmpFFScr, #TNPTransport
         
      SELECT @TagRnd       = dbo.Isd_RandomNumberChars(dbo.Isd_RandomNumber());

         
          IF OBJECT_ID('Tempdb..#TmpFF')         IS NOT NULL
             DROP TABLE #TmpFF;
          IF OBJECT_ID('Tempdb..#TmpFFScr')      IS NOT NULL
             DROP TABLE #TmpFFScr;
          IF OBJECT_ID('Tempdb..#TmpFFScrPrvz')  IS NOT NULL
             DROP TABLE #TmpFFScrPrvz;
          IF OBJECT_ID('Tempdb..#TmpYearFt')     IS NOT NULL
             DROP TABLE #TmpYearFt;
          IF OBJECT_ID('Tempdb..#TmpTotal')      IS NOT NULL
             DROP TABLE #TmpTotal;
          IF OBJECT_ID('Tempdb..#TmpTransport')   IS NOT NULL
             DROP TABLE #TmpTransport;
             
             
      SELECT * INTO #TmpFF         FROM FF          WHERE 1=2;
      SELECT * INTO #TmpFfScr      FROM FFSCR       WHERE 1=2; 
      SELECT * INTO #TmpFfScrPrvz  FROM FFSCR       WHERE 1=2;
      SELECT * INTO #TmpTransport  FROM FFShoqerues WHERE 1=2; 

       ALTER TABLE  #TmpFfScr      ADD KODFKL       Varchar(60) NULL;
       ALTER TABLE  #TmpFfScrPrvz  ADD KODFKL       Varchar(60) NULL;
	   ALTER TABLE  #TmpFfScr      ADD SHENIM4      Varchar(10) NULL;
	   ALTER TABLE  #TMPFFSCRPRVZ  ADD SHENIM4      VARCHAR(10) NULL;
    
       
          IF @TipFat=1                                               -- Gjenerohen fatura per fermeret me nipt dhe ne filter kontrollohet fusha [StNipt]=0
	         BEGIN 
                 INSERT INTO #TmpFfScrPrvz
                       (KartLlg,       KodFKL,   KodAgjent,          DtSkadence, Sasi,   PerqTvsh,   APLTVSH,  SHENIM4)
                 SELECT KartLlg=KodAF, A.KodFKL, KodAgjent=A.KodAgj, A.DateDok,  A.Sasi, A.PerqTvsh, A.APLTVSH,A.KMAG
                   FROM
        
                    (                                       -- Ndryshuar filter per NotDocumentFat 05.02.2021 si dhe kufij per magazinen
           
                           SELECT B.KodAgj,KodFKL=B.KodAF,KodAf=@Kod1,DateDok,Sasi=Sasi01_Gr, PerqTvsh=CASE WHEN ISNULL(B.NIPTACTIV,0)=1 THEN 6 ELSE 0 END, APLTVSH=ISNULL(B.NIPTACTIV,0),A.KMAG
                             FROM Grumbullim A Inner Join GrumbullimScr B  ON A.NrRendor=B.NrD
		                                       Inner join AgjentBlerjeFurnitorscr Sc On Sc.KODAF=B.KODAF 
                            WHERE A.StNipt=0 And A.KMag>=@sKMagKp And A.KMag<=@sKMagKs And A.DATEDOK=@DateDok And IsNull(B.NIPTActiv,0)=@TipFat And IsNull(B.NotDocumentFat,0)=0 And 
						          IsNull(B.Sasi01_Gr,0)<>0 And ISNULL(Sc.DateEnd,0)-1>=A.DateDok
                                                   
                        UNION ALL
    
                           SELECT B.KodAgj,KodFKL=B.KodAF,KodAF=@Kod2,DateDok,Sasi=Sasi02_Gr, PerqTvsh=CASE WHEN ISNULL(B.NIPTACTIV,0)=1 THEN 6 ELSE 0 END, APLTVSH=ISNULL(B.NIPTACTIV,0),A.KMAG
                             FROM Grumbullim A Inner Join GrumbullimScr B ON A.NrRendor=B.NrD 
		                                       Inner join agjentblerjefurnitorscr sc on sc.kodaf=b.kodaf 
                            WHERE A.StNipt=0 And A.KMag>=@sKMagKp And A.KMag<=@sKMagKs And A.DATEDOK=@DateDok And IsNull(B.NIPTActiv,0)=@TipFat And IsNull(B.NotDocumentFat,0)=0 And 
						          IsNull(B.Sasi02_Gr,0)<>0 And ISNULL(Sc.DateEnd,0)-1>=A.DateDok 
                                                   
                        UNION ALL
    
                           SELECT B.KodAgj,KodFKL=B.KodAF,KodAF=@Kod3,DateDok,Sasi=Sasi03_Gr, PerqTvsh=CASE WHEN ISNULL(B.NIPTACTIV,0)=1 THEN 6 ELSE 0 END, APLTVSH=ISNULL(B.NIPTACTIV,0),A.KMAG
                             FROM Grumbullim A Inner Join GrumbullimScr B ON A.NrRendor=B.NrD 
		                                       Inner join agjentblerjefurnitorscr sc on sc.kodaf=b.kodaf 
                            WHERE A.StNipt=0 And A.KMag>=@sKMagKp And A.KMag<=@sKMagKs And A.DATEDOK=@DateDok And IsNull(B.NIPTActiv,0)=@TipFat And IsNull(B.NotDocumentFat,0)=0 And 
						          IsNull(B.Sasi03_Gr,0)<>0 And ISNULL(Sc.DateEnd,0)-1>=A.DateDok 
                                                   
                        UNION ALL
    
                           SELECT B.KodAgj,KodFKL=B.KodAF,KodAF=@Kod4,DateDok,Sasi=Sasi04_Gr, PerqTvsh=CASE WHEN ISNULL(B.NIPTACTIV,0)=1 THEN 6 ELSE 0 END, APLTVSH=ISNULL(B.NIPTACTIV,0),A.KMAG 
                             FROM Grumbullim A Inner Join GrumbullimScr B ON A.NrRendor=B.NrD
		                                       Inner join agjentblerjefurnitorscr sc on sc.kodaf=b.kodaf  
                            WHERE A.StNipt=0 And A.KMag>=@sKMagKp And A.KMag<=@sKMagKs And A.DATEDOK=@DateDok And IsNull(B.NIPTActiv,0)=@TipFat And IsNull(B.NotDocumentFat,0)=0 And 
						          IsNull(B.Sasi04_Gr,0)<>0 And ISNULL(Sc.DateEnd,0)-1>=A.DateDok 
                                                   
                        ) A            LEFT JOIN Artikuj R1 ON A.KodAF=R1.Kod
                          
             
               ORDER BY A.KodFKL,A.KodAgj;
	         END;
	


          IF @TipFat=0                                               -- Gjenerohen fatura per fermeret pa nipt dhe ne filter kontrollohet fusha [StNiptJo]=0
	         BEGIN 
                 INSERT INTO #TmpFfScrPrvz
                       (KartLlg,       KodFKL,   KodAgjent,          DtSkadence, Sasi,   PerqTvsh,   APLTVSH,  SHENIM4)
                 SELECT KartLlg=KodAF, A.KodFKL, KodAgjent=A.KodAgj, A.DateDok,  A.Sasi, A.PerqTvsh, A.APLTVSH,A.KMAG
                   FROM
        
                    (                                       -- Ndryshuar filter per NotDocumentFat 05.02.2021 si dhe kufij per magazinen
           
                           SELECT B.KodAgj,KodFKL=B.KodAF,KodAf=@Kod1,DateDok,Sasi=Sasi01_Gr, PerqTvsh=CASE WHEN ISNULL(B.NIPTACTIV,0)=1 THEN 6 ELSE 0 END, APLTVSH=ISNULL(B.NIPTACTIV,0),A.KMAG
                             FROM Grumbullim A Inner Join GrumbullimScr B  ON A.NrRendor=B.NrD
		                                       Inner join AgjentBlerjeFurnitorscr Sc On Sc.KODAF=B.KODAF 
                            WHERE A.StNiptJo=0 And A.KMag>=@sKMagKp And A.KMag<=@sKMagKs And A.DATEDOK=@DateDok And IsNull(B.NIPTActiv,0)=@TipFat And IsNull(B.NotDocumentFat,0)=0 And 
						          IsNull(B.Sasi01_Gr,0)<>0 And ISNULL(Sc.DateEnd,0)-1>=A.DateDok
                                                   
                        UNION ALL
    
                           SELECT B.KodAgj,KodFKL=B.KodAF,KodAF=@Kod2,DateDok,Sasi=Sasi02_Gr, PerqTvsh=CASE WHEN ISNULL(B.NIPTACTIV,0)=1 THEN 6 ELSE 0 END, APLTVSH=ISNULL(B.NIPTACTIV,0),A.KMAG
                             FROM Grumbullim A Inner Join GrumbullimScr B ON A.NrRendor=B.NrD 
		                                       Inner join agjentblerjefurnitorscr sc on sc.kodaf=b.kodaf 
                            WHERE A.StNiptJo=0 And A.KMag>=@sKMagKp And A.KMag<=@sKMagKs And A.DATEDOK=@DateDok And IsNull(B.NIPTActiv,0)=@TipFat And IsNull(B.NotDocumentFat,0)=0 And 
						          IsNull(B.Sasi02_Gr,0)<>0 And ISNULL(Sc.DateEnd,0)-1>=A.DateDok 
                                                   
                        UNION ALL
    
                           SELECT B.KodAgj,KodFKL=B.KodAF,KodAF=@Kod3,DateDok,Sasi=Sasi03_Gr, PerqTvsh=CASE WHEN ISNULL(B.NIPTACTIV,0)=1 THEN 6 ELSE 0 END, APLTVSH=ISNULL(B.NIPTACTIV,0),A.KMAG
                             FROM Grumbullim A Inner Join GrumbullimScr B ON A.NrRendor=B.NrD 
		                                       Inner join agjentblerjefurnitorscr sc on sc.kodaf=b.kodaf 
                            WHERE A.StNiptJo=0 And A.KMag>=@sKMagKp And A.KMag<=@sKMagKs And A.DATEDOK=@DateDok And IsNull(B.NIPTActiv,0)=@TipFat And IsNull(B.NotDocumentFat,0)=0 And 
						          IsNull(B.Sasi03_Gr,0)<>0 And ISNULL(Sc.DateEnd,0)-1>=A.DateDok 
                                                   
                        UNION ALL
    
                           SELECT B.KodAgj,KodFKL=B.KodAF,KodAF=@Kod4,DateDok,Sasi=Sasi04_Gr, PerqTvsh=CASE WHEN ISNULL(B.NIPTACTIV,0)=1 THEN 6 ELSE 0 END, APLTVSH=ISNULL(B.NIPTACTIV,0),A.KMAG 
                             FROM Grumbullim A Inner Join GrumbullimScr B ON A.NrRendor=B.NrD
		                                       Inner join agjentblerjefurnitorscr sc on sc.kodaf=b.kodaf  
                            WHERE A.StNiptJo=0 And A.KMag>=@sKMagKp And A.KMag<=@sKMagKs And A.DATEDOK=@DateDok And IsNull(B.NIPTActiv,0)=@TipFat And IsNull(B.NotDocumentFat,0)=0 And 
						          IsNull(B.Sasi04_Gr,0)<>0 And ISNULL(Sc.DateEnd,0)-1>=A.DateDok 
                                                   
                        ) A            LEFT JOIN Artikuj R1 ON A.KodAF=R1.Kod
                          
             
               ORDER BY A.KodFKL,A.KodAgj;
	         END;




      INSERT INTO #TmpFfScr
	        (Nrd,      KartLlg, KodFKL, KodAgjent, DtSkadence,              Sasi,           PerqTvsh,               TagNr,      APLTVSH, SHENIM4)
      SELECT Nrd=@NrD, KartLlg, KodFKL, KodAgjent, DateDok=MAX(DtSkadence), Sasi=SUM(Sasi), PerqTvsh=MAX(PerqTvsh), TagNr=@NrD, APLTVSH=MAX(CASE WHEN APLTVSH=1 THEN 1 ELSE 0 END),SHENIM4
	    FROM #TmpFfScrPrvz A
    GROUP BY KartLlg,KodFKL, KodAgjent, SHENIM4
	ORDER BY KartLlg,KodFKL, KodAgjent;

	
      
          IF OBJECT_ID('Tempdb..#TmpFFScrPrvz')  IS NOT NULL
             DROP TABLE #TmpFFScrPrvz;



      SELECT NrMax = MAX(NRDOK),VITI = YEAR(DATEDOK)
        INTO #TmpYearFt
        FROM FF
    GROUP BY YEAR(DATEDOK);
    
    
    
      INSERT INTO #TmpFf
            (KodFKL,Klasifikim,DateDok,
             NrDok,
             LLOJDOK,KLASETVSH, TagNr,JOBCREATE,SHENIM4)
            
      SELECT KodFKL, KodAgjent, DateDok=DtSkadence, 
             NrDok         = Row_Number() OVER(ORDER BY DtSkadence,KodFKL,KodAgjent,NrD)+@NrSeri,
             LLojDok       = CASE WHEN APLTVSH=0 THEN 'BL' ELSE '' END, 
             KLASETVSH     = 'FFRM', 
             TagNr         = NrD,
			 JOBCREATE     = 'GRM',
			 SHENIM4       
        FROM #TmpFfScr
    GROUP BY KodFKL, KodAgjent, DtSkadence, NrD, APLTVSH,SHENIM4
    ORDER BY DtSkadence, KodFKL, KodAgjent, NrD;



      UPDATE A
         SET SHENIM1       = R2.PERSHKRIM,
             SHENIM2       = R2.ADRESA1,
             SHENIM3       = R2.ADRESA2,
         --  SHENIM4       = R2.ADRESA3,
             NRDOK         = A.NRDOK, 
             NRDSHOQ       = CAST(CAST(A.NRDOK AS BIGINT) AS VARCHAR(20)),
             NRSERIAL      = CAST(CAST(A.NRDOK AS BIGINT) AS VARCHAR(20)),
             NRFRAKS       = 0,
             KOD           = KODFKL+'.',
             NIPT          = R2.NIPT,
          -- NRDOK         = A.NRDOK + IsNull((SELECT C.NrMax FROM #TmpYearFt C WHERE C.Viti=YEAR(A.DATEDOK)),0),
          -- NRDSHOQ       = CAST(CAST(A.NRDOK + IsNull((SELECT C.NrMax FROM #TmpYearFt C WHERE C.Viti=YEAR(A.DATEDOK)),0) AS BIGINT) AS VARCHAR(20)),
             DTDSHOQ       = A.DATEDOK,
             
             TIPDMG        = '',   -- 'H',
             KMAG          = '',   -- @KMag,
             NRDMAG        = 0,    -- A.NRDOK+@NrMaxMg,
             DTDMAG        = NULL, -- A.DATEDOK,
             NRRENDDMG     = 0,
             
             KURS1         = 1,
             KURS2         = 1,
             KMON          = '',
          -- LLOJDOK       = 'BL',  -- Kujdes
          -- KLASETVSH     = '',
             KTH           = 0,
             VENHUAJ       = R2.VENDHUAJ,
             KLASAKF       = R2.GRUP,
             RRETHI        = (SELECT PERSHKRIM FROM VENDNDODHJE WHERE KOD=R2.VENDNDODHJE),
             LlogTVSH      = ISNULL(LM.LLOGTATS,''),
             LlogZbr       = ISNULL(LM.LLOGZBR,''),
             LlogArk       = ISNULL(LM.LLOGARK,''),
             
             TAGRND        = @TagRND
             
        FROM #TmpFf A LEFT JOIN FURNITOR R2 ON A.KODFKL=R2.KOD, CONFIGLM LM
        

      UPDATE A        
         SET NRD           = B.NRRENDOR
        FROM #TmpFFScr A INNER JOIN #TmpFF B ON A.TAGNR=B.TAGNR AND A.KODFKL=B.KODFKL AND A.DTSKADENCE=B.DATEDOK

      UPDATE #TmpFF     SET TAGNR = NRRENDOR; 
      UPDATE #TmpFFScr  SET TAGNR = NRD, NOTMAG = 1, TROW = 0;



      UPDATE A        
         SET KOD           = @KMag+'.'+A.KARTLLG+'...', -- Kujdes
             KODAF         = A.KARTLLG,
             LLOGARIPK     = A.KARTLLG,
             NRRENDKLLG    = R1.NRRENDOR,
             TIPKLL        = 'K',
             PERSHKRIM     = R1.PERSHKRIM,
             NJESI         = R1.NJESI,
               
             SASI          = A.SASI,
             CMIMM         = CASE WHEN EXISTS (SELECT * FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR)
                                  THEN    ( SELECT TOP 1 ROUND(CMIMBS / (1+(A.PERQTVSH/100)),2) FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR)
                                  ELSE     ROUND(( R1.CMB/1.06),2)
                             END,   
                                           
/*           VLERAM        = ROUND(A.SASI*( SELECT TOP 1 ROUND(CMIMBS / (1+(A.PERQTVSH/100)),2) FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR),2),                           
             VLPATVSH      = ROUND(A.SASI*( SELECT TOP 1 ROUND(CMIMBS / (1+(A.PERQTVSH/100)),2) FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR),2),
             VLTVSH        = CASE WHEN A.PERQTVSH=6 THEN ROUND(A.SASI*(SELECT TOP 1 ROUND(CMIMBS / (1+(A.PERQTVSH/100)),2) FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR)*A.PERQTVSH/100,2) ELSE 0 END, -- Kujdes
             CMIMBS        =              ( SELECT TOP 1 ROUND(CMIMBS / (1+(A.PERQTVSH/100)),2) FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR), 
             VLERABS       = CASE WHEN A.PERQTVSH=6 THEN ROUND(A.SASI*(SELECT TOP 1 ROUND(CMIMBS / (1+(A.PERQTVSH/100)),2) FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR)*(1+A.PERQTVSH/100),2) ELSE 0 END, -- Kujdes
          -- VLERABS       = ROUND(A.SASI*R1.CMB,2) + CASE WHEN A.PERQTVSH=6 THEN ROUND(A.SASI*(SELECT TOP 1 ROUND(CMIMBS * (1+(A.PERQTVSH/100),2) FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR),2) ELSE 0 END,-- Kujdes  */          
             PERQTVSH      = A.PERQTVSH,
             
             KOEFSHB       = 1,
             NJESINV       = R1.NJESI,
             CMSHZB0       = R1.CMB,
             KOMENT        = 'Grumbullim ditor'
       FROM #TmpFfScr A INNER JOIN ARTIKUJ  R1 ON A.KARTLLG=R1.KOD 
                        INNER JOIN Furnitor R2 ON A.KODFKL=R2.KOD;
                     -- INNER JOIN FurnitorCmim Cm ON FCM.KOD=A.KARTLLG  -- Albani 
       

      UPDATE A        
         SET CMIMBS        = A.CMIMM, 
             VLERAM        = ROUND(A.SASI*A.CMIMM,2),                           
             VLPATVSH      = ROUND(A.SASI*A.CMIMM,0),
             VLTVSH        = CASE WHEN A.PERQTVSH=6 THEN ROUND((A.SASI*A.CMIMM*A.PERQTVSH)/100,0) ELSE 0 END, 
             VLERABS       = ROUND(A.SASI*A.CMIMM,0)+
                             CASE WHEN A.PERQTVSH=6 THEN ROUND((A.SASI*A.CMIMM*A.PERQTVSH)/100,0) ELSE 0 END
       FROM #TmpFfScr A INNER JOIN ARTIKUJ  R1 ON A.KARTLLG=R1.KOD; 
                     



      SELECT NRD, VLPATVSH=SUM(VLPATVSH), VLTVSH=SUM(VLTVSH), VLERTOT=SUM(VLERABS) 
        INTO #TmpTotal
        FROM #TmpFFScr
    GROUP BY NRD;    
       
      UPDATE A
         SET VLPATVSH      = B.VLPATVSH,
             VLTVSH        = B.VLTVSH,
             VLERTOT       = B.VLERTOT,
             VLERZBR       = 0,
             PARAPG        = 0,
             PERQZBR       = 0,
             PERQTVSH      = CASE WHEN ISNULL(B.VLTVSH,0)<>0 THEN 20 ELSE 0 END
        FROM #TmpFF A INNER JOIN #TmpTotal B ON A.NRRENDOR=B.NRD;
       
       


-- A.1.2     Krijimi i tabeles #TmpTransport
      
      INSERT INTO #TmpTransport       
            (NRD,KOD,PERSHKRIM,NIPT,NIPTCERTIFIKATE,KODFISKAL,NRLICENCE,TARGE,MJET,AGJENT,TRANSPORTUES,
             KOMPANI,SHENIM1,SHENIM2,SHENIM3,TELEFON1,TELEFON2,FAX,SASINGARKIM,NJESINGARKIM,TAGNR)

      SELECT A.NRRENDOR,R2.KOD,'Grumbullim qumeshti',R2.NIPT,R2.NIPTCERTIFIKATE,R2.KODFISKAL,R2.NRLICENCE,R2.TARGE,R2.MJET,A.KLASIFIKIM,R2.PERSHKRIM,
             R2.KOMPANI,R2.ADRESA1,R2.ADRESA2,R2.ADRESA3,R2.TELEFON1,R2.TELEFON2,R2.FAX,R2.SASINGARKIM,
             R2.NJESINGARKIM,A.NRRENDOR
        FROM #TmpFF A INNER JOIN AgjentBlerje R1 ON A.KLASIFIKIM=R1.KOD
                      INNER JOIN TRANSPORT    R2 ON R1.Transport=R2.KOD;
                       
 
-- A.        Fund ndertimi i tabelave temporare





-- U.        Kalimi ne te dhenat e nd/jes       


-- U.1       Kalimi i #TmpFF ne FF

         SET @ListCommun   = dbo.Isd_ListFields2Tables('FF','#TmpFF','NRRENDOR,FIRSTDOK');

         SET @sSql= ' 
      INSERT INTO FF
            ('+@ListCommun+') 
      SELECT '+@ListCommun+'
        FROM #TmpFF 
    ORDER BY YEAR(DATEDOK),NRDOK;';

       EXEC (@sSql);





-- U.2.1     Update NRD ne #TmpFFScr me vlerat e FF te sapo krijuara

      UPDATE #TmpFFScr SET NRD=0;

      UPDATE B 
         SET B.NRD = A.NRRENDOR 
        FROM FF A INNER JOIN #TmpFFScr B ON A.TAGNR=B.TAGNR 
       WHERE A.TagRND=@TagRnd  AND A.TAGNR<>0;  -- Kujdes @TagRnd




-- U.2.2     Kalimi i #TmpFFScr te krijuara ne FFScr

         SET @ListCommun = dbo.Isd_ListFields2Tables('FFSCR','#TMPFFSCR','NRRENDOR,TAGNR,TAGRND');

         SET @sSql= ' 
      INSERT INTO FFSCR 
            ('+@ListCommun+',TAGNR,TAGRND) 
      SELECT '+@ListCommun+',0,''''
        FROM #TMPFFSCR 
       WHERE NRD<>0 ';

       EXEC (@sSql);
       
       
 

       
-- U.3.1     Update NRD ne #TmpTransport me vlerat e FF te sapo krijuara

      UPDATE B 
         SET B.NRD = A.NRRENDOR 
        FROM FF A INNER JOIN #TmpTransport B ON A.TAGNR=B.TAGNR 
       WHERE A.TagRND=@TagRnd  AND A.TAGNR<>0;  -- Kujdes @TagRnd




-- U.3.2     Kalimi i #TmpTransport te krijuara ne tabelen FFShoqerues

         SET @ListCommun = dbo.Isd_ListFields2Tables('FFShoqerues','#TmpTransport','NRRENDOR,TAGNR,TAGRND');

         SET @sSql= ' 
      INSERT INTO FFShoqerues
            ('+@ListCommun+',TAGNR) 
      SELECT '+@ListCommun+',0
        FROM #TmpTransport
       WHERE NRD<>0 ';

       EXEC (@sSql);





-- U.4       Zerime vlera ne FF per FF e shtuara

      UPDATE FF    
         SET TAGNR         = 0,
             FIRSTDOK      = 'F'+CAST(NRRENDOR AS VARCHAR)  
       WHERE TAGRND=@TagRnd AND ISNULL(TAGNR,0)<>0;





-- U5.       Ndertimi i te dhenave (dokumentave dhe ditareve) te faturave

      SELECT @sSql = '';
      
      SELECT @sSql = @sSql + ','+CAST(CAST(NRRENDOR AS BIGINT) AS VARCHAR) 
        FROM FF 
       WHERE TAGRND=@TagRnd 
    ORDER BY NRRENDOR;


         SET @i = 1;     
         SET @j = Len(@sSql) - Len(Replace(@sSql,',',''))+1;
         
       WHILE @i<=@j
         BEGIN
             SET @sNrRendor  = CAST([dbo].[Isd_StringInListStr](@sSql,@i,',') AS BIGINT);
             IF  @sNrRendor<>''
                 BEGIN
                   SET  @NrRendor  = CAST(@sNrRendor AS BIGINT);
                   EXEC dbo.Isd_DocSaveFF @NrRendor,'S',1,@TableTmpLm,@Perdorues,@LgJob;   --  PRINT @NrRendor;--567717,'M',1,'#12345678','ADMIN','1234567890'
                 END;             --Print @NrRendor
             SET @i = @i + 1;
         END;
       
       



-- U6.       Ndryshimi i statusit te dokumentit

--    UPDATE A   SET [STATUS]=0    FROM Grumbullim A   WHERE DATEDOK=@DateDok;


          IF OBJECT_ID('Tempdb..#TmpFfStatus') IS NOT NULL
		     DROP TABLE #TmpFfStatus;


      SELECT DISTINCT NRRENDOR
	    INTO #TmpFfStatus
        FROM
        
           (    SELECT A.NRRENDOR
                  FROM Grumbullim A Inner Join GrumbullimScr B  ON A.NrRendor=B.NrD
		                            Inner join AgjentBlerjeFurnitorscr Sc On Sc.KODAF=B.KODAF 
                 WHERE A.KMag>=@sKMagKp And A.KMag<=@sKMagKs And A.DATEDOK=@DateDok And IsNull(B.NIPTActiv,0)=@TipFat And IsNull(B.NotDocumentFat,0)=0 And IsNull(B.Sasi01_Gr,0)<>0 AND 
	                   ISNULL(Sc.DateEnd,0)-1>=A.DateDok
                                                   
             UNION ALL
    
                SELECT A.NRRENDOR
                  FROM Grumbullim A Inner Join GrumbullimScr B ON A.NrRendor=B.NrD 
		                            Inner join agjentblerjefurnitorscr sc on sc.kodaf=b.kodaf 
                 WHERE A.KMag>=@sKMagKp And A.KMag<=@sKMagKs And A.DATEDOK=@DateDok And IsNull(B.NIPTActiv,0)=@TipFat And IsNull(B.NotDocumentFat,0)=0 And IsNull(B.Sasi02_Gr,0)<>0 AND 
	                   ISNULL(Sc.DateEnd,0)-1>=A.DateDok 
                                                   
             UNION ALL
    
                SELECT A.NRRENDOR
                  FROM Grumbullim A Inner Join GrumbullimScr B ON A.NrRendor=B.NrD 
		                            Inner join agjentblerjefurnitorscr sc on sc.kodaf=b.kodaf 
                 WHERE A.KMag>=@sKMagKp And A.KMag<=@sKMagKs And A.DATEDOK=@DateDok And IsNull(B.NIPTActiv,0)=@TipFat And IsNull(B.NotDocumentFat,0)=0 And IsNull(B.Sasi03_Gr,0)<>0 AND 
	                   ISNULL(Sc.DateEnd,0)-1>=A.DateDok 
                                                   
             UNION ALL
    
                SELECT A.NRRENDOR
                  FROM Grumbullim A Inner Join GrumbullimScr B ON A.NrRendor=B.NrD
		                            Inner join agjentblerjefurnitorscr sc on sc.kodaf=b.kodaf  
                 WHERE A.KMag>=@sKMagKp And A.KMag<=@sKMagKs And A.DATEDOK=@DateDok And IsNull(B.NIPTActiv,0)=@TipFat And IsNull(B.NotDocumentFat,0)=0 And IsNull(B.Sasi04_Gr,0)<>0 AND 
	                   ISNULL(Sc.DateEnd,0)-1>=A.DateDok 
                                                   
             ) A
	   ORDER BY A.NRRENDOR;

          IF @TipFat=1
		     BEGIN
               UPDATE A
	              SET STNIPT=1
                 FROM Grumbullim A INNER JOIN #TmpFfStatus B ON A.NRRENDOR=B.NRRENDOR
			 END
		  ELSE
		     BEGIN
			   UPDATE A
			      SET STNIPTJO=1
				 FROM Grumbullim A INNER JOIN #TmpFfStatus B ON A.NRRENDOR=B.NRRENDOR
			 END;


       

          IF OBJECT_ID('Tempdb..#TmpFF')        IS NOT NULL
             DROP TABLE #TmpFF;
          IF OBJECT_ID('Tempdb..#TmpFFScr')     IS NOT NULL
             DROP TABLE #TmpFFScr;
          IF OBJECT_ID('Tempdb..#TmpYearFt')    IS NOT NULL
             DROP TABLE #TmpYearFt;
          IF OBJECT_ID('Tempdb..#TmpTotal')     IS NOT NULL
             DROP TABLE #TmpTotal;
          IF OBJECT_ID('Tempdb..#TmpTransport') IS NOT NULL
             DROP TABLE #TmpTransport;
          IF OBJECT_ID('Tempdb..#TmpFfStatus')  IS NOT NULL
		     DROP TABLE #TmpFfStatus;

GO
