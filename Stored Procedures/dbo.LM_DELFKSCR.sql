SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[LM_DELFKSCR]
(
@PNRD AS INT
)
AS

DELETE FROM FKSCR
WHERE NRD=@PNRD


GO
