SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--  EXEC dbo.Isd_GjenerimFJfromSM @pKaseKp   = '', @pKaseKs   = 'zzz',   @pDateKp   = '01/01/2011', @pDateKs   = '31/12/2014',
--                                @pKodFKLKp = '', @pKodFKLKs = 'zzz',   @pWhere    = '',
--                                @pNrFjKp   = 1,  @pNrFjKs   = 9999999, @pAnalitik = 0, @pUser = 'ADMIN'

CREATE   procedure [dbo].[Isd_GjenerimFJfromSM]
(
 @pKaseKp         VARCHAR(30),
 @pKaseKs         VARCHAR(30),
 @pDateKp         VARCHAR(30),
 @pDateKs         VARCHAR(30),
 @pKodFKLKp       VARCHAR(30),
 @pKodFKLKs       VARCHAR(30),
 @pWhere          VARCHAR(MAX),
 @pNrFjKp         BIGINT,  -- Referoju Users
 @pNrFjKs         BIGINT,  -- Referoju Users
 @pAnalitik       INT,
 @pUser           VARCHAR(30)
)

AS


         SET NOCOUNT ON


     DECLARE @DateDok        DATETIME,
             @NrDok          INT,
             @NrDokFromFJ    BIT,

             @LlogTVSH       VARCHAR(30),
             @LlogZbr        VARCHAR(30),
             @LlogArk        VARCHAR(30),
             @Where          VARCHAR(MAX),
             @ListCommun     VARCHAR(MAX),
             @ListCommunA    VARCHAR(MAX),
             @Sql            VARCHAR(MAX),
             @NrFjKp         BIGINT,
             @NrFjKs         BIGINT,
             @Analitik       INT,
             @TagRnd         VARCHAR(30),
             @SMAplTvsh      BIT;

         SET @Where        = UPPER(@pWhere);
          IF @Where<>''
             BEGIN
               IF CHARINDEX('WHERE',@Where)=0
                  SET @Where = ' WHERE '+@Where;
             END;

      SELECT @TagRnd       = dbo.Isd_RandomNumberChars(dbo.Isd_RandomNumber());

      SELECT @LlogTVSH     = ISNULL(LLOGTATS,''),
             @LlogZbr      = ISNULL(LLOGZBR,''),
             @LlogArk      = ISNULL(LLOGARK,'')
        FROM CONFIGLM;


      SELECT @NrFjKp       = ISNULL(NRKUFIP,1), 
             @NrFjKs       = ISNULL(NRKUFIS,99999999)
        FROM DRHUSER
       WHERE KODUS=@pUser AND MODUL='S' AND TIPDOK='FJ';

         SET @NrFjKp       = ISNULL(@NrFjKp,1);
         SET @NrFjKs       = ISNULL(@NrFjKs,99999999);

         SET @Analitik     = ISNULL(@pAnalitik,0);

		 SET @SMAplTvsh    = (SELECT SMAPLTVSH  FROM CONFIGMG);

          IF OBJECT_ID('TempDB..#KASETmp')    IS NOT NULL
             DROP TABLE #KASETmp;
          IF OBJECT_ID('TempDB..#SMTmp')      IS NOT NULL
             DROP TABLE #SMTmp;
          IF OBJECT_ID('TempDB..#SM')         IS NOT NULL
             DROP TABLE #SM;
          IF OBJECT_ID('TempDB..#SMSCR')      IS NOT NULL
             DROP TABLE #SMSCR;
          IF OBJECT_ID('TempDB..#SMNrDokFt')  IS NOT NULL
             DROP TABLE #SMNrDokFt;
          IF OBJECT_ID('TempDB..#SMNrDokFt1') IS NOT NULL
             DROP TABLE #SMNrDokFt1;
          IF OBJECT_ID('TempDB..#SMNrDokMg')  IS NOT NULL
             DROP TABLE #SMNrDokMg;


      SELECT KOD_KASE = KASE.KOD 
        INTO #KASETmp
        FROM KASE INNER JOIN DRHReference C ON KASE.KOD=C.KOD
       WHERE KODUS=@pUser AND REFERENCE='KASE';


      SELECT NRRENDOR = CAST(0 AS BIGINT)
        INTO #SMTmp      
        FROM SM  
       WHERE 1=2;



   IF @Where<>''

      BEGIN

        SET @Sql = ' 

        INSERT INTO #SMTmp       
              (NRRENDOR)
        SELECT NRRENDOR
          FROM SM INNER JOIN #KASETmp ON SM.KASE=#KASETmp.KOD_KASE 
        '+@Where;

        EXEC (@Sql);

      END

   ELSE

      BEGIN

        INSERT INTO #SMTmp
              (NRRENDOR)
        SELECT NRRENDOR
          FROM SM INNER JOIN #KASETmp ON SM.KASE=#KASETmp.KOD_KASE  
         WHERE KASE    >= @pKaseKp                AND KASE    <= @pKaseKs                AND 
               DATEDOK >= DBO.DATEVALUE(@pDateKp) AND DATEDOK <= DBO.DATEVALUE(@pDateKs) AND 
               KODFKL  >= @pKodFKLKp              AND KODFKL  <= @pKodFKLKs  

      END;


          IF OBJECT_ID('TempDB..#KASETmp')      IS NOT NULL
             DROP TABLE #KASETmp;




      CREATE UNIQUE INDEX AK_Index ON #SMTmp (NRRENDOR)
        WITH (IGNORE_DUP_KEY = OFF); 



      SELECT A.DATEDOK,          
 		     A.KODFKL,          
		     A.KMON,          
		     A.KMAG,          
		     NRRENDOR      = MIN(A.NRRENDOR),           
		     KOD           = UPPER(A.KODFKL+'.'+ISNULL(A.KMON,'')),
		     TIPDMG        = 'D',          
		     DTDMAG        = A.DATEDOK,          
		     NRDOK         = 0,          
		     NRDMAG        = 0,          
		     NRMAG         = 0,          
		     NRDSHOQ       = 0,          
		     NRSERIAL      = REPLICATE('',30),          
		     DTDSHOQ       = A.DATEDOK,          
		     NRFRAKS       = 0,          
		     FRDMAG        = 0,           
		     KLASAKF       = UPPER(MAX(A.KLASAKF)),
		     SHENIM1       = MAX(A.SHENIM1),           
		     SHENIM2       = 'Xhiro Kase '+UPPER(A.KASE)+', Date '+CAST(A.DATEDOK AS VarChar),
             SHENIM3       = REPLICATE(' ',10),
             SHENIM4       = REPLICATE(' ',10),
             NIPT          = MAX(C.NIPT),
             RRETHI        = UPPER(MAX(D.PERSHKRIM)),
             VENHUAJ       = UPPER(MAX(C.VENDHUAJ)),
		     VLPATVSH      = SUM(A.VLPATVSH),           
		     VLTVSH        = SUM(A.VLTVSH),          
		     VLTAX         = SUM(A.VLTAX),           
		     VLERZBR       = SUM(A.VLERZBR),          
		     PARAPG        = CAST(0 AS REAL),          
		     VLERTOT       = CAST(0 AS REAL),          
		     PERQZBR       = CAST(0 AS REAL),          
		     NRDFK         = 0,          
		     KURS1         = MIN(A.KURS1),           
		     KURS2         = MIN(A.KURS2),           
		     LLOGTVSH      = @LlogTVSH,          
		     LLOGZBR       = @LlogZbr,           
		     LLOGARK       = @LlogArk,           
		     PERQTVSH      = 20, 
             KLASETVSH     = 'SVND',
             ISDG          = ISNULL(A.ISDG,0),
             ISDOKSHOQ     = ISNULL(A.ISDOKSHOQ,0),
             KTH           = 0,
             MODPG         = '',
             DTAF          = 0,
             NRDOKDG       = '',
			 KLASIFIKIM	   = UPPER(MAX(C.AGJENTSHITJE)),
             AGJENTSHITJE  = UPPER(MAX(C.AGJENTSHITJE)),
             KODARK        = '',
             PAGESEARK     = CAST(0 AS REAL), 
		     TAGNR         = 0,
             TAGRND        = @TagRnd,   
             USI           = '',
             USM           = '',
             A.KASE      
        INTO #SM      
        FROM SM A INNER JOIN #SMTmp      B ON A.NRRENDOR=B.NRRENDOR
                  LEFT  JOIN KLIENT      C ON A.KODFKL=C.KOD 
                  LEFT  JOIN VENDNDODHJE D ON C.VENDNDODHJE=D.KOD
    GROUP BY A.DATEDOK, A.KMON, A.KMAG, A.KODFKL, A.KASE, ISNULL(A.ISDG,0), ISNULL(A.ISDOKSHOQ,0); 

      SELECT DATEDOK,  
             KMON          = UPPER(ISNULL(KMON,'')),  
             KMAG          = UPPER(KMAG),          
             KODFKL        = UPPER(KODFKL),  
             KARTLLG       = UPPER(C.KARTLLG), 
             KODAF         = UPPER(C.KARTLLG),
             KOD           = UPPER(A.KMAG+'.'+C.KARTLLG+'...'),
             LLOGARIPK     = UPPER(C.KARTLLG),
             PERSHKRIM     = MIN(C.PERSHKRIM),
             KASE          = UPPER(A.KASE),
             KOMENT        = 'Xhiro Kase: '+UPPER(ISNULL(A.KASE,'')),
             BC            = MIN(C.BC),          
             NJESI         = MIN(C.NJESI),           
             NJESINV       = MIN(C.NJESI),          
             KOEFSHB       = 1,          
             SASI          = ISNULL(SUM(C.SASI),0), 

             VLPATVSH      = ISNULL(SUM(CASE WHEN @SMAplTvsh=1 AND ISNULL(T.PERQINDJE,0)<>0 
                                             THEN C.VLPATVSH/(1 + (T.PERQINDJE/100))
                                             ELSE C.VLPATVSH 
                                        END),0),
         
             VLTVSH        = ISNULL(SUM(C.VLERABS - 
                                        CASE WHEN @SMAplTvsh=1 AND ISNULL(T.PERQINDJE,0)<>0 
                                             THEN C.VLPATVSH/(1 + (T.PERQINDJE/100))
                                             ELSE C.VLPATVSH 
                                        END),0),         
             VLTAX         = ISNULL(SUM(C.VLTAX),0),          

             CMIMM         = ISNULL(MAX(D.KOSTMES),0),
             VLERAM        = ROUND(SUM(C.SASI) * MAX(D.KOSTMES),4),
             CMIMBS        = CAST(0 AS REAL),          

             VLERABS       = ISNULL(SUM(C.VLERABS),0),       -- SUM(C.VLPATVSH+C.VLTVSH+C.VLTAX)

             CMSHZB0       = MAX(D.CMSH),          
             CMSHZB0MV     = MAX(D.CMSH),          

             PERQTVSH      = MAX(T.PERQINDJE), --MAX(C.PERQTVSH),  

             KODTVSH       = MAX(D.KODTVSH),
             NRRENDKLLG    = MAX(C.NRRENDKLLG),
             PESHANET      = ISNULL(SUM(C.SASI*C.PESHANET),0), 
             PESHABRT      = ISNULL(SUM(C.SASI*C.PESHABRT),0), 
             
             KODAGJENT     = UPPER(ISNULL(C.KODAGJENT,'')),
             
             APLTVSH       = 0,
             PERQDSCN      = CAST(0 AS REAL),
             NOTMAG        = 0,
             PROMOC        = 0,
             PROMOCTIP     = '',
             TIPFR         = '',
             SASIFR        = CAST(0 AS REAL),
             VLERAFR       = CAST(0 AS REAL),
             TIPKTH        = '',
             FBARS         = 0,
             FCOLOR        = '',
             FPROFIL       = '',
             FLENGTH       = '',
             TIPREF        = '',
             NRDOKREF      = '',
             SERI          = '',
             NRDITAR       = 0,
             KONVERTART    = 1,
             ORDERSCR      = 0,
             TIPKLL        = 'K',
             KODKR         = '',
             KLSART        = '',
             GJENDJE       = CAST(0 AS REAL),
             KOEFICIENT    = 1,
             NRD           = 0,
             TROW          = CAST(0 AS BIT),
             TAGNR         = 0--,          
          -- TAGRND        = @TagRnd      -- Pse duhet ketu nuk e di ????

        INTO #SMSCR
        FROM SM A INNER JOIN #SMTmp     B ON A.NRRENDOR = B.NRRENDOR
                  LEFT  JOIN SMSCR      C ON A.NRRENDOR = C.NRD  
                  LEFT  JOIN ARTIKUJ    D ON C.KARTLLG  = D.KOD
                  LEFT  JOIN KLASATATIM T ON D.KODTVSH  = T.KOD
       WHERE ISNULL(C.STATROW,'')<>'*'                                   
    GROUP BY A.DATEDOK, A.KMON, A.KMAG, A.KODFKL, A.KASE, C.KARTLLG,        
             CASE WHEN ISNULL(C.CMRIMBURSIM,0)<>0 THEN 1 ELSE 0 END,  -- Rimbursimi
             ISNULL(C.KODAGJENT,''),                                  -- Kod agjent ne rreshta
             CASE WHEN @Analitik=1 THEN C.NRRENDOR ELSE 0 END;
   


      UPDATE #SMSCR
         SET CMIMBS        = CASE WHEN VLPATVSH*SASI>0 THEN ROUND((VLPATVSH/SASI),4) ELSE CAST(0 AS REAL) END,
             APLTVSH       = CASE WHEN ISNULL(VLTVSH,0)<>0 THEN 1 ELSE 0 END;

      UPDATE #SMSCR
         SET PERQDSCN      = CASE WHEN ((SASI*VLPATVSH<=0) OR (CMSHZB0<=0) OR (CMSHZB0-CMIMBS<=0.01)) 
                                  THEN CAST(0 AS REAL) 
                                  ELSE ROUND(((CMSHZB0-CMIMBS)/CMSHZB0)*100,3) 
                             END;

