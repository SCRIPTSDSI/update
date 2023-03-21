SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



 
CREATE     VIEW [dbo].[Isd_AQDisplayKartele]   


AS   

          -- SELECT * FROM dbo.Isd_AQDisplayKartele WHERE KOD='X01000003' ORDER BY TIPROW,DATEOPER
          -- Perdoret tek AQ dhe AQHistori, mund te unifikohet me ate tek AQKartela (afishim ditar ne grid)



      SELECT KOD      = A.KARTLLG,A.PERSHKRIM,A.KODOPER,VEPRIMI=dbo.Isd_AQOperDetailDisplay(KODOPER),A.DATEOPER,
             DOKUMENT = CASE WHEN A.TIPROW=1 THEN 'Histori' ELSE 'Ditar' END,
             VLERA    = A.VLERABS,
             A.VLERAAM,A.NORMEAM,
             A.VLERAFAT,A.VLERAFATMV,A.VLERAEXTMV,
             A.KOMENT,
             A.NRDOK,A.DATEDOK,A.KODPRONESI,A.KODLOCATION,A.KODFKL,A.TIPROW,
             TROW     = CAST(0 AS INT),
             TAGNR    = 0
        FROM LevizjeAQAll A --INNER JOIN AQKARTELA B ON A.KARTLLG=B.KOD
   -- ORDER BY TIPROW,DATEOPER

         


GO
