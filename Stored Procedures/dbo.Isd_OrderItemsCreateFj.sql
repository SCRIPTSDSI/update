SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   Procedure [dbo].[Isd_OrderItemsCreateFj]
( 
  @PNrRendor     Int,
  @PTip          Varchar(10),
  @PListRef      Varchar(MAX)
 )
As


-- Krijimi i dokumentave dhe kalim ne Baze,Krijim ditare per FJ

         SET NOCOUNT ON;

          IF OBJECT_ID('TempDB..#TMPD')        IS NOT NULL
             DROP TABLE #TMPD;
          IF OBJECT_ID('TempDB..#TMPDSCR')     IS NOT NULL
             DROP TABLE #TMPDSCR;
          IF OBJECT_ID('TempDB..#ListCmime')   IS NOT NULL   
             DROP TABLE #ListCmime;
		  IF OBJECT_ID('TempDB..#ListCmimeSp') IS NOT NULL   
             DROP TABLE #ListCmimeSp;
             
             
     DECLARE @NrRendor      Int,
             @NrDokMg       Int,
             @NrDokFt       Int,
			 @NrFiskalizim	Int,
             @KMag          Varchar(10),
             @Shenim1       Varchar(150),
             @DateDok       DateTime,
             @DateDitar     Varchar(20),
             @ListRef       Varchar(MAX),
             @TipKl         Varchar(10),
             @ListOrdKl     Varchar(MAX),
             @ListCommun    Varchar(MAX),
             @KodUserFt     Varchar(60),
             @KodUserFd     Varchar(60),
             @NrFdKp        BigInt,
             @NrFdKs        BigInt,
             @NrFtKp        BigInt,
             @NrFtKs        BigInt,
             @Sql           Varchar(MAX);

         SET @NrRendor    = @PNrRendor;
         SET @ListRef     = UPPER(@PListRef);
         SET @TipKl       = 'K';
         
         IF  @ListRef='*'
             SET @ListRef = '';

         SET @NrFdKp      = 1;
         SET @NrFdKs      = 999999999;
         SET @NrFtKp      = 0;
         SET @NrFtKs      = 0;
       
         SET @KodUserFt   = (SELECT ORDERITEMSUSERKL FROM CONFIGMG);
         SET @KodUserFd   = @KodUserFt;
      --  IF NOT EXISTS(SELECT USERN FROM DRH..USERS WHERE USERN=@KodUserFt )
      --     BEGIN
      --       RETURN;
      --     END;
             
         SET @KMag        = (SELECT KMAG          FROM ORDERITEMS WHERE NRRENDOR=@NrRendor);
         SET @DateDok     = (SELECT DATEDOKCREATE FROM ORDERITEMS WHERE NRRENDOR=@NrRendor);
         SET @Shenim1     = (SELECT SHENIM1       FROM ORDERITEMS WHERE NRRENDOR=@NrRendor);



-- 1. Gjetja e kufijve dhe numur maksimal per flete daljet e magazines prodhim nga levrohet malli

      SELECT @NrFdKp=ISNULL(NRKUFIP,0), @NrFdKs=ISNULL(NRKUFIS,999999999)
        FROM DRHUSER 
       WHERE KODUS=@KodUserFd AND MODUL='M' AND (TIPDOK='D' OR TIPDOK='FD') AND KODREF=@KMag;
       
         SET @NrDokMg     = (SELECT MAX(NRDOK) 
                               FROM FD 
                              WHERE KMAG=@KMag AND YEAR(DATEDOK)=YEAR(@DateDok) AND NRDOK>=@NrFdKp AND NRDOK<=@NrFdKs );

         SET @NrDokMg     = CASE WHEN ISNULL(@NrDokMg,0)>0 THEN @NrDokMg ELSE @NrFdKp END;



