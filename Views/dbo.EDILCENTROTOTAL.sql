SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE                   VIEW [dbo].[EDILCENTROTOTAL] AS 
   SELECT NRRENDOR  = 0,
          NRD,
          PERSHKRIM = 'PESHA NETO.'
     FROM FJSCR
 GROUP BY NRD
   HAVING MAX(ISNULL(FJSCR.FBARS,0))<>0

UNION ALL

     SELECT NRRENDOR  = 1,  
            NRD       = MIN(NRD),
            PERSHKRIM = RIGHT('        '+CAST(SUM(SASI) AS VARCHAR(8)),8)+'  COPE X  '+
                        RIGHT('        '+CAST(ISNULL(FBARS,0) AS VARCHAR(8)),8)+'  =  '+
                        RIGHT('        '+CAST(ISNULL(FBARS,0)*SUM(SASI) AS VARCHAR(8)),8) + '  KG'
       FROM FJSCR
      WHERE ISNULL(FBARS,0)<>0
   GROUP BY NRD,FBARS

  UNION ALL 

     SELECT NRRENDOR  = 2,
            NRD,
            PERSHKRIM = 'TOTALE NETO                 =  '+
                        RIGHT('        '+CAST(SUM(ISNULL(FBARS,0)*SASI) AS VARCHAR),8)+'  KG'
       FROM FJSCR
   GROUP BY NRD
     HAVING MAX(ISNULL(FBARS,0))<>0
GO
