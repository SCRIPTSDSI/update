SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Isd_GatiFiskalFFPdf]
(
 @pNrRendor Integer
)
AS
BEGIN
	SET NOCOUNT ON;
    


	DECLARE @EIC VARCHAR(MAX)
	DECLARE @OUTPUT1 VARCHAR(MAX)
	DECLARE @DATEDOK DATETIME

	SET @EIC=(SELECT FISEIC FROM FisStatusFF WHERE NRRENDOR=@pNrRendor)
	SET @DATEDOK=(SELECT ISNULL(DATEDOK,DATECREATE) FROM FisStatusFF WHERE NRRENDOR=@pNrRendor)
	EXEC __eInvoiceGetRequestFF @EIC,'BUYER',@DATEDOK,@DATEDOK,@pNrRendor,@OUTPUT1 OUT

	
END
GO