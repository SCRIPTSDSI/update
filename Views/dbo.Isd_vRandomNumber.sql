SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE   VIEW [dbo].[Isd_vRandomNumber] 

AS
SELECT RandomNumber = (SELECT RAND( (DATEPART(mm, GETDATE()) * 100000 ) + 
                                       (DATEPART(ss, GETDATE()) * 1000 )   + 
                                        DATEPART(ms, GETDATE()) ))
GO
