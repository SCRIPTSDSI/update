SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- EXEC [Isd_GjenerimFDFromFt] 76156,'',''


CREATE         Procedure [dbo].[Isd_GjenerimFDFromFt]

(
  @PNrRendor      INT,
--@PTableTmpLm    VARCHAR(30), -- Aktivizoje me vone
  @PUser          VARCHAR(20),
  @PLgJob         VARCHAR(30)

 )

AS


         SET NOCOUNT ON


     DECLARE @NrRendor       INT,
             @Perdorues      VARCHAR(30),
             @LgJob          VARCHAR(30),
             @IDMStatus      VARCHAR(5),
             @GrupMg         VARCHAR(10),
             @sKMag          VARCHAR(30),
             @NrMag          INT,
             @NrMag1         INT,
             @NrDMag         INT,
             @NrRendorMg     INT,
             @NrDFkMg        INT,
             @NewID          INT,
             @RowCount       INT,
             @Vlere          Float,
             @Kurs1          Float,
             @Kurs2          Float,
             @NewMg          BIT,
             @AutoPostLmFD   BIT,
             @AutoPostMgFJ   BIT,
             @TableTmpLm     VARCHAR(30)
          -- @LlojDok        VARCHAR(10),
          -- @TipDokMg       VARCHAR(10),
          -- @TipDstMg       VARCHAR(10),
          -- @ShkarkimLPFt   BIT

      -- SET @TableTmpLm   = @PTableTmpLm;
         SET @AutoPostLmFD = 0;
         SET @AutoPostMgFJ = 0;
         SET @NewMg        = 0;
         SET @NewId        = 0; 
         SET @NrDFkMg      = 0; --SET @ShkarkimLPFt=0

         SET @NrRendor     = @PNrRendor;
         SET @Perdorues    = @PUser;
         SET @LgJob        = @PLgJob;

      SELECT @AutoPostLmFD = ISNULL(AUTOPOSTLMFD,0),
             @AutoPostMgFJ = ISNULL(AUTOPOSTMGFJ,0)  
        FROM CONFIGLM;


--    SELECT @ShkarkimLPFt = (SELECT DISTINCT 1 FROM ARTIKUJ WHERE AUTOSHKLPFJ=1)


      SELECT @NrRendorMg   = ISNULL(NRRENDDMG,0), 
             @sKMag        = ISNULL(KMAG,''),
             @NrMag        = ISNULL(NRMAG,0),
             @NrDMag       = ISNULL(NRDMAG,0),
             @Kurs1        = ISNULL(KURS1,1),
             @Kurs2        = ISNULL(KURS2,1)
          -- @LlojDok      = LLOJDOK
        FROM FJ 
       WHERE NRRENDOR = @NrRendor;     -- AND (NRMAG<>0) AND (NRDMAG<>0) 


-- Test i nevojshem sepse gjate importeve mbetet keq NRMAG tek FJ

        SET  @NrMag1 = ISNULL((SELECT NRRENDOR FROM MAGAZINA WHERE KOD=@sKMag),'');

         IF  @NrMag<>@NrMag1
             BEGIN

                  SET @NrMag = @NrMag1

               UPDATE FJ
                  SET NRMAG = @NrMag
                 FROM FJ 
                WHERE NRRENDOR=@NrRendor

             END; 


          IF @NrRendorMg>0
             BEGIN
               DECLARE @ChangeDoc BIT,
                       @ChangeScr BIT;

                  EXEC dbo.Isd_ChangeMgFromFt 'FJ', '', @NrRendor, @ChangeDoc Out, @ChangeScr Out -- SELECT @ChangeDoc , @ChangeScr

                    IF @ChangeDoc=0 AND @ChangeScr=0
                       BEGIN
                         RETURN;
                       END;

                    IF @ChangeDoc=1 AND @ChangeScr=0
                       BEGIN
                         EXEC dbo.Isd_UpdateFdFromFt @NrRendor,@Perdorues,@LgJob
                         RETURN;
                       END;
             END;


