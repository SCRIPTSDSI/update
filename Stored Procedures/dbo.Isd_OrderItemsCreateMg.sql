SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[Isd_OrderItemsCreateMg]
( 
   @pNrRendor     Int,
   @pTip          Varchar(10),
   @pListRef      Varchar(Max)
 )
As



         SET NOCOUNT ON

     DECLARE @NrRendor Int;


-- Krijimi i dokumentave ne Baze

         SET @NrRendor = @pNrRendor

          IF OBJECT_ID('TempDB..#TMPD')    IS NOT NULL
             DROP TABLE #TMPD;
          IF OBJECT_ID('TempDB..#TMPDSCR') IS NOT NULL
             DROP TABLE #TMPDSCR;
          IF OBJECT_ID('TempDB..#TMPH')    IS NOT NULL
             DROP TABLE #TMPH;
          IF OBJECT_ID('TempDB..#TMPHSCR') IS NOT NULL
             DROP TABLE #TMPHSCR;
          IF OBJECT_ID('TEMPDB..#TMPNRFH') IS NOT NULL
             DROP TABLE #TMPNRFH;

     DECLARE @NrDokMg        Int,
			 @NrDokMgNrFis	 Int,
             @KMag           Varchar(10),
             @Shenim1        Varchar(150),
             @TipMk          Varchar(10),
             @TipDq          Varchar(10),
             @ListRef        Varchar(Max),
             @ListOrdMk      Varchar(Max),
             @ListOrdDq      Varchar(Max),
             @DateDok        DateTime,
             @KodUser        Varchar(60),
             @KodUserMk      Varchar(60),
             @KodUserDq      Varchar(60),
             @NrFdKp         BigInt,
             @NrFdKs         BigInt,
             @CreateFhMk     Bit,
             @CreateFhDq     Bit,
             @Sql            Varchar(Max);

         SET @KodUserMk    = (SELECT ISNULL(ORDERITEMSUSERMK,'')    FROM CONFIGMG);
         SET @KodUserDq    = (SELECT ISNULL(ORDERITEMSUSERDQ,'')    FROM CONFIGMG);
         SET @CreateFhMk   = (SELECT ISNULL(ORDERITEMSCREATEFHMK,0) FROM CONFIGMG);
         SET @CreateFhDq   = (SELECT ISNULL(ORDERITEMSCREATEFHDQ,0) FROM CONFIGMG);
         
         SET @NrFdKp       = 1;
         SET @NrFdKs       = 999999999;
       
         IF  @pTip='M' 
             BEGIN
               SET @TipMk   = @pTip
               SET @TipDq   = '';
               SET @KodUser = @KodUserMk;
             END
         ELSE
         IF  @pTip='D' 
             BEGIN
               SET @TipMk   = '';
               SET @TipDq   = @PTip
               SET @KodUser = @KodUserDq;
             END
         ELSE
      -- IF  @pTip='' OR @pTip='*'
             BEGIN
               SET @TipMk = 'M';
               SET @TipDq = 'D';
               IF @KodUserMk<>''
                  SET @KodUser = @KodUserMk
               ELSE   
                  SET @KodUser = @KodUserDq;
             END;

         SET @ListRef = @pListRef;
         IF  @ListRef='*'
             SET @ListRef = '';


         SET @KMag         = (SELECT KMAG          FROM ORDERITEMS WHERE NRRENDOR=@NrRendor);
         SET @DateDok      = (SELECT DATEDOKCREATE FROM ORDERITEMS WHERE NRRENDOR=@NrRendor);
         SET @Shenim1      = (SELECT SHENIM1       FROM ORDERITEMS WHERE NRRENDOR=@NrRendor);



-- 1. Gjetja e kufijve dhe numur maksimal per flete daljet e magazines prodhim nga levrohet malli

      SELECT @NrFdKp=ISNULL(NRKUFIP,0), @NrFdKs=ISNULL(NRKUFIS,999999999)
        FROM DRHUSER 
       WHERE KODUS=@KodUser AND MODUL='M' AND (TIPDOK='D' OR TIPDOK='FD') AND KODREF=@KMag;
       
         SET @NrDokMg      = (SELECT MAX(NRDOK) 
                                FROM FD 
                               WHERE KMAG=@KMag AND YEAR(DATEDOK)=YEAR(@DateDok) AND NRDOK>=@NrFdKp AND NRDOK<=@NrFdKs );
		SET @NrDokMgNrFis      = (SELECT MAX(NRFISKALIZIM) 
                                FROM FD 
                               WHERE KMAG=@KMag AND YEAR(DATEDOK)=YEAR(@DateDok) AND ISDOCFISCAL=1 AND NRDOK>=@NrFdKp AND NRDOK<=@NrFdKs );

         SET @NrDokMg      = CASE WHEN ISNULL(@NrDokMg,0)>0 THEN @NrDokMg ELSE @NrFdKp END;
         

          