-- 2. Gjetja e kufijve dhe numur maksimal per fature shitje 
                                                            
      SELECT @NrFtKp=ISNULL(NRKUFIP,0), @NrFtKs=ISNULL(NRKUFIS,999999999)
        FROM DRHUSER 
       WHERE KODUS=@KodUserFt AND MODUL='S' AND TIPDOK='FJ' -- AND KODREF='FJ'
       
         SET @NrDokFt     = (SELECT MAX(NRDOK) 
                               FROM FJ 
                              WHERE YEAR(DATEDOK)=YEAR(@DateDok) AND NRDOK>=@NrFtKp AND NRDOK<=@NrFtKs );

		--------------------------------------------------------------------------------------------------------
		DECLARE @BusinUnit VARCHAR(20),
				@OPERATOR  VARCHAR(20),
				@TcrCode   VARCHAR(20),
				@FISPROCES VARCHAR(20),
				@FISTIPDOK VARCHAR(20),
				@FISMENPAGESE VARCHAR(20),
				@FISTVSHEFEKT VARCHAR(20),
				@FISDATEPARE DATETIME,
				@FISDATEFUND DATETIME,
				@ISDOCFISKAL BIT;
			
		SET @BusinUnit=(SELECT TOP 1 FISBUSINESSUNIT FROM MAGAZINA WHERE KOD='PG1')
		SET @OPERATOR=(SELECT TOP 1 FISKODOPERATOR FROM DRH..Users WHERE USERN='FATUR')
		SET @TcrCode=(SELECT TOP 1 B.KODAF FROM FisBusUnit A INNER JOIN FisBusUnitScr B ON A.NRRENDOR=B.NRD WHERE A.KOD=@BusinUnit)
		SET @FISPROCES=(SELECT VLERA FROM FisConfig WHERE KOD='FISFJINSERT' AND FUSHA='FISPROCES')
		SET @FISTIPDOK=(SELECT VLERA FROM FisConfig WHERE KOD='FISFJINSERT' AND FUSHA='FISTIPDOK')
		SET @FISMENPAGESE=(SELECT VLERA FROM FisConfig WHERE KOD='FISFJINSERT' AND FUSHA='FISMENPAGESE')
		SET @FISTVSHEFEKT=(SELECT VLERA FROM FisConfig WHERE KOD='FISFJINSERT' AND FUSHA='FISTVSHEFEKT')
		SET @FISDATEPARE=(SELECT TOP 1 DATEDOK FROM OrderItems WHERE NRRENDOR=@PNrRendor)
		SET @FISDATEFUND=(SELECT TOP 1 DATEDOK FROM OrderItems WHERE NRRENDOR=@PNrRendor)
		SET @Datedok=(SELECT TOP 1 DATEDOK FROM OrderItems WHERE NRRENDOR=@PNrRendor)
		
		--SELECT * FROM FISTCR ORDER BY NRRENDOR DESC

		SET @NrFiskalizim =(SELECT  ISNULL(MAX(CONVERT(BIGINT,NrFiskalizim)),0) 
		               FROM 
							(SELECT NRFISKALIZIM=ISNULL(NRFISKALIZIM,0) FROM FJ f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                  WHERE ISNULL(f.isDocFiscal,0)=1 
							AND f.FisBusinessunit = @BusinUnit 
			                AND T.KOD=@TcrCode 
							AND YEAR(Datedok)=YEAR(@Datedok) 
							AND ISNUMERIC(NrFiskalizim)=1 
							
							UNION 
							SELECT ISNULL(NRFISKALIZIM,0) FROM FF f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                  WHERE ISNULL(f.isDocFiscal,0)=1 
							AND f.FisBusinessunit = @BusinUnit 
			                AND T.KOD=@TcrCode 
							AND YEAR(Datedok)=YEAR(@Datedok) 
							AND ISNUMERIC(NrFiskalizim)=1 
							
							) AS A )
SELECT @PNrRendor,@BusinUnit,@TcrCode,@Datedok,@NrFiskalizim
        -------------------------------------------------------------------------------------------------------                     
         SET @NrDokFt     = CASE WHEN ISNULL(@NrDokFt,0)>0 THEN @NrDokFt ELSE @NrFtKp END;
  
    

