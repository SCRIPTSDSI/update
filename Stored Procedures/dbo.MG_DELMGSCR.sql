SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE  procedure [dbo].[MG_DELMGSCR]
(
@PTABLENAME VARCHAR(10),
@PNRD INT
)
AS
DECLARE @STR AS VARCHAR(500)

SET @STR='DELETE FROM ' +  @PTABLENAME + ' WHERE NRD=' + CONVERT(VARCHAR,@PNRD)

EXECUTE(@STR)




GO