-- 2. Ndertimi i nje tabele me kufijte e numurave per flete hyrjet e magazinave ku levrohet malli

      SELECT KMAG=KODREF, NRKUFIP=ISNULL(NRKUFIP,0), NRKUFIS=ISNULL(NRKUFIS,999999999)
        INTO #TMPNRFH
        FROM DRHUSER 
       WHERE KODUS=@KodUser AND MODUL='M' AND (TIPDOK='H' OR TIPDOK='FH');
     

       
-- 3. Krijimi dokumentave dhe detajeve temporare
                                               -- Kujdes !
                                               -- Renditje te dokumentave Fd sipas kollonave ne grid te cilat jane sipas radhes tek @ListRef. (Me perpara renditja behej sipas KMag.)
      SELECT NRRENDOR      =                      ROW_NUMBER() OVER(ORDER BY CHARINDEX(','+B.KODAF+',',','+@ListRef+',')),    -- ROW_NUMBER() OVER(ORDER BY B.KODAF),
             KMAG          = MAX(A.KMAG),      
             DATEDOK       = MAX(A.DATEDOKCREATE),
             NRDOK         = ISNULL(@NrDokMg,0) + ROW_NUMBER() OVER(ORDER BY CHARINDEX(','+B.KODAF+',',','+@ListRef+',')),    -- ROW_NUMBER() OVER(ORDER BY B.KODAF),
			 NRFISKALIZIM  = ISNULL(@NrDokMgNrFis,0) + ROW_NUMBER() OVER(ORDER BY CHARINDEX(','+B.KODAF+',',','+@ListRef+',')),    -- ROW_NUMBER() OVER(ORDER BY B.KODAF),
             KMAGLNK       = B.KODAF,
          -- NRDOKLNK      = ISNULL((SELECT MAX(NRDOK) FROM FH WHERE KMAG=B.KODAF AND YEAR(DATEDOK)=YEAR(@DateDok)),0) + 1 
------------------ERIALD             
             
             --NRDOKLNK      = ISNULL((SELECT MAX(NRDOK)
             --                          FROM FH LEFT JOIN #TMPNRFH T ON FH.KMAG=T.KMAG
             --                         WHERE FH.KMAG=B.KODAF AND YEAR(FH.DATEDOK)=YEAR(@DateDok) AND FH.NRDOK>=T.NRKUFIP AND FH.NRDOK<=T.NRKUFIS),0)+1
			 NRDOKLNK=0
----------------------------------------------------------------------------------------------                                      
        INTO #TMPD
        FROM ORDERITEMS A INNER JOIN ORDERITEMSSCR B ON A.NRRENDOR=B.NRD
       WHERE A.NRRENDOR = @NrRendor AND (TIPKLL=@TipMk OR TIPKLL=@TipDq) AND (CHARINDEX(','+B.KODAF+',',','+@ListRef+',')>0)
    GROUP BY B.KODAF;


      SELECT B.KOD,
             KMAG          = A.KMAG,
             KMAGLNK       = B.KODAF,
             B.SASI,
             B.SASIKONV,
             NRD           = T1.NRRENDOR,
             TAGNR         = T1.NRRENDOR,
             TIPORD        = B.TIPKLL,
             CMIMSH        = CAST(0.0 AS FLOAT),
             VLERASH       = CAST(0.0 AS FLOAT)
        INTO #TMPDSCR
        FROM ORDERITEMS A INNER JOIN ORDERITEMSSCR B  ON A.NRRENDOR = B.NRD
                          LEFT  JOIN #TMPD         T1 ON T1.KMAGLNK=B.KODAF
       WHERE A.NRRENDOR=@NrRendor AND (TIPKLL=@TipMk OR TIPKLL=@TipDq) AND (ABS(B.SASI)>=0.01 OR ABS(B.SASIKONV)>=0.01) AND
             (CHARINDEX(','+B.KODAF+',',','+@ListRef+','))>0
    ORDER BY B.KODAF,B.KOD;



