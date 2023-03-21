SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   VIEW [dbo].[DGTVSH_IMP]

-- Si procedura DGTVSH_I por per Librin e Ri per 2015
AS

      SELECT *,
             E_TOTAL          = EE_PERJASHTUAR + F_INVESTIM + L_VNDMALLMETVSH + LL_VNDMALLMETVSH + 
                                M_VNDINVMETVSH + N_VNDINVMETVSH + NJ_FERMER + O_FERMER + 
                                P_AUTONGARK + Q_AUTONGARK + R_REGULLIM + RR_REGULLIM +
                                S_BORXHKEQ + SH_BORXHKEQ +

                                G_IMPINVPATVSH  + GJ_IMPMALLPATVSH + 
                                H_IMPMALLMETVSH + I_IMPMALLMETVSH  +
                                J_IMPINVMETVSH  + K_IMPINVMETVSH
        FROM

    (

      SELECT A.NRRENDOR, 
             TIPIE            = MAX(A.TIPFT),
             NRFATIE          = MAX(A.NRRENDORFAT), 
             DATEDOKIE        = MAX(A.DATEDOK), 
             NRDOKIE          = MAX(A.NRDOK), 
             SHENIMIE         = MAX(A.SHENIM1), 
             SHENIM2IE        = MAX(A.SHENIM2), 
             PERSHKRIMIE      = MAX(C.PERSHKRIM), 
             TIPTVSHIE        = MAX(C.TIP), 
          -- VLTATUSHTVSH = SUM(CASE WHEN C.TIP=1 THEN B.VLERATAT ELSE 0 END), 
          -- VLTAXTVSH    = SUM(CASE WHEN C.TIP=1 THEN B.VLERATAX ELSE 0 END), 
          -- VLTATUESHEM  = SUM(B.VLERATAT), 
          -- VLTAX        = SUM(B.VLERATAX),
          -- PERQTVSH     = ISNULL(CASE WHEN SUM(CASE WHEN C.TIP=1 THEN B.VLERATAT ELSE 0 END)=0 
          --                            THEN 0
          --                            ELSE CASE WHEN (100*(SUM(CASE WHEN C.TIP=1 THEN B.VLERATAX ELSE 0 END)/
          --                                                 SUM(CASE WHEN C.TIP=1 THEN B.VLERATAT ELSE 0 END))<=5) THEN 0
          --                                      WHEN (100*(SUM(CASE WHEN C.TIP=1 THEN B.VLERATAX ELSE 0 END)/
          --                                                 SUM(CASE WHEN C.TIP=1 THEN B.VLERATAT ELSE 0 END))>5) AND
          --                                           (100*(SUM(CASE WHEN C.TIP=1 THEN B.VLERATAX ELSE 0 END)/
          --                                                 SUM(CASE WHEN C.TIP=1 THEN B.VLERATAT ELSE 0 END))<=15)THEN 10
          --                                      ELSE 20 END 
          --                            END,0), 

          -- E_TOTAL          = 0,
             EE_PERJASHTUAR   = 0,
             F_INVESTIM       = 0,

             L_VNDMALLMETVSH  = 0,
             LL_VNDMALLMETVSH = 0,
             M_VNDINVMETVSH   = 0,
             N_VNDINVMETVSH   = 0,
             NJ_FERMER        = 0,
             O_FERMER         = 0,
             P_AUTONGARK      = 0,
             Q_AUTONGARK      = 0,
             R_REGULLIM       = 0,
             RR_REGULLIM      = 0,
             S_BORXHKEQ       = 0,
             SH_BORXHKEQ      = 0,

             G_IMPINVPATVSH   = SUM(CASE WHEN C.TIP=1 AND 
                                              ISNULL(B.APLINVESTIM,0)=1 AND
                                              ISNULL(B.VLERATAX,0)=0
                                         THEN ISNULL(B.VLERATAT,0) 
                                         ELSE 0 
                                         END), 
             GJ_IMPMALLPATVSH = SUM(CASE WHEN C.TIP=1 AND 
                                              ISNULL(B.APLINVESTIM,0)=0 AND
                                              ISNULL(B.VLERATAX,0)=0
                                         THEN ISNULL(B.VLERATAT,0) 
                                         ELSE 0 
                                         END), 

             H_IMPMALLMETVSH  = SUM(CASE WHEN C.TIP=1 AND 
                                              ISNULL(B.APLINVESTIM,0)=0 AND
                                              ISNULL(B.VLERATAX,0)<>0
                                         THEN ISNULL(B.VLERATAT,0) 
                                         ELSE 0 
                                         END), 
             J_IMPINVMETVSH   = SUM(CASE WHEN C.TIP=1 AND 
                                              ISNULL(B.APLINVESTIM,0)=1 AND
                                              ISNULL(B.VLERATAX,0)<>0
                                         THEN ISNULL(B.VLERATAT,0) 
                                         ELSE 0 
                                         END), 
         -- 
             I_IMPMALLMETVSH  = SUM(CASE WHEN C.TIP=1 AND 
                                              ISNULL(B.APLINVESTIM,0)=0 AND
                                              ISNULL(B.VLERATAX,0)<>0
                                         THEN ISNULL(B.VLERATAX,0) 
                                         ELSE 0 
                                         END), 
             K_IMPINVMETVSH   = SUM(CASE WHEN C.TIP=1 AND 
                                              ISNULL(B.APLINVESTIM,0)=1 AND
                                              ISNULL(B.VLERATAX,0)<>0
                                         THEN ISNULL(B.VLERATAX,0) 
                                         ELSE 0 
                                         END), 
             NRDFK            = MAX(ISNULL(A.NRDFK,0)),              
             KODIE            = '0', 
             NIPTIE           = MIN(A.NIPT),
             KLASIFIKIM       = MAX(A.KLASIFIKIM)

        FROM DG A LEFT JOIN DGSCR B ON A.NRRENDOR = B.NRD 
                  LEFT JOIN TATIM C ON B.TATIM = C.KOD

       WHERE ((A.TIPFT='F') AND (C.TIP=1))

    GROUP BY A.NRRENDOR   --,C.KOD

     ) A


GO
