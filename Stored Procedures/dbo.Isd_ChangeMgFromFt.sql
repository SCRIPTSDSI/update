SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Declare @ChangeDoc     Bit,
--        @ChangeScr     Bit;
--   Exec Isd_ChangeMgFromFt 'FJ', '', 567723, @ChangeDoc Out, @ChangeScr Out;
-- SELECT A=@ChangeDoc, B=@ChangeScr;

CREATE         Procedure [dbo].[Isd_ChangeMgFromFt]

(
  @PTableName     Varchar(40),
  @PTableMg       Varchar(40),
  @PNrRendor      Int,
  @PChangeDoc     Bit Out,
  @PChangeScr     Bit Out
 )

As

         SET NoCount On

     Declare @TableName   Varchar(40),
             @TableMg     Varchar(40),
             @NrRendor    Int,
             @ChangeDoc   Bit,
             @ChangeScr   Bit,
             @KodFKLAmb   Varchar(30),
             @DtDokAmb    DateTime,
             @NrMagAmb    Int,
             @KMagAmb     Varchar(30),
             @GrupMgFt    Varchar(10),
             @DSTFt       Varchar(10),
             @Kurs1       Float,
             @Kurs2       Float,
             @NrRendorMg  Int;

         SET @TableName = @PTableName;
         SET @TableMg   = @PTableMg;
         SET @NrRendor  = @PNrRendor;
         SET @ChangeDoc = 0;
         SET @ChangeScr = 0;



