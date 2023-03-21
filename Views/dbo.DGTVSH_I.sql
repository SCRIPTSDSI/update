SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   VIEW [dbo].[DGTVSH_I]



AS



   SELECT A.NRRENDOR, 
          TIPIE        = MAX(A.TIPFT),
          NRFATIE      = MAX(A.NRRENDORFAT), 
          DATEDOKIE    = MAX(A.DATEDOK), 
          NRDOKIE      = MAX(A.NRDOK),
          KOD          = MAX(A.KOD),
          SHENIMIE     = MAX(A.SHENIM1), 
          SHENIM2IE    = MAX(A.SHENIM2), 
          PERSHKRIMIE  = MAX(C.PERSHKRIM), 
          TIPTVSHIE    = MAX(C.TIP), 
          VLTATUSHTVSH = SUM(CASE WHEN C.TIP=1 THEN B.VLERATAT ELSE 0 END), 
          VLTAXTVSH    = SUM(CASE WHEN C.TIP=1 THEN B.VLERATAX ELSE 0 END), 
          VLTATUESHEM  = SUM(B.VLERATAT), 
          VLTAX        = SUM(B.VLERATAX),
          PERQTVSH     = ISNULL(CASE WHEN SUM(CASE WHEN C.TIP=1 THEN B.VLERATAT ELSE 0 END)=0 
                                     THEN 0
                                     ELSE CASE WHEN (100*(SUM(CASE WHEN C.TIP=1 THEN B.VLERATAX ELSE 0 END)/
                                                          SUM(CASE WHEN C.TIP=1 THEN B.VLERATAT ELSE 0 END))<=5) THEN 0
                                               WHEN (100*(SUM(CASE WHEN C.TIP=1 THEN B.VLERATAX ELSE 0 END)/
                                                          SUM(CASE WHEN C.TIP=1 THEN B.VLERATAT ELSE 0 END))>5) AND
                                                    (100*(SUM(CASE WHEN C.TIP=1 THEN B.VLERATAX ELSE 0 END)/
                                                          SUM(CASE WHEN C.TIP=1 THEN B.VLERATAT ELSE 0 END))<=15)THEN 10
                                               ELSE 20 END 
                                     END,0), 
          NRDFK        = MAX(ISNULL(A.NRDFK,0)),              
          KODIE        = '0', 
          NIPTIE       = MIN(A.NIPT),
          KLASIFIKIM   = MAX(A.KLASIFIKIM)

     FROM DG A LEFT JOIN DGSCR B ON A.NRRENDOR = B.NRD 
               LEFT JOIN TATIM C ON B.TATIM = C.KOD

    WHERE ((A.TIPFT='F') AND (C.TIP=1))

 GROUP BY A.NRRENDOR,C.KOD

GO