-- 3. Krijimi i dokumentave temporare

      SELECT * INTO #TMPD    FROM FJ    WHERE 1=2;

      SELECT * INTO #TMPDSCR FROM FJSCR WHERE 1=2;

       ALTER TABLE #TMPD     DROP COLUMN NRRENDOR;
       ALTER TABLE #TMPD     ADD         NRRENDOR BigInt      Default 0;
	  

       ALTER TABLE #TMPDSCR  ADD         KODFKL   Varchar(30) Default '';
       ALTER TABLE #TMPDSCR  ADD         TIPORD   Varchar(10) Default '';
       ALTER TABLE #TMPDSCR  ADD         KLASAKF  Varchar(30) Default ''




      INSERT INTO #TMPD
            (NRRENDOR,DATEDOK,NRDOK,NRFISKALIZIM,NRFRAKS,KODFKL,KMAG,NRMAG,NRDMAG,NRRENDDMG,
			FISBUSINESSUNIT,FISKODOPERATOR,FISTCR,FISPROCES,FISTIPDOK,FISMENPAGESE,FISTVSHEFEKT,FISDATEPARE,FISDATEFUND,ISDOCFISCAL,FISKALIZUAR)

          
      SELECT NRRENDOR      =                      ROW_NUMBER() OVER(ORDER BY B.KODAF),
             DATEDOK       = MAX(A.DATEDOKCREATE),
             NRDOK         = ISNULL(@NrDokFt,0) + ROW_NUMBER() OVER(ORDER BY B.KODAF),
			 NRFISKALIZIM  = ISNULL(@NrFiskalizim,0) + ROW_NUMBER() OVER(ORDER BY B.KODAF),
             NRFRAKS       = 0,
             KODFKL        = B.KODAF,
             KMAG          = MAX(A.KMAG),
             NRMAG         = MAX(M.NRRENDOR),
             NRDMAG        = ISNULL(@NrDokMg,0) + ROW_NUMBER() OVER(ORDER BY B.KODAF),
             NRRENDDMG     = 0,
			 @BusinUnit,@OPERATOR,@TcrCode,@FISPROCES,@FISTIPDOK,@FISMENPAGESE,@FISTVSHEFEKT,@FISDATEPARE,@FISDATEFUND,
			 ISDOCFICAL=(SELECT ISDOCFISCAL FROM KLIENT WHERE KOD=B.KODAF),
			 FISKALIZUAR=0
        FROM ORDERITEMS A INNER JOIN ORDERITEMSSCR B ON A.NRRENDOR=B.NRD
                          LEFT  JOIN MAGAZINA M      ON A.KMAG=M.KOD
       WHERE A.NRRENDOR=@NrRendor AND TIPKLL=@TipKl AND (CHARINDEX(','+UPPER(B.KODAF)+',',','+@ListRef+',')>0)  
    GROUP BY B.KODAF;

	SELECT NRFISKALIZIM,* FROM #TMPD
      INSERT INTO #TMPDSCR
            (KOD,KARTLLG,KODFKL,KLASAKF,SASI,SASIKONV,NRD,TIPORD,TAGNR)
      SELECT KOD           = A.KMAG+'.'+B.KOD+'...',
             B.KOD,
             KODFKL        = B.KODAF,
             KLASAKF       = K.GRUP,
             B.SASI,
             B.SASIKONV,
             NRD           = T1.NRRENDOR,
             TIPORD        = B.TIPKLL,
             TAGNR         = T1.NRRENDOR
        FROM ORDERITEMS A INNER JOIN ORDERITEMSSCR B  ON A.NRRENDOR = B.NRD
                          LEFT  JOIN #TMPD         T1 ON T1.KODFKL  = B.KODAF
                          LEFT  JOIN KLIENT        K  ON B.KODAF    = K.KOD
       WHERE A.NRRENDOR=@NrRendor AND TIPKLL=@TipKl AND (CHARINDEX(','+UPPER(B.KODAF)+',',','+@ListRef+',')>0) AND 
            (ABS(B.SASI)>=0.01 OR ABS(B.SASIKONV)>=0.01) 
    ORDER BY B.KODAF,B.KOD;