--------------

          IF @TableName='FJ' AND (@TableMg='' Or @TableMg='FD')
             BEGIN    

               SELECT @NrRendorMg = ISNULL(NRRENDDMG,0),

                      @GrupMgFt   = (SELECT CASE WHEN CHARINDEX(LEFT(LTRIM(RTRIM(ISNULL(GRUP,'A'))),1),'ABCDEFGHIJ')>0 
                                                 THEN           LEFT(LTRIM(RTRIM(ISNULL(GRUP,'A'))),1) 
                                                 ELSE 'A' END 
                                       FROM MAGAZINA B
                                      WHERE B.KOD=A.KMAG),

                      @DSTFt      = CASE WHEN A.LLOJDOK = 'K'  THEN 'KM'
                                         WHEN A.LLOJDOK = 'D'  THEN 'DM'
                                         WHEN A.LLOJDOK = 'T'  THEN 'ST'
                                         WHEN A.LLOJDOK = 'FR' THEN 'FR'  -- Firo Klasa 'A'
                                         ELSE                       'SH'
                                    END
                 FROM FJ A
                WHERE NRRENDOR=@NrRendor;

                  SET @NrRendorMg=ISNULL(@NrRendorMg,0);

         -- Dokumenti FJ - FD

              IF ( EXISTS ( SELECT KMAG, NRMAG, NRDMAG, DTDMAG,FRDMAG,
                                   SHENIM1,SHENIM2,SHENIM3,SHENIM4,KTH,NRRENDOR,
                                   GRUP=@GrupMgFt, DST=@DSTFt,KODPACIENT,KODDOCTEGZAM,KODDOCTREFER,
                                   USI,USM   
                              FROM FJ
                             WHERE NrRendor = @NrRendor

                            EXCEPT

                            SELECT KMAG, NRMAG, NRDOK, DATEDOK,NRFRAKS,
                                   SHENIM1,SHENIM2,SHENIM3,SHENIM4,KTH,NRRENDORFAT,
                                   GRUP,DST,KODPACIENT,KODDOCTEGZAM,KODDOCTREFER,
                                   USI,USM   
                              FROM FD 
                             WHERE NrRendor = @NrRendorMg)) 

                 OR

                 ( EXISTS ( SELECT KMAG, NRMAG, NRDOK, DATEDOK,NRFRAKS,
                                   SHENIM1,SHENIM2,SHENIM3,SHENIM4,KTH,NRRENDORFAT,
                                   GRUP,DST,KODPACIENT,KODDOCTEGZAM,KODDOCTREFER,
                                   USI,USM   
                              FROM FD 
                             WHERE NrRendor = @NrRendorMg

                            EXCEPT

                            SELECT KMAG, NRMAG, NRDMAG, DTDMAG,FRDMAG,
                                   SHENIM1,SHENIM2,SHENIM3,SHENIM4,KTH,NRRENDOR,
                                   GRUP=@GrupMgFt,DST=@DSTFt,KODPACIENT,KODDOCTEGZAM,KODDOCTREFER,
                                   USI,USM 
                              FROM FJ 
                             WHERE NrRendor = @NrRendor))

                  SET @ChangeDoc = 1;

         -- Reshta FJSCR - FDSCR

              IF ( EXISTS ( SELECT KODAF, SASI, 
                                   SASIKONV   = ISNULL(SASIKONV,0),
                                   DTSKADENCE = ISNULL(DTSKADENCE,0), SERI      = ISNULL(SERI,''),      RIMBURSIM   = ISNULL(RIMBURSIM,0),
                                   PROMOC     = ISNULL(PROMOC,0),     PROMOCTIP = ISNULL(PROMOCTIP,''), PROMOCKOD   = ISNULL(PROMOCKOD,''), 
                                   TIPFR      = ISNULL(TIPFR,''),     SASIFR    = ISNULL(SASIFR,0),     VLERAFR     = ISNULL(VLERAFR,0),
                                   ISAMB      = ISNULL(ISAMB,0),      NRSERIAL  = ISNULL(NRSERIAL,''),  PROMPTPROD1 = ISNULL(PROMPTPROD1,''),
                                   NrRow      = (SELECT COUNT(*) FROM FJSCR WHERE NrD=@NrRendor AND TIPKLL='K')
                              FROM FJSCR 
                             WHERE NrD = @NrRendor AND TIPKLL='K'

                            EXCEPT

                            SELECT KODAF, SASI, 
                                   SASIKONV   = ISNULL(SASIKONV,0),
                                   DTSKADENCE = ISNULL(DTSKADENCE,0), SERI      = ISNULL(SERI,''),      RIMBURSIM   = ISNULL(RIMBURSIM,0),  
                                   PROMOC     = ISNULL(PROMOC,0),     PROMOCTIP = ISNULL(PROMOCTIP,''), PROMOCKOD   = ISNULL(PROMOCKOD,''), 
                                   TIPFR      = ISNULL(TIPFR,''),     SASIFR    = ISNULL(SASIFR,0),     VLERAFR     = ISNULL(VLERAFR,0),
                                   ISAMB      = ISNULL(ISAMB,0),      NRSERIAL  = ISNULL(NRSERIAL,''),  PROMPTPROD1 = ISNULL(PROMPTPROD1,''),
                                   NrRow      = (SELECT COUNT(*) FROM FDSCR WHERE NrD=@NrRendorMg) 
                              FROM FDSCR 
                             WHERE NrD = @NrRendorMg AND ISNULL(GJENROWAUT,0)=0)) 

                 OR

                 ( EXISTS ( SELECT KODAF, SASI,
                                   SASIKONV   = ISNULL(SASIKONV,0),
                                   DTSKADENCE = ISNULL(DTSKADENCE,0), SERI      = ISNULL(SERI,''),      RIMBURSIM   = ISNULL(RIMBURSIM,0),  
                                   PROMOC     = ISNULL(PROMOC,0),     PROMOCTIP = ISNULL(PROMOCTIP,''), PROMOCKOD   = ISNULL(PROMOCKOD,''), 
                                   TIPFR      = ISNULL(TIPFR,''),     SASIFR    = ISNULL(SASIFR,0),     VLERAFR     = ISNULL(VLERAFR,0),
                                   ISAMB      = ISNULL(ISAMB,0),      NRSERIAL  = ISNULL(NRSERIAL,''),  PROMPTPROD1 = ISNULL(PROMPTPROD1,''),
                                   NrRow      = (SELECT COUNT(*) FROM FDSCR WHERE NrD=@NrRendorMg) 
                              FROM FDSCR 
                             WHERE NrD = @NrRendorMg AND ISNULL(GJENROWAUT,0)=0

                            EXCEPT

                            SELECT KODAF, SASI,
                                   SASIKONV   = ISNULL(SASIKONV,0), 
                                   DTSKADENCE = ISNULL(DTSKADENCE,0), SERI      = ISNULL(SERI,''),      RIMBURSIM   = ISNULL(RIMBURSIM,0),
                                   PROMOC     = ISNULL(PROMOC,0),     PROMOCTIP = ISNULL(PROMOCTIP,''), PROMOCKOD   = ISNULL(PROMOCKOD,''),  
                                   TIPFR      = ISNULL(TIPFR,''),     SASIFR    = ISNULL(SASIFR,0),     VLERAFR     = ISNULL(VLERAFR,0),
                                   ISAMB      = ISNULL(ISAMB,0),      NRSERIAL  = ISNULL(NRSERIAL,''),  PROMPTPROD1 = ISNULL(PROMPTPROD1,''),
                                   NrRow      = (SELECT COUNT(*) FROM FJSCR WHERE NrD=@NrRendor AND TIPKLL='K') 
                              FROM FJSCR 
                             WHERE NrD = @NrRendor AND TIPKLL='K'))

                  SET @ChangeScr = 1;
     
             END;


