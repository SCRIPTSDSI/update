SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec dbo.Fisc_eGetTaxpayers '','altin vrusho'
CREATE PROC [dbo].[Fisc_eGetTaxpayers]
 	@Tin		NVARCHAR(100)	=	 '',-- NIPT
	@Name		NVARCHAR(200)	=	 '' -- EMRI
AS 
BEGIN	
	SET NOCOUNT ON;

	DECLARE  @VatRegistrationNo	VARCHAR(20)
			,@SoftNum			VARCHAR(1000)
			,@CertificatePath	VARCHAR(1000)
			,@CertificatePwd	VARCHAR(1000)
			,@Certificate		VARBINARY(MAX)
			,@Schema			VARCHAR(1000)
			,@FiscUrL			VARCHAR(1000)
			,@Fic				VARCHAR(1000)
			,@UniqueIdentif		UNIQUEIDENTIFIER
			,@XmlString			VARCHAR(MAX)
			,@Xml				XML
			,@responseXml		XML
			,@SignedXml			VARCHAR(MAX)
			,@Error				NVARCHAR(MAX)
			,@ErrorText			NVARCHAR(MAX)
			,@hDoc				INT;		
			
	SET @UniqueIdentif = NEWID();
	
	/*
		UPDATE Configuration SET Picture = (
		SELECT * FROM OPENROWSET(BULK N'C:\FISCAL\infosoft.p12', SINGLE_BLOB) rs )
		WHERE [KEY] = 'FiscCertificate'
	 */
		
	--SELECT TOP 1 @VatRegistrationNo		= ISNULL(dbo.GetConfigKeyValue('Info', 'VatRegistrationNo', ''), '')
	--			,@SoftNum				= ISNULL(dbo.GetConfigKeyValue('Fiscal', 'FiscSoftNum', ''), '')
	--			,@Schema				= ISNULL(dbo.GetConfigKeyValue('Fiscal', 'FiscSchema', ''), '')
	--			,@FiscUrL				= ISNULL(dbo.GetConfigKeyValue('Fiscal', 'FiscURL', ''), '')
	--			,@CertificatePath       = ISNULL(dbo.GetConfigKeyValue('Fiscal', 'FiscCertificatePath', ''), '')
	--			,@CertificatePwd	    = ISNULL(dbo.GetConfigKeyValue('Fiscal', 'FiscCertificatePwd', ''), '')
	--			,@Certificate			= (SELECT Picture FROM Configuration WHERE [key] = 'FiscCertificate');
		
		SELECT TOP 1 @VatRegistrationNo				= ISNULL(NIPT, '')					-- CONFND:	 NIPT i kompanise
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
			NEWID()				     AS 'Header/@UUID',
	(SELECT	CASE WHEN @Tin = '' THEN NULL ELSE @Tin END AS 'Tin',
		CASE WHEN @Name = '' THEN NULL ELSE @Name END AS 'Name'
		FOR XML PATH('Filter'), TYPE
	)
	FOR XML PATH('GetTaxpayersRequest'));

	SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<GetTaxpayersRequest>','<GetTaxpayersRequest xmlns="https://Einvoice.tatime.gov.al/EinvoiceService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="1">') AS XML)
	SET @XMLSTRING = CAST(@xml AS VARCHAR(MAX));
	
	EXEC _FiscalSignRequest @XmlString, @CertificatePath, @CertificatePwd, @Certificate, @SignedXml OUTPUT;

	EXEC _FiscalProcessRequest 
			@InputString		 = @XmlString,
			@CertificatePath	 = @CertificatePath, 
			@Certificatepassword = @CertificatePwd,
			@CertBinary			 = @Certificate,
			@Url				 = 'https://einvoice-test.tatime.gov.al/EinvoiceService-v1/EinvoiceService.wsdl',
			@Schema				 = "https://Einvoice.tatime.gov.al/EinvoiceService/schema",
			@ReturnValue		 = '',
			@SignedXml			 = @SignedXml	OUTPUT, 
			@Fic				 = @Fic			OUTPUT, 
			@Error				 = @Error		OUTPUT, 
			@Errortext			 = @Errortext	OUTPUT,
			@responseXML			 = @responseXML OUTPUT;
 
	SET @XML = CAST(@SignedXml  AS XML)

	IF(@Error = 0)
	BEGIN
		--SUCCESS
		EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="https://Einvoice.tatime.gov.al/EinvoiceService/schema" />';

			SELECT *
			FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:GetTaxpayersResponse/ns2:Taxpayers/ns2:Taxpayer')
			WITH
			(
				[Name]		NVARCHAR(MAX)	'@Name',
				[Address]	NVARCHAR(MAX)	'@Address',
				[Country]	NVARCHAR(MAX)	'@Country',
				[Tin]		NVARCHAR(MAX)	'@Tin',
				[Town]		NVARCHAR(MAX)	'@Town'
			)
			ORDER BY [Name];
			EXEC sp_xml_removedocument @hDoc;
	END
	ELSE 
		SELECT @responseXml, @Errortext, @Error;
END
GO