--                                                -- Kujdes: Kjo metode nuk evidenton klientet me sasi zero ...
--       SET @ListOrdKl = '';
--    SELECT @ListOrdKl = @ListOrdKl + CASE WHEN TIPORD=@TipKl THEN ',' + KODFKL ELSE '' END
--      FROM #TMPDSCR								
--  GROUP BY KODFKL,TIPORD
--  ORDER BY KODFKL,TIPORD;

--        IF SUBSTRING(@ListOrdKl,1,1)=','
--           SET @ListOrdKl = SUBSTRING(@ListOrdKl,2,Len(@ListOrdKl));
--                                                                        


--                                                -- Kujdes: Kjo metode evidenton klientet edhe kur jane me sasi zero ...

         SET @ListOrdKl = '';
      SELECT @ListOrdKl = @ListOrdKl + CASE WHEN B.TIPKLL=@TipKl THEN ',' + B.KODAF ELSE '' END
        FROM ORDERITEMS A INNER JOIN ORDERITEMSSCR B  ON A.NRRENDOR = B.NRD
       WHERE A.NRRENDOR=@NrRendor AND B.TIPKLL=@TipKl AND (CHARINDEX(','+UPPER(B.KODAF)+',',','+@ListRef+',')>0)
    GROUP BY B.TIPKLL,B.KODAF
    ORDER BY B.TIPKLL,B.KODAF;

          IF SUBSTRING(@ListOrdKl,1,1)=','
             SET @ListOrdKl = SUBSTRING(@ListOrdKl,2,Len(@ListOrdKl));
             
         
             
             
             
-- Ska nevoje fshirja sepse u vendos ne WHERE tek INSERT

          IF @ListRef<>''
             BEGIN
               SET @Sql = ' 
      DELETE 
        FROM #TMPD
       WHERE CHARINDEX('',''+KODFKL+'','','',''+'''+@ListRef+'''+'','')=0; 

      DELETE 
        FROM #TMPDSCR
       WHERE CHARINDEX('',''+KODFKL+'','','',''+'''+@ListRef+'''+'','')=0 ';
            -- PRINT @Sql;
               EXEC (@Sql);
             END;


--SELECT KOD1=A.KARTLLG,A.PERSHKRIM,A.SASI,A.SASIKONV,B.KOEFICENTCOPEDOC,B.KOD FROM #TMPDSCR A LEFT JOIN ORDERITEMSSORTSCR B ON A.KARTLLG=B.KOD ORDER BY A.KOD;


      UPDATE A                      -- Zeron fushen SASIKONV per ato artikuj qe nuk duhet (kontrollohet fusha OrderItemsSortScr..KOEFICENTCOPEDOC)
         SET A.SASIKONV = 0
        FROM #TMPDSCR A 
       WHERE (ISNULL(A.SASIKONV,0)<>0) AND 
             (EXISTS  ( SELECT KOD 
                          FROM OrderItemsSortScr B 
                         WHERE B.KOD=A.KARTLLG AND ISNULL(B.KOEFICENTCOPEDOC,0)=0));
