SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[CHECKOFFERBOUNDLELIST](@KODKLILOYAL AS VARCHAR(50),@VLERTOT AS FLOAT,@MAGAZINA AS VARCHAR(30),@BCPRODUCT AS VARCHAR(max))
                                        AS


                                        DECLARE @KODPROD AS VARCHAR(30);

                                        SELECT      DISTINCT OM.NRRENDOR		 
                                        FROM OFERTEMARKETING OM
                                        INNER JOIN OFERTEMARKETINGBOUNDLE OMB ON OMB.NRD = OM.NRRENDOR
                                        WHERE DNGA		<=GETDATE()			AND DDERI		>= GETDATE()
                                          AND VLNGA		<=@VLERTOT			AND VLDERI		>= @VLERTOT
                                          AND ((KLILOYNGA <=@KODKLILOYAL		AND KLILOYDERI  >= @KODKLILOYAL) OR PERKLILOYAL=0)
                                          AND MAGAZINAT LIKE '%' + @MAGAZINA + '%'
                                          AND  @BCPRODUCT like '%' + OMB.KOD + '%'
                                          and ISNULL(om.SHORTE,0) = 0
                                        ORDER BY OM.NRRENDOR
                                    
GO
