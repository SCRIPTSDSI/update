SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--        Exec dbo.Isd_GjenerimFFFromGrumbullim 2,'M',1,'#12345678','ADMIN','1234567890'

CREATE Procedure [dbo].[Isd_GjenerimFFFromGrumbullim_Ishte]
(
  @pNrRendor      Int,
  @pIDMStatus     Varchar(10),
  @pSaveMg        Bit,
  @pTableTmpLm    Varchar(40),
  @pPerdorues     Varchar(30),
  @pLgJob         Varchar(30)
 )

As


-- Procedura e vjeter nderton dokumenta fature blerje sipas turneve, pra nje furnitor ka aq fatura blerje sa turne ka dorezuar.
-- Punohet me parameter NrRendor dokument grumbullimi.

-- Procedura Isd_GjenerimFFFromGrumbullim u modifikua dhe nderton dokumenta ditore, pavaresisht turneve, 
-- pra nje furnitor ka nje fature blerje pavaresisht turnit 



-- Procedure e sakte dhe e kolauduar



     DECLARE @NrD            Int,
             @Kod1           Varchar(30),
             @Kod2           Varchar(30),
             @Kod3           Varchar(30),
             @Kod4           Varchar(30),
             @KMag           Varchar(30),
             @sSql           Varchar(Max),
             @ListCommun     Varchar(MAX),
             @TagRnd         Varchar(30),
             @NrMaxMg        Int,
             @DateDok        DateTime,
             
             @i              Int,
             @j              Int,
             @NrRendor       Int,
             @sNrRendor      Varchar(30),
             @TableTmpLm     Varchar(30),
             @Perdorues      Varchar(30),
             @LgJob          Varchar(60);
      
      
         SET @TableTmpLm   = @pTableTmpLm;
         SET @Perdorues    = @pPerdorues;
         SET @LgJob        = @pLgJob;
      
             
         SET @NrD          = @pNrRendor;  
      SELECT @Kod1         = ArtField01,@Kod2=ArtField02, @Kod3=ArtField03,@Kod4=ArtField04 
        FROM GrumbullimPrompts;

      SELECT @DateDok      = DATEDOK,   
             @KMag         = ISNULL(KMAG,'') 
        FROM Grumbullim A  
       WHERE NrRendor=@NrD;
       
      SELECT @NrMaxMg      = MAX(NRDOK) 
        FROM FH 
       WHERE KMAG=@KMag AND YEAR(DateDok)=YEAR(@DateDok);
      
        
      SELECT @TagRnd       = dbo.Isd_RandomNumberChars(dbo.Isd_RandomNumber());

         
          IF OBJECT_ID('Tempdb..#TmpFF')     IS NOT NULL
             DROP TABLE #TmpFF;
          IF OBJECT_ID('Tempdb..#TmpFFScr')  IS NOT NULL
             DROP TABLE #TmpFFScr;
          IF OBJECT_ID('Tempdb..#TmpYearFt') IS NOT NULL
             DROP TABLE #TmpYearFt;
          IF OBJECT_ID('Tempdb..#TmpTotal')  IS NOT NULL
             DROP TABLE #TmpTotal;
             
             
             
      SELECT * INTO #TmpFF    FROM FF    WHERE 1=2;
      SELECT * INTO #TmpFfScr FROM FFSCR WHERE 1=2; 

      ALTER TABLE #TmpFfScr ADD KODFKL Varchar(60) NULL;
    
       
        
      INSERT INTO #TmpFfScr
            (NrD,   KartLlg,       KodFKL,   KodAgjent,          Sasi,   PerqTvsh, DtSkadence, TagNr,         TRow)
      SELECT A.Nrd, KartLlg=KodAF, A.KodFKL, KodAgjent=A.KodAgj, A.Sasi, PerqTvsh, A.DateDok,  TagNr=A.NrD, A.TRow
        FROM
        
           (
           
      SELECT Nrd=A.NrRendor,B.KodAgj,KodFKL=B.KodAF,KodAf=@Kod1,Sasi=Sasi01_Pr, PerqTvsh=CASE WHEN ISNULL(B.NIPTACTIV,0)=1 THEN 6 ELSE 6 END,DateDok,TROW=ISNULL(B.NIPTACTIV,0)
        FROM Grumbullim A Inner Join GrumbullimScr B ON A.NrRendor=B.NrD 
       WHERE 1=1 And IsNull(B.Sasi01_Pr,0)<>0 And NrD=@NrD
       
    UNION ALL
    
      SELECT NrD=A.NrRendor,B.KodAgj,KodFKL=B.KodAF,KodAF=@Kod2,Sasi=Sasi02_Pr, PerqTvsh=CASE WHEN ISNULL(B.NIPTACTIV,0)=1 THEN 6 ELSE 6 END,DateDok,TROW=ISNULL(B.NIPTACTIV,0)
        FROM Grumbullim A Inner Join GrumbullimScr B ON A.NrRendor=B.NrD 
       WHERE 1=1 And IsNull(B.Sasi02_Pr,0)<>0 And NrD=@NrD
       
    UNION ALL
    
      SELECT NrD=A.NrRendor,B.KodAgj,KodFKL=B.KodAF,KodAF=@Kod3,Sasi=Sasi03_Pr, PerqTvsh=CASE WHEN ISNULL(B.NIPTACTIV,0)=1 THEN 6 ELSE 6 END,DateDok,TROW=ISNULL(B.NIPTACTIV,0)
        FROM Grumbullim A Inner Join GrumbullimScr B ON A.NrRendor=B.NrD 
       WHERE 1=1 And IsNull(B.Sasi03_Pr,0)<>0 And NrD=@NrD
       
    UNION ALL
    
      SELECT NrD=A.NrRendor,B.KodAgj,KodFKL=B.KodAF,KodAF=@Kod4,Sasi=Sasi04_Pr, PerqTvsh=CASE WHEN ISNULL(B.NIPTACTIV,0)=1 THEN 6 ELSE 6 END,DateDok,TROW=ISNULL(B.NIPTACTIV,0) 
        FROM Grumbullim A Inner Join GrumbullimScr B ON A.NrRendor=B.NrD 
       WHERE 1=1 And IsNull(B.Sasi04_Pr,0)<>0 And NrD=@NrD
       
             ) A            LEFT JOIN Artikuj R1 ON A.KodAF=R1.Kod
                          
             
    ORDER BY A.KodFKL,A.KodAgj;