--                                                               -- Kujdes: Kjo metode nuk evidenton magazinat me sasi zero ...
--       SET @ListOrdMk    = '';
--       SET @ListOrdDq    = '';
--    SELECT @ListOrdMk    = @ListOrdMk + CASE WHEN TIPORD=@TipMk THEN ','+KMAGLNK ELSE '' END,
--           @ListOrdDq    = @ListOrdDq + CASE WHEN TIPORD=@TipDq THEN ','+KMAGLNK ELSE '' END
--      FROM #TMPDSCR
--  GROUP BY KMAGLNK,TIPORD
--  ORDER BY KMAGLNK,TIPORD;

--        IF SUBSTRING(@ListOrdMk,1,1)=','
--           SET @ListOrdMk = SUBSTRING(@ListOrdMk,2,Len(@ListOrdMk));
--        IF SUBSTRING(@ListOrdDq,1,1)=','
--           SET @ListOrdDq = SUBSTRING(@ListOrdDq,2,Len(@ListOrdDq));
--                                                                        


--                                                               

         SET @ListOrdMk    = '';                                 -- Kujdes: Kjo metode evidenton edhe magazinat me sasi zero ...
         SET @ListOrdDq    = '';
      SELECT @ListOrdMk    = @ListOrdMk + CASE WHEN B.TIPKLL=@TipMk THEN ','+B.KODAF ELSE '' END,
             @ListOrdDq    = @ListOrdDq + CASE WHEN B.TIPKLL=@TipDq THEN ','+B.KODAF ELSE '' END
        FROM ORDERITEMS A INNER JOIN ORDERITEMSSCR B ON A.NRRENDOR=B.NRD
       WHERE A.NRRENDOR = @NrRendor AND (B.TIPKLL=@TipMk OR B.TIPKLL=@TipDq) AND (CHARINDEX(','+B.KODAF+',',','+@ListRef+',')>0)
    GROUP BY B.TIPKLL,B.KODAF
    ORDER BY B.TIPKLL,B.KODAF;

          IF SUBSTRING(@ListOrdMk,1,1)=','
             SET @ListOrdMk = SUBSTRING(@ListOrdMk,2,Len(@ListOrdMk));
          IF SUBSTRING(@ListOrdDq,1,1)=','
             SET @ListOrdDq = SUBSTRING(@ListOrdDq,2,Len(@ListOrdDq));





-- Ska nevoje fshirja sepse u vendos ne WHERE tek INSERT

          IF @ListRef<>''
             BEGIN
               SET @Sql = ' 
      DELETE 
        FROM #TMPD
       WHERE CHARINDEX('',''+KMAGLNK+'','','',''+'''+@ListRef+'''+'','')=0; 

      DELETE 
        FROM #TMPDSCR
       WHERE CHARINDEX('',''+KMAGLNK+'','','',''+'''+@ListRef+'''+'','')=0 ';
          -- PRINT @Sql;
             EXEC (@Sql);
           END;



      UPDATE A                      -- Zeron fushen SASIKONV per ato artikuj qe nuk duhet (kontrollohet fusha OrderItemsSortScr..KOEFICENTCOPEDOC)
         SET A.SASIKONV = 0
        FROM #TMPDSCR A 
       WHERE (ISNULL(A.SASIKONV,0)<>0) AND 
             (EXISTS  ( SELECT KOD 
                          FROM OrderItemsSortScr B 
                         WHERE B.KOD=A.KOD AND ISNULL(B.KOEFICENTCOPEDOC,0)=0));
