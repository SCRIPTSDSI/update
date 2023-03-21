SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--   EXEC dbo.KostoMg4TestUpd '','zzz','01/02/2017', '30/04/2017','FH,FD',2,0

CREATE        PROCEDURE [dbo].[KostoMg4TestUpd]
(
  @PKMagKp        Varchar(30),
  @PKMagKs        Varchar(30),
  @PDateKp        Varchar(30),
  @PDateKs        Varchar(30),
  @PDocuments     Varchar(30),
  @PTest          Int,
  @PUpdate        Bit
)

AS

-- Testi jo i detajuar, por kryesisht per fushen DST te dokumentave FH,FD,
-- Vlera e fushes DST (tek procedura e re) ka rendesi shume ne riveresimin  te magazines.

-- 1.  Pra FH quhet e gabuar ne se: 
--     1.a   DST='BL dhe nuk vjen nga fature blerje, por nga levizje brendeshme.
--     1.b   Fature blerje dhe DST<>'BL'.
--     1.c   Rastin (DOK_JB=1 and ISAMB=True) por DST<>'SH', pra vjen nga nje dokument FJ dhe eshte amballazh. 

-- 2.  Pra FD quhet e gabuar ne se: 
--     2.a  DST='SH' por nuk vjen nga fature shitje, por nga levizje e brendeshme.

-- 3.  Teston fushat qe nisin me sasi negative(kryesisht ato me kthim malli).


     DECLARE @sKMagKp         Varchar(30),
             @sKMagKs         Varchar(30),
             @sDateKp         Varchar(20),
             @sDateKs         Varchar(20),
             @Documents       Varchar(30),
             @Test            Int,
             @Update          Bit;

         SET @sKMagKp       = @PKMagKp;
         SET @sKMagKs       = @PKMagKs;
         SET @sDateKp       = CONVERT(VARCHAR(12),@PDateKp,104);
         SET @sDateKs       = CONVERT(VARCHAR(12),@PDateKs,104);
         SET @Documents     = @PDocuments;
         SET @Test          = @PTest;
         SET @Update        = @PUpdate;