--    SELECT NRD,DtSkadence,KodFKL,KartLlg,TagNr FROM #TmpFfScr ORDER BY DtSkadence,KodFKL,KartLlg



      SELECT NrMax = MAX(NRDOK),VITI = YEAR(DATEDOK)
        INTO #TmpYearFt
        FROM FF
    GROUP BY YEAR(DATEDOK)



      INSERT INTO #TmpFf
            (KodFKL,Klasifikim,DateDok,
             NrDok,
             LLOJDOK,KLASETVSH, TagNr)
            
      SELECT KodFKL, KodAgjent, DateDok=DtSkadence, 
             NrDok   = Row_Number() OVER(ORDER BY DtSkadence,KodFKL,KodAgjent,NrD),
             LLojDok = CASE WHEN TROW=0 THEN 'BL' ELSE '' END, KLASETVSH='FANG', TagNr=NrD
        FROM #TmpFfScr
    GROUP BY KodFKL, KodAgjent, DtSkadence, NrD, TROW
    ORDER BY DtSkadence, KodFKL, KodAgjent, NrD;
    



      UPDATE A
         SET SHENIM1       = R2.PERSHKRIM,
             SHENIM2       = R2.ADRESA1,
             SHENIM3       = R2.ADRESA2,
             SHENIM4       = R2.ADRESA3,
             NRDOK         = A.NRDOK + IsNull((SELECT C.NrMax FROM #TmpYearFt C WHERE C.Viti=YEAR(A.DATEDOK)),0),
             NRFRAKS       = 0,
             KOD           = KODFKL+'.',
             NIPT          = R2.NIPT,
             NRDSHOQ       = CAST(CAST(A.NRDOK + IsNull((SELECT C.NrMax FROM #TmpYearFt C WHERE C.Viti=YEAR(A.DATEDOK)),0) AS BIGINT) AS VARCHAR),
             DTDSHOQ       = A.DATEDOK,
             
             TIPDMG        = 'H',
             KMAG          = @KMag,
             NRDMAG        = A.NRDOK+@NrMaxMg,
             DTDMAG        = A.DATEDOK,
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

      UPDATE #TmpFF     SET TAGNR = NRRENDOR 
      UPDATE #TmpFFScr  SET TAGNR = NRD


      UPDATE A        
         SET KOD           = @KMag+'.'+A.KARTLLG+'...', -- Kujdes
             KODAF         = A.KARTLLG,
             LLOGARIPK     = A.KARTLLG,
             NRRENDKLLG    = R1.NRRENDOR,
             TIPKLL        = 'K',
             PERSHKRIM     = R1.PERSHKRIM,
             NJESI         = R1.NJESI,
               
             SASI          = A.SASI,
                                                                            -- Kujdes me klasa Furnitor
             CMIMM         =              ( SELECT TOP 1 ROUND(CMIMBS / (1+(A.PERQTVSH/100)),2) FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR),                                 -- Kujdes
             VLERAM        = ROUND(A.SASI*( SELECT TOP 1 ROUND(CMIMBS / (1+(A.PERQTVSH/100)),2) FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR),2),                           -- Kujdes
             
             VLPATVSH      = ROUND(A.SASI*( SELECT TOP 1 ROUND(CMIMBS / (1+(A.PERQTVSH/100)),2) FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR),2),
             VLTVSH        = CASE WHEN A.PERQTVSH=6 THEN ROUND(A.SASI*(SELECT TOP 1 ROUND(CMIMBS / (1+(A.PERQTVSH/100)),2) FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR)*A.PERQTVSH/100,2) ELSE 0 END, -- Kujdes
             CMIMBS        =              ( SELECT TOP 1 ROUND(CMIMBS / (1+(A.PERQTVSH/100)),2) FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR), 
             VLERABS       = CASE WHEN A.PERQTVSH=6 THEN ROUND(A.SASI*(SELECT TOP 1 ROUND(CMIMBS / (1+(A.PERQTVSH/100)),2) FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR)*(1+A.PERQTVSH/100),2) ELSE 0 END, -- Kujdes
          -- VLERABS       = ROUND(A.SASI*R1.CMB,2) + CASE WHEN A.PERQTVSH=6 THEN ROUND(A.SASI*(SELECT TOP 1 ROUND(CMIMBS * (1+(A.PERQTVSH/100),2) FROM FurnitorCmim Cm WHERE Cm.KOD=A.KARTLLG  AND Cm.NRD=R2.NRRENDOR),2) ELSE 0 END,-- Kujdes
             PERQTVSH      = A.PERQTVSH,
             
             KOEFSHB       = 1,
             NJESINV       = R1.NJESI,
             CMSHZB0       = R1.CMB,
             KOMENT        = 'Grumbullim ditor'
             
       FROM #TmpFfScr A INNER JOIN ARTIKUJ  R1 ON A.KARTLLG=R1.KOD 
                        INNER JOIN Furnitor R2 ON A.KODFKL=R2.KOD
                     -- INNER JOIN FurnitorCmim Cm ON FCM.KOD=A.KARTLLG  -- Albani 
       

      SELECT NRD, VLPATVSH=SUM(VLPATVSH), VLTVSH=SUM(VLTVSH), VLERTOT=SUM(VLERABS) 
        INTO #TmpTotal
        FROM #TmpFFScr
    GROUP BY NRD    
       
      UPDATE A
         SET VLPATVSH      = B.VLPATVSH,
             VLTVSH        = B.VLTVSH,
             VLERTOT       = B.VLERTOT,
             VLERZBR       = 0,
             PARAPG        = 0,
             PERQZBR       = 0,
             PERQTVSH      = CASE WHEN ISNULL(B.VLTVSH,0)<>0 THEN 20 ELSE 0 END
        FROM #TmpFF A INNER JOIN #TmpTotal B ON A.NRRENDOR=B.NRD
       
       
       
       
-- Kalimi ne te dhenat e nd/jes       

-- U.1  Kalimi i #TmpFF ne FF

         SET @ListCommun   = dbo.Isd_ListFields2Tables('FF','#TmpFF','NRRENDOR,FIRSTDOK');

         SET @sSql= ' 
     INSERT  INTO FF
            ('+@ListCommun+') 
     SELECT  '+@ListCommun+'
       FROM #TmpFF 
   ORDER BY YEAR(DATEDOK),NRDOK;';

       EXEC (@sSql);



-- U.2  UPDATE NRD ne #TmpFFScr me vlerat e FF te sapo krijuara

      UPDATE #TmpFFScr SET NRD=0;

      UPDATE B 
         SET B.NRD = A.NRRENDOR 
        FROM FF A INNER JOIN #TmpFFScr B ON A.TAGNR=B.TAGNR 
       WHERE A.TagRND=@TagRnd  AND A.TAGNR<>0;  -- Kujdes @TagRnd




-- U.3  Kalimi i #TmpFFScr te krijuara ne FFScr

         SET @ListCommun = dbo.Isd_ListFields2Tables('FFSCR','#TMPFFSCR','NRRENDOR,TAGNR,TAGRND');

         SET @sSql= ' 
      INSERT INTO FFSCR 
            ('+@ListCommun+',TAGNR,TAGRND) 
      SELECT '+@ListCommun+',0,''''
        FROM #TMPFFSCR 
        WHERE NRD<>0 ';

       EXEC (@sSql);

-- U.4  Zerime vlera ne FF per FF e shtuara

      UPDATE FF    
         SET TAGNR         = 0,
             FIRSTDOK      = 'F'+CAST(NRRENDOR AS VARCHAR)  
       WHERE TAGRND=@TagRnd AND ISNULL(TAGNR,0)<>0;



-- Ndertimi i te dhenave (dokumentave dhe ditareve) te faturave

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
       
       

      UPDATE A
         SET [STATUS] = 1 
        FROM Grumbullim A  
       WHERE NrRendor=@NrD;

          SELECT * FROM #TmpFF

          IF OBJECT_ID('Tempdb..#TmpFF')     IS NOT NULL
             DROP TABLE #TmpFF;
          IF OBJECT_ID('Tempdb..#TmpFFScr')  IS NOT NULL
             DROP TABLE #TmpFFScr;
          IF OBJECT_ID('Tempdb..#TmpYearFt') IS NOT NULL
             DROP TABLE #TmpYearFt;
          IF OBJECT_ID('Tempdb..#TmpTotal')  IS NOT NULL
             DROP TABLE #TmpTotal;



GO
