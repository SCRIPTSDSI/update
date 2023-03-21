SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE                    VIEW [dbo].[LEVIZJEHDPROD] 

AS
 

      SELECT TOP 100 PERCENT 
             A.NRRENDOR,KMAG,NRMAG,NRDOK,NRFRAKS,DATEDOK,DOK_JB,DST,KTH,
             SHENIM1,SHENIM2,SHENIM3,SHENIM4,
             KMAGRF,KMAGLNK,NRDOKLNK,NRFRAKSLNK,DATEDOKLNK,
             KODLM       = ISNULL(KODLM,''),
             TIPDOK      = 'FH',
             TIP         = 'H',
             KODPACIENT,KODDOCTEGZAM,KODDOCTREFER,
             
             KOD,KODAF,KARTLLG,PERSHKRIM,NJESI,BARCOD=B.BC,
             CMIMM,
             CMIMSH,
             SASIH       = SASI,
             VLERAH      = VLERAM,
             VLERASHH    = VLERASH,
             SASID       = 0,
             VLERAD      = 0,
             VLERASHD    = 0,
             SASIHKOEF   = ISNULL(KONVERTART,0),
             SASIDKOEF   = 0,
             B.DTSKADENCE,B.SERI,B.ISAMB,B.KODKLF,B.GJENROWRVL,GJENROWAUT=ISNULL(B.GJENROWAUT,0),
             B.TIPFR,B.SASIFR,B.VLERAFR,TIPKTH,B.KONVERTART,B.KOMENT,PROMOC=ISNULL(B.PROMOC,0),
             A.NRRENDORFAT,B.NRD,NRRENDORSCR=B.NRRENDOR
        FROM FH A LEFT JOIN FHSCR B ON A.NRRENDOR = B.NRD
       WHERE NOT (B.SASI < 0 AND ISNULL(A.DST,'')='PR')

   UNION ALL

      SELECT TOP 100 PERCENT 
             A.NRRENDOR,KMAG,NRMAG,
             NRDOK       = (  SELECT COUNT('')
                                FROM
                                   (SELECT NR=1
                                      FROM FH D INNER JOIN FHSCR E ON D.NRRENDOR=E.NRD
                                                LEFT  JOIN MAGAZINA M ON D.KMAG=M.KOD 
                                     WHERE D.KMAG = A.KMAG                    AND
                                           E.SASI<0 AND ISNULL(D.DST,'')='PR' AND
                                           D.NRDOK>=ISNULL(M.NRPRODUKTKP,0)   AND D.NRDOK<=ISNULL(M.NRPRODUKTKS,0) AND
                                           YEAR(D.DATEDOK)=YEAR(A.DATEDOK)    AND
                                           (D.DATEDOK<A.DATEDOK OR (D.DATEDOK=A.DATEDOK AND D.NRRENDOR<A.NRRENDOR))
                                  GROUP BY D.NRRENDOR ) A ) + 1,

             NRFRAKS,DATEDOK,DOK_JB,DST,KTH,
             SHENIM1     = 'Shkarkim i Hyrjes se prodhimit Nr: '+CAST(NRDOK AS VARCHAR),SHENIM2,SHENIM3,SHENIM4,
             KMAGRF      = KMAG,KMAGLNK=KMAG,NRDOKLNK=NRDOK,NRFRAKSLNK=NRFRAKS,DATEDOKLNK=DATEDOK,
             KODLM       = ISNULL(KODLM,''),
             TIPDOK      = 'FD',
             TIP         = 'D',
             KODPACIENT,KODDOCTEGZAM,KODDOCTREFER,
             
             KOD,KODAF,KARTLLG,PERSHKRIM,NJESI,BARCOD=B.BC,
             CMIMM,
             CMIMSH,
             SASIH       = 0,
             VLERAH      = 0,
             VLERASHH    = 0,
             SASID       = 0-SASI,
             VLERAD      = 0-VLERAM,
             VLERASHD    = 0-VLERASH,
             
             SASIHKOEF   = ISNULL(KONVERTART,0),
             SASIDKOEF   = 0,
             B.DTSKADENCE,B.SERI,B.ISAMB,B.KODKLF,B.GJENROWRVL,GJENROWAUT=0, --ISNULL(GJENROWAUT,0),
             B.TIPFR,B.SASIFR,B.VLERAFR,TIPKTH,B.KONVERTART,B.KOMENT,PROMOC=ISNULL(B.PROMOC,0),
             A.NRRENDORFAT,B.NRD,NRRENDORSCR=B.NRRENDOR
        FROM FH A LEFT JOIN FHSCR B ON A.NRRENDOR = B.NRD
       WHERE B.SASI < 0 AND ISNULL(A.DST,'')='PR'

   UNION ALL

      SELECT TOP 100 PERCENT 
             A.NRRENDOR,KMAG,NRMAG,NRDOK,NRFRAKS,DATEDOK,DOK_JB,DST,KTH,
             SHENIM1,SHENIM2,SHENIM3,SHENIM4,
             KMAGRF,KMAGLNK,NRDOKLNK,NRFRAKSLNK,DATEDOKLNK,       
             KODLM       = ISNULL(KODLM,''),
             TIPDOK      = 'FD',
             TIP         = 'D',
             KODPACIENT,KODDOCTEGZAM,KODDOCTREFER,
             
             KOD,KODAF,KARTLLG,PERSHKRIM,NJESI,BARCOD=B.BC,
             B.CMIMM,
             B.CMIMSH,
             SASIH       = 0,
             VLERAH      = 0,
             VLERASHH    = 0,
             SASID       = SASI,
             VLERAD      = B.VLERAM,
             VLERASHD    = B.VLERASH,
             SASIHKOEF   = 0,
             SASIDKOEF   = ISNULL(KONVERTART,0),
             B.DTSKADENCE,B.SERI,B.ISAMB,B.KODKLF,B.GJENROWRVL,GJENROWAUT=ISNULL(B.GJENROWAUT,0),
             B.TIPFR,B.SASIFR,B.VLERAFR,TIPKTH,B.KONVERTART,KOMENT,PROMOC=ISNULL(B.PROMOC,0),
             A.NRRENDORFAT,B.NRD,NRRENDORSCR=B.NRRENDOR
        FROM FD A LEFT JOIN FDSCR B ON A.NRRENDOR = B.NRD

--  ORDER BY KMAG,DATEDOK,NRDOK



GO
