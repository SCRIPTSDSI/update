SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--Exec [Isd_SistemimMG] @PUser='ADMIN', @PNrRendor=1

CREATE Procedure [dbo].[Isd_SistemimMG]
 (
    @PUser         Varchar(20),
    @PNrRendor     Int
  )
As


     DECLARE @NewID        Int, 
             @NrDok        Int,
             @NrFraks      Int,
             @DateDok      Varchar(25),
             @Vlera        Float,
             @KMag         Varchar(20),
             @QKosto       Varchar(100),
             @OkSist       Bit,
             @ListFields   Varchar(Max);


          IF NOT EXISTS ( SELECT NRRENDOR
                            FROM ARTIKUJSIST 
                           WHERE NRD=@PNrRendor AND (SASINEW-SASIOLD<>0 OR ABS(VLERANEW-VLERAOLD)>=0.01 OR CMIMNEW<>CMIMOLD) 
                         )
             BEGIN
               RETURN
             END;



      SELECT @KMag     = KMAG, 
             @NrDok    = NRDOK,
             @NrFraks  = IsNull(NRFRAKS,0),
             @DateDok  = Convert(Varchar(30),GetDate(),103),
             @QKosto   = IsNull(QKOSTO,''),
             @Vlera    = (SELECT SUM(ISNULL(VLERADIF,0)) 
                            FROM ARTIKUJSIST B 
                           WHERE B.NRD=@PNrRendor) 
        FROM ARTIKUJSISTM A
       WHERE NRRENDOR = @PNrRendor


      SELECT * INTO #FHSCR FROM FHSCR WHERE 1>2;

      INSERT INTO FH 
            (TIP,KMAG,NRMAG, NRDOK,NRFRAKS,DATEDOK,SHENIM1,SHENIM2,SHENIM3,SHENIM4,KODLM,GRUP,
             DST,KMAGLNK,NRDOKLNK,NRFRAKSLNK,KMAGRF,NRSERIAL,NRRENDORFAT,
             NRDFK,DOK_JB,USI,USM,TAGNR)
      SELECT 'H',A.KMAG,B.NRRENDOR,A.NRDOK,A.NRFRAKS,A.DATEDOK,A.SHENIM1,
             'Periudhe '+REPLACE(LEFT(CONVERT(Varchar(30),A.DATEDOK,103),5)+' - '+
                                      CONVERT(Varchar(30),A.DATEDOK,103),'/','.'),
             '','',@QKosto,B.GRUP,
             'SI','',0,0,'','',0,0,0,'','',0 
        FROM ARTIKUJSISTM A LEFT JOIN MAGAZINA B ON A.KMAG=B.KOD
       WHERE A.NRRENDOR = @PNrRendor

      SELECT @NewID=@@IDENTITY


      UPDATE FH
         SET FIRSTDOK = 'H'+CAST(@NewID As Varchar)
       WHERE NRRENDOR = @NewID


      INSERT INTO #FHSCR
            (NRD,KOD,KARTLLG,KODAF,PERSHKRIM,NJESI,BC,
             SASI,CMIMM,VLERAM,NRRENDKLLG,TIPKLL,TAGNR)
      SELECT @NEWID,
             KMAG+'.'+KOD+'.'+'..',
             KOD,
             KOD,
             PERSHKRIM,NJESI,BC,
             ROUND((SASINEW-SASIOLD),2),
             ROUND(CMIMNEW,3),
             ROUND((VLERANEW-VLERAOLD),3),
             NRRENDKLLG,'K',0 
        FROM ARTIKUJSIST 
       WHERE NRD=@PNrRendor And (SASINEW-SASIOLD<>0 OR ABS(VLERANEW-VLERAOLD)>=0.01 OR CMIMNEW<>CMIMOLD) 

      UPDATE A 
         SET A.NJESINV    = A.NJESI,
             A.KOEFSHB    = 1,
             A.VLERAFT    = 0,
             A.CMIMBS     = A.CMIMM,
             A.VLERABS    = A.VLERAM,
             A.CMIMSH     = B.CMSH,
             A.VLERASH    = ROUND(B.CMSH*SASI,2),
             A.CMIMOR     = A.CMIMM,
             A.VLERAOR    = A.VLERAM,
             A.PROMOC     = 0,
             A.PROMOCTIP  = '', 
             A.TIPFR      = '', 
             A.SASIFR     = 0, 
             A.VLERAFR    = 0,
             A.KONVERTART = 1, 
             A.ORDERSCR   = 0 
        FROM #FHSCR A LEFT JOIN ARTIKUJ B ON A.KOD=B.KOD 

      SELECT @ListFields = dbo.Isd_ListFieldsTable('FHSCR','NRRENDOR')

        EXEC ('  
              INSERT INTO FHSCR ('+@ListFields+') 
              SELECT '+@ListFields+'
                FROM #FHSCR 
            ORDER BY NRD,KODAF; ' );

-- u fut me 11.03.2016

        EXEC dbo.Isd_DocSaveMG 'FH',@NewID,@PUser,'','S','';


-- Ndryshime me 11.03.2016

--  Declare @OkIdLog Bit
-- --Select @OkIdLog = IsNull(dbo.Isd_FieldTableExists('DITARVEPRIME', 'LgJob'),0)
--   Select @OkIdLog = dbo.Isd_ParamExists('Isd_AppendLg','@PLgJob')
--
--  if @OkIdLog=0
--     Exec [Isd_AppendLog] 
--          @PUser         = @PUser,
--          @PNrRendor     = @NewID,
--          @PTip          = 'FH',
--          @PMaster       = @KMag,
--          @PNrdok        = @NrDok,
--          @PNrFraks      = @NrFraks,
--          @PDateDok      = @DateDok,
--          @PVlere        = @Vlera,
--          @POperacion    = 'S',
--          @POperacionDok = 'SI'
--  else
--     Exec [Isd_AppendLog] 
--          @PUser         = @PUser,
--          @PNrRendor     = @NewID,
--          @PTip          = 'FH',
--          @PMaster       = @KMag,
--          @PNrdok        = @NrDok,
--          @PNrFraks      = @NrFraks,
--          @PDateDok      = @DateDok,
--          @PVlere        = @Vlera,
--          @POperacion    = 'S',
--          @POperacionDok = 'SI',
--          @PLgJob        = ''


GO
