SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- EXEC [Isd_GjenerimFhFromFtAmb] 76156,'',''


CREATE         Procedure [dbo].[Isd_GjenerimFhFromFtAmb]

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
             @Vlere          Float,
             @KMagAmb        VARCHAR(30),
             @NrMagAmb       INT,
          -- @NrMag          INT,
             @NrDMag         INT,
             @FrDMag         INT,
             @NrRendorMg     INT,
             @NrDFkMg        INT,
             @NewID          INT,
             @RowCount       INT,
             @Kurs1          Float,
             @Kurs2          Float,
             @NewMg          Bit,
             @AutoPostLmFh   Bit,
             @AutoPostMgFj   Bit,
             @TableTmpLm     VARCHAR(30),
             @IsAmb          Bit,
             @KodFKL         VARCHAR(30),
             @DtDok          DateTime;      

         
      -- SET @TableTmpLm   = @PTableTmpLm;
         SET @AutoPostLmFh = 0;
         SET @AutoPostMgFj = 0;
         SET @NewMg        = 0;
         SET @NewId        = 0; 
         SET @NrDFkMg      = 0; 
         SET @IsAmb        = 0;

         SET @NrRendor     = @PNrRendor;
         SET @Perdorues    = @PUser;
         SET @LgJob        = @PLgJob;

      SELECT @AutoPostLmFh = ISNULL(AUTOPOSTLMFH,0),
             @AutoPostMgFj = ISNULL(AUTOPOSTMGFJ,0)  
        FROM CONFIGLM;



-- Kujdes: NrdMag ???? 

      SELECT @NrRendorMg   = ISNULL(NRRENDORAMB,0),
             @KodFKL       = KODFKL,
             @DtDok        = DATEDOK,
          -- @NrMag        = ISNULL(NRMAG,0),
          -- @NrDMag       = ISNULL(NRDMAG,0),  -- ?? te llogaritet
             @Kurs1        = ISNULL(KURS1,1),
             @Kurs2        = ISNULL(KURS2,1)
        FROM FJ 
       WHERE NRRENDOR = @NrRendor;     


         SET @IsAmb = 0;
          IF EXISTS (SELECT NRD FROM FJSCR WHERE NRD=@NrRendor And ISNULL(ISAMB,0)=1)
             SET @IsAmb  = 1;
      

      SELECT @KMagAmb = KMAGAMB
        FROM CONFIGMG;

         SET @KMagAmb = ISNULL(@KMagAmb,'');


      SELECT @GrupMg   = CASE WHEN CHARINDEX(LEFT(LTRIM(RTRIM(ISNULL(GRUP,'A'))),1),'ABCDEFGHIJ')>0 
                              THEN           LEFT(LTRIM(RTRIM(ISNULL(GRUP,'A'))),1) 
                              ELSE 'A' 
                         END,
             @NrMagAmb = NRRENDOR 
        FROM MAGAZINA 
       WHERE KOD = @KMagAmb


          IF @NrRendorMg>0  -- And @IsAmb=1
             BEGIN
               DECLARE @ChangeDoc Bit,
                       @ChangeScr Bit;      

                  EXEC dbo.Isd_ChangeMgFromFt 'FJ', 'FH', @NrRendor, @ChangeDoc Out, @ChangeScr Out -- SELECT @ChangeDoc , @ChangeScr

                    IF @ChangeDoc=0 And @ChangeScr=0
                       BEGIN
                         RETURN;
                       END;

                    IF @ChangeDoc=1 And @ChangeScr=0
                       BEGIN
                         EXEC dbo.Isd_UpdateFhFromFtAmb @NrRendor,@Perdorues,@LgJob
                         RETURN;
                       END;
             END;



