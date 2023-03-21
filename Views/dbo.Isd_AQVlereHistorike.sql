SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE   VIEW [dbo].[Isd_AQVlereHistorike] 

AS
 


      SELECT TOP 100 PERCENT *
        FROM 
        
      (
             SELECT 
                    KOD            = A.KOD,
                    PERSHKIM       = A.PERSHKRIM,
                    VLERAHISTORIKE = CASE WHEN A.KODOPER='BL' THEN A.VLERABS     
                                          WHEN A.KODOPER='CE' THEN A.VLERAFATMV
                                     END,
                    KODOPER,   
                    DATEOPER,
                    KURS           = CASE WHEN ISNULL(KMON,'')='' OR KURS2*KURS1<=0 THEN 1 
                                          ELSE                                      ROUND(KURS2/KURS1,3) 
                                     END,           
                    KMON,KURS1, KURS2,
                    NRORD          = ROW_NUMBER() OVER(PARTITION BY KOD ORDER BY KOD,KODOPER,DATEOPER)                

               FROM LevizjeAQALL A
              WHERE KODOPER IN ('BL','CE')  
              
              ) A

       WHERE NRORD=1

    ORDER BY A.KOD, A.KODOPER  


 -- ORDER BY KMON,DKODRF





GO
