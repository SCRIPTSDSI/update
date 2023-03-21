SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[Isd_FloatRound]
(
 @pVlera    As Float,
 @pDecimal  As Int
 ) 
 
RETURNS FLOAT

-- Qellimi eshte per vlerat e vogla qe zhduken dhe behen zero ....     @pDecimal te perdoret me vone
-- U perdor ne rastet e shkarkimit te lendeve te para ose produkteve per koeficiente te vegjel

BEGIN
  

     DECLARE @Result   Float;
     
     
          IF @pVlera = 0
             RETURN 0;
             
  
         SET @Result = CASE WHEN ABS(@pVlera)>=1                   THEN ROUND(@pVlera,4,0)
                            WHEN ABS(@pVlera)>=0.0001              THEN ROUND(@pVlera,4,1)
                            WHEN ABS(@pVlera)>=0.00001             THEN ROUND(@pVlera,5,1)
                            WHEN ABS(@pVlera)>=0.000001            THEN ROUND(@pVlera,6,1)
                            WHEN ABS(@pVlera)>=0.0000001           THEN ROUND(@pVlera,7,1)
                            WHEN ABS(@pVlera)>=0.00000001          THEN ROUND(@pVlera,8,1)
                            WHEN ABS(@pVlera)>=0.000000001         THEN ROUND(@pVlera,9,1)
                            ELSE 0.000000001  
                       END;     
      RETURN @Result;

END


GO