--------------

          IF @TableName='FF' AND (@TableMg='' Or @TableMg='FH')
             BEGIN    

               SELECT @NrRendorMg = ISNULL(NRRENDDMG,0),
                      @Kurs1      = KURS1,
                      @Kurs2      = KURS2,
                      @GrupMgFt   = (SELECT CASE WHEN CHARINDEX(LEFT(LTRIM(RTRIM(ISNULL(GRUP,'A'))),1),'ABCDEFGHIJ')>0 
                                                 THEN           LEFT(LTRIM(RTRIM(ISNULL(GRUP,'A'))),1) 
                                                 ELSE 'A' END 
                                       FROM MAGAZINA B
                                      WHERE B.KOD=A.KMAG),

                      @DSTFt      = CASE WHEN A.LLOJDOK = 'K'  THEN 'KM'
                                         WHEN A.LLOJDOK = 'D'  THEN 'DM'
                                         WHEN A.LLOJDOK = 'T'  THEN 'ST'
                                      -- WHEN A.LLOJDOK = 'FR' THEN 'FR'   -- Firo
                                         ELSE                       'BL'
                                    END
                 FROM FF A
                WHERE NRRENDOR=@NrRendor;

                  SET @NrRendorMg=ISNULL(@NrRendorMg,0);


         -- Dokumenti FF - FH

              IF ( EXISTS ( SELECT KMAG, NRMAG, NRDMAG, DTDMAG,FRDMAG,          -- Patjeter Kursi .....
                                   SHENIM1,SHENIM2,SHENIM3,SHENIM4,KTH,NRRENDOR,
                                   GRUP=@GrupMgFt, DST=@DSTFt,
                                   USI,USM   
                              FROM FF
                             WHERE NrRendor = @NrRendor

                            EXCEPT

                            SELECT KMAG, NRMAG, NRDOK, DATEDOK,NRFRAKS,
                                   SHENIM1,SHENIM2,SHENIM3,SHENIM4,KTH,NRRENDORFAT,
                                   GRUP,DST,
                                   USI,USM   
                              FROM FH 
                             WHERE NrRendor = @NrRendorMg)) 

                 OR

                 ( EXISTS ( SELECT KMAG, NRMAG, NRDOK, DATEDOK,NRFRAKS,
                                   SHENIM1,SHENIM2,SHENIM3,SHENIM4,KTH,NRRENDORFAT,
                                   GRUP,DST,
                                   USI,USM   
                              FROM FH 
                             WHERE NrRendor = @NrRendorMg

                            EXCEPT

                            SELECT KMAG, NRMAG, NRDMAG, DTDMAG,FRDMAG,
                                   SHENIM1,SHENIM2,SHENIM3,SHENIM4,KTH,NRRENDOR,
                                   GRUP=@GrupMgFt,DST=@DSTFt,
                                   USI,USM 
                              FROM FF 
                             WHERE NrRendor = @NrRendor))

                  SET @ChangeDoc = 1;



         -- Reshta FFSCR - FHSCR

              IF ( EXISTS ( SELECT KODAF, SASI, 
                                   ROUND((CMIMBS   * @Kurs2)/@Kurs1,3), 
                                   ROUND((VLPATVSH * @Kurs2)/@Kurs1,3),
                                -- SASIKONV   = ISNULL(SASIKONV,0),
                                   DTSKADENCE = ISNULL(DTSKADENCE,0), SERI      = ISNULL(SERI,''),      RIMBURSIM   = ISNULL(RIMBURSIM,0),
                                   PROMOC     = ISNULL(PROMOC,0),     PROMOCTIP = ISNULL(PROMOCTIP,''), PROMOCKOD   = ISNULL(PROMOCKOD,''),  
                                   TIPFR      = ISNULL(TIPFR,''),     SASIFR    = ISNULL(SASIFR,0),     VLERAFR     = ISNULL(VLERAFR,0),
                                   ISAMB      = ISNULL(ISAMB,0),      NRSERIAL  = ISNULL(NRSERIAL,''),  PROMPTPROD1 = ISNULL(PROMPTPROD1,''),
                                   NrRow      = (SELECT COUNT(*) FROM FFSCR WHERE NrD=@NrRendor AND TIPKLL='K')
                              FROM FFSCR
                             WHERE NrD = @NrRendor AND TIPKLL='K'

                            EXCEPT

                            SELECT KODAF, SASI, CMIMOR, VLERAOR, 
                                -- SASIKONV   = ISNULL(SASIKONV,0),
                                   DTSKADENCE = ISNULL(DTSKADENCE,0), SERI      = ISNULL(SERI,''),      RIMBURSIM   = ISNULL(RIMBURSIM,0),
                                   PROMOC     = ISNULL(PROMOC,0),     PROMOCTIP = ISNULL(PROMOCTIP,''), PROMOCKOD   = ISNULL(PROMOCKOD,''),  
                                   TIPFR      = ISNULL(TIPFR,''),     SASIFR    = ISNULL(SASIFR,0),     VLERAFR     = ISNULL(VLERAFR,0),
                                   ISAMB      = ISNULL(ISAMB,0),      NRSERIAL  = ISNULL(NRSERIAL,''),  PROMPTPROD1 = ISNULL(PROMPTPROD1,''),
                                   NrRow      = (SELECT COUNT(*) FROM FHSCR WHERE NrD=@NrRendorMg)
                              FROM FHSCR 
                             WHERE NrD = @NrRendorMg  AND ISNULL(GJENROWAUT,0)=0)) 

                 OR

                 ( EXISTS ( SELECT KODAF, SASI, CMIMOR, VLERAOR,
                                -- SASIKONV   = ISNULL(SASIKONV,0), 
                                   DTSKADENCE = ISNULL(DTSKADENCE,0), SERI      = ISNULL(SERI,''),      RIMBURSIM   = ISNULL(RIMBURSIM,0),
                                   PROMOC     = ISNULL(PROMOC,0),     PROMOCTIP = ISNULL(PROMOCTIP,''), PROMOCKOD   = ISNULL(PROMOCKOD,''),  
                                   TIPFR      = ISNULL(TIPFR,''),     SASIFR    = ISNULL(SASIFR,0),     VLERAFR     = ISNULL(VLERAFR,0),
                                   ISAMB      = ISNULL(ISAMB,0),      NRSERIAL  = ISNULL(NRSERIAL,''),  PROMPTPROD1 = ISNULL(PROMPTPROD1,''),
                                   NrRow      = (SELECT COUNT(*) FROM FHSCR WHERE NrD=@NrRendorMg) 
                              FROM FHSCR 
                             WHERE NrD = @NrRendorMg AND ISNULL(GJENROWAUT,0)=0

                            EXCEPT

                            SELECT KODAF, SASI, 
                                   ROUND((CMIMBS   * @Kurs2)/@Kurs1,3), 
                                   ROUND((VLPATVSH * @Kurs2)/@Kurs1,3),
                                -- SASIKONV   = ISNULL(SASIKONV,0),
                                   DTSKADENCE = ISNULL(DTSKADENCE,0), SERI      = ISNULL(SERI,''),      RIMBURSIM   = ISNULL(RIMBURSIM,0),
                                   PROMOC     = ISNULL(PROMOC,0),     PROMOCTIP = ISNULL(PROMOCTIP,''), PROMOCKOD   = ISNULL(PROMOCKOD,''),  
                                   TIPFR      = ISNULL(TIPFR,''),     SASIFR    = ISNULL(SASIFR,0),     VLERAFR     = ISNULL(VLERAFR,0),
                                   ISAMB      = ISNULL(ISAMB,0),      NRSERIAL  = ISNULL(NRSERIAL,''),  PROMPTPROD1 = ISNULL(PROMPTPROD1,''),
                                   NrRow      = (SELECT COUNT(*) FROM FFSCR WHERE NrD=@NrRendor AND TIPKLL='K') 
                              FROM FFSCR 
                             WHERE NrD = @NrRendor AND TIPKLL='K'))

                  SET @ChangeScr = 1;
     
             END;


