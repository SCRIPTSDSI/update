SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE     procedure [dbo].[QARTIKUJ]
(
  @pKod Varchar(50)
 )

As

SELECT A.NRRENDOR, 
       A.KOD, 
       A.PERSHKRIM,
       A.TIP, 
       A.NJESI,      A.NJESB,  A.KOEFB,  A.NJESSH, A.KOEFSH, 
       
       A.KOSTMES,    A.CMB, 
       
       A.CMSH,       A.CMSH1,  A.CMSH2,  A.CMSH3,  A.CMSH4,  A.CMSH5,  A.CMSH6,  A.CMSH7,  A.CMSH8,  A.CMSH9, 
       A.CMSH10,     A.CMSH11, A.CMSH12, A.CMSH13, A.CMSH14, A.CMSH15, A.CMSH16, A.CMSH17, A.CMSH18, A.CMSH19, 
       
       BC          = CASE WHEN ISNULL(CONFIGMG.MULTIBC,0)=0
                          THEN A.BC
                          ELSE ( SELECT TOP 1 BC 
                                   FROM ARTIKUJBCSCR C 
                                  WHERE A.NRRENDOR=C.NRD AND ISNULL(C.BC,'')<>'' )
                     END,
                    
--     BC          = A.BC,
--     BC          = CASE WHEN EXISTS ( SELECT BC 
--                                        FROM ARTIKUJBCSCR C 
--                                       WHERE A.NRRENDOR=C.NRD AND ISNULL(C.BC,'')<>'' )
--                        THEN ( SELECT TOP 1 BC 
--                                 FROM ARTIKUJBCSCR C 
--                                WHERE A.NRRENDOR=C.NRD AND ISNULL(C.BC,'')<>'' )
--                        ELSE A.BC 
--                   END,

       A.PESHANET,   A.PESHABRT, A.STATUSSPEC, A.NRSERIAL, A.GARANCI,
       KONVERTART  = ISNULL(A.KONV1,1) * ISNULL(A.KONV2,1),

       A.TATIM,  
       A.KODTVSH,
       PERQTVSH    = B.PERQINDJE,
       APLKMS      = A.APLKMS,    
       PERQKMS     = A.PERQKMS,
       A.VLTAX,
       A.CMSHMIN,
       A.CMSHMAX,    A.CMSHLIMIT,  A.CMSHLIMITBLC, A.CMBLMIN, A.CMBLMAX, A.CMBLLIMIT, A.CMBLLIMITBLC,

       A.ISAMB,

       A.NOTACTIV,   A.NOTACTIVSH, A.NOTACTIVBL

  FROM ARTIKUJ A LEFT JOIN KLASATATIM B ON A.KODTVSH=B.KOD, CONFIGMG
                 
 WHERE A.KOD=@pKod






GO