-- Fillim Test



          IF @Test = 1
             BEGIN

                 Select DOK      = 'FH',
                        KMAG,DATEDOK,NRDOK,NRFRAKS,DST,
                        SHENIM1,SHENIM2,KMAGRF,KMAGLNK,
                        FATURE   = CASE WHEN ISNULL(A.DOK_JB,0)=1 THEN CASE WHEN ISNULL(A.ISAMB,0)=1 THEN 'FJ-Amballazh' ELSE 'FF' END
                                        ELSE '' 
                                   END,
                        DOK_JB, 
                        ERRORMSG = 'Origjine gabim: '''+ISNULL(A.DST,'')+''' ',
                        ERRORCOD = '1',
                        TIP      = 'H',
                        NRRENDOR,TAGNR,TROW 
                   From FH A
                  Where ( A.KMAG>=@sKMagKp AND A.KMAG<=@sKMagKs )     AND 
                        ( A.DATEDOK>=CONVERT(DATETIME,@sDateKp,104)   AND 
                          A.DATEDOK<=CONVERT(DATETIME,@sDateKs,104) ) AND

                        ( 
                         (ISNULL(A.DOK_JB,0)=1 AND CHARINDEX(','+ISNULL(A.DST,'')+',',',BL,SH,')=0) OR 
                         (ISNULL(A.DOK_JB,0)=0 AND CHARINDEX(','+ISNULL(A.DST,'')+',',',BL,SH,')>0)
                         ) 

                        
               Union All

                 Select DOK      = 'FD',
                        KMAG,DATEDOK,NRDOK,NRFRAKS,DST,
                        SHENIM1,SHENIM2,KMAGRF,KMAGLNK,
                        FATURE   = CASE WHEN ISNULL(DOK_JB,0)=1 THEN 'FJ' ELSE '' END, 
                        DOK_JB,
                        ERRORMSG = 'Destinacion gabim: '+ISNULL(A.DST,''),
                        ERRORCOD = '2',
                        TIP      = 'D',
                        NRRENDOR,TAGNR,TROW
                   From FD A
                  Where ( A.KMAG>=@sKMagKp AND A.KMAG<=@sKMagKs )     AND 
                        ( A.DATEDOK>=CONVERT(DATETIME,@sDateKp,104)   AND 
                          A.DATEDOK<=CONVERT(DATETIME,@sDateKs,104) ) AND

                        ( 
                         (ISNULL(A.DOK_JB,0)=1 AND ISNULL(A.DST,'')<>'SH') OR 
                         (ISNULL(A.DOK_JB,0)=0 AND ISNULL(A.DST,'') ='SH') 
                         ); 

             END;



          IF @Test = 2  
             BEGIN

          --            Testohen Artikujt qe mund te kene problem perseri pas rivleresimit 
          --            per aresye te mungeses se dokumentit fillestar: Blerje,Celje,Sistemim


                     IF OBJECT_ID('TEMPDB..#TableRV1') IS NOT NULL
                        DROP TABLE #TableRV1;
             
           -- 1.        Zgjidhen Artikujt qe skane veprime para periudhes qe po vleresohet.

                 SELECT DTMIN     = MIN(A.DTMIN),
                        EXISTRV   = MAX(A.EXISTRV),
                     -- KMAG,
                        KARTLLG
                   INTO #TABLERV1     
                   FROM
                (
                        SELECT DTMIN    = MIN(CASE WHEN DATEDOK>=CONVERT(DATETIME,@pDateKp,104) THEN DATEDOK ELSE 0 END),
                               EXISTRV  = MAX(CASE WHEN DATEDOK< CONVERT(DATETIME,@pDateKp,104) THEN 1       ELSE 0 END),
                            -- KMAG,
                               KARTLLG,
                               DOKUMENT = 'FH' 
                          FROM FH A INNER JOIN FHSCR B ON A.NRRENDOR=B.NRD 
                      -- WHERE (1=1) AND  ISNULL(B.SASI,0)<>0                -- ishte perpara 05.05.2017
                         WHERE (1=1) AND (ISNULL(B.SASI,0)<>0 OR A.DST='SI') -- u shtua       05.05.2017
                      GROUP BY KARTLLG  -- KMAG,
    
                     UNION ALL
     
                        SELECT DTMIN    = MIN(CASE WHEN DATEDOK>=CONVERT(DATETIME,@pDateKp,104) THEN DATEDOK ELSE 0 END),
                               EXISTRV  = MAX(CASE WHEN DATEDOK< CONVERT(DATETIME,@pDateKp,104) THEN 1       ELSE 0 END),
                            -- KMAG,
                               KARTLLG,
                               DOKUMENT = 'FD' 
                          FROM FD A INNER JOIN FDSCR B ON A.NRRENDOR=B.NRD 
                      -- WHERE (1=1) AND  ISNULL(B.SASI,0)<>0                -- ishte perpara 05.05.2017
                         WHERE (1=1) AND (ISNULL(B.SASI,0)<>0 OR A.DST='SI') -- u shtua       05.05.2017
                      GROUP BY KARTLLG  -- KMAG,
                   ) A
               GROUP BY KARTLLG  -- KMAG,
                 HAVING MAX(A.EXISTRV)<1
               ORDER BY KARTLLG; -- KMAG,
    
    
           -- 2.     Zgjidhen Artikujt qe ne veprimin e pare nuk jane DST='CE,BL,SI'.


                 SELECT DTFILLIM = T1.DTMIN,
                        KOD      = T1.KARTLLG,
                        R1.PERSHKRIM,
                        R1.NJESI,
                        KLASIF1  = ISNULL(R1.KLASIF, ''),
                        KLASIF2  = ISNULL(R1.KLASIF2,''),
                        KLASIF3  = ISNULL(R1.KLASIF3,''),
                        ERRORMSG = 'Nuk ka rivlersim para periudhe, dokumenti pare i periudhes jo ''CE,BL,SI'' ',
                        NRRENDOR = R1.NRRENDOR,
                        ERRORCOD = '1',
                        TROW     = CAST(0 AS BIT)
                   FROM #TableRV1 T1 LEFT JOIN ARTIKUJ R1 ON T1.KARTLLG=R1.KOD
                  WHERE NOT EXISTS (
                                       SELECT 1 
                                         FROM FH A INNER JOIN FHSCR B ON A.NRRENDOR=B.NRD 
                                        WHERE A.DATEDOK=T1.DTMIN AND B.KARTLLG=T1.KARTLLG AND CHARINDEX(','+ISNULL(A.DST,'')+',',',CE,BL,SI,')>0
                                     GROUP BY A.DATEDOK,B.KARTLLG 
                                            ) 
               ORDER BY T1.KARTLLG
           
                     IF OBJECT_ID('TEMPDB..#TableRV1') IS NOT NULL
                        DROP TABLE #TableRV1;

             END;


             
-- Fund Test



          IF @Update = 1
             BEGIN
                 UpDate A 
                    Set DST = CASE WHEN ISNULL(A.DOK_JB,0)=1 
                                        THEN CASE WHEN ISNULL(A.ISAMB,0)=1 THEN 'SH' ELSE 'BL' END
                                   WHEN ISNULL(A.DOK_JB,0)=0 AND CHARINDEX(','+ISNULL(A.DST,'')+',',',BL,SH,')>0
                                        THEN ''
                                   ELSE 
                                        A.DST
                              END
                   From FH A
                  Where CHARINDEX(',FH,',','+@Documents+',')>0        AND
                        ( A.KMAG>=@sKMagKp AND A.KMAG<=@sKMagKs )     AND 
                        ( A.DATEDOK>=CONVERT(DATETIME,@sDateKp,104)   AND 
                          A.DATEDOK<=CONVERT(DATETIME,@sDateKs,104) ) AND

                        ( 
                         (ISNULL(A.DOK_JB,0)=1 AND CHARINDEX(','+ISNULL(A.DST,'')+',',',BL,SH,')=0) OR 
                         (ISNULL(A.DOK_JB,0)=0 AND CHARINDEX(','+ISNULL(A.DST,'')+',',',BL,SH,')>0)
                         );


                 UpDate A 
                    Set DST = CASE WHEN ISNULL(A.DOK_JB,0)=1 AND ISNULL(A.DST,'')<>'SH' THEN 'SH'
                                   WHEN ISNULL(A.DOK_JB,0)=0 AND ISNULL(A.DST,'') ='SH' THEN ''
                                   ELSE                                                      A.DST
                              END
                   From FD A
                  Where CHARINDEX(',FD,',','+@Documents+',')>0        AND
                        ( A.KMAG>=@sKMagKp AND A.KMAG<=@sKMagKs )     AND 
                        ( A.DATEDOK>=CONVERT(DATETIME,@sDateKp,104)   AND 
                          A.DATEDOK<=CONVERT(DATETIME,@sDateKs,104) ) AND

                        ( (ISNULL(A.DOK_JB,0)=1 AND ISNULL(A.DST,'')<>'SH') OR 
                          (ISNULL(A.DOK_JB,0)=0 AND ISNULL(A.DST,'') ='SH') ); 
                        
             END;



GO