-- Vazhdon ndertimin e dokumentit magazine ...

          IF @NrRendorMg>0
             BEGIN
               SELECT @NewID      = NRRENDOR, 
                      @NrDFkMg    = ISNULL(NRDFK,0),
                      @Vlere      = (SELECT SUM(VLERAM) FROM FDSCR WHERE NRD=@NrRendorMg),
                      @GrupMg     = (SELECT CASE WHEN CharIndex(Left(LTrim(RTrim(ISNULL(GRUP,'A'))),1),'ABCDEFGHIJ')>0 
                                                 THEN           Left(LTrim(RTrim(ISNULL(GRUP,'A'))),1) 
                                                 ELSE 'A' END 
                                       FROM MAGAZINA B
                                      WHERE B.KOD=A.KMAG)
                 FROM FD A
                WHERE NRRENDOR=@NrRendorMg;
             END;


          IF @NrDFkMg > 0
             BEGIN
               EXEC Dbo.LM_DELFK @NrDFkMg;
               UPDATE FD
                  SET NRDFK=0
                WHERE NRRENDOR = @NrRendorMG;
             END;


       -- IF @NrMag<>0 OR @NrDMag<>0
       --    SELECT Top 1 @NewMg=1  
       --      FROM FJSCR 
       --     WHERE NRD=@NrRendor AND TIPKLL='K' AND ISNULL(NOTMAG,0)=0;
          IF (@NrMag<>0 OR @NrDMag<>0) AND @AutoPostMgFJ>0 
             BEGIN
               IF EXISTS ( SELECT NRRENDOR 
                             FROM FJSCR 
                            WHERE NRD=@NrRendor AND TIPKLL='K' AND ISNULL(NOTMAG,0)=0)
                  SET @NewMg=1;
             END;

                   
          IF @NewMg=0
             BEGIN

               IF @NrRendorMg>0
                  BEGIN
                      EXEC dbo.Isd_AppendTransLog 'FD', @NrRendorMg, @Vlere,'D',@Perdorues,@LgJob;

                    DELETE 
                      FROM FD 
                     WHERE NRRENDOR=@NrRendorMg;  

                    UPDATE FJ 
                       SET NRRENDDMG=0, TIPDMG='' 
                     WHERE NRRENDOR=@NrRendor;
                  END;

               RETURN;

             END;


         SET @IDMStatus = 'M';

          IF @NewID<=0         -- Print @NewID
             BEGIN                   
                   SET  @NewID = 0;

                INSERT  INTO FD 
                       (NRRENDORFAT)
                VALUES (@NrRendor);

                   SET  @RowCount=@@ROWCOUNT;

                    IF  @RowCount<>0
                        SELECT @NewID=@@IDENTITY  

                   SET  @IDMStatus='S';
             END;   
        

          IF @NrRendorMg <> @NewID
             BEGIN
               UPDATE FJ 
                  SET NRRENDDMG = @NewID
                WHERE NRRENDOR=@NrRendor;

                  SET @NrRendorMg = @NewID;
             END;

          IF @NrRendorMg<=0
             RETURN;


          IF @NrRendorMg > 0
             BEGIN
               DELETE FROM FDSCR WHERE NRD = @NrRendorMG;
             END;


      UPDATE A
         SET A.NRMAG        = B.NRMAG,
             A.KMAG         = B.KMAG,
             A.NRDOK        = B.NRDMAG,
             A.DATEDOK      = B.DTDMAG,
             A.NRFRAKS      = B.FRDMAG,
             A.SHENIM1      = B.SHENIM1,
             A.SHENIM2      = B.SHENIM2,
             A.SHENIM3      = B.SHENIM3,
             A.SHENIM4      = B.SHENIM4,
             A.DOK_JB       = 1,
             A.GRUP         = CASE WHEN CHARINDEX(LEFT(LTRIM(RTRIM(ISNULL(C.GRUP,'A'))),1),'ABCDEFGHIJ')>0 
                                   THEN           LEFT(LTRIM(RTRIM(ISNULL(C.GRUP,'A'))),1) 
                                   ELSE 'A' 
                              END,  --@GrupMg,
             A.KTH          = B.KTH,
             A.NRRENDORFAT  = B.NRRENDOR,
             A.TIPFAT       = 'S',
             A.DST          = CASE WHEN B.LLOJDOK = 'K'  THEN 'KM'
                                   WHEN B.LLOJDOK = 'D'  THEN 'DM'
                                   WHEN B.LLOJDOK = 'T'  THEN 'ST'
                                   WHEN B.LLOJDOK = 'FR' THEN 'FR'
                                   ELSE                       'SH'
                              END,  --Left(@TipDstMg,2),  
             A.KMAGRF       = '',
             A.KMAGLNK      = '',
             A.NRDOKLNK     = 0,
             A.NRFRAKSLNK   = 0,
             A.NRSERIAL     = '',
             A.KODLM        = '',
             A.KLASIFIKIM   = '',
             A.FAKLS        = '',
             A.FADESTIN     = '',
             A.FABUXHET     = '',
             A.TIP          = 'D',
             A.KODPACIENT   = B.KODPACIENT,
             A.KODDOCTEGZAM = B.KODDOCTEGZAM,
             A.KODDOCTREFER = B.KODDOCTREFER,
             A.USI          = B.USI,
             A.USM          = B.USM,
             A.POSTIM       = 0,
             A.LETER        = 0,  
             A.FIRSTDOK     = B.FIRSTDOK,
             A.NRDFK        = 0,
             A.DATEEDIT     = GETDATE()
        FROM FD A INNER JOIN FJ B       ON A.NRRENDOR=B.NRRENDDMG
                  INNER JOIN MAGAZINA C ON B.NRMAG=C.NRRENDOR
       WHERE A.NRRENDOR=@NrRendorMG AND B.NRRENDOR=@NrRendor;

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
             TIPFR,SASIFR,VLERAFR,SASIKONV,GJENROWAUT,ORDERSCR)
      SELECT @NrRendorMG, 
             Dbo.Isd_SegmentNewInsert(A.KOD,'',5), 
             A.KODAF, A.KARTLLG, A.PERSHKRIM, A.NRRENDKLLG, A.NJESI,
             A.SASI,  

             B.KOSTMES, ROUND((SASI*B.KOSTMES),3), 
             ROUND((A.CMIMBS*@Kurs2)/@Kurs1,3), ROUND((A.VLPATVSH*@Kurs2)/@Kurs1,3),
             B.KOSTMES, ROUND((SASI*B.KOSTMES),3),

             CASE WHEN @GrupMg='' OR @GrupMg='A' THEN CMSH
                  WHEN @GrupMg='B' THEN CMSH1 
                  WHEN @GrupMg='C' THEN CMSH2 
                  WHEN @GrupMg='D' THEN CMSH3 
                  WHEN @GrupMg='E' THEN CMSH4 
                  WHEN @GrupMg='F' THEN CMSH5 
                  WHEN @GrupMg='G' THEN CMSH6 
                  WHEN @GrupMg='H' THEN CMSH7 
                  WHEN @GrupMg='I' THEN CMSH8 
                  WHEN @GrupMg='J' THEN CMSH9 
                  WHEN @GrupMg='K' THEN CMSH10 
                  WHEN @GrupMg='L' THEN CMSH11
                  WHEN @GrupMg='M' THEN CMSH12 
                  WHEN @GrupMg='N' THEN CMSH13
                  WHEN @GrupMg='O' THEN CMSH14
                  WHEN @GrupMg='P' THEN CMSH15 
                  WHEN @GrupMg='Q' THEN CMSH16 
                  WHEN @GrupMg='R' THEN CMSH17 
                  WHEN @GrupMg='S' THEN CMSH18 
                  WHEN @GrupMg='T' THEN CMSH19 
                  ELSE                  CMSH 
             END,
             ROUND(SASI * CASE WHEN @GrupMg='' OR @GrupMg='A' THEN CMSH
                               WHEN @GrupMg='B' THEN CMSH1 
                               WHEN @GrupMg='C' THEN CMSH2 
                               WHEN @GrupMg='D' THEN CMSH3 
                               WHEN @GrupMg='E' THEN CMSH4 
                               WHEN @GrupMg='F' THEN CMSH5 
                               WHEN @GrupMg='G' THEN CMSH6 
                               WHEN @GrupMg='H' THEN CMSH7 
                               WHEN @GrupMg='I' THEN CMSH8 
                               WHEN @GrupMg='J' THEN CMSH9 
                               WHEN @GrupMg='K' THEN CMSH10 
                               WHEN @GrupMg='L' THEN CMSH11 
                               WHEN @GrupMg='M' THEN CMSH12 
                               WHEN @GrupMg='N' THEN CMSH13 
                               WHEN @GrupMg='O' THEN CMSH14 
                               WHEN @GrupMg='P' THEN CMSH15 
                               WHEN @GrupMg='Q' THEN CMSH16 
                               WHEN @GrupMg='R' THEN CMSH17 
                               WHEN @GrupMg='S' THEN CMSH18 
                               WHEN @GrupMg='T' THEN CMSH19 
                               ELSE                  CMSH 
                          END,3),
             ROUND((A.VLPATVSH * @Kurs2) / @Kurs1,3), 

             A.KOEFSHB, A.NJESINV, A.TIPKLL, 
             A.BC, 
             ISNULL(A.KOMENT,''), 
             ISNULL(A.PROMOC,0), 
             ISNULL(A.PROMOCTIP,''), 
             ISNULL(A.TIPKTH,''), 
             '',
             ISNULL(A.SERI,''),
             ISNULL(A.RIMBURSIM,0), 
             A.DTSKADENCE,
             A.KONVERTART,--ISNULL(B.KONV1,1)*ISNULL(B.KONV2,1),
             '',1,'',
             '','','', 
             FPROFIL,FCOLOR,FLENGTH,FBARS,
             A.PESHANET,A.PESHABRT,PROMPTPROD1,
             ISNULL(TIPFR,''),
             ISNULL(SASIFR,0),
             ISNULL(VLERAFR,0),
             ISNULL(SASIKONV,0),
             0,0

        FROM FJSCR A LEFT JOIN ARTIKUJ B ON A.KARTLLG = B.KOD 

       WHERE (A.NRD=@NrRendor) AND (A.TIPKLL='K') AND (ISNULL(A.NOTMAG,0)=0)

    ORDER BY A.NRD,A.NRRENDOR;



      SELECT @Vlere = SUM(ISNULL(VLERAM,0))
        FROM FDSCR A
       WHERE NRD=@NrRendorMg;  

        EXEC dbo.Isd_AppendTransLog 'FD', @NrRendorMg, @Vlere, @IDMStatus, @Perdorues, @LgJob;

-- AutoShkarkim                     -- IF @ShkarkimLPFt=1
--   IF (SELECT ISNULL(Count(''),0)  
--         FROM FDSCR A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD 
--        WHERE A.NRD=@NrRendorMg AND B.TIP='P' AND B.AUTOSHKLPFJ=1)>0
--      EXEC Isd_ShkarkimProdukt 'D', @NrRendorMg



--    AutoShkarkim                     IF @ShkarkimLPFt=1

--    SELECT * FROM FDSCR WHERE NRD=@NrRendorMg
        EXEC Isd_ShkarkimProdukt 'D', @NrRendorMg;


--    Postimi ne LM

      --  IF @AutoPostLmFD=0 OR @TableTmpLm=''
      --     RETURN;
     -- EXEC [Isd_KalimLM] @PTip='D', @PNrRendor=@NrID, @PSQLFilter='', @PTableNameTmp=@TableTmpLm; 
GO
