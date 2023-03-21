SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--        Exec dbo.Isd_GjenerimFFFromDorezim 2,'PG1','F1100','2021-02-20',1001,2001,'Pranim ditor i qumeshtit','D','ADMIN','1234567890';


CREATE Procedure [dbo].[Isd_GjenerimFFFromDorezim]
(
  @pNrD           Int,               
  @pKMag          Varchar(30),
  @pKodFu         Varchar(30),
  @pDateDok       Varchar(20),
  @pNrDok         Int,                 -- Kujdes
  @pNrDokMg       Int,                 -- Kujdes
  @pKoment        Varchar(150),
  @pProces        Varchar(10),         -- 'G' per gjenerim, 'D' per display
  @pPerdorues     Varchar(30),
  @pLgJob         Varchar(30)
 )

As

-- Procedura nderton nje dokument te vetem FF per gjithe artikujt e dorezuar te nje dite. 
-- Ky dokument i ngarkohet nje kodi furnitori (parameter) dhe ndertohet nje Fh per nje magazine (parameter).
-- Dokumenti FF ne total eshte zero sepse e gjithe vlera stornohet brenda ketij dokumenti me reshta llogari. Rreshtat artikuj krijojne dokumentin Fh.
-- Pra eshte nje furnitor pa detyrime dhe na krijon dokument magazine nga blerje.

/*
DECLARE @pNrD          Int,
        @pKMag         Varchar(30),
        @pKodFu        Varchar(30),
        @pDateDok      DateTime,
        @pNrDok        Int,                 -- Kujdes
        @pNrDokMg      Int,                 -- Kujdes
        @pKoment       Varchar(150),
        @pPerdorues    Varchar(30),
        @pProces       Varchar(10),
        @pLgJob        Varchar(30);

         SET @pNrD         = 2
         SET @pKMag        = 'PG1';
         SET @pKodFu       = 'F1100';
         SET @pDateDok     = '2021-02-18';
         SET @pNrDok       = 1001;
         SET @pNrDokMg     = 1003;
         SET @pKoment      = 'Pranimi ditor i qumeshtit'
         SET @pPerdorues   = 'ADMIN';
         SET @pLgJob       = '123456';
         SET @pProces      = 'G';  */
   

     DECLARE @NrD            Int,
             @sKMag          Varchar(30),
             @sKodFu         Varchar(30),
             @DateDok        DateTime,
             @sKoment        Varchar(150),
             @Perdorues      Varchar(30),
             @sProces        Varchar(10),
             @LgJob          Varchar(30),
             @TagRnd         BigInt,
             @NrMax          Int,
             @NrMaxMg        Int,
             @NrRendor       BigInt,
             @sSql           Varchar(Max),
             @ListCommun     Varchar(Max);
     
         SET @Nrd          = @pNrD;
         SET @sKMag        = @pKMag;
         SET @sKodFu       = @pKodFu;
         SET @DateDok      = dbo.DateValue(@pDateDok);
         SET @sKoment      = @pKoment;
         SET @Perdorues    = @pPerdorues;
         SET @sProces      = @pProces;
         SET @LgJob        = @pLgJob;
         

          IF OBJECT_ID('TEMPDB..#TmpArtikuj') IS NOT NULL
             DROP TABLE #TmpArtikuj;
             
             

      SELECT KMag          = @sKMag, 
          -- DateDok       = @DateDok, 
          -- KodFu         = @sKodFu, 
          -- EmerFu        = (SELECT PERSHKRIM FROM FURNITOR WHERE KOD=@sKodFu),
             Kod           = A.KARTLLG, 
             PERSHKRIM     = R1.Pershkrim,
             Sasi, 
             CmimBs        = CASE WHEN Vlefte*Sasi>0 THEN ROUND(Vlefte/Sasi,2) ELSE 0.0 END, -- Vlefte e grumbullimi / Sasi e pranimit
             VleraBs       = ROUND(A.Vlefte,2),
             VlPaTvsh      = ROUND(A.Vlefte,2) - ROUND(A.Vlefte*0.06,2),
             VlTvsh        = ROUND(A.Vlefte*0.06,2),
             PerqTvsh      = 6,
             AplTvsh       = CAST(1 AS BIT),
             Koment        = @sKoment,
             TROW          = CAST(0 AS BIT), 
             TAGNR         = CAST(0 AS INT),
             NRRENDOR      = R1.NRRENDOR
             
        INTO #TmpArtikuj     
        
        FROM 
           (     
               SELECT KARTLLG=MAX(ArtField01),SASI=SUM(ISNULL(SASI01_PR,0)),VLEFTE=SUM(ISNULL(SASI01_GR,0)*ISNULL(CMIM01,0))
                 FROM GrumbullimScr, GrumbullimPrompts
                WHERE NRD=@NrD AND ISNULL(SASI01_PR,0)<>0 AND IsNull(NotDocumentFat,0)=0 
             GROUP BY NRD    

            UNION ALL  

               SELECT KARTLLG=MAX(ArtField02),SASI=SUM(ISNULL(SASI02_PR,0)),VLEFTE=SUM(ISNULL(SASI02_GR,0)*ISNULL(CMIM02,0))
                 FROM GrumbullimScr, GrumbullimPrompts
                WHERE NRD=@NrD AND ISNULL(SASI02_PR,0)<>0 AND IsNull(NotDocumentFat,0)=0 
             GROUP BY NRD    

            UNION ALL  

               SELECT KARTLLG=MAX(ArtField03),SASI=SUM(ISNULL(SASI03_PR,0)),VLEFTE=SUM(ISNULL(SASI03_GR,0)*ISNULL(CMIM03,0))
                 FROM GrumbullimScr, GrumbullimPrompts
                WHERE NRD=@NrD AND ISNULL(SASI03_PR,0)<>0 AND IsNull(NotDocumentFat,0)=0 
             GROUP BY NRD    
             
             )      A LEFT JOIN ARTIKUJ R1 ON A.KARTLLG=R1.KOD

    ORDER BY A.KARTLLG;
    
    
          IF @sProces='D'
             BEGIN
                   SELECT-- KMag     = @sKMag,
                          --DateDok  = @DateDok, 
                          KodFu    = @sKodFu, 
                          --EmerFu   = (SELECT PERSHKRIM FROM FURNITOR WHERE KOD=@sKodFu),
                          * 
                     FROM #TmpArtikuj 
                 ORDER BY Kod; --Rasti Afishim ....
                 
               RETURN;
               
             END;

    
    
    
    
