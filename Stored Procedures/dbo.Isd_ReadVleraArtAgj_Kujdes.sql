SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- Declare @pVlArtAgj float
-- EXEC Isd_ReadVleraArtAgj '100',1.191,1000,1200,@pVlArtAgj Out
                                 
CREATE procedure [dbo].[Isd_ReadVleraArtAgj_Kujdes]
(
   @pKodAgj      VarChar(50),
-- @pKodArt      VarChar(50), -- ?
   @pKoeficent   Float,
   @pVlPaTvsh    Float,
   @pVlMeTvsh    Float,
   @pVlArtAgj    Float Out
)
AS

Select @pVlArtAgj = Round(@pKoeficent*@pVlPaTvsh,2)



















GO
