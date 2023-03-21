SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[_FiscalCreateCashXmlPos]
	 @Operation VARCHAR(50) -- BALANCE, CREDIT, DEPOSIT
   , @CashAmount FLOAT
   , @TCRNumber VARCHAR(50)
   --, @Xml XML OUTPUT 
AS 
--HARD CODED VALUES
DECLARE     @VatRegistrationNo	VARCHAR(50)
			,@BusinessUnit		VARCHAR(50)
			,@SoftNum			VARCHAR(50)
			,@ManufacNum		VARCHAR(50)
			,@FIC				VARCHAR(1000)
			,@SIGNEDXML			VARCHAR(MAX)
			,@ERROR				VARCHAR(1000)
			,@ERRORtext			VARCHAR(1000)
			,@schema			VARCHAR(MAX)
			,@Url				VARCHAR(MAX)
			,@CertificatePath   VARCHAR(MAX)
			,@certificatepassword VARCHAR(MAX)
			,@XMLSTRING           VARCHAR(MAX)
			,@QRCODELINK        VARCHAR(MAX)
			,@xml				XML;

SELECT       @VatRegistrationNo = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCVATREGISTRATIONNO')
		    ,@BusinessUnit      = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCBUSINESSUNIT')
		    ,@SoftNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCSOFTNUM')
		    ,@ManufacNum        = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCMANUFACNUM')
			,@schema			= (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCSCHEMA')
		    ,@Url				= (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCURL')
		    ,@CertificatePath           = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'CERTPATH')
		    ,@certificatepassword        = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'CERTPASS')		

SET @XML  = (
SELECT 
		dbo.DATE_1601(GETDATE()) AS 'Header/@SendDateTime',
		--'false'					 AS 'Header/@SubseqDelivType',
		NEWID()				     AS 'Header/@UUID',					--Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
(
	SELECT dbo.DATE_1601(GETDATE())					AS '@ChangeDateTime'
		   , @VatRegistrationNo						AS '@IssuerNUIS'		--Duhet shtuar ne magazina/fature
		   , @Operation								AS '@Operation'	
		   , CONVERT(DECIMAL(18, 2), @CashAmount)	AS '@CashAmt'
		   , @TCRNumber								AS '@TCRCode'
	FOR XML PATH('CashDeposit'), TYPE
)
FOR XML PATH('RegisterCashDepositRequest'));

SET @XML = CAST( REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterCashDepositRequest>','<RegisterCashDepositRequest xmlns="https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3"> ') AS XML);

SET @XMLSTRING = CAST(@xml AS VARCHAR(MAX));
	declare @fisccert as varbinary(max)
	

	select top 1 @fisccert = fisccertificate from CONFND

	
	DECLARE @responseXML AS XML




EXEC _FiscalProcessRequest 
		@XMLSTRING,								
		@certificatePath		= @certificatePath,														
		@certificatepassword	= @certificatepassword,	
		@certbinary				= @fisccert,
		@url					= @url,
		@schema					= @schema,
		@returnValue			= '',
		@USESYSTEMPROXY		='',					--> VLERA QE KERKON TE MARRESH NGA DERGIMI I KERKESES
		@SIGNEDXML				= @SIGNEDXML OUTPUT,			--> XML E PERGATITUR BASHKE ME SHENJIMIN 
		@FIC					= @FIC OUTPUT,					--> FIC PER VLEREN E FATURES, NR I SHENJIMIT
		@ERROR					= @ERROR OUTPUT,				--> 0 -> SKA GABIM 1-> KA GABIM
		@ERRORtext				= @ERRORtext OUTPUT,				--> MESAZHI I GABIMIT
		@responseXML			= @responseXML	OUTPUT	

		--if @ERROR='0'
		--begin
		--	update kase set FISCTCRNUM= @FIC where kod=@id
		--end

	IF @ERROR = '30'
	SET @ERRORtext = 'Mungon lidhja me serverin e tatimeve.'

IF @ERROR = '0' or @ERROR = '50'
begin
	UPDATE U SET  U.DKLCASH = 1
	FROM DRH..USERS U 
	INNER JOIN KASE K
	ON K.KOD=U.DRN WHERE K.FISCTCRNUM = @TCRNumber
end
ELSE 
begin
   UPDATE U SET U.DKLCASH = 0 
   FROM DRH..USERS U 
   INNER JOIN KASE K 
   ON K.KOD=U.DRN 
   WHERE K.FISCTCRNUM = @TCRNumber
   SET @ERROR = '50'
end





INSERT INTO LOGARKA(TCRCODE,TIPI,VLERA,ERROR,ERRORTEXT,[XML],ERRORMESSAGE) VALUES (@TCRNumber,@Operation,@CashAmount,@ERROR,@ERRORtext,@xml,@FIC)

SELECT  @FIC AS returnValue, @ERROR AS error, @ERRORtext AS errortext,@xml as xmlstring, @SIGNEDXML AS singedxml;
GO
