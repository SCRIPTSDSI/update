SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Isd_GatiFiskaleInvoice]
(
 @pNrRendor Integer
)

AS

BEGIN
	SET NOCOUNT ON;
    


	DECLARE @EIC VARCHAR(MAX)
	DECLARE @DATEDOK DATETIME
	DECLARE @OUTPUT1 VARCHAR(MAX)

	SET @EIC=(SELECT FISEIC FROM FJ WHERE NRRENDOR=@pNrRendor)
	SET @DATEDOK=(SELECT DATEDOK FROM FJ WHERE NRRENDOR=@pNrRendor)
	EXEC __eInvoiceGetRequest @EIC,'SELLER',@DATEDOK,@DATEDOK,@pNrRendor,@OUTPUT1 OUTPUT
	

	
END
GO
