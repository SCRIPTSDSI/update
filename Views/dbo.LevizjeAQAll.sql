SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE                      VIEW [dbo].[LevizjeAQAll] 

AS
 
      SELECT TOP 100 PERCENT 
             NRDOK       = 0, 
             NRFRAKS     = 0, 
             DATEDOK     = CASE WHEN ISNULL(DATEDOK,0)=0 THEN DATEOPER ELSE DATEDOK END, 
             DST         = 'HI',
             TIPDOK      = 'AQ',
             A.SHENIM1,
             A.SHENIM2,
             SHENIM3     = '',
             SHENIM4     = '',
             KODLM       = '',
             DOK_JB      = 0,
             TIPFAT      = '',
             
             KOD         = A.KARTLLG, 
             KODAF       = A.KARTLLG, 
             A.KARTLLG, 
             BARCOD      = A.BC,
             B.PERSHKRIM,
             A.KODOPER,
             A.DATEOPER,
             
             A.CMIMBS,
             A.VLERABS,
             A.VLERAAM,
             A.NORMEAM,
             A.SASI,
             A.NJESI,
             A.VLERAFAT,
             A.VLERAFATMV,
             A.VLERAEXTMV,
             A.KMON,
             KURS1       = CASE WHEN ISNULL(A.KURS1,0)<=0 THEN 1 ELSE A.KURS1 END,
             KURS2       = CASE WHEN ISNULL(A.KURS2,0)<=0 THEN 1 ELSE A.KURS2 END,
             
             A.KOMENT,
             A.KODPRONESI,
             A.PERSHKRIMPRONESI,
             A.KODLOCATION,
             A.PERSHKRIMLOCATION,
             A.KODFKL,
             A.PERSHKRIMFKL,
             TIP         = 'X',
             TIPROW      = '1',  -- Te dhena historike
             NRRENDORFAT = 0,
             NRRENDOR    = A.NRD,
             A.NRD,
             NRRENDORSCR = A.NRRENDOR
        FROM AQHistoriSCr A LEFT JOIN AQKARTELA B ON A.NRD=B.NRRENDOR
       WHERE ISNULL(A.KARTLLG,'')<>''
       
   UNION ALL

      SELECT TOP 100 PERCENT 
             A.NRDOK, 
             A.NRFRAKS, 
             A.DATEDOK, 
             A.DST,
             TIPDOK      = 'AQ',
             A.SHENIM1,
             A.SHENIM2,
             A.SHENIM3,
             A.SHENIM4,
             KODLM       = ISNULL(KODLM,''),
             A.DOK_JB,
             A.TIPFAT,
             
             B.KOD, 
             B.KODAF, 
             B.KARTLLG, 
             BARCOD      = B.BC,
             B.PERSHKRIM,
             B.KODOPER,
             DATEOPE     = CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END,
             
             B.CMIMBS,
             B.VLERABS,
             B.VLERAAM,
             B.NORMEAM,
             B.SASI,
             B.NJESI,
             B.VLERAFAT,
             B.VLERAFATMV,
             B.VLERAEXTMV,
             B.KMON,
             KURS1       = CASE WHEN ISNULL(B.KURS1,0)<=0 THEN 1 ELSE B.KURS1 END,
             KURS2       = CASE WHEN ISNULL(B.KURS2,0)<=0 THEN 1 ELSE B.KURS2 END,
             
             KOMENT,
             B.KODPRONESI,
             B.PERSHKRIMPRONESI,
             B.KODLOCATION,
             B.PERSHKRIMLOCATION,
             B.KODFKL,
             B.PERSHKRIMFKL,
             TIP         = 'X',
             TIPROW      = '2',   -- Ditar AQ
             A.NRRENDORFAT,
             A.NRRENDOR,
             B.NRD,
             NRRENDORSCR = B.NRRENDOR
        FROM AQ A LEFT JOIN AQSCR B ON A.NRRENDOR = B.NRD
       WHERE ISNULL(B.KARTLLG,'')<>''
       
    -- ORDER BY KARTLLG,TIPROW DESC,DATEDOK,NRDOK










GO
