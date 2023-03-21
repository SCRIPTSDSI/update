SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- EXEC [Isd_GjenerimFDFromFtAll] '',100,''


CREATE         Procedure [dbo].[Isd_GjenerimFDFromFtAll]
(
  @PTagRnd    VARCHAR(30), -- Rasti kur vjen nga Pike shitje dhe aty krijohen FJ (me nje @PTagRnd te dhene)
  @PWhere     VARCHAR(Max) -- Rasti kur vjen me nje WHERE...
 )
AS

          SET NOCOUNT ON

     DECLARE @TagRnd       VARCHAR(30),
             @WHERE        VARCHAR(MAX);


      SELECT @TagRnd = @PTagRnd;

          IF @TagRnd=''
             SELECT @TagRnd = dbo.Isd_RandomNumberChars(dbo.Isd_RandomNumber());

          IF @PWhere <> ''
             SELECT @WHERE = @PWhere
          ELSE
          IF @PTagRnd<>'' 
             SELECT @WHERE = 'TAGRND='+QUOTENAME(@TagRnd,'''')
          ELSE
             SELECT @WHERE = '1=1';

      SELECT @WHERE = @WHERE + ' AND ';

          IF OBJECT_ID('TempDB..#FJ') IS NOT NULL
             DROP TABLE #FJ;
--      EXEC ('  Use TempDB 
--                IF Exists (SELECT Name FROM Sys.TABLES WHERE Object_Id=Object_Id(''#FJ''))
--   	               DROP TABLE #FJ ')

      SELECT NRRENDOR  = CAST(0 AS BIGINt),
             NRRENDDMG = CAST(0 AS BIGINT) 
        INTO #Fj
        FROM FJ 
       WHERE 1=2;


      EXEC ('  INSERT INTO #FJ 
                     (NRRENDOR,NRRENDDMG) 
               SELECT NRRENDOR,NRRENDDMG  
                 FROM FJ A
                WHERE '+@WHERE+' ISNULL(A.NRMAG,0)<>0 AND ISNULL(A.NRDMAG,0)<>0 AND 
                      EXISTS (SELECT NRD 
                                FROM FJScr B 
                               WHERE A.NrRendor=B.Nrd AND B.TIPKLL=''K'' AND ISNULL(B.NOTMAG,0)=0) ');

      CREATE UNIQUE INDEX AK_FJ ON #FJ (NRRENDOR)
             WITH (IGNORE_DUP_KEY = OFF) 


-- FSHI FD dhe FDSCR    per ato qe egzistojne.

-- Delete FK
       DELETE A
         FROM FK    A INNER JOIN FD  B ON A.NRRENDOR = B.NRDFK 
                      INNER JOIN #FJ C ON B.NRRENDOR = C.NRRENDDMG;
-- Delete FD 
       DELETE A
         FROM FD    A INNER JOIN #FJ B ON A.NRRENDOR=B.NRRENDDMG;
       DELETE A
         FROM FDSCR A INNER JOIN #FJ B ON A.NRD=B.NRRENDDMG;


  INSERT INTO FD 
             (NRMAG,KMAG,NRDOK,DATEDOK,NRFRAKS,
              SHENIM1,SHENIM2,SHENIM3,SHENIM4,
              DOK_JB,GRUP,KTH,NRRENDORFAT,TIPFAT,DST,KMAGRF,KMAGLNK,NRDOKLNK,
              NRSERIAL,KODLM,KLASIFIKIM,
              FAKLS,FADESTIN,FABUXHET,NRDOKUP,
              NRFRAKSLNK,TIP,USI,USM,POSTIM,LETER,FIRSTDOK,NRDFK,TAGNR,TAGRND)
       SELECT MAX(A.NRMAG),
              MAX(A.KMAG),
              MAX(A.NRDMAG),
              MAX(A.DTDMAG),
              MAX(A.FRDMAG),
              MAX(A.SHENIM1),
              MAX(A.SHENIM2),
              MAX(A.SHENIM3),
              MAX(A.SHENIM4),
              1, 
              CASE WHEN CHARINDEX(LEFT(LTRIM(RTRIM(ISNULL(MAX(B.GRUP),'A'))),1),'ABCDEFGHIJ')>0 
                   THEN           LEFT(LTRIM(RTRIM(ISNULL(MAX(B.GRUP),'A'))),1) 
                   ELSE 'A' 
              END, 
              A.KTH, 
              A.NRRENDOR,
              'S', 
              CASE WHEN MAX(A.LLOJDOK) = 'K'  THEN 'KM'
                   WHEN MAX(A.LLOJDOK) = 'D'  THEN 'DM'
                   WHEN MAX(A.LLOJDOK) = 'T'  THEN 'ST'
                   WHEN MAX(A.LLOJDOK) = 'FR' THEN 'FR'
                   ELSE                            'SH'
              END,
              '','', 0,
              '','','',
              '','','','',
              0, 'D',
              MAX(ISNULL(A.USI,'')), 
              MAX(ISNULL(A.USM,'')), 
              0, 
              0, 
              MAX(A.FIRSTDOK), 
              0,
              A.NRRENDOR,
              @TagRnd
         FROM FJ A INNER JOIN #FJ      C ON A.NRRENDOR=C.NRRENDOR 
                   INNER JOIN MAGAZINA B ON A.NRMAG   =B.NRRENDOR
     GROUP BY A.NRRENDOR, A.KTH;



  INSERT INTO FDSCR 
             (NRD, KOD, KODAF, KARTLLG, PERSHKRIM, NRRENDKLLG, NJESI,
              SASI, 
              CMIMM, VLERAM, CMIMOR, VLERAOR, CMIMBS, VLERABS, 
              CMIMSH,VLERASH,
              VLERAFT, 
              KOEFSHB, NJESINV, TIPKLL, BC, KOMENT, PROMOC, PROMOCTIP,TIPKTH, KMON,SERI,
              RIMBURSIM, DTSKADENCE,KONVERTART,
              LLOGLM,KOEFICIENT,KLSART,
              FAKLS,FASTATUS,FADESTIN,
              FPROFIL,FCOLOR,FLENGTH,FBARS,
              PESHANET,PESHABRT,PROMPTPROD1,
              TIPFR,SASIFR,VLERAFR,SASIKONV,GJENROWAUT,
              ORDERSCR,GJENDJE,
              TAGNR,TAGRND)
       SELECT C1.NRRENDOR,   
              Dbo.Isd_SegmentNewInsert(A.KOD,'',5), 
              A.KODAF, A.KARTLLG, A.PERSHKRIM, A.NRRENDKLLG, A.NJESI,
              A.SASI,  

              D.KOSTMES, 
              ROUND((SASI*D.KOSTMES),3), 
              CASE WHEN B.KURS1*B.KURS2>0 
                   THEN ROUND((A.CMIMBS   * B.KURS2)/B.KURS1,3)
                   ELSE A.CMIMBS   END, 
              CASE WHEN B.KURS1*B.KURS2>0 
                   THEN ROUND((A.VLPATVSH * B.KURS2)/B.KURS1,3)
                   ELSE A.VLPATVSH END,
              D.KOSTMES, 
              ROUND((SASI*D.KOSTMES),3),

              CASE WHEN E.GRUP='B' THEN CMSH1 
                   WHEN E.Grup='C' THEN CMSH2 
                   WHEN E.Grup='D' THEN CMSH3 
                   WHEN E.Grup='E' THEN CMSH4 
                   WHEN E.Grup='F' THEN CMSH5 
                   WHEN E.Grup='G' THEN CMSH6 
                   WHEN E.Grup='H' THEN CMSH7 
                   WHEN E.Grup='I' THEN CMSH8 
                   WHEN E.Grup='J' THEN CMSH9 
                   WHEN E.Grup='K' THEN CMSH10 
                   WHEN E.Grup='L' THEN CMSH11 
                   WHEN E.Grup='M' THEN CMSH12 
                   WHEN E.Grup='N' THEN CMSH13 
                   WHEN E.Grup='O' THEN CMSH14 
                   WHEN E.Grup='P' THEN CMSH15 
                   WHEN E.Grup='Q' THEN CMSH16 
                   WHEN E.Grup='R' THEN CMSH17 
                   WHEN E.Grup='S' THEN CMSH18 
                   WHEN E.Grup='T' THEN CMSH19 
                   ELSE                 CMSH 
              END,
              
              ROUND(SASI * CASE WHEN E.Grup='B' THEN CMSH1 
                                WHEN E.Grup='C' THEN CMSH2 
                                WHEN E.Grup='D' THEN CMSH3 
                                WHEN E.Grup='E' THEN CMSH4 
                                WHEN E.Grup='F' THEN CMSH5 
                                WHEN E.Grup='G' THEN CMSH6 
                                WHEN E.Grup='H' THEN CMSH7 
                                WHEN E.Grup='I' THEN CMSH8 
                                WHEN E.Grup='J' THEN CMSH9 
                                WHEN E.Grup='K' THEN CMSH10 
                                WHEN E.Grup='L' THEN CMSH11 
                                WHEN E.Grup='M' THEN CMSH12 
                                WHEN E.Grup='N' THEN CMSH13 
                                WHEN E.Grup='O' THEN CMSH14 
                                WHEN E.Grup='P' THEN CMSH15 
                                WHEN E.Grup='Q' THEN CMSH16 
                                WHEN E.Grup='R' THEN CMSH17 
                                WHEN E.Grup='S' THEN CMSH18 
                                WHEN E.Grup='T' THEN CMSH19 
                                ELSE                 CMSH 
                           END,3),
                           
              CASE WHEN B.KURS1*B.KURS2>0
                   THEN ROUND((A.VLPATVSH * B.Kurs2) / B.Kurs1,3)
                   ELSE A.VLPATVSH 
              END, 
                   
              A.KOEFSHB, 
              A.NJESINV, 
              A.TIPKLL, 
              A.BC, 
              ISNULL(A.KOMENT,''), 
              ISNULL(A.PROMOC,0), 
              ISNULL(A.PROMOCTIP,''), 
              ISNULL(A.TIPKTH,''), 
              '',
              ISNULL(A.SERI,''),
              ISNULL(A.RIMBURSIM,0), 
              A.DTSKADENCE,
              ISNULL(D.KONV1,1)*ISNULL(D.KONV2,1),
              '',1,'',
              '','','', 
              ISNULL(FPROFIL,''),
              ISNULL(FCOLOR,''),
              ISNULL(FLENGTH,''),
              ISNULL(FBARS,0),
              A.PESHANET,
              A.PESHABRT,
              A.PROMPTPROD1,
              ISNULL(TIPFR,''),
              ISNULL(SASIFR,0),
              ISNULL(VLERAFR,0),
              ISNULL(SASIKONV,0),
              0,
              0,0,
              0, 
              '' 
         FROM FJSCR A INNER JOIN FJ  B      ON A.NRD = B.NRRENDOR
                      INNER JOIN #FJ C      ON B.NRRENDOR = C.NRRENDOR
                      INNER JOIN FD  C1     ON B.NRRENDOR = C1.TAGNR
                      LEFT  JOIN ARTIKUJ D  ON A.KARTLLG  = D.KOD
                      LEFT  JOIN MAGAZINA E ON B.NRMAG = E.NRRENDOR 
        WHERE (A.TIPKLL='K') AND (ISNULL(A.NOTMAG,0)=0); 

       UPDATE A
          SET A.NRRENDDMG = B.NRRENDOR
         FROM FJ A INNER JOIN FD  B ON A.NRRENDOR=B.TAGNR
                   INNER JOIN #FJ C ON A.NRRENDOR=C.NRRENDOR;

-- Zerimet ....
       UPDATE A
          SET A.TAGNR = 0
         FROM FD A 
        WHERE A.TAGRND=@TagRnd AND ISNULL(A.TAGNR,0)<>0;



-- Shkarkim te Produkteve ne se ka te tille

      EXEC Isd_ShkarkimProduktAll 'D', @TagRnd, ''; 


-- Zerimi perfundimtar i FD te ardhura nga FJ

       UPDATE A
          SET A.TAGRND = 0
         FROM FD A 
        WHERE A.TAGRND=@TagRnd;



GO
