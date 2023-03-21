SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[__eInvoiceGetRequestFF]
 	@Eic			  NVARCHAR(100)	=	 '',
	@PartyType		  VARCHAR(10)	=	 'BUYER', -- SELLER, BUYER
	@RecDateTimeFrom  DATETIME		=	 '',
	@RecDateTimeTo    DATETIME		=	 '',
	@Nrrendor		  INT ,
	@OUTPUT1		  VARCHAR(MAX) OUTPUT
AS 
BEGIN	
	SET NOCOUNT ON;

BEGIN TRY
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




		SELECT   @NIPT	= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCVATREGISTRATIONNO')
		    
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
			NEWID()				     AS 'Header/@UUID',							--Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
	(
		SELECT CASE WHEN @Eic = '' THEN NULL
					ELSE @Eic
					END	AS 'EIC'
			   , @PartyType						AS 'PartyType'		--Duhet shtuar ne magazina/fature
			   , CASE WHEN @Eic = '' THEN dbo.DATE_1601(@RecDateTimeFrom)
									 ELSE NULL 
									 END AS 'RecDateTimeFrom'	
			   , CASE WHEN @Eic = '' THEN dbo.DATE_1601(@RecDateTimeTo)
									 ELSE NULL 
									 END AS 'RecDateTimeTo'
		FOR XML PATH(''), TYPE
	)
	FOR XML PATH('GetEinvoicesRequest'));

	SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<GetEinvoicesRequest>','<GetEinvoicesRequest xmlns="https://Einvoice.tatime.gov.al/EinvoiceService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="1">') AS XML)

	SET @XMLSTRING = CAST(@xml AS VARCHAR(MAX));
	
	
	EXEC _FiscalSignRequest @XmlString, @CertificatePath, @CertificatePwd, @Certificate, @SignedXml OUTPUT;

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
	BEGIN
		--RASTI KUR PO KERKON
		IF(@Eic = '')
		BEGIN
			EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="https://Einvoice.tatime.gov.al/EinvoiceService/schema" />';

			SELECT *
			FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:GetEinvoicesResponse/ns2:Einvoices/ns2:Einvoice')
			WITH
			(
				[DocNumber]		NVARCHAR(50)	'@DocNumber',
				[Amount]		FLOAT			'@Amount',
				[DocType]		NVARCHAR(50)	'@DocType',
				[DueDateTime]	NVARCHAR(50)	'@DueDateTime',
				[EIC]		    NVARCHAR(50)	'@EIC',
				[PartyType]		NVARCHAR(50)	'@PartyType',
				[RecDateTime]	NVARCHAR(50)	'@RecDateTime',
				[Status]		NVARCHAR(50)	'@Status'
			);
/*
			SELECT * INTO #TTT
			FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:GetEinvoicesResponse/ns2:Einvoices/ns2:Einvoice')
			WITH
			(
				[DocNumber]		NVARCHAR(50)	'@DocNumber',
				[Amount]		FLOAT			'@Amount',
				[DocType]		NVARCHAR(50)	'@DocType',
				[DueDateTime]	NVARCHAR(50)	'@DueDateTime',
				[EIC]		    NVARCHAR(50)	'@EIC',
				[PartyType]		NVARCHAR(50)	'@PartyType',
				[RecDateTime]	NVARCHAR(50)	'@RecDateTime',
				[Status]		NVARCHAR(50)	'@Status'
			);
			*/
			
			EXEC sp_xml_removedocument @hDoc;
		END		
		ELSE 
		BEGIN
			EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="https://Einvoice.tatime.gov.al/EinvoiceService/schema" />';
			
			DECLARE @pdf NVARCHAR(MAX);
			DECLARE @status NVARCHAR(MAX);

			SELECT @pdf = Pdf
			FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:GetEinvoicesResponse/ns2:Einvoices/ns2:Einvoice')
			WITH
			(
				Pdf NVARCHAR(MAX) 'ns2:Pdf'
			);


			SELECT @status = Status
			FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:GetEinvoicesResponse/ns2:Einvoices/ns2:Einvoice')
			WITH
			(
				[Status]		NVARCHAR(50)	'@Status'
				
			);
			
			UPDATE FisStatusFF SET FISPDF = @pdf
			WHERE NRRENDOR = @Nrrendor;

			--SELECT LEN(@pdf), @pdf;

		--	select @status
		SET @OUTPUT1=@ErrorText

		END
	END
--	ELSE 
	SELECT @responseXml;
END TRY
BEGIN CATCH
	SET @OUTPUT1 = ERROR_MESSAGE()
END CATCH
END
GO
