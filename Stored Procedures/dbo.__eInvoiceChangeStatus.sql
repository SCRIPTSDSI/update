SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--  DECLARE @OkChange Int; EXEC dbo.__eInvoiceChangeStatus '700d6683-cb2c-4179-ad29-669f0a8fedeb', 'ACCEPTED',@OkChange Output; Print @OkChange;


CREATE PROC [dbo].[__eInvoiceChangeStatus]
 	@Eic		NVARCHAR(MAX)	=	 '',
	@Status		NVARCHAR(100)	=	 '', -- REFUSED, ACCEPTED
	@OkChange   Int             = 0 Output
AS 
BEGIN	
	SET NOCOUNT ON;

	DECLARE  @NIPT				VARCHAR(20)
			,@PerqZbr			FLOAT
			,@Date				VARCHAR(100)
			,@Nr				VARCHAR(10)
			,@VlerTot			VARCHAR(20)
			
			,@SoftNum			VARCHAR(1000)
			,@CertificatePath	VARCHAR(1000)
			,@CertificatePwd	VARCHAR(1000)
			,@Certificate		VARBINARY(MAX)
			,@IicBlank			VARCHAR(MAX)
			,@Iic				VARCHAR(1000)
			,@Fic				VARCHAR(MAX)
			,@IicSignature		VARCHAR(1000)
			,@Schema			VARCHAR(1000)
			,@FiscUrL			VARCHAR(1000)
			,@UniqueIdentif		UNIQUEIDENTIFIER
			,@XmlString			VARCHAR(MAX)
			,@Xml				XML
			,@responseXml		XML
			,@SignedXml			VARCHAR(MAX)
			,@Error				NVARCHAR(MAX)
			,@ErrorText			NVARCHAR(MAX)
			,@hDoc				INT
			,@EICURL			VARCHAR(MAX);

	SET @UniqueIdentif = NEWID();

	

		
		SELECT   @NIPT	= NIPT
		    
		    ,@SoftNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSOFTNUM')
		   
			,@schema			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSCHEMA')
		    ,@FiscUrL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCURL')
			,@EICURL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'EICURL')
		    ,@CertificatePath   = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPATH')
		    ,@CertificatePwd    = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPASS')		
			,@Certificate		= FiscCertificate
		FROM CONFND


	SET @XML  = (
	SELECT 
			dbo.DATE_1601(GETDATE()) AS 'Header/@SendDateTime',
			NEWID()				     AS 'Header/@UUID',
	(
		SELECT @Eic		AS 'EIC'
		FOR XML PATH('EICs'), TYPE
	),
	@Status AS 'EinStatus'
	FOR XML PATH('EinvoiceChangeStatusRequest'));

	SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<EinvoiceChangeStatusRequest>','<EinvoiceChangeStatusRequest xmlns="https://Einvoice.tatime.gov.al/EinvoiceService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="1">') AS XML)

	SET @XMLSTRING = CAST(@xml AS VARCHAR(MAX));
	
	EXEC _FiscalSignRequest @XmlString, @CertificatePath, @CertificatePwd, @Certificate, @SignedXml OUTPUT;

	--EXEC _FiscalProcessRequest 
	--		@InputString		 = @XmlString,
	--		@CertificatePath	 = @CertificatePath, 
	--		@Certificatepassword = @CertificatePwd,
	--		@CertBinary			 = @Certificate,
	--		@Url				 = 'https://einvoice-test.tatime.gov.al/EinvoiceService-v1/EinvoiceService.wsdl',
	--		@Schema				 = "https://Einvoice.tatime.gov.al/EinvoiceService/schema",
	--		@ReturnValue		 = '',
	--		@SignedXml			 = @SignedXml	OUTPUT, 
	--		@Fic				 = @Fic			OUTPUT, 
	--		@Error				 = @Error		OUTPUT, 
	--		@Errortext			 = @Errortext	OUTPUT,
	--		@responseXML		 = @responseXML OUTPUT;

		EXEC _FiscalProcessRequest 
			@InputString		 = @XmlString,
			@CertificatePath	 = @CertificatePath, 
			@Certificatepassword = @CertificatePwd,
			@CertBinary			 = @Certificate,
			@Url				 = @EICURL,
			@Schema				 = "https://Einvoice.tatime.gov.al/EinvoiceService/schema",
			@ReturnValue		 = '',
			@useSystemProxy		 = '',
			@SignedXml			 = @SignedXml	OUTPUT, 
			@Fic				 = @Fic			OUTPUT, 
			@Error				 = @Error		OUTPUT, 
			@Errortext			 = @Errortext	OUTPUT,
			@responseXML		 = @responseXML OUTPUT;
 
	SET @XML = CAST(@SignedXml  AS XML)
    
	IF(@Error = 0)
	BEGIN		--SUCCESS
		SET @OkChange = 1
	END
	ELSE 
		SET @OkChange = 0;   --@responseXml, @Error

SELECT ChangeStatus=@OkChange
END
GO
