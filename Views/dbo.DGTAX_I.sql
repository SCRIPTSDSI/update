SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE   VIEW [dbo].[DGTAX_I]



AS

-- per efekt te Liber Tvsh se vjeter, para 2014

   SELECT A.NRRENDOR, 
          TIPIE        = MIN(A.TIPFT), 
          NRFATIE      = MIN(A.NRRENDORFAT), 
          DATEDOKIE    = MIN(A.DATEDOK),
          NRDOKIE      = MIN(A.NRDOK), 
          SHENIMIE     = MIN(A.SHENIM1), 
          NIPTIE       = CASE WHEN MIN(A.TIPFT)='F' THEN MIN(A.NIPT) ELSE '' END, 
          SHENIM2IE    = MIN(A.SHENIM2),
          PERSHKRIMIE  = MIN(C.PERSHKRIM), 
          TIPTVSHIE    = MIN(C.TIP),
          VLTATUSHTVSH = 0,
          VLTAXTVSH    = 0,
          VLTATUESHEM  = 0, 
          VLTAX        = SUM(CASE C.TIP WHEN 2 THEN B.VLERATAX ELSE 0 END), 
          KODIE        = '0',
          KLASIFIKIM   = MAX(A.KLASIFIKIM)

     FROM DG A LEFT JOIN DGSCR B ON A.NRRENDOR = B.NRD
               LEFT JOIN TATIM C ON B.TATIM = C.KOD

    WHERE ((A.TIPFT='F') AND (C.TIP=2))

 GROUP BY A.NRRENDOR

   HAVING SUM(CASE C.TIP WHEN 2 THEN B.VLERATAX ELSE 0 END)<>0




GO
