SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--        Exec dbo.Isd_GjenerimKthimMg 'YEAR(DATEDOK)>=2020','ADMIN','1234567890';


CREATE PROCEDURE [dbo].[Isd_GjenerimKthimMg]
(
 @pWhere         Varchar(MAX),                   --@pKMag          Varchar(30),
 @pPerdorues     Varchar(30),
 @pLgJob         Varchar(30)
 )

AS


     DECLARE @Perdorues      Varchar(30),
             @sWhere         Varchar(MAX),
             @sSql           Varchar(Max),
             @ListCommun     Varchar(MAX),
             @TagRnd         Varchar(30);
             
         SET @Perdorues    = @pPerdorues;    
         SET @sWhere       = @pWhere;

          IF OBJECT_ID('TEMPDB..#TmpFD')    IS NOT NULL
             DROP TABLE #TmpFD;
          IF OBJECT_ID('TEMPDB..#TMPFDSCR') IS NOT NULL
             DROP TABLE #TMPFDSCR;
          IF OBJECT_ID('TEMPDB..#TMPNrDok') IS NOT NULL
             DROP TABLE #TMPNrDok;
          IF OBJECT_ID('Tempdb..#TmpFH')    IS NOT NULL
             DROP TABLE #TmpFH;
          IF OBJECT_ID('Tempdb..#TmpFHScr') IS NOT NULL
             DROP TABLE #TmpFHScr;
             
             
          IF NOT EXISTS ( SELECT 1 FROM Sys.Columns WHERE OBJECT_ID=OBJECT_ID('FD') AND [Name]='TAGRND' )
             ALTER TABLE FD ADD TAGRND Varchar(30) NULL;
          IF NOT EXISTS ( SELECT 1 FROM Sys.Columns WHERE OBJECT_ID=OBJECT_ID('FH') AND [Name]='TAGRND' )
             ALTER TABLE FH ADD TAGRND Varchar(30) NULL;
         
         
      SELECT * INTO #TmpFD    FROM FD    WHERE 1=2;
      SELECT * INTO #TMPFDSCR FROM FDSCR WHERE 1=2;
      SELECT * INTO #TmpFH    FROM FH    WHERE 1=2;
      SELECT * INTO #TMPFHSCR FROM FHSCR WHERE 1=2;
      
       ALTER TABLE #TMPFDSCR ADD KMAG    VARCHAR(30) NULL;
       ALTER TABLE #TMPFDSCR ADD DATEDOK DATETIME    NULL;
       ALTER TABLE #TMPFHSCR ADD KMAG    VARCHAR(30) NULL;
       ALTER TABLE #TMPFHSCR ADD DATEDOK DATETIME    NULL;

      SELECT @TagRnd = dbo.Isd_RandomNumberChars(dbo.Isd_RandomNumber());