--------------

          IF @TableName='FJ' AND @TableMg='FH'
             BEGIN    

               SELECT @KMagAmb = KMAGAMB
                 FROM CONFIGMG;


                  SET @KMagAmb = ISNULL(@KMagAmb,'');


               SELECT @NrRendorMg = ISNULL(NRRENDORAMB,0),
                      @KodFKLAmb  = KODFKL,
                      @DtDokAmb   = DATEDOK,

                      @GrupMgFt   = (SELECT CASE WHEN CharIndex(Left(LTrim(RTrim(ISNULL(GRUP,'A'))),1),'ABCDEFGHIJ')>0 
                                                 THEN           Left(LTrim(RTrim(ISNULL(GRUP,'A'))),1) 
                                                 ELSE 'A' END 
                                       FROM MAGAZINA B
                                      WHERE B.KOD=@KMagAmb),

                      @DSTFt      = CASE WHEN A.LLOJDOK = 'K' THEN 'KM'
                                         WHEN A.LLOJDOK = 'D' THEN 'DM'
                                         WHEN A.LLOJDOK = 'T' THEN 'ST'
                                         ELSE                      'SH'
                                    END
                 FROM FJ A
                WHERE NRRENDOR=@NrRendor;

                  SET @NrRendorMg=ISNULL(@NrRendorMg,0);


         -- Dokumenti FJ - FH

              IF ( EXISTS ( SELECT KMAG  = @KMagAmb, 
                                   NRMAG = @NrMagAmb,  --NRDMAG, DTDMAG,FRDMAG,
                                   SHENIM1,SHENIM2,SHENIM3,SHENIM4,KTH,NRRENDOR,
                                   GRUP=@GrupMgFt, DST=@DSTFt,
                                   USI,USM   
                              FROM FJ
                             WHERE NrRendor = @NrRendor

                            EXCEPT

                            SELECT KMAG,          
                                   NRMAG,              --NRDOK, DATEDOK,NRFRAKS,
                                   SHENIM1,SHENIM2,SHENIM3,SHENIM4,KTH,NRRENDORFATAMB,
                                   GRUP,DST,
                                   USI,USM   
                              FROM FH 
                             WHERE NrRendor = @NrRendorMg)) 

                 OR

                 ( EXISTS ( SELECT KMAG,          
                                   NRMAG,             --NRDOK, DATEDOK,NRFRAKS,
                                   SHENIM1,SHENIM2,SHENIM3,SHENIM4,KTH,NRRENDORFATAMB,
                                   GRUP,DST,
                                   USI,USM   
                              FROM FH 
                             WHERE NrRendor = @NrRendorMg

                            EXCEPT

                            SELECT KMAG  = @KMagAmb, 
                                   NRMAG = @NrMagAmb, --NRDMAG, DTDMAG,FRDMAG,
                                   SHENIM1,SHENIM2,SHENIM3,SHENIM4,KTH,NRRENDOR,
                                   GRUP=@GrupMgFt,DST=@DSTFt,
                                   USI,USM 
                              FROM FJ 
                             WHERE NrRendor = @NrRendor))

                  SET @ChangeDoc = 1;



         -- Reshta FJSCR - FHSCR

              IF ( EXISTS ( SELECT KODAF, SASI, KODFKL = @KodFKLAmb, DATEDOK = @DtDokAmb, 
                                   ISAMB       = ISNULL(ISAMB,0),      NRSERIAL = ISNULL(NRSERIAL,''),
                                   SASIKONV    = ISNULL(SASIKONV,0),
                                   DTSKADENCE  = ISNULL(DTSKADENCE,0), SERI     = ISNULL(SERI,''), RIMBURSIM = ISNULL(RIMBURSIM,0),
                                   PROMPTPROD1 = ISNULL(PROMPTPROD1,''),
                                   NrRow       = (SELECT COUNT(*) FROM FJSCR WHERE NrD=@NrRendor AND TIPKLL='K' AND ISNULL(ISAMB,0)=1)
                              FROM FJSCR 
                             WHERE NrD = @NrRendor AND TIPKLL='K' AND ISNULL(ISAMB,0)=1

                            EXCEPT

                            SELECT KODAF, SASI, KODKLF, DTDOK,   
                                   ISAMB       = ISNULL(ISAMB,0),      NRSERIAL = ISNULL(NRSERIAL,''),
                                   SASIKONV    = ISNULL(SASIKONV,0),
                                   DTSKADENCE  = ISNULL(DTSKADENCE,0), SERI     = ISNULL(SERI,''), RIMBURSIM = ISNULL(RIMBURSIM,0),
                                   PROMPTPROD1 = ISNULL(PROMPTPROD1,''),
                                   NrRow       = (SELECT COUNT(*) FROM FDSCR WHERE NrD=@NrRendorMg) 
                              FROM FHSCR 
                             WHERE NrD = @NrRendorMg)) --AND ISNULL(GJENROWAUT,0)=0))

                 OR

                 ( EXISTS ( SELECT KODAF, SASI, KODKLF, DTDOK,   
                                   ISAMB       = ISNULL(ISAMB,0),      NRSERIAL = ISNULL(NRSERIAL,''),
                                   SASIKONV    = ISNULL(SASIKONV,0),
                                   DTSKADENCE  = ISNULL(DTSKADENCE,0), SERI     = ISNULL(SERI,''), RIMBURSIM = ISNULL(RIMBURSIM,0),
                                   PROMPTPROD1 = ISNULL(PROMPTPROD1,''),
                                   NrRow       = (SELECT COUNT(*) FROM FDSCR WHERE NrD=@NrRendorMg) 
                              FROM FHSCR 
                             WHERE NrD = @NrRendorMg AND ISNULL(GJENROWAUT,0)=0

                            EXCEPT

                            SELECT KODAF, SASI, KODFKL = @KodFKLAmb, DATEDOK = @DtDokAmb, 
                                   ISAMB       = ISNULL(ISAMB,0),      NRSERIAL = ISNULL(NRSERIAL,''),
                                   SASIKONV    = ISNULL(SASIKONV,0),
                                   DTSKADENCE  = ISNULL(DTSKADENCE,0), SERI     = ISNULL(SERI,''), RIMBURSIM = ISNULL(RIMBURSIM,0),
                                   PROMPTPROD1 = ISNULL(PROMPTPROD1,''),
                                   NrRow       = (SELECT COUNT(*) FROM FJSCR WHERE NrD=@NrRendor AND TIPKLL='K' AND ISNULL(ISAMB,0)=1) 
                              FROM FJSCR 
                             WHERE NrD = @NrRendor AND TIPKLL='K' AND ISNULL(ISAMB,0)=1))

                  SET @ChangeScr = 1;
     
             END;

--------------


         SET @PChangeDoc = @ChangeDoc;
         SET @PChangeScr = @ChangeScr;


GO
