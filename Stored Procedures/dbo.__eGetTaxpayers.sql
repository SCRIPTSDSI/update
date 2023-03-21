SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[__eGetTaxpayers]
 	@Tin		NVARCHAR(100)	=	 '',-- NIPT
	@Name		NVARCHAR(200)	=	 '' -- EMRI
AS 
BEGIN	
	SET NOCOUNT ON;

	DECLARE  @NIPT				VARCHAR(20)
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
			,@hDoc				INT
			,@EICURL			NVARCHAR(MAX);

	SET @UniqueIdentif = NEWID();

SELECT TOP 1 @NIPT					= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCVATREGISTRATIONNO')					-- CONFND:	 NIPT i kompanise
				,@SoftNum				= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSOFTNUM')			-- CONFIGMG: SoftNum -- kodi i zgjidhjes software te merret ne nje tabele konfigurimi
				,@Schema				= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSCHEMA')				-- CONFIGMG: fiscSchema ka te beje me skemen e perdorur per krijimin e xml e cila eshte fikse, por mund te ndryshoje ne vijim
				,@FiscUrL				= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCURL')				-- CONFIGMG: url per web service
				,@EICURL				= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'EICURL')
				,@CertificatePath       = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPATH')		-- CONFIGMG: PATH ne te cilin ndohet certifikata ne server
				,@CertificatePwd	    = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPASS')	-- CONFIGMG: Fjalekalim per hapjen e certifikates
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

	--SELECT @Xml;
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
		--SUCCESS
		EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="https://Einvoice.tatime.gov.al/EinvoiceService/schema" />';
			--select @responseXML
			SELECT *
			FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:GetTaxpayersResponse/ns2:Taxpayers/ns2:Taxpayer')
			WITH
			(
				[Name]		NVARCHAR(100)	'@Name',
				[Address]	NVARCHAR(100)	'@Address',
				[Country]	NVARCHAR(100)	'@Country',
				[Tin]		NVARCHAR(100)	'@Tin',
				[Town]		NVARCHAR(100)	'@Town'
			);
			EXEC sp_xml_removedocument @hDoc;
	END
	ELSE SELECT @responseXml, @Error
END


--EXEC __eGetTaxpayers 'K31418036C',''
GO