-- A.        Gjenerimi i tabelave temporare FD,FDSCR


      SELECT KMAG=A.KOD, VITI=YEAR(ISNULL(B.DATEDOK,0)), NRMAX=MAX(ISNULL(B.NRDOK,0)),TIP='D'           -- Nr per FD
        INTO #TmpNrDok
        FROM MAGAZINA A LEFT JOIN FD B ON ISNULL(A.KOD,'')=ISNULL(B.KMAG,'')
    GROUP BY A.KOD,YEAR(ISNULL(B.DATEDOK,0));
    
      INSERT INTO #TmpNrDok                                                                             -- Nr per FH
            (KMAG,VITI,NRMAX,TIP)
      SELECT KMAG=A.KOD, VITI=YEAR(ISNULL(B.DATEDOK,0)), NRMAX=MAX(ISNULL(B.NRDOK,0)),TIP='H'
        FROM MAGAZINA A LEFT JOIN FH B ON ISNULL(A.KOD,'')=ISNULL(B.KMAG,'')
    GROUP BY A.KOD,YEAR(ISNULL(B.DATEDOK,0));



         SET @sSql = '
      INSERT INTO #TMPFDSCR
            (KMAG,DATEDOK,KARTLLG,SASI)  
      SELECT KMAG=ISNULL(A.KMAG,''''),DATEDOK=ISNULL(A.DATEDOK,0),KARTLLG=ISNULL(A.KARTLLG,''''),
             SASI=SUM(ISNULL(A.SASIH,0)-ISNULL(A.SASID,0))
        FROM LEVIZJEHD A INNER JOIN MAGAZINA B ON A.KMAG=B.KOD
       WHERE 1=1
    GROUP BY ISNULL(A.KMAG,''''),ISNULL(A.DATEDOK,0),ISNULL(A.KARTLLG,'''')
      HAVING ABS(SUM(ISNULL(A.SASIH,0)-ISNULL(A.SASID,0)))>=0.01
    ORDER BY KMAG,DATEDOK,KARTLLG; ';
          
          IF @sWhere<>''
             SET @sSql = REPLACE(@sSql, '1=1', @sWhere);


             
        EXEC (@sSql);


             
      INSERT INTO #TmpFD
            (KMAG,DATEDOK,NRDOK)
      SELECT KMAG,DATEDOK,NRDOK=Row_Number() OVER(PARTITION BY KMAG,YEAR(DATEDOK) ORDER BY KMAG,DATEDOK)
        FROM #TMPFDSCR
    GROUP BY KMAG,DATEDOK
    ORDER BY KMAG,DATEDOK;


      UPDATE B
         SET B.NRD         = A.NRRENDOR,
             B.TAGNR       = A.NRRENDOR
        FROM #TmpFD A INNER JOIN #TMPFDSCR B ON A.KMAG=B.KMAG AND A.DATEDOK=B.DATEDOK;


    
      UPDATE #TmpFD
         SET TIP           = 'D',
             NRMAG         = ISNULL((SELECT R1.NRRENDOR FROM MAGAZINA R1 WHERE R1.KOD=#TmpFD.KMAG),0),
             GRUP          = ISNULL((SELECT R1.GRUP     FROM MAGAZINA R1 WHERE R1.KOD=#TmpFD.KMAG),'A'),
             NRDOK         = ISNULL(NRDOK,1)+ISNULL((SELECT NRMAX FROM #TmpNrDok B WHERE B.KMAG=#TmpFD.KMAG AND B.VITI=YEAR(#TmpFD.DATEDOK) AND B.TIP='D'),0),
             NRFRAKS       = 0,
             DOK_JB        = 0,
             DST           = 'KM',
             SHENIM1       = 'Kthim furnizimi ditor',
             KMAGRF        = '', --@KMag,
             KMAGLNK       = '', --@KMag,
             NRDOKLNK      = 0,
             NRFRAKSLNK    = 0,
             DATEDOKLNK    = DATEDOK,
             USI           = @Perdorues,        
             USM           = @Perdorues,
             TAGNR         = NRRENDOR,
             TAGRND        = @TagRND;
             
             
      UPDATE #TmpFD
         SET KMAGRF        = B.KODDST,
             KMAGLNK       = B.KODDST
        FROM #TmpFD A INNER JOIN RelacionReferenca B ON A.KMAG=B.KOD;
             
            
        
      UPDATE A
         SET KODAF         = A.KARTLLG,
             KOD           = A.KMAG+'.'+A.KARTLLG+'...',
             PERSHKRIM     = R1.PERSHKRIM,
             NJESI         = R1.NJESI,
             CMIMM         = R1.KOSTMES,
             VLERAM        = ROUND(A.SASI*R1.KOSTMES,2),
             CMIMSH        = R1.CMSH,       -- Kujdes klase magazine
             CMIMBS        = R1.KOSTMES,
             VLERABS       = ROUND(A.SASI*R1.KOSTMES,2),
             KOEFSHB       = 1,
             NJESINV       = R1.NJESI,
             TIPKLL        = 'K',
             BC            = R1.BC,
             KONVERTART    = 1,
             PROMOC        = 0,
             CMIMOR        = R1.KOSTMES,
             VLERAOR       = ROUND(A.SASI*R1.KOSTMES,2),
             KOMENT        = 'Kthim malli',
             GJENROWAUT    = 0,
             GJENROWRVL    = 0,
             NRRENDKLLG    = R1.NRRENDOR
        FROM #TmpFDScr A LEFT JOIN ARTIKUJ R1 ON A.KARTLLG=R1.KOD;
        
      UPDATE B
         SET B.CMIMSH      = CASE WHEN A.GRUP='A' THEN R1.CMSH
                                  WHEN A.GRUP='B' THEN R1.CMSH1
                                  WHEN A.GRUP='C' THEN R1.CMSH2
                                  WHEN A.GRUP='D' THEN R1.CMSH3
                                  WHEN A.GRUP='E' THEN R1.CMSH4
                                  WHEN A.GRUP='F' THEN R1.CMSH5
                                  WHEN A.GRUP='G' THEN R1.CMSH6
                                  WHEN A.GRUP='H' THEN R1.CMSH7
                                  WHEN A.GRUP='I' THEN R1.CMSH8
                                  WHEN A.GRUP='J' THEN R1.CMSH9
                                  WHEN A.GRUP='K' THEN R1.CMSH10
                                  WHEN A.GRUP='L' THEN R1.CMSH11
                                  WHEN A.GRUP='M' THEN R1.CMSH12
                                  WHEN A.GRUP='N' THEN R1.CMSH13
                                  WHEN A.GRUP='O' THEN R1.CMSH14
                                  WHEN A.GRUP='P' THEN R1.CMSH15
                                  WHEN A.GRUP='Q' THEN R1.CMSH16
                                  WHEN A.GRUP='R' THEN R1.CMSH17
                                  WHEN A.GRUP='S' THEN R1.CMSH18
                                  WHEN A.GRUP='T' THEN R1.CMSH19
                                  ELSE                 R1.CMSH
                             END,       
             B.VLERASH     = ROUND(B.SASI*CASE WHEN A.GRUP='A' THEN R1.CMSH
                                               WHEN A.GRUP='B' THEN R1.CMSH1
                                               WHEN A.GRUP='C' THEN R1.CMSH2
                                               WHEN A.GRUP='D' THEN R1.CMSH3
                                               WHEN A.GRUP='E' THEN R1.CMSH4
                                               WHEN A.GRUP='F' THEN R1.CMSH5
                                               WHEN A.GRUP='G' THEN R1.CMSH6
                                               WHEN A.GRUP='H' THEN R1.CMSH7
                                               WHEN A.GRUP='I' THEN R1.CMSH8
                                               WHEN A.GRUP='J' THEN R1.CMSH9
                                               WHEN A.GRUP='K' THEN R1.CMSH10
                                               WHEN A.GRUP='L' THEN R1.CMSH11
                                               WHEN A.GRUP='M' THEN R1.CMSH12
                                               WHEN A.GRUP='N' THEN R1.CMSH13
                                               WHEN A.GRUP='O' THEN R1.CMSH14
                                               WHEN A.GRUP='P' THEN R1.CMSH15
                                               WHEN A.GRUP='Q' THEN R1.CMSH16
                                               WHEN A.GRUP='R' THEN R1.CMSH17
                                               WHEN A.GRUP='S' THEN R1.CMSH18
                                               WHEN A.GRUP='T' THEN R1.CMSH19
                                               ELSE                 R1.CMSH
                                          END, 2)     
                                               
        FROM #TmpFD A INNER JOIN #TmpFDScr B  ON A.NRRENDOR=B.NRD
                      INNER JOIN ARTIKUJ   R1 ON B.KARTLLG=R1.KOD;

      UPDATE A
         SET A.ORDERSCR = ISNULL(B.Nr,0)
        FROM #TmpFDScr A INNER JOIN
                        ( 
                          SELECT NRD, KARTLLG, Nr=Row_Number() OVER(PARTITION BY NRD ORDER BY NRD,KARTLLG) 
                            FROM #TmpFdScr 
                  
                           )        B ON A.NRD=B.NRD AND A.KARTLLG=B.KARTLLG;



        
-- A.        Fund Gjenerimi i tabelave temporare FD,FDSCR

        
        
        
-- B.        Gjenerimi i tabelave temporare FH, FHSCR


      INSERT INTO #TmpFH
            (TIP,KMAG,NRMAG,DATEDOK,NRDOK,NRFRAKS,DOK_JB,DST,GRUP,SHENIM1,
             KMAGRF,KMAGLNK,NRDOKLNK,NRFRAKSLNK,DATEDOKLNK,
             USI,USM,TAGNR,TAGRND)
      SELECT TIP           = 'H',
             KMAG          = A.KMAGRF,
             NRMAG         = (SELECT NRRENDOR FROM MAGAZINA R2 WHERE R2.KOD=A.KMagRF),
             A.DATEDOK,
             NRDOK         = Row_Number() OVER(PARTITION BY KMAGRF,YEAR(DATEDOK) ORDER BY KMAGRF,DATEDOK),
             NRFRAKS       = 0,
             A.DOK_JB,
             A.DST,
             A.GRUP,
             SHENIM1       = 'Kthim malli nga '+ISNULL(A.KMAG,''),
             KMAGRF        = A.KMAG, KMAGLNK=A.KMAG, NRDOKLNK=A.NRDOK, NRFRAKSLNK=A.NRFRAKS, DATEDOKLNK=A.DATEDOK,
             A.USI,
             A.USM,
             TAGNR         = A.NRRENDOR,
             TAGRND        = @TagRND
        FROM #TmpFD A
    ORDER BY A.DATEDOK, A.KMAG;

      UPDATE #TmpFH
         SET NRDOK         = ISNULL(NRDOK,1)+ISNULL((SELECT NRMAX FROM #TmpNrDok B WHERE B.KMAG=#TmpFH.KMAG AND B.VITI=YEAR(#TmpFH.DATEDOK) AND B.TIP='H'),0);



      UPDATE A                                          -- Update Referencat per lidhje dokumentash transferimi
         SET A.KMAGRF      = B.KMAG,
             A.KMAGLNK     = B.KMAG,
             A.NRDOKLNK    = B.NRDOK,
             A.NRFRAKSLNK  = B.NRFRAKS
        FROM #TmpFD A INNER JOIN #TmpFH B ON A.NRRENDOR=B.TAGNR


      INSERT INTO #TMPFHSCR
            (KOD,KARTLLG,KODAF,PERSHKRIM,SASI,NJESI,
             CMIMM,VLERAM,CMIMSH,VLERASH,CMIMBS,VLERABS,CMIMOR,VLERAOR,
             KOEFSHB,NJESINV,TIPKLL,BC,KONVERTART,PROMOC,KOMENT,ORDERSCR,GJENROWAUT,GJENROWRVL,NRRENDKLLG,
             TAGNR)  
      SELECT KOD          = ISNULL(B.KMAGRF,'')+'.'+A.KARTLLG+'...',
             A.KARTLLG, A.KODAF,  A.PERSHKRIM, A.SASI, A.NJESI, A.CMIMM, A.VLERAM, A.CMIMSH, A.VLERASH,A.CMIMBS, A.VLERABS, A.CMIMOR, A.VLERAOR,
             A.KOEFSHB, A.NJESINV, A.TIPKLL, A.BC, A.KONVERTART, A.PROMOC, A.KOMENT, A.ORDERSCR, A.GJENROWAUT, A.GJENROWRVL, A.NRRENDKLLG,
             A.NRD
        FROM #TmpFdScr A INNER JOIN #TmpFD B On A.NRD=B.NRRENDOR
    ORDER BY NRD,KARTLLG;
    

    
      UPDATE B
         SET B.NRD        = A.NRRENDOR,
             B.TAGNR      = A.NRRENDOR
        FROM #TmpFH A INNER JOIN #TmpFHScr B ON A.TagNr=B.TagNr;
         
-- SELECT * FROM #TMPFH    ORDER BY NRRENDOR
-- SELECT * FROM #TMPFHSCR ORDER BY NRD
-- SELECT * FROM #TMPFDSCR ORDER BY NRD
--RETURN             
  
--  Select Nr=(SELECT COUNT(*) FROM #TmpFdScr B WHERE A.NRRENDOR=B.NRD),* From #TmpFd A ORDER BY KMAG,DATEDOK
--  Select Nr=(SELECT COUNT(*) FROM #TmpFhScr B WHERE A.NRRENDOR=B.NRD),* From #TmpFh A ORDER BY KMAGLNK,DATEDOK;
        
--  RETURN;


-- B.        Fund Gjenerimi i tabelave temporare FH, FHSCR





-- U.        Kalimi ne te dhenat e nd/jes       




-- U.1       Kalimi i FD


-- U.1.1     Kalimi i #TmpFD ne FD

         SET @ListCommun   = dbo.Isd_ListFields2Tables('FD','#TmpFD','TAGNR,NRRENDOR,FIRSTDOK');

         SET @sSql= ' 
      INSERT INTO FD
            ('+@ListCommun+',TAGNR) 
      SELECT '+@ListCommun+',NRRENDOR
        FROM #TmpFD 
    ORDER BY YEAR(DATEDOK),NRDOK;';

       EXEC (@sSql);


-- U.1.2     Update NRD ne #TmpFDScr me vlerat e FD te sapo krijuara

      UPDATE #TmpFDScr SET NRD=0;

      UPDATE B 
         SET B.NRD = A.NRRENDOR 
        FROM FD A INNER JOIN #TmpFDScr B ON A.TAGNR=B.TAGNR 
       WHERE A.TagRND=@TagRnd  AND A.TAGNR<>0;  -- Kujdes @TagRnd


-- U.1.3     Kalimi i #TmpFDScr te krijuara ne FDScr

         SET @ListCommun = dbo.Isd_ListFields2Tables('FDSCR','#TMPFDSCR','NRRENDOR,TAGNR,TAGRND');

         SET @sSql= ' 
      INSERT INTO FDSCR 
            ('+@ListCommun+',TAGNR,TAGRND) 
      SELECT '+@ListCommun+',0,''''
        FROM #TMPFDSCR 
       WHERE NRD<>0 ';

       EXEC (@sSql);
       

-- U.1.4     Zerime vlera ne FD per FD e shtuara

      UPDATE FD    
         SET TAGNR         = 0,
             FIRSTDOK      = 'D'+CAST(NRRENDOR AS VARCHAR)  
       WHERE TAGRND=@TagRnd AND ISNULL(TAGNR,0)<>0;


-- U.1.5     Zerim TAGRND per FD

      UPDATE FD
         SET TAGRND=0 
       WHERE TAGRND=@TagRnd;
    

    
-- U.1       Fund Kalimi i FD







-- U.2       Kalimi i FH


-- U.2.1     Kalimi i #TmpFH ne FH

         SET @ListCommun   = dbo.Isd_ListFields2Tables('FH','#TmpFH','NRRENDOR,FIRSTDOK');

         SET @sSql= ' 
      INSERT INTO FH
            ('+@ListCommun+') 
      SELECT '+@ListCommun+'
        FROM #TmpFH 
    ORDER BY YEAR(DATEDOK),NRDOK;';

       EXEC (@sSql);


-- U.2.2     Update NRD ne #TmpFHScr me vlerat e FH te sapo krijuara

      UPDATE #TmpFHScr SET NRD=0;

      UPDATE B 
         SET B.NRD = A.NRRENDOR 
        FROM FH A INNER JOIN #TmpFHScr B ON A.TAGNR=B.TAGNR 
       WHERE A.TagRND=@TagRnd  AND A.TAGNR<>0;  -- Kujdes @TagRnd



-- U.2.3     Kalimi i #TmpFHScr te krijuara ne FHScr

         SET @ListCommun = dbo.Isd_ListFields2Tables('FHSCR','#TMPFHSCR','NRRENDOR,TAGNR,TAGRND');

         SET @sSql= ' 
      INSERT INTO FHSCR 
            ('+@ListCommun+',TAGNR,TAGRND) 
      SELECT '+@ListCommun+',0,''''
        FROM #TMPFHSCR 
       WHERE NRD<>0 ';

       EXEC (@sSql);
       
       
-- U.2.4     Zerime vlera ne FH per FH e shtuara

      UPDATE FH    
         SET TAGNR         = 0,
             FIRSTDOK      = 'H'+CAST(NRRENDOR AS VARCHAR)  
       WHERE TAGRND=@TagRnd AND ISNULL(TAGNR,0)<>0;

      SELECT @sSql = '';
      
      SELECT @sSql = @sSql + ','+CAST(CAST(NRRENDOR AS BIGINT) AS VARCHAR) 
        FROM FD 
       WHERE TAGRND=@TagRnd 
    ORDER BY NRRENDOR;


-- U.2.5     Zerim TAGRND ne FH

      UPDATE FH
         SET TAGRND = 0
       WHERE TAGRND=@TagRnd;



-- U.2       Fund kalimi i FH





/*
-- U5.       Kontroll dhe validim i te dhenave brenda nd/jes per FD dhe FH

      SELECT @sSql = '';
      
      SELECT @sSql = @sSql + ','+CAST(CAST(NRRENDOR AS BIGINT) AS VARCHAR) 
        FROM FD 
       WHERE TAGRND=@TagRnd 
    ORDER BY NRRENDOR;


         SET @i = 1;     
         SET @j = Len(@sSql) - Len(Replace(@sSql,',',''))+1;
         
       WHILE @i<=@j
         BEGIN
             SET @sNrRendor  = CAST([dbo].[Isd_StringInListStr](@sSql,@i,',') AS BIGINT);
             IF  @sNrRendor<>''
                 BEGIN
                   SET  @NrRendor = CAST(@sNrRendor AS BIGINT);                    --Print @NrRendor
                   EXEC dbo.Isd_DocSaveMG 'FD',@NrRendor,@Perdorues,@LgJob,'S','';
                 END;             
             SET @i = @i + 1;
         END;

         
         
-- U6.       Per FH

      SELECT @sSql = '';
      
      SELECT @sSql = @sSql + ','+CAST(CAST(NRRENDOR AS BIGINT) AS VARCHAR) 
        FROM FH 
       WHERE TAGRND=@TagRnd 
    ORDER BY NRRENDOR;


         SET @i = 1;     
         SET @j = Len(@sSql) - Len(Replace(@sSql,',',''))+1;
         
       WHILE @i<=@j
         BEGIN
             SET @sNrRendor  = CAST([dbo].[Isd_StringInListStr](@sSql,@i,',') AS BIGINT);
             IF  @sNrRendor<>''
                 BEGIN
                   SET  @NrRendor = CAST(@sNrRendor AS BIGINT);                    --Print @NrRendor
                   EXEC dbo.Isd_DocSaveMG 'FH',@NrRendor,@Perdorues,@LgJob,'S','';
                 END;             
             SET @i = @i + 1;
         END;
         
         
*/     

       

GO
