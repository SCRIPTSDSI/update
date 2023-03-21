SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE                      VIEW [dbo].[LEVIZJEFA] 

AS
      SELECT TOP 100 PERCENT 
             TIP         = 'H', 
             A.NRRENDOR,
             KMAG, 
             KARTLLG, 
             PERSHKRIM,
             SASIH       = SASI, 
             SASID       = 0,
             NJESI,
             DATECREATE,
             B.FADESTIN,
             B.FAKLS,
             B.FASTATUS,
             B.FADATE,
             NRRENDORSCR = B.NRRENDOR,
             A.TROW
        FROM FH A LEFT JOIN FHSCR B ON A.NRRENDOR = B.NRD

   UNION ALL

      SELECT TOP 100 PERCENT 
             TIP         = 'H', 
             A.NRRENDOR,
             KMAG, 
             KARTLLG, 
             PERSHKRIM,
             SASIH       = SASI, 
             SASID       = 0,
             NJESI,
             DATECREATE,
             B.FADESTIN,
             B.FAKLS,
             B.FASTATUS,
             B.FADATE, 
             NRRENDORSCR = B.NRRENDOR,
             A.TROW
        FROM FD A LEFT JOIN FDSCR B ON A.NRRENDOR = B.NRD

    ORDER BY KMAG,KARTLLG,DATEDOK,DATECREATE
GO
