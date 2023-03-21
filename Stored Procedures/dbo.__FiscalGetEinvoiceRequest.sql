SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[__FiscalGetEinvoiceRequest]
 	@Eic			  NVARCHAR(100)	=	 '',
	@PartyType		  VARCHAR(10)	=	 'SELLER', -- SELLER, BUYER
	@RecDateTimeFrom  DATETIME		=	 '',
	@RecDateTimeTo    DATETIME		=	 ''
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
			,@hDoc				INT;		

	SET @UniqueIdentif = NEWID();

	SELECT TOP 1 @NIPT					= ISNULL(NIPT, '')						-- CONFND:	 NIPT i kompanise
				,@SoftNum				= ISNULL(FiscSoftNum, '')				-- CONFIGMG: SoftNum -- kodi i zgjidhjes software te merret ne nje tabele konfigurimi
				,@Schema				= ISNULL(FiscSchema, '')				-- CONFIGMG: fiscSchema ka te beje me skemen e perdorur per krijimin e xml e cila eshte fikse, por mund te ndryshoje ne vijim
				,@FiscUrL				= ISNULL(FiscUrL, '')					-- CONFIGMG: url per web service
				,@CertificatePath       = ISNULL(FiscCertificatePath, '')		-- CONFIGMG: PATH ne te cilin ndohet certifikata ne server
				,@CertificatePwd	    = ISNULL(FiscCertificatePassword, '')	-- CONFIGMG: Fjalekalim per hapjen e certifikates
				,@Certificate			= FiscCertificate						-- CONFIGMG: Binary per certifikaten
		FROM CONFIGMG 
		CROSS JOIN CONFND;

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

	--SELECT @XmlString, @SignedXml

	EXEC _FiscalProcessRequest 
			@InputString		 = @XmlString,
			@CertificatePath	 = @CertificatePath, 
			@Certificatepassword = @CertificatePwd,
			@CertBinary			 = @Certificate,
			@Url				 = 'https://einvoice-test.tatime.gov.al/EinvoiceService-v1/EinvoiceService.wsdl',
			@Schema				 = "https://Einvoice.tatime.gov.al/EinvoiceService/schema",
			@ReturnValue		 = '',
			@useSystemProxy		 = '',
			@SignedXml			 = @SignedXml	OUTPUT, 
			@Fic				 = @Fic			OUTPUT, 
			@Error				 = @Error		OUTPUT, 
			@Errortext			 = @Errortext	OUTPUT,
			@responseXML		 = @responseXML OUTPUT;
 
	SET @XML = CAST(@SignedXml  AS XML)
	--SELECT @XmlString, @SignedXml, @Fic, @Error, @ErrorText AS AAA, @XML;

	
	IF(@Error = 0)
	BEGIN
		--RASTI KUR PO KERKON
		IF(@Eic = '')
		BEGIN
			EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="https://Einvoice.tatime.gov.al/EinvoiceService/schema" />';
			--SELECT @responseXML
			SELECT *
			INTO #TEMPORANE 
			FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:GetEinvoicesResponse/ns2:Einvoices/ns2:Einvoice')
			WITH
			(
				DocNumber [varchar] (50) '@DocNumber',
				Amount	[float] '@Amount',
				DocType [varchar] (50) '@DocType',
				DueDateTime [varchar] (50) '@DueDateTime',
				EIC [varchar] (50) '@EIC',
				PartyType [varchar] (50) '@PartyType',
				RecDateTime [varchar] (50) '@RecDateTime',
				Status [varchar] (50) '@Status'
			);
			EXEC sp_xml_removedocument @hDoc;
			SELECT * FROM #TEMPORANE ORDER BY RECDATETIME
			UPDATE S
				SET S.status = [T].[Status]
			FROM SM S 
			INNER JOIN #TEMPORANE T ON T.EIC =S.eic

		END		
		ELSE 
		BEGIN

			SELECT @responseXML

			EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="https://Einvoice.tatime.gov.al/EinvoiceService/schema" />';


			DECLARE @pdf NVARCHAR(MAX);

			SELECT @pdf = Pdf
			FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:GetEinvoicesResponse/ns2:Einvoices/ns2:Einvoice')
			WITH
			(
				Pdf NVARCHAR(MAX) 'ns2:Pdf'
			);
			UPDATE SM SET FISCPDF = @pdf WHERE eic = @Eic
			--SELECT LEN(@pdf), @pdf

		END
	END

	ELSE SELECT @responseXml;
END


GO