-- Vazhdon ndertimin e dokumentit magazine ...

         SET @NrDMag = 0;
         SET @FrDMag = 0;

          IF @NrRendorMg>0
             BEGIN
               SELECT @NewID      = NRRENDOR, 
                      @NrDFkMg    = ISNULL(NRDFK,0),
                      @NrDMag     = NRDOK,
                      @FrDMag     = NRFRAKS,
                   -- @NrFraks    = 0,
                      @Vlere      = (SELECT SUM(VLERAM) FROM FHSCR WHERE NRD=@NrRendorMg)
                 FROM FH A
                WHERE NRRENDOR=@NrRendorMg;
             END;


          IF @NrDFkMg > 0
             EXEC Dbo.LM_DELFK @NrDFkMg;


          IF (@NrMagAmb<>0) And @AutoPostMgFj>0 
       -- IF (@NrMagAmb<>0 or @NrDMag<>0) And @AutoPostMgFj>0 
             BEGIN
               IF EXISTS ( SELECT NRRENDOR 
                             FROM FJSCR 
                            WHERE NRD=@NrRendor AND TIPKLL='K' AND ISNULL(NOTMAG,0)=0 And ISNULL(ISAMB,0)=1)
                  SET @NewMg=1;
             END;

                   
          IF @NewMg=0
             BEGIN

               IF @NrRendorMg>0
                  BEGIN
                      EXEC dbo.Isd_AppendTransLog 'FH', @NrRendorMg, @Vlere,'D',@Perdorues,@LgJob;

                    DELETE 
                      FROM FH 
                     WHERE NRRENDOR=@NrRendorMg;  

                    UPDATE FJ 
                       SET NRRENDORAMB=0
                     WHERE NRRENDOR=@NrRendor;
                  END;

               RETURN;

             END;


         SET @IDMStatus = 'M';

          IF @NewID<=0         -- Print @NewID
             BEGIN                   
                   SET  @NewID = 0;

                INSERT  INTO FH 
                       (NRRENDORFATAMB)
                VALUES (@NrRendor);

                   SET  @RowCount=@@ROWCOUNT;

                    IF  @RowCount<>0
                        SELECT @NewID=@@IDENTITY  

                   SET  @IDMStatus='S';
             END;   
        

          IF @NrRendorMg <> @NewID
             BEGIN
               UPDATE FJ 
                  SET NRRENDORAMB = @NewID
                WHERE NRRENDOR=@NrRendor;

                  SET @NrRendorMg = @NewID;
             END;

          IF @NrRendorMg<=0
             RETURN;


          IF @NrRendorMg > 0
             BEGIN
               DELETE 
                 FROM FHSCR 
                WHERE NRD = @NrRendorMG;
             END;

          IF ISNULL(@NrDMag,0)=0
             BEGIN
                 SELECT @NrDMag = MAX(ISNULL(NRDOK,0))
                   FROM FH
                  WHERE KMAG=@KMagAmb AND YEAR(DATEDOK)=YEAR(@DtDok)
               Group By KMAG,YEAR(DATEDOK)
             END;


          IF ISNULL(@NrDMag,0)=0
             SET @NrDMag = 1;


      UPDATE A
         SET A.NRMAG          = @NrMagAmb,  
             A.KMAG           = @KMagAmb,
             A.DATEDOK        = B.DTDMAG,
             A.NRDOK          = @NrDMag,    -- Te llogaritet
             A.NRFRAKS        = @FrDMag,    -- Te llogaritet
             A.SHENIM1        = B.SHENIM1,
             A.SHENIM2        = B.SHENIM2,
             A.SHENIM3        = B.SHENIM3,
             A.SHENIM4        = B.SHENIM4,
             A.DOK_JB         = 1,
             A.GRUP           = @GrupMg,
