SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- Declare @Koeficent float
-- EXEC Isd_ReadKoeficentArtAgj '100','A01',@Koeficent out
                                 
CREATE procedure [dbo].[Isd_ReadKoeficentArtAgj]
(
 @KodAgj    VarChar(50),
 @KodArt    VarChar(50), 
 @Koeficent Float out 
)
AS

Select @Koeficent = 0


















GO
