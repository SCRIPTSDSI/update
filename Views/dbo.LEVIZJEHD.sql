SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO







CREATE                      VIEW [dbo].[LEVIZJEHD] 

AS
 
      SELECT TOP 100 PERCENT 
             A.NRRENDOR,
             KMAG, 
             NRMAG,
             NRDOK, 
             NRFRAKS, 
             DATEDOK, 
             DOK_JB,
             DST,
             KTH,
             TIPDOK      = 'FH',
             SHENIM1,
             SHENIM2,
             SHENIM3,
             SHENIM4,
             KODLM       = ISNULL(KODLM,''),
             NRRENDORFAT, 
             KMAGRF,
             KMAGLNK, 
             NRDOKLNK, 
             NRFRAKSLNK, 
             DATEDOKLNK,
             KOD, 
             KODAF, 
             KARTLLG, 
             PERSHKRIM,
             TIP         = 'H',
             CMIMM,
             CMIMSH,
             SASIH       = SASI,
             VLERAH      = VLERAM,
             VLERASHH    = VLERASH,
             SASID       = 0,
             VLERAD      = 0,
             VLERASHD    = 0,
			 VLERAOR,
			 VLERAFT,
             NJESI,
             SASIHKOEF   = ISNULL(KONVERTART,0),
             SASIDKOEF   = 0,
             SASIHKONV   = ISNULL(SASIKONV,0),
             SASIDKONV   = 0,
             BARCOD      = BC,
             B.DTSKADENCE,
             B.SERI,
             B.ISAMB,
             B.KODKLF,
             A.KODPACIENT,
             A.KODDOCTEGZAM,
             A.KODDOCTREFER,
             B.GJENROWRVL,
             NRD,
             NRRENDORSCR = B.NRRENDOR,
             GJENROWAUT  = ISNULL(GJENROWAUT,0),
             TIPFR,SASIFR,VLERAFR,TIPKTH,KONVERTART,KOMENT,PROMOC=ISNULL(PROMOC,0)
        FROM FH A LEFT JOIN FHSCR B ON A.NRRENDOR = B.NRD

   UNION ALL

      SELECT TOP 100 PERCENT 
             A.NRRENDOR,
             KMAG, 
             NRMAG,
             NRDOK, 
             NRFRAKS, 
             DATEDOK, 
             DOK_JB,
             DST,
             KTH,
             TIPDOK      = 'FD',
             SHENIM1,
             SHENIM2,
             SHENIM3,
             SHENIM4,
             KODLM       = ISNULL(KODLM,''),
             NRRENDORFAT,
             KMAGRF,
             KMAGLNK, 
             NRDOKLNK, 
             NRFRAKSLNK, 
             DATEDOKLNK,       
             KOD, 
             KODAF, 
             KARTLLG, 
             PERSHKRIM,
             TIP         = 'D',
             B.CMIMM,
             B.CMIMSH,
             SASIH       = 0,
             VLERAH      = 0,
             VLERASHH    = 0,
             SASID       = SASI,
             VLERAD      = VLERAM,
             VLERASHD    = VLERASH,
			 VLERAOR,
			 VLERAFT,
             NJESI,
             SASIHKOEF   = 0,
             SASIDKOEF   = ISNULL(KONVERTART,0),
             SASIHKONV   = 0,
             SASIDKONV   = ISNULL(SASIKONV,0),
             BARCOD      = BC,
             B.DTSKADENCE,
             B.SERI,
             B.ISAMB,
             B.KODKLF,
             A.KODPACIENT,
             A.KODDOCTEGZAM,
             A.KODDOCTREFER,
             B.GJENROWRVL,
             NRD,
             NRRENDORSCR = B.NRRENDOR,
             GJENROWAUT  = ISNULL(GJENROWAUT,0),
             TIPFR,SASIFR,VLERAFR,TIPKTH,KONVERTART,KOMENT,PROMOC=ISNULL(PROMOC,0)
        FROM FD A LEFT JOIN FDSCR B ON A.NRRENDOR = B.NRD

    --ORDER BY KMAG,DATEDOK,NRDOK





GO