--                              CASE WHEN CharIndex(Left(LTrim(RTrim(ISNULL(C.GRUP,'A'))),1),'ABCDEFGHIJ')>0 
--                                   THEN           Left(LTrim(RTrim(ISNULL(C.GRUP,'A'))),1) 
--                                   ELSE 'A' 
--                              END,  --@GrupMg,
             A.KTH            = B.KTH,
             A.NRRENDORFATAMB = B.NRRENDOR,
             A.TIPFAT         = 'S',
             A.DST            = CASE WHEN B.LLOJDOK = 'K' THEN 'KM'
                                     WHEN B.LLOJDOK = 'D' THEN 'DM'
                                     WHEN B.LLOJDOK = 'T' THEN 'ST'
                                     ELSE                      'SH'
                                END,  --Left(@TipDstMg,2),  
             A.KMAGRF         = '',
             A.KMAGLNK        = '',
             A.NRDOKLNK       = 0,
             A.NRFRAKSLNK     = 0,
             A.NRSERIAL       = '',
             A.KODLM          = '',
             A.KLASIFIKIM     = '',
             A.FAKLS          = '',
             A.FADESTIN       = '',
             A.FABUXHET       = '',
             A.TIP            = 'D',
             A.USI            = B.USI,
             A.USM            = B.USM,
             A.POSTIM         = 0,
             A.LETER          = 0,  
             A.FIRSTDOK       = B.FIRSTDOK,
             A.NRDFK          = 0,
             A.ISAMB          = 1

        FROM FH A INNER JOIN FJ B       On A.NRRENDOR=B.NRRENDORAMB
                  INNER JOIN MAGAZINA C On B.NRMAG=C.NRRENDOR

       WHERE A.NRRENDOR=@NrRendorMG AND B.NRRENDOR=@NrRendor;


      INSERT INTO FHSCR 
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
             PESHANET,PESHABRT,
             ISAMB,KODKLF,DTDOK,PROMPTPROD1,
             TIPFR,SASIFR,VLERAFR,SASIKONV,GJENROWAUT,ORDERSCR)
      SELECT @NrRendorMG, 
             Dbo.Isd_SegmentNewInsert(Dbo.Isd_SegmentNewInsert(A.KOD,'',5),@KMagAmb,1), 
             A.KODAF, A.KARTLLG, A.PERSHKRIM, A.NRRENDKLLG, A.NJESI,
             A.SASI,  

             B.KOSTMES, Round((SASI*B.KOSTMES),3), 
             Round((A.CMIMBS*@Kurs2)/@Kurs1,3), Round((A.VLPATVSH*@Kurs2)/@Kurs1,3),
             B.KOSTMES, Round((SASI*B.KOSTMES),3),

             CASE WHEN @GrupMg='' or @GrupMg='A' THEN CMSH
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
             Round(SASI * 
                   CASE WHEN @GrupMg='' or @GrupMg='A' THEN CMSH
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
             Round((A.VLPATVSH * @Kurs2) / @Kurs1,3), 

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
             A.PESHANET,A.PESHABRT,

             A.ISAMB,KODKLF=@KodFKL, DTDOK=@DtDok,
             PROMPTPROD1,
             ISNULL(TIPFR,''),
             ISNULL(SASIFR,0),
             ISNULL(VLERAFR,0),
             ISNULL(SASIKONV,0),
             0,0

        FROM FJSCR A LEFT JOIN ARTIKUJ B On A.KARTLLG = B.KOD 

       WHERE (A.NRD=@NrRendor) AND (A.TIPKLL='K') AND (ISNULL(A.NOTMAG,0)=0) And ISNULL(A.ISAMB,0)=1;


      SELECT @Vlere = SUM(ISNULL(VLERAM,0))
        FROM FHSCR A
       WHERE NRD=@NrRendorMg;  


        EXEC dbo.Isd_AppendTransLog 'FH', @NrRendorMg, @Vlere, @IDMStatus, @Perdorues, @LgJob;

      UPDATE FJ 
         SET NRRENDORAMB=@NrRendorMG
       WHERE NRRENDOR=@NrRendor


--    Postimi ne LM

      --  IF @AutoPostLmFD=0 Or @TableTmpLm=''
      --     RETURN;
     -- EXEC [Isd_KalimLM] @PTip='D', @PNrRendor=@NrID, @PSQLFilter='', @PTableNameTmp=@TableTmpLm; 



GO
