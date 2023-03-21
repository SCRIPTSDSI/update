SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[GETPRICECMSHZB0](@KOD AS VARCHAR(100)
                            )
                            AS
                            BEGIN


                            DECLARE @CMIM AS FLOAT;
							set @CMIM = (select top 1 cmsh from artikuj where kod = @KOD)
							select @CMIM
							
                            end



							--select * from artikuj

							--update artikuj set PERSHKRIM = left(pershkrim,100)
GO