-- A.1       Krijimi i tabelave #TmpFF, #TmpFFScr
         
      SELECT @TagRnd = dbo.Isd_RandomNumberChars(dbo.Isd_RandomNumber());

         
          IF OBJECT_ID('Tempdb..#TmpFF')         IS NOT NULL
             DROP TABLE #TmpFF;
          IF OBJECT_ID('Tempdb..#TmpFFScr')      IS NOT NULL
             DROP TABLE #TmpFFScr;
             
      SELECT * INTO #TmpFF         FROM FF          WHERE 1=2;
      SELECT * INTO #TmpFfScr      FROM FFSCR       WHERE 1=2; 




-- A.1.1     Krijimi ne Temp te reshtave te artikujve

      INSERT INTO #TmpFfScr
	        (KartLlg, KodAF, Pershkrim, Sasi, CmimBs, VlPaTvsh, VlTvsh, VleraBs, PerqTvsh, AplTvsh, Koment) 
      SELECT Kod,     Kod,   Pershkrim, Sasi, CmimBs, VlPaTvsh, VlTvsh, VleraBs, PerqTvsh, AplTvsh, Koment
	    FROM #TmpArtikuj A
	ORDER BY A.Kod;
	
	
      UPDATE A        
         SET KOD           = @sKMag+'.'+KARTLLG+'...',
             LLOGARIPK     = A.KARTLLG,
             NJESI         = R1.NJESI,
             CMIMM         = A.CMIMBS, 
             VLERAM        = A.VLPATVSH,
             PERQDSCN      = 0,
             BC            = R1.BC,
             KONVERTART    = 1,
             KOEFSHB       = 1,
             NJESINV       = R1.NJESI,
             CMSHZB0       = A.CMIMBS,
             NRRENDKLLG    = R1.NRRENDOR,
             TIPKLL        = 'K' 
       FROM #TmpFfScr A INNER JOIN ARTIKUJ  R1 ON A.KARTLLG=R1.KOD; 
                     
	
	