--   UPDATE B
--      SET B.CMIMBS   = CBS,
--          B.PERQDSCN = PBS
--     FROM (SELECT CMIMBS,
--                  PERQDSCN,
--                  CBS    = CASE WHEN A.VLPATVSH*A.SASI>0 THEN ROUND((A.VLPATVSH/A.SASI),4) ELSE 0 END,
--                  PBS    = CASE WHEN ((A.SASI*A.VLPATVSH<=0) OR (A.CMSHZB0<=0) OR (A.CMSHZB0-A.CMIMBS<=0)) 
--                                THEN 0 
--                                ELSE ROUND(((A.CMSHZB0-A.CMIMBS)/A.CMSHZB0)*100,3) END
--             FROM #SMSCR A) B 


      UPDATE A    
         SET A.VLPATVSH    = (SELECT SUM(B.VLPATVSH) 
                                FROM #SMSCR B                      
                               WHERE A.DATEDOK=B.DATEDOK AND A.KMON=B.KMON AND A.KMAG=B.KMAG AND A.KODFKL=B.KODFKL AND A.KASE=B.KASE),
             A.VLTVSH      = (SELECT SUM(B.VLTVSH)   
                                FROM #SMSCR B  
                               WHERE A.DATEDOK=B.DATEDOK AND A.KMON=B.KMON AND A.KMAG=B.KMAG AND A.KODFKL=B.KODFKL AND A.KASE=B.KASE),
             A.VLTAX       = (SELECT SUM(B.VLTAX)     
                                FROM #SMSCR B 
                               WHERE A.DATEDOK=B.DATEDOK AND A.KMON=B.KMON AND A.KMAG=B.KMAG AND A.KODFKL=B.KODFKL AND A.KASE=B.KASE)
        FROM #SM A;     


      UPDATE A
         SET A.VLERTOT     =  A.VLPATVSH + A.VLTVSH + A.VLTAX - A.VLERZBR,
             A.PERQZBR     =  CASE WHEN A.VLERZBR*A.VLPATVSH>0 THEN ROUND((A.VLERZBR*100/A.VLPATVSH),4) ELSE 0 END,
             A.NRMAG       = (SELECT NRRENDOR FROM MAGAZINA B WHERE B.KOD=A.KMAG),
             A.KLASETVSH   = 'SVND'
        FROM #SM A;

      UPDATE B  
         SET B.NRD         = A.NRRENDOR, 
             B.TAGNR       = A.NRRENDOR
        FROM #SM A LEFT JOIN #SMSCR B ON (A.DATEDOK=B.DATEDOK) AND (A.KMON=B.KMON) AND
                                         (A.KMAG=B.KMAG) AND (A.KODFKL=B.KODFKL) AND A.KASE=B.KASE;   


-- *****           Rinumurim FJ       *****

      SELECT @NrDokFromFJ  = ISNULL(NRMAGNRFJ,0),
             @SMAplTvsh    = ISNULL(SMAPLTVSH,0) 
        FROM CONFIGMG;


-- 23.07.2015
      SELECT VITI          = YEAR(A.DATEDOK),
             NRMAX         = ISNULL(( SELECT MAX(B.NRDOK)
                                        FROM FJ B
                                       WHERE YEAR(B.DATEDOK)=YEAR(A.DATEDOK) AND (NRDOK>=@NrFjKp AND NRDOK<=@NrFjKs)
                                    GROUP BY YEAR(B.DATEDOK)),  0)
        INTO #SMNrDokFt1
        FROM #SM A 
    GROUP BY YEAR(A.DATEDOK);
    
      UPDATE #SMNrDokFt1
         SET NRMAX = @NrFjKp
       WHERE ISNULL(NRMAX,0)=0;  

 
      SELECT VITI          = YEAR(A.DATEDOK),
             A.DATEDOK,
             B.NRMAX,
             NrDokNew      = CAST(B.NRMAX + ROW_NUMBER() OVER(PARTITION BY YEAR(A.DATEDOK) ORDER BY A.DATEDOK,A.NRDOK) AS BIGINT),
             A.NRRENDOR
        INTO #SMNrDokFt
        FROM #SM A INNER JOIN #SMNrDokFt1 B ON YEAR(A.DATEDOK)=B.VITI
    ORDER BY VITI,A.DATEDOK,A.NRDOK;


      UPDATE A
         SET A.NRDOK       = B.NrDokNew,
             A.NRDSHOQ     = B.NrDokNew,
             A.NRDMAG      = CASE WHEN @NrDokFromFJ=1 THEN B.NrDokNew ELSE 0 END,
		     A.NRSERIAL    = CAST(CAST(B.NrDokNew AS BIGINT) AS VARCHAR(20)),
             A.TAGNR       = A.NRRENDOR
        FROM #SM A INNER JOIN #SMNrDokFt B ON A.NRRENDOR=B.NRRENDOR;



-- *****           Rinumurim MG           *****

    IF @NrDokFromFJ<>1
       BEGIN

         SELECT A.NRRENDOR,         -- VITI=YEAR(A.DATEDOK),A.KMAG,A.NRMAG,A.DATEDOK,B.NRMAX,
                NrDokNew   = CAST(B.NRMAX + ROW_NUMBER() OVER(PARTITION BY A.NRMAG,YEAR(A.DATEDOK) ORDER BY A.NRMAG,A.DATEDOK,A.NRDOK) AS BIGINT)

           INTO #SMNrDokMg

           FROM #SM A INNER JOIN 

                (    SELECT A.NRMAG, VITI=YEAR(A.DATEDOK), NRMAX=MAX(A.NRDOK)
                       FROM FD A
                   GROUP BY A.NRMAG,YEAR(A.DATEDOK)

                    )       B    ON A.NRMAG=B.NRMAG AND YEAR(A.DATEDOK)=B.VITI;
   

         UPDATE A
            SET A.NRDMAG   = B.NrDokNew
           FROM #SM A INNER JOIN #SMNrDokMg B ON A.NRRENDOR=B.NRRENDOR;

     END;

-- *****           FUND RINUMURIMI           ***** --


--U.    Kalimi ne DBase

--   UPDATE FJ      SET TAGNR=0 WHERE ISNULL(TAGNR,0)<>0; 
--   UPDATE FJScr   SET TAGNR=0 WHERE ISNULL(TAGNR,0)<>0; 
     


-- U.1  Kalimi i #SM ne FJ

      
         SET @ListCommun   = dbo.Isd_ListFields2Tables('FJ','#SM','NRRENDOR,FIRSTDOK');

         SET @Sql= ' 
     INSERT  INTO FJ 
            ('+@ListCommun+') 
     SELECT  '+@ListCommun+'
       FROM #SM ';

       EXEC (@Sql);


-- U.2  UPDATE NRD ne #SMScr me vlerat e FJ te sapo shtuara

      UPDATE #SMScr SET NRD=0;

      UPDATE B 
         SET B.NRD = A.NRRENDOR 
        FROM FJ A INNER JOIN #SMScr B ON A.TAGNR=B.TAGNR 
       WHERE A.TagRND=@TagRnd  AND A.TAGNR<>0;



-- U.3  Kalimi i #SMScr te krijuara ne FJScr

         SET @ListCommun = dbo.Isd_ListFields2Tables('FJSCR','#SMSCR','NRRENDOR,TAGNR,TAGRND');

         SET @Sql= ' 
      INSERT INTO FJSCR 
            ('+@ListCommun+',TAGNR,TAGRND) 
      SELECT '+@ListCommun+',0,''''
        FROM #SMSCR 
        WHERE NRD<>0 ';

       EXEC (@Sql);



-- U.4  Zerime vlera ne FJ per FJ e shtuara

      UPDATE FJ    
         SET TAGNR         = 0,
             FIRSTDOK      = 'F'+CAST(NRRENDOR AS VARCHAR)  
       WHERE TAGRND=@TagRnd AND ISNULL(TAGNR,0)<>0;




-- X.   Kalimi ne Bak te SM para Fshirjes


-- X.1  Kalimi i SM ne SMBak

      SET    @ListCommun   = dbo.Isd_ListFields2Tables('SM','SMBAK','NRRENDOR,TAGNR,TAGRND');
      SET    @ListCommunA  = dbo.Isd_ListFieldsAlias(@ListCommun,'A');
      SET    @Sql= ' INSERT INTO SMBAK 
                           ('+@ListCommun+',TAGNR,TAGRND) 
                     SELECT '+@ListCommun+',A.NRRENDOR,'''+@TagRnd+'''  
                       FROM SM A INNER JOIN #SMTmp B ON A.NRRENDOR=B.NRRENDOR; ';
      EXEC ( @Sql );


-- X.2  Kalimi i SMScr ne SMBakScr
     
      SET    @ListCommun   = dbo.Isd_ListFields2Tables('SMSCR','SMBAKSCR','NRRENDOR,NRD,TAGNR,TAGRND');
      SELECT @ListCommunA  = dbo.Isd_ListFieldsAlias(@ListCommun,'B');
      SET    @Sql= ' INSERT INTO SMBAKSCR 
                           (NRD,'+@ListCommun+',TAGNR) 
                     SELECT A.NRRENDOR,'+@ListCommunA+',0
                       FROM SMBAK A INNER JOIN SMSCR B ON A.TAGNR=B.NRD 
                      WHERE ISNULL(A.TAGNR,0)<>0 AND A.TAGRND='''+@TagRnd+'''';
      EXEC ( @Sql );


-- X.3  Zerime vlera ne SMBak

      UPDATE SMBak SET TAGNR =0 WHERE TAGRND=@TagRnd AND ISNULL(TAGNR,0)<>0;
      UPDATE SMBak SET TAGRND=0 WHERE TAGRND=@TagRnd; 


-- X.4  Fshirje e SM qe u kthyen ne FJ            

      DELETE A
        FROM SM A    INNER JOIN #SMTmp B ON A.NRRENDOR=B.NRRENDOR;
      DELETE A
        FROM SMScr A INNER JOIN #SMTmp B ON A.NRD=B.NRRENDOR;
  

          IF OBJECT_ID('TempDB..#KASETmp')      IS NOT NULL
             DROP TABLE #KASETmp;
          IF OBJECT_ID('TempDB..#SMTmp')        IS NOT NULL
             DROP TABLE #SMTmp;
          IF OBJECT_ID('TempDB..#SM')           IS NOT NULL
             DROP TABLE #SM;
          IF OBJECT_ID('TempDB..#SMSCR')        IS NOT NULL
             DROP TABLE #SMSCR;
          IF OBJECT_ID('TempDB..#SMNrDokFt')    IS NOT NULL
             DROP TABLE #SMNrDokFt;
          IF OBJECT_ID('TempDB..#SMNrDokFt1')   IS NOT NULL
             DROP TABLE #SMNrDokFt1;
          IF OBJECT_ID('TempDB..#SMNrDokMg')    IS NOT NULL
             DROP TABLE #SMNrDokMg;



-- Krijim ditare dhe dokumenta magazine

        EXEC dbo.Isd_GjenerimDitar  @pDateKp, @pDateKs,'S', '0'       -- Gjenerim Ditare per FJ e krijuara

        EXEC dbo.Isd_GjenerimFDFromFtAll @TagRnd,''                   -- Krijimi i dokumentave Dalje magazine per FJ e krijuara


      UPDATE FJ SET TAGRND=0 WHERE TAGRND=@TagRnd;                    -- Zerime vlera ne FJ qe u perdoren per kete procedure


GO
