SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE                      VIEW [dbo].[LEVIZJEHDFA] 

AS
      SELECT TOP 100 PERCENT 
             TIP         = 'H',
             FH.NRRENDOR,KMAG, NRMAG,NRDOK, NRFRAKS, DATEDOK, DOK_JB,DST,KTH,
             TIPDOK      = 'FH',
             SHENIM1,SHENIM2,SHENIM3,SHENIM4,KODLM=ISNULL(KODLM,''),NRRENDORFAT, 
             KMAGRF,KMAGLNK, NRDOKLNK, NRFRAKSLNK, DATEDOKLNK,DATECREATE,
             KOD, KODAF, KARTLLG, PERSHKRIM,
             CMIMM,
             SASIH       = SASI,
             VLERAH      = VLERAM,
             VLERASHH    = VLERASH,
             SASID       = 0,
             VLERAD      = 0,
             VLERASHD    = 0,
             NJESI,
             SASIHKOEF   = ISNULL(KONVERTART,0),
             SASIDKOEF   = 0,
             FHSCR.DTSKADENCE,
             FHSCR.SERI,NRD,
             NRRENDORSCR = FHSCR.NRRENDOR,
             GJENROWAUT  = ISNULL(GJENROWAUT,0),
             TIPFR,
             SASIFR,
             TIPKTH,
             KONVERTART,
             FHSCR.FADESTIN,FHSCR.FAKLS,FHSCR.FASTATUS,FHSCR.FADATE,FH.TROW 
        FROM FH LEFT JOIN FHSCR ON FH.NRRENDOR = FHSCR.NRD

   UNION ALL

      SELECT TOP 100 PERCENT 
             TIP         = 'D',
             FD.NRRENDOR,KMAG, NRMAG,NRDOK, NRFRAKS, DATEDOK, DOK_JB,DST,KTH,
             TIPDOK      = 'FD',
             SHENIM1,SHENIM2,SHENIM3,SHENIM4,KODLM=ISNULL(KODLM,''),NRRENDORFAT,
             KMAGRF,KMAGLNK, NRDOKLNK, NRFRAKSLNK, DATEDOKLNK,DATECREATE,       
             KOD, KODAF, KARTLLG, PERSHKRIM,
             FDSCR.CMIMM,
             SASIH       = 0,
             VLERAH      = 0,
             VLERASHH    = 0,
             SASID       = SASI,
             VLERAD      = VLERAM,
             VLERASHD    = VLERASH,NJESI,
             SASIHKOEF   = 0,
             SASIDKOEF   = ISNULL(KONVERTART,0),
             FDSCR.DTSKADENCE,FDSCR.SERI,NRD,
             NRRENDORSCR = FDSCR.NRRENDOR,
             GJENROWAUT  = ISNULL(GJENROWAUT,0),
             TIPFR,
             SASIFR,
             TIPKTH,
             KONVERTART,
             FDSCR.FADESTIN,FDSCR.FAKLS,FDSCR.FASTATUS,FDSCR.FADATE,FD.TROW 
        FROM FD LEFT JOIN FDSCR ON FD.NRRENDOR = FDSCR.NRD

    ORDER BY KMAG,DATEDOK,DATECREATE,NRDOK
GO
