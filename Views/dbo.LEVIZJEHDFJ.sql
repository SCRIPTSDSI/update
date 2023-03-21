SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE                     VIEW [dbo].[LEVIZJEHDFJ] 

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
             A.KMAG, 
             A.NRMAG,
             A.NRDOK, 
             A.NRFRAKS, 
             A.DATEDOK, 
             A.DOK_JB,
             A.DST,
             A.KTH,
             TIPDOK      = 'FD',
             A.SHENIM1,
             A.SHENIM2,
             A.SHENIM3,
             A.SHENIM4,
             KODLM       = ISNULL(A.KODLM,''),
             A.NRRENDORFAT,
             A.KMAGRF,
             A.KMAGLNK, 
             A.NRDOKLNK, 
             A.NRFRAKSLNK, 
             A.DATEDOKLNK,       
             B.KOD, 
             B.KODAF, 
             B.KARTLLG, 
             B.PERSHKRIM,
             TIP         = 'D',
             B.CMIMM,
             B.CMIMBS,
             SASIH       = 0,
             VLERAH      = 0,
             VLERASHH    = 0,
             SASID       = SASI,
             VLERAD      = CASE WHEN ISNULL(D.KURS2,0)*ISNULL(D.KURS1,0)>0 THEN (B.VLERABS*D.KURS2)/D.KURS1 ELSE B.VLERABS END,
             VLERASHD    = CASE WHEN ISNULL(D.KURS2,0)*ISNULL(D.KURS1,0)>0 THEN (B.VLERABS*D.KURS2)/D.KURS1 ELSE B.VLERABS END,
			 VLERAOR     = CASE WHEN ISNULL(D.KURS2,0)*ISNULL(D.KURS1,0)>0 THEN (B.VLERABS*D.KURS2)/D.KURS1 ELSE B.VLERABS END,
			 VLERAFT     = CASE WHEN ISNULL(D.KURS2,0)*ISNULL(D.KURS1,0)>0 THEN (B.VLERABS*D.KURS2)/D.KURS1 ELSE B.VLERABS END,
             B.NJESI,
             SASIHKOEF   = 0,
             SASIDKOEF   = ISNULL(B.KONVERTART,0),
             SASIHKONV   = 0,
             SASIDKONV   = ISNULL(B.SASIKONV,0),
             BARCOD      = B.BC,
             B.DTSKADENCE,
             B.SERI,
             B.ISAMB,
             B.KODKLF,
             A.KODPACIENT,
             A.KODDOCTEGZAM,
             A.KODDOCTREFER,
             GJENROWRVL  = 0,
             B.NRD,
             NRRENDORSCR = B.NRRENDOR,
             GJENROWAUT  = 0,
             B.TIPFR,B.SASIFR,B.VLERAFR,B.TIPKTH,B.KONVERTART,B.KOMENT,PROMOC=ISNULL(B.PROMOC,0)
        FROM FD A INNER JOIN FJ    D ON A.DOK_JB=1 AND A.NRRENDOR=D.NRRENDDMG
		          LEFT  JOIN FJSCR B ON D.NRRENDOR=B.NRD
       WHERE B.TIPKLL='K'
   
    --ORDER BY KMAG,DATEDOK,NRDOK


	

GO