--     WHERE NOT EXISTS  ( SELECT KOD 
--                           FROM OrderItemsSortScr B 
--                          WHERE B.KOD=A.KOD AND ISNULL(B.KOEFICENTCOPEDOC,0)=1);


                            
      DELETE 
        FROM #TMPD
       WHERE NOT EXISTS (SELECT * FROM #TMPDSCR WHERE #TMPD.NRRENDOR=#TMPDSCR.NRD);



      SELECT A.NRRENDOR,
             KMAG          = A.KMAGLNK,
             A.DATEDOK,
             NRDOK         = A.NRDOKLNK,
             KMAGLNK       = A.KMAG,
             NRDOKLNK      = A.NRDOK
        INTO #TMPH
        FROM #TMPD A
       WHERE (@TipMk='M' AND @CreateFhMk=1) OR (@TipDq='D' AND @CreateFhDq=1)
    ORDER BY KMAG;

      SELECT KOD,
             KMAG       = KMAGLNK,
             KMAGLNK    = KMAG,
             SASI,SASIKONV,
             CMIMSH,VLERASH,
             NRD,TAGNR
        INTO #TMPHSCR
        FROM #TMPDSCR
       WHERE (@TipMk='M' AND @CreateFhMk=1) OR (@TipDq='D' AND @CreateFhDq=1) 
    ORDER BY NRD,KOD;
    

      UPDATE A
         SET CMIMSH = CASE WHEN M.GRUP='' OR M.GRUP='A' THEN B.CMSH
                           WHEN M.GRUP='B' THEN B.CMSH1
                           WHEN M.GRUP='C' THEN B.CMSH2
                           WHEN M.GRUP='D' THEN B.CMSH3
                           WHEN M.GRUP='E' THEN B.CMSH4
                           WHEN M.GRUP='F' THEN B.CMSH5
                           WHEN M.GRUP='G' THEN B.CMSH6
                           WHEN M.GRUP='H' THEN B.CMSH7
                           WHEN M.GRUP='I' THEN B.CMSH8
                           WHEN M.GRUP='J' THEN B.CMSH9
                           WHEN M.GRUP='K' THEN B.CMSH10
                           WHEN M.GRUP='L' THEN B.CMSH11
                           WHEN M.GRUP='M' THEN B.CMSH12
                           WHEN M.GRUP='N' THEN B.CMSH13
                           WHEN M.GRUP='O' THEN B.CMSH14
                           WHEN M.GRUP='P' THEN B.CMSH15
                           WHEN M.GRUP='Q' THEN B.CMSH16
                           WHEN M.GRUP='R' THEN B.CMSH17
                           WHEN M.GRUP='S' THEN B.CMSH18
                           WHEN M.GRUP='T' THEN B.CMSH19
                           ELSE                 B.CMSH 
                      END,
             VLERASH = ROUND(A.SASI * CASE WHEN M.GRUP='' OR M.GRUP='A' THEN B.CMSH
                                           WHEN M.GRUP='B' THEN B.CMSH1
                                           WHEN M.GRUP='C' THEN B.CMSH2
                                           WHEN M.GRUP='D' THEN B.CMSH3
                                           WHEN M.GRUP='E' THEN B.CMSH4
                                           WHEN M.GRUP='F' THEN B.CMSH5
                                           WHEN M.GRUP='G' THEN B.CMSH6
                                           WHEN M.GRUP='H' THEN B.CMSH7
                                           WHEN M.GRUP='I' THEN B.CMSH8
                                           WHEN M.GRUP='J' THEN B.CMSH9
                                           WHEN M.GRUP='K' THEN B.CMSH10
                                           WHEN M.GRUP='L' THEN B.CMSH11
                                           WHEN M.GRUP='M' THEN B.CMSH12
                                           WHEN M.GRUP='N' THEN B.CMSH13
                                           WHEN M.GRUP='O' THEN B.CMSH14
                                           WHEN M.GRUP='P' THEN B.CMSH15
                                           WHEN M.GRUP='Q' THEN B.CMSH16
                                           WHEN M.GRUP='R' THEN B.CMSH17
                                           WHEN M.GRUP='S' THEN B.CMSH18
                                           WHEN M.GRUP='T' THEN B.CMSH19
                                           ELSE                 B.CMSH 
                                      END, 2)         
        FROM #TMPDSCR A LEFT JOIN ARTIKUJ  B ON A.KOD=B.KOD
                        LEFT JOIN MAGAZINA M ON A.KMAGLNK=M.KOD;                -- KUJDES, GRUPI meret sipas magazines se lidhur

-- KUJDES : Ne rastin e FD dhe me destinacion meren Cmim shitje ato te magazines Destinacion
--          Ne rastin e FH meren gjithmone ato te magazines se dokumentit(Jo destinacion);
--          (Edhe ne program keshtu eshte)

      UPDATE A
         SET CMIMSH = CASE WHEN M.GRUP='' OR M.GRUP='A' THEN B.CMSH
                           WHEN M.GRUP='B' THEN B.CMSH1
                           WHEN M.GRUP='C' THEN B.CMSH2
                           WHEN M.GRUP='D' THEN B.CMSH3
                           WHEN M.GRUP='E' THEN B.CMSH4
                           WHEN M.GRUP='F' THEN B.CMSH5
                           WHEN M.GRUP='G' THEN B.CMSH6
                           WHEN M.GRUP='H' THEN B.CMSH7
                           WHEN M.GRUP='I' THEN B.CMSH8
                           WHEN M.GRUP='J' THEN B.CMSH9
                           WHEN M.GRUP='K' THEN B.CMSH10
                           WHEN M.GRUP='L' THEN B.CMSH11
                           WHEN M.GRUP='M' THEN B.CMSH12
                           WHEN M.GRUP='N' THEN B.CMSH13
                           WHEN M.GRUP='O' THEN B.CMSH14
                           WHEN M.GRUP='P' THEN B.CMSH15
                           WHEN M.GRUP='Q' THEN B.CMSH16
                           WHEN M.GRUP='R' THEN B.CMSH17
                           WHEN M.GRUP='S' THEN B.CMSH18
                           WHEN M.GRUP='T' THEN B.CMSH19
                           ELSE                 B.CMSH 
                      END,
             VLERASH = ROUND(A.SASI * CASE WHEN M.GRUP='' OR M.GRUP='A' THEN B.CMSH
                                           WHEN M.GRUP='B' THEN B.CMSH1
                                           WHEN M.GRUP='C' THEN B.CMSH2
                                           WHEN M.GRUP='D' THEN B.CMSH3
                                           WHEN M.GRUP='E' THEN B.CMSH4
                                           WHEN M.GRUP='F' THEN B.CMSH5
                                           WHEN M.GRUP='G' THEN B.CMSH6
                                           WHEN M.GRUP='H' THEN B.CMSH7
                                           WHEN M.GRUP='I' THEN B.CMSH8
                                           WHEN M.GRUP='J' THEN B.CMSH9
                                           WHEN M.GRUP='K' THEN B.CMSH10
                                           WHEN M.GRUP='L' THEN B.CMSH11
                                           WHEN M.GRUP='M' THEN B.CMSH12
                                           WHEN M.GRUP='N' THEN B.CMSH13
                                           WHEN M.GRUP='O' THEN B.CMSH14
                                           WHEN M.GRUP='P' THEN B.CMSH15
                                           WHEN M.GRUP='Q' THEN B.CMSH16
                                           WHEN M.GRUP='R' THEN B.CMSH17
                                           WHEN M.GRUP='S' THEN B.CMSH18
                                           WHEN M.GRUP='T' THEN B.CMSH19
                                           ELSE                 B.CMSH 
                                      END,2)         
        FROM #TMPHSCR A LEFT JOIN ARTIKUJ  B ON A.KOD=B.KOD
                        LEFT JOIN MAGAZINA M ON A.KMAG=M.KOD;                   -- KUJDES




   -- INSERT NE DB

   -- FD

      INSERT INTO FD
            (TIP,KMAG,NRMAG,NRDOK,NRFRAKS,DATEDOK,KMAGLNK,NRDOKLNK,NRFRAKSLNK,DATEDOKLNK,DOK_JB,NRSERIAL,DST,
             KMAGRF,SHENIM1,SHENIM2,SHENIM3,SHENIM4,GRUP,
             NRRENDORFAT,TIPFAT,KODLM,KALIMLMZGJ,FAKLS,FADESTIN,FABUXHET,KLASIFIKIM,
             FIRSTDOK,NRDFK,POSTIM,LETER,TAGNR,FISBUSINESSUNIT,FISKODOPERATOR,ISDOCFISCAL,FISPROCES,FISTIPDOK,NRFISKALIZIM)
      SELECT TIP           = 'D',
             KMAG          = A.KMAG,
             NRMAG         = M1.NRRENDOR,
             NRDOK         = A.NRDOK,
             NRFRAKS       = 0,
             DATEDOK       = A.DATEDOK,
             KMAGLNK       = A.KMAGLNK,
             NRDOKLNK      = A.NRDOKLNK,
             NRFRAKSLNK    = 0,
             DATEDOKLNK    = A.DATEDOK,
             DOK_JB        = 0,
             NRSERIAL      = '',                   -- CAST(CAST(A.NRDOK AS BIGINT) AS VARCHAR),
             DST           = 'FU',
             KMAGRF        = A.KMAGLNK,
             
             SHENIM1       = M2.PERSHKRIM,         -- KUJDES, GRUPI meret sipas magazines se lidhur
             SHENIM2       = M2.SHENIM1,
             SHENIM3       = M2.SHENIM2,
             SHENIM4       = '',
             GRUP          = M2.GRUP,              
             
             0,'','',0,'','','','','',0,0,0,
             A.NRRENDOR,
			-----------------------FISKAL------------------------------
			FISBUSINESSUNIT=M1.FISBUSINESSUNIT,
			 FISKODOPERATOR=(SELECT TOP 1 FISKODOPERATOR FROM DRH..USERS WHERE USERN=@KodUser),
			 ISDOCFISCAL=1,
			 FISPROCES='TRANSFER',
			 FISTIPDOK='WTN',
			 NRFISKALIZIM=A.NRFISKALIZIM
			-----------------------------------------------------------
        FROM #TMPD A LEFT JOIN MAGAZINA M1 ON A.KMAG=M1.KOD
                     LEFT JOIN MAGAZINA M2 ON A.KMAGLNK=M2.KOD
        
    ORDER BY A.NRRENDOR; --KMAG;

      UPDATE A
         SET A.NRD=B.NRRENDOR
        FROM #TMPDSCR A INNER JOIN FD B ON A.TAGNR=B.TAGNR
       WHERE B.TAGNR<>0;

          -- FDSCR

      INSERT INTO FDSCR
            (KOD,KODAF,KARTLLG,PERSHKRIM,KOMENT,NRRENDKLLG,
             NJESI,NJESINV,KONVERTART,BC,KOEFSHB,
             SASI,SASIKONV,
             CMIMM,VLERAM,CMIMBS,VLERABS,
             CMIMSH,VLERASH,CMIMOR,VLERAOR,
             TIPKLL,KMON,PROMOC,PROMOCTIP,RIMBURSIM,GJENROWAUT,TIPKTH,TIPFR,SASIFR,VLERAFR,PESHANET,PESHABRT,
             VLERAFT,FAKLS,FADESTIN,FASTATUS,LLOGLM,KOEFICIENT,KLSART,SERI,DTSKADENCE,
             NRD)
      SELECT KOD           = KMAG+'.'+A.KOD+'...',
             A.KOD,A.KOD,
             B.PERSHKRIM,
             KOMENT        = @Shenim1,
             NRRENDKLLG    = B.NRRENDOR,
             B.NJESI,B.NJESI,1,B.BC,1,
             A.SASI,A.SASIKONV,
             B.KOSTMES, 
             VLERAM        = ROUND(A.SASI*B.KOSTMES,2),
             B.KOSTMES, 
             VLERABS       = ROUND(A.SASI*B.KOSTMES,2),
             A.CMIMSH,                         
             A.VLERASH,                    
             CMIMOR        = A.CMIMSH,     -- B.KOSTMES, 
             VLERAOR       = A.VLERASH,    -- ROUND(A.SASI*B.KOSTMES,2),
             TIPKLL        = 'K',
             '',0,'',0,0,'','',0,0,0,0,0,'','','','',0,'',L.SERI,L.DTSKADENCE,
             A.NRD
        FROM #TMPDSCR A LEFT JOIN ARTIKUJ    B ON A.KOD=B.KOD
                        LEFT JOIN ARTIKUJLOT L ON A.KOD=L.KOD
    ORDER BY A.NRD,A.KOD;

      UPDATE FD
         SET TAGNR=0
       WHERE ISNULL(TAGNR,0)<>0;


     -- FH
 
      INSERT INTO FH
            (TIP,KMAG,NRMAG,NRDOK,NRFRAKS,DATEDOK,KMAGLNK,NRDOKLNK,NRFRAKSLNK,DATEDOKLNK,DOK_JB,NRSERIAL,DST,
             KMAGRF,SHENIM1,SHENIM2,SHENIM3,SHENIM4,GRUP,
             NRRENDORFAT,TIPFAT,KODLM,KALIMLMZGJ,FAKLS,FADESTIN,FABUXHET,KLASIFIKIM,
             FIRSTDOK,NRDFK,POSTIM,LETER,TAGNR)
      SELECT TIP           = 'H',
             KMAG          = A.KMAG,
             NRMAG         = M1.NRRENDOR,
             NRDOK         = A.NRDOK,
             NRFRAKS       = 0,
             DATEDOK       = A.DATEDOK,
             KMAGLNK       = A.KMAGLNK,
             NRDOKLNK      = A.NRDOKLNK,
             NRFRAKSLNK    = 0,
             DATEDOKLNK    = A.DATEDOK,
             DOK_JB        = 0,
             NRSERIAL      = '',
             DST           = 'FU',
             KMAGRF        = A.KMAGLNK,
             SHENIM1       = M2.PERSHKRIM,
             SHENIM2       = M2.SHENIM1,
             SHENIM3       = M2.SHENIM2,
             SHENIM4       = '',
             GRUP          = M1.GRUP,              -- KUJDES
             0,'','',0,'','','','','',0,0,0,
             A.NRRENDOR
        FROM #TMPH A LEFT JOIN MAGAZINA M1 ON A.KMAG=M1.KOD
                     LEFT JOIN MAGAZINA M2 ON A.KMAGLNK=M2.KOD
    ORDER BY KMAG;


   -- FHSCR

      UPDATE A
         SET A.NRD=B.NRRENDOR
        FROM #TMPHSCR A INNER JOIN FH B ON A.TAGNR=B.TAGNR
       WHERE B.TAGNR<>0;

      INSERT INTO FHSCR
            (KOD,KODAF,KARTLLG,PERSHKRIM,KOMENT,NRRENDKLLG,
             NJESI,NJESINV,KONVERTART,BC,KOEFSHB,
             SASI,SASIKONV,
             CMIMM,VLERAM,CMIMBS,VLERABS,
             CMIMSH,VLERASH,CMIMOR,VLERAOR,
             TIPKLL,KMON,PROMOC,PROMOCTIP,RIMBURSIM,GJENROWAUT,TIPKTH,TIPFR,SASIFR,VLERAFR,PESHANET,PESHABRT,
             VLERAFT,FAKLS,FADESTIN,FASTATUS,LLOGLM,KOEFICIENT,KLSART,SERI,DTSKADENCE,
             NRD)
      SELECT KOD           = KMAG+'.'+A.KOD+'...',
             A.KOD,A.KOD,
             B.PERSHKRIM,
             KOMENT        = '',
             NRRENDKLLG    = 0,
             B.NJESI,B.NJESI,1,B.BC,1,
             A.SASI,A.SASIKONV,
             B.KOSTMES, 
             VLERAM        = ROUND(A.SASI*B.KOSTMES,2),
             B.KOSTMES, 
             VLERABS       = ROUND(A.SASI*B.KOSTMES,2),

             A.CMIMSH,                        
             A.VLERASH,                    
             CMIMOR        = A.CMIMSH,     -- B.KOSTMES, 
             VLERAOR       = A.VLERASH,    -- ROUND(A.SASI*B.KOSTMES,2),
             TIPKLL        = 'K',
             '',0,'',0,0,'','',0,0,0,0,0,'','','','',0,'',L.SERI,L.DTSKADENCE,
             A.NRD
        FROM #TMPHSCR A LEFT JOIN ARTIKUJ    B ON A.KOD=B.KOD
                        LEFT JOIN ARTIKUJLOT L ON A.KOD=B.KOD
    ORDER BY A.NRD,A.KOD;

      UPDATE FH
         SET TAGNR=0
       WHERE ISNULL(TAGNR,0)<>0;



      UPDATE ORDERITEMS
         SET LISTORDEREDMK = ISNULL(LISTORDEREDMK,'') + CASE WHEN ISNULL(LISTORDEREDMK,'')<>'' AND @ListOrdMk<>'' THEN ',' ELSE '' END + @ListOrdMk,
             LISTORDEREDDQ = ISNULL(LISTORDEREDDQ,'') + CASE WHEN ISNULL(LISTORDEREDDQ,'')<>'' AND @ListOrdDq<>'' THEN ',' ELSE '' END + @ListOrdDq
       WHERE NRRENDOR=@NrRendor;


          IF OBJECT_ID('TempDB..#TMPD')    IS NOT NULL
             DROP TABLE #TMPD;
          IF OBJECT_ID('TempDB..#TMPDSCR') IS NOT NULL
             DROP TABLE #TMPDSCR;
          IF OBJECT_ID('TempDB..#TMPH')    IS NOT NULL
             DROP TABLE #TMPH;
          IF OBJECT_ID('TempDB..#TMPHSCR') IS NOT NULL
             DROP TABLE #TMPHSCR;
          IF OBJECT_ID('TEMPDB..#TMPNRFH') IS NOT NULL
             DROP TABLE #TMPNRFH;
GO
