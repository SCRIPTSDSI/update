SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Isd_GatiFiskalWTN]
(
 @pNrRendor Integer
)
AS

BEGIN


         SET NOCOUNT ON;

	 DECLARE @TempOutput   Varchar(MAX);

	 DECLARE @Output1      Varchar(MAX);
	 DECLARE @Output2      Varchar(MAX);
	 DECLARE @Output3      Varchar(MAX);
	 DECLARE @OutMessage   Varchar(MAX);
	 DECLARE @TipPagese    Varchar(MAX);
	 DECLARE @TipKlient    Varchar(MAX);
	 DECLARE @Fiskalizuar bit;
	     SET @TempOutput = '';
		 SET @Output1    = '0';
		 SET @Output2    = '0';

		

set @Fiskalizuar=(SELECT TOP 1 ISNULL(FISKALIZUAR,0) FROM FD WHERE NRRENDOR=@pNrRendor)

-- Zhvillim
IF @Fiskalizuar=0
EXEC Isd_FiscalWTN @pNrRendor,@Output1 OUTPUT
ELSE
	
	--SET @Output1='WTN e fiskalizuar'
	PRINT @Output1

	if  (ISNULL(@Output1,'0')='0' and ISNULL(@Output2,'0')='0')
	set @OUTMESSAGE=''
	ELSE
	set @OUTMESSAGE = 'Gabim gjate procesit te deklarimit tatime....'+char(10)+ char(13) + @Output1


	


	  SELECT @Output1 AS KodError1, @Output2 AS KodError2, @OutMessage AS MsgError;
	
-- Etc ....

END



GO
