SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Declare @PSasi  Float
-- EXEC Isd_GetSasiExtra 'P100',@PSasi out

CREATE procedure [dbo].[Isd_GetSasiExtra]
(
 @PKod      VarChar(50),
 @PSasi     Float out 
)

As

  Set    @PSasi = 0;
  Select SASI   = @PSasi;

















GO