/*    
      SELECT @NrMax = MAX(NRDOK)
        FROM FF
    GROUP BY YEAR(DATEDOK);

      SELECT @NrMaxMg = MAX(NRDOK)
        FROM FH
       WHERE KMAG=@sKMag 
    GROUP BY KMAG,YEAR(DATEDOK);
*/    
         SET @NrMax        = @pNrDok;                 -- Kujdes
         SET @NrMaxMg      = @pNrDokMg;
    
    
     

-- A.1.2.    Krijimi i dokumentit (koke dokumenti)
     
      INSERT INTO #TmpFf
            (KodFKL,DateDok,NrDok)
      SELECT KODFKL=@sKodFu, DATEDOK=@DateDok, NRDOK=@NrMax+1;
                             

      UPDATE A
         SET SHENIM1       = R2.PERSHKRIM,
             SHENIM2       = R2.ADRESA1,
             SHENIM3       = R2.ADRESA2,
             SHENIM4       = @sKoment, --R2.ADRESA3,
             NRDOK         = A.NRDOK, 
             NRDSHOQ       = CAST(CAST(A.NRDOK AS BIGINT) AS VARCHAR(20)),
             NRSERIAL      = CAST(CAST(A.NRDOK AS BIGINT) AS VARCHAR(20)),
             NRFRAKS       = 0,
             KOD           = KODFKL+'.',
             NIPT          = R2.NIPT,
             LLOJDOK       = 'BL',
             KLASETVSH     = '',
          -- NRDOK         = A.NRDOK + IsNull((SELECT C.NrMax FROM #TmpYearFt C WHERE C.Viti=YEAR(A.DATEDOK)),0),
          -- NRDSHOQ       = CAST(CAST(A.NRDOK + IsNull((SELECT C.NrMax FROM #TmpYearFt C WHERE C.Viti=YEAR(A.DATEDOK)),0) AS BIGINT) AS VARCHAR(20)),
             DTDSHOQ       = A.DATEDOK,
             
             TIPDMG        = 'H',
             KMAG          = @sKMag,
             NRMAG         = (SELECT NRRENDOR FROM MAGAZINA WHERE KOD=@sKMag),
             NRDMAG        = @NrMaxMg,
             FRDMAG        = 0,
             DTDMAG        = A.DATEDOK,
             NRRENDDMG     = 0,
             MODPG         = '', 
             KURS1         = 1,
             KURS2         = 1,
             KMON          = '',
          -- LLOJDOK       = 'BL',  -- Kujdes
          -- KLASETVSH     = '',
             KTH           = 0,
             VENHUAJ       = R2.VENDHUAJ,
             KLASAKF       = R2.GRUP,
             RRETHI        = (SELECT PERSHKRIM FROM VENDNDODHJE WHERE KOD=R2.VENDNDODHJE),
             VLPATVSH      = 0,
             VLTVSH        = 0,
             PARAPG        = 0,
             VLERZBR       = 0,
             VLERTOT       = 0,
             PERQZBR       = 0,             
             PERQTVSH      = 6,
             LlogTVSH      = ISNULL(LM.LLOGTATS,''),
             LlogZbr       = ISNULL(LM.LLOGZBR,''),
             LlogArk       = ISNULL(LM.LLOGARK,''),
             USI           = @Perdorues,
             USM           = @Perdorues,
             TAGNR         = A.NRRENDOR,
             TAGRND        = @TagRnd
             
        FROM #TmpFf A LEFT JOIN FURNITOR R2 ON A.KODFKL=R2.KOD, CONFIGLM LM


             

-- A.1.3.    Krijimi i reshtit stornim

      INSERT INTO #TmpFfScr
	        (KartLlg,   Pershkrim,                             TipKLL,    NrRendKLLG) 
      SELECT R2.Llogari,Pershkrim=MAX(ISNULL(R3.Pershkrim,'')),TipKll='L',NrRendKllg=MAX(ISNULL(R3.NrRendor,0))
	    FROM #TmpFF A INNER JOIN FURNITOR R2 ON A.KODFKL=R2.KOD
	                  LEFT  JOIN LLOGARI  R3 ON R2.LLOGARI=R3.KOD
	GROUP BY R2.Llogari
	ORDER BY R2.Llogari;


      UPDATE A        
         SET KOD           = @sKMag+'.'+A.KARTLLG+'...',
             KODAF         = A.KARTLLG,
             LLOGARIPK     = A.KARTLLG,
             KOMENT        = @sKoment,
             NJESI         = '',
             SASI          = 0-ISNULL(B.SASI,0),
             CMIMM         = CASE WHEN ISNULL(B.VLPATVSH,0)*ISNULL(B.SASI,0)>0 THEN ROUND(ISNULL(B.VLPATVSH,0)/ISNULL(B.SASI,0),2) ELSE 0.0 END, 
             VLERAM        = 0-ISNULL(B.VLPATVSH,0),
             VLPATVSH      = 0-ISNULL(B.VLPATVSH,0),
             VLTVSH        = 0-ISNULL(B.VLTVSH,0),
             CMIMBS        = CASE WHEN ISNULL(B.VLPATVSH,0)*ISNULL(B.SASI,0)>0 THEN ROUND(ISNULL(B.VLPATVSH,0)/ISNULL(B.SASI,0),2) ELSE 0.0 END,
             VLERABS       = 0-(ISNULL(B.VLPATVSH,0)+ISNULL(B.VLTVSH,0)),
             CMSHZB0       = CASE WHEN ISNULL(B.VLPATVSH,0)*ISNULL(B.SASI,0)>0 THEN ROUND(ISNULL(B.VLPATVSH,0)/ISNULL(B.SASI,0),2) ELSE 0.0 END,
             AplTvsh       = CAST(1 AS BIT), 
             PERQTVSH      = 6,
             PERQDSCN      = 0,
             VLTAX         = 0,
             BC            = '',
             KONVERTART    = 0,
             KOEFSHB       = 1,
             NJESINV       = ''
       FROM #TmpFfScr A,
                        (SELECT SASI=SUM(ISNULL(SASI,0)),VLPATVSH=SUM(ISNULL(VLPATVSH,0)),VLTVSH=SUM(ISNULL(VLTVSH,0))
                           FROM #TmpFfScr 
                         ) B
      WHERE TIPKLL='L'; 


      UPDATE A        
         SET NRD           = B.NRRENDOR, 
             TAGNR         = B.NRRENDOR
        FROM #TmpFFScr A, #TmpFF B 

--SELECT * FROM #TmpFF
--Select * From #TmpFFScr;
--RETURN;




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
       
 
-- U.3       Zerime vlera ne FF per FF e shtuara


      SELECT @NrRendor = NRRENDOR
        FROM FF
       WHERE TAGRND=@TagRnd;
        

      UPDATE FF    
         SET TAGNR         = 0,
             FIRSTDOK      = 'F'+CAST(NRRENDOR AS VARCHAR),
             TAGRND        = 0  
       WHERE TAGRND=@TagRnd AND ISNULL(TAGNR,0)<>0;



-- U4.       Ndertimi i te dhenave (dokumentave dhe ditareve) te fatures

        EXEC dbo.Isd_DocSaveFF @NrRendor,'S',1,'',@Perdorues,@LgJob;   
       



          IF OBJECT_ID('TempDb..#TmpFf')    IS NOT NULL
             DROP TABLE #TmpFf;
          IF OBJECT_ID('Tempdb..#TmpFfScr') IS NOT NULL   
             DROP TABLE #TmpFfScr;
             
             
     --Select * From #TmpFf;
     --Select * From #TmpFfScr;
          
GO
