SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--   EXEC dbo.KostoMg3UpdDb '','zzz','01/01/2014', '31/01/2014',1,1,0,'##AAAAAAA','##BBBBBBB','MG,FJ,FK'

CREATE        PROCEDURE [dbo].[KostoMg3UpdDb]
(
  @pKMagKp        Varchar(30),
  @pKMagKs        Varchar(30),
  @pDateKp        Varchar(30),
  @pDateKs        Varchar(30),
  @pUpdCmArt      Bit,
  @pDeleteOld     Bit,
  @pCreateDocDIF  Bit,
  @pTableART      Varchar(50),
  @pTableDIF      Varchar(50),
  @pOper          Varchar(50)
)

AS

-- Kryen postimin ne baze te rezultatit te perpunuar ne tabele temporare

--     1. Ndryshohen vlerat tek Referenca ARTIKUJ

--     2. Postimi i vlerave te reja ne Fhscr dhe Fdscr ne baze

--     3. Postohen vlerat e reja tek tabela FjScr (me vete sepse ke edhe produktin...!)

--     4. Delete Fk per FH dhe FD te ndryshuara

--     5. Krijim dokumenti FH me diferencat (kur @pOper='MG' dhe @pCreateDocDIF=True)


         SET NOCOUNT ON

     DECLARE @sKMagKp         Varchar(30),
             @sKMagKs         Varchar(30),
             @sDateKp         Varchar(20),
             @sDateKs         Varchar(20),
             @UpdCmArt        Bit,
             @DeleteOld       Bit,
             @CreateDocDIF    Bit,
             @TableArtikuj    Varchar(50),
             @TableDiffer     Varchar(50),
             @sOper           Varchar(50),
             @sSql            Varchar(MAX);

         SET @sKMagKp       = @pKMagKp;
         SET @sKMagKs       = @pKMagKs;
         SET @sDateKp       = CONVERT(VARCHAR(12),@pDateKp,104);
         SET @sDateKs       = CONVERT(VARCHAR(12),@pDateKs,104);
         SET @UpdCmArt      = @pUpdCmArt;
         SET @DeleteOld     = @pDeleteOld;
         SET @CreateDocDIF  = @pCreateDocDIF;
         SET @TableArtikuj  = @pTableART;
         SET @TableDiffer   = @pTableDIF;

         SET @sOper         = @pOper;


       IF CHARINDEX('MG',@sOper)>0         --    Ndryshohen vlerat tek Referenca ARTIKUJ,Dokumenta Magazine
          BEGIN

              IF @UpdCmArt=1
                 BEGIN 
                                           -- 1. Ndryshohen vlerat tek Referenca ARTIKUJ
                   EXEC      dbo.Isd_UpdateCmimMgArtikuj @sDateKs, @TableArtikuj;
                   RAISERROR ('', 0, 1) WITH NOWAIT;
                   
                 END;


                                           -- 2. Postimi i vlerave te reja ne Fhscr dhe Fdscr ne baze
                 SET @sSql = '
   

                  IF '+CAST(@DeleteOld AS VARCHAR)+'=1
                     BEGIN                                                                     -- FSHIRJE E FH TE VJETRA (SISTEMUESE NE VLEFTE)

                                                                         -- 1. Fshirje FHSCR

                          DELETE B                                                             -- Kjo tabele (@TableDiffer) u mbush tek dbo.KostoMg2Tmp
                            FROM '+@TableDiffer+' A INNER JOIN FHSCR B ON A.NRD=B.NRD          -- Keto reshta u fshine nga tabela temporare tek dbo.KostoMg2Tmp por jo nga baza
                           WHERE ISNULL(B.GJENROWRVL,0)=1;                                     -- per keto reshta te dokumentave kemi GJENROWRVL=1  (True)


                       -- Fshirja e dokumentave FH qe pas fshirjeve te reshtave te vjetra te rivleresuara 
                       -- mund te jene dokumenta pa reshta (per FD ska nevoje .... Kujdes fshihen e dhe FK e tyre.


                          DELETE FK                                      -- 2. Fshirje FK
                            FROM 
                              (
                                 SELECT NRROWS=(SELECT COUNT(*) FROM FHSCR B WHERE B.NRD=A.NRD GROUP BY B.NRD), A.NRD
                                   FROM '+@TableDiffer+' A 
                               GROUP BY A.NRD

                               ) A           INNER JOIN FH ON A.NRD=FH.NRRENDOR
                                             INNER JOIN FK ON FH.NRDFK=FK.NRRENDOR AND FK.ORG=''H''

                           WHERE ISNULL(A.NRROWS,0)=0 AND ISNULL(FH.NRDFK,0)<>0;

                       RAISERROR ('''', 0, 1) WITH NOWAIT;
                       

                          DELETE FH                                      -- 3. Fshirje FH
                            FROM 
                              (
                                 SELECT NRROWS=(SELECT COUNT(*) FROM FHSCR B WHERE B.NRD=A.NRD GROUP BY B.NRD), A.NRD
                                   FROM '+@TableDiffer+' A 
                               GROUP BY A.NRD

                               ) A           INNER JOIN FH ON A.NRD=FH.NRRENDOR

                           WHERE ISNULL(A.NRROWS,0)=0;

                       RAISERROR ('''', 0, 1) WITH NOWAIT;
                       
                     END;
                     
                     


              UPDATE A 
                 SET A.CMIMM = B.CMIMMNEW, A.VLERAM = B.VLERAMNEW, A.CMIMOR = B.CMIMMNEW, A.VLERAOR = B.VLERAMNEW                    
                FROM '+@TableArtikuj+' B INNER JOIN FHSCR A ON B.NRRENDOR=A.NRRENDOR 
               WHERE B.TIP=''H'' AND 
                    (
                     ( ISNULL(B.DOK_JB,0)=0 AND ISNULL(B.CMIMUPDATE,0)=1 AND CHARINDEX('',''+ISNULL(DST,'''')+'','','',SI,BL,CE,'')=0 )
                       OR
                     ( ISNULL(B.DOK_JB,0)=1 AND ISNULL(B.CMIMUPDATE,0)=1 AND ISNULL(B.DST,'''')=''SH'' )       -- Rasti FH Amballazhi nga Shitja
                     ); 
                     
              RAISERROR ('''', 0, 1) WITH NOWAIT;

              UPDATE A 
                 SET A.CMIMM = B.CMIMMNEW, A.VLERAM = B.VLERAMNEW, A.CMIMOR = B.CMIMMNEW, A.VLERAOR = B.VLERAMNEW  
                FROM '+@TableArtikuj+' B INNER JOIN FDSCR A ON B.NRRENDOR=A.NRRENDOR 
               WHERE B.TIP=''D'' AND ISNULL(B.CMIMUPDATE,0)=1 AND   
                     CHARINDEX('',''+ISNULL(DST,'''')+'','','',SI,BL,CE,'')=0;
                  -- Test i tepert ndoshta tek FD per DST (tek FH ka kuptim) ..! ';
           -- PRINT  @sSql;
              EXEC  (@sSql);
             
         END;

       RAISERROR ('', 0, 1) WITH NOWAIT;

       IF CHARINDEX('FJ',@sOper)>0         -- 3. Postohen vlerat e reja tek tabela FjScr (me vete sepse ke edhe produktin...!)
          BEGIN
                                
                 SET @sSql = '

              UPDATE B2 
                 SET B2.VLERAM = ROUND(A2.CMIMM * B2.SASI, 3) 
                FROM FD A1 INNER JOIN FDSCR A2 ON A1.NRRENDOR    = A2.NRD 
                           INNER JOIN FJSCR B2 ON A1.NRRENDORFAT = B2.NRD AND A2.KARTLLG=B2.KARTLLG AND B2.TIPKLL=''K''
               WHERE (A1.DOK_JB=1 AND A1.NRRENDORFAT<>0) AND
                     (A1.KMAG>='''+@sKMagKp+''' AND A1.KMAG<='''+@sKMagKs+''') AND 
                     (A1.DATEDOK>=CONVERT(DATETIME,'''+@sDateKp+''',104)       AND 
                      A1.DATEDOK<=CONVERT(DATETIME,'''+@sDateKs+''',104))      AND 

                     (A2.GJENROWAUT=0) ';

           -- PRINT  @sSql;
              EXEC  (@sSql);

/*
                 SET @sSql = '

              UPDATE B2 
                 SET B2.VLERAM = ROUND(A2.CMIMM * B2.SASI, 3) 
                FROM FD A1 INNER JOIN FJ    B1 ON A1.NRRENDORFAT = B1.NRRENDOR 
                           INNER JOIN FDSCR A2 ON A1.NRRENDOR    = A2.NRD 
                           INNER JOIN FJSCR B2 ON B1.NRRENDOR    = B2.NRD
               WHERE (A1.KMAG>='''+@sKMagKp+''' AND A1.KMAG<='''+@sKMagKs+''') AND (A1.DOK_JB=1 AND A1.NRRENDORFAT<>0) AND
                     (A1.DATEDOK>=CONVERT(DATETIME,'''+@sDateKp+''',104)     AND 
                      A1.DATEDOK<=CONVERT(DATETIME,'''+@sDateKs+''',104))    AND 
                     (A2.KARTLLG=B2.KARTLLG) ';
           -- PRINT  @sSql;
              EXEC  (@sSql);

*/ 

         END;

       RAISERROR ('', 0, 1) WITH NOWAIT;

       IF CHARINDEX('FK',@sOper)>0         -- 4. Delete Fk per FH dhe FD te ndryshuara
          BEGIN
                                
                 SET @sSql = '
 
              DELETE A 
                FROM FK A 
               WHERE (ORG=''H'')   AND (A.KMAG>='''+@sKMagKp+''' AND A.KMAG<='''+@sKMagKs+''') AND 
                     (A.DATEDOK>=CONVERT(DATETIME,'''+@sDateKp+''',104)  AND 
                      A.DATEDOK<=CONVERT(DATETIME,'''+@sDateKs+''',104)) AND
                     ( EXISTS ( SELECT NRRENDOR 
                                  FROM FH B 
                                 WHERE B.NRDFK<>0 AND B.NRDFK=A.NRRENDOR ));
         
              RAISERROR ('''', 0, 1) WITH NOWAIT;

              UPDATE A 
                 SET NRDFK=0 
                FROM FH A 
               WHERE (A.NRDFK<>0)  AND (A.KMAG>='''+@sKMagKp+''' AND A.KMAG<='''+@sKMagKs+''') AND 
                     (A.DATEDOK>=CONVERT(DATETIME,'''+@sDateKp+''',104)  AND 
                      A.DATEDOK<=CONVERT(DATETIME,'''+@sDateKs+''',104));


              RAISERROR ('''', 0, 1) WITH NOWAIT;

              DELETE A 
                FROM FK A 
               WHERE (ORG=''D'')   AND (A.KMAG>='''+@sKMagKp+''' AND A.KMAG<='''+@sKMagKs+''') AND 
                     (A.DATEDOK>=CONVERT(DATETIME,'''+@sDateKp+''',104)  AND 
                      A.DATEDOK<=CONVERT(DATETIME,'''+@sDateKs+''',104)) AND
                     ( EXISTS ( SELECT NRRENDOR 
                                  FROM FD B 
                                 WHERE B.NRDFK<>0 AND B.NRDFK=A.NRRENDOR ));
         
              RAISERROR ('''', 0, 1) WITH NOWAIT;

              UPDATE A 
                 SET NRDFK=0 
                FROM FD A 
               WHERE (A.NRDFK<>0)  AND (A.KMAG>='''+@sKMagKp+''' AND A.KMAG<='''+@sKMagKs+''') AND 
                     (A.DATEDOK>=CONVERT(DATETIME,'''+@sDateKp+''',104)  AND 
                      A.DATEDOK<=CONVERT(DATETIME,'''+@sDateKs+''',104)); ';
           -- PRINT  @sSql;
              EXEC  (@sSql);


          END;

       RAISERROR ('', 0, 1) WITH NOWAIT;


--PRINT 'BBBB';
--PRINT @CreateDocDIF
--PRINT @sOper;
       IF (CHARINDEX('MG',@sOper)=0) OR  (@CreateDocDIF=0)
          RETURN;

--PRINT 'CCCC';

       IF (CHARINDEX('MG',@sOper)>0) AND (@CreateDocDIF=1)       -- 5. Krijim dokumenti FH me diferencat
          BEGIN

               IF OBJECT_ID('TEMPDB..#TMPFH')    is not null
                  DROP TABLE #TMPFH;
               IF OBJECT_ID('TEMPDB..#TMPFHSCR') is not null
                  DROP TABLE #TMPFHSCR;
               IF OBJECT_ID('TEMPDB..#TMPFHNR')  is not null
                  DROP TABLE #TMPFHNR;


               SELECT * INTO #TMPFH    FROM FH      WHERE 2=1;
               SELECT * INTO #TMPFHSCR FROM FHSCR   WHERE 2=1;
               ALTER TABLE   #TMPFHSCR ADD  KMAG    VARCHAR(10)  NULL
               ALTER TABLE   #TMPFHSCR ADD  DATEDOK DATETIME     NULL
               ALTER TABLE   #TMPFHSCR ADD  KODLM   VARCHAR(100) NULL



            --  Koka e dokumentit

             EXEC ( '
           INSERT INTO #TMPFHSCR
                 (KMAG,    DATEDOK, KARTLLG, VLERAM,            CMIMM,      KODLM   )
           SELECT KMAGDIF, DATEDOK, KARTLLG, SUM(VLERAMDIF),MAX(CMIMM), MAX(KODLMDIF)
             FROM '+@TableArtikuj+'
         GROUP BY KMAGDIF,DATEDOK,KARTLLG
           HAVING SUM(VLERAMDIF)<>0
         ORDER BY KMAGDIF,DATEDOK,KARTLLG;');



           INSERT INTO #TMPFH
                 (KMAG, DATEDOK,     KODLM)
           SELECT KMAG, DATEDOK, MAX(KODLM)
             FROM #TMPFHSCR
         GROUP BY KMAG,DATEDOK
         ORDER BY KMAG,DATEDOK;

        RAISERROR ('', 0, 1) WITH NOWAIT;


-- Rinumurimi

                                                       -- Zevendesoi pjesen e komentuar me poshte, 15.10.19 
           SELECT KMAG, DATEDOK, NRDOK = ISNULL(NRDOKMAX,0)+ROW_NUMBER() OVER (PARTITION BY KMAG,VITI ORDER BY KMAG,DATEDOK)
             INTO #TMPFHNR
             FROM 
               (    SELECT KMAG, DATEDOK, VITI=YEAR(A.DATEDOK),
                           NRDOKMAX = ( SELECT MAX(B.NRDOK) FROM FH B WHERE A.KMAG=B.KMAG AND YEAR(A.DATEDOK)=YEAR(B.DATEDOK) )
                      FROM #TMPFH A
                  GROUP BY KMAG,DATEDOK  )    A
         ORDER BY KMAG,DATEDOK;
         

 /*        SELECT KMAG,                                -- Komentuar 15.10.19 sepse u zevendesua nga paragrafi me siper
                  DATEDOK,
                  NRDOK = ISNULL(NRDOK,0)  --CASE WHEN ISNULL(NRDOK,0)=0 THEN 1 ELSE NRDOK END
             INTO #TMPFHNR
             FROM 

             (
                   SELECT KMAG, DATEDOK, 
                          NRDOK = ( SELECT MAX(NRDOK) 
                                      FROM FH B                                                -- ?? A duhet B.DATEDOK<=A.DATEDOK
                                     WHERE A.KMAG=B.KMAG AND YEAR(B.DATEDOK)=YEAR(A.DATEDOK) AND B.DATEDOK<=A.DATEDOK )
                     FROM #TMPFH A
                 GROUP BY KMAG,DATEDOK

                ) A

         ORDER BY KMAG;

        RAISERROR ('', 0, 1) WITH NOWAIT;

           UPDATE #TMPFHNR
              SET NRDOK = B.NRDOK
             FROM #TMPFHNR A INNER JOIN 

                 (  SELECT KMAG, DATEDOK, NRDOK = Row_Number() OVER (PARTITION BY KMAG,YEAR(DATEDOK) ORDER BY KMAG,DATEDOK)
                      FROM #TMPFHNR 
                     WHERE ISNULL(NRDOK,0)=0 
                  ) B
                        ON A.KMAG=B.KMAG AND A.DATEDOK=B.DATEDOK

            WHERE ISNULL(A.NRDOK,0)=0 */
           

        RAISERROR ('', 0, 1) WITH NOWAIT;


           UPDATE A
              SET TIP            = 'H', 
                  NRMAG          = B.NRRENDOR,
                  NRDOK          = C.NRDOK,
                  NRFRAKS        = 1,
                  NRSERIAL       = '',
                  KMAGRF         = '',
                  SHENIM1        = 'Dokument korigjimi kosto magazine',
                  SHENIM2        = '',
                  SHENIM3        = '', 
                  SHENIM4        = '',
                  GRUP           = B.GRUP,
                  DOK_JB         = 0,
                  DST            = 'SI',
                  NRRENDORFAT    = 0,
                  KMAGLNK        = '',
                  NRDOKLNK       = 0,
                  NRFRAKSLNK     = 0,
                  VLEXTRA        = 0,
                  EXTMGFIELD     = '',
                  EXTMGVLORIGJ   = '',
                  EXTMGFORME     = '',
                  FAKLS          = '',
                  FADESTIN       = '',
                  FABUXHET       = '',
                  NRDOKUP        = '',
                  ISAMB          = 0,
                  NRRENDORFATAMB = 0,
                  CMPRODCALCUL   = 0,
                  NRDFK          = 0,
                  POSTIM         = 0,
                  LETER          = 0,
                  DATECREATE     = GETDATE(),
                  USI            = '',
                  USM            = '',
                  TAGNR          = A.NRRENDOR,
                  TAG            = 0,
                  TROW           = 0
             FROM #TMPFH A LEFT JOIN MAGAZINA B ON A.KMAG=B.KOD
                           LEFT JOIN #TMPFHNR C ON A.KMAG=C.KMAG AND A.DATEDOK=C.DATEDOK;

        RAISERROR ('', 0, 1) WITH NOWAIT;


           UPDATE A
              SET NRFRAKS = ISNULL(B.NRFRAKS,0) + 1
             FROM #TMPFH A LEFT JOIN 
                         
                    (   SELECT KMAG, NRDOK, NRFRAKS=( SELECT MAX(ISNULL(NRFRAKS,0)) FROM FH B WHERE A.KMAG=B.KMAG AND B.NRDOK=A.NRDOK )
                          FROM #TMPFH A
                      GROUP BY A.KMAG,A.NRDOK ) B 
                                                  ON A.KMAG=B.KMAG AND A.NRDOK=B.NRDOK


               -- Reshta dokumenti (artikujt)


        RAISERROR ('', 0, 1) WITH NOWAIT;

           UPDATE A
              SET KOD            = KMAG+'.'+KARTLLG+'...',
                  KODAF          = KARTLLG,
                  PERSHKRIM      = B.PERSHKRIM,
                  NJESI          = B.NJESI,
                  KOMENT         = 'Dokument korigjimi kosto magazine',
                  NRRENDKLLG     = B.NRRENDOR,
                  SASI           = 0,
               -- CMIMM          = 0,
                  CMIMSH         = B.CMSH,
                  VLERASH        = 0,
                  VLERAFT        = 0,
                  CMIMBS         = 0,
                  VLERABS        = 0,
                  KOEFSHB        = 1,
                  NJESINV        = B.NJESI,
                  TIPKLL         = 'K',
                  BC             = B.BC,
                  KONVERTART     = B.KONV2,
                  KMON           = '',
                  PROMOC         = 0,
                  PROMOCTIP      = '',
                  RIMBURSIM      = '',
                  SERI           = '',
                  ORDERSCR       = 0,
                  STATROW        = '',
                  GJENROWAUT     = 0,
                  CMIMOR         = 0,
                  VLERAOR        = 0,
                  TIPFR          = '', 
                  SASIFR         = 0,
                  VLERAFR        = '',
                  LLOGLM         = '',
                  FBARS          = '',
                  FCOLOR         = '',
                  FLENGTH        = 0,
                  FPROFIL        = '',
                  KOEFICIENT     = 0,
                  KLSART         = '',
                  FAKLS          = '',
                  FADESTIN       = '',
                  FASTATUS       = '',
                  PESHANET       = B.PESHANET,
                  PESHABRT       = B.PESHABRT,
                  PROMOCKOD      = '',
                  ISAMB          = 0,
                  KODKLF         = '',
                  NRSERIAL       = '',
                  GJENROWRVL     = 1,
                  TAGNR          = 0,
                  TROW           = 0
             FROM #TMPFHSCR A LEFT JOIN ARTIKUJ  B ON A.KARTLLG=B.KOD;


        RAISERROR ('', 0, 1) WITH NOWAIT;


           UPDATE A
              SET NRD   = B.NRRENDOR,
                  TAGNR = B.NRRENDOR
             FROM #TMPFHSCR A INNER JOIN #TMPFH B ON A.KMAG=B.KMAG AND A.DATEDOK=B.DATEDOK;


            ALTER TABLE #TMPFHSCR DROP COLUMN KMAG;
            ALTER TABLE #TMPFHSCR DROP COLUMN DATEDOK;

-- SELECT * FROM #TMPFH
-- SELECt * FROM #TMPFHSCR
-- SELECT * FROM #TMPFHNR


               -- Kalimi ne Database

          DECLARE @sListFields Varchar(Max);

              SET @sListFields = dbo.Isd_ListFields2Tables('FH','#TMPFH','NRRENDOR')

             EXEC (' 
           INSERT INTO FH
                 (' + @sListFields + ')
           SELECT ' + @sListFields + '
             FROM #TMPFH
         ORDER BY KMAG,DATEDOK ');

        RAISERROR ('', 0, 1) WITH NOWAIT;

           UPDATE A
              SET NRD=B.NRRENDOR
             FROM #TMPFHSCR A INNER JOIN FH B ON A.TAGNR=B.TAGNR;


              SET @sListFields = dbo.Isd_ListFields2Tables('FHSCR','#TMPFHSCR','NRRENDOR')

             EXEC (' 
           INSERT INTO FHSCR
                 (' + @sListFields + ')
           SELECT ' + @sListFields + '
             FROM #TMPFHSCR
         ORDER BY NRD,KARTLLG ');

        RAISERROR ('', 0, 1) WITH NOWAIT;


           UPDATE FH SET TAGNR=0 WHERE ISNULL(TAGNR,0)<>0;


               IF OBJECT_ID('TEMPDB..#TMPFH')    is not null
                  DROP TABLE #TMPFH;
               IF OBJECT_ID('TEMPDB..#TMPFHSCR') is not null
                  DROP TABLE #TMPFHSCR;
               IF OBJECT_ID('TEMPDB..#TMPFHNR')  is not null
                  DROP TABLE #TMPFHNR;


          END;
GO
