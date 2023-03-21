SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[HASACTIVEBOUNDLE](@KODKLILOYAL AS VARCHAR(50),@VLERTOT AS FLOAT,@MAGAZINA AS VARCHAR(30),@BCPRODUCT AS VARCHAR(30))
                                        AS

                                        SELECT       COUNT(1)			 
                                        FROM OFERTEMARKETING OM
                                        INNER JOIN OFERTEMARKETINGBOUNDLE OMB ON OMB.NRD = OM.NRRENDOR
                                        INNER JOIN ARTIKUJ A ON A.KOD = OMB.KOD
                                        WHERE DNGA		<=GETDATE()			AND DDERI		>= GETDATE()
                                          AND VLNGA		<=@VLERTOT			AND VLDERI		>= @VLERTOT
                                          AND ((KLILOYNGA <=@KODKLILOYAL		AND KLILOYDERI  >= @KODKLILOYAL) OR PERKLILOYAL=0)
                                          AND MAGAZINAT LIKE '%' + @MAGAZINA + '%'
                                          AND  @BCPRODUCT = A.NRRENDOR 
GO
