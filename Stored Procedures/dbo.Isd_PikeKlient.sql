SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Declare @PikeKlient float
-- EXEC Isd_PikeKlient '00000111',@PikeKlient out

CREATE procedure [dbo].[Isd_PikeKlient]
(
 @KlientID VarChar(50),
 @Pike     Float out 
)
AS

Select @Pike=0

















GO
