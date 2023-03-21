SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE   VIEW [dbo].[Isd_FkOrigjineDok] 

AS

      SELECT KOD = CASE WHEN KOD='O'  THEN 'G' 
                        WHEN KOD='AQ' THEN 'X' 
                        ELSE KOD 
                   END,           
             PERSHKRIM, 0 AS NRRENDOR,0 AS TROW      
        FROM CONFIG..TIPDOK      
       WHERE ISNULL(TIPDOK,'')=KOD AND CHARINDEX(','+KOD+',',',A,B,H,D,F,S,T,O,E,AQ,')>0   
--  ORDER BY CHARINDEX(','+KOD+',',',A,B,H,D,F,S,T,O,E,AQ,');
    
GO