--     WHERE NOT EXISTS  ( SELECT KOD 
--                           FROM OrderItemsSortScr B 
--                          WHERE B.KOD=A.KARTLLG AND ISNULL(B.KOEFICENTCOPEDOC,0)=1);

                            

      DELETE 
        FROM #TMPD
       WHERE NOT EXISTS (SELECT * FROM #TMPDSCR WHERE #TMPD.NRRENDOR=#TMPDSCR.NRD);



--    Regullime ne Dokument dhe reshta

      UPDATE A
         SET KODAF         = A.KARTLLG,
             LLOGARIPK     = A.KARTLLG,
             PERSHKRIM     = B.PERSHKRIM,
             
             CMIMM         = B.KOSTMES,
             VLERAM        = ROUND(A.SASI*B.KOSTMES,2),
             CMSHZB0       = B.CMSH,
             CMSHZB0MV     = B.CMSH,
             PERQDSCN      = 0,                   -- Sipas Klases se klientit  
             CMIMBS        = CASE WHEN A.KLASAKF='A' OR ISNULL(A.KLASAKF,'')='' THEN B.CMSH
                                  WHEN A.KLASAKF='B' THEN B.CMSH1
                                  WHEN A.KLASAKF='C' THEN B.CMSH2
                                  WHEN A.KLASAKF='D' THEN B.CMSH3
                                  WHEN A.KLASAKF='E' THEN B.CMSH4
                                  WHEN A.KLASAKF='F' THEN B.CMSH5
                                  WHEN A.KLASAKF='G' THEN B.CMSH6
                                  WHEN A.KLASAKF='H' THEN B.CMSH7
                                  WHEN A.KLASAKF='I' THEN B.CMSH8
                                  WHEN A.KLASAKF='J' THEN B.CMSH9
                                  WHEN A.KLASAKF='K' THEN B.CMSH10
                                  WHEN A.KLASAKF='L' THEN B.CMSH11
                                  WHEN A.KLASAKF='M' THEN B.CMSH12
                                  WHEN A.KLASAKF='N' THEN B.CMSH13
                                  WHEN A.KLASAKF='O' THEN B.CMSH14
                                  WHEN A.KLASAKF='P' THEN B.CMSH15
                                  WHEN A.KLASAKF='Q' THEN B.CMSH16
                                  WHEN A.KLASAKF='R' THEN B.CMSH17
                                  WHEN A.KLASAKF='S' THEN B.CMSH18
                                  WHEN A.KLASAKF='T' THEN B.CMSH19
                                  ELSE                    B.CMSH
                             END,

             NJESI         = B.NJESI,
             NJESINV       = B.NJESI,
             KOMENT        = @Shenim1,
             KODTVSH       = B.KODTVSH,

             PROMOC        = 0,
             PROMOCTIP     = '',
             NOTMAG        = 0,
             RIMBURSIM     = 0,
             SASIFR        = 0,
             VLERAFR       = 0,
             TIPFR         = '',
             PROMOCKOD     = '',
             PESHANET      = ROUND(A.SASI*ISNULL(B.PESHANET,0),3),       
             PESHABRT      = ROUND(A.SASI*ISNULL(B.PESHABRT,0),3),       
             TIPREF        = '',
             NRDOKREF      = '',
             SERI          = '',
             NRDITAR       = 0,
             TIPKTH        = '',
             KOEFICIENT    = 0,
             KLSART        = '',
             TIPKLL        = 'K',

             KONVERTART    = ISNULL(B.KONV1,1) * ISNULL(B.KONV2,1),
             BC            = B.BC,
             KOEFSHB       = B.KOEFSH,
             NRRENDKLLG    = B.NRRENDOR,
             ORDERSCR      = A.NRRENDOR
        FROM #TMPDSCR A LEFT JOIN ARTIKUJ    B ON A.KARTLLG=B.KOD
                     -- LEFT JOIN KLASATATIM K ON B.KODTVSH=K.KOD;

-- Faturim kliente me cmime nga ofertat 

      SELECT KODFKL,KOD,CMSH=MIN(CMSH)
        INTO #ListCmime
        FROM  
        (    SELECT KODFKL=D.KOD,KOD=B.KOD,CMSH=ROUND(C.CMIM,2)
               FROM KlientCmim A INNER JOIN KlientCmimArt B ON A.NRRENDOR=B.NRD
                                 INNER JOIN KlientCmimCm  C ON B.NRRENDOR=C.NRD
                                 INNER JOIN KlientCmimKl  D ON A.NRRENDOR=D.NRD
                                 INNER JOIN #TMPDSCR      T ON D.KOD=T.KODFKL AND B.KOD=T.KARTLLG
--                               INNER JOIN KLIENT        E ON D.KOD=E.KOD
              WHERE ROUND(ISNULL(C.CMIM,0),2)>0 AND --ISNULL(A.ACTIV,0)=1 AND
		           (A.DATESTART<=DBO.DATEVALUE(CONVERT(VARCHAR(10),GETDATE(),103)) AND A.DATEEND>=DBO.DATEVALUE(CONVERT(VARCHAR(10),GETDATE(),103)))
            ) AS A
    GROUP BY KODFKL,KOD;



      UPDATE A
         SET CMIMBS = T.CMSH
        FROM #TMPDSCR A INNER JOIN #ListCmime T ON A.KODFKL=T.KODFKL AND A.KARTLLG=T.KOD; 
        
  
  
       
        
-- ERIALDI dt 07/01/2020 fillim modifikimi -- Per rastin e faturave u percaktua cmimi per cdo artikull sipas Sales_Price  

	 DECLARE @DateSalesPrice   DateTime;
	     SET @DateSalesPrice = DBO.DATEVALUE(CONVERT(Varchar(10),GETDATE(),103));
	     

	  SELECT KOD,KARTLLG,KODFKL,
	         CMSHZB0 = dbo.Sales_PriceZb0(KARTLLG,'',KODFKL,@DateSalesPrice,1,1,1 ),
             CMSH    = dbo.Sales_Price(KARTLLG,   '',KODFKL,@DateSalesPrice,1,1,1 )
	    INTO #ListCmimeSp
	    FROM #TMPDSCR;


      UPDATE A
         SET CMSHZB0=T.CMSHZB0, CMIMBS=T.CMSH
        FROM #TMPDSCR A INNER JOIN #ListCmimeSp T ON A.KODFKL=T.KODFKL AND A.KARTLLG=T.KARTLLG;
       
-- ERIALDI dt 07/01/2020 fund modifikimi
        
        
        
      UPDATE A
         SET CMIMM         = B.KOSTMES,
             VLERAM        = ROUND(A.SASI*B.KOSTMES,2),
          -- CMSHZB0       = B.CMSH,                        -- ERIALDI dt 07/01/2020, u llogarit pak me siper
             CMSHZB0MV     = CMSHZB0,
             PERQDSCN      = 0,                             -- Sipas Klases se klientit, llogaritet pak me poshte  

             VLPATVSH      = ROUND(A.SASI*A.CMIMBS,2),
             VLTVSH        = CASE WHEN B.TATIM=1 THEN ROUND(A.SASI*A.CMIMBS*ISNULL(K.PERQINDJE,0),2) ELSE 0 END,      -- Sipas Tvsh se Artikullit
             VLTAX         = 0,
             VLERABS       = ROUND(A.SASI*A.CMIMBS,2)
                             +
                             CASE WHEN B.TATIM=1 THEN ROUND(A.SASI*A.CMIMBS*ISNULL(K.PERQINDJE,0),2) ELSE 0 END,
             PERQTVSH      = CASE WHEN B.TATIM=1 THEN ISNULL(K.PERQINDJE,0)                          ELSE 0 END,      -- Sipas Klases TVSH
             SERI          = L.SERI,
             DTSKADENCE    = L.DTSKADENCE

        FROM #TMPDSCR A LEFT JOIN ARTIKUJ    B ON A.KARTLLG=B.KOD
                        LEFT JOIN KLASATATIM K ON B.KODTVSH=K.KOD
                        LEFT JOIN ARTIKUJLOT L ON A.KARTLLG=L.KOD;


-- ERIALDI dt 07/01/2020 fillim modifikimi

       UPDATE A 
          SET PERQDSCN = ROUND(100-(CMIMBS*100/CMSHZB0),2)
         FROM #TMPDSCR A; 
         
-- ERIALDI dt 07/01/2020 fund modifikimi






--         I N S E R T I M   ne   DB



-- 1. Regullim dhe Insertim i FJ

      UPDATE A
         SET A.KOD         = A.KODFKL+'.',  
             A.NIPT        = K.NIPT,
             A.SHENIM1     = K.PERSHKRIM,
             A.SHENIM2     = K.ADRESA1,
             A.SHENIM3     = '',
             A.SHENIM4     = @Shenim1,

             A.KMON        = '',
             A.KURS1       = 1,
             A.KURS2       = 1,
             A.DTDMAG      = A.DATEDOK,
             A.FRDMAG      = 0,
             A.TIPDMG      = 'D',
             A.NRDSHOQ     = CAST(CAST(A.NRDOK AS BIGINT) AS VARCHAR), --CAST(CAST(A.NRDOKLNK As BigInt) As Varchar)
             
             A.DTDSHOQ     = A.DATEDOK,

             A.VLPATVSH    = B.VLPATVSH,
             A.VLTVSH      = B.VLTVSH,
             A.VLTAX       = B.VLTAX,
             A.VLERZBR     = 0,
             A.PARAPG      = 0,
             A.VLERTOT     = B.VLPATVSH+B.VLTVSH+B.VLTAX,
             A.PERQTVSH    = 0,
             A.PERQZBR     = 0,
             A.KTH         = 0,
             A.NRSERIAL    = CAST(CAST(A.NRDOK AS BIGINT) AS VARCHAR),

             A.DTAF        = 0,
             A.PERQDS      = 0,
             A.MODPG       = '',

             A.LLOJDOK     = 'A',
             A.ISDG        = 0,
             A.ISDOKSHOQ   = 0,
             A.LLOGTVSH    = '',
             A.LLOGZBR     = '',
             A.LLOGARK     = '',
             A.NRDITAR     = 0,
             A.NRDITARSHL  = 0,
             A.NRDITARPRMC = 0,
             A.NRDFK       = 0,
             A.POSTIM      = 0,
             A.LETER       = 0,
             A.KLASAKF     = K.GRUP,
             A.VENHUAJ     = K.VENDHUAJ,
             A.RRETHI      = V.PERSHKRIM,
             A.KODARK      = '',
             A.NRRENDORAR  = 0 

			
        FROM #TMPD A INNER JOIN 
                             (  SELECT KODFKL,
                                       VLPATVSH  = SUM(ISNULL(T2.VLPATVSH,0)),
                                       VLTVSH    = SUM(ISNULL(T2.VLTVSH,0)),
                                       VLTAX     = SUM(ISNULL(T2.VLTAX,0))
                                  FROM #TMPDSCR T2 
                              GROUP BY KODFKL ) B ON A.KODFKL=B.KODFKL
                              
                     LEFT  JOIN KLIENT          K ON A.KODFKL=K.KOD
                     LEFT  JOIN VENDNDODHJE     V ON K.VENDNDODHJE=V.KOD;

         SET @ListCommun = dbo.Isd_ListFields2Tables('FJ','#TMPD','NRRENDOR,TAGNR,TAGRND');
         SET @Sql= ' 
                   INSERT INTO FJ 
                         ('+@ListCommun+',TAGNR) 
                   SELECT '+@ListCommun+',NRRENDOR
                     FROM #TMPD 
                 ORDER BY NRRENDOR ';
		--PRINT ( @Sql );
        EXEC ( @Sql );
		
      UPDATE A
         SET A.NRRENDDMG   = B.NRRENDOR
        FROM #TMPD A INNER JOIN FJ B ON A.NRRENDOR=B.TAGNR
       WHERE B.TAGNR<>0;

      UPDATE FJ
         SET FIRSTDOK = 'S'+CAST(CAST(NRRENDOR AS BIGINT) AS VARCHAR),
             TAGNR    = 0
       WHERE ISNULL(TAGNR,0)<>0;

-- 2. Regullim dhe Insertim i FJSCR

      UPDATE A
         SET A.NRD=B.NRRENDDMG
        FROM #TMPDSCR A INNER JOIN #TMPD B ON A.TAGNR=B.NRRENDOR;

         SET @ListCommun = dbo.Isd_ListFields2Tables('FJSCR','#TMPDSCR','NRRENDOR,TAGNR,TAGRND');
         SET @Sql= ' 
                   INSERT INTO FJSCR 
                         ('+@ListCommun+',TAGNR,TAGRND) 
                   SELECT '+@ListCommun+',0,''''
                     FROM #TMPDSCR 
                    WHERE NRD<>0
                 ORDER BY NRD,KOD ';
        EXEC ( @Sql );



-- 3. Regullim dhe Insertim i FD

      INSERT INTO FD
            (KMAG,NRMAG,DATEDOK,NRDOK,NRFRAKS,TIP,DST,
             KMAGRF,KMAGLNK,NRDOKLNK,NRFRAKSLNK,
             SHENIM1,SHENIM2,SHENIM3,SHENIM4,
             NRSERIAL,KODLM,NRRENDORFAT,DOK_JB,TIPFAT,GRUP,KTH,NRDFK,POSTIM,LETER,KALIMLMZGJ,
             FAKLS,FADESTIN,FABUXHET,KLASIFIKIM,TAGNR)
      SELECT KMAG,NRMAG,DATEDOK,NRDMAG,NRFRAKS,
             TIP           = 'D',
             DST           = 'SH',
             KMAGRF        = '',
             KMAGLNK       = '',
             NRDOKLNK      = 0,
             NRFRAKSLNK    = 0,
             A.SHENIM1,
             A.SHENIM2,
             A.SHENIM3,
             A.SHENIM4,
             NRSERIAL      = '',     -- A.NRSERIAL, -- A duhet seriali i fatures tek Fd .....?????
             KODLM         = '',
             A.NRRENDDMG,
             DOK_JB        = 1,
             TIPFAT        = 'S',
             GRUP          = M.GRUP,
             KTH           = 0,
             0,0,0,0,'','','','',
             A.NRRENDOR
        FROM #TMPD A LEFT JOIN MAGAZINA M ON A.KMAG=M.KOD
    ORDER BY A.NRRENDOR;

      UPDATE A
         SET A.NRRENDDMG   = B.NRRENDOR
        FROM #TMPD A INNER JOIN FD B ON A.NRRENDOR=B.TAGNR
       WHERE B.TAGNR<>0;
     

--    UPDATE B
--       SET B.NRRENDDMG   = A.NRRENDDMG
--      FROM #TMPD A INNER JOIN FJ B ON A.NRRENDOR=B.TAGNR
--     WHERE B.TAGNR<>0;     
     

      UPDATE A
         SET A.NRRENDDMG   = B.NRRENDOR
        FROM FJ A INNER JOIN FD B ON A.NRRENDOR=B.NRRENDORFAT
       WHERE ISNULL(B.NRRENDORFAT,0)<>0;     
     

      UPDATE FD
         SET FIRSTDOK = TIP + CAST(CAST(NRRENDOR AS BIGINT) AS VARCHAR),
             TAGNR    = 0
       WHERE ISNULL(TAGNR,0)<>0;


      UPDATE ORDERITEMS
         SET LISTORDEREDKL = ISNULL(LISTORDEREDKL,'') + CASE WHEN ISNULL(LISTORDEREDKL,'')<>'' AND @ListOrdKl<>'' THEN ',' ELSE '' END + @ListOrdKl
       WHERE NRRENDOR=@NrRendor;



-- 4. Regullim dhe Insertim i FDSCR

      UPDATE A
         SET A.NRD=B.NRRENDDMG
        FROM #TMPDSCR A INNER JOIN #TMPD B ON A.TAGNR=B.NRRENDOR

         SET @ListCommun = dbo.Isd_ListFields2Tables('FDSCR','#TMPDSCR','NRRENDOR,TAGNR,TAGRND')
         SET @Sql= ' 
                   INSERT INTO FDSCR 
                         ('+@ListCommun+',KMON,CMIMSH,VLERASH,VLERAFT,CMIMOR,VLERAOR,
                          FAKLS,FASTATUS,FADESTIN,GJENROWAUT,TAGRND,TAGNR) 
                   SELECT '+@ListCommun+','''',CMIMBS,VLPATVSH,VLPATVSH,CMIMBS,VLPATVSH,'''','''','''',0,0,0
                     FROM #TMPDSCR 
                    WHERE NRD<>0
                 ORDER BY NRD,KOD ';
        EXEC ( @Sql );


          IF OBJECT_ID('TempDB..#TMPD')        IS NOT NULL
             DROP TABLE #TMPD;
          IF OBJECT_ID('TempDB..#TMPDSCR')     IS NOT NULL
             DROP TABLE #TMPDSCR;
          IF OBJECT_ID('TempDB..#ListCmime')   IS NOT NULL
             DROP TABLE #ListCmime;
          IF OBJECT_ID('TempDB..#ListCmimeSp') IS NOT NULL   
             DROP TABLE #ListCmimeSp;
GO
