SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO













CREATE               VIEW [dbo].[FDFHLIDHJE02] AS 
   SELECT TOP 100 PERCENT 
          DOKUMENT    = 'FD',
          FD.NRRENDOR,
          KMAG,
          NRDOK,
          NRFRAKS     = ISNULL(NRFRAKS,0),
          DATEDOK,
          KMAGRF      = ISNULL(KMAGRF,''),
          SHENIM1,
          SHENIM2,
          KMAGLNK     = ISNULL(KMAGLNK,''),
          NRDOKLNK    = ISNULL(NRDOKLNK,0),
          NRFRAKSLNK  = ISNULL(NRFRAKSLNK,0),
          DATEDOKLNK  = ISNULL(DATEDOKLNK,DATEDOK),
          KMAGLNK1    = ISNULL(KMAGLNK,''),
          NRDOKLNK1   = ISNULL(NRDOKLNK,0),
          NRFRAKSLNK1 = ISNULL(NRFRAKSLNK,0),
          DATEDOKLNK1 = ISNULL(DATEDOKLNK,DATEDOK),
          KMAGLNK2    = KMAG,
          NRDOKLNK2   = NRDOK,
          NRFRAKSLNK2 = ISNULL(NRFRAKS,''),
          DATEDOKLNK2 = DATEDOK,  
          KARTLLG,
          PERSHKRIM   = FDSCR.PERSHKRIM,
          SASI,
          TIP         = 'D'
     FROM FD INNER JOIN FDSCR ON FD.NRRENDOR=FDSCR.NRD
    WHERE ISNULL(DOK_JB,0)=0 AND (ISNULL(DST,'') IN ('LB','KM','DM','FU'))

UNION ALL

   SELECT TOP 100 PERCENT 
          DOKUMENT    = 'FH',
          FH.NRRENDOR,
          KMAG,
          NRDOK,
          NRFRAKS     = ISNULL(NRFRAKS,0),
          DATEDOK,
          KMAGRF      = ISNULL(KMAGRF,''),
          SHENIM1,
          SHENIM2,
          KMAGLNK     = ISNULL(KMAGLNK,''),
          NRDOKLNK    = ISNULL(NRDOKLNK,0),
          NRFRAKSLNK  = ISNULL(NRFRAKSLNK,0),
          DATEDOKLNK  = ISNULL(DATEDOKLNK,DATEDOK),
          KMAGLNK1    = KMAG,
          NRDOKLNK1   = NRDOK,
          NRFRAKSLNK1 = ISNULL(NRFRAKS,0),
          DATEDOKLNK1 = DATEDOK,
          KMAGLNK2    = ISNULL(KMAGLNK,''),
          NRDOKLNK2   = ISNULL(NRDOKLNK,0),
          NRFRAKSLNK2 = ISNULL(NRFRAKSLNK,0), 
          DATEDOKLNK2 = ISNULL(DATEDOKLNK,DATEDOK),
          KARTLLG,
          PERSHKRIM   = FHSCR.PERSHKRIM,
          SASI,
          TIP         = 'H'
     FROM FH INNER JOIN FHSCR ON FH.NRRENDOR=FHSCR.NRD
    WHERE ISNULL(DOK_JB,0)=0 AND (ISNULL(DST,'') IN ('LB','KM','DM','FU'))

 ORDER BY KMAGLNK, NRDOKLNK, DATEDOKLNK










GO