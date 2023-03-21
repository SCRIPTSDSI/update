//TEST
IF OBJECT_ID('dbo.FJStornimScr', 'U') IS NULL 
SET NOEXEC ON
GO
if not exists (select
                     column_name
               from
                     INFORMATION_SCHEMA.columns
               where
                     table_name = 'FJ'
                     and column_name = 'EINVOICE')
ALTER TABLE [dbo].FJ ADD
[EINVOICE] [bit] NULL CONSTRAINT [DF_FJ_EINVOICE] DEFAULT ((0))
GO
 UPDATE CONFIG..TABLELISTFIELDS SET 
 LISTFIELDSDOCEXC=LISTFIELDSDOCEXC+',EINVOICE'
 FROM CONFIG..TABLELISTFIELDS
 WHERE MODUL='FT' AND LISTFIELDSDOCEXC NOT LIKE '%EINVOICE%';
GO

IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'Isd_FisGetOperators')
DROP PROCEDURE Isd_FisGetOperators
GO
PRINT N'Create [dbo].[Isd_FisGetOperators]'
GO
CREATE PROC [dbo].[Isd_FisGetOperators]
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
			NEWID()				     AS 'Header/@UUID',
			dbo.DATE_1601(GETDATE()) AS 'Header/@SendDateTime'
			
	FOR XML PATH('GetOperatorsRequest'));

	SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<GetOperatorsRequest>','<GetOperatorsRequest xmlns="https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3">') AS XML)
	
	SET @XMLSTRING = CAST(@xml AS VARCHAR(MAX));	

	EXEC _FiscalSignRequest @XmlString, @CertificatePath, @CertificatePwd, @Certificate, @SignedXml OUTPUT;	

	EXEC _FiscalProcessRequest 
			@InputString		 = @XmlString,
			@CertificatePath	 = @CertificatePath, 
			@Certificatepassword = @CertificatePwd,
			@CertBinary			 = @Certificate,
			@Url				 = @FISCURL,
			@Schema				 = "https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema",
			@ReturnValue		 = '',
			@useSystemProxy		 = '',
			@SignedXml			 = @SignedXml	OUTPUT, 
			@Fic				 = @Fic			OUTPUT, 
			@Error				 = @Error		OUTPUT, 
			@Errortext			 = @Errortext	OUTPUT,
			@responseXML		 = @responseXML OUTPUT;
 
 
	-- SELECT @responseXml, @Error,@Errortext,@Fic

	IF(@Error = 0)
	BEGIN
		
	IF OBJECT_ID('tempdb..##operators') IS NOT NULL 
	DROP TABLE ##operators;
	
		

		EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema" />';
			SELECT *
			INTO ##operators
			FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:GetOperatorsResponse/ns2:Operators/ns2:Operator')
			WITH
			(
				[OprCode]			NVARCHAR(100)	'@OprCode',
				[OprFirstName]		NVARCHAR(100)	'@OprFirstName',
				[OprLastName]		NVARCHAR(100)	'@OprLastName',
				[OprID]				NVARCHAR(100)	'@OprID',
				[OprValidFrom]		NVARCHAR(100)	'@OprValidFrom',
				[OprValidTo]		NVARCHAR(100)	'@OprValidTo'
			);
			EXEC sp_xml_removedocument @hDoc;


			UPDATE FisOperator SET NOTACTIV=1
			FROM FisOperator WHERE NOT EXISTS (SELECT * FROM ##operators A WHERE KODFISCAL=A.OprCode )

			UPDATE FisOperator SET NOTACTIV=0,DATEFILLIM=OprValidFrom,DATEFUND=OprValidto,NIPT=OprID
			FROM FisOperator INNER JOIN  ##operators A ON KODFISCAL=A.OprCode 


	END 
	ELSE SELECT [OprCode]='', [OprFirstName]='', [OprLastName]='', [OprID]='', [OprValidFrom]='',[OprValidTo]='',
	 ErrorText=@Errortext, ErrorKod=@Error;

	 --SELECT * FROM ##operators
END
GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'Isd_FisGetTCRs')
DROP PROCEDURE Isd_FisGetTCRs
GO
PRINT N'Create [dbo].[Isd_FisGetTCRs]'
GO
CREATE PROC [dbo].[Isd_FisGetTCRs]
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
			NEWID()				     AS 'Header/@UUID',
			dbo.DATE_1601(GETDATE()) AS 'Header/@SendDateTime'
			
	FOR XML PATH('GetTCRsRequest'));

	SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<GetTCRsRequest>','<GetTCRsRequest xmlns="https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3">') AS XML)
	
	SET @XMLSTRING = CAST(@xml AS VARCHAR(MAX));	

	EXEC _FiscalSignRequest @XmlString, @CertificatePath, @CertificatePwd, @Certificate, @SignedXml OUTPUT;	

	EXEC _FiscalProcessRequest 
			@InputString		 = @XmlString,
			@CertificatePath	 = @CertificatePath, 
			@Certificatepassword = @CertificatePwd,
			@CertBinary			 = @Certificate,
			@Url				 = @FISCURL,
			@Schema				 = "https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema",
			@ReturnValue		 = '',
			@useSystemProxy		 = '',
			@SignedXml			 = @SignedXml	OUTPUT, 
			@Fic				 = @Fic			OUTPUT, 
			@Error				 = @Error		OUTPUT, 
			@Errortext			 = @Errortext	OUTPUT,
			@responseXML		 = @responseXML OUTPUT;
 
 
	-- SELECT @responseXml, @Error,@Errortext,@Fic

	IF(@Error = 0)
	BEGIN
		
	IF OBJECT_ID('tempdb..##TCRs') IS NOT NULL 
	DROP TABLE ##TCRs;
	
		

		EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema" />';
			SELECT *
			INTO ##TCRs
			FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:GetTCRsResponse/ns2:TCRs/ns2:TCR')
			WITH
			(
				[BusinUnitCode]		NVARCHAR(100)	'@BusinUnitCode',
				[TCRCode]			NVARCHAR(100)	'@TCRCode',
				[ValidFrom]			NVARCHAR(100)	'@ValidFrom'
			);
			EXEC sp_xml_removedocument @hDoc;

			UPDATE FisTCR SET NOTACTIV=1
			FROM FisTCR WHERE NOT EXISTS (SELECT * FROM ##TCRs A WHERE KODTCR=A.TCRCode )

			UPDATE FisTCR SET NOTACTIV=0,DATESTART=ValidFrom,SHENIM1=BusinUnitCode
			FROM FisTCR INNER JOIN  ##TCRs A ON KODTCR=A.TCRCode


	END 
	ELSE 
	SELECT [BusinUnitCode]='', [TCRCode]='', [ValidFrom]='', ErrorText=@Errortext, ErrorKod=@Error;

	 --SELECT * FROM ##TCRs
END
GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'Isd_FisGetBusinessUnits')
DROP PROCEDURE Isd_FisGetBusinessUnits
GO
PRINT N'Create [dbo].[Isd_FisGetBusinessUnits]'
GO
CREATE PROC [dbo].[Isd_FisGetBusinessUnits]
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
			NEWID()				     AS 'Header/@UUID',
			dbo.DATE_1601(GETDATE()) AS 'Header/@SendDateTime'
			
	FOR XML PATH('GetBusinessUnitsRequest'));

	SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<GetBusinessUnitsRequest>','<GetBusinessUnitsRequest xmlns="https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3">') AS XML)
	
	SET @XMLSTRING = CAST(@xml AS VARCHAR(MAX));	

	EXEC _FiscalSignRequest @XmlString, @CertificatePath, @CertificatePwd, @Certificate, @SignedXml OUTPUT;	

	EXEC _FiscalProcessRequest 
			@InputString		 = @XmlString,
			@CertificatePath	 = @CertificatePath, 
			@Certificatepassword = @CertificatePwd,
			@CertBinary			 = @Certificate,
			@Url				 = @FISCURL,
			@Schema				 = "https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema",
			@ReturnValue		 = '',
			@useSystemProxy		 = '',
			@SignedXml			 = @SignedXml	OUTPUT, 
			@Fic				 = @Fic			OUTPUT, 
			@Error				 = @Error		OUTPUT, 
			@Errortext			 = @Errortext	OUTPUT,
			@responseXML		 = @responseXML OUTPUT;
 
 
	-- SELECT @responseXml, @Error,@Errortext,@Fic

	IF(@Error = 0)
	BEGIN
		
	IF OBJECT_ID('tempdb..##BusinessUnits') IS NOT NULL 
	DROP TABLE ##BusinessUnits;
	
		

		EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema" />';
			SELECT *
			INTO ##BusinessUnits
			FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:GetBusinessUnitsResponse/ns2:BusinessUnits/ns2:BusinessUnit')
			WITH
			(
				[BUCode]			NVARCHAR(100)	'@BUCode',
				[BUName]			NVARCHAR(100)	'@BUName',
				[BUSerialNumber]	NVARCHAR(100)	'@BUSerialNumber',
				[BUStreetName]		NVARCHAR(100)	'@BUStreetName',
				[BUValidFrom]		NVARCHAR(100)	'@BUValidFrom'
			);
			EXEC sp_xml_removedocument @hDoc;

			UPDATE FisBusUnit SET NOTACTIV=1
			FROM FisBusUnit WHERE NOT EXISTS (SELECT * FROM ##BusinessUnits A WHERE KOD=A.BUCode )

			UPDATE FisBusUnit SET NOTACTIV=0,ADRESE1=left(BUStreetName,150),SHENIM1=left(BUName,100),SHENIM2=BUValidFrom,NIPTCERTIFIKATE=BUSerialNumber
			FROM FisBusUnit INNER JOIN  ##BusinessUnits A ON KOD=A.BUCode

	END 
	ELSE 
	SELECT [BUCode]='', [BUName]='', [BUSerialNumber]='', [BUStreetName]='', [BUValidFrom]='', ErrorText=@Errortext, ErrorKod=@Error;

	 --SELECT * FROM ##BusinessUnits
END

GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'Isd_InicTablePromoc')
DROP PROCEDURE Isd_InicTablePromoc
GO
PRINT N'Create [dbo].[Isd_InicTablePromoc]'
GO
CREATE Procedure [dbo].[Isd_InicTablePromoc] 
As
-- Perdoret vetem per rastin e pare te table Promoc


DECLARE @CERT AS VARCHAR(MAX)
SET @CERT=(SELECT FISCCERTIFICATE FROM CONFND)

IF (SELECT COUNT('') from sys.assemblies
			  WHERE NAME='IIC')<>0 AND ISNULL(@CERT,'')<>''
			  BEGIN

			  EXEC [dbo].[Isd_FisGetBusinessUnits]
			  EXEC [dbo].[Isd_FisGetOperators]
			  EXEC [dbo].[Isd_FisGetTCRs]
			  END


Declare @LlogDhurA Varchar(30),
        @LlogDhurB Varchar(30),
        @LlogDhurC Varchar(30),
        @LlogDhurD Varchar(30),
        @Kod       Varchar(5),
        @Llogari   Varchar(30),

        @ListKod   Varchar(10),
        @Pershkrim Varchar(50),
        @Koment    Varchar(50),
        @Prompt    Varchar(30),
        @Bosh      Varchar(5),
        @Lidhez    Varchar(5)

      SELECT @LlogDhurA=LLOGDHURA, @LlogDhurB=LLOGDHURB, @LlogDhurC=LLOGDHURC, @LlogDhurD=LLOGDHURD 
        FROM CONFIGLM

         SET @ListKod   = 'ABCD'
         SET @Prompt    = 'Promocion '
         SET @Koment    = 'Promocion ne shitje'
         SET @Bosh      = ''
         SET @Lidhez    = ' - ';


         SET @Kod       = SUBSTRING(@ListKod,1,1)
         SET @Llogari   = @LlogDhurA
         SET @Pershkrim = @Prompt+@Kod+@Lidhez+@Llogari;

         IF (IsNull(@Llogari,@Bosh)<>@Bosh) AND (NOT EXISTS (SELECT KOD FROM PROMOC WHERE KOD=@Kod))
            BEGIN
              INSERT INTO PROMOC
                     (KOD,PERSHKRIM,SHENIM1,SHENIM2,SHENIM3,KODLMFJ,KODLMFF,TIPI,KLASIFIKIM1,KLASIFIKIM2,DATELIMITED,NOTACTIV)
              VALUES (@Kod,@Pershkrim,@Koment,@Bosh,@Bosh,@Llogari,@Bosh,2,@Bosh,@Bosh,0,0);
            END;

         SET @Kod       = SUBSTRING(@ListKod,2,1)
         SET @Llogari   = @LlogDhurB
         SET @Pershkrim = @Prompt+@Kod+@Lidhez+@Llogari;

         IF (IsNull(@Llogari,@Bosh)<>@Bosh) AND (NOT EXISTS (SELECT KOD FROM PROMOC WHERE KOD=@Kod))
            BEGIN
              INSERT INTO PROMOC
                     (KOD,PERSHKRIM,SHENIM1,SHENIM2,SHENIM3,KODLMFJ,KODLMFF,TIPI,KLASIFIKIM1,KLASIFIKIM2,DATELIMITED,NOTACTIV)
              VALUES (@Kod,@Pershkrim,@Koment,@Bosh,@Bosh,@Llogari,@Bosh,2,@Bosh,@Bosh,0,0);
            END;

         SET @Kod       = SUBSTRING(@ListKod,3,1)
         SET @Llogari   = @LlogDhurC
         SET @Pershkrim = @Prompt+@Kod+@Lidhez+@Llogari;

         IF (IsNull(@Llogari,@Bosh)<>@Bosh) AND (NOT EXISTS (SELECT KOD FROM PROMOC WHERE KOD=@Kod))
            BEGIN
              INSERT INTO PROMOC
                     (KOD,PERSHKRIM,SHENIM1,SHENIM2,SHENIM3,KODLMFJ,KODLMFF,TIPI,KLASIFIKIM1,KLASIFIKIM2,DATELIMITED,NOTACTIV)
              VALUES (@Kod,@Pershkrim,@Koment,@Bosh,@Bosh,@Llogari,@Bosh,2,@Bosh,@Bosh,0,0);
            END;

         SET @Kod       = SUBSTRING(@ListKod,4,1)
         SET @Llogari   = @LlogDhurD
         SET @Pershkrim = @Prompt+@Kod+@Lidhez+@Llogari;

         IF (IsNull(@Llogari,@Bosh)<>@Bosh) AND (NOT EXISTS (SELECT KOD FROM PROMOC WHERE KOD=@Kod))
            BEGIN
              INSERT INTO PROMOC
                     (KOD,PERSHKRIM,SHENIM1,SHENIM2,SHENIM3,KODLMFJ,KODLMFF,TIPI,KLASIFIKIM1,KLASIFIKIM2,DATELIMITED,NOTACTIV)
              VALUES (@Kod,@Pershkrim,@Koment,@Bosh,@Bosh,@Llogari,@Bosh,2,@Bosh,@Bosh,0,0);
            END;

      SELECT @Llogari = CASE WHEN ISNULL(LLOGDHURA,'')<>'' THEN LLOGDHURA
                             WHEN ISNULL(LLOGDHURB,'')<>'' THEN LLOGDHURB
                             WHEN ISNULL(LLOGDHURC,'')<>'' THEN LLOGDHURC
                             WHEN ISNULL(LLOGDHURD,'')<>'' THEN LLOGDHURD
                             ELSE ''
                        END
        FROM CONFIGLM;


          IF IsNull(@Llogari,@Bosh)<>@Bosh
             BEGIN
               UPDATE CONFIGLM
                  SET LLOGPRMCFJ = CASE WHEN ISNULL(LLOGPRMCFJ,@Bosh)<>@Bosh 
                                        THEN ISNULL(LLOGPRMCFJ,@Bosh)
                                        ELSE @Llogari 
                                   END,
                      LLOGPRMCFF = CASE WHEN ISNULL(LLOGPRMCFF,@Bosh)<>@Bosh 
                                        THEN ISNULL(LLOGPRMCFF,@Bosh)
                                        ELSE @Llogari 
                                   END
             END;

GO
ALTER PROCEDURE [dbo].[Isd_GatiFiskalCashOperation2]
(
  @pTCRCode          Varchar(50),
  @pDateDok          Varchar(20),
  @pCashOperation    Varchar(50),
  @pCashAmount       Float,
  @pArke             Varchar(30),
  @pKase             Varchar(30),
  @pKMon             Varchar(20),
  @pQellimi          Varchar(300),
  @pUser             Varchar(30)
)
AS
BEGIN
	     SET NOCOUNT ON;

EXEC [dbo].[Isd_FisGetOperators]
EXEC [dbo].[Isd_FisGetBusinessUnits]
EXEC [dbo].[Isd_FisGetTCRs]

     DECLARE @VatRegistrationNo	     VARCHAR(50)
			,@BusinessUnit		     VARCHAR(50)
			,@SoftNum			     VARCHAR(50)
			,@ManufacNum		     VARCHAR(50)
			,@FIC				     VARCHAR(1000)
			,@SIGNEDXML			     VARCHAR(MAX)
			,@ERROR				     VARCHAR(1000)
			,@ERRORtext			     VARCHAR(1000)
			,@schema			     VARCHAR(MAX)
			,@Url				     VARCHAR(MAX)
			,@CertificatePath        VARCHAR(MAX)
			,@certificatepassword    VARCHAR(MAX)
			,@XMLSTRING              VARCHAR(MAX)
			,@QRCODELINK             VARCHAR(MAX)
			,@xml				     XML
			,@TCRNumber			     VARCHAR(MAX)
			,@DateDok                DateTime
			,@CashOperation          Varchar(30)
			,@CashAmount             Float
			,@Arke                   Varchar(30)
			,@Kase                   Varchar(30)
			,@KMon                   Varchar(10)
			,@Qellimi                Varchar(300)
			,@Perdorues              Varchar(30);
         SET @TCRNumber            = @pTcrCode;
		 SET @DateDok              = dbo.DateValue(@pDateDok);
		 SET @CashOperation        = @pCashOperation;
		 SET @CashAmount           = @pCashAmount;
--       SET @BusinessUnit         = @pBusinessUnit;
		 SET @Arke                 = @pArke;
		 SET @Kase                 = @pKase;
		 SET @KMon                 = @pKMon;
		 SET @Qellimi              = @pQellimi;
		 SET @Perdorues            = @pUser;
      SELECT @VatRegistrationNo    = (SELECT TOP 1 NIPT             FROM CONFND)
		    ,@BusinessUnit         = (SELECT TOP 1 SHENIM1          FROM FisTCR    WHERE KODTCR=@TCRNumber)
		    ,@SoftNum              = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSOFTNUM')
		    ,@ManufacNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCMANUFACNUM')
			,@schema			   = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSCHEMA')
		    ,@Url				   = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCURL')
		    ,@CertificatePath      = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPATH')
		    ,@certificatepassword  = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPASS')		
SET @XML  = (
      SELECT
		     dbo.DATE_1601(GETDATE()) AS 'Header/@SendDateTime',
          -- 'false'                  AS 'Header/@SubseqDelivType',
		     NEWID()                  AS 'Header/@UUID',					--Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
(
	  SELECT dbo.DATE_1601(GETDATE())               AS '@ChangeDateTime'
		    ,@VatRegistrationNo						AS '@IssuerNUIS'		--Duhet shtuar ne magazina/fature
		    ,@pCashOperation	                    AS '@Operation'	
		    ,CONVERT(DECIMAL(18, 2),@pCashAmount)	AS '@CashAmt'
		    ,@TCRNumber								AS '@TCRCode'
	     FOR XML PATH('CashDeposit'), TYPE
)
FOR XML PATH('RegisterCashDepositRequest'));
SET @XML = CAST( REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterCashDepositRequest>','<RegisterCashDepositRequest xmlns="https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3"> ') AS XML);
SET @XMLSTRING = CAST(@xml AS VARCHAR(MAX));
	 DECLARE @FiscCert AS VARBINARY(MAX);
	
	  SELECT TOP 1 @FiscCert = FiscCertificate FROM CONFND;
	
	 DECLARE @responseXML AS XML;
        EXEC _FiscalProcessRequest
             @XMLSTRING,								
             @certificatePath		= @certificatePath,														
             @certificatepassword	= @certificatepassword,	
             @certbinary			= @fisccert,
             @url					= @url,
             @schema				= @schema,
             @returnValue			= '',							--> VLERA QE KERKON TE MARRESH NGA DERGIMI I KERKESES
             @useSystemProxy        = '',
             @SIGNEDXML				= @SIGNEDXML OUTPUT,			--> XML E PERGATITUR BASHKE ME SHENJIMIN
             @FIC					= @FIC OUTPUT,					--> FIC PER VLEREN E FATURES, NR I SHENJIMIT
             @ERROR					= @ERROR OUTPUT,				--> 0 -> SKA GABIM 1-> KA GABIM
             @ERRORtext				= @ERRORtext OUTPUT,			--> MESAZHI I GABIMIT
             @responseXML			= @responseXML	OUTPUT	
--      INSERT INTO LOGARKA( BUSINESSUNIT, TCRCODE,   DATEDOK, TIPI,           VLERA,       ERROR, ERRORTEXT, [XML],ERRORMESSAGE,ARKE, KASE, KMON, QELLIMI, USI,       USM)
--      VALUES             (@BusinessUnit,@TCRNumber,@DateDok,@pCashOperation,@pCashAmount,@ERROR,@ERRORtext, @xml, @FIC,        @Arke,@Kase,@KMon,@Qellimi,@Perdorues,@Perdorues);
	 
	  INSERT INTO LOGARKA( BUSINESSUNIT, TCRCODE,   DATEDOK, TIPI,           VLERA,       ERROR, ERRORTEXT, [XML],ERRORMESSAGE,ARKE, KASE, KMON, QELLIMI, USI,       USM, FISKALIZUAR)
	  VALUES             (@BusinessUnit,@TCRNumber,@DateDok,@pCashOperation,@pCashAmount,'0',@ERRORtext, @xml, @FIC,        @Arke,@Kase,@KMon,
						CASE WHEN @ERROR='0' THEN @Qellimi ELSE 'PA FISKALIZUAR' END,@Perdorues,@Perdorues,
						 CASE WHEN @ERROR='0' THEN 1 ELSE 0 END);
   --   SELECT @FIC AS ReturnValue, 
	  --@ERROR AS Error, @ERRORtext AS ErrorText,@xml as XmlString, @SIGNEDXML AS SingedXml, @Fic AS ERRORMESSAGE;
	  DECLARE @OUTPUT1 VARCHAR(60),
				@OUTPUT2 VARCHAR(60),
				@OUTMESSAGE VARCHAR(MAX)
		SET @OUTPUT1=@Error
		SET @OUTPUT2='0'
		SET @OUTMESSAGE= CASE WHEN @Error='0' THEN '' ELSE @ErrorText END
		
		
			   
		select @OUTPUT1 AS KodError1,@OUTPUT2 AS KodError2,@OUTMESSAGE AS MsgError
END
--------------------------------------------------------------
PRINT N'Shtim vlere OTHER FEE tek klasat e tvsh-se '
GO
IF (select count('') FROM CONFIG..TIPDOK where TIPDOK='TVSHFIC' AND KOD='OTHER')=0
INSERT INTO CONFIG..TIPDOK
           ([TIPDOK]
           ,[KOD]
           ,[PERSHKRIM]
           ,[NRORD]
           ,[KODNUM]
           ,[KODTD]
          
           ,[VISIBLE]
           )
SELECT 'TVSHFIC','OTHER',	'OTHER FEE',	'FIC07',	'7','',1
IF (select count('') FROM CONFIG..TIPDOK where TIPDOK='TVSHFIC' AND KOD='PACK')=0
INSERT INTO CONFIG..TIPDOK
           ([TIPDOK]
           ,[KOD]
           ,[PERSHKRIM]
           ,[NRORD]
           ,[KODNUM]
           ,[KODTD]
          
           ,[VISIBLE]
           )
SELECT 'TVSHFIC','PACK',	'Packaging fee',	'FIC08',	'8','',1
GO
IF (select count('') FROM CONFIG..TIPDOK where TIPDOK='TVSHFIC' AND KOD='BOTTLE')=0
INSERT INTO CONFIG..TIPDOK
           ([TIPDOK]
           ,[KOD]
           ,[PERSHKRIM]
           ,[NRORD]
           ,[KODNUM]
           ,[KODTD]
          
           ,[VISIBLE]
           )
SELECT 'TVSHFIC','BOTTLE',	'BOTTLE Fee for the return of glass bottles',	'FIC09',	'9','',1
GO
IF (select count('') FROM CONFIG..TIPDOK where TIPDOK='TVSHFIC' AND KOD='COMMISSION')=0
INSERT INTO CONFIG..TIPDOK
           ([TIPDOK]
           ,[KOD]
           ,[PERSHKRIM]
           ,[NRORD]
           ,[KODNUM]
           ,[KODTD]
          
           ,[VISIBLE]
           )
SELECT 'TVSHFIC','COMMISSION',	'Commission for currency exchange activities',	'FIC10',	'10','',1
GO
ALTER PROCEDURE [dbo].[Isd_GatiFiskalCashOperation]
(
  @CashAmount       Float,
  @CashOperation    Varchar(50),
  @pNrRendor        Integer
)

AS

BEGIN

 -- @pNrRendor -  ID tek tabela FisTCR
 
	SET NOCOUNT ON;

   DECLARE  @VatRegistrationNo	VARCHAR(50)
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
			,@xml				XML
			,@TCRNumber			VARCHAR(MAX);

SET @TCRNumber=(SELECT TOP 1 KODTCR FROM FisTCR WHERE NRRENDOR=@pNrRendor)

SELECT       @VatRegistrationNo = (SELECT TOP 1 NIPT FROM CONFND)
		    ,@BusinessUnit      = (SELECT TOP 1 SHENIM1 FROM FisTCR WHERE NRRENDOR=@pNrRendor)
		    ,@SoftNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSOFTNUM')
		    ,@ManufacNum        = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCMANUFACNUM')
			,@schema			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSCHEMA')
		    ,@Url				= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCURL')
		    ,@CertificatePath           = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPATH')
		    ,@certificatepassword        = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPASS')		

SET @XML  = (
SELECT 
		dbo.DATE_1601(GETDATE()) AS 'Header/@SendDateTime',
		--'false'					 AS 'Header/@SubseqDelivType',
		NEWID()				     AS 'Header/@UUID',					--Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
(
	SELECT dbo.DATE_1601(GETDATE())					AS '@ChangeDateTime'
		   , @VatRegistrationNo						AS '@IssuerNUIS'		--Duhet shtuar ne magazina/fature
		   , @CashOperation								AS '@Operation'	
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
		@returnValue			= '',							--> VLERA QE KERKON TE MARRESH NGA DERGIMI I KERKESES
		@useSystemProxy         = '',
		@SIGNEDXML				= @SIGNEDXML OUTPUT,			--> XML E PERGATITUR BASHKE ME SHENJIMIN 
		@FIC					= @FIC OUTPUT,					--> FIC PER VLEREN E FATURES, NR I SHENJIMIT
		@ERROR					= @ERROR OUTPUT,				--> 0 -> SKA GABIM 1-> KA GABIM
		@ERRORtext				= @ERRORtext OUTPUT,				--> MESAZHI I GABIMIT
		@responseXML			= @responseXML	OUTPUT	


IF @ERROR=0
UPDATE LOGARKA SET FISKALIZUAR=1,QELLIMI='FISKALIZUAR'
FROM LOGARKA WHERE DATEDOK=DBO.DATEVALUE(CONVERT(VARCHAR,GETDATE(),103)) AND FISKALIZUAR=0 AND TCRCODE=@TCRNumber


--INSERT INTO LOGARKA(TCRCODE,TIPI,VLERA,ERROR,ERRORTEXT,[XML],ERRORMESSAGE) VALUES (@TCRNumber,@CashOperation,@CashAmount,@ERROR,@ERRORtext,@xml,@FIC)
--SELECT  @FIC AS returnValue, @ERROR AS error, @ERRORtext AS errortext,@xml as xmlstring, @SIGNEDXML AS singedxml;

------------------------------------------------
	
END
GO


ALTER PROCEDURE [dbo].[Isd_GatiFiskalCashOperationOffline]
(
   @pNrRendor        Integer
)

AS

BEGIN

 -- @pNrRendor -  ID tek tabela FisTCR
 
	SET NOCOUNT ON;

--   DECLARE  @VatRegistrationNo	VARCHAR(50)
--			,@BusinessUnit		VARCHAR(50)
--			,@SoftNum			VARCHAR(50)
--			,@ManufacNum		VARCHAR(50)
--			,@FIC				VARCHAR(1000)
--			,@SIGNEDXML			VARCHAR(MAX)
--			,@ERROR				VARCHAR(1000)
--			,@ERRORtext			VARCHAR(1000)
--			,@schema			VARCHAR(MAX)
--			,@Url				VARCHAR(MAX)
--			,@CertificatePath   VARCHAR(MAX)
--			,@certificatepassword VARCHAR(MAX)
--			,@XMLSTRING           VARCHAR(MAX)
--			,@QRCODELINK        VARCHAR(MAX)
--			,@xml				XML
--			,@TCRNumber			VARCHAR(MAX);



--SELECT       @VatRegistrationNo = (SELECT TOP 1 NIPT FROM CONFND)
--		    ,@BusinessUnit      = (SELECT TOP 1 SHENIM1 FROM FisTCR WHERE NRRENDOR=@pNrRendor)
--		    ,@SoftNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSOFTNUM')
--		    ,@ManufacNum        = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCMANUFACNUM')
--			,@schema			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSCHEMA')
--		    ,@Url				= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCURL')
--		    ,@CertificatePath           = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPATH')
--		    ,@certificatepassword        = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPASS')		

--SET @XML  = (select [xml] from LOGARKA where NRRENDOR=@pNrRendor)

--SET @XMLSTRING = CAST(@xml AS VARCHAR(MAX));
--	declare @fisccert as varbinary(max)
	

--	select top 1 @fisccert = fisccertificate from CONFND

	
--	DECLARE @responseXML AS XML


--EXEC _FiscalProcessRequest 
--		@XMLSTRING,								
--		@certificatePath		= @certificatePath,														
--		@certificatepassword	= @certificatepassword,	
--		@certbinary				= @fisccert,
--		@url					= @url,
--		@schema					= @schema,
--		@returnValue			= '',							--> VLERA QE KERKON TE MARRESH NGA DERGIMI I KERKESES
--		@useSystemProxy         = '',
--		@SIGNEDXML				= @SIGNEDXML OUTPUT,			--> XML E PERGATITUR BASHKE ME SHENJIMIN 
--		@FIC					= @FIC OUTPUT,					--> FIC PER VLEREN E FATURES, NR I SHENJIMIT
--		@ERROR					= @ERROR OUTPUT,				--> 0 -> SKA GABIM 1-> KA GABIM
--		@ERRORtext				= @ERRORtext OUTPUT,				--> MESAZHI I GABIMIT
--		@responseXML			= @responseXML	OUTPUT	

--IF @ERROR=0
--UPDATE LOGARKA SET FISKALIZUAR=1 WHERE NRRENDOR=@pNrRendor
--------------------------------------------------

DECLARE @LNRRENDOR INT,
		@CashAmount FLOAT,
		@CashOperation VARCHAR(50);

SELECT @LNRRENDOR=(SELECT TOP 1 NRRENDOR FROM FisTCR WHERE KODTCR=TCRCODE),
		@CashAmount=VLERA,
		@CashOperation=TIPI
FROM LOGARKA WHERE NRRENDOR=@pNrRendor

EXEC [dbo].[Isd_GatiFiskalCashOperation]  @CashAmount,@CashOperation,@LNRRENDOR 

	
END



GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'Isd_FisNrFiskalizim_2')
DROP PROCEDURE Isd_FisNrFiskalizim_2
GO
CREATE procedure [dbo].[Isd_FisNrFiskalizim_2] 
(
 @pTableName    As Varchar(40),
 @pNrRendor     As Int,
 @pNrFiskalizim As Bigint Output 
)

AS

-- DECLARE @NrFiskalizim   Int;	EXEC dbo.Isd_FisNrFiskalizim 'FJ',0,@NrFiskalizim Output;

     DECLARE @Businunit    As VarchaR(50),
			 @TcrCode	   As VarchaR(50),
             @Datedok      As Datetime,
             @Nr           As Bigint,
		     @Nrd          As Varchar(30),
			 @sTableName   As Varchar(40),
		     @NrRendor     As Int;
 
		 SET @Nr            = 0;
         SET @sTableName    = @pTableName;
		 SET @Nr            = 0;
		 SET @NrRendor      = @pNrRendor


	      IF @sTableName IN ('FJ','FF','SM')
	         BEGIN

                IF @sTableName='FJ'
		           BEGIN
                     SELECT @Datedok = Datedok, @Businunit = FisBusinessunit , @Nrd=NrFiskalizim ,
	                        @TcrCode=(SELECT TOP 1 KODTCR FROM FisTCR A WHERE KOD=FJ.FISTCR)
	                   FROM FJ 
	                  WHERE NrRendor = @NrRendor;

                        SET @Nr = ( 
		                            SELECT  ISNULL(MAX(CONVERT(BIGINT,NrFiskalizim)),0)+1  
		                              FROM 
							               (     SELECT NRFISKALIZIM FROM FJ f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                            AND F.NRRENDOR<>@NrRendor

							                  UNION ALL

							                     SELECT NRFISKALIZIM FROM FF f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok)
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                         -- AND F.NRRENDOR<>@NrRendor

							                  UNION ALL

							                     SELECT NRFISKALIZIM FROM SM f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                         -- AND F.NRRENDOR<>@NrRendor
							                ) AS A
					                ) 

	               END;
  
                IF @sTableName='FF'
		           BEGIN
                     SELECT @Datedok = Datedok, @Businunit = FisBusinessunit , @Nrd=NrFiskalizim ,
	                        @TcrCode=(SELECT TOP 1 KODTCR FROM FisTCR A WHERE KOD=FF.FISTCR)
	                   FROM FF 
	                  WHERE NrRendor = @NrRendor;

                        SET @Nr = ( 
		                            SELECT  ISNULL(MAX(CONVERT(BIGINT,NrFiskalizim)),0)+1  
		                              FROM 
							               (     SELECT NRFISKALIZIM FROM FJ f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                         -- AND F.NRRENDOR<>@NrRendor

							                  UNION ALL

							                     SELECT NRFISKALIZIM FROM FF f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok)
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                            AND F.NRRENDOR<>@NrRendor

							                  UNION ALL

							                     SELECT NRFISKALIZIM FROM SM f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                         -- AND F.NRRENDOR<>@NrRendor
							                ) AS A
					                ) 
	               END;

                IF @sTableName='SM'
		           BEGIN
                     SELECT @Datedok = Datedok, @Businunit = FisBusinessunit , @Nrd=NrFiskalizim ,
	                        @TcrCode=(SELECT TOP 1 KODTCR FROM FisTCR A WHERE KOD=SM.FISTCR)
	                   FROM SM 
	                  WHERE NrRendor = @NrRendor;

                        SET @Nr = ( 
		                            SELECT  ISNULL(MAX(CONVERT(BIGINT,NrFiskalizim)),0)+1  
		                              FROM 
							               (     SELECT NRFISKALIZIM FROM FJ f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                         -- AND F.NRRENDOR<>@NrRendorFj

							                  UNION ALL

							                     SELECT NRFISKALIZIM FROM FF f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok)
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                         -- AND F.NRRENDOR<>@NrRendor

							                  UNION ALL

							                     SELECT NRFISKALIZIM FROM SM f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                            AND F.NRRENDOR<>@NrRendor
							                ) AS A
					                ) 

	               END;


		     END ; 




	      IF @sTableName='FD'
	         BEGIN

               SELECT @Datedok = Datedok, @Businunit = FisBusinessunit , @Nrd=NrFiskalizim
	             FROM FD 
	            WHERE NrRendor = @NrRendor;

                  SET @Nr = ( 
		                      SELECT  ISNULL(MAX(CONVERT(BIGINT,f.NrFiskalizim)),0)+1  
		                        FROM FD f
	                           WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(f.NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							         AND f.FisBusinessunit = @BusinUnit 
							         AND F.NRRENDOR<>@NrRendor
					          ) 
	         END;


         SET @pNrFiskalizim = @Nr;

GO
IF (select count('') FROM CONFIG..TIPDOK where TIPDOK='SKTV' AND KOD='OTHER')=0
INSERT INTO CONFIG..TIPDOK
           ([TIPDOK]
           ,[KOD]
           ,[PERSHKRIM]
           ,[NRORD]
           ,[KODNUM]
           ,[KODTD]
          
           ,[VISIBLE]
           )
SELECT 'SKTV','OTHER',	'Te tjera (Fis)',	'S09',	'0','FJ',1
GO

PRINT 'ALTER Isd_DocSaveFJ '
GO
ALTER Procedure [dbo].[Isd_DocSaveFJ]
(
  @PNrRendor      Int,
  @PIDMStatus     Varchar(10),
  @PSaveMg        Bit,                -- Te hiqet sepse duhet 1 gjithmone...
  @PTableTmpLm    Varchar(40),
  @PPerdorues     Varchar(30),
  @PLgJob         Varchar(30)
 )

As

DECLARE @NRFISKALIZIM INT;
DECLARE @TIPPAGESE VARCHAR(50);
DECLARE @FISTCR VARCHAR(50);

SET @TIPPAGESE=(SELECT top 1 KLASEPAGESE FROM FJ A INNER JOIN FisMenPagese B ON  A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@PNrRendor)
SET @FISTCR=(SELECT top 1 KODTCR FROM FJ A INNER JOIN FisTCR B ON  A.FISTCR=B.KOD WHERE A.NRRENDOR=@PNrRendor)

		IF @PIDMStatus='M'
		  BEGIN
			 -- UPDATE FJ SET FISRELATEDFIC=FISIIC WHERE NRRENDOR=@PNrRendor AND ISNULL(FISRELATEDFIC,'')='';
			  UPDATE FJ SET DATECREATE=GETDATE() WHERE NRRENDOR=@PNrRendor AND ISNULL(FISFIC,'')=''  AND ISNULL(FISIIC,'')='';

		  END

		IF @PIDMStatus='S'
		  BEGIN
			  UPDATE FJ 
			  SET FISFIC='',FISIIC='' --,FISRELATEDFIC=FISIIC,
			  --,
			  --ISDOCFISCAL=CASE WHEN ISNULL(ISDOCFISCAL,0)=1 THEN ISDOCFISCAL 
					--		ELSE 
					--		(SELECT TOP 1 B.ISDOCFISCAL FROM FJ A INNER JOIN KLIENT B ON A.KODFKL=B.KOD
					--		  WHERE A.NRRENDOR=@PNrRendor)
					--		END
			  WHERE NRRENDOR=@PNrRendor AND ISNULL(FISKALIZUAR,0)=0;
		/*	
			 EXEC [dbo].[Isd_FisNrFiskalizim] 'FJ',@PNrRendor,@NRFISKALIZIM OUTPUT
			  
			 IF @TIPPAGESE='BANKE'
			 UPDATE FJ SET  NRDSHOQ=CONVERT(VARCHAR,@NRFISKALIZIM)+'/'+CONVERT(VARCHAR,YEAR(DATEDOK))
			 WHERE NRRENDOR=@PNrRendor 

			 IF @TIPPAGESE<>'BANKE'
			 UPDATE FJ SET  NRDSHOQ=CONVERT(VARCHAR,@NRFISKALIZIM)+'/'+CONVERT(VARCHAR,YEAR(DATEDOK))+'/'+@FISTCR
			 WHERE NRRENDOR=@PNrRendor 
		*/


		  END

-- Njesoj me FF por Tipi='S',Isd_GjenerimFDFromFt dhe ka DokShoqerues.

         SET NOCOUNT ON

          IF ISNULL(@PNrRendor,0)<=0 -- ISNULL(@PTableName,'')<>'FJ' OR ISNULL(@PNrRendor,0)<=0
             RETURN;

     DECLARE @NrRendor       Int,
             @IDMStatus      Varchar(10),
             @TableTmpLm     Varchar(40),
          -- @SaveMg         Bit,       -- Te hiqet sepse duhet 1 gjithmone...
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),
             @TableName      Varchar(30),
             @KodKF          Varchar(30),
             @KMag           Varchar(30),
             @LlogTvsh       Varchar(30),
             @LlogZbr        Varchar(30),
             @LlogArk        Varchar(30),
             @NrMag          Int,
             @NrRndMg        Int,
             @NrRendorFk     Int,
             @AutoPostLmFJ   Bit,
             @Sql            nVarchar(MAX),
             @Transaksion    Varchar(20),
             @Vlere          Float;

         SET @NrRendor     = @PNrRendor;
         SET @IDMStatus    = @PIDMStatus;
         SET @TableTmpLm   = @PTableTmpLm;
      -- SET @SaveMg       = @PSaveMg;            -- Perdoret rasti kur nuk prekete Fd nga Programi,
         SET @Perdorues    = @PPerdorues;         -- por te hiqet sepse duhet 1 gjithmone... 
         SET @LgJob        = @PLgJob;
         SET @TableName    = 'FJ';
         SET @Transaksion  = 'IFMDS';  -- DELETE me F apo D, INSERT me I apo S


          -- Perdore ketu qe ta perdorin edhe Magazina dhe Arka
          IF OBJECT_ID('TempDb..'+@TableTmpLm) IS NOT NULL
             BEGIN
               EXEC ('DROP TABLE '+@TableTmpLm);
             END;

      SELECT @AutoPostLmFJ = CASE WHEN @PTableTmpLm<>'' THEN ISNULL(AUTOPOSTLMFJ,0) ELSE 0 END,
             @LlogTvsh     = LLOGTATS,
             @LlogZbr      = LLOGZBR,
             @LlogArk      = LLOGARK
        FROM CONFIGLM;



--      Test per Kod-e, referenca, kurse etj.
        EXEC dbo.Isd_DocSaveTestFields @TableName,@NrRendor,@IDMStatus;


      SELECT @NrRendorFk   = NRDFK,
             @Vlere        = VLERTOT,
             @KodKF        = KODFKL,
             @KMag         = ISNULL(KMAG,''),
             @NrMag        = ISNULL(NRMAG,0)
        FROM FJ
       WHERE NRRENDOR = @NrRendor;


          IF NOT EXISTS 
             ( SELECT NRRENDOR 
                 FROM FJ A 
                WHERE A.NRRENDOR=@NrRendor AND (ISNULL(A.VLTVSH,0)<>0) AND 
                     (NOT EXISTS (SELECT KOD FROM LLOGARI B WHERE B.KOD=A.LLOGTVSH AND B.POZIC=1)) 
               )
             BEGIN
               UPDATE FJ  SET LLOGTVSH=@LlogTvsh  WHERE NRRENDOR=@NrRendor
             END;

          IF NOT EXISTS 
             ( SELECT NRRENDOR 
                 FROM FJ A 
                WHERE A.NRRENDOR=@NrRendor AND (ISNULL(A.VLERZBR,0)<>0) AND 
                     (NOT EXISTS (SELECT KOD FROM LLOGARI B WHERE B.KOD=A.LLOGZBR AND B.POZIC=1)) 
               )
             BEGIN
               UPDATE FJ  SET LLOGZBR =@LlogZbr  WHERE NRRENDOR=@NrRendor
             END;

          IF NOT EXISTS 
             ( SELECT NRRENDOR 
                 FROM FJ A 
                WHERE A.NRRENDOR=@NrRendor AND (ISNULL(A.PARAPG,0)<>0) AND (ISNULL(A.KODARK,'')='') AND 
                     (NOT EXISTS (SELECT KOD FROM LLOGARI B WHERE B.KOD=A.LLOGARK AND B.POZIC=1)) 
               )
             BEGIN
               UPDATE FJ  SET LLOGARK =@LlogArk  WHERE NRRENDOR=@NrRendor
             END;

      UPDATE A 
         SET KONVERTART = ROUND(CASE WHEN ISNULL(B.KONV2,1)*ISNULL(B.KONV1,1)<=0 
                                     THEN 1 
                                     ELSE ISNULL(B.KONV2,1)/ISNULL(B.KONV1,1) END,3) 
        FROM FJSCR A INNER JOIN ARTIKUJ B On A.KARTLLG=B.KOD
       WHERE NRD=@NrRendor;


      UPDATE A
         SET A.AGJENTSHITJELINK = ISNULL(B.KODMASTER,'')
        FROM FJ A INNER JOIN AGJENTSHITJE B ON ISNULL(A.KLASIFIKIM,'')=B.KOD
       WHERE A.NRRENDOR=@NrRendor;



--           Korigjimi i koeficenteve dhe vlerave per bonuse te Klient/Agjent sipas kategori artikuj

--           Ne se do te duhej te perdoret ne program atehere perpara BeforePost (ose RegjistrimSCR) perdor store procedure Isd_ArtikujKtgAgjKlGetVlere
--           Shiko ne program proceduren SysF5Sql.GetVleraArtikujKtgAgjKl(pTable,pDataSet);

          IF OBJECT_ID('TempDB..#TempKtgAgjKL') IS NOT NULL
             DROP TABLE #TempKtgAgjKL;

      SELECT NRRENDOR, KARTLLG, 
             KOEFICENTARTAGJ = MAX(KOEFICENTARTAGJ), 
             KOEFICENTARTKL  = MAX(KOEFICENTARTKL)  

         INTO #TempKtgAgjKL     
         FROM

            (    
                SELECT A.NRRENDOR, KARTLLG = B.KARTLLG, KOEFICENTARTAGJ = MAX(R32.VLEFTE), KOEFICENTARTKL = 0 
                  FROM FJ A  INNER JOIN FJSCR            B   ON A.NRRENDOR=B.NRD
                             INNER JOIN ARTIKUJ          R1  ON B.KARTLLG=R1.KOD AND ISNULL(R1.APLKATEGORIAGJ,0)=1
                             INNER JOIN ARTIKUJKTG       R2  ON ISNULL(R1.KATEGORI,'')=R2.KOD AND ISNULL(R2.NOTACTIV,0)=0
                             INNER JOIN ARTIKUJKTGAGJSCR R32 ON R32.KOD=ISNULL(A.KLASIFIKIM,'') AND R32.KODAF=R2.KOD
                             INNER JOIN ARTIKUJKTGAGJ    R31 ON R31.NRRENDOR=R32.NRD AND ISNULL(R31.ACTIV,0)=0
                 WHERE A.NRRENDOR=@NrRendor AND B.TIPKLL='K' AND ISNULL(A.KLASIFIKIM,'')<>''
              GROUP BY A.NRRENDOR,B.KARTLLG

             UNION ALL  

                SELECT A.NRRENDOR, KARTLLG = B.KARTLLG, KOEFICENTARTAGJ = 0, KOEFICENTARTKL = MAX(R32.VLEFTE) 
                  FROM FJ A  INNER JOIN FJSCR            B   ON A.NRRENDOR=B.NRD
                             INNER JOIN ARTIKUJ          R1  ON B.KARTLLG=R1.KOD AND ISNULL(R1.APLKATEGORIKL,0)=1
                             INNER JOIN ARTIKUJKTG       R2  ON ISNULL(R1.KATEGORI,'')=R2.KOD AND ISNULL(R2.NOTACTIV,0)=0
                             INNER JOIN ARTIKUJKTGKLSCR  R32 ON R32.KOD=A.KODFKL AND R32.KODAF=R2.KOD
                             INNER JOIN ARTIKUJKTGKL     R31 ON R31.NRRENDOR=R32.NRD AND ISNULL(R31.ACTIV,0)=0
                 WHERE A.NRRENDOR=@NrRendor AND B.TIPKLL='K' 
              GROUP BY A.NRRENDOR,B.KARTLLG

              ) A

    GROUP BY NRRENDOR,KARTLLG          
    ORDER BY NRRENDOR,KARTLLG;

      UPDATE A
         SET KOEFICENTARTAGJ = ISNULL(B.KOEFICENTARTAGJ,0), --VLERAARTAGJ = ISNULL(B.KOEFICENTARTAGJ,0) * A.VLPATVSH,
             KOEFICENTARTKL  = ISNULL(B.KOEFICENTARTKL,0)   --VLERAARTKL  = ISNULL(B.KOEFICENTARTKL, 0) * A.VLPATVSH
        FROM FJSCR A LEFT JOIN #TempKtgAgjKL B ON A.NRD=B.NRRENDOR AND A.KARTLLG=B.KARTLLG
       WHERE A.NRD=@NrRendor AND A.TIPKLL='K'; 


          IF OBJECT_ID('TempDB..#TempKtgAgjKL') IS NOT NULL
             DROP TABLE #TempKtgAgjKL;

-- Fund      Korigjimi i koeficentave dhe vlerave per bonuse te Klient/Agjent sipas kategori artikuj            





-- 1.
        EXEC dbo.Isd_GjenerimDitarOne @TableName, 0, @NrRendor;


-- 2.
          IF CHARINDEX(@IDMStatus,@Transaksion)>0  -- DELETE me F apo D, INSERT me I apo S
             EXEC dbo.Isd_AppendTransLog @TableName,@NrRendor,@Vlere,@IDMStatus,@Perdorues,@LgJob;

     -- Postimi shiko me poshte -- Ketu le te behet fshirja ....
          IF @NrRendorFk>=1
             BEGIN
               EXEC dbo.LM_DelFk @NrRendorFk;
             END;
     -- Postimi shiko me poshte 


-- 3.1
       -- IF @SaveMg=1  -- Gjithmone ..... dallimi behet brenda tek    dbo.Isd_GjenerimFDFromFt
             EXEC Isd_GjenerimFDFromFt      @NrRendor,@Perdorues,@LgJob;

-- 3.2
       -- IF @SaveMg=1  -- Gjithmone ..... dallimi behet brenda tek    dbo.Isd_GjenerimFhFromFtAmb
             EXEC Isd_GjenerimFHFromFtAmb   @NrRendor,@Perdorues,@LgJob;

-- 3.3
             EXEC Isd_GjenerimAQFromFt 'FJ',@NrRendor,@Perdorues,@LgJob;

-- 4.
     -- FJ - DokShoq:  Fillim'

          IF NOT EXISTS (SELECT * FROM FJSHOQERUES WHERE NRD=@NrRendor)
             BEGIN

               INSERT  INTO FJSHOQERUES
                      (NRD,[DATE],[TIME])
               VALUES (@NrRendor,GETDATE(),dbo.Isd_DateTimeServer ('T'));

               UPDATE A 
                  SET A.NIPT            = B.NIPT,
                      A.NIPTCERTIFIKATE = B.NIPTCERTIFIKATE,
                      A.KODFISKAL       = B.KODFISKAL,
                      A.NRLICENCE       = B.NRLICENCE,
                      A.TARGE           = B.TARGE,
                      A.MJET            = B.MJET,
                      A.KOMPANI         = B.KOMPANI,
                      A.TRANSPORTUES    = B.PERSHKRIM,
                      A.SHENIM1         = B.ADRESA1,
                      A.SHENIM2         = B.ADRESA2,
                      A.SHENIM3         = B.ADRESA3,
                      A.TELEFON1        = B.TELEFON1,
                      A.TELEFON2        = B.TELEFON2,
                      A.FAX             = B.FAX 
                 FROM FJSHOQERUES A, TRANSPORT B
                WHERE A.NRD = @NrRendor AND B.LINKKLIENT = @KodKF;

             END;
     -- FJ - DokShoq:  Fund'


-- 5.

     -- FJ - Dokument Arke: Fillim

        EXEC dbo.Isd_DocumentArkeFromFt @TableName,0,@NrRendor,@Perdorues,@LgJob;

     -- FJ - Dokument Arke: Fund


-- 6.

     -- FJ - Kalimi ne Lm: Fillim

     --   IF @NrRendorFk>=1
     --      EXEC dbo.LM_DelFk @NrRendorFk;

          IF @NrRendorFk>=1
             BEGIN
               IF ISNULL(@AutoPostLmFJ,0)=1
                  BEGIN
                    DELETE FROM FKSCR     WHERE NrD=@NrRendorFk
                  END 
               ELSE
                  BEGIN
                    DELETE FROM FK        WHERE NrRendor=@NrRendorFk;
                    UPDATE FJ SET NRDFK=0 WHERE NRRENDOR=@NrRendor;

                    RETURN;

                  END;
             END;

          IF ISNULL(@AutoPostLmFJ,0)=0 OR @TableTmpLm=''
             RETURN;

--        Jo ketu fshirja sepse mund te perdoret nga Arka ose magazina ....
--        IF OBJECT_ID('TempDb..'+@TableTmpLm) IS NOT NULL
--           EXEC ('DROP TABLE '+@TableTmpLm);

        EXEC [Isd_KalimLM] @PTip='S', @PNrRendor=@NrRendor, @PSQLFilter='', @PTableNameTmp=@TableTmpLm; 

     -- FJ - Kalimi ne Lm: Fund 

/*                   PJESA TEST TEPER E RENDESISHME
  DECLARE @NrRendor Int
      SET @NrRendor=567717

   SELECT T01Dok='FJ-Fj     ',* FROM Fj          WHERE NrRendor =@NrRendor;
   SELECT T02Dok='FJ-FjRow  ',* FROM FjScr       WHERE Nrd      =@NrRendor;
   SELECT T03Dok='FJ-Tr     ',* FROM FJSHOQERUES WHERE Nrd      =@NrRendor;
   SELECT T04Dok='FJ-Pg     ',* FROM FJPG        WHERE Nrd      =@NrRendor;
   SELECT T05Dok='FJ-FjDt   ',* FROM DKL         WHERE NrRendor =(SELECT NRDITAR    FROM Fj WHERE NrRendor=@NrRendor);

   SELECT T06Dok='FJ-Fd     ',* FROM FD          WHERE NrRendor =(SELECT NRRENDDMG  FROM Fj WHERE NrRendor=@NrRendor);
   SELECT T07Dok='FJ-FdRow  ',* FROM FDScr       WHERE Nrd      =(SELECT NRRENDDMG  FROM Fj WHERE NrRendor=@NrRendor);

   SELECT T08Dok='FJ-Ar     ',* FROM Arka        WHERE NrRendor =(SELECT NRRENDORAR FROM Fj WHERE NrRendor=@NrRendor);
   SELECT T09Dok='FJ-ArRow  ',* FROM ArkaScr     WHERE Nrd      =(SELECT NRRENDORAR FROM Fj WHERE NrRendor=@NrRendor);
   SELECT T10Dok='FJ-ArDt   ',* FROM DAR         WHERE NrRendor =(SELECT NRDITAR 
                                                                    FROM Arka
                                                                   WHERE NrRendor=(SELECT NRRENDORAR FROM Fj WHERE NrRendor=@NrRendor));
-- Fk-Fj
   SELECT T11Dok='FJ-Fk     ',* FROM FK          WHERE NrRendor =(SELECT NRDFK      FROM Fj WHERE NrRendor=@NrRendor);
   SELECT T12Dok='FJ-FkRow  ',* FROM FKScr       WHERE Nrd      =(SELECT NRDFK      FROM Fj WHERE NrRendor=@NrRendor);
-- Fk-Fd
   SELECT T13Dok='FJ-FdFk   ',* FROM FK          WHERE NrRendor =(SELECT NRDFK 
                                                                    FROM FD
                                                                   WHERE NrRendor=(SELECT NRRENDDMG  FROM Fj WHERE NrRendor=@NrRendor));
   SELECT T14Dok='FJ-FdFkRow',* FROM FKScr       WHERE Nrd      =(SELECT NRDFK 
                                                                    FROM FD
                                                                   WHERE NrRendor=(SELECT NRRENDDMG  FROM Fj WHERE NrRendor=@NrRendor));
-- Fk-Arka
   SELECT T15Dok='FJ-ArFk   ',* FROM FK          WHERE NrRendor =(SELECT NRDFK 
                                                                    FROM Arka
                                                                   WHERE NrRendor =(SELECT NRRENDORAR FROM Fj WHERE NrRendor=@NrRendor));
   SELECT T16Dok='FJ-ArFkRow',* FROM FKScr       WHERE Nrd      =(SELECT NRDFK 
                                                                    FROM Arka
                                                                   WHERE NrRendor =(SELECT NRRENDORAR FROM Fj WHERE NrRendor=@NrRendor));
*/

GO

ALTER Procedure [dbo].[Isd_DocSaveFF]
(
  @PNrRendor      Int,
  @PIDMStatus     Varchar(10),
  @PSaveMg        Bit,
  @PTableTmpLm    Varchar(40),
  @PPerdorues     Varchar(30),
  @PLgJob         Varchar(30)
 )

As

-- Njesoj me FJ por Tipi='F',Isd_GjenerimFHFromFt dhe ska DokShoqerues.

         Set NoCount On

          if IsNull(@PNrRendor,0)<=0 -- IsNull(@PTableName,'')<>'FF' or IsNull(@PNrRendor,0)<=0
             Return;

		  IF @PIDMStatus='M'
		     BEGIN
			   UPDATE FF 
			      SET ISDOCFISCAL=CASE WHEN  KLASETVSH IN ('DOMESTIC','ABROAD','FANG','AGREEMENT','OTHER') THEN 1 ELSE 0 END 
			    WHERE NRRENDOR=@PNrRendor AND ISNULL(FISRELATEDFIC,'')='';
		     END

		IF @PIDMStatus='S'
		  BEGIN
			  UPDATE FF 
			     SET FISFIC='',FISIIC=''--,FISRELATEDFIC=FISIIC
				 ,ISDOCFISCAL=CASE WHEN  KLASETVSH IN ('DOMESTIC','ABROAD','FANG','AGREEMENT','OTHER') THEN 1 ELSE 0 END
			   WHERE NRRENDOR=@PNrRendor AND ISNULL(FISKALIZUAR,0)=0;
		  END;

     Declare @NrRendor       Int,
             @IDMStatus      Varchar(10),
             @TableTmpLm     Varchar(40),
             @SaveMg         Bit,
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),
             @TableName      Varchar(30),
             @KMag           Varchar(30),
             @NrMag          Int,
             @NrRndMg        Int,
             @NrRendorFk     Int,
             @AutoPostLmFF   Bit,
             @Sql            nVarchar(Max),
             @Transaksion    Varchar(20),
             @Vlere          Float;

         Set @NrRendor     = @PNrRendor;
         Set @IDMStatus    = @PIDMStatus;
         Set @TableTmpLm   = @PTableTmpLm;
         Set @SaveMg       = @PSaveMg;   -- Perdoret rasti kur nuk prekete Fh nga Programi
         Set @Perdorues    = @PPerdorues;
         Set @LgJob        = @PLgJob;
         Set @TableName    = 'FF';
         Set @Transaksion  = 'IFMDS';  -- Delete me F apo D, Insert me I apo S


          -- Perdore ketu qe ta perdorin edhe Magazina dhe Arka
          if Object_Id('TempDb..'+@TableTmpLm) is not null
             Exec ('DROP TABLE '+@TableTmpLm);

      Select @AutoPostLmFF = Case When @PTableTmpLm<>'' Then IsNull(AUTOPOSTLMFF,0) Else 0 End
        From CONFIGLM;
              

--      Test per Kod-e, referenca, kurse etj.
        Exec dbo.Isd_DocSaveTestFields @TableName,@NrRendor,@IDMStatus;


      Select @NrRendorFk   = NRDFK,
             @Vlere        = VLERTOT,
             @KMag         = IsNull(KMAG,''),
             @NrMag        = IsNull(NRMAG,0)  
        From FF
       Where NRRENDOR = @NrRendor;

      Update A 
         Set KONVERTART = Round(Case When IsNull(B.KONV2,1)*IsNull(B.KONV1,1)<=0 
                                     Then 1 
                                     Else IsNull(B.KONV2,1)/IsNull(B.KONV1,1) End,3) 
        From FFSCR A INNER JOIN ARTIKUJ B On A.KARTLLG=B.KOD
       Where A.NRD=@NrRendor And A.TIPKLL='K';

      Update B 
         Set B.DATELASTBL = A.DATEDOK,
             B.CMB        = Case When IsNull(A.KMON,'')='' OR (A.KURS1=1 AND A.KURS2=1) OR (A.KURS1*A.KURS2<=0)
                                 Then A1.CMIMBS
                                 Else Round((A1.CMIMBS*A.KURS2)/A.KURS1,4)
                            End
        From FF A INNER JOIN FFSCR   A1 ON A.NRRENDOR=A1.NRD
                  INNER JOIN ARTIKUJ B  ON A1.KARTLLG=B.KOD
       Where A1.NRD=@NrRendor And A1.TIPKLL='K' AND IsNull(B.UPDATELASTBL,0)=1 And IsNull(B.DATELASTBL,0)<=A.DATEDOK;



-- 1.
        Exec dbo.Isd_GjenerimDitarOne @TableName, 0, @NrRendor;
-- 2.
          if CharIndex(@IDMStatus,@Transaksion)>0  
             Exec dbo.Isd_AppendTransLog @TableName,@NrRendor,@Vlere,@IDMStatus,@Perdorues,@LgJob;

     -- Postimi shiko me poshte -- Ketu le te behet fshirja ....
          if @NrRendorFk>=1
             Exec dbo.LM_DelFk @NrRendorFk;
     -- Postimi shiko me poshte 

-- 3.
          if @SaveMg=1
             BEGIN
               Exec Isd_GjenerimFHFromFt      @NrRendor,@Perdorues,@LgJob;
               EXEC Isd_GjenerimAQFromFt 'FF',@NrRendor,@Perdorues,@LgJob;
             END;  

-- 4.
     -- FF - DokShoq:  Fillim'

/*        if Not Exists (Select * 
                           From FJSHOQERUES 
                          Where NRD=@NrRendor)
             begin
               
               Insert  Into FJSHOQERUES
                      (NRD,[DATE],[TIME])
               Values (@NrRendor,GetDate(),dbo.Isd_DateTimeServer ('T'));

               UpDate A 
                  Set A.NIPT            = B.NIPT,
                      A.NIPTCERTIFIKATE = B.NIPTCERTIFIKATE,
                      A.KODFISKAL       = B.KODFISKAL,
                      A.NRLICENCE       = B.NRLICENCE,
                      A.TARGE           = B.TARGE,
                      A.MJET            = B.MJET,
                      A.KOMPANI         = B.KOMPANI,
                      A.TRANSPORTUES    = B.PERSHKRIM,
                      A.SHENIM1         = B.ADRESA1,
                      A.SHENIM2         = B.ADRESA2,
                      A.SHENIM3         = B.ADRESA3,
                      A.TELEFON1        = B.TELEFON1,
                      A.TELEFON2        = B.TELEFON2,
                      A.FAX             = B.FAX 
                 From FJSHOQERUES A, TRANSPORT B
                Where A.NRD = @NrRendor And B.LINKKLIENT = @KodKF;

             end;
*/
     -- FF - DokShoq:  Fund'


-- 5.

     -- FF - Dokument Arke: Fillim

        Exec dbo.Isd_DocumentArkeFromFt @TableName,0,@NrRendor,@Perdorues,@LgJob;

     -- FF - Dokument Arke: Fund


-- 6.

     -- FF - Kalimi ne Lm: Fillim

     --   if @NrRendorFk>=1
     --      Exec dbo.LM_DelFk @NrRendorFk;

          if @NrRendorFk>=1
             begin
               if IsNull(@AutoPostLmFF,0)=1
                  begin
                    Delete 
                      From FKSCR 
                     Where NrD = @NrRendorFk
                  end 
               else
                  begin
                    Delete 
                      From FK 
                     Where NrRendor=@NrRendorFk;

                    Update FF
                       Set NRDFK=0
                     Where NRRENDOR = @NrRendor;

                    Return;
                  end;
             end;

          if IsNull(@AutoPostLmFF,0)=0 Or @TableTmpLm=''
             Return;

--        Jo ketu fshirja sepse mund te perdoret nga Arka ose magazina ....
--        if Object_Id('TempDb..'+@TableTmpLm) is not null
--           Exec ('DROP TABLE '+@TableTmpLm);

        Exec [Isd_KalimLM] @PTip='F', @PNrRendor=@NrRendor, @PSQLFilter='', @PTableNameTmp=@TableTmpLm; 

     -- FF - Kalimi ne Lm: Fund 

/*                   PJESA TEST TEPER E RENDESISHME
  Declare @NrRendor Int
      Set @NrRendor=44749

   Select T01Dok='FF-Ff     ',* from Ff          Where NrRendor =@NrRendor;
   Select T02Dok='FF-FfRow  ',* from FfScr       Where Nrd      =@NrRendor;
-- Select T03Dok='FF-Tr     ',* From FJSHOQERUES Where Nrd      =@NrRendor;
-- Select T04Dok='FF-Pg     ',* From FJPG        Where Nrd      =@NrRendor;
   Select T05Dok='FF-FfDt   ',* From DKL         Where NrRendor =(Select NRDITAR    From Ff Where NrRendor=@NrRendor);

   Select T06Dok='FF-Fh     ',* From FH          Where NrRendor =(Select NRRENDDMG  From Ff Where NrRendor=@NrRendor);
   Select T07Dok='FF-FhRow  ',* From FHScr       Where Nrd      =(Select NRRENDDMG  From Ff Where NrRendor=@NrRendor);

   Select T08Dok='FF-Ar     ',* From Arka        Where NrRendor =(Select NRRENDORAR From Ff Where NrRendor=@NrRendor);
   Select T09Dok='FF-ArRow  ',* From ArkaScr     Where Nrd      =(Select NRRENDORAR From Ff Where NrRendor=@NrRendor);
   Select T10Dok='FF-ArDt   ',* From DAR         Where NrRendor =(Select NRDITAR 
                                                                    From Arka
                                                                   Where NrRendor=(Select NRRENDORAR From Ff Where NrRendor=@NrRendor));
-- Fk-Ff
   Select T11Dok='FF-Fk     ',* From FK          Where NrRendor =(Select NRDFK      From Ff Where NrRendor=@NrRendor);
   Select T12Dok='FF-FkRow  ',* From FKScr       Where Nrd      =(Select NRDFK      From Ff Where NrRendor=@NrRendor);
-- Fk-Fh
   Select T13Dok='FF-FhFk   ',* From FK          Where NrRendor =(Select NRDFK 
                                                                    From FH
                                                                   Where NrRendor=(Select NRRENDDMG  From Ff Where NrRendor=@NrRendor));
   Select T14Dok='FF-FhFkRow',* From FKScr       Where Nrd      =(Select NRDFK 
                                                                    From FH
                                                                   Where NrRendor=(Select NRRENDDMG  From Ff Where NrRendor=@NrRendor));
-- Fk-Arka
   Select T15Dok='FF-ArFk   ',* From FK          Where NrRendor =(Select NRDFK 
                                                                    From Arka
                                                                   Where NrRendor =(Select NRRENDORAR From Ff Where NrRendor=@NrRendor));
   Select T16Dok='FF-ArFkRow',* From FKScr       Where Nrd      =(Select NRDFK 
                                                                    From Arka
                                                                   Where NrRendor =(Select NRRENDORAR From Ff Where NrRendor=@NrRendor));
*/

GO


GO

ALTER PROCEDURE [dbo].[Isd_GatiFiskal]
(
 @pNrRendor Integer
)
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @TEMPOUTPUT VARCHAR(MAX)
	DECLARE @ERRORFISC VARCHAR(MAX)
	DECLARE @OUTPUT1 VARCHAR(MAX)
	DECLARE @OUTPUT2 VARCHAR(MAX)
	DECLARE @OUTPUT3 VARCHAR(MAX)
	DECLARE @OUTMESSAGE VARCHAR(MAX)
	DECLARE @TIPPAGESE VARCHAR(MAX)
	DECLARE @TIPKLIENT VARCHAR(MAX)
	DECLARE @SELF VARCHAR(MAX)
	DECLARE @NIPT VARCHAR(MAX)
	DECLARE @FISFIC VARCHAR(MAX)

	DECLARE @TCRCODE VARCHAR(50)

	SET @TCRCODE=(SELECT TOP 1 KODTCR FROM FJ A INNER JOIN FisTCR B ON A.FISTCR=B.KOD WHERE A.NRRENDOR=@pNrRendor)

	IF ISNULL(@TCRCODE,'')<>''
	EXEC [dbo].[ISD_GATIFISKALOFFLINE_ARKA] @TCRCODE


	SET @ERRORFISC=(SELECT TOP 1 FISLASTERRORFIC FROM FJ WHERE NRRENDOR=@pNrRendor)
	IF ISNULL(@ERRORFISC,'')='70'
	BEGIN
		SET @OUTPUT1='Kjo fature mund te jete fiskalizuar, ju lutem kontrollojeni ne portalin Self Care'
		SET @OUTPUT2=''
		set @OUTMESSAGE = 'Gabim!!! Gjate fiskalizimit heren e pare ka ndodhur time out....'+char(10)+ char(13)+@OUTPUT1
		select @OUTPUT1 AS KodError1,@OUTPUT2 AS KodError2,@OUTMESSAGE AS MsgError
		RETURN;
	END

	SET @FISFIC=(SELECT ISNULL(FISFIC,'') FROM FJ WHERE NRRENDOR=@pNrRendor)
	SET @NIPT=(SELECT NIPT FROM CONFND)
	SET @TEMPOUTPUT=''

	SET @TIPPAGESE=(SELECT top 1 KLASEPAGESE FROM FJ A INNER JOIN FisMenPagese B ON  A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@pNrRendor)
	SET @TIPKLIENT=(SELECT top 1 ISNULL(A.TIPNIPT,'')  FROM FJ A INNER JOIN KLIENT B ON A.KODFKL=B.KOD WHERE A.NRRENDOR=@pNrRendor)
	SET @SELF=(SELECT CASE WHEN ISNULL(A.KLASETVSH,'') IN ('SANG','SELF','SEXP','OTHER') THEN  A.KLASETVSH
							ELSE  NULL END FROM FJ A WHERE A.NRRENDOR=@pNrRendor)
	

	IF @TIPPAGESE='BANKE' AND @TIPKLIENT='NUIS' AND @SELF IS NULL
	BEGIN	
		IF EXISTS(SELECT 1 FROM FJ WHERE NRRENDOR = @pNrRendor   
		AND ISNULL(FISEIC,'')<>'')
			BEGIN
				SET @OUTPUT1='0'
				SET @OUTPUT2='0'
			END
			ELSE
			BEGIN
				
					if @FISFIC=''
					begin
					EXEC Isd_Fiscal_FIC @pNrRendor,1,@OUTPUT1 OUTPUT
					SET @OUTPUT1=ISNULL(@OUTPUT1,'')
					--print 'nuk duhet te hyje'
					end
					ELSE
					SET @OUTPUT1='0'--ISNULL(@OUTPUT1,'errrrrr')
				
					IF @OUTPUT1 <> '0'
						SET @TEMPOUTPUT = ISNULL(@OUTPUT1,'') + char(10)+char(13)

				SET @FISFIC=(SELECT FISFIC FROM FJ WHERE NRRENDOR=@pNrRendor)
				IF ISNULL(@FISFIC,'')<>''
				EXEC Isd_Fiscal_EIC @pNrRendor,1,@OUTPUT2 OUTPUT
				ELSE
				SET @OUTPUT2=0

				IF @OUTPUT2 <> '0'
					SET @TEMPOUTPUT = @TEMPOUTPUT+ ISNULL(@OUTPUT2,'') + char(10)+char(13)

				IF @OUTPUT2 LIKE '%Einvoice with that FIC is allready received%'
				SET @OUTPUT2='0'

				IF @OUTPUT2 LIKE '%Invoice is not fiscalized.%'
				SET @OUTPUT2='0'
			END
						
	END
	ELSE
		BEGIN
				IF EXISTS(SELECT 1 FROM FJ WHERE NRRENDOR = @pNrRendor 
						   AND FISLASTERRORFIC = '0' AND  ISNULL(FISFIC, '') != '' )	
					BEGIN
						Update Fj set FISKALIZUAR=1,NRSERIAL=FISFIC,FISSTATUS='FISKALIZUAR'
						where NRRENDOR = @pNrRendor  and isnull(FISKALIZUAR,0)=0
						
						SET @OUTPUT1='0'
						SET @OUTPUT2='0'
						
					END
					ELSE
						BEGIN
									
									
									EXEC Isd_Fiscal_FIC @pNrRendor,0,@OUTPUT1 OUTPUT
									SET @OUTPUT1=@OUTPUT1;
									SET @OUTPUT2='0'

									IF ISNULL(@OUTPUT1,'') <> '0'
										SET @TEMPOUTPUT = ISNULL(@OUTPUT1,'') + char(10)+char(13)
						END

		END
		

	if  (ISNULL(@OUTPUT1,'0')='0' and ISNULL(@OUTPUT2,'0')='0')
	set @OUTMESSAGE=''
	ELSE
	set @OUTMESSAGE = 'Gabim gjate procesit te deklarimit tatime....'+char(10)+ char(13) + @TEMPOUTPUT


	select @OUTPUT1 AS KodError1,@OUTPUT2 AS KodError2,@OUTMESSAGE AS MsgError
	
END



GO

ALTER procedure [dbo].[Isd_FisNrFiskalizim] 
(
 @pTableName    As Varchar(40),
 @pNrRendor     As Int,
 @pNrFiskalizim As Bigint Output 
)

AS

-- DECLARE @NrFiskalizim   Int;	EXEC dbo.Isd_FisNrFiskalizim 'FJ',0,@NrFiskalizim Output;

     DECLARE @Businunit    As VarchaR(50),
			 @TcrCode	   As VarchaR(50),
             @Datedok      As Datetime,
             @Nr           As Bigint,
		     @Nrd          As Varchar(30),
			 @sTableName   As Varchar(40),
		     @NrRendor     As Int,
			 @FisTipdok	   As Varchar(50);
 
		 SET @Nr            = 0;
         SET @sTableName    = @pTableName;
		 SET @Nr            = 0;
		 SET @NrRendor      = @pNrRendor


	      IF @sTableName IN ('FJ','FF','SM')
	         BEGIN

                IF @sTableName='FJ'
		           BEGIN
                     SELECT @Datedok = Datedok, @Businunit = FisBusinessunit , @Nrd=NrFiskalizim ,
	                        @TcrCode=(SELECT TOP 1 KODTCR FROM FisTCR A WHERE KOD=FJ.FISTCR)
	                   FROM FJ 
	                  WHERE NrRendor = @NrRendor;

                        SET @Nr = ( 
		                            SELECT  ISNULL(MAX(CONVERT(BIGINT,NrFiskalizim)),0)+1  
		                              FROM 
							               (     SELECT NRFISKALIZIM FROM FJ f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                            AND F.NRRENDOR<>@NrRendor

							                  UNION ALL

							                     SELECT NRFISKALIZIM FROM FF f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok)
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                         -- AND F.NRRENDOR<>@NrRendor

							                  UNION ALL

							                     SELECT NRFISKALIZIM FROM SM f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                         -- AND F.NRRENDOR<>@NrRendor
							                ) AS A
					                ) 

	               END;
  
                IF @sTableName='FF'
		           BEGIN
                     SELECT @Datedok = Datedok, @Businunit = FisBusinessunit , @Nrd=NrFiskalizim ,
	                        @TcrCode=(SELECT TOP 1 KODTCR FROM FisTCR A WHERE KOD=FF.FISTCR)
	                   FROM FF 
	                  WHERE NrRendor = @NrRendor;

                        SET @Nr = ( 
		                            SELECT  ISNULL(MAX(CONVERT(BIGINT,NrFiskalizim)),0)+1  
		                              FROM 
							               (     SELECT NRFISKALIZIM FROM FJ f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                         -- AND F.NRRENDOR<>@NrRendor

							                  UNION ALL

							                     SELECT NRFISKALIZIM FROM FF f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok)
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                            AND F.NRRENDOR<>@NrRendor

							                  UNION ALL

							                     SELECT NRFISKALIZIM FROM SM f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                         -- AND F.NRRENDOR<>@NrRendor
							                ) AS A
					                ) 
	               END;

                IF @sTableName='SM'
		           BEGIN
                     SELECT @Datedok = Datedok, @Businunit = FisBusinessunit , @Nrd=NrFiskalizim ,
	                        @TcrCode=(SELECT TOP 1 KODTCR FROM FisTCR A WHERE KOD=SM.FISTCR)
	                   FROM SM 
	                  WHERE NrRendor = @NrRendor;

                        SET @Nr = ( 
		                            SELECT  ISNULL(MAX(CONVERT(BIGINT,NrFiskalizim)),0)+1  
		                              FROM 
							               (     SELECT NRFISKALIZIM FROM FJ f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                         -- AND F.NRRENDOR<>@NrRendorFj

							                  UNION ALL

							                     SELECT NRFISKALIZIM FROM FF f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok)
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                         -- AND F.NRRENDOR<>@NrRendor

							                  UNION ALL

							                     SELECT NRFISKALIZIM FROM SM f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                              WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							                            AND f.FisBusinessunit = @BusinUnit 
			                                            AND T.KODTCR=@TcrCode 
							                            AND F.NRRENDOR<>@NrRendor
							                ) AS A
					                ) 

	               END;

/*
               SET @Nr = ( 
		                   SELECT  ISNULL(MAX(CONVERT(BIGINT,NrFiskalizim)),0)+1  
		                     FROM 
							      (    SELECT NRFISKALIZIM FROM FJ f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                    WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 
							                  AND f.FisBusinessunit = @BusinUnit 
			                                  AND T.KODTCR=@TcrCode 
							                  AND YEAR(Datedok)=YEAR(@Datedok) 
							                  AND F.NRRENDOR<>@NrRendor

							        UNION ALL

							           SELECT NRFISKALIZIM FROM FF f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                    WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 
							                  AND f.FisBusinessunit = @BusinUnit 
			                                  AND T.KODTCR=@TcrCode 
							                  AND YEAR(Datedok)=YEAR(@Datedok) 
							                  AND F.NRRENDOR<>@NrRendor

							        UNION ALL

							           SELECT NRFISKALIZIM FROM SM f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                    WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 
							                  AND f.FisBusinessunit = @BusinUnit 
			                                  AND T.KODTCR=@TcrCode 
							                  AND YEAR(Datedok)=YEAR(@Datedok) 
							                  AND F.NRRENDOR<>@NrRendor
							       ) AS A
					       )
						   */
		     END ; 




	      IF @sTableName='FD'
	         BEGIN

               SELECT @Datedok = Datedok, @Businunit = FisBusinessunit , @Nrd=NrFiskalizim,@FisTipdok=FISTIPDOK
	             FROM FD 
	            WHERE NrRendor = @NrRendor;

				if @FisTipdok='TI'
                  SET @Nr = ( 
		                      SELECT  ISNULL(MAX(CONVERT(BIGINT,f.NrFiskalizim)),0)+1  
		                        FROM FD f
	                           WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(f.NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							         AND f.FisBusinessunit = @BusinUnit and f.FISTIPDOK='TI'
							         AND F.NRRENDOR<>@NrRendor
					          ) 
				ELSE
				 SET @Nr = ( 
		                      SELECT  ISNULL(MAX(CONVERT(BIGINT,f.NrFiskalizim)),0)+1  
		                        FROM FD f
	                           WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(f.NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							         AND f.FisBusinessunit = @BusinUnit and ISNULL(f.FISTIPDOK,'')<>'TI'
							         AND F.NRRENDOR<>@NrRendor
					          ) 
				
	         END;



/*
	      IF @sTableName= 'SM'
	         BEGIN

               SELECT @Datedok = Datedok, @Businunit = FisBusinessunit , @Nrd=NrFiskalizim ,
	                  @TcrCode=(SELECT TOP 1 KODTCR FROM FisTCR A WHERE KOD=SM.FISTCR)
	             FROM SM 
	            WHERE NrRendor = @NrRendor;
	
                  SET @Nr = ( 
		                      SELECT  ISNULL(MAX(CONVERT(BIGINT,NrFiskalizim)),0)+1  
		                        FROM SM f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                           WHERE ISNULL(f.isDocFiscal,0)=1 AND ISNUMERIC(NrFiskalizim)=1 AND YEAR(Datedok)=YEAR(@Datedok) 
							         AND f.FisBusinessunit = @BusinUnit 
			                         AND T.KODTCR=@TcrCode 
							         AND F.NRRENDOR<>@NrRendor
					          )
	         END;
*/



         SET @pNrFiskalizim = @Nr;

      SELECT NRFISKALIZIM   = @Nr;


GO


ALTER Procedure [dbo].[Isd_FiscalInformationFt]
(
  @pTableName     Varchar(20),
  @pNrRendor      Int
 )
As
     DECLARE @NrRendor        Int,
             @TableName       Varchar(20),
			 @iLength         Int,
			 @FISRELATEDFIC	  VARCHAR(100),
			 @FISRELATEDDATE  DATETIME,
			 @TIPPAGESE		  VARCHAR(30),
			 @TIPKLIENT		  VARCHAR(30),
			 @SELF			  VARCHAR(30),
			 @ISEINVOICE	  VARCHAR(10);

         SET @TableName     = @pTableName;   -- 'FJ';
         SET @NrRendor      = @pNrRendor;    -- 443250;
		 SET @iLength       = 150;

		 

          IF CHARINDEX(','+@TableName+',',',FJ,FF,FD,SM,')=0
             BEGIN
               SELECT NrOrder = '', Pershkrim = '', Koment = '', PromptDok = '', 
			          ISDOCFISCAL=CAST(0 AS BIT), FISSTATUS='', FISPROCES='', FISMENPAGESE='', FISTIPDOK='', FISKODOPERATOR='', FISBUSINESSUNIT='', 
					  FISTCR='', FISFIC='', FISEIC='', FISPDF='', FISUUID='', NRFISKALIZIM=0,
					  NrRendor = 0, DisplayValue = '', FieldValue = '', TipRow = '', TRow = CAST(0 AS BIT);
               RETURN;
             END;




-- 1.  ------------------------------------------------  Fature Shitje  ------------------------------------------------


      IF @TableName='FJ'
         BEGIN
		 --PRINT 'AAAA'
                 IF OBJECT_ID('Tempdb..#TMP_FJ ') IS NOT NULL
                    DROP TABLE #TMP_FJ;

             SELECT A.*, M.Transportues, M.Mjet, M.Targe
			   INTO #TMP_FJ 
			   FROM FJ A LEFT JOIN FJSHOQERUES M ON A.NRRENDOR = M.NRD 
			  WHERE A.NRRENDOR=@NrRendor;

			 	SET @TIPPAGESE=(SELECT top 1 KLASEPAGESE FROM FJ A INNER JOIN FisMenPagese B ON  A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@pNrRendor)
				SET @TIPKLIENT=(SELECT top 1 ISNULL(A.TIPNIPT,B.TIPNIPT)  FROM FJ A INNER JOIN KLIENT B ON A.KODFKL=B.KOD WHERE A.NRRENDOR=@pNrRendor)
				SET @SELF=(SELECT CASE WHEN ISNULL(A.KLASETVSH,'') IN ('SANG','SELF','SEXP','OTHER') THEN  A.KLASETVSH
								ELSE  NULL END FROM FJ A WHERE A.NRRENDOR=@pNrRendor)
	

	IF @TIPPAGESE='BANKE' AND @TIPKLIENT='NUIS' AND @SELF IS NULL
	SET @ISEINVOICE='Po'
	ELSE
	SET @ISEINVOICE='Jo'

			 
			 SET @FISRELATEDFIC=(SELECT TOP 1 B.FISIIC FROM FJStornimScr B WHERE NRD=@NrRendor )
			 SET @FISRELATEDDATE=(SELECT TOP 1 B.DATEDOKCREATE FROM FJStornimScr B WHERE NRD=@NrRendor)




             SELECT A.NrOrder, A.Pershkrim, A.Koment,
                    PromptDok='Fature shitje Nr '+CONVERT(VARCHAR,B.NRDOK)+', date '+CONVERT(VARCHAR,B.DATEDOK,104),
                    B.ISDOCFISCAL,    B.FISSTATUS,	     B.FISPROCES, B.FISMENPAGESE, B.FISTIPDOK,
					B.FISKODOPERATOR, B.FISBUSINESSUNIT, B.FISTCR,    B.FISFIC, B.FISIIC,      B.FISEIC,    
					B.FISPDF, B.FISUUID, B.NRFISKALIZIM,
					B.NRRENDOR,
                    A.TipRow,A.TRow

               FROM

              (

			 SELECT NrOrder = '01', Pershkrim = 'Status'+Space(50),           Koment = CASE WHEN ISNULL(FISKALIZUAR,0)=1 
			                                                                                THEN 'Fiskalizuar' 
																				            ELSE 'Pa Fiskalizuar' 
																			           END +Space(@iLength), TipRow = 'B', TRow = CAST(1 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '02', Pershkrim = 'Dokument fiskal '+Space(50), Koment = CASE WHEN ISNULL(ISDOCFISCAL,0)=1 THEN 'Po' ELSE 'Jo' END +Space(@iLength), 
			                                                                                                 TipRow = 'B', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '03', Pershkrim = 'Status e-fatura ',           Koment = [FISSTATUS],          TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          
		  UNION ALL
             SELECT NrOrder = '00', Pershkrim = 'Fature elektronike ',        Koment = @ISEINVOICE,          TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          
		  UNION ALL
             SELECT NrOrder = '04', Pershkrim = 'Procesi ',	                  Koment = [FISPROCES],          TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '05', Pershkrim = 'Menyra e pageses',	          Koment = [FISMENPAGESE],       TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '06', Pershkrim = 'Tipi dokumentit', 	          Koment = [FISTIPDOK],          TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '07', Pershkrim = 'Operatori ',	              Koment = [FISKODOPERATOR],     TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '08', Pershkrim = 'Njesi biznesi',	          Koment = [FISBUSINESSUNIT],    TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '09', Pershkrim = 'TCR ',	                      Koment = [FISTCR],             TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '10', Pershkrim = 'Dokument PDF ',              Koment = CASE WHEN LTRIM(RTRIM(ISNULL(FISPDF,'')))<>'' 
			                                                                                THEN 'Gjeneruar PDF' 
																					        ELSE 'Nuk ka' 
																			           END,                  TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
	         SELECT NrOrder = '11', Pershkrim = 'UUID ',                      Koment = CAST(LTRIM(RTRIM(ISNULL([FISUUID],'')))              AS Varchar(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ 

		  UNION ALL
			 SELECT NrOrder = '12', Pershkrim = 'NIVF ',	                  Koment = CAST(LTRIM(RTRIM(ISNULL([FISFIC],'')))               AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ

			 
		  UNION ALL
			 SELECT NrOrder = '13', Pershkrim = 'NSLF ',	                  Koment = CAST(LTRIM(RTRIM(ISNULL([FISIIC],'')))               AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ

		  UNION ALL
		     SELECT NrOrder = '14', Pershkrim = 'QRCODELINK ',                Koment = CAST(LTRIM(RTRIM(ISNULL([FISQRCODELINK],'')))        AS VARCHAR(250)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ

		  UNION ALL
		     SELECT NrOrder = '15', Pershkrim = 'RELATEDFIC ',                Koment = CAST(LTRIM(RTRIM(ISNULL(@FISRELATEDFIC,'')))        AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ

		  UNION ALL
		     SELECT NrOrder = '16', Pershkrim = 'RELATEDDATE ',                Koment = CONVERT(varchar, @FISRELATEDDATE, 103), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ

		  UNION ALL
		     SELECT NrOrder = '17', Pershkrim = 'EIC ',	                      Koment = CAST(LTRIM(RTRIM(ISNULL([FISEIC],'')))               AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ

		  UNION ALL
		     SELECT NrOrder = '18',Pershkrim = 'ERROR FISKALIZIMI ',          Koment = CAST(LTRIM(RTRIM(ISNULL(CASE WHEN FISLASTERRORFIC='0' THEN '' ELSE [FISLASTERRORTEXTFIC] END,'')))  AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ

		  UNION ALL
		     SELECT NrOrder = '19', Pershkrim = 'ERROR E-INVOICE ',          Koment = CAST(LTRIM(RTRIM(ISNULL([FISLASTERRORTEXTEIC],'')))  AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
		  UNION ALL
		     SELECT NrOrder = '20', Pershkrim = 'XML STRING ',          Koment = CAST(LTRIM(RTRIM(ISNULL([FISXMLSTRING],'')))  AS VARCHAR(8000)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '21', Pershkrim = 'Transprtues: ',	          Koment = ISNULL(Transportues,'') + CASE WHEN ISNULL(Transportues,'')<>'' AND (ISNULL(Mjet,'')<>'' OR ISNULL(Targe,'')<>'') THEN ',  ' ELSE '' END+
				                                                                       ISNULL(Mjet,'')         + CASE WHEN ISNULL(Mjet,'')<>'' AND ISNULL(Targe,'')<>''	                                 THEN ',  ' ELSE '' END+
				                                                                       ISNULL(Targe,''),                                                      TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ
          UNION ALL
             SELECT NrOrder = '22', Pershkrim = 'Nr fiskalizimi: ',	          Koment = CAST([NRFISKALIZIM] AS VARCHAR),                                       TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FJ


                    ) A,  FJ B 
		 
		      WHERE B.NRRENDOR=@NrRendor
           ORDER BY NrOrder

		   
         END;




-- 2.  ------------------------------------------------  Fature Blerje  ------------------------------------------------


      IF @TableName='FF'
         BEGIN

                 IF OBJECT_ID('Tempdb..#TMP_FF ') IS NOT NULL
                    DROP TABLE #TMP_FF;

             SELECT * INTO #TMP_FF FROM FF WHERE NRRENDOR=@NrRendor;

			 SET @FISRELATEDFIC=(SELECT TOP 1 B.FISIIC FROM FFStornimScr B WHERE NRD=@NrRendor )
			 SET @FISRELATEDDATE=(SELECT TOP 1 B.DATEDOKCREATE FROM FFStornimScr B WHERE NRD=@NrRendor)

             SELECT A.NrOrder, A.Pershkrim, A.Koment,
                    PromptDok='Fature shitje Nr '+CONVERT(VARCHAR,B.NRDOK)+', date '+CONVERT(VARCHAR,B.DATEDOK,104),
                    B.ISDOCFISCAL,    B.FISSTATUS,	     B.FISPROCES, B.FISMENPAGESE, B.FISTIPDOK,
					B.FISKODOPERATOR, B.FISBUSINESSUNIT, B.FISTCR,    B.FISFIC, B.FISIIC,      B.FISEIC,    B.FISPDF, B.FISUUID,
					B.NRRENDOR,
                    A.TipRow,A.TRow

               FROM

              (

			 SELECT NrOrder = '01', Pershkrim = 'Status'+Space(50),           Koment = CASE WHEN ISNULL(FISKALIZUAR,0)=1 
			                                                                                THEN 'Fiskalizuar' 
																							ELSE 'Pa Fiskalizuar' 
																					   END +Space(@iLength), TipRow = 'B', TRow = CAST(1 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '02', Pershkrim = 'Dokument fiskal '+Space(50), Koment = CASE WHEN ISNULL(ISDOCFISCAL,0)=1 THEN 'Po' ELSE 'Jo' END +Space(@iLength), 
			                                                                                                 TipRow = 'B', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '03', Pershkrim = 'Status e-fatura ',           Koment = [FISSTATUS],          TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '04', Pershkrim = 'Procesi ',	                  Koment = [FISPROCES],          TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '05', Pershkrim = 'Menyra e pageses',	          Koment = [FISMENPAGESE],       TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '06', Pershkrim = 'Tipi dokumentit', 	          Koment = [FISTIPDOK],          TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '07', Pershkrim = 'Operatori ',	              Koment = [FISKODOPERATOR],     TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '08', Pershkrim = 'Njesi biznesi',	          Koment = [FISBUSINESSUNIT],    TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '09', Pershkrim = 'TCR ',	                      Koment = [FISTCR],             TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
             SELECT NrOrder = '10', Pershkrim = 'Dokument PDF ',              Koment = CASE WHEN LTRIM(RTRIM(ISNULL(FISPDF,'')))<>'' 
			                                                                                THEN 'Gjeneruar PDF' 
																					        ELSE 'Nuk ka' 
																			           END,                  TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
          UNION ALL
	         SELECT NrOrder = '11', Pershkrim = 'UUID ',                      Koment = CAST(LTRIM(RTRIM(ISNULL([FISUUID],'')))              AS Varchar(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF 

		  UNION ALL
			 SELECT NrOrder = '12', Pershkrim = 'NIVF ',	                  Koment = CAST(LTRIM(RTRIM(ISNULL([FISFIC],'')))               AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF

		  UNION ALL
			 SELECT NrOrder = '13', Pershkrim = 'NSLF ',	                  Koment = CAST(LTRIM(RTRIM(ISNULL([FISIIC],'')))               AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF

		  UNION ALL
		     SELECT NrOrder = '14', Pershkrim = 'QRCODELINK ',                Koment = CAST(LTRIM(RTRIM(ISNULL([FISQRCODELINK],'')))        AS VARCHAR(250)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF

		  UNION ALL
		     SELECT NrOrder = '15', Pershkrim = 'RELATEDFIC ',                Koment = CAST(LTRIM(RTRIM(ISNULL(@FISRELATEDFIC,'')))        AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF

		  UNION ALL
		     SELECT NrOrder = '16', Pershkrim = 'RELATEDDATE ',                Koment = CONVERT(varchar, @FISRELATEDDATE, 103), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF
		     
	      UNION ALL
		     SELECT NrOrder = '20', Pershkrim = 'XML STRING ',          Koment = CAST(LTRIM(RTRIM(ISNULL([FISXMLSTRING],'')))  AS VARCHAR(8000)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF

		  --UNION ALL
		  --   SELECT NrOrder = '17', Pershkrim = 'EIC ',	                      Koment = CAST(LTRIM(RTRIM(ISNULL([FISEIC],'')))               AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF

		  UNION ALL
		     SELECT NrOrder = '18', Pershkrim = 'ERROR FISKALIZIMI ',          Koment = CAST(LTRIM(RTRIM(ISNULL(CASE WHEN FISLASTERRORFIC='0' THEN '' ELSE [FISLASTERRORTEXTFIC] END,'')))  AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF

		  --UNION ALL
		  --   SELECT NrOrder = '19', Pershkrim = 'LASTERRORTEXTEIC ',          Koment = CAST(LTRIM(RTRIM(ISNULL([FISLASTERRORTEXTEIC],'')))  AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF

          UNION ALL
             SELECT NrOrder = '20', Pershkrim = 'Nr fiskalizimi: ',	          Koment = CAST([NRFISKALIZIM] AS VARCHAR),                                       TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FF


                    ) A,  FF B 
		 
		      WHERE B.NRRENDOR=@NrRendor
           ORDER BY NrOrder

		   
         END;




-- 3.  ------------------------------------------------  Flete Dalje  ------------------------------------------------


      IF @TableName='FD'
         BEGIN

                 IF OBJECT_ID('Tempdb..#TMP_FD ') IS NOT NULL
                    DROP TABLE #TMP_FD;


             SELECT A.*, M.Transportues, M.Mjet, M.Targe        --FISKALIZUAR, NRDOK, QRCODELINK, NIVFSH 
			   INTO #TMP_FD 
			   FROM FD A LEFT JOIN MGSHOQERUES M ON A.NRRENDOR = M.NRD 
			  WHERE A.NRRENDOR=@NrRendor;


             SELECT A.NrOrder, A.Pershkrim, A.Koment,
                    PromptDok='WTN Nr '+CONVERT(VARCHAR,B.NRDOK)+', date '+CONVERT(VARCHAR,B.DATEDOK,104)+', mag '+B.KMAG,
                    B.FISKALIZUAR, B.ISDOCFISCAL, B.FISKODOPERATOR, B.FISBUSINESSUNIT,
--			        B.FISSTATUS, B.FISPROCES, B.FISMENPAGESE, B.FISTIPDOK,B.FISTCR,B.FISFIC,B.FISEIC,B.FISPDF,B.FISUUID,
				    B.NRRENDOR,  A.TipRow,    A.TRow

               FROM

              (

             SELECT NrOrder = '01', Pershkrim = 'Status'+Space(50),           Koment = CASE WHEN ISNULL(FISKALIZUAR,0)=1 
			                                                                                THEN 'Fiskalizuar' 
																						    ELSE 'Pa Fiskalizuar' 
																					   END +Space(@iLength),                                        TipRow = 'B', TRow = CAST(1 AS BIT) FROM #TMP_FD
          UNION ALL
		     SELECT NrOrder = '02', Pershkrim = 'QRCODELINK ',                Koment = CAST(LTRIM(RTRIM(ISNULL([QRCODELINK],''))) AS VARCHAR(250)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD

		  UNION ALL
	         SELECT NrOrder = '03', Pershkrim = 'NIVFSH ',                    Koment = CAST(LTRIM(RTRIM(ISNULL(NIVFSH,''))) AS VARCHAR(150)),       TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD

		  UNION ALL
             SELECT NrOrder = '04', Pershkrim = 'Dokument fiskal '+Space(50), Koment = CASE WHEN ISNULL(ISDOCFISCAL,0)=1 THEN 'Po' ELSE 'Jo' END +Space(@iLength),
			                                                                                                                                        TipRow = 'B', TRow = CAST(0 AS BIT) FROM #TMP_FD
          UNION ALL
             SELECT NrOrder = '05', Pershkrim = 'Status fiskalizimi ',        Koment = [FISSTATUS],                                                 TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD
          UNION ALL
             SELECT NrOrder = '06', Pershkrim = 'Procesi ',	                  Koment = [FISPROCES],                                                 TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD
          UNION ALL
             SELECT NrOrder = '07', Pershkrim = 'Tipi dokumentit', 	          Koment = [FISTIPDOK],                                                 TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD
          UNION ALL
             SELECT NrOrder = '08', Pershkrim = 'Operatori ',	              Koment = [FISKODOPERATOR],                                            TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD
          UNION ALL
             SELECT NrOrder = '09', Pershkrim = 'Njesi biznesi',	          Koment = [FISBUSINESSUNIT],                                           TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD
		  UNION ALL
			  SELECT NrOrder = '20', Pershkrim = 'XML STRING ',          Koment = CAST(LTRIM(RTRIM(ISNULL([FISXMLSTRING],'')))  AS VARCHAR(8000)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD
         
		  UNION ALL
             SELECT NrOrder = '10', Pershkrim = 'Transprtues: ',	          Koment = ISNULL(Transportues,'') + CASE WHEN ISNULL(Transportues,'')<>'' AND (ISNULL(Mjet,'')<>'' OR ISNULL(Targe,'')<>'') THEN ',  ' ELSE '' END+
				                                                                       ISNULL(Mjet,'')         + CASE WHEN ISNULL(Mjet,'')<>'' AND ISNULL(Targe,'')<>''	                                 THEN ',  ' ELSE '' END+
				                                                                       ISNULL(Targe,''),                                            TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD
          UNION ALL
             SELECT NrOrder = '11', Pershkrim = 'Nr fiskalizimi: ',	          Koment = CAST([NRFISKALIZIM] AS VARCHAR),                             TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_FD


                    ) A,  FD B 

		      WHERE B.NRRENDOR=@NrRendor

           ORDER BY NrOrder


         END;




-- 4.  ------------------------------------------------  Pike Shitje  ------------------------------------------------

	 
      IF @TableName='SM'
         BEGIN
	
                 IF OBJECT_ID('Tempdb..#TMP_SM ') IS NOT NULL
                    DROP TABLE #TMP_SM;


             SELECT A.* INTO #TMP_SM FROM SM A WHERE A.NRRENDOR=@NrRendor;
			 SET @FISRELATEDFIC=(SELECT TOP 1 B.FISIIC FROM SMStornimScr B WHERE NRD=@NrRendor )
			 SET @FISRELATEDDATE=(SELECT TOP 1 B.DATEDOKCREATE FROM SMStornimScr B WHERE NRD=@NrRendor)

             SELECT A.NrOrder, A.Pershkrim, A.Koment,
                    PromptDok='Pike shitje Nr '+CONVERT(VARCHAR,B.NRDOK)+', date '+CONVERT(VARCHAR,B.DATEDOK,104)+', kasa '+ISNULL(B.KASE,''),
                    B.FISKALIZUAR, B.ISDOCFISCAL, B.FISPROCES, B.FISMENPAGESE, B.FISTIPDOK, B.FISKODOPERATOR, B.FISBUSINESSUNIT,B.NRFISKALIZIM,
			     -- B.FISSTATUS, B.FISTCR,B.FISFIC,B.FISEIC,B.FISPDF,B.FISUUID,
                    B.FISQRCODELINK,
				    B.NRRENDOR,  A.TipRow,    A.TRow

               FROM

              (

             SELECT NrOrder = '01', Pershkrim = 'Status'+Space(50),           Koment = CASE WHEN ISNULL(FISKALIZUAR,0)=1 THEN 'Fiskalizuar' ELSE 'Pa Fiskalizuar' END +Space(@iLength),
	                                                                                                                                                   TipRow = 'B', TRow = CAST(1 AS BIT) FROM #TMP_SM
          UNION ALL
		     SELECT NrOrder = '02', Pershkrim = 'QRCODELINK ',                Koment = CAST(LTRIM(RTRIM(ISNULL([FISQRCODELINK],''))) AS VARCHAR(250)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM
		  UNION ALL
             SELECT NrOrder = '03', Pershkrim = 'Dokument fiskal '+Space(50), Koment = CASE WHEN ISNULL(ISDOCFISCAL,0)=1 THEN 'Po' ELSE 'Jo' END +Space(@iLength),
			                                                                                                                                           TipRow = 'B', TRow = CAST(0 AS BIT) FROM #TMP_SM
          UNION ALL
             SELECT NrOrder = '04', Pershkrim = 'Procesi ',	                  Koment = [FISPROCES],                                                    TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM
          UNION ALL
             SELECT NrOrder = '05', Pershkrim = 'Tipi dokumentit', 	          Koment = [FISTIPDOK],                                                    TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM
          UNION ALL
             SELECT NrOrder = '06', Pershkrim = 'Operatori ',	              Koment = [FISKODOPERATOR],                                               TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM
          UNION ALL
             SELECT NrOrder = '07', Pershkrim = 'Njesi biznesi',	          Koment = [FISBUSINESSUNIT],                                              TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM
          UNION ALL
             SELECT NrOrder = '08', Pershkrim = 'Nr fiskalizimi: ',	          Koment = CAST([NRFISKALIZIM] AS VARCHAR),                                TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM
		  UNION ALL	    	 
			 SELECT NrOrder = '20', Pershkrim = 'XML STRING ',          Koment = CAST(LTRIM(RTRIM(ISNULL([FISXMLSTRING],'')))  AS VARCHAR(8000)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM

		  UNION ALL
		     SELECT NrOrder = '15', Pershkrim = 'RELATEDFIC ',                Koment = CAST(LTRIM(RTRIM(ISNULL(@FISRELATEDFIC,'')))        AS VARCHAR(150)), TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM

		  UNION ALL
		     SELECT NrOrder = '16', Pershkrim = 'RELATEDDATE ',                Koment =  CONVERT(varchar, @FISRELATEDDATE, 103) , TipRow = ' ', TRow = CAST(0 AS BIT) FROM #TMP_SM


          
                    ) A,  SM B 

		      WHERE B.NRRENDOR=@NrRendor

           ORDER BY NrOrder


         END;




          
GO

ALTER PROC [dbo].[Isd_FiscalWTN]
       @NrRendor INT,
	    @OUTPUT1	VARCHAR(MAX) OUTPUT  

AS 
DECLARE  
						@BusinessUnit		VARCHAR(50)
						,@OperatorCode		VARCHAR(50)
						,@CashRegister		VARCHAR(50)
						,@Fiscalize			BIT		= 1
						,@QrCodeLink		VARCHAR(1000) --OUTPUT 
						,@Xml				XML			  --OUTPUT
						,@Error				VARCHAR(1000) --OUTPUT 
						,@ErrorText			VARCHAR(1000) --OUTPUT 
						,@NIPT				VARCHAR(20)
						,@PerqZbr			FLOAT
						,@Date				VARCHAR(100)
						,@DATECREATE		DATETIME
						,@Nr				VARCHAR(10)
						,@VlerTot			VARCHAR(20)
						,@CertificatePwd	VARCHAR(1000)
						,@IicBlank			VARCHAR(MAX)
						,@Iic				VARCHAR(1000)
						,@IicSignature		VARCHAR(1000)
						,@FiscUrL			VARCHAR(1000)
						,@responseXml		XML
						,@UniqueIdentif		UNIQUEIDENTIFIER
						,@VatRegistrationNo	VARCHAR(50)
						,@SoftNum			VARCHAR(50)
						,@ManufacNum		VARCHAR(50)
						,@FIC				VARCHAR(1000)
						,@SIGNEDXML			VARCHAR(MAX)
						,@schema			VARCHAR(MAX)
						,@Url				VARCHAR(MAX)
						,@Certificate		VARBINARY(MAX)
						,@CertificatePath   VARCHAR(MAX)
						,@certificatepassword VARCHAR(MAX)
						,@XMLSTRING         VARCHAR(MAX)
						,@TIPFISKAL		    VARCHAR(50)
						,@IsGoodsFlammable  bit
						,@IsEscortRequired  bit
						,@ItemsNum			int
						,@PackType			VARCHAR(50)
						,@PackNum			int
						,@VehPlates         VARCHAR(50)
						,@VehOwnership		VARCHAR(50)
						,@StartDateTime		VARCHAR(50)
						,@DestinDateTime	VARCHAR(50)
						,@SENDDATETIME		VARCHAR(100);
				
				SET @SENDDATETIME		= dbo.DATE_1601(getdate());
				
				SELECT   @VatRegistrationNo	= CONFND.NIPT
						,@SoftNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSOFTNUM')
						,@ManufacNum        = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCMANUFACNUM')
						,@schema			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSCHEMA')
						,@FiscUrL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCURL')
						,@CertificatePath   = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPATH')
						,@CertificatePwd    = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPASS')		
						,@Certificate		= FiscCertificate
						,@TIPFISKAL			= ISNULL(KODFISKAL,'VAT')
				FROM CONFND

				--UPDATE FD SET DATECREATE=getdate() where NRRENDOR=@NrRendor;

				DECLARE @FISMENPAGESE AS VARCHAR(50);
				DECLARE @KLASEPAGESE AS VARCHAR(50);
				DECLARE @KURSFAT AS VARCHAR(50);
				DECLARE @SELF AS VARCHAR(50);
				DECLARE @TCRCODE AS VARCHAR(50);
				DECLARE @IsEinvoice AS BIT;
				DECLARE @VLERAFD AS FLOAT;
				DECLARE @STARTPOINT AS VARCHAR(50);
				DECLARE @DESTINPOINT AS VARCHAR(50);
				DECLARE @StartAddr AS VARCHAR(50);
				DECLARE @StartCity AS VARCHAR(50);
				DECLARE @DestinAddr AS VARCHAR(50);
				DECLARE @DestinCity AS VARCHAR(50);
				DECLARE @FISPROCES AS VARCHAR(50);
				DECLARE @FISTIPDOK AS VARCHAR(50);
	

				SET @CashRegister = 'hy521rx101'--(SELECT TOP 1 KODTCR FROM FJ A INNER JOIN FisTCR B ON A.FISTCR=B.KOD WHERE A.NRRENDOR=@NrRendor)
				SET @OperatorCode = (SELECT TOP 1 LOWER(KODFISCAL) FROM FD A INNER JOIN FisOperator B ON A.FISKODOPERATOR=B.KOD WHERE A.NRRENDOR=@NrRendor)
				SET @BusinessUnit = (SELECT TOP 1 LOWER(FISBUSINESSUNIT) FROM FD A  WHERE A.NRRENDOR=@NrRendor)
				SET @TCRCODE='qo315bz249'
				SET @VLERAFD=((SELECT SUM(SASI*CASE WHEN ISNULL(MAGRF.GRUP,'A')='B' THEN ARTIKUJ.CMSH1
                                 WHEN ISNULL(MAGRF.GRUP,'A')='C' THEN ARTIKUJ.CMSH2
                                 WHEN ISNULL(MAGRF.GRUP,'A')='D' THEN ARTIKUJ.CMSH3
                                 WHEN ISNULL(MAGRF.GRUP,'A')='E' THEN ARTIKUJ.CMSH4
                                 WHEN ISNULL(MAGRF.GRUP,'A')='F' THEN ARTIKUJ.CMSH5
                                 WHEN ISNULL(MAGRF.GRUP,'A')='G' THEN ARTIKUJ.CMSH6
                                 WHEN ISNULL(MAGRF.GRUP,'A')='H' THEN ARTIKUJ.CMSH7
                                 WHEN ISNULL(MAGRF.GRUP,'A')='I' THEN ARTIKUJ.CMSH8
                                 WHEN ISNULL(MAGRF.GRUP,'A')='J' THEN ARTIKUJ.CMSH9
                                 ELSE                                 ARTIKUJ.CMSH
                                 END * 1) FROM FDSCR A INNER JOIN ARTIKUJ ON A.KARTLLG=ARTIKUJ.KOD 
													   INNER JOIN FD C ON A.NRD=C.NRRENDOR
													   LEFT  JOIN MAGAZINA MAGRF ON C.KMAGRF=MAGRF.KOD
													   
													   WHERE NRD=@NrRendor))
				--SET @VLERAFD=((SELECT SUM(SASI*B.CMSH) FROM FDSCR A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD WHERE NRD=@NrRendor))
				--SET @DATECREATE=(SELECT DATECREATE FROM FD WHERE NRRENDOR=@NrRendor)
				--SET @STARTPOINT=(SELECT CASE WHEN ISNULL(ISDOGANE,0)=0 THEN 'WAREHOUSE' ELSE 'WAREHOUSE' END FROM MAGAZINA A INNER JOIN FD B ON A.KOD=B.KMAG WHERE B.NRRENDOR=@NrRendor)
				--SET @DESTINPOINT=(SELECT CASE WHEN ISNULL(ISDOGANE,0)=0 THEN 'WAREHOUSE' ELSE 'WAREHOUSE' END FROM MAGAZINA A INNER JOIN FD B ON A.KOD=B.KMAGRF WHERE B.NRRENDOR=@NrRendor)
				--SET @StartAddr=(SELECT ISNULL(A.SHENIM1,'Adresa nga po niset malli') FROM MAGAZINA A INNER JOIN FD B ON A.KOD=B.KMAG WHERE B.NRRENDOR=@NrRendor)
				--SET @StartCity=(SELECT ISNULL(A.SHENIM2,'Qyteti nga po niset malli') FROM MAGAZINA A INNER JOIN FD B ON A.KOD=B.KMAG WHERE B.NRRENDOR=@NrRendor)
    --            SET @DestinAddr=(SELECT ISNULL(A.SHENIM1,'Adresa destinacion') FROM MAGAZINA A INNER JOIN FD B ON A.KOD=B.KMAGRF WHERE B.NRRENDOR=@NrRendor)
				--SET @DestinCity=(SELECT ISNULL(A.SHENIM2,'Qyteti destinacion') FROM MAGAZINA A INNER JOIN FD B ON A.KOD=B.KMAGRF WHERE B.NRRENDOR=@NrRendor)
                SELECT TOP 1 @DATECREATE=A.DATECREATE,
					   @STARTPOINT=ISNULL(B.STARTPOINT,''),
					   @DESTINPOINT=ISNULL(B.DESTINPOINT,''),
					   @StartAddr=ISNULL(B.SHENIM1,''),
					   @StartCity=ISNULL(B.SHENIM3,''),
					   @DestinAddr=ISNULL(B.DESTINSHENIM1,''),
					   @DestinCity=ISNULL(B.DESTINSHENIM3,''),
					   @IsGoodsFlammable=case when isnull(GoodsFlammable,0)=0 then 'false' else 'true' end,
					   @IsEscortRequired=case when isnull(EscortRequired,0)=0 then 'false' else 'true' end,
					   @ItemsNum=(select nr=count('') from (SELECT nr=COUNT('1') FROM FDSCR WHERE NRD=@NrRendor GROUP BY KARTLLG) as a),
					   @PackType=B.PackType,
					   @PackNum=B.PackNum,
					   @VehPlates=B.TARGE,
					   @VehOwnership=B.VehOwner,
					   @StartDateTime=dbo.DATE_1601(B.[DATE]),--+B.[TIME]),
					   @DestinDateTime=dbo.DATE_1601(B.DestinDate),--+B.DestinTime),
					   @FISPROCES= A.FISPROCES,
					   @FISTIPDOK= A.FISTIPDOK


				FROM FD A LEFT JOIN MGSHOQERUES B ON A.NRRENDOR=B.NRD
				--LEFT JOIN MAGAZINA B ON A.KMAG=B.KOD
				--LEFT JOIN MAGAZINA C ON A.KMAGRF=C.KOD
				WHERE A.NRRENDOR=@NrRendor
				
       DECLARE @IICBLANC AS VARCHAR(MAX)
       SELECT @IICBLANC = @VatRegistrationNo + '|'
	    + dbo.DATE_1601(@DATECREATE) + '|' 
        + convert(varchar(max),NRFISKALIZIM)+ '|'
       + @BusinessUnit + '|'
	   + @TCRCODE + '|'
       + @SoftNum + '|'
	   + CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(18,2), ROUND(ISNULL(@VLERAFD,1),2)))
       FROM FD WHERE NRRENDOR = @NrRendor

	   --PRINT @IICBLANC
      

	   EXEC _FiscalGenerateHash @IICBLANC, @CertificatePath, @CertificatePwd, @Certificate, @IIC OUTPUT, @IICSIGNATURE OUTPUT, @ERROR OUTPUT, @ERRORtext OUTPUT;
   

--SELECT @IIC, @IICSIGNATURE, @ERROR,@CertificatePath, @CertificatePwd, @Certificate
SET @XML  = (
SELECT 
              --dbo.DATE_1601(@DATECREATE) AS 'Header/@SendDateTime',
              CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 THEN @SENDDATETIME ELSE dbo.DATE_1601(@DATECREATE) END AS 'Header/@SendDateTime',
              CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 then 'NOINTERNET' else null END AS 'Header/@SubseqDelivType',
              NEWID() AS 'Header/@UUID',                                                 --Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
(
       SELECT    @BusinessUnit                     AS '@BusinUnitCode'        --Duhet shtuar tek magazina, apo duhet shtuar ne FD?
                 ,dbo.DATE_1601(@DATECREATE)      AS '@IssueDateTime'
                 ,@IIC                          AS '@WTNIC'                       --Duhet shtuar ne dokument
                 ,@IICSIGNATURE                 AS '@WTNICSignature' --Duhet shtuar ne dokument
                                                                                                              --kthim
                 --,'false'                                     AS '@IsAfterDel'           --Duhet shtuar ne dokument
                 ,@IsGoodsFlammable             AS '@IsGoodsFlammable'     --Duhet shtuar ne dokument
                 ,@IsEscortRequired             AS '@IsEscortRequired'     --Duhet shtuar ne dokument
				 ,@ItemsNum						AS '@ItemsNum'
				 ,@PackType						AS '@PackType'
				 ,@PackNum						AS '@PackNum'
                 ,@OperatorCode                 AS '@OperatorCode'         --Duhet shtuar ne user ->       
                 ,@SoftNum                      AS '@SoftCode'
                 --,CASE WHEN ISNULL(DST,'')='FU' THEN 'SALE' ELSE 'WTN' END                                      AS '@Type'                        --warehouse transfer
				 ,@FISTIPDOK					AS '@Type'                        --warehouse transfer
                 --,'OTHER'                                     AS '@GroupOfGoods'
				 --,CONVERT(DECIMAL(34,2),(select sum(vleram) from fDscr where nrd=s.NRRENDOR)) as '@ValueOfGoods'
				 ,CONVERT(DECIMAL(34,2),@VLERAFD) AS '@ValueOfGoods'
                 --,CASE WHEN ISNULL(DST,'')='FU' THEN 'DOOR' ELSE 'TRANSFER' END      AS '@Transaction'          --> TIPI I TRANSFERTES
				 ,@FISPROCES      AS '@Transaction'          --> TIPI I TRANSFERTES
                 , CONVERT(VARCHAR(40), ISNULL(NRFISKALIZIM, 1)) +'/'+ CONVERT(VARCHAR(4), YEAR([DATEDOK]))                     AS '@WTNNum'                                    
                 , CONVERT(VARCHAR(40), ISNULL(NRFISKALIZIM, 1)) AS '@WTNOrdNum'                                    
                 ,@VehPlates   AS '@VehPlates'                   --
                 ,@VehOwnership AS '@VehOwnership'         -- == THIRDPARTY DUHET SPECIFIKUAR CARRIER
                 ,@STARTPOINT                                 AS '@StartPoint'           --
                 ,@DESTINPOINT                                AS '@DestinPoint'          --
                 ,isnull(@StartDateTime,dbo.DATE_1601(S.DATECREATE))             AS '@StartDateTime'
                 ,isnull(@DestinDateTime,dbo.DATE_1601(S.DATECREATE))            AS '@DestinDateTime'
                 ,@StartAddr								AS '@StartAddr'                   --
                 ,@StartCity								AS '@StartCity'                   --
                 ,@DestinAddr								AS '@DestinAddr'           -- ADRESA MAG BURIM
                 ,@DestinCity								AS '@DestinCity'           -- ADRESA MAG DESTINACION
          ,(  --nga config
                     SELECT		  PERSHKRIM                 AS 'Issuer/@Name',                
                                  NIPT                      AS 'Issuer/@NUIS',
                                  SHENIM2                   AS 'Issuer/@Town',
                                  SHENIM1                   AS 'Issuer/@Address'
                     FROM CONFND
                     FOR XML PATH (''), TYPE
              ) ,
              (      --nga klienti
                    SELECT  REPLACE(CarrierAdress, '"', '') AS 'Carrier/@Address',
                                  CarrierIDNum              AS 'Carrier/@IDNum',
								  IDType					AS 'Carrier/@IDType',
                                  Carriername               AS 'Carrier/@Name',
                                  Carriertown               AS 'Carrier/@Town'
                                 
                     FROM MGSHOQERUES WHERE MGSHOQERUES.NRD=@NrRendor
					-- and ISNULL(SHENIM3,'OWNER')='THIRDPARTY'
                     FOR XML PATH (''), TYPE
              ),
              (      SELECT		  C.KARTLLG							AS 'I/@C',
                                  LEFT(C.PERSHKRIM, 50)				AS 'I/@N',
                                  CONVERT(DECIMAL(18, 2), C.SASI)	AS 'I/@Q',
                                  NJESI								AS 'I/@U'                                 
                     FROM FDSCR C 
                     WHERE C.NRD = S.NRRENDOR
                     FOR XML PATH (''), TYPE
              ) Items
       FROM FD S
       LEFT JOIN MGSHOQERUES M ON S.NRRENDOR = M.NRD
       WHERE S.NRRENDOR = @NrRendor
       FOR XML PATH('WTN'), TYPE
	  
)
FOR XML PATH('RegisterWTNRequest'));
SET @XML = CAST( REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterWTNRequest>',
'<RegisterWTNRequest xmlns="https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3">') AS XML);

SET @XMLSTRING = CAST(@XML AS VARCHAR(MAX))
	
	EXEC _FiscalProcessRequest 
							@InputString		 = @XmlString,
							@CertBinary		 = @Certificate,
							@CertificatePath	 = @CertificatePath, 
							@Certificatepassword = @CertificatePwd, 
							@Url				 = @FiscUrL,
							@Schema				 = @Schema,
							@ReturnValue		 = 'FWTNIC',
							@useSystemProxy		 = '',
							@SignedXml			 = @SignedXml	OUTPUT, 
							@Fic				 = @Fic			OUTPUT, 
							@Error				 = @Error		OUTPUT, 
							@Errortext			 = @Errortext	OUTPUT,
							@responseXml		 = @responseXml OUTPUT;
	          
              declare @OrderNumber as varchar(10),@total as varchar(50)
       
	   SELECT @DATE         = dbo.DATE_1601(DATECREATE),
                 @OrderNumber = CONVERT(VARCHAR(10), NRFISKALIZIM),
                 @Total       = CONVERT(VARCHAR(20), (CONVERT(DECIMAL(18, 2), 
				 (select sum(sasi*cmimm) from fDscr where nrd = @NrRendor))))
       FROM fD
       WHERE NRRENDOR = @NrRendor;

              SET @QrCodeLink = CASE WHEN @FiscUrL LIKE '%-TEST%' THEN 'https://efiskalizimi-app-test.tatime.gov.al/invoice-check/#/wtn?'
																	ELSE REPLACE('https://efiskalizimi-app-test.tatime.gov.al/invoice-check/#/wtn?', '-TEST', '')
																	END 
                                  + 'wtnic='   + @Iic
                                  + '&tin='     + @VatRegistrationNo
                                  + '&crtd='    + @Date
                                  + '&ord='   + @OrderNumber
                                  + '&bu='    + @BusinessUnit                     
                                  + '&sw='    + @SoftNum;
                                 -- + '&prc='   + @Total;

              if @ERROR = 0 
              begin

					
              update FD set 
                     NSLFSH = @fic,FISKALIZUAR=1,FISSTATUS='FISKALIZUAR',NRSERIAL=@fic
                     where nrrendor = @NrRendor
			  SET @OUTPUT1='0'
              end
			  ELSE
			  BEGIN
			  
			  
			  SET @OUTPUT1='Gabim ne fiskalizim'+@ERRORtext
			  update FD set 
                    FISSTATUS='PA FISKALIZUAR'
                     where nrrendor = @NrRendor

			  END

                     update FD set NIVFSH=@Iic,
                     errorlast = @error,errortextlast = @ERRORtext,XMLSTRING=@XMLSTRING,SIGNEDXML=@SIGNEDXML,QRCODELINK=@QrCodeLink
                     where nrrendor = @NrRendor
              
       --  SELECT @FIC, @ERROR, @ERRORtext, @XMLSTRING, @SIGNEDXML, @QRCODELINK
			  
			  PRINT @OUTPUT1

GO

ALTER   Procedure [dbo].[Isd_UpdateDetailRows]
( 
  @pNrRendor  Int,  
  @pPerqindje Float,
  @pDecimal   Int
 )
AS



       SET NOCOUNT OFF

   DECLARE @NrRendor     Int,
           @Perqindje    Float,
           @Decimal      Int

       SET @NrRendor   = @pNrRendor;
       SET @Perqindje  = @pPerqindje;
       SET @Decimal    = @pDecimal;
       
        IF NOT EXISTS(SELECT * FROM Sys.Columns WHERE OBJECT_ID=OBJECT_ID('SMSCR')    AND [NAME]='VLERASM')
           ALTER TABLE SMSCR ADD VLERASM FLOAT NULL;
        IF NOT EXISTS(SELECT * FROM Sys.Columns WHERE OBJECT_ID=OBJECT_ID('SMBAKSCR') AND [NAME]='VLERASM')
           ALTER TABLE SMBAKSCR ADD VLERASM FLOAT NULL;
           

    --UPDATE SMSCR
    --   SET VLERASM  =       CASE WHEN ISNULL(VLERASM,0) =0  THEN VLERABS ELSE          VLERASM END,
    --    -- VLERABS  = ROUND(CASE WHEN ISNULL(VLERASM,0) =0  THEN VLERABS ELSE          VLERASM END * @Perqindje/100, @Decimal),
    --       VLPATVSH = ROUND(CASE WHEN ISNULL(VLERASM,0) =0  THEN VLERABS ELSE          VLERASM END * @Perqindje/100  
    --                        / 
    --                        CASE WHEN ISNULL(PERQTVSH,0)=0  THEN 1       ELSE 1+(PERQTVSH/100) END, @Decimal)
    -- WHERE NRD=@pNrRendor;
    --
    --UPDATE SMSCR
    --   SET CMIMBS   = ROUND( CASE WHEN ISNULL(SASI,0)=0 THEN CMIMBS ELSE VLPATVSH/SASI END,@Decimal),
    --       VLTVSH   = ROUND((VLPATVSH * PERQTVSH)/100, @Decimal),
    --       VLERABS  = VLPATVSH + ROUND((VLPATVSH * PERQTVSH)/100, @Decimal)
    -- WHERE NRD=@pNrRendor;

    UPDATE SMSCR
       SET VLERASM  =       CASE WHEN ISNULL(VLERASM,0) =0  THEN VLERABS ELSE          VLERASM END,
           VLERABS  = ROUND(CASE WHEN ISNULL(VLERASM,0) =0  THEN VLERABS ELSE          VLERASM END * 
		                    CASE WHEN ISNULL(@Perqindje,0)=0 THEN 1 ELSE @Perqindje/100 END, @Decimal)
     WHERE NRD=@pNrRendor;

    UPDATE SMSCR
       SET VLPATVSH =            ROUND(VLERABS / CASE WHEN ISNULL(PERQTVSH,0)=0  THEN 1       ELSE 1+(PERQTVSH/100) END, 2),
           VLTVSH   = VLERABS  - ROUND(VLERABS / CASE WHEN ISNULL(PERQTVSH,0)=0  THEN 1       ELSE 1+(PERQTVSH/100) END, 2),
           CMIMBS   = ROUND( CASE WHEN ISNULL(SASI,0)=0 
                                  THEN CMIMBS 
                                  ELSE ROUND(VLERABS / CASE WHEN ISNULL(PERQTVSH,0)=0  THEN 1 ELSE 1+(PERQTVSH/100) END, 2)/SASI 
                             END,2),
           CMSHZB0  = ROUND( CASE WHEN ISNULL(SASI,0)=0 
                                  THEN CMIMBS 
                                  ELSE ROUND(VLERABS / CASE WHEN ISNULL(PERQTVSH,0)=0  THEN 1 ELSE 1+(PERQTVSH/100) END, 2)/SASI 
                             END,2),
           CMSHREF  = ROUND( CASE WHEN ISNULL(SASI,0)=0 
                                  THEN CMIMBS 
                                  ELSE ROUND(VLERABS / CASE WHEN ISNULL(PERQTVSH,0)=0  THEN 1 ELSE 1+(PERQTVSH/100) END, 2)/SASI 
                             END,2),
           PERQDSCN = 0
     WHERE NRD=@pNrRendor;
	 PRINT @pNrRendor

GO

ALTER PROCEDURE [dbo].[Isd_GatiFiskalFF]
(
 @pNrRendor Integer
)
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @TEMPOUTPUT VARCHAR(MAX)

	DECLARE @OUTPUT1 VARCHAR(MAX)
	DECLARE @OUTPUT2 VARCHAR(MAX)
	DECLARE @OUTPUT3 VARCHAR(MAX)
	DECLARE @OUTMESSAGE VARCHAR(MAX)
	DECLARE @TIPPAGESE VARCHAR(MAX)
	DECLARE @TIPKLIENT VARCHAR(MAX)
	DECLARE @SELF VARCHAR(MAX)
	DECLARE @NIPT VARCHAR(MAX)

	SET @NIPT=(SELECT NIPT FROM CONFND)
	SET @TEMPOUTPUT=''

	SET @TIPPAGESE=(SELECT top 1 KLASEPAGESE FROM FF A INNER JOIN FisMenPagese B ON  A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@pNrRendor)
	--SET @TIPKLIENT=(SELECT top 1 CASE WHEN ISNULL(TIPNIPT,'')='' THEN 'NUIS' ELSE TIPNIPT END FROM FJ A INNER JOIN KLIENT B ON A.KODFKL=B.KOD WHERE A.NRRENDOR=@pNrRendor)
	SET @TIPKLIENT=(SELECT top 1 ISNULL(A.TIPNIPT,B.TIPNIPT)  FROM FF A INNER JOIN FURNITOR B ON A.KODFKL=B.KOD WHERE A.NRRENDOR=@pNrRendor)
	SET @SELF=(SELECT CASE WHEN ISNULL(A.KLASETVSH,'') IN ('ABROAD','DOMESTIC','AGREEMENT','OTHER') THEN  A.KLASETVSH
										 WHEN ISNULL(A.KLASETVSH,'')='FANG' THEN 'ABROAD' 
									     ELSE  NULL END FROM FF A WHERE A.NRRENDOR=@pNrRendor)
	
	IF @SELF IN ('ABROAD','DOMESTIC','AGREEMENT','OTHER','FANG') AND ISNULL(@TIPKLIENT,'')<>'NUIS'
	BEGIN
					IF EXISTS(SELECT 1 FROM FF WHERE NRRENDOR = @pNrRendor 
						   AND FISLASTERRORFIC = '0'
						   AND (ISNULL(FISFIC, '') != '' AND FISKALIZUAR=1 AND ISNULL(FISRELATEDFIC,'')!=ISNULL(FISFIC, '') ) )	
					BEGIN
						SET @OUTPUT1='0'
						SET @OUTPUT2='0'
					END
					ELSE
						BEGIN
									EXEC Isd_FiscalFF @pNrRendor,0,@OUTPUT1 OUTPUT
								  --EXEC __FiscalCreateSalesXmlFJ2 @pNrRendor,@OUTPUT1 OUTPUT

									SET @OUTPUT2='0'
	
									IF ISNULL(@OUTPUT1,'') <> '0'
										SET @TEMPOUTPUT = ISNULL(@OUTPUT1,'') + char(10)+char(13)
						END
	END
	ELSE
	BEGIN
		
		IF ISNULL(@TIPKLIENT,'')='NUIS'
		SET @OUTPUT1='Fatura nuk mund te fiskalizohet. Tipi i Furnitorit nuk duhet NUIS'
		ELSE
		SET @OUTPUT1='Fatura nuk mund te fiskalizohet. Kujdes klase e tvsh tek koka e dokumentit'
		SET @OUTPUT2='0'
		IF ISNULL(@OUTPUT1,'') <> '0'
	SET @TEMPOUTPUT = ISNULL(@OUTPUT1,'') + char(10)+char(13)
	END

	if  (ISNULL(@OUTPUT1,'0')='0' and ISNULL(@OUTPUT2,'0')='0')
	set @OUTMESSAGE=''
	ELSE
	set @OUTMESSAGE = 'Gabim gjate procesit te deklarimit tatime....'+char(10)+ char(13) + @TEMPOUTPUT


	select @OUTPUT1 AS KodError1,@OUTPUT2 AS KodError2,@OUTMESSAGE AS MsgError
	
END



GO



ALTER PROC [dbo].[Isd_Fiscal_EIC]
	 @NrRendor	INT,
	 @IsInvoice bit,
	 @OUTPUT1	VARCHAR(MAX) OUTPUT  
AS
BEGIN	
		/*
		UPDATE CONFND SET FiscCertificate = (SELECT * FROM OPENROWSET( BULK 'C:\fiscal\isd.p12',  SINGLE_BLOB) AS a)
		*/
--BEGIN TRY
		DECLARE  @NIPT				VARCHAR(20)
				,@PerqZbr			FLOAT
				,@Date				VARCHAR(100)
				,@Nr				VARCHAR(10)
				,@VlerTot			VARCHAR(20)
				,@SoftNum			VARCHAR(1000)
				,@ManufacNum		VARCHAR(1000)
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
				,@SignedXml			VARCHAR(MAX)
				,@Error				VARCHAR(MAX)
				,@ErrorText			VARCHAR(MAX)
				,@XmlStringTemp		NVARCHAR(MAX)
				,@responseXml		XML
				,@hDOC				INT
				,@EIC				NVARCHAR(MAX)
				,@EICURL			NVARCHAR(MAX)
				,@FISUUID			VARCHAR(50)		
			    ,@BusinessUnit		VARCHAR(50)				-- element ne fature
			    ,@OperatorCode		VARCHAR(50)				-- element ne fature
			    ,@CashRegister		VARCHAR(50)
				,@TIPFISKAL			VARCHAR(50)
				,@KURS2				FLOAT
			    ,@FISMENPAGESEFIC	VARCHAR(50)
			    ,@FISMENPAGESEEIC	VARCHAR(50)
			    ,@MODEPAGESE		VARCHAR(50)
			    ,@KLASEPAGESE		VARCHAR(50)
			    ,@FISPROCES			VARCHAR(50)
			    ,@FISTIPDOK			VARCHAR(50)
				,@KODBANKE			VARCHAR(50)
				,@IBAN				VARCHAR(50)
				,@SWIFT				VARCHAR(50)
				,@BANPERSHKRIM		VARCHAR(50)
				,@XML				XML
				,@IsEinvoice		BIT
				,@SELF				VARCHAR(50)
				,@SENDDATETIME		VARCHAR(100)
				,@Fiscalize			BIT		= 1
				,@DATECREATE		DATETIME
				,@QrCodeLink		VARCHAR(1000)
				,@TIPPAGESE			VARCHAR(MAX)
				,@FISFIC			VARCHAR(MAX)
				,@FISFISFJ			VARCHAR(MAX)
				,@FISLASTERRORFIC	VARCHAR(MAX)
				,@FISLASTERRORTEXTFIC VARCHAR(MAX)
				,@FISQRCODELINK		VARCHAR(MAX)
				,@FISIIC			VARCHAR(MAX)
				,@FISIICSIG			VARCHAR(MAX)
				,@FISRESPONSEXMLFIC	XML
				,@FISXMLSTRING		VARCHAR(MAX)
				,@FISXMLSIGNED		VARCHAR(MAX)
				,@TIPKLIENT			VARCHAR(MAX)
				,@RELATEDFIC		VARCHAR(MAX)
				,@RELATEDDATE		DATETIME
				,@RELATEDTYPE		VARCHAR(MAX)
				,@FISDATEPARE		DATETIME
				,@FISDATEFUND		DATETIME
				,@FISTVSHEFEKT		INT
				,@SHENIMEEIC		VARCHAR(200)
				,@BADDEBT			VARCHAR(20)
			    ,@BUYERNAME			VARCHAR(100)
				,@BuyerIDNum		VARCHAR(100)
				,@BuyerIDType		VARCHAR(100)
				,@BuyerAddress		VARCHAR(100)
				,@BuyerTown		    VARCHAR(100)
				,@BuyerCountry      VARCHAR(100)
				,@IIC_FAT			VARCHAR(1000)
				,@MONEDHEBAZE       FLOAT
				,@KMON				VARCHAR(10);

SET @MONEDHEBAZE=ISNULL(ROUND((SELECT KURS1/KURS2 FROM MONEDHA WHERE KOD='ALL'),6),1)
		


  	SELECT 
			 @BUYERNAME			= CASE WHEN ISNULL(FJ.SHENIM1,'')<>'' THEN FJ.SHENIM1 ELSE KLIENT.PERSHKRIM END
			,@BuyerIDNum		= FJ.NIPT--CASE WHEN ISNULL(FJ.NIPT,'')<>'' THEN FJ.NIPT ELSE KLIENT.NIPT END
			,@BuyerIDType		= ISNULL(FJ.TIPNIPT,'')
			,@BuyerAddress		= CASE WHEN ISNULL(FJ.SHENIM2,'')<>'' THEN FJ.SHENIM2 ELSE KLIENT.ADRESA1 END
			,@BuyerTown		    = CASE WHEN ISNULL(FJ.RRETHI,'')<>'' THEN FJ.RRETHI ELSE KLIENT.ADRESA2 END
			,@BuyerCountry      = CASE WHEN ISNULL(VENDNDODHJE.KODCOUNTRY,'')<>'' 
																	  THEN VENDNDODHJE.KODCOUNTRY ELSE KLIENT.ADRESA3 END 
	FROM FJ INNER JOIN KLIENT ON FJ.KODFKL=KLIENT.KOD
			LEFT JOIN VENDNDODHJE ON KLIENT.VENDNDODHJE=VENDNDODHJE.KOD
	WHERE FJ.NRRENDOR=@NrRendor

	
		
   SET @SignedXml = '';
   SET @Fic = ISNULL(@Fic,'');


   

   SELECT    @NIPT				= CONFND.NIPT
		    ,@BusinessUnit      = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCBUSINESSUNIT')
		    ,@SoftNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSOFTNUM')
		    ,@ManufacNum        = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCMANUFACNUM')
			,@schema			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSCHEMA')
		    ,@FiscUrL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCURL')
			,@EICURL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'EICURL')
		    ,@CertificatePath   = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPATH')
		    ,@CertificatePwd    = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPASS')		
			,@Certificate		= FiscCertificate
			,@TIPFISKAL			= CASE WHEN ISNULL(KODFISKAL,'')='' THEN 'VAT' ELSE KODFISKAL END 
	FROM CONFND; 


	SET @IsEinvoice=@IsInvoice
	
	SET @SENDDATETIME		= dbo.DATE_1601(getdate())

	SELECT 	 @KURS2			= CASE WHEN @MONEDHEBAZE<>1 THEN 
																	CASE WHEN ISNULL(FJ.KMON,'')='' THEN @MONEDHEBAZE
																		 WHEN ISNULL(FJ.KMON,'')='ALL' THEN 1
																	ELSE  @MONEDHEBAZE*KURS2 END
								  ELSE KURS2 END
			, @KMON				= CASE WHEN @MONEDHEBAZE<>1 THEN 
																	CASE WHEN ISNULL(FJ.KMON,'')='' THEN 'EUR'
																		 WHEN ISNULL(FJ.KMON,'')='ALL' THEN ''
																	ELSE FJ.KMON END
								  ELSE KMON END
   FROM FJ WHERE NRRENDOR=@NrRendor


   		IF OBJECT_ID('tempdb..#fj') IS NOT NULL 
		DROP TABLE #FJ;

		IF OBJECT_ID('tempdb..#fjscr') IS NOT NULL 
		DROP TABLE #FJSCR;

		--IF OBJECT_ID('tempdb..#PAGESE') IS NOT NULL 
		--DROP TABLE #PAGESE;
	
		--SELECT VLERE = 100, TIP = 'BANKNOTE'
		--	INTO #PAGESE
		--	UNION ALL 
		--SELECT VLERE = 164, TIP = 'CARD'


		SELECT TOP 1 * INTO #FJ 
		FROM FJ 
		WHERE NRRENDOR=@NrRendor;

		SELECT  NRD,KARTLLG,
				S.PERSHKRIM,
				NJESI=CASE WHEN ISNULL(NJESI,'')='' THEN (SELECT TOP 1 KOD FROM NJESI) else NJESI END,
				SASI,
				CMIMBS=ROUND(CMIMBS,2),
				CMSHZB0MV=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND(CMSHZB0*@KURS2,2) ELSE  ROUND(ROUND(CMIMBS,2)*@KURS2,2) END,
				CMIMBSMV=CASE WHEN SASI=0 THEN ROUND(ROUND(CMIMBS*@KURS2,2),2) ELSE ROUND((VLERABS*(100/(100+S.PERQTVSH))*@KURS2)/SASI,2) END,
				CMIMBSTVSH = ROUND((VLERABS / CASE WHEN SASI = 0 THEN 1 ELSE SASI END),2),
				PERQTVSH=ROUND(S.PERQTVSH,2),--CASE WHEN ROUND(S.VLTVSH,2)=0 THEN 0 ELSE ROUND(S.PERQTVSH,2) END,
				VLPATVSH=ROUND(S.VLPATVSH,2),
				VLPATVSHMV=ROUND(VLERABS*(100/(100+S.PERQTVSH))*@KURS2,2),--ROUND(ROUND(S.VLPATVSH*@KURS2,2),2),
				VLTVSH=ROUND(VLERABS,2)-ROUND(S.VLPATVSH,2),--ROUND(S.VLTVSH,2),
				VLTVSHMV=ROUND(ROUND(VLERABS*@KURS2,2),2)-ROUND(VLERABS*(100/(100+S.PERQTVSH))*@KURS2,2),
				VLERABS=ROUND(VLERABS,2),
				VLERABSMV=ROUND(ROUND(VLERABS,2)*@KURS2,2),
				APLTVSH,
				CASE WHEN APLTVSH = 1 THEN 'true' ELSE 'false' END AS APLTVSHFIS,
				CASE WHEN APLINVESTIM = 1 THEN 'true' ELSE 'false' END AS APLINVESTIM,
				VLPATVSHTAXFREEAMOUNT=ROUND((CASE WHEN S.VLTVSH=0 AND ISNULL(KLASETVSH,'')<>'SEXP' AND KODTVSHFIC in ('TAX_FREE','TAX-FREE')
										THEN S.VLPATVSH ELSE 0 END)*@KURS2,2),
				--VLPATVSHTAXFREEAMOUNT= ROUND(CASE WHEN ISNULL(KLASETVSH,'')='SEXP' THEN 0
				--							WHEN KODTVSHFIC NOT IN ('TYPE_1','TYPE_2') 
				--										THEN (CASE WHEN S.VLTVSH=0 
				--											  THEN ROUND(S.VLPATVSH,2) ELSE 0 END)*F.KURS2
				--						ELSE 0 END,2),
				MarkUpAmt= ROUND((CASE WHEN ISNULL(KLASETVSH,'')='SEXP' THEN 0
								WHEN KODTVSHFIC ='MARGIN_SCHEME' 
									THEN ROUND(S.VLPATVSH,2) 
								ELSE 0 
								END)*F.KURS2,2),
				PERQDSCN=CASE WHEN TIPKLL<>'L' THEN ROUND(PERQDSCN,2) ELSE 0 END,
				VLERAZBR=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND((SASI*CMSHZB0)-(SASI*CMIMBS),2) ELSE 0 END,
				VLERAZBRMV=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND(((SASI*CMSHZB0)-(SASI*CMIMBS))*@KURS2,2) ELSE 0 END,
				VLERAPAZBR=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND(SASI*CMSHZB0,2) ELSE  ROUND(S.VLPATVSH,2) END,
				VLERAPAZBRMV=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND(SASI*CMSHZB0*@KURS2,2) ELSE  ROUND(S.VLPATVSH*@KURS2,2) END,
				EXTVSHFIC=REPLACE(KODTVSHFIC,'TAX-FREE','TAX_FREE'),
				EXTVSHEIC=KODTVSHEIC

		--SELECT * FROM KLASATATIM WHERE NRD=1086		
		  
		INTO #FJSCR 
		FROM FJ F
		INNER JOIN FJSCR S ON F.NRRENDOR = S.NRD
		LEFT JOIN KLASATATIM K ON S.KODTVSH=K.KOD
		WHERE NRD = @NrRendor;



	
		CREATE INDEX FJSCR_Idx ON #FJSCR(NRD)




	SELECT  
			  --@DATECREATE			= CASE WHEN @IsEinvoice=0 THEN FJ.DATECREATE 
					--				  ELSE 
					--				  CASE WHEN abs(DATEDIFF(minute,getdate(),FJ.DATECREATE))>60 THEN getdate()
					--					   ELSE FJ.DATECREATE END
				 --                 END
			 @DATECREATE			= FJ.DATECREATE
			 ,@DATE					= dbo.DATE_1601(FJ.DATECREATE)
				                 
			--, @DATE				= CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 
			--						   THEN @SENDDATETIME ELSE dbo.DATE_1601(@DATECREATE) END--dbo.DATE_1601( CASE WHEN @IsEinvoice=1 THEN getdate() ELSE FJ.DATECREATE END)		--> kujdes data duhet edhe me pjesen e ORE-s
			, @Nr				= CONVERT(VARCHAR(15), CONVERT(BIGINT, NRFISKALIZIM))
			, @VlerTot			= CONVERT(VARCHAR(20), (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLERABSMV),2)) FROM #FJSCR))
			, @PerqZbr			= ISNULL(PERQZBR, 0)
			, @IicBlank			= @NIPT
									+ '|' + dbo.DATE_1601(FJ.DATECREATE) 
									+ '|' + CONVERT(VARCHAR(MAX), CONVERT(BIGINT, NRFISKALIZIM))
									+ '|' + LOWER(FISBUSINESSUNIT) 
									+ '|' + LOWER(tcr.KODTCR) 
									+ '|' + @SoftNum 
									+ '|' + CONVERT(VARCHAR(MAX), (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLERABSMV),2)) FROM #FJSCR))
			, @CashRegister		= LOWER(tcr.KODTCR)
			, @OperatorCode		= LOWER(oper.KODFISCAL)
			, @BusinessUnit		= LOWER(FISBUSINESSUNIT)
			, @FISMENPAGESEFIC	= pag.KODFIC
			, @FISMENPAGESEEIC	= pag.KODEIC
			, @MODEPAGESE		= CASE WHEN PAG.KLASEPAGESE = 'ARKE' THEN 'CASH' ELSE 'NONCASH' END
			, @KLASEPAGESE		= CASE WHEN PAG.KLASEPAGESE = 'ARKE' THEN 'CASH' ELSE 'NONCASH' END
			, @FISPROCES		= FISPROCES
			, @FISTIPDOK		= FISTIPDOK
			, @FISUUID			= FISUUID
			--, @KURS2			= KURS2
			, @KODBANKE			= pag.SHENIM1
			, @IBAN				= (SELECT TOP 1 B.IBAN      FROM BANKAT B WHERE KOD = ISNULL(PAG.KODREFERENCE,pag.SHENIM1))
			, @SWIFT			= (SELECT TOP 1 B.SWIFTCODE FROM BANKAT B WHERE KOD = ISNULL(PAG.KODREFERENCE,pag.SHENIM1))
			, @BANPERSHKRIM		= (SELECT TOP 1 B.PERSHKRIM   FROM BANKAT B WHERE KOD = ISNULL(PAG.KODREFERENCE,pag.SHENIM1))
			--, @SELF				= CASE WHEN FJ.NIPT=@NIPT AND ISNULL(FJ.KLASETVSH,'')<>'SANG' THEN  'SELF' 
			--						   WHEN FJ.KLASETVSH='SANG' THEN 'DOMESTIC' 
			--						   ELSE  NULL END
			
			,@SELF=(SELECT CASE WHEN ISNULL(FJ.KLASETVSH,'') ='SANG' THEN 'ABROAD'
								WHEN ISNULL(FJ.KLASETVSH,'') ='SELF' THEN 'SELF'
								WHEN ISNULL(FJ.KLASETVSH,'') ='OTHER' THEN 'OTHER'
								ELSE  NULL END )
			/*OPTIONAL:  AGREEMENT - The previous agreement between the parties., 
						  DOMESTIC - Purchase from domestic farmers., 
						  ABROAD - Purchase of services from abroad., 
						  SELF - Self-consumption., 
						  OTHER - Other 
			*/
			, @TIPPAGESE		= PAG.KLASEPAGESE
			, @TIPKLIENT		= (SELECT TIPNIPT FROM KLIENT WHERE KOD=FJ.KODFKL)
			, @RELATEDFIC		= ISNULL(FJ.FISRELATEDFIC,'')
			, @RELATEDTYPE		= CASE WHEN FJ.LLOJDOK IN ('FK','T') THEN 'CORRECTIVE' 
									   WHEN FJ.LLOJDOK='CRN' THEN 'CREDIT'
									   WHEN FJ.LLOJDOK='DBN' THEN 'DEBIT' ELSE NULL END
			, @UniqueIdentif	= CASE WHEN ISNULL(FISUUID,'') = '' 
									   THEN NEWID()
									   ELSE FJ.FISUUID END

									   --WHENCASE WHEN @IsEinvoice=1 THEN NEWID() 
									   --WHEN ISNULL(FISUUID,'')='' THEN NEWID()
									   --ELSE FISUUID END
			,@FISDATEPARE		= ISNULL(FISDATEPARE,DTDSHOQ)
			,@FISDATEFUND		= ISNULL(FISDATEFUND,DTDSHOQ)		
			,@FISTVSHEFEKT		= ISNULL(FISTVSHEFEKT,'35')
			,@SHENIMEEIC		= FJ.SHENIME
			,@FISFISFJ			= FJ.FISFIC--CASE WHEN  DATEDIFF(DAY,FJ.DATECREATE,GETDATE())>2 THEN '' ELSE FJ.FISFIC END
			,@BADDEBT			= CASE WHEN ISNULL(FJ.KLASETVSH,'')='SBKQ' THEN KLASETVSH ELSE NULL END
			,@IIC_FAT			= ISNULL(FJ.FISIIC,'')
	FROM FJ 
	LEFT JOIN FisTCR tcr ON FJ.FISTCR = tcr.KOD
	LEFT JOIN FisOperator oper ON FJ.FISKODOPERATOR = oper.KOD
	LEFT JOIN FisMenPagese pag ON FJ.FISMENPAGESE = pag.KOD
	WHERE fj.NRRENDOR = @NrRendor;
	
--	SET NOCOUNT ON;
	--SET @UniqueIdentif = NEWID();
	
	
		IF OBJECT_ID('tempdb..#BANKAT') IS NOT NULL 
		DROP TABLE #BANKAT;
	
		SELECT FISMENPAGESEFIC=@FISMENPAGESEFIC,FISMENPAGESEEIC=@FISMENPAGESEEIC,
		IBAN,BANPERSHKRIM=ISNULL(SHENIM2,PERSHKRIM),SWIFT=SWIFTCODE INTO #BANKAT
		FROM BANKAT
		WHERE ISNULL(IBAN,'')<>'' AND @MODEPAGESE<>'CASH'
		ORDER BY SHENIM1


		IF OBJECT_ID('tempdb..#FJSTORNIM') IS NOT NULL 
		DROP TABLE #FJSTORNIM;


		 SELECT RELATEDFIC=CASE WHEN ISNULL(FISIIC,'')='' 
								THEN RIGHT(NRSERIAL,32)  
							--	THEN RIGHT('00000000000000000000000000000000'+NRSERIAL,32)  
								ELSE  FISIIC END,
		 RELATEDDATE=DATEDOKCREATE ,RELATEDTYPE=@RELATEDTYPE,NRRENDOR
		 INTO #FJSTORNIM
		 FROM FJSTORNIMSCR 
		 WHERE NRD=@NrRendor

		-- SELECT * FROM #FJSTORNIM
	
		 --SET @RELATEDDATE=(SELECT TOP 1 DATECREATE FROM FJ WHERE FISIIC=@RELATEDFIC AND NRRENDOR<>@NrRendor)

		 SET @RELATEDFIC=(SELECT TOP 1 RELATEDFIC FROM #FJSTORNIM)
	
/*
		CASE WHEN (@RELATEDFIC<>'' AND @RELATEDTYPE='CORRECTIVE') THEN
											( 
											SELECT
												--RIGHT('0000000000000000000000000000000000000012345678',32)		AS '@IICRef',				-- IIC reference on the original invoice.
												--DBO.DATE_1601(@RELATEDDATE)	AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.
												@RELATEDFIC		AS '@IICRef',				-- IIC reference on the original invoice.
												DBO.DATE_1601(@RELATEDDATE)	AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.

												@RELATEDTYPE	AS '@Type'
											 FOR XML PATH ('CorrectiveInv'), TYPE

											)
											ELSE NULL END

*/





						--SELECT * INTO #FJSCR 
						--FROM FJSCR 
						--WHERE NRD=@NrRendor


		UPDATE #FJ SET	VLTVSH		=	(SELECT ROUND(SUM(round(VLERABS-VLPATVSH,2)),2) FROM #FJSCR),
						VLPATVSH	=	(SELECT ROUND(SUM(round(VLPATVSH,2)),2) FROM #FJSCR),
						VLERTOT		=	(SELECT ROUND(SUM(round(VLERABS,2)),2) FROM #FJSCR),
						KMON		=	CASE WHEN @KMON = '' THEN 'ALL' ELSE @KMON END,
						KURS2		=   @KURS2 ;
	
	SELECT  @FISFIC					=FISFIC,
					--@FISLASTERRORFIC		=@Error,
					--@FISLASTERRORTEXTFIC	=@Errortext ,
					@FISQRCODELINK			=FISQRCODELINK,
					@FISIIC					=FISIIC,
					@FISIICSIG				=FISIICSIG,
					--@FISRESPONSEXMLFIC		=@responseXml,
					@FISXMLSTRING			=FISXMLSTRING,	
					@FISXMLSIGNED			=FISXMLSIGNED,
					@BADDEBT				=CASE WHEN ISNULL(KLASETVSH,'')='SBKQ' THEN 'Po' ELSE 'Jo' END
	FROM FJ WHERE NRRENDOR=@NrRendor
	
	DECLARE @TRANSPORTUES VARCHAR(50),
			@TARGA		  VARCHAR(50),
			@TRANSDATA	  VARCHAR(50),
			@TRANSORA     VARCHAR(50),
			@TRANSADRES   VARCHAR(50),
			@TRANSNIPT	  VARCHAR(50),
			@SumOfTaxableAmountLek float,
			@AmountWoVatLek float,
			@AmountWithVatLek float

IF ISNULL(@KMON,'')<>''
BEGIN
	SELECT  @SumOfTaxableAmountLek=SUM(VLPATVSHMV),
			@AmountWoVatLek=SUM(VLPATVSHMV),
			@AmountWithVatLek=SUM(VLERABSMV)
	FROM #FJSCR
END
	--SELECT * FROM FJSHOQERUES WHERE NRD=3279

	select TOP 1 @TRANSPORTUES='Emri i Transportuesit:		'+CONVERT(VARCHAR,TRANSPORTUES),
		@TARGA='Targa e mjetit:			'+CONVERT(VARCHAR,TARGE),
		@TRANSDATA='Data e Furnizimit:			'+CONVERT(VARCHAR,[DATE],103),
		@TRANSORA='Ora e Furnizimit:			'+CONVERT(VARCHAR,[time]),
		@TRANSADRES='Adresa e Transportuesit:	'+CONVERT(VARCHAR,LEFT(SHENIM1,50)),
		@TRANSNIPT='Nipti i Transportuesit:	'+CONVERT(VARCHAR,NIPT)
	FROM FJSHOQERUES WHERE NRD=@NrRendor AND ISNULL(TRANSPORTUES,'')<>''


	IF @IsInvoice=1 
	BEGIN

			SET @SignedXml = '';
			SET @XML =''
	 
			;WITH XMLNAMESPACES ('cbc' AS cbc, 'cac' AS cac)
			SELECT @XML = (
			SELECT TOP 1 
				'UBLExtensions' AS 'A',
				'urn:cen.eu:en16931:2017' AS 'cbc:CustomizationID',
				--'P1' AS 'cbc:ProfileID',
				ISNULL(@FISPROCES,'P1') AS 'cbc:ProfileID',
				CONVERT(VARCHAR(10), CONVERT(BIGINT, NRFISKALIZIM)) + '/' + CONVERT(VARCHAR(4), YEAR(@DATECREATE)) + CASE WHEN @MODEPAGESE = 'CASH' THEN + '/' + ISNULL(@CashRegister, 'ABCDEF') ELSE '' END AS 'cbc:ID',
				--CONVERT(VARCHAR(10), CONVERT(BIGINT, NRDSHOQ)) + '/' + CONVERT(VARCHAR(4), YEAR(@DATECREATE)) + CASE WHEN @MODEPAGESE <> 'CASH' THEN + '/' + ISNULL(@CashRegister, 'ABCDEF') ELSE '' END AS 'cbc:ID',
				REPLACE(CONVERT(VARCHAR, @DATECREATE, 111), '/', '-') AS 'cbc:IssueDate',		
				REPLACE(CONVERT(VARCHAR, DTDSHOQ + ISNULL(DTAF, 0), 111), '/', '-')  AS 'cbc:DueDate',
				ISNULL(@FISTIPDOK,'380')	AS 'cbc:InvoiceTypeCode',
  				(	
					SELECT * FROM 
					(
						SELECT	'CurrencyExchangeRate=' + CONVERT(VARCHAR(10), @KURS2) +'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	'IssueDateTime=' + ISNULL(dbo.DATE_1601(@DATECREATE), '') +'#AAI#'  AS 'cbc:Note'
						UNION ALL
						SELECT	'OperatorCode='+ ISNULL(@OperatorCode, '')+'#AAI#' AS 'cbc:Note' --> duhet kodi i operatorit
						UNION ALL
						SELECT	'RemarkNote='+ISNULL(@SHENIMEEIC,'')+'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	'BusinessUnitCode='+ ISNULL(@BusinessUnit, '')+'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	'SoftwareCode='+ ISNULL(@SoftNum, '')+'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	'CurrencyExchangeRate=' + CONVERT(VARCHAR(10),@KURS2) +'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	'CurrencyIsBuying=false#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	'IsBadDebtInv='+@BADDEBT+'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT 'IIC=' + ISNULL(@FISIIC, '') +'#AAI#' AS 'cbc:Note' 
						UNION ALL
						SELECT	'IICSignature=' + ISNULL(@FISIICSIG, '')+'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	'FIC=' +ISNULL(@FISFIC, '')+'#AAI#' AS 'cbc:Note' --> DUHET FISCFIC
						UNION ALL
						SELECT	''+@TRANSPORTUES+'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	''+@TRANSADRES+'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	''+@TRANSNIPT+'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	''+@TARGA+'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	''+@TRANSDATA+'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	''+@TRANSORA+'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	'SumOfTaxableAmountLek='+CONVERT(VARCHAR,CONVERT(DECIMAL(20, 2),@SumOfTaxableAmountLek))+'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	'AmountWoVatLek='+CONVERT(VARCHAR,CONVERT(DECIMAL(20, 2),@AmountWoVatLek))+'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	'AmountWithVatLek='+CONVERT(VARCHAR,CONVERT(DECIMAL(20, 2),@AmountWithVatLek))+'#AAI#' AS 'cbc:Note'
					
						--UNION ALL
						--SELECT	KMON  +'#AAI#' AS 'cbc:Note'
						--UNION ALL
						--SELECT @SoftNum +'#AAI#' AS 'cbc:Note'
					) A
					FOR XML PATH(''), TYPE
				),		
				KMON AS 'cbc:DocumentCurrencyCode',
				'ALL' AS 'cbc:TaxCurrencyCode',

		
				(
						SELECT TOP 1 
									 REPLACE(CONVERT(VARCHAR, CAST(@FISDATEPARE AS datetime), 111), '/', '-') AS 'cac:InvoicePeriod/cbc:StartDate',
									 REPLACE(CONVERT(VARCHAR, CAST(@FISDATEFUND AS datetime), 111), '/', '-') AS 'cac:InvoicePeriod/cbc:EndDate',
									 --REPLACE(CONVERT(VARCHAR, CAST(eomonth(DTDSHOQ) AS datetime), 111), '/', '-') AS 'cac:InvoicePeriod/cbc:EndDate',
									 @FISTVSHEFEKT  AS 'cac:InvoicePeriod/cbc:DescriptionCode'
						FROM #FJ 			
						FOR XML PATH(''), TYPE
					),	
		
				CASE WHEN ISNULL(@RELATEDFIC,'')='' THEN NULL ELSE (
						SELECT TOP 1 
									 RIGHT(RELATEDFIC,32) AS 'cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID',
									 REPLACE(CONVERT(VARCHAR, CAST(RELATEDDATE AS datetime), 111), '/', '-') AS 'cac:BillingReference/cac:InvoiceDocumentReference/cbc:IssueDate'
								
						 FROM #FJSTORNIM 
						 ORDER BY NRRENDOR			
						FOR XML PATH(''), TYPE
					) END,	

				(
						SELECT ISNULL(PERSHKRIM, '') AS 'cac:AdditionalDocumentReference/cbc:ID',
							   --ISNULL(PERSHKRIM, '') AS 'cac:AdditionalDocumentReference/cbc:DocumentType',
							   ISNULL(PERSHKRIM, 'Test')+'.' + REPLACE(PDFOBJEKTEXT, '.', '') AS 'cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@filename',
							   'application/' + REPLACE(lower(PDFOBJEKTEXT), '.', '') AS 'cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@mimeCode',
							 --  cast('' as xml).value(  'xs:base64Binary(sql:column("OBJECTSLINK.OBJEKT"))', 'VARCHAR(MAX)'  )  AS 'cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject'
							   (SELECT CAST(PDFOBJEKT AS VARBINARY(MAX)) FOR XML PATH(''), BINARY BASE64) AS 'cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject'
						FROM OBJECTSLINK
						WHERE TABELA = 'FJ' and REPLACE(PDFOBJEKTEXT, '.', '')='pdf'
						AND NRD = @NrRendor
						FOR XML PATH(''), TYPE
		
				),
		
				(
					SELECT TOP 1  
									'9923'              AS 'cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID',
									NIPT		        AS 'cac:AccountingSupplierParty/cac:Party/cbc:EndpointID',
									'9923:'+NIPT		AS 'cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID',
									PERSHKRIM	        AS 'cac:AccountingSupplierParty/cac:Party/cac:PartyName/cbc:Name',
									isnull(SHENIM1,'Mungon Adresa')  AS 'cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName',
									ISNULL(SHENIM2,'Mungon Rrethi')	 AS 'cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName',
									'AL'			    AS 'cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode',
								--  'RRUGA SALES'		AS 'cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName',
								--	'ALB'			    AS 'cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity',
									'AL:'+NIPT		    AS 'cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID',
									--'VAT'		        AS 'cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID',
									CASE WHEN @TIPFISKAL='VAT' THEN @TIPFISKAL else 'FRE'end	        AS 'cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID',
									PERSHKRIM	        AS 'cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName',
									NIPT		        AS 'cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID'
					FROM CONFND
					FOR XML PATH(''), TYPE
		
				),
		
				(
					SELECT TOP 1	'9923'				AS 'cac:AccountingCustomerParty/cac:Party/cbc:EndpointID/@schemeID',
									@BuyerIDNum		    AS 'cac:AccountingCustomerParty/cac:Party/cbc:EndpointID',
									'9923:'+@BuyerIDNum	AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID',
									@BUYERNAME	AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name',
									@BuyerAddress		AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName',
									@BuyerTown		    AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName',
									'AL'			    AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode',
								--	KLIENT.ADRESA2	    AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName',
								--	'ALB'				AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity',
									'AL:'+@BuyerIDNum    AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID',
									CASE WHEN ISNULL(KLIENT.KODFISKAL,'') IN ('','VAT') THEN 'VAT' else 'FRE'end  AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID',
									@BUYERNAME	AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName',
									@BuyerIDNum		    AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID'

					FROM KLIENT
					--LEFT JOIN VENDNDODHJE V ON KLIENT.VENDNDODHJE = V.KOD
					WHERE KLIENT.KOD = S.KODFKL
					FOR XML PATH(''), TYPE
				),
			 
				--@FISMENPAGESEEIC	 AS 'cac:PaymentMeans/cbc:PaymentMeansCode',
				--@FISMENPAGESEFIC	AS 'cac:PaymentMeans/cbc:InstructionNote',
				--@IBAN AS 'cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:ID',
				--@BANPERSHKRIM AS 'cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:Name',
				--@SWIFT AS 'cac:PaymentMeans/cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID',
				(SELECT   FISMENPAGESEEIC	 AS 'cac:PaymentMeans/cbc:PaymentMeansCode',
				FISMENPAGESEFIC	AS 'cac:PaymentMeans/cbc:InstructionNote',
				IBAN AS 'cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:ID',
				BANPERSHKRIM AS 'cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:Name',
				SWIFT AS 'cac:PaymentMeans/cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID'
				
				FROM #BANKAT
				FOR XML PATH(''), TYPE
				),   	
			   /*
				KMON AS 'cac:AllowanceCharge/cbc:BaseAmount/@currencyID',
				CONVERT(DECIMAL(20, 2), VLERZBR) AS 'cac:AllowanceCharge/cbc:BaseAmount',
				'false' AS 'cac:AllowanceCharge/cbc:ChargeIndicator',

				CONVERT(DECIMAL(20, 2), VLERZBR) AS 'cac:AllowanceCharge/cbc:MultiplierFactorNumeric',*/
		

				/*
					S - Per tvsh 20,10,6
					K - Per exportet brenda BE-se
					G - Per export jashte BE-se
					E - Përjashtim nga taksa
					AE- Auto ngarkesa e TVSH-së
					Z - Norma zero
					O - Jashtë fushës së TVSh-së
					L - IGIC Ishujt Kanarie 
					M - IPSI Taksa Ceute dhe Melille (Reklama & Tabela)
				
				*/
				(	SELECT  KMON AS 'cbc:TaxAmount/@currencyID'
						  , CONVERT(DECIMAL(20, 2), ROUND(SUM(round(F.VLTVSH,2)),2)) AS 'cbc:TaxAmount'
				  
					FROM #FJSCR F
					WHERE NRD = S.NRRENDOR 
					FOR XML PATH(''), TYPE
				)  AS 'cac:TaxTotal',

				( SELECT   
							KMON AS 'cac:TaxSubtotal/cbc:TaxableAmount/@currencyID'
						  , CONVERT(DECIMAL(20, 2), ROUND(SUM(round(F.VLPATVSH,2)),2)) AS 'cac:TaxSubtotal/cbc:TaxableAmount'
						  , KMON AS 'cac:TaxSubtotal/cbc:TaxAmount/@currencyID'
						  , CONVERT(DECIMAL(20, 2), ROUND(SUM(round(F.VLTVSH,2)),2)) AS 'cac:TaxSubtotal/cbc:TaxAmount'
						  , CASE WHEN PERQTVSH=20 THEN  ISNULL(F.EXTVSHEIC,'S')
								 WHEN PERQTVSH=0 and APLTVSH=0 THEN  ISNULL(F.EXTVSHEIC,'E')
								 WHEN PERQTVSH=0 and APLTVSH=1 THEN  ISNULL(F.EXTVSHEIC,'Z')
								 WHEN KLASETVSH='SEXP' THEN 'K'
					 			 ELSE 'S' END AS 'cac:TaxSubtotal/cac:TaxCategory/cbc:ID' 
						  , CONVERT(DECIMAL(20, 2), PERQTVSH) AS 'cac:TaxSubtotal/cac:TaxCategory/cbc:Percent'
						  , CASE WHEN  PERQTVSH=0 and ISNULL(F.EXTVSHEIC,'') NOT IN ('Z','O') THEN 'VATEX-EU-O' ELSE NULL END AS 'cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReasonCode'
						  , CASE WHEN  PERQTVSH=0 and ISNULL(F.EXTVSHEIC,'') NOT IN ('Z','O') THEN 'Not subject to VAT' ELSE NULL END AS 'cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReason'
						  --, CASE WHEN  PERQTVSH=0 and APLTVSH=0 THEN 'VATEX-EU-O' ELSE NULL END AS 'cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReasonCode'
						  --, CASE WHEN  PERQTVSH=0 and APLTVSH=0 THEN 'Not subject to VAT' ELSE NULL END AS 'cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReason'
						 , 'VAT' AS 'cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:ID'
					FROM #FJSCR F 
					WHERE NRD = S.NRRENDOR 
					GROUP BY F.PERQTVSH,APLTVSH,EXTVSHEIC
					ORDER BY F.PERQTVSH,APLTVSH,EXTVSHEIC DESC			
					FOR XML PATH(''), TYPE
				)  AS 'cac:TaxTotal',
				CASE WHEN KMON='ALL' THEN null else (SELECT   
							'ALL' AS 'cbc:TaxAmount/@currencyID'
						  , CONVERT(DECIMAL(20, 2), ROUND(SUM(F.VLTVSHMV),2)) AS 'cbc:TaxAmount'
				  
					FROM #FJSCR F
					WHERE NRD = S.NRRENDOR
					FOR XML PATH(''), TYPE
				) end AS 'cac:TaxTotalALL',
				--TOTALS
				KMON AS 'cac:LegalMonetaryTotal/cbc:LineExtensionAmount/@currencyID',
				CONVERT(DECIMAL(20, 2), S.VLPATVSH) AS 'cac:LegalMonetaryTotal/cbc:LineExtensionAmount', -- Totali i të gjitha shumave neto për artikujt në një Faturë
				KMON AS 'cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount/@currencyID',		
				CONVERT(DECIMAL(20, 2), S.VLPATVSH) AS 'cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount',  -- Shuma totale e faturës pa TVSH
				KMON AS 'cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount/@currencyID',		
				CONVERT(DECIMAL(20, 2), S.VLERTOT) AS 'cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount',   -- Shuma totale e faturës me TVSH
				KMON AS 'cac:LegalMonetaryTotal/cbc:PrepaidAmount/@currencyID',
				CONVERT(DECIMAL(20, 2), 0) AS 'cac:LegalMonetaryTotal/cbc:PrepaidAmount',				 -- Totali i shumave të parapaguara.
				KMON AS 'cac:LegalMonetaryTotal/cbc:PayableRoundingAmount/@currencyID',
				CONVERT(DECIMAL(20, 2), 0) AS 'cac:LegalMonetaryTotal/cbc:PayableRoundingAmount',		 -- Shuma e cila duhet të shtohet në total për të rrumbullakosur shumën e pagesës.
				KMON AS 'cac:LegalMonetaryTotal/cbc:PayableAmount/@currencyID',
				CONVERT(DECIMAL(20, 2), S.VLERTOT) AS 'cac:LegalMonetaryTotal/cbc:PayableAmount',				 -- Mbetja e shumës së pagesës
		
				(SELECT   KARTLLG AS 'cac:InvoiceLine/cbc:ID',
						  CASE WHEN ISNULL(NJESI,'')=''THEN'XPP'ELSE (SELECT TOP 1 KODEIC FROM NJESI WHERE NJESI.KOD=F.NJESI) END AS 'cac:InvoiceLine/cbc:InvoicedQuantity/@unitCode',
						  CONVERT(DECIMAL(20, 2), SASI) AS 'cac:InvoiceLine/cbc:InvoicedQuantity',
						  KMON AS 'cac:InvoiceLine/cbc:LineExtensionAmount/@currencyID',
						  CONVERT(DECIMAL(20, 2), ROUND(VLPATVSH,2)) AS 'cac:InvoiceLine/cbc:LineExtensionAmount',
						 --VLERAZBR
						  /*
								<ns3:AllowanceCharge>
									<ChargeIndicator>false</ChargeIndicator>
									<AllowanceChargeReason>Aaaaa</AllowanceChargeReason>
									<Amount currencyID="ALL">11.9</Amount>
									<BaseAmount currencyID="ALL">18.79</BaseAmount>
									</ns3:AllowanceCharge>

						  */

						  CASE WHEN PERQZBR=0 THEN NULL ELSE 'false' END AS'cac:InvoiceLine/cac:AllowanceCharge/cbc:ChargeIndicator',
						  CASE WHEN PERQZBR=0 THEN NULL ELSE  'Zbritje sezonale' END AS'cac:InvoiceLine/cac:AllowanceCharge/cbc:AllowanceChargeReason',
						  CASE WHEN PERQZBR=0 THEN NULL ELSE KMON END AS 'cac:InvoiceLine/cac:AllowanceCharge/cbc:Amount/@currencyID',
						  CASE WHEN PERQZBR=0 THEN NULL ELSE 
									CASE WHEN ISNULL(VLERAZBR,0)=0 
											  THEN CONVERT(DECIMAL(20, 2),0) 
											  ELSE CONVERT(DECIMAL(20, 2),VLERAZBR) 
											  END END AS 'cac:InvoiceLine/cac:AllowanceCharge/cbc:Amount',
						  CASE WHEN PERQZBR=0 THEN NULL ELSE KMON END AS 'cac:InvoiceLine/cac:AllowanceCharge/cbc:BaseAmount/@currencyID',
						  CASE WHEN PERQZBR=0 THEN NULL ELSE 
									CASE WHEN ISNULL(VLERAPAZBR,0)=0 
										      THEN CONVERT(DECIMAL(20, 2),0) 
											  ELSE CONVERT(DECIMAL(20, 2),VLERAPAZBR) END END AS 'cac:InvoiceLine/cac:AllowanceCharge/cbc:BaseAmount',
						 
						  
						  PERSHKRIM AS 'cac:InvoiceLine/cac:Item/cbc:Name',
						  CASE WHEN PERQTVSH=20 THEN  ISNULL(F.EXTVSHEIC,'S') 
								 WHEN PERQTVSH=0 and APLTVSH=0 THEN  ISNULL(F.EXTVSHEIC,'E')
								 WHEN PERQTVSH=0 and APLTVSH=1 THEN  ISNULL(F.EXTVSHEIC,'Z')
								 WHEN KLASETVSH='SEXP' THEN 'K'
					 			 ELSE 'S' END 'cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory/cbc:ID',
						  CONVERT(DECIMAL(20, 2), PERQTVSH) AS 'cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent',
						 'VAT' AS 'cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory/cac:TaxScheme/cbc:ID',
						  KMON AS 'cac:InvoiceLine/cac:Price/cbc:PriceAmount/@currencyID',
						  CONVERT(DECIMAL(20, 2), ROUND(CMIMBS,2)) AS'cac:InvoiceLine/cac:Price/cbc:PriceAmount',
						  CASE WHEN ISNULL(NJESI,'')=''THEN'XPP'ELSE (SELECT TOP 1 KODEIC FROM NJESI WHERE NJESI.KOD=F.NJESI) END AS 'cac:InvoiceLine/cac:Price/cbc:BaseQuantity/@unitCode',		 		 
						  CONVERT(DECIMAL(20, 2), 1) AS 'cac:InvoiceLine/cac:Price/cbc:BaseQuantity'							 
					FROM #FJSCR F
					WHERE NRD = S.NRRENDOR
					FOR XML PATH(''), TYPE
				)   	
			FROM #FJ S 
			FOR XML PATH('Invoice'));

			--SELECT @XML
			SELECT @XmlString = REPLACE(CAST(@XML AS NVARCHAR(MAX)), ' xmlns:cac="cac" xmlns:cbc="cbc"', '');
	
			-- Ndryshon root per taxtotal
			SELECT @XmlString = REPLACE(@XmlString, 'cac:TaxTotalALL', 'cac:TaxTotal');
	
			--SELECT @XmlString

			SELECT @XmlString = REPLACE(@XmlString, '<Invoice>', '<Invoice xmlns:csc="urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2"
													 xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
													 xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
													 xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
													 xmlns:sac="urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2"
													 xmlns:sbc="urn:oasis:names:specification:ubl:schema:xsd:SignatureBasicComponents-2"
													 xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">');

			SET @XmlString = '<?xml version="1.0" encoding="UTF-8"?>' + @XmlString;

	
			SET @XmlStringTemp = REPLACE(@XmlString, '<A>UBLExtensions</A>', ' <ext:UBLExtensions>
								<ext:UBLExtension>
								<ext:ExtensionContent>
								<csc:UBLDocumentSignatures>
								<sac:SignatureInformation>'			
					+ '</sac:SignatureInformation>
					   </csc:UBLDocumentSignatures>
					   </ext:ExtensionContent>
					   </ext:UBLExtension>
					   </ext:UBLExtensions>');
/*
		IF @RELATEDTYPE='CREDIT'
			BEGIN
			SET @XmlStringTemp = REPLACE (@XmlStringTemp,'InvoiceLine','CreditNoteLine')
			SET @XmlStringTemp = REPLACE (@XmlStringTemp,'<Invoice xmlns:csc=','<CreditNote xmlns:csc=')
			SET @XmlStringTemp = REPLACE (@XmlStringTemp,'</Invoice>','</CreditNote>')
			END
	 
			--SELECT CAST(@XmlStringTemp AS XML) AS 'PARA'
	SELECT @XmlStringTemp AS 'PARA'
	*/
			--SET @XmlStringTemp = '<?xml version="1.0" encoding="UTF-8"?>' + @XmlStringTemp;
	
			EXEC _FiscalSignRequest @XmlStringTemp, @CertificatePath, @CertificatePwd, @Certificate, @SignedXml OUTPUT;	

			SET @SignedXml =  ' <ext:UBLExtensions>
								<ext:UBLExtension>
								<ext:ExtensionContent>
								<csc:UBLDocumentSignatures>
								<sac:SignatureInformation>'
					+ @SignedXml
					+ '</sac:SignatureInformation>
					   </csc:UBLDocumentSignatures>
					   </ext:ExtensionContent>
					   </ext:UBLExtension>
					   </ext:UBLExtensions>';

			SET @XmlString = REPLACE(@XmlString, '<A>UBLExtensions</A>', @SignedXml) ;
	
			--SET @XML = CAST(@XmlString AS XML);
/*
			 IF @RELATEDTYPE='CREDIT'
			BEGIN
			SET @XmlString = REPLACE (@XmlString,'InvoiceLine','CreditNoteLine')
			SET @XmlString = REPLACE (@XmlString,'<Invoice xmlns:csc=','<CreditNote xmlns:csc=')
			SET @XmlString = REPLACE (@XmlString,'</Invoice>','</CreditNote>')
			END
			
		
			sELECT @XmlString AS 'PAS'
	*/
			EXEC _Base64Encode @XmlString, @XmlString OUT;

			--SELECT @XmlString

			SET @XML  = (
				SELECT 
						--@SENDDATETIME AS 'Header/@SendDateTime',  -- MANDATORY: 
						CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 THEN @SENDDATETIME ELSE dbo.DATE_1601(@DATECREATE) END AS 'Header/@SendDateTime',  -- MANDATORY: 
						ISNULL(@UniqueIdentif,NEWID()) AS 'Header/@UUID',			 -- MANDATORY: Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
				(
					SELECT @XmlString AS 'EinvoiceEnvelope/UblInvoice'	     -- OPTIONAL:  AGREEMENT - The previous agreement between the parties., DOMESTIC - Purchase from domestic farmers., ABROAD - Purchase of services from abroad., SELF - Self-consumption., OTHER - Other 
					FOR XML PATH (''), TYPE
				)
			FOR XML PATH('RegisterEinvoiceRequest'));	

			--IF @RELATEDTYPE='CREDIT'
			--SET @XML=REPLACE(CAST(@xml AS NVARCHAR(MAX)),'UblInvoice','UblCreditNote')

			SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterEinvoiceRequest>','<RegisterEinvoiceRequest xmlns="https://Einvoice.tatime.gov.al/EinvoiceService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="1">') AS XML)
			--SELECT @XML;
			


			

			SET @XmlString = CAST(@XML AS NVARCHAR(MAX));
	
	      -- PRINT @XmlString
/*
		  IF @RELATEDTYPE='CREDIT'
			BEGIN
			SET @XmlString = REPLACE (@XmlString,'InvoiceLine','CreditNoteLine')
			SET @XmlString = REPLACE (@XmlString,'<Invoice xmlns:csc=','<CreditNote xmlns:csc=')
			SET @XmlString = REPLACE (@XmlString,'</Invoice>','</CreditNote>')
			END
			
			SELECT @XmlString AS 'PAS2'
*/	
			--DECLARE @useSystemProxy BIT
			--SET @useSystemProxy = CAST(0 AS BIT);

			EXEC _FiscalProcessRequest 
					@InputString		 = @XmlString,
					@CertificatePath	 = @CertificatePath, 
					@Certificatepassword = @CertificatePwd,
					@CertBinary			 = @Certificate,
					@Url				 = @EICURL,
					@Schema				 = @Schema,
					@ReturnValue		 = '',
					@useSystemProxy		 = '',
					@SignedXml			 = @SignedXml	OUTPUT, 
					@Fic				 = @Fic			OUTPUT, 
					@Error				 = @Error		OUTPUT, 
					@Errortext			 = @Errortext	OUTPUT,
					@responseXml		 = @responseXml OUTPUT;
					
--SELECT @Fic ,@Error, @Errortext, @responseXml, LEN(@XmlString), @SignedXml, @XmlString



			IF (@Error = '0')
				 BEGIN
					EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML,
					 '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" 
					 xmlns:ns2="https://Einvoice.tatime.gov.al/EinvoiceService/schema" />';

					SELECT @EIC = EIC
					FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:RegisterEinvoiceResponse')
					WITH
					(
						EIC VARCHAR (50) 'ns2:EIC'
					);
					EXEC sp_xml_removedocument @hDoc;

					UPDATE FJ SET		  
										  --FISFIC			    = @FISFIC,
										  --FISLASTERRORFIC		= @FISLASTERRORFIC,
										  --FISLASTERRORTEXTFIC	= @FISLASTERRORTEXTFIC,
										  --FISQRCODELINK			= @FISQRCODELINK,
										  --FISIIC				= CASE WHEN ISNULL(FISIIC,'')='' THEN @FISIIC ELSE FISIIC END,
										  --FISIICSIG				= CASE WHEN ISNULL(FISIICSIG,'')='' THEN @FISIICSIG ELSE FISIICSIG END,
										  --FISRESPONSEXMLFIC		= CONVERT(VARCHAR(MAX),@FISRESPONSEXMLFIC),
										  --FISXMLSTRING			= @FISXMLSTRING,
										  --FISXMLSIGNED			= @FISXMLSIGNED,
										  FISEIC				= @EIC,
										  FISRESPONSEXMLEIC		= CONVERT(VARCHAR(MAX),@responseXml),
										  FISLASTERROREIC		= @Error,
										  --FISUUID				= @UniqueIdentif,
										--  DATECREATE			= @DATECREATE,
										  FISKALIZUAR			= CASE WHEN ISNULL(@EIC,'')<>'' THEN 1 ELSE 0 END,
										  FISSTATUS				= CASE WHEN ISNULL(@EIC,'')<>'' THEN 'DELIVERED' ELSE '' END,
										  NRSERIAL				= FISFIC
										  WHERE NRRENDOR		= @NrRendor;
			
				 SET @OUTPUT1 = ISNULL(@Error, '');
			END;		 		
			ELSE 
			BEGIN
					
	
					IF (@responseXML IS NOT NULL)
							BEGIN TRY
								--SELECT @responseXML AS 'RESP';

								EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" />';

								SELECT @OUTPUT1 = ISNULL(faultcode, '') + ' - ' + ISNULL(faultstring, '')
								FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/SOAP-ENV:Fault')
								WITH
								(
									[faultcode]		NVARCHAR(MAX)	'faultcode',
									[faultstring]	NVARCHAR(MAX)	'faultstring'
								)
								ORDER BY [faultcode];
						
								EXEC sp_xml_removedocument @hDoc;
								
										IF(@Error = 50)
												BEGIN
												--PRINT 'ERRORI I TEMPIT '+@Error
													DECLARE @tempOutput VARCHAR(MAX),
															@tempDateFat DATETIME,
															@tempDateFat2 DATETIME,
															@tempNr	VARCHAR(50),
															@tempVlera float,
															@tempEic VARCHAR(50);
							
					
					
													SELECT @tempNr = CONVERT(VARCHAR(10), CONVERT(BIGINT, NRFISKALIZIM)) + '/' + CONVERT(VARCHAR(4), YEAR(DATECREATE)) + CASE WHEN @MODEPAGESE = 'CASH' THEN + '/' + ISNULL(@CashRegister, 'ABCDEF') ELSE '' END,
														   @tempDateFat = CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, DATECREATE))),
														   @tempDateFat2= CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, DATECREATE+1))),
														   @tempVlera=Vlertot
													FROM FJ 
													WHERE NRRENDOR = @NrRendor;

													EXEC __eInvoiceGetRequest '', 'SELLER', @tempDateFat, @tempDateFat2, 0, @tempOutput OUT

													IF OBJECT_ID(N'tempdb..##FisFjEicTemp') IS NOT NULL
													BEGIN
														set @tempEic=(select FISEIC = (SELECT TOP 1 EIC FROM ##FisFjEicTemp WHERE DocNumber = @tempNr AND ABS(AMOUNT-@tempVlera)<=1)
														from fj
														WHERE NRRENDOR = @NrRendor);
													END
													--SELECT @tempNr,@tempVlera,@tempEic
					 
													--PRINT 'tempEic'+@tempEic

													IF ISNULL(@tempEic,'')<>'' 
													BEGIN
													UPDATE FJ SET FISEIC = @tempEic,FISKALIZUAR=1,FISSTATUS = 'DELIVERED',NRSERIAL=FISFIC
													WHERE NRRENDOR = @NrRendor;				
													SET @OUTPUT1='0'
													END

												END	
				
							END TRY
							BEGIN CATCH
								SET @OUTPUT1 = ISNULL(@Errortext, '') + '-> CAN NOT PARSE RESPONSE';
							END CATCH
							ELSE 
								SET @OUTPUT1 = ISNULL(@Errortext, '');

				
					IF @Error = '0'
						SET @OUTPUT1=@Error
				  --  ELSE
						--SET @OUTPUT1=ISNULL(@Errortext, '')--+ISNULL(@OUTPUT1,'')+@FIC

				

						UPDATE FJ SET	  FISEIC				= @EIC,
										  FISRESPONSEXMLEIC		= CONVERT(VARCHAR(MAX),@responseXml),
										  FISLASTERRORTEXTEIC	= @ErrorText,
										  FISLASTERROREIC		= @Error,
										  FISKALIZUAR			= CASE WHEN ISNULL(@EIC,'')<>'' THEN 1 ELSE 0 END
						WHERE NRRENDOR		= @NrRendor AND FISKALIZUAR=0;

					--UPDATE FJ SET  FISLASTERROREIC		= @Error
					--			 , FISLASTERRORTEXTEIC	= @ErrorText
					--WHERE NRRENDOR=@NrRendor;

					--SET @OUTPUT1=ISNULL(@OUTPUT1,'')+@Errortext;

					--PRINT 'AA'+@OUTPUT1
			END;


	END ----IF INVOICE=1
	
 END;

GO



GO
ALTER PROC [dbo].[Isd_Fiscal_FIC]
	 @NrRendor	INT,
	 @IsInvoice bit,
	 @OUTPUT1	VARCHAR(MAX) OUTPUT  
AS
BEGIN	
		/*
		UPDATE CONFND SET FiscCertificate = (SELECT * FROM OPENROWSET( BULK 'C:\fiscal\isd.p12',  SINGLE_BLOB) AS a)
		*/
--BEGIN TRY
		DECLARE  @NIPT				VARCHAR(20)
				,@PerqZbr			FLOAT
				,@Date				VARCHAR(100)
				,@Nr				VARCHAR(10)
				,@VlerTot			VARCHAR(20)
				,@SoftNum			VARCHAR(1000)
				,@ManufacNum		VARCHAR(1000)
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
				,@SignedXml			VARCHAR(MAX)
				,@Error				VARCHAR(MAX)
				,@ErrorText			VARCHAR(MAX)
				,@XmlStringTemp		NVARCHAR(MAX)
				,@responseXml		XML
				,@hDOC				INT
				,@EIC				NVARCHAR(MAX)
				,@EICURL			NVARCHAR(MAX)
				,@FISUUID			VARCHAR(50)		
			    ,@BusinessUnit		VARCHAR(50)				-- element ne fature
			    ,@OperatorCode		VARCHAR(50)				-- element ne fature
			    ,@CashRegister		VARCHAR(50)
				,@TIPFISKAL			VARCHAR(50)
				,@KURS2				FLOAT
			    ,@FISMENPAGESEFIC	VARCHAR(50)
			    ,@FISMENPAGESEEIC	VARCHAR(50)
			    ,@MODEPAGESE		VARCHAR(50)
			    ,@KLASEPAGESE		VARCHAR(50)
			    ,@FISPROCES			VARCHAR(50)
			    ,@FISTIPDOK			VARCHAR(50)
				,@KODBANKE			VARCHAR(50)
				,@IBAN				VARCHAR(50)
				,@SWIFT				VARCHAR(50)
				,@BANPERSHKRIM		VARCHAR(50)
				,@XML				XML
				,@IsEinvoice		BIT
				,@SELF				VARCHAR(50)
				,@SENDDATETIME		VARCHAR(100)
				,@Fiscalize			BIT		= 1
				,@DATECREATE		DATETIME
				,@QrCodeLink		VARCHAR(1000)
				,@TIPPAGESE			VARCHAR(MAX)
				,@FISFIC			VARCHAR(MAX)
				,@FISFISFJ			VARCHAR(MAX)
				,@FISLASTERRORFIC	VARCHAR(MAX)
				,@FISLASTERRORTEXTFIC VARCHAR(MAX)
				,@FISQRCODELINK		VARCHAR(MAX)
				,@FISIIC			VARCHAR(MAX)
				,@FISIICSIG			VARCHAR(MAX)
				,@FISRESPONSEXMLFIC	XML
				,@FISXMLSTRING		VARCHAR(MAX)
				,@FISXMLSIGNED		VARCHAR(MAX)
				,@TIPKLIENT			VARCHAR(MAX)
				,@RELATEDFIC		VARCHAR(MAX)
				,@RELATEDDATE		DATETIME
				,@RELATEDTYPE		VARCHAR(MAX)
				,@FISDATEPARE		DATETIME
				,@FISDATEFUND		DATETIME
				,@FISTVSHEFEKT		INT
				,@SHENIMEEIC		VARCHAR(200)
				,@BADDEBT			VARCHAR(20)
			    ,@BUYERNAME			VARCHAR(100)
				,@BuyerIDNum		VARCHAR(100)
				,@BuyerIDType		VARCHAR(100)
				,@BuyerAddress		VARCHAR(100)
				,@BuyerTown		    VARCHAR(100)
				,@BuyerCountry      VARCHAR(100)
				,@IIC_FAT			VARCHAR(1000)
				,@MONEDHEBAZE       FLOAT
				,@KMON				VARCHAR(10);

SET @MONEDHEBAZE=ISNULL(ROUND((SELECT KURS1/KURS2 FROM MONEDHA WHERE KOD='ALL'),6),1)
		


  	SELECT 
			 @BUYERNAME			= CASE WHEN ISNULL(FJ.SHENIM1,'')<>'' THEN FJ.SHENIM1 ELSE KLIENT.PERSHKRIM END
			,@BuyerIDNum		= FJ.NIPT--CASE WHEN ISNULL(FJ.NIPT,'')<>'' THEN FJ.NIPT ELSE KLIENT.NIPT END
			,@BuyerIDType		= ISNULL(FJ.TIPNIPT,'')
			,@BuyerAddress		= CASE WHEN ISNULL(FJ.SHENIM2,'')<>'' THEN FJ.SHENIM2 ELSE KLIENT.ADRESA1 END
			,@BuyerTown		    = CASE WHEN ISNULL(FJ.RRETHI,'')<>'' THEN FJ.RRETHI ELSE KLIENT.ADRESA2 END
			,@BuyerCountry      = CASE WHEN ISNULL(VENDNDODHJE.KODCOUNTRY,'')<>'' 
																	  THEN VENDNDODHJE.KODCOUNTRY ELSE KLIENT.ADRESA3 END 
	FROM FJ INNER JOIN KLIENT ON FJ.KODFKL=KLIENT.KOD
			LEFT JOIN VENDNDODHJE ON KLIENT.VENDNDODHJE=VENDNDODHJE.KOD
	WHERE FJ.NRRENDOR=@NrRendor

	
		
   SET @SignedXml = '';
   SET @Fic = ISNULL(@Fic,'');


   

   SELECT    @NIPT				= CONFND.NIPT
		    ,@BusinessUnit      = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCBUSINESSUNIT')
		    ,@SoftNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSOFTNUM')
		    ,@ManufacNum        = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCMANUFACNUM')
			,@schema			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSCHEMA')
		    ,@FiscUrL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCURL')
			,@EICURL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'EICURL')
		    ,@CertificatePath   = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPATH')
		    ,@CertificatePwd    = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPASS')		
			,@Certificate		= FiscCertificate
			,@TIPFISKAL			= CASE WHEN ISNULL(KODFISKAL,'')='' THEN 'VAT' ELSE KODFISKAL END 
	FROM CONFND; 


	SET @IsEinvoice=@IsInvoice
	
	SET @SENDDATETIME		= dbo.DATE_1601(getdate())

	SELECT 	 @KURS2			= CASE WHEN @MONEDHEBAZE<>1 THEN 
																	CASE WHEN ISNULL(FJ.KMON,'')='' THEN @MONEDHEBAZE
																		 WHEN ISNULL(FJ.KMON,'')='ALL' THEN 1
																	ELSE  @MONEDHEBAZE*KURS2 END
								  ELSE KURS2 END
			, @KMON				= CASE WHEN @MONEDHEBAZE<>1 THEN 
																	CASE WHEN ISNULL(FJ.KMON,'')='' THEN 'EUR'
																		 WHEN ISNULL(FJ.KMON,'')='ALL' THEN ''
																	ELSE FJ.KMON END
								  ELSE KMON END
   FROM FJ WHERE NRRENDOR=@NrRendor


   		IF OBJECT_ID('tempdb..#fj') IS NOT NULL 
		DROP TABLE #FJ;

		IF OBJECT_ID('tempdb..#fjscr') IS NOT NULL 
		DROP TABLE #FJSCR;

		--IF OBJECT_ID('tempdb..#PAGESE') IS NOT NULL 
		--DROP TABLE #PAGESE;
	
		--SELECT VLERE = 100, TIP = 'BANKNOTE'
		--	INTO #PAGESE
		--	UNION ALL 
		--SELECT VLERE = 164, TIP = 'CARD'


		SELECT TOP 1 * INTO #FJ 
		FROM FJ 
		WHERE NRRENDOR=@NrRendor;

		SELECT  NRD,KARTLLG,
				PERSHKRIM = REPLACE(REPLACE(S.PERSHKRIM,CHAR(10),''),CHAR(13),''),
				NJESI=CASE WHEN ISNULL(NJESI,'')='' THEN (SELECT TOP 1 KOD FROM NJESI) else NJESI END,
				SASI,
				CMIMBS=ROUND(CMIMBS,2),
				CMSHZB0MV=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND(CMSHZB0*@KURS2,2) ELSE  ROUND(ROUND(CMIMBS*@KURS2,2),2) END,
				CMIMBSMV=CASE WHEN SASI=0 THEN ROUND(ROUND(CMIMBS*@KURS2,2),2) ELSE ROUND((VLERABS*(100/(100+S.PERQTVSH))*@KURS2)/SASI,2) END,
				CMIMBSTVSH = ROUND((VLERABS / CASE WHEN SASI = 0 THEN 1 ELSE SASI END),2),
				PERQTVSH=ROUND(S.PERQTVSH,2),--CASE WHEN ROUND(S.VLTVSH,2)=0 THEN 0 ELSE ROUND(S.PERQTVSH,2) END,
				VLPATVSH=ROUND(S.VLPATVSH,2),
				VLPATVSHMV=ROUND(VLERABS*(100/(100+S.PERQTVSH))*@KURS2,2),
				VLTVSH=ROUND(VLERABS,2)-ROUND(S.VLPATVSH,2),--ROUND(S.VLTVSH,2),
				VLTVSHMV=ROUND(ROUND(VLERABS*@KURS2,2),2)-ROUND(VLERABS*(100/(100+S.PERQTVSH))*@KURS2,2),
				VLERABS=ROUND(VLERABS,2),
				VLERABSMV=ROUND(ROUND(VLERABS*@KURS2,2),2),
				APLTVSH,
				CASE WHEN APLTVSH = 1 THEN 'true' ELSE 'false' END AS APLTVSHFIS,
				CASE WHEN APLINVESTIM = 1 THEN 'true' ELSE 'false' END AS APLINVESTIM,
				VLPATVSHTAXFREEAMOUNT=ROUND((CASE WHEN S.VLTVSH=0 AND ISNULL(KLASETVSH,'')<>'SEXP' AND KODTVSHFIC in ('TAX_FREE','TAX-FREE')
										THEN S.VLPATVSH ELSE 0 END)*@KURS2,2),
				VLPATVSHTAXFEEAMOUNT=ROUND((CASE WHEN S.VLTVSH=0 AND ISNULL(F.KLASETVSH,'')<>'SEXP' 
									                  AND KODTVSHFIC IN ('OTHER','PACK','BOTTLE','COMMISSION')
									THEN S.VLPATVSH ELSE 0 END)*@KURS2,2),
				--VLPATVSHTAXFREEAMOUNT= ROUND(CASE WHEN ISNULL(KLASETVSH,'')='SEXP' THEN 0
				--							WHEN KODTVSHFIC NOT IN ('TYPE_1','TYPE_2') 
				--										THEN (CASE WHEN S.VLTVSH=0 
				--											  THEN ROUND(S.VLPATVSH,2) ELSE 0 END)*F.KURS2
				--						ELSE 0 END,2),
				MarkUpAmt= ROUND((CASE WHEN ISNULL(KLASETVSH,'')='SEXP' THEN 0
								WHEN KODTVSHFIC ='MARGIN_SCHEME' 
									THEN ROUND(S.VLPATVSH,2) 
								ELSE 0 
								END)*F.KURS2,2),
				PERQDSCN=CASE WHEN TIPKLL<>'L' THEN ROUND(PERQDSCN,2) ELSE 0 END,
				VLERAZBR=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND((SASI*CMSHZB0)-(SASI*CMIMBS),2) ELSE 0 END,
				VLERAZBRMV=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND(((SASI*CMSHZB0*@KURS2)-(SASI*CMIMBS*@KURS2)),2) ELSE 0 END,
				VLERAPAZBR=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND(SASI*CMSHZB0,2) ELSE  ROUND(S.VLPATVSH,2) END,
				VLERAPAZBRMV=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND(SASI*CMSHZB0*@KURS2,2) ELSE  ROUND(S.VLPATVSH*@KURS2,2) END,
				EXTVSHFIC=CASE WHEN ISNULL(F.KLASETVSH,'')='SEXP' THEN 'EXPORT_OF_GOODS' ELSE REPLACE(KODTVSHFIC,'TAX-FREE','TAX_FREE') END,
				EXTVSHEIC=KODTVSHEIC

		--SELECT * FROM KLASATATIM WHERE NRD=1086		
		  
		INTO #FJSCR 
		FROM FJ F
		INNER JOIN FJSCR S ON F.NRRENDOR = S.NRD
		LEFT JOIN KLASATATIM K ON S.KODTVSH=K.KOD
		WHERE NRD = @NrRendor;



	
		CREATE INDEX FJSCR_Idx ON #FJSCR(NRD)




	SELECT  
			  --@DATECREATE			= CASE WHEN @IsEinvoice=0 THEN FJ.DATECREATE 
					--				  ELSE 
					--				  CASE WHEN abs(DATEDIFF(minute,getdate(),FJ.DATECREATE))>60 THEN getdate()
					--					   ELSE FJ.DATECREATE END
				 --                 END
			 @DATECREATE			= FJ.DATECREATE
			 ,@DATE					= dbo.DATE_1601(FJ.DATECREATE)
				                 
			--, @DATE				= CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 
			--						   THEN @SENDDATETIME ELSE dbo.DATE_1601(@DATECREATE) END--dbo.DATE_1601( CASE WHEN @IsEinvoice=1 THEN getdate() ELSE FJ.DATECREATE END)		--> kujdes data duhet edhe me pjesen e ORE-s
			, @Nr				= CONVERT(VARCHAR(15), CONVERT(BIGINT, NRFISKALIZIM))
			, @VlerTot			= CONVERT(VARCHAR(20), (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLERABSMV),2)) FROM #FJSCR))
			, @PerqZbr			= ISNULL(PERQZBR, 0)
			, @IicBlank			= @NIPT
									+ '|' + dbo.DATE_1601(FJ.DATECREATE) 
									+ '|' + CONVERT(VARCHAR(MAX), CONVERT(BIGINT, NRFISKALIZIM))
									+ '|' + LOWER(FISBUSINESSUNIT) 
									+ '|' + LOWER(tcr.KODTCR) 
									+ '|' + @SoftNum 
									+ '|' + CONVERT(VARCHAR(MAX), (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLERABSMV),2)) FROM #FJSCR))
			, @CashRegister		= LOWER(tcr.KODTCR)
			, @OperatorCode		= LOWER(oper.KODFISCAL)
			, @BusinessUnit		= LOWER(FISBUSINESSUNIT)
			, @FISMENPAGESEFIC	= pag.KODFIC
			, @FISMENPAGESEEIC	= pag.KODEIC
			, @MODEPAGESE		= CASE WHEN PAG.KLASEPAGESE = 'ARKE' THEN 'CASH' ELSE 'NONCASH' END
			, @KLASEPAGESE		= CASE WHEN PAG.KLASEPAGESE = 'ARKE' THEN 'CASH' ELSE 'NONCASH' END
			, @FISPROCES		= FISPROCES
			, @FISTIPDOK		= FISTIPDOK
			, @FISUUID			= FISUUID
			--, @KURS2			= KURS2
			, @KODBANKE			= pag.SHENIM1
			, @IBAN				= (SELECT TOP 1 B.IBAN      FROM BANKAT B WHERE KOD = ISNULL(PAG.KODREFERENCE,pag.SHENIM1))
			, @SWIFT			= (SELECT TOP 1 B.SWIFTCODE FROM BANKAT B WHERE KOD = ISNULL(PAG.KODREFERENCE,pag.SHENIM1))
			, @BANPERSHKRIM		= (SELECT TOP 1 B.PERSHKRIM   FROM BANKAT B WHERE KOD = ISNULL(PAG.KODREFERENCE,pag.SHENIM1))
			--, @SELF				= CASE WHEN FJ.NIPT=@NIPT AND ISNULL(FJ.KLASETVSH,'')<>'SANG' THEN  'SELF' 
			--						   WHEN FJ.KLASETVSH='SANG' THEN 'DOMESTIC' 
			--						   ELSE  NULL END
			
			,@SELF=(SELECT CASE WHEN ISNULL(FJ.KLASETVSH,'') ='SANG' THEN 'ABROAD'
								WHEN ISNULL(FJ.KLASETVSH,'') ='SELF' THEN 'SELF'
								WHEN ISNULL(FJ.KLASETVSH,'') ='OTHER' THEN 'OTHER'
								ELSE  NULL END )
			/*OPTIONAL:  AGREEMENT - The previous agreement between the parties., 
						  DOMESTIC - Purchase from domestic farmers., 
						  ABROAD - Purchase of services from abroad., 
						  SELF - Self-consumption., 
						  OTHER - Other 
			*/
			, @TIPPAGESE		= PAG.KLASEPAGESE
			, @TIPKLIENT		= (SELECT TIPNIPT FROM KLIENT WHERE KOD=FJ.KODFKL)
			, @RELATEDFIC		= ISNULL(FJ.FISRELATEDFIC,'')
			, @RELATEDTYPE		= CASE WHEN FJ.LLOJDOK IN ('FK','T') THEN 'CORRECTIVE' 
									   WHEN FJ.LLOJDOK='CRN' THEN 'CREDIT'
									   WHEN FJ.LLOJDOK='DBN' THEN 'DEBIT' ELSE NULL END
			, @UniqueIdentif	= CASE WHEN ISNULL(FISUUID,'') = '' 
									   THEN NEWID()
									   ELSE FJ.FISUUID END

									   --WHENCASE WHEN @IsEinvoice=1 THEN NEWID() 
									   --WHEN ISNULL(FISUUID,'')='' THEN NEWID()
									   --ELSE FISUUID END
			,@FISDATEPARE		= ISNULL(FISDATEPARE,DTDSHOQ)
			,@FISDATEFUND		= ISNULL(FISDATEFUND,DTDSHOQ)		
			,@FISTVSHEFEKT		= ISNULL(FISTVSHEFEKT,'35')
			,@SHENIMEEIC		= FJ.SHENIME
			,@FISFISFJ			= FJ.FISFIC--CASE WHEN  DATEDIFF(DAY,FJ.DATECREATE,GETDATE())>2 THEN '' ELSE FJ.FISFIC END
			,@BADDEBT			= CASE WHEN ISNULL(FJ.KLASETVSH,'')='SBKQ' THEN KLASETVSH ELSE NULL END
			,@IIC_FAT			= ISNULL(FJ.FISIIC,'')
	FROM FJ 
	LEFT JOIN FisTCR tcr ON FJ.FISTCR = tcr.KOD
	LEFT JOIN FisOperator oper ON FJ.FISKODOPERATOR = oper.KOD
	LEFT JOIN FisMenPagese pag ON FJ.FISMENPAGESE = pag.KOD
	WHERE fj.NRRENDOR = @NrRendor;
	
--	SET NOCOUNT ON;
	--SET @UniqueIdentif = NEWID();
	
	
		IF OBJECT_ID('tempdb..#BANKAT') IS NOT NULL 
		DROP TABLE #BANKAT;
	
		SELECT FISMENPAGESEFIC=@FISMENPAGESEFIC,FISMENPAGESEEIC=@FISMENPAGESEEIC,
		IBAN,BANPERSHKRIM=ISNULL(SHENIM2,PERSHKRIM),SWIFT=SWIFTCODE INTO #BANKAT
		FROM BANKAT
		WHERE ISNULL(IBAN,'')<>'' AND @MODEPAGESE<>'CASH'


		IF OBJECT_ID('tempdb..#FJSTORNIM') IS NOT NULL 
		DROP TABLE #FJSTORNIM;


		 SELECT RELATEDFIC=CASE WHEN ISNULL(FISIIC,'')='' 
								THEN RIGHT(NRSERIAL,32)  
							--	THEN RIGHT('00000000000000000000000000000000'+NRSERIAL,32)  
								ELSE  FISIIC END,
		 RELATEDDATE=DATEDOKCREATE ,RELATEDTYPE=@RELATEDTYPE,NRRENDOR
		 INTO #FJSTORNIM
		 FROM FJSTORNIMSCR 
		 WHERE NRD=@NrRendor

		-- SELECT * FROM #FJSTORNIM
	
		 --SET @RELATEDDATE=(SELECT TOP 1 DATECREATE FROM FJ WHERE FISIIC=@RELATEDFIC AND NRRENDOR<>@NrRendor)

		 SET @RELATEDFIC=(SELECT TOP 1 RELATEDFIC FROM #FJSTORNIM)
	
/*
		CASE WHEN (@RELATEDFIC<>'' AND @RELATEDTYPE='CORRECTIVE') THEN
											( 
											SELECT
												--RIGHT('0000000000000000000000000000000000000012345678',32)		AS '@IICRef',				-- IIC reference on the original invoice.
												--DBO.DATE_1601(@RELATEDDATE)	AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.
												@RELATEDFIC		AS '@IICRef',				-- IIC reference on the original invoice.
												DBO.DATE_1601(@RELATEDDATE)	AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.

												@RELATEDTYPE	AS '@Type'
											 FOR XML PATH ('CorrectiveInv'), TYPE

											)
											ELSE NULL END

*/





						--SELECT * INTO #FJSCR 
						--FROM FJSCR 
						--WHERE NRD=@NrRendor


		UPDATE #FJ SET	VLTVSH		=	(SELECT ROUND(SUM(round(VLERABS-VLPATVSH,2)),2) FROM #FJSCR),
						VLPATVSH	=	(SELECT ROUND(SUM(round(VLPATVSH,2)),2) FROM #FJSCR),
						VLERTOT		=	(SELECT ROUND(SUM(round(VLERABS,2)),2) FROM #FJSCR),
						KMON		=	CASE WHEN @KMON = '' THEN 'ALL' ELSE @KMON END,
						KURS2		=   @KURS2 ;
		--CASE WHEN VLTVSH = 0 AND APLTVSHFIS = 'false' and @TIPFISKAL='VAT' AND ISNULL(KLASETVSH,'')<>'SEXP'THEN 'TYPE_1'
		--											 WHEN VLTVSH = 0 AND APLTVSHFIS = 'false' and @TIPFISKAL='FRE' THEN 'TAX_FREE'
		--										     WHEN KLASETVSH='SEXP' THEN 'EXPORT_OF_GOODS' 
		--									    ELSE NULL END AS 'I/@EX',			-- OPTIONAL: 
		--																																		-- Exempt from VAT.
																																				-- TYPE_1 Exempt type 1. Exempted on the basis of Article 51 of the VAT law 
																																				-- TYPE_2 Exempt type 2. Exempted on the basis of Articles 53 and 54 of the VAT law 
																																				-- TAX_FREE Tax free amount. Sales without VAT that is exempted based on VAT law other then articles 51, 53 and 54 of VAT law, and is not margin scheme nor export of goods 
																																				-- MARGIN_SCHEME Margin scheme (Travel agents VAT scheme, second hand goods VAT scheme, works of art VAT scheme, collectors’ items and antiques VAT scheme etc.). 
																																				-- EXPORT_OF_GOODS Export of goods. No VAT.
												
		--SELECT * FROM #FJSCR

	---------------------------------------------FISKALIZIMI
		/* TE HIQET
		IF @TIPPAGESE='BANKE' AND @TIPKLIENT='NUIS'
		SET @IsEinvoice='true'
		ELSE 
		SET @IsEinvoice='false'
		PRINT @IsEinvoice
		PRINT @IsInvoice	
		*/
	
		--SELECT * FROM #FJ
		--SELECT * FROM #FJSCR
	IF ISNULL(@FISFISFJ,'')='' 
	BEGIN
	
		IF ISNULL(@IICBLANK,'')<>''
		EXEC _FiscalGenerateHash @IicBlank, @CertificatePath, @CertificatePwd, @Certificate, 
		@IIC OUTPUT, @IICSIGNATURE OUTPUT, @ERROR OUTPUT, @ERRORtext OUTPUT;



	
		--SELECT @IicBlank,@CertificatePath,@CertificatePwd,@Certificate,@Iic,@IicSignature,@Error,@ErrorText

	

		SET @XML  = (
						SELECT 
								CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 THEN @SENDDATETIME ELSE dbo.DATE_1601(@DATECREATE) END AS 'Header/@SendDateTime',  -- MANDATORY: 
							--	@SENDDATETIME AS 'Header/@SendDateTime',  -- MANDATORY: 
							--	'NOINTERNET' AS 'Header/@SubseqDelivType',
							CASE WHEN @IIC_FAT<>'' AND @IIC_FAT=@IIC THEN 'NOINTERNET' 
								 ELSE
										CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 
										then 'NOINTERNET' 
										else null end  
								END AS 'Header/@SubseqDelivType',	-- MANDATORY:  Duhet shtuar ne fature NOINTERNET, BOUNDBOOK, SERVICE, TECHNICALERROR
																							   -- NOINTERNET When TCR operates in the area where there is no Internet available. 
																							   -- BOUNDBOOK When TCR is not working and message cannot be created with TCR. 
																							   -- SERVICE When there is an issue with the fiscalization service that blocks fiscalization. 
																							   -- TECHNICALERROR When there is a temporary technical error at TCR side that prevents successful fiscalization
								--DUHET SHTUAR SUBSEQUENTDELIVERYTYPE
								@UniqueIdentif AS 'Header/@UUID',			 -- MANDATORY: Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
					--SELECT * FROM FJ WHERE NRRENDOR=147156
					(
							SELECT 
									@KLASEPAGESE AS '@TypeOfInv' -- MANDATORY: 
									,@SELF AS '@TypeOfSelfIss'    
				/*OPTIONAL:  AGREEMENT - The previous agreement between the parties., 
							  DOMESTIC - Purchase from domestic farmers., 
							  ABROAD - Purchase of services from abroad., 
							  SELF - Self-consumption., 
							  OTHER - Other 
				*/
								   --,'false' AS '@IsSimplifiedInv'							-- MANDATORY:
								   ,CASE WHEN @TIPFISKAL='VAT' THEN 'false' else 'true' end AS '@IsSimplifiedInv'
								   ,dbo.DATE_1601(@DATECREATE) AS '@IssueDateTime'			-- MANDATORY: 
								   ,@Nr + '/' + CONVERT(VARCHAR(4), YEAR(@DATECREATE)) + CASE WHEN @KLASEPAGESE = 'CASH' THEN + '/' + @CashRegister ELSE '' END AS '@InvNum'	-- MANDATORY: NQS CASH PERNDRYSHE BEJE BOSH @CashRegister -- > NrRendor vjetor qe fillon nga 1 ne fillim vit
																															/*
																															A. NUMERIC ORDINAL NUMBER OF INVOICE
																																AND CALENDER YEAR
																																Can contain only numbers 0-9, without leading 0.
																																(also field “InvOrdNum”)
																															B. CALENDER YEAR (YYYY)
																											
																															C. ECD CODE (also field “TCRCode”)
																																Unique ECD CODE that is registered in CIS
																															*/		
								   ,@Nr	AS '@InvOrdNum'						
								   ,@CashRegister	AS '@TCRCode'							--Duhet shtuar ne magazina/fature -- nr i tcr
								   --,'true'			AS '@IsIssuerInVAT'						-- MANDATORY: 
								   ,CASE WHEN @TIPFISKAL='VAT' THEN 'true' else 'false' end	AS '@IsIssuerInVAT'
																							/*
																								Possible values:
																									1. Taxpayer is registered for VAT – 1
																									2. TAXPAYER is not registered for VAT – 2
																							*/
								   --,'0.00'			AS '@TaxFreeAmt'						-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged
								   --,CASE WHEN @TIPFISKAL='VAT' THEN CONVERT(DECIMAL(20, 2), 0) else CONVERT(DECIMAL(20, 2), S.VLERTOT) end			AS '@TaxFreeAmt'						-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged
								   --,CASE WHEN @TIPFISKAL='VAT' THEN NULL ELSE (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHTAXFREEAMOUNT),2)) FROM #FJSCR) END AS '@TaxFreeAmt'-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged							   							   
								   ,CASE WHEN (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHTAXFREEAMOUNT),2)) FROM #FJSCR)-
											  (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHTAXFEEAMOUNT),2)) FROM #FJSCR)=0 THEN null 
										 else (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHTAXFREEAMOUNT),2)) FROM #FJSCR) end AS '@TaxFreeAmt'-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged							   							   
								   ,CASE WHEN (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(MarkUpAmt),2)) FROM #FJSCR)=0 THEN NULL
										 ELSE (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(MarkUpAmt),2)) FROM #FJSCR) END AS '@MarkUpAmt'						-- OPTIONAL: Amount related to special procedure for margin scheme
								   --,NULL			AS '@GoodsExAmt'						-- OPTIONAL: Amount of goods for export from the Republic of Albania. 
								   ,CASE WHEN KLASETVSH='SEXP' THEN (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLERABSMV),2)) FROM #FJSCR) ELSE NULL END			AS '@GoodsExAmt'						-- OPTIONAL: Amount of goods for export from the Republic of Albania. 
								   --,CONVERT(DECIMAL(18, 2), ROUND(VLPATVSH*S.KURS2,2))	AS '@TotPriceWoVAT'	-- MANDATORY: Total price of the invoice excluding VAT.
								   ,(SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHMV),2)) FROM #FJSCR)-(SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHTAXFEEAMOUNT),2)) FROM #FJSCR) AS '@TotPriceWoVAT'
								   --,CASE WHEN @TIPFISKAL='VAT' THEN CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2)) ELSE NULL end		AS '@TotVATAmt'		-- MANDATORY: Total VAT amount of the invoice. 
								   ,CASE WHEN KLASETVSH='SEXP' THEN NULL
										 WHEN @TIPFISKAL='VAT' AND (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLTVSHMV),2)) FROM #FJSCR)<>0 THEN (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLTVSHMV),2)) FROM #FJSCR)  
										 ELSE NULL end		AS '@TotVATAmt'		-- MANDATORY: Total VAT amount of the invoice. 
								   --,CONVERT(DECIMAL(18, 2), ROUND(VLERTOT*S.KURS2,2))	AS '@TotPrice'		-- MANDATORY: Total price of all items including taxes and discounts.
								   ,(SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLERABSMV),2)) FROM #FJSCR)	AS '@TotPrice'		-- MANDATORY: Total price of all items including taxes and discounts.
								   ,@OperatorCode	AS '@OperatorCode'						-- MANDATORY: Reference to the operator code, who is operating on TCR and issues invoices.
								   ,@BusinessUnit	AS '@BusinUnitCode'						-- MANDATORY: Business unit (premise) code. Duhet shtuar tek magazina, apo duhet shtuar ne fature? faturat vetem sherbim?				   
								   ,@SoftNum		AS '@SoftCode'							-- MANDATORY: Software code.
								   ,NULL			AS '@ImpCustDecNum'						-- OPTIONAL: Import customs declaration number. Only for internal usage. Must not be populated by a TCR.
								   ,@Iic			AS '@IIC'								-- MANDATORY: Duhet shtuar ne fature, Nr unik i cili behet me concat
								   ,@IicSignature	AS '@IICSignature'						-- MANDATORY: Shenjimi i iic
								   ,CASE WHEN KLASETVSH='SANG' THEN 'true' ELSE 'false'	END		AS '@IsReverseCharge'					-- MANDATORY: If true, the buyer is obliged to pay the VAT.	
								   ,NULL			AS '@PayDeadline'						-- OPTIONAL:  Last day for payment.		--> MANDATORY IF NON CASH
								   ,CASE WHEN @IsEinvoice='0' THEN 'false' ELSE 'true' END		AS '@IsEinvoice'
								   ,
									/*
									CASE WHEN EXISTS(SELECT 1 FROM FJ FREF WHERE ISNULL(FREF.FISIIC,'') = ISNULL(S.FISRELATEDFIC,'')) THEN
									(
										SELECT  ISNULL(FREF.FISIIC,'') AS '@IICRef',				-- IIC reference on the original invoice.
							 					ISNULL(DBO.DATE_1601(FREF.DATECREATE),DBO.DATE_1601(FREF.DATECREATE)) AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.
												CASE WHEN ISNULL(FREF.LLOJDOK,'') IN ('','01') 	THEN 'CORRECTIVE' ELSE 'DEBIT' END AS '@Type'				-- Type of the corrective invoice.
										FROM FJ FREF WHERE ISNULL(FREF.FISIIC,'') = ISNULL(S.FISRELATEDFIC,'')  
										AND ISNULL(S.FISRELATEDFIC,'')<>'' 
										--AND FREF.NRRENDOR=@NrRendor
										FOR XML PATH ('CorrectiveInv'), TYPE
									) ELSE NULL END						-- XML element groups data for an original invoice that will be corrected with current invoice.
								   ,
								  */

								 -- #FJSTRORNIM
							  /*
									CASE WHEN (@RELATEDFIC<>'' AND @RELATEDTYPE IN ('CORRECTIVE','CREDIT','DEBIT')) THEN
											( 
											SELECT
												--RIGHT('0000000000000000000000000000000000000012345678',32)		AS '@IICRef',				-- IIC reference on the original invoice.
												--DBO.DATE_1601(@RELATEDDATE)	AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.
												@RELATEDFIC		AS '@IICRef',				-- IIC reference on the original invoice.
												DBO.DATE_1601(@RELATEDDATE)	AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.

												@RELATEDTYPE	AS '@Type'
											 FOR XML PATH ('CorrectiveInv'), TYPE

											)
											ELSE NULL END
							  */
							  (CASE WHEN (@RELATEDFIC<>'' AND @RELATEDTYPE IN ('CORRECTIVE','CREDIT','DEBIT') AND @BADDEBT IS NULL) THEN
											( 
											SELECT TOP 1
												--RIGHT('0000000000000000000000000000000000000012345678',32)		AS '@IICRef',				-- IIC reference on the original invoice.
												--DBO.DATE_1601(@RELATEDDATE)	AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.
												RIGHT(RELATEDFIC,32)		AS '@IICRef',				-- IIC reference on the original invoice.
												DBO.DATE_1601(RELATEDDATE)	AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.

												RELATEDTYPE	AS '@Type'
											 FROM #FJSTORNIM 
											 ORDER BY NRRENDOR
											 FOR XML PATH ('CorrectiveInv'), TYPE



											)
											ELSE NULL END
											)
							  
								  ,

								   (CASE WHEN (@RELATEDFIC<>'' AND @RELATEDTYPE IN ('CORRECTIVE','CREDIT','DEBIT') AND @BADDEBT='SBKQ') THEN
											( 
											SELECT TOP 1
												--RIGHT('0000000000000000000000000000000000000012345678',32)		AS '@IICRef',				-- IIC reference on the original invoice.
												--DBO.DATE_1601(@RELATEDDATE)	AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.
												RIGHT(RELATEDFIC,32)		AS '@IICRef',				-- IIC reference on the original invoice.
												DBO.DATE_1601(RELATEDDATE)	AS '@IssueDateTime'		-- Date and time the original invoice is created and issued at TCR.

												
											 FROM #FJSTORNIM 
											 ORDER BY NRRENDOR
											 FOR XML PATH ('BadDebtInv'), TYPE



											)
											ELSE NULL END
											)
							  
								  ,
					/*			  
								  
								  CASE WHEN EXISTS(SELECT 1 FROM FJSCR WHERE 1 = 2) THEN	-- OPTIONAL: 
									(
										SELECT NULL AS 'BadDebtInv/@IICRef',				--IIC reference on the original invoice.
												NULL AS 'BadDebtInv/@IssueDateTime'			--Date and time the original invoice is created and issued at TCR.
										FOR XML PATH (''), TYPE
									 ) 	ELSE NULL END AS BadDebtInv							--XML element groups data for an original invoice that will be declared bad debt invoice, as uncollectible.				   
								   ,
								   
					*/			   
								   
								   
								    CASE WHEN EXISTS(SELECT 1 FROM FJSCR WHERE 1 = 2) THEN	-- MANDATORY case of Summary invoice:
									(														--XML element that contains one IIC reference, e.g. reference of the invoice that is part of the summary invoice.
										SELECT NULL AS 'SumInvIICRef/@IIC',					--IIC of the invoice that is referenced in the summary invoice.
											   NULL AS 'SumInvIICRef/@IssueDateTime'		--Date and time the invoice referenced by the summary invoice is created and issued at TCR.
										WHERE 1=2
										FOR XML PATH (''), TYPE	
									 ) ELSE NULL END AS SumInvIICRefs						--XML element that contains list of IIC-s to which this invoice referred to, e.g. if this is a summary invoice it 
																							--shall contain a reference to each individual invoice issued and fiscalized before and included in this summary invoice.
								   ,														-- OPTIONAL:  
									(
										SELECT	REPLACE(CONVERT(VARCHAR,CAST(CASE WHEN @FISTVSHEFEKT='432' THEN @DATECREATE ELSE @FISDATEPARE END AS datetime), 111), '/', '-') AS '@Start',		--Start day of the supply.
												REPLACE(CONVERT(VARCHAR,CAST(CASE WHEN @FISTVSHEFEKT='432' THEN @DATECREATE ELSE @FISDATEFUND END AS datetime), 111), '/', '-') AS '@End'	
												--REPLACE(CONVERT(VARCHAR,CAST(eomonth(dtdshoq) AS datetime), 111), '/', '-') AS '@End'			--End day of the supply.
										WHERE 1 = 1
										FOR XML PATH ('SupplyDateOrPeriod'), TYPE	
									  )										--XML element representing supply date or period of supply, if it is different from the date when the invoice was issued.
									,
									(														-- MANDATORY: 

										-- SELECT * FROM CONFIG..TIPDOK WHERE TIPDOK = 'S'
										--SELECT CONVERT(DECIMAL(18, 2), ROUND(S.VLERTOT*S.KURS2,2)) AS 'PayMethod/@Amt',
									   SELECT (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLERABSMV),2)) FROM #FJSCR) AS 'PayMethod/@Amt',
										@FISMENPAGESEFIC AS 'PayMethod/@Type',
										--SELECT CONVERT(DECIMAL(18, 2), ROUND(VLERE,2)) AS 'PayMethod/@Amt',
										--TIP AS 'PayMethod/@Type',
											  -- CASE WHEN MODPG = 'CA' THEN 'BANKNOTE'
													--WHEN MODPG = 'VO' THEN 'ACCOUNT'
													--WHEN MODPG = 'TT' THEN 'OTHER'
													--ELSE 'ACCOUNT' 
													--END AS 'PayMethod/@Type',			-- Type of the payment method.
											   NULL AS 'PayMethod/@CompCard',				-- Amount payed by payment method in the ALL.
											   (
												SELECT NULL AS 'Voucher/@Num'				--Voucher serial number
												WHERE 1=2				
												FOR XML PATH (''), TYPE
											   ) Vouchers	
										--FROM #PAGESE-- XML element that contains list of voucher numbers if the payment method is voucher.
										FOR XML PATH (''), TYPE	
									 ) PayMethods										--> MENYRA E PAGESES, PER CDO MENYRE PAGESE 
																							-- BANKNOTE, CARD, CHECK, SVOUCHER, COMPANY, ORDER   , ACCOUNT , FACTORING, COMPENSATION, TRANSFER, WAIVER  , KIND     , OTHER   
																							--  CASH   , CASH, CASH ,  CASH   , CASH   , NON CASH, NON CASH, NON CASH ,     NON CASH, NON CASH, NON CASH, NON CASH , NON CASH
									,
																							-- OPTIONAL:  
									(
										SELECT	KMON AS 'Currency/@Code',					--Currency code in which the amount on the invoice should be paid, if different from ALL.
												CONVERT(DECIMAL(18, 6), @KURS2) AS 'Currency/@ExRate'	
												--,				--Exchange rate applied to calculate the equivalent amount of foreign currency for the total amount expressed in ALL. Exchange rate express equivalent amount of ALL for 1 unit of foreign currency.
												--'false' AS 'Currency/@IsBuying'				--True if exchange transaction is buying of the foreign currency. False if exchange transaction is selling of the foreign currency.
										WHERE KMON NOT IN ('', 'ALL')						
										FOR XML PATH (''), TYPE	
									  )														--XML element representing currency in which the amount on the invoice should be paid, if different from ALL
								   ,(	--nga config -- SELECT * FROM CONFND
										SELECT PERSHKRIM AS 'Seller/@Name',					-- MANDATORY: 
											   @NIPT		 AS 'Seller/@IDNum',				-- MANDATORY:	
											   'NUIS'    AS 'Seller/@IDType',				 -- MANDATORY:	FIX
											   ISNULL(SHENIM1,'') AS 'Seller/@Address', -- MANDATORY FOR FOREIGNER:	FUSHA PER ADRESEN
											   ISNULL(SHENIM2,'Tirane')	 AS 'Seller/@Town',					 -- MANDATORY FOR FOREIGNER:    QYTETI
											   'ALB'     AS 'Seller/@Country'				 -- MANDATORY FOR FOREIGNER:    SHTETI
										FROM CONFND
										FOR XML PATH (''), TYPE
									) ,
									(	--nga klienti
										SELECT	REPLACE(@BUYERNAME, '"', '') AS 'Buyer/@Name',		-- OPTIONAL| MANDATORY B2B: 
												@BuyerIDNum					 AS 'Buyer/@IDNum',		-- OPTIONAL| MANDATORY B2B: 
																									/* This field is filled out if buyer is:
																											 a taxpayer of profit tax or a taxpayer of simplified profit tax for small businesses or a taxpayer who is subject to VAT in accordance with special regulations, or
																											 a legal entity to whom goods or services are provided in the territory of the Republic of Albania for the purpose of carrying out his economic activity; or
																											 if personal property of a single value is sold above 500,000 ALL;
																											 or in other cases when the buyer asks for this data to be entered into the invoice, but there is no control in that case. Also, this field is mandatory if the buyer issues the
																											invoice instead of the seller. If this field is entered, beside in the book of sales of the seller, this invoice will also appear in the book of purchase of the buyer if the buyer is a taxpayer.
																											If the buyer is an individual who requires invoice for recognition of the cost of the medication, no book of purchase will be created for him, but a special application will be created to register all the data on
																											all invoices where he has appeared as a buyer and that information will be exchanged with the CIS system. Also, data may be entered for a foreigner or diplomat who will request a VAT refund and this information will be exchanged with the CIS system as well.
																									*/
												ISNULL(@BuyerIDType,'NUIS')	 AS 'Buyer/@IDType',	-- OPTIONAL| MANDATORY B2B: 
																									-- NQS ESHTE PERSON FIZIK DUHET SPECIFIKUAR 
																									--> NDARES PER PERSON FIZIK APO SUBJEKT 
																									-- NUIS: NUIS-number | ID: Personal ID-number | PASS: Passport-number | VAT: VAT-number | TAX: TAX-number 
																						
												ISNULL(@BuyerAddress, '')	 AS 'Buyer/@Address',	-- OPTIONAL| MANDATORY IF NAME IS FILLED: 
												ISNULL(@BuyerTown, '')		 AS 'Buyer/@Town',		-- OPTIONAL| MANDATORY IF NAME IS FILLED: 
												CASE WHEN ISNULL(@BuyerCountry, '')='' THEN NULL ELSE ISNULL(@BuyerCountry, '') END    AS 'Buyer/@Country'	-- OPTIONAL| MANDATORY IF NAME IS FILLED: 	
									
										FROM KLIENT C
										WHERE C.KOD = S.KODFKL AND ISNULL(@BuyerIDNum,'')<>''
										--AND ISNULL(C.TIPNIPT, '') != ''
										FOR XML PATH (''), TYPE
									)
									,
										(	SELECT  KARTLLG AS 'I/@C',								-- OPTIONAL:  Code of the item from the barcode or similar representation
												LEFT(PERSHKRIM, 50) AS 'I/@N',						-- MANDATORY: Name of the item (goods or services).
												--CONVERT(DECIMAL(18, 2), VLPATVSH) AS 'I/@PA',		-- MANDATORY: Total price of goods after the tax and applying discounts Negative values allowed when CorrectiveInv or BadDebtInv exist.
												CONVERT(DECIMAL(18, 2), ROUND(VLERABSMV,2)) AS 'I/@PA',		-- MANDATORY: Total price of goods after the tax and applying discounts Negative values allowed when CorrectiveInv or BadDebtInv exist.
										--		CASE WHEN PERQDSCN<>0 THEN CONVERT(DECIMAL(18, 2), ROUND(VLERAPAZBRMV,2)) ELSE CONVERT(DECIMAL(18, 2), ROUND(VLPATVSHMV,2)) END AS 'I/@PB',		-- MANDATORY: Total price of goods and services before the tax Negative values allowed when CorrectiveInv or BadDebtInv exist.
											    CONVERT(DECIMAL(18, 2), ROUND(VLPATVSHMV,2)) AS'I/@PB',		-- MANDATORY: Total price of goods and services before the tax Negative values allowed when CorrectiveInv or BadDebtInv exist.
												CONVERT(DECIMAL(18, 2), ROUND(SASI,3)) AS 'I/@Q',			-- MANDATORY: Amount or number (quantity) of items. Negative values allowed when CorrectiveInv or BadDebtInv exist.
												CONVERT(DECIMAL(18, 2), PERQDSCN) AS 'I/@R',					-- OPTIONAL:  Percentage of the rebate.	
												CASE WHEN PERQDSCN<>0 AND VLTVSH<>0 THEN 'true' ELSE 'false' end AS 'I/@RR',	-- OPTIONAL:  Is rebate reducing tax base amount?
												NJESI AS 'I/@U',									-- MANDATORY: What is the item’s unit of measure (piece, weight measure, length measure, etc.)
												CASE WHEN PERQDSCN<>0 THEN CONVERT(DECIMAL(18, 2), ROUND(CMSHZB0MV,2)) ELSE CONVERT(DECIMAL(18, 2), ROUND(CMIMBSMV,2)) END AS 'I/@UPB',		-- MANDATORY: Unit price before Value added tax is applied
												--CONVERT(DECIMAL(18, 2), ROUND(CMIMBSMV,2)) AS 'I/@UPB',		-- MANDATORY: Unit price before Value added tax is applied
												--CONVERT(DECIMAL(18, 2), CMIMBS) AS 'I/@UPA',		-- MANDATORY: Unit price after Value added tax is applied
												CONVERT(DECIMAL(18, 2), ROUND(VLERABSMV/CASE WHEN SASI=0 THEN 1 ELSE ROUND(SASI,3) END,2)) AS 'I/@UPA',
								
												-- nuk duhet APLTVSH
												--CASE WHEN VLTVSH = 0 AND APLTVSHFIS = 'false' and @TIPFISKAL='VAT' AND ISNULL(KLASETVSH,'')<>'SEXP'THEN 'TYPE_1'
												--	 WHEN VLTVSH = 0 AND APLTVSHFIS = 'false' and @TIPFISKAL='FRE' THEN 'TAX_FREE'
												--     WHEN KLASETVSH='SEXP' THEN 'EXPORT_OF_GOODS' 
											 --   ELSE NULL END AS 'I/@EX',			-- OPTIONAL: 
											 CASE WHEN ISNULL(KLASETVSH,'')='SEXP' THEN 'EXPORT_OF_GOODS' 
												  WHEN @TIPFISKAL='FRE' THEN 'TAX_FREE' 
												  WHEN ISNULL(EXTVSHFIC,'') IN ('TYPE_1','TYPE_2','MARGIN_SCHEME') THEN ISNULL(EXTVSHFIC,'')
												  WHEN ISNULL(EXTVSHFIC,'')='VAT' THEN NULL
												  ELSE ISNULL(EXTVSHFIC,'') END AS 'I/@EX',
										 
										 
										 
											 --VLTVSH = 0 AND APLTVSHFIS = 'false' AND ISNULL(KLASETVSH,'')<>'SEXP'THEN 
												--								CASE WHEN EXTVSHFIC='VAT' THEN NULL ELSE EXTVSHFIC END
												--  WHEN VLTVSH = 0 AND APLTVSHFIS = 'false' and @TIPFISKAL='FRE' THEN 'TAX_FREE'
												--  WHEN KLASETVSH='SEXP' THEN 'EXPORT_OF_GOODS' 
											 --   ELSE NULL END AS 'I/@EX',			-- OPTIONAL: 
																																				-- Exempt from VAT.
																																				-- TYPE_1 Exempt type 1. Exempted on the basis of Article 51 of the VAT law 
																																				-- TYPE_2 Exempt type 2. Exempted on the basis of Articles 53 and 54 of the VAT law 
																																				-- TAX_FREE Tax free amount. Sales without VAT that is exempted based on VAT law other then articles 51, 53 and 54 of VAT law, and is not margin scheme nor export of goods 
																																				-- MARGIN_SCHEME Margin scheme (Travel agents VAT scheme, second hand goods VAT scheme, works of art VAT scheme, collectors’ items and antiques VAT scheme etc.). 
																																				-- EXPORT_OF_GOODS Export of goods. No VAT.
																					

												--CASE WHEN KLASETVSH='SEXP' THEN APLINVESTIM ELSE NULL END AS 'I/@IN',								-- If true, the item is investment for the buyer. Mandatory only for importation of goods.
												NULL AS 'I/@IN',								-- If true, the item is investment for the buyer. Mandatory only for importation of goods.
												--CASE WHEN KLASETVSH='SANG' THEN CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2))
												--	 WHEN ISNULL(@TIPFISKAL,'')<>'VAT' THEN NULL 
												--	 ELSE CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2)) END  AS 'I/@VA',		-- MANDATORY: Amount of value added tax for goods and services. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true. Negative values allowed when CorrectiveInv or BadDebtInv exist.
											
												--CASE WHEN KLASETVSH='SANG' THEN CONVERT(DECIMAL(18, 2), PERQTVSH)
												--	 WHEN (VLTVSH = 0 AND APLTVSHFIS = 'false') OR  ISNULL(@TIPFISKAL,'')<>'VAT' OR PERQTVSH=0 THEN NULL 
												--	 ELSE CONVERT(DECIMAL(18, 2), PERQTVSH) END AS 'I/@VR',		-- MANDATORY: Rate of value added tax. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true.
									CASE WHEN (EXTVSHFIC<>'VAT' OR ISNULL(@TIPFISKAL,'')<>'VAT' OR ISNULL(KLASETVSH,'')='SEXP') 
									THEN NULL ELSE  CONVERT(DECIMAL(18, 2), ROUND(VLTVSHMV,2)) END  AS 'I/@VA',

									CASE WHEN (EXTVSHFIC<>'VAT' OR ISNULL(@TIPFISKAL,'')<>'VAT' OR ISNULL(KLASETVSH,'')='SEXP') 
									THEN NULL ELSE  CONVERT(DECIMAL(18, 2), PERQTVSH) END AS 'I/@VR',
									--			CASE WHEN @TIPFISKAL='FRE' THEN NULL ELSE CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2)) END  AS 'I/@VA',		-- MANDATORY: Amount of value added tax for goods and services. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true. Negative values allowed when CorrectiveInv or BadDebtInv exist.
									--			CASE WHEN @TIPFISKAL='FRE' THEN NULL ELSE CONVERT(DECIMAL(18, 2), PERQTVSH) END AS 'I/@VR',		-- MANDATORY: Rate of value added tax. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true.
								
												CASE WHEN EXISTS(SELECT 1 FROM FJSCR WHERE 1 = 2) THEN
												(													-- OPTIONAL: 
													SELECT (SELECT NULL AS 'VD/@D',					-- Expiration date of the voucher.
																	NULL AS 'VD/@N'					-- Nominal voucher value.			
																										--> DUHET E GRUPUAR VETEM 1 ELEMENT
															FOR XML PATH(''), TYPE					-- XML element representing serial numbers of voucher sold.
															),	 
															(SELECT NULL AS 'V/@Num'				--Voucher serial number.
																										--> DUHET TE KTHEJE ARRAY ME ROOT VN
															FOR XML PATH(''), TYPE 					-- XML element representing serial numbers of voucher sold.
															) VN	 
													FOR XML PATH(''), TYPE
												) ELSE NULL END AS VS												-- XML element representing vouchers sold
								
										FROM #FJSCR C 		
										WHERE ISNULL(EXTVSHFIC,'') not in ('OTHER','PACK','BOTTLE','COMMISSION')			
										FOR XML PATH (''), TYPE
									) Items
									,																-- MANDATORY IF ISSUER IN VAT:
									(CASE WHEN ISNULL(KLASETVSH,'')<>'SEXP' THEN
										(	SELECT  CONVERT(VARCHAR(10), CONVERT(DECIMAL(18, 0), COUNT(1)))	  AS 'SameTax/@NumOfItems',
												CONVERT(DECIMAL(18, 2), ROUND(SUM(VLPATVSHMV),2))	      AS 'SameTax/@PriceBefVAT',
												CASE WHEN EXTVSHFIC NOT IN ('TYPE_1','TYPE_2') 
													 THEN CONVERT(DECIMAL(18, 2), PERQTVSH) ELSE NULL END AS 'SameTax/@VATRate',
												CASE WHEN EXTVSHFIC IN ('TYPE_1','TYPE_2') 
													 THEN EXTVSHFIC ELSE NULL END						  AS 'SameTax/@ExemptFromVAT',
												--APLTVSH												  AS 'SameTax/@ExemptFromVAT',		-- nuk duhet APLTVSH
																											-- Exempt from VAT.
																											-- TYPE_1 Exempt type 1. Exempted on the basis of Article 51 of the VAT law 
																											-- TYPE_2 Exempt type 2. Exempted on the basis of Articles 53 and 54 of the VAT law 
												CASE WHEN EXTVSHFIC NOT IN ('TYPE_1','TYPE_2')
												THEN CONVERT(DECIMAL(18, 2), ROUND(SUM(VLTVSHMV),2)) ELSE NULL END
												AS 'SameTax/@VATAmt'
										FROM #FJSCR
										--WHERE @TIPFISKAL='VAT' AND (PERQTVSH<>0 OR EXTVSHFIC IN ('TYPE_1','TYPE_2'))
										WHERE @TIPFISKAL='VAT' AND ISNULL(EXTVSHFIC,'') not in ('MARGIN_SCHEME','TAX_FREE','OTHER','PACK','BOTTLE','COMMISSION')
										GROUP BY PERQTVSH, EXTVSHFIC
										FOR XML PATH (''), TYPE
									) 
									ELSE
									NULL
									END)SameTaxes,
																								-- OPTIONAL:
									(	--per tu interpretuar cfare jane?
										SELECT  1		 AS 'ConsTax/@NumOfItems',				-- Number of items under consumption tax.
												VLPATVSH AS 'ConsTax/@PriceBefConsTax',			-- Price before adding consumption tax.
												PERQTVSH AS 'ConsTax/@ConsTaxRate',				-- Rate of the consumption tax.
												VLTVSH   AS 'ConsTax/@ConsTaxAmt'				-- Amount of consumption tax.
										FROM #FJSCR C 
										WHERE 1 = 2 -- NQS NUK KA REKORDE HIQET VETE SI TAG						
										FOR XML PATH (''), TYPE
									) ConsTaxes													-- XML element representing one cons tax item.
									, (															-- OPTIONAL: FEES
										SELECT  EXTVSHFIC	 AS 'Fee/@Type',						-- Type of the fee.
																									-- PACK Packaging fee 
																									-- BOTTLE Fee for the return of glass bottles 
																									-- COMMISSION Commission for currency exchange activities 
																									-- OTHER Other fees that are not listed here.
												CONVERT(DECIMAL(18, 2), SUM(VLPATVSHMV)) AS 'Fee/@Amt'							-- Amount of the fee.
										FROM #FJSCR C 
										WHERE EXTVSHFIC in ('OTHER','PACK','BOTTLE','COMMISSION')-- NQS NUK KA REKORDE HIQET VETE SI TAG
										GROUP BY EXTVSHFIC
										FOR XML PATH (''), TYPE
									) Fees														-- XML element representing list of fees.
						FROM #FJ  S
						WHERE S.NRRENDOR = @NrRendor
						FOR XML PATH('Invoice'), TYPE
					)
					FOR XML PATH('RegisterInvoiceRequest'));

				--SELECT @XML
    
					--Gjenerimi i url per kontrollin e fiskalizimit te fatures
					SET @QrCodeLink = CASE WHEN @FiscUrL LIKE '%-TEST%' THEN 'https://efiskalizimi-app-test.tatime.gov.al/invoice-check/#/verify?'
																		ELSE REPLACE('https://efiskalizimi-app-test.tatime.gov.al/invoice-check/#/verify?', '-TEST', '')
																		END 
									+ 'iic='	+ @Iic
									+ '&tin='	+ @NIPT
									+ '&crtd='	+ @DATE
									+ '&ord='   + @Nr
									+ '&bu='    + @BusinessUnit				
									+ '&cr='    + @CashRegister
									+ '&sw='    + @SoftNum
									+ '&prc='   + CONVERT(VARCHAR(50),(SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLERABSMV),2)) FROM #FJSCR));;  
				  -- SELECT 	@QrCodeLink,@Iic,@NIPT,@Date,@Nr,@BusinessUnit,@CashRegister,@SoftNum,@VlerTot
	
					SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterInvoiceRequest>','<RegisterInvoiceRequest xmlns="' + @Schema +'" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3">') AS XML)

					SELECT @XmlString = CAST(@XML AS VARCHAR(MAX))  

					--SELECT @XmlString


						UPDATE FJ SET		 
											  FISQRCODELINK			= @FISQRCODELINK,
											  FISIIC			= @IIC,
											  FISIICSIG			= @IICSIGNATURE,
											  FISXMLSTRING			= @XmlString,
											  FISUUID			= @UniqueIdentif,
											  EINVOICE			= @IsInvoice
											 
						WHERE NRRENDOR = @NrRendor


					IF(@Fiscalize != 0)	
					BEGIN
						--BEGIN TRY
							
							EXEC _FiscalProcessRequest 
								@InputString		 = @XmlString,
								@CertBinary		     = @Certificate,
								@CertificatePath	 = @CertificatePath, 
								@Certificatepassword = @CertificatePwd, 
								@Url				 = @FiscUrL,
								@Schema				 = @Schema,
								@ReturnValue		 = 'FIC',
								@useSystemProxy		 = '',
								@SignedXml			 = @SignedXml	OUTPUT, 
								@Fic				 = @Fic			OUTPUT, 
								@Error				 = @FISLASTERRORFIC		OUTPUT, 
								@Errortext			 = @FISLASTERRORTEXTFIC	OUTPUT,
								@responseXml		 = @responseXml OUTPUT;
					END			
					
		    --SELECT @Error,@FISLASTERRORFIC,@Errortext,@Fic	
			SET @Error=@FISLASTERRORFIC
		
				SELECT  @FISFIC					=@FIC,
						@FISLASTERRORFIC		=@FISLASTERRORFIC,
						@FISLASTERRORTEXTFIC	=@FISLASTERRORTEXTFIC ,
						@FISQRCODELINK			=@QrCodeLink,
						@FISIIC					=@IIC,
						@FISIICSIG				=@IICSIGNATURE,
						@FISRESPONSEXMLFIC		=@responseXml,
						@FISXMLSTRING			=@XmlString,	
						@FISXMLSIGNED			=@SignedXml
	
			IF(@Error != '0')
			BEGIN
				BEGIN TRY
					EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXml, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" />';

					SELECT @ErrorText = faultcode + ' - ' + faultstring
					FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/SOAP-ENV:Fault')
					WITH
					(
						[faultcode]		NVARCHAR(MAX)	'detail/code',
						[faultstring]	NVARCHAR(MAX)	'faultstring'
					)
					ORDER BY [faultcode];

					SET @FISLASTERRORTEXTFIC = ISNULL(@ErrorText,'')--+ ISNULL(@FISLASTERRORTEXTFIC,'')

					UPDATE FJ SET FISLASTERRORTEXTFIC = @ErrorText,FISLASTERRORFIC=@Error
					WHERE NRRENDOR = @NrRendor;

					EXEC sp_xml_removedocument @hDoc;
				END TRY
				BEGIN CATCH
					SET @Errortext = ISNULL(@Errortext, '') + '-> CAN NOT PARSE RESPONSE';

					SET @FISLASTERRORTEXTFIC = @ErrorText;

					UPDATE FJ SET FISLASTERRORTEXTFIC = @ErrorText
					WHERE NRRENDOR = @NrRendor;
				END CATCH
			END;
			ELSE
			BEGIN
					UPDATE FJ SET			  FisFic			= @FISFIC
											, FisIic			= @FISIic
											, FISQRCODELINK		= @QrCodeLink							   
					WHERE NRRENDOR = @NrRendor;

					--UPDATE #fj SET FisFic = @Fic, FisIic = @Iic;
			END
			
			
				IF @Error = '0' 
				BEGIN
				
						UPDATE FJ SET		  FISFIC			    = CASE WHEN @FISLASTERRORFIC = '0' AND ISNULL(@FISFISFJ,'')='' THEN @FISFIC ELSE '' END ,
											  FISLASTERRORFIC		= @FISLASTERRORFIC,
											  FISLASTERRORTEXTFIC	= @FISLASTERRORTEXTFIC,
											  FISQRCODELINK			= @FISQRCODELINK,
											  --FISIIC				= CASE WHEN ISNULL(FISIIC,'')='' THEN @FISIIC ELSE FISIIC END,
											  --FISIICSIG				= CASE WHEN ISNULL(FISIICSIG,'')='' THEN @FISIICSIG ELSE FISIICSIG END,
											  FISRESPONSEXMLFIC		= CONVERT(VARCHAR(MAX),@FISRESPONSEXMLFIC),
											  FISXMLSTRING			= @FISXMLSTRING,
											  FISXMLSIGNED			= @FISXMLSIGNED,
											  FISUUID				= @UniqueIdentif,
											  --DATECREATE			=@DATECREATE,
											  FISSTATUS		= CASE WHEN @FISLASTERRORFIC = '0' AND @IsEinvoice=0 THEN 'FISKALIZUAR' ELSE 'PA FISKALIZUAR' END,
											  FISEIC		= CASE WHEN @FISLASTERRORFIC = '0' AND @IsEinvoice=0 THEN 'FISKALIZUAR' ELSE '' END ,
											  FISKALIZUAR	= CASE WHEN @FISLASTERRORFIC = '0' AND @IsEinvoice=0 THEN 1 ELSE 0 END ,
											  NRSERIAL		= CASE WHEN @FISLASTERRORFIC = '0' AND @IsEinvoice=0 THEN @FISFIC ELSE NRSERIAL END
								WHERE NRRENDOR = @NrRendor

					
					IF @FISLASTERRORFIC = '0'
						SET @OUTPUT1=@FISLASTERRORFIC
					ELSE
						SET @OUTPUT1=ISNULL(@FISLASTERRORTEXTFIC,'')+@FISFIC
		

				END
				ELSE
					BEGIN
						IF @FISLASTERRORFIC = '0'
						SET @OUTPUT1=@FISLASTERRORFIC
					ELSE
						SET @OUTPUT1=ISNULL(@FISLASTERRORTEXTFIC,'')+@FISFIC
					END





				UPDATE FJ SET		 
											  FISQRCODELINK			= @FISQRCODELINK,
											  --FISIIC				= CASE WHEN ISNULL(FISIIC,'')='' THEN @FISIIC ELSE FISIIC END,
											  --FISIICSIG				= CASE WHEN ISNULL(FISIICSIG,'')='' THEN @FISIICSIG ELSE FISIICSIG END,
											  FISUUID				= CASE WHEN ISNULL(FISUUID,'')='' THEN @UniqueIdentif ELSE FISUUID END
											  --DATECREATE			=@DATECREATE,
											  --  FISSTATUS		= CASE WHEN @FISLASTERRORFIC = '0' THEN 'FISKALIZUAR' ELSE 'PA FISKALIZUAR' END,
											  --,
											  --FISKALIZUAR	=CASE WHEN @FISLASTERRORFIC = '0' THEN 1 ELSE 0 END 
				WHERE NRRENDOR = @NrRendor


				
	END --ISNULL(@FISFISFJ,'')=''
	ELSE
	SET @OUTPUT1='0'

	--SELECT  @FISFIC					=FISFIC,
	--				--@FISLASTERRORFIC		=@Error,
	--				--@FISLASTERRORTEXTFIC	=@Errortext ,
	--				@FISQRCODELINK			=FISQRCODELINK,
	--				@FISIIC					=FISIIC,
	--				@FISIICSIG				=FISIICSIG,
	--				--@FISRESPONSEXMLFIC		=@responseXml,
	--				@FISXMLSTRING			=FISXMLSTRING,	
	--				@FISXMLSIGNED			=FISXMLSIGNED
	--FROM FJ WHERE NRRENDOR=@NrRendor
	
	
 END;



GO



ALTER PROC [dbo].[Isd_FiscalFF]
	 @NrRendor	INT,
	 @IsInvoice bit,
	 @OUTPUT1	VARCHAR(MAX) OUTPUT  
AS
BEGIN	
		/*
		UPDATE CONFND SET FiscCertificate = (SELECT * FROM OPENROWSET( BULK 'C:\fiscal\isd.p12',  SINGLE_BLOB) AS a)
		*/
--BEGIN TRY
		DECLARE  @NIPT				VARCHAR(20)
				,@PerqZbr			FLOAT
				,@Date				VARCHAR(100)
				,@Nr				VARCHAR(10)
				,@VlerTot			VARCHAR(20)
				,@SoftNum			VARCHAR(1000)
				,@ManufacNum		VARCHAR(1000)
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
				,@SignedXml			VARCHAR(MAX)
				,@Error				VARCHAR(MAX)
				,@ErrorText			VARCHAR(MAX)
				,@XmlStringTemp		NVARCHAR(MAX)
				,@responseXml		XML
				,@hDOC				INT
				,@EIC				NVARCHAR(MAX)
				,@EICURL			NVARCHAR(MAX)
				,@FISUUID			VARCHAR(50)		
			    ,@BusinessUnit		VARCHAR(50)				-- element ne fature
			    ,@OperatorCode		VARCHAR(50)				-- element ne fature
			    ,@CashRegister		VARCHAR(50)
				,@TIPFISKAL			VARCHAR(50)
				,@KURS2				FLOAT
			    ,@FISMENPAGESEFIC	VARCHAR(50)
			    ,@FISMENPAGESEEIC	VARCHAR(50)
			    ,@MODEPAGESE		VARCHAR(50)
			    ,@KLASEPAGESE		VARCHAR(50)
			    ,@FISPROCES			VARCHAR(50)
			    ,@FISTIPDOK			VARCHAR(50)
				,@KODBANKE			VARCHAR(50)
				,@IBAN				VARCHAR(50)
				,@SWIFT				VARCHAR(50)
				,@BANPERSHKRIM		VARCHAR(50)
				,@XML				XML
				,@IsEinvoice		BIT
				,@SELF				VARCHAR(50)
				,@SENDDATETIME		VARCHAR(100)
				,@Fiscalize			BIT		= 1
				,@DATECREATE		DATETIME
				,@QrCodeLink		VARCHAR(1000)
				,@TIPPAGESE			VARCHAR(MAX)
				,@FISFIC			VARCHAR(MAX)
				,@FISLASTERRORFIC	VARCHAR(MAX)
				,@FISLASTERRORTEXTFIC VARCHAR(MAX)
				,@FISQRCODELINK		VARCHAR(MAX)
				,@FISIIC			VARCHAR(MAX)
				,@FISIICSIG			VARCHAR(MAX)
				,@FISRESPONSEXMLFIC	XML
				,@FISXMLSTRING		VARCHAR(MAX)
				,@FISXMLSIGNED		VARCHAR(MAX)
				,@TIPKLIENT			VARCHAR(MAX)
				,@RELATEDFIC		VARCHAR(MAX)
				,@RELATEDDATE		DATETIME
				,@RELATEDTYPE		VARCHAR(MAX)
				,@FISDATEPARE		DATETIME
				,@FISDATEFUND		DATETIME
				,@FISTVSHEFEKT		INT
				,@MONEDHEBAZE       FLOAT
				,@KMON				VARCHAR(10)
				,@BUYERNAME			VARCHAR(100)
				,@BuyerIDNum		VARCHAR(100)
				,@BuyerIDType		VARCHAR(100)
				,@BuyerAddress		VARCHAR(100)
				,@BuyerTown		    VARCHAR(100)
				,@BuyerCountry      VARCHAR(100)
				,@IIC_FAT			VARCHAR(1000);

	SELECT 
			 @BUYERNAME			= CASE WHEN ISNULL(FF.SHENIM1,'')<>'' THEN FF.SHENIM1 ELSE FURNITOR.PERSHKRIM END
			,@BuyerIDNum		= FF.NIPT--CASE WHEN ISNULL(FF.NIPT,'')<>'' THEN FF.NIPT ELSE FURNITOR.NIPT END
			,@BuyerIDType		= FF.TIPNIPT
			,@BuyerAddress		= CASE WHEN ISNULL(FF.SHENIM2,'')<>'' THEN FF.SHENIM2 ELSE FURNITOR.ADRESA1 END
			,@BuyerTown		    = CASE WHEN ISNULL(FF.RRETHI,'')<>'' THEN FF.RRETHI ELSE FURNITOR.ADRESA2 END
			,@BuyerCountry      = CASE WHEN ISNULL(VENDNDODHJE.KODCOUNTRY,'')<>'' 
																	  THEN VENDNDODHJE.KODCOUNTRY ELSE FURNITOR.ADRESA3 END 
	FROM FF INNER JOIN FURNITOR ON FF.KODFKL=FURNITOR.KOD
			LEFT JOIN VENDNDODHJE ON FURNITOR.VENDNDODHJE=VENDNDODHJE.KOD
	WHERE FF.NRRENDOR=@NrRendor


SET @MONEDHEBAZE=ISNULL(ROUND((SELECT KURS1/KURS2 FROM MONEDHA WHERE KOD='ALL'),6),1)
		
		
   SET @SignedXml = '';
   SET @Fic = '';

  

   SELECT   @NIPT				= CONFND.NIPT
		    ,@BusinessUnit      = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCBUSINESSUNIT')
		    ,@SoftNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSOFTNUM')
		    ,@ManufacNum        = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCMANUFACNUM')
			,@schema			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSCHEMA')
		    ,@FiscUrL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCURL')
			,@EICURL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'EICURL')
		    ,@CertificatePath   = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPATH')
		    ,@CertificatePwd    = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPASS')		
			,@Certificate		= FiscCertificate
			,@TIPFISKAL			= CASE WHEN ISNULL(KODFISKAL,'')='' THEN 'VAT' ELSE KODFISKAL END 
	FROM CONFND; 


	SET @IsEinvoice=@IsInvoice
	SET @SENDDATETIME		= dbo.DATE_1601(getdate())

	SELECT 	 @KURS2			= CASE WHEN @MONEDHEBAZE<>1 THEN 
																	CASE WHEN ISNULL(FF.KMON,'')='' THEN @MONEDHEBAZE
																		 WHEN ISNULL(FF.KMON,'')='ALL' THEN 1
																	ELSE  @MONEDHEBAZE*KURS2 END
								  ELSE KURS2 END
			, @KMON				= CASE WHEN @MONEDHEBAZE<>1 THEN 
																	CASE WHEN ISNULL(FF.KMON,'')='' THEN 'EUR'
																		 WHEN ISNULL(FF.KMON,'')='ALL' THEN ''
																	ELSE FF.KMON END
								  ELSE KMON END
   FROM FF WHERE NRRENDOR=@NrRendor


   IF OBJECT_ID('tempdb..#fF') IS NOT NULL 
	DROP TABLE #FF;

	IF OBJECT_ID('tempdb..#fFscr') IS NOT NULL 
	DROP TABLE #FFSCR;
	
	SELECT TOP 1 * INTO #FF 
	FROM FF 
	WHERE NRRENDOR=@NrRendor;

					--SELECT * INTO #FFSCR 
					--FROM FJSCR 
					--WHERE NRD=@NrRendor
	
	

	SELECT  NRD,KARTLLG,
			S.PERSHKRIM,
			NJESI=CASE WHEN ISNULL(NJESI,'')='' THEN (SELECT TOP 1 KOD FROM NJESI) else NJESI END,
			SASI,
			CMIMBS=ROUND(CMIMBS,2),
			CMSHZB0MV=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND(CMSHZB0*F.KURS2,2) ELSE  ROUND(ROUND(CMIMBS*F.KURS2,2),2) END,
			CMIMBSMV=ROUND(ROUND(CMIMBS*@KURS2,2),2),
			CMIMBSTVSH = ROUND((VLERABS / CASE WHEN SASI = 0 THEN 1 ELSE SASI END),2),
			PERQTVSH=ROUND(S.PERQTVSH,2),--CASE WHEN ROUND(S.VLTVSH,2)=0 THEN 0 ELSE ROUND(S.PERQTVSH,2) END,
			VLPATVSH=ROUND(S.VLPATVSH,2),
			VLPATVSHMV=ROUND(ROUND(S.VLPATVSH*@KURS2,2),2),
			VLTVSH=ROUND(VLERABS,2)-ROUND(S.VLPATVSH,2),--ROUND(S.VLTVSH,2),
			VLTVSHMV=ROUND((VLERABS*@KURS2)-(S.VLPATVSH*@KURS2),2),
			VLERABS=ROUND(VLERABS,2),
			VLERABSMV=ROUND(ROUND(VLERABS*@KURS2,2),2),
			APLTVSH,
			CASE WHEN APLTVSH = 1 THEN 'true' ELSE 'false' END AS APLTVSHFIS,
			CASE WHEN APLINVESTIM = 1 THEN 'true' ELSE 'false' END AS APLINVESTIM,
		    VLPATVSHTAXFREEAMOUNT=ROUND((CASE WHEN S.VLTVSH=0 AND ISNULL(KLASETVSH,'')<>'SEXP' AND KODTVSHFIC in ('TAX_FREE','TAX-FREE') THEN S.VLPATVSH ELSE 0 END)*@KURS2,2),
			MarkUpAmt= ROUND((CASE WHEN ISNULL(KLASETVSH,'')='SEXP' THEN 0
							WHEN KODTVSHFIC ='MARGIN_SCHEME' 
								THEN ROUND(S.VLPATVSH,2) 
							ELSE 0 
							END)*@KURS2,2),
			PERQDSCN=CASE WHEN TIPKLL<>'L' THEN ROUND(PERQDSCN,2) ELSE 0 END,
			VLERAZBR=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND((SASI*CMSHZB0)-(SASI*CMIMBS),2) ELSE 0 END,
			VLERAPAZBR=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND(SASI*CMSHZB0,2) ELSE  ROUND(S.VLPATVSH,2) END,
			EXTVSHFIC=REPLACE(KODTVSHFIC,'TAX-FREE','TAX_FREE'),--(SELECT TOP 1 KODTVSHFIC FROM KlasaTatim WHERE KlasaTatim.KOD=S.KODTVSH),
			EXTVSHEIC=KODTVSHEIC--(SELECT TOP 1 KODTVSHEIC FROM KlasaTatim WHERE KlasaTatim.KOD=S.KODTVSH)
			--PERQDSCN,
			--VLERAZBR=ROUND((SASI*CMSHZB0)-(SASI*CMIMBS),2),
			--VLERAPAZBR=ROUND(SASI*CMSHZB0,2),
			--EXTVSHFIC=KODTVSHFIC,--(SELECT TOP 1 KODTVSHFIC FROM KlasaTatim WHERE KlasaTatim.KOD=S.KODTVSH),
			--EXTVSHEIC=KODTVSHEIC--(SELECT TOP 1 KODTVSHEIC FROM KlasaTatim WHERE KlasaTatim.KOD=S.KODTVSH)
	--SELECT * FROM FJSCR WHERE NRD=1086		
		  
	INTO #FFSCR 
	FROM FF F
	INNER JOIN FFSCR S ON F.NRRENDOR = S.NRD
	INNER JOIN KLASATATIM K ON S.KODTVSH=K.KOD
	WHERE NRD = @NrRendor;


	SELECT    @DATECREATE		= FF.DATECREATE
			, @DATE				= dbo.DATE_1601(FF.DATECREATE)
			, @Nr				= CONVERT(VARCHAR(10), CONVERT(BIGINT, NRFISKALIZIM))
			, @VlerTot			= CONVERT(VARCHAR(20), (CONVERT(DECIMAL(18, 2), ROUND(VLERTOT,2))))
			, @PerqZbr			= ISNULL(PERQZBR, 0)
			, @IicBlank			= @NIPT
									+ '|' + dbo.DATE_1601(FF.DATECREATE) 
									+ '|' + CONVERT(VARCHAR(MAX), CONVERT(BIGINT, NRFISKALIZIM))
									+ '|' + LOWER(FISBUSINESSUNIT) 
									+ '|' + LOWER(tcr.KODTCR)
									+ '|' + @SoftNum 
									+ '|' + CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(18,2), ROUND(VLERTOT,2)))
			, @CashRegister		= LOWER(tcr.KODTCR)
			, @OperatorCode		= LOWER(oper.KODFISCAL)
			, @BusinessUnit		= LOWER(FISBUSINESSUNIT)
			, @FISMENPAGESEFIC	= pag.KODFIC
			, @FISMENPAGESEEIC	= pag.KODEIC
			, @MODEPAGESE		= CASE WHEN PAG.KLASEPAGESE = 'ARKE' THEN 'CASH' ELSE 'NONCASH' END
			, @KLASEPAGESE		= CASE WHEN PAG.KLASEPAGESE = 'ARKE' THEN 'CASH' ELSE 'NONCASH' END
			, @FISPROCES		= FISPROCES
			, @FISTIPDOK		= FISTIPDOK
			, @FISUUID			= FISUUID
			--, @KURS2			= KURS2
			, @KODBANKE			= pag.SHENIM1
			, @IBAN				= (SELECT TOP 1 B.IBAN      FROM BANKAT B WHERE KOD = ISNULL(PAG.KODREFERENCE,pag.SHENIM1))
			, @SWIFT			= (SELECT TOP 1 B.SWIFTCODE FROM BANKAT B WHERE KOD = ISNULL(PAG.KODREFERENCE,pag.SHENIM1))
			, @BANPERSHKRIM		= (SELECT TOP 1 B.PERSHKRIM   FROM BANKAT B WHERE KOD = ISNULL(PAG.KODREFERENCE,pag.SHENIM1))
			, @SELF				= (SELECT CASE WHEN ISNULL(FF.KLASETVSH,'')='ABROAD' THEN  'ABROAD' 
									   WHEN ISNULL(FF.KLASETVSH,'')='DOMESTIC' THEN 'DOMESTIC'
									   WHEN ISNULL(FF.KLASETVSH,'')='AGREEMENT' THEN 'AGREEMENT' 
									   WHEN ISNULL(FF.KLASETVSH,'')='OTHER' THEN 'OTHER'
									   WHEN ISNULL(FF.KLASETVSH,'')='FANG' THEN 'ABROAD' 
									   ELSE  NULL END 
								   )
/*
										WHEN ISNULL(A.KLASETVSH,'')='AGREEMENT' THEN 'AGREEMENT' 
										WHEN ISNULL(A.KLASETVSH,'')='OTHER' THEN 'OTHER' 
*/
			/*OPTIONAL:  [AGREEMENT - The previous agreement between the parties., 
						  DOMESTIC - Purchase from domestic farmers., 
						  ABROAD - Purchase of services from abroad., 
						  SELF - Self-consumption., 
						  OTHER - Other] 
			*/
			, @TIPPAGESE		= PAG.KLASEPAGESE
			, @TIPKLIENT		= (SELECT TIPNIPT FROM KLIENT WHERE KOD=FF.KODFKL)
			, @RELATEDFIC		= ISNULL(FF.FISRELATEDFIC,'')
			--, @RELATEDTYPE		= CASE WHEN FF.LLOJDOK IN ('FK','T') THEN 'CORRECTIVE' 
			--						   WHEN FF.TIPFT IN ('FK','T') THEN 'CORRECTIVE'
			--					   ELSE NULL END
			, @RELATEDTYPE		= CASE WHEN FF.LLOJDOK IN ('FK','T') THEN 'CORRECTIVE' 
									   WHEN FF.LLOJDOK='CRN' THEN 'CREDIT'
									   WHEN FF.LLOJDOK='DBN' THEN 'DEBIT' ELSE NULL END
			, @UniqueIdentif	= CASE WHEN ISNULL(FISUUID,'')='' 
											THEN NEWID()
										ELSE FF.FISUUID END

			--, @UniqueIdentif	= CASE WHEN @IsEinvoice=1 THEN NEWID() 
			--						   WHEN ISNULL(FISUUID,'')='' THEN NEWID()
			--						   ELSE FISUUID END
			,@FISDATEPARE		= ISNULL(FISDATEPARE,DTDSHOQ)
			,@FISDATEFUND		= ISNULL(FISDATEFUND,DTDSHOQ)		
			,@FISTVSHEFEKT		= ISNULL(FISTVSHEFEKT,35)	
			,@IIC_FAT			= ISNULL(FF.FISIIC,'')	
	FROM FF 
	LEFT JOIN FisTCR tcr ON FF.FISTCR = tcr.KOD
	LEFT JOIN FisOperator oper ON FF.FISKODOPERATOR = oper.KOD
	LEFT JOIN FisMenPagese pag ON FF.FISMENPAGESE = pag.KOD
	WHERE FF.NRRENDOR = @NrRendor;
	--SELECT * FROM FisMenPagese
	SET NOCOUNT ON;
	--SET @UniqueIdentif = NEWID();
	


	
		IF OBJECT_ID('tempdb..#FFSTORNIM') IS NOT NULL 
		DROP TABLE #FFSTORNIM;


		 SELECT RELATEDFIC=CASE WHEN ISNULL(FISIIC,'')='' 
								THEN RIGHT(NRSERIAL,32)  
								ELSE  FISIIC END,
		 RELATEDDATE=DATEDOKCREATE ,RELATEDTYPE=@RELATEDTYPE,NRRENDOR
		 INTO #FFSTORNIM
		 FROM FFSTORNIMSCR 
		 WHERE NRD=@NrRendor
		 

		 SET @RELATEDFIC=(SELECT TOP 1 RELATEDFIC FROM #FFSTORNIM)

	--SET @RELATEDDATE=(SELECT TOP 1 DATECREATE FROM FF WHERE FISIIC=@RELATEDFIC AND NRRENDOR<>@NrRendor)

	
	/*
	(SELECT CASE WHEN KODTVSHFIC NOT IN ('TYPE_1','TYPE_2') THEN (CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHTAXFREEAMOUNT),2)))
											ELSE 0 END 
											FROM #FFSCR 
											GROUP BY EXTVSHFIC )
	*/

	UPDATE #FF SET	VLTVSH		=	(SELECT ROUND(SUM(round(VLERABS-VLPATVSH,2)),2) FROM #FFSCR),
					VLPATVSH	=	(SELECT ROUND(SUM(round(VLPATVSH,2)),2) FROM #FFSCR),
					VLERTOT		=	(SELECT ROUND(SUM(round(VLERABS,2)),2) FROM #FFSCR),
					KMON		=	CASE WHEN @KMON = '' THEN 'ALL' ELSE @KMON END,
					KURS2		=   @KURS2 ;

	

	--SELECT * FROM #FFSCR

---------------------------------------------FISKALIZIMI
	/* TE HIQET
	IF @TIPPAGESE='BANKE' AND @TIPKLIENT='NUIS'
	SET @IsEinvoice='true'
	ELSE 
	SET @IsEinvoice='false'
	PRINT @IsEinvoice
	PRINT @IsInvoice	
	*/
	

	
	IF ISNULL(@IICBLANK,'')<>''
	EXEC _FiscalGenerateHash @IicBlank, @CertificatePath, @CertificatePwd, @Certificate, 
	@IIC OUTPUT, @IICSIGNATURE OUTPUT, @ERROR OUTPUT, @ERRORtext OUTPUT;
	
	--SELECT @IicBlank,@CertificatePath,@CertificatePwd,@Certificate,@Iic,@IicSignature,@Error,@ErrorText

	

	SET @XML  = (
					SELECT 
							CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 THEN @SENDDATETIME ELSE dbo.DATE_1601(@DATECREATE) END AS 'Header/@SendDateTime',  -- MANDATORY: 
							--@SENDDATETIME  AS 'Header/@SendDateTime',  -- MANDATORY: 
							--CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 then 'NOINTERNET' else null end  AS 'Header/@SubseqDelivType',	
							CASE WHEN @IIC_FAT<>'' AND @IIC_FAT=@IIC THEN 'NOINTERNET' 
																ELSE
																	CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 
																	then 'NOINTERNET' 
																	else null end  
															END AS 'Header/@SubseqDelivType',																						   
																						   -- MANDATORY:  Duhet shtuar ne fature [NOINTERNET, BOUNDBOOK, SERVICE, TECHNICALERROR]
																						   -- NOINTERNET When TCR operates in the area where there is no Internet available. 
																						   -- BOUNDBOOK When TCR is not working and message cannot be created with TCR. 
																						   -- SERVICE When there is an issue with the fiscalization service that blocks fiscalization. 
																						   -- TECHNICALERROR When there is a temporary technical error at TCR side that prevents successful fiscalization
							--DUHET SHTUAR SUBSEQUENTDELIVERYTYPE
							@UniqueIdentif AS 'Header/@UUID',			 -- MANDATORY: Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
				
				(
						SELECT 
								@KLASEPAGESE AS '@TypeOfInv' -- MANDATORY: 
								,@SELF AS '@TypeOfSelfIss'    
			/*OPTIONAL:  [AGREEMENT - The previous agreement between the parties., 
						  DOMESTIC - Purchase from domestic farmers., 
						  ABROAD - Purchase of services from abroad., 
						  SELF - Self-consumption., 
						  OTHER - Other] 
			*/
							   --,'false' AS '@IsSimplifiedInv'							-- MANDATORY:
							   ,CASE WHEN @TIPFISKAL='VAT' THEN 'false' else 'true' end AS '@IsSimplifiedInv'
							   ,dbo.DATE_1601(@DATECREATE) AS '@IssueDateTime'			-- MANDATORY: 
							   ,@Nr + '/' + CONVERT(VARCHAR(4), YEAR(@DATECREATE)) + CASE WHEN @KLASEPAGESE = 'CASH' THEN + '/' + @CashRegister ELSE '' END AS '@InvNum'	-- MANDATORY: NQS CASH PERNDRYSHE BEJE BOSH @CashRegister -- > NrRendor vjetor qe fillon nga 1 ne fillim vit
																														/*
																														A. NUMERIC ORDINAL NUMBER OF INVOICE
																															AND CALENDER YEAR
																															Can contain only numbers 0-9, without leading 0.
																															(also field “InvOrdNum”)
																														B. CALENDER YEAR (YYYY)
																											
																														C. ECD CODE (also field “TCRCode”)
																															Unique ECD CODE that is registered in CIS
																														*/		
							   ,@Nr	AS '@InvOrdNum'						
							   ,@CashRegister	AS '@TCRCode'							--Duhet shtuar ne magazina/fature -- nr i tcr
							   --,'true'			AS '@IsIssuerInVAT'						-- MANDATORY: 
							   ,CASE WHEN @TIPFISKAL='VAT' THEN 'true' else 'false' end	AS '@IsIssuerInVAT'
																						/*
																							Possible values:
																								1. Taxpayer is registered for VAT – 1
																								2. TAXPAYER is not registered for VAT – 2
																						*/
							   --,'0.00'			AS '@TaxFreeAmt'						-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged
							   --,CASE WHEN @TIPFISKAL='VAT' THEN CONVERT(DECIMAL(20, 2), 0) else CONVERT(DECIMAL(20, 2), S.VLERTOT) end			AS '@TaxFreeAmt'						-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged
							   ,CASE WHEN (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHTAXFREEAMOUNT),2)) FROM #FFSCR)=0 THEN null 
										 else (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHTAXFREEAMOUNT),2)) FROM #FFSCR) END AS  '@TaxFreeAmt'-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged							   							   
							   ,CASE WHEN (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(MarkUpAmt),2)) FROM #FFSCR)=0 THEN NULL
									 ELSE (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(MarkUpAmt),2)) FROM #FFSCR) END AS '@MarkUpAmt'							-- OPTIONAL: Amount related to special procedure for margin scheme
							   --,NULL			AS '@GoodsExAmt'						-- OPTIONAL: Amount of goods for export from the Republic of Albania. 
							   ,CASE WHEN KLASETVSH='SEXP' THEN  CONVERT(DECIMAL(18, 2), ROUND(VLERTOT*S.KURS2,2)) ELSE NULL END			AS '@GoodsExAmt'						-- OPTIONAL: Amount of goods for export from the Republic of Albania. 
							   ,(SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHMV),2)) FROM #FFSCR) AS '@TotPriceWoVAT'	-- MANDATORY: Total price of the invoice excluding VAT.
							   --,CONVERT(DECIMAL(18, 2), VLERTOT)	AS '@TotPriceWoVAT'
							   ,CASE WHEN @TIPFISKAL='VAT' AND (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLTVSHMV),2)) FROM #FFSCR) <>0 THEN (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLTVSHMV),2)) FROM #FFSCR)  ELSE NULL end		AS '@TotVATAmt'		-- MANDATORY: Total VAT amount of the invoice. 
							   --,CONVERT(DECIMAL(18, 2), 0) AS '@TotVATAmt'
							   ,(SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLERABSMV),2)) FROM #FFSCR)	AS '@TotPrice'		-- MANDATORY: Total price of all items including taxes and discounts.
							   ,@OperatorCode	AS '@OperatorCode'						-- MANDATORY: Reference to the operator code, who is operating on TCR and issues invoices.
							   ,@BusinessUnit	AS '@BusinUnitCode'						-- MANDATORY: Business unit (premise) code. Duhet shtuar tek magazina, apo duhet shtuar ne fature? faturat vetem sherbim?				   
							   ,@SoftNum		AS '@SoftCode'							-- MANDATORY: Software code.
							   ,NULL			AS '@ImpCustDecNum'						-- OPTIONAL: Import customs declaration number. Only for internal usage. Must not be populated by a TCR.
							   ,@Iic			AS '@IIC'								-- MANDATORY: Duhet shtuar ne fature, Nr unik i cili behet me concat
							   ,@IicSignature	AS '@IICSignature'						-- MANDATORY: Shenjimi i iic
							   ,CASE WHEN KLASETVSH='FANG' THEN 'true' ELSE 'false'	END		AS '@IsReverseCharge'					-- MANDATORY: If true, the buyer is obliged to pay the VAT.	
							   ,NULL			AS '@PayDeadline'						-- OPTIONAL:  Last day for payment.		--> MANDATORY IF NON CASH
							   ,CASE WHEN @IsEinvoice='0' THEN 'false' ELSE 'true' END		AS '@IsEinvoice'
							   ,
								/*
								CASE WHEN EXISTS(SELECT 1 FROM FJ FREF WHERE ISNULL(FREF.FISIIC,'') = ISNULL(S.FISRELATEDFIC,'')) THEN
								(
									SELECT  ISNULL(FREF.FISIIC,'') AS '@IICRef',				-- IIC reference on the original invoice.
							 				ISNULL(DBO.DATE_1601(FREF.DATECREATE),DBO.DATE_1601(FREF.DATECREATE)) AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.
											CASE WHEN ISNULL(FREF.LLOJDOK,'') IN ('','01') 	THEN 'CORRECTIVE' ELSE 'DEBIT' END AS '@Type'				-- Type of the corrective invoice.
									FROM FJ FREF WHERE ISNULL(FREF.FISIIC,'') = ISNULL(S.FISRELATEDFIC,'')  
									AND ISNULL(S.FISRELATEDFIC,'')<>'' 
									--AND FREF.NRRENDOR=@NrRendor
									FOR XML PATH ('CorrectiveInv'), TYPE
								) ELSE NULL END						-- XML element groups data for an original invoice that will be corrected with current invoice.
							   ,
							  */
							  (CASE WHEN (@RELATEDFIC<>'' AND @RELATEDTYPE IN ('CORRECTIVE','CREDIT','DEBIT') ) THEN
											( 
											SELECT TOP 1
												--RIGHT('0000000000000000000000000000000000000012345678',32)		AS '@IICRef',				-- IIC reference on the original invoice.
												--DBO.DATE_1601(@RELATEDDATE)	AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.
												RIGHT(RELATEDFIC,32)		AS '@IICRef',				-- IIC reference on the original invoice.
												DBO.DATE_1601(RELATEDDATE)	AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.

												RELATEDTYPE	AS '@Type'
											 FROM #FFSTORNIM 
											 ORDER BY NRRENDOR
											 FOR XML PATH ('CorrectiveInv'), TYPE



											)
											ELSE NULL END
											)
							  
								  ,

							  CASE WHEN EXISTS(SELECT 1 FROM FFSCR WHERE 1 = 2) THEN	-- OPTIONAL: 
								(
									SELECT NULL AS 'BadDebtInv/@IICRef',				--IIC reference on the original invoice.
											NULL AS 'BadDebtInv/@IssueDateTime'			--Date and time the original invoice is created and issued at TCR.
									FOR XML PATH (''), TYPE
								 ) 	ELSE NULL END AS BadDebtInv							--XML element groups data for an original invoice that will be declared bad debt invoice, as uncollectible.				   
							   , CASE WHEN EXISTS(SELECT 1 FROM FFSCR WHERE 1 = 2) THEN	-- MANDATORY case of Summary invoice:
								(														--XML element that contains one IIC reference, e.g. reference of the invoice that is part of the summary invoice.
									SELECT NULL AS 'SumInvIICRef/@IIC',					--IIC of the invoice that is referenced in the summary invoice.
										   NULL AS 'SumInvIICRef/@IssueDateTime'		--Date and time the invoice referenced by the summary invoice is created and issued at TCR.
									WHERE 1=2
									FOR XML PATH (''), TYPE	
								 ) ELSE NULL END AS SumInvIICRefs						--XML element that contains list of IIC-s to which this invoice referred to, e.g. if this is a summary invoice it 
																						--shall contain a reference to each individual invoice issued and fiscalized before and included in this summary invoice.
							   ,														-- OPTIONAL:  
								(
									SELECT	REPLACE(CONVERT(VARCHAR,CAST(@FISDATEPARE AS datetime), 111), '/', '-') AS '@Start',		--Start day of the supply.
											REPLACE(CONVERT(VARCHAR,CAST(@FISDATEFUND AS datetime), 111), '/', '-') AS '@End'	
											--REPLACE(CONVERT(VARCHAR,CAST(eomonth(dtdshoq) AS datetime), 111), '/', '-') AS '@End'			--End day of the supply.
									WHERE 1 = 1
									FOR XML PATH ('SupplyDateOrPeriod'), TYPE	
								  )										--XML element representing supply date or period of supply, if it is different from the date when the invoice was issued.
								,
								(														-- MANDATORY: 

									-- SELECT * FROM CONFIG..TIPDOK WHERE TIPDOK = 'S'
									 SELECT (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLERABSMV),2)) FROM #FFSCR) AS 'PayMethod/@Amt',
									@FISMENPAGESEFIC AS 'PayMethod/@Type',
										  -- CASE WHEN MODPG = 'CA' THEN 'BANKNOTE'
												--WHEN MODPG = 'VO' THEN 'ACCOUNT'
												--WHEN MODPG = 'TT' THEN 'OTHER'
												--ELSE 'ACCOUNT' 
												--END AS 'PayMethod/@Type',			-- Type of the payment method.
										   NULL AS 'PayMethod/@CompCard',				-- Amount payed by payment method in the ALL.
										   (
											SELECT NULL AS 'Voucher/@Num'				--Voucher serial number
											WHERE 1=2				
											FOR XML PATH (''), TYPE
										   ) Vouchers									-- XML element that contains list of voucher numbers if the payment method is voucher.
									FOR XML PATH (''), TYPE	
								 ) PayMethods											--> MENYRA E PAGESES, PER CDO MENYRE PAGESE 
																						-- [BANKNOTE, CARD, CHECK, SVOUCHER, COMPANY, ORDER   , ACCOUNT , FACTORING, COMPENSATION, TRANSFER, WAIVER  , KIND     , OTHER   ]
																						-- [ CASH   , CASH, CASH ,  CASH   , CASH   , NON CASH, NON CASH, NON CASH ,     NON CASH, NON CASH, NON CASH, NON CASH , NON CASH]
								,
																						-- OPTIONAL:  
								(
									SELECT	KMON AS 'Currency/@Code',					--Currency code in which the amount on the invoice should be paid, if different from ALL.
											CONVERT(DECIMAL(18, 6), @KURS2) AS 'Currency/@ExRate'
											--,				--Exchange rate applied to calculate the equivalent amount of foreign currency for the total amount expressed in ALL. Exchange rate express equivalent amount of ALL for 1 unit of foreign currency.
											--'false' AS 'Currency/@IsBuying'				--True if exchange transaction is buying of the foreign currency. False if exchange transaction is selling of the foreign currency.
									WHERE KMON NOT IN ('', 'ALL')						
									FOR XML PATH (''), TYPE	
								  )														--XML element representing currency in which the amount on the invoice should be paid, if different from ALL
							   ,(	--nga config -- 
									SELECT PERSHKRIM				 AS 'Buyer/@Name',					-- MANDATORY: 
										   @NIPT					 AS 'Buyer/@IDNum',				-- MANDATORY:	
										   'NUIS'					 AS 'Buyer/@IDType',				 -- MANDATORY:	FIX
										   ISNULL(SHENIM1,'')		 AS 'Buyer/@Address', -- MANDATORY FOR FOREIGNER:	FUSHA PER ADRESEN
										   ISNULL(SHENIM2,'Tirane')	 AS 'Buyer/@Town',					 -- MANDATORY FOR FOREIGNER:    QYTETI
										   'ALB'					 AS 'Buyer/@Country'				 -- MANDATORY FOR FOREIGNER:    SHTETI
									FROM CONFND
									FOR XML PATH (''), TYPE
								) ,
								(	--nga furnitori
									SELECT	REPLACE(@BUYERNAME, '"', '')  AS 'Seller/@Name',		-- OPTIONAL| MANDATORY B2B: 
											@BuyerIDNum					  AS 'Seller/@IDNum',		-- OPTIONAL| MANDATORY B2B: 
																								/* This field is filled out if buyer is:
																										 a taxpayer of profit tax or a taxpayer of simplified profit tax for small businesses or a taxpayer who is subject to VAT in accordance with special regulations, or
																										 a legal entity to whom goods or services are provided in the territory of the Republic of Albania for the purpose of carrying out his economic activity; or
																										 if personal property of a single value is sold above 500,000 ALL;
																										 or in other cases when the buyer asks for this data to be entered into the invoice, but there is no control in that case. Also, this field is mandatory if the buyer issues the
																										invoice instead of the seller. If this field is entered, beside in the book of sales of the seller, this invoice will also appear in the book of purchase of the buyer if the buyer is a taxpayer.
																										If the buyer is an individual who requires invoice for recognition of the cost of the medication, no book of purchase will be created for him, but a special application will be created to register all the data on
																										all invoices where he has appeared as a buyer and that information will be exchanged with the CIS system. Also, data may be entered for a foreigner or diplomat who will request a VAT refund and this information will be exchanged with the CIS system as well.
																								*/
											ISNULL(@BuyerIDType,'')	 AS 'Seller/@IDType',	-- OPTIONAL| MANDATORY B2B: 
																								-- NQS ESHTE PERSON FIZIK DUHET SPECIFIKUAR --> NDARES PER PERSON FIZIK APO SUBJEKT -- [NUIS: NUIS-number | ID: Personal ID-number | PASS: Passport-number | VAT: VAT-number | TAX: TAX-number ]
																						
											ISNULL(@BuyerAddress, '')			 AS 'Seller/@Address',	-- OPTIONAL| MANDATORY IF NAME IS FILLED: 

											@BuyerTown AS 'Seller/@Town',		-- OPTIONAL| MANDATORY IF NAME IS FILLED: 
											@BuyerCountry AS 'Seller/@Country'	-- OPTIONAL| MANDATORY IF NAME IS FILLED: 	
									
									FROM FURNITOR C LEFT JOIN VENDNDODHJE V 
									ON C.VENDNDODHJE=V.KOD
									WHERE C.KOD = S.KODFKL
									--AND ISNULL(C.NIPT, '') != ''
									FOR XML PATH (''), TYPE
								)
								,
									(	SELECT  KARTLLG AS 'I/@C',								-- OPTIONAL:  Code of the item from the barcode or similar representation
											LEFT(PERSHKRIM, 50) AS 'I/@N',						-- MANDATORY: Name of the item (goods or services).
											--CONVERT(DECIMAL(18, 2), VLPATVSH) AS 'I/@PA',		-- MANDATORY: Total price of goods after the tax and applying discounts Negative values allowed when CorrectiveInv or BadDebtInv exist.
											CONVERT(DECIMAL(18, 2), ROUND(VLERABSMV,2)) AS 'I/@PA',		-- MANDATORY: Total price of goods after the tax and applying discounts Negative values allowed when CorrectiveInv or BadDebtInv exist.
											CONVERT(DECIMAL(18, 2), ROUND(VLPATVSHMV,2)) AS 'I/@PB',		-- MANDATORY: Total price of goods and services before the tax Negative values allowed when CorrectiveInv or BadDebtInv exist.
											CONVERT(DECIMAL(18, 2), SASI) AS 'I/@Q',			-- MANDATORY: Amount or number (quantity) of items. Negative values allowed when CorrectiveInv or BadDebtInv exist.
											CONVERT(DECIMAL(18, 2), PERQDSCN) AS 'I/@R',					-- OPTIONAL:  Percentage of the rebate.	
											CASE WHEN PERQDSCN<>0 AND VLTVSH<>0 THEN 'true' ELSE 'false' end AS 'I/@RR',	-- OPTIONAL:  Is rebate reducing tax base amount?
											NJESI AS 'I/@U',									-- MANDATORY: What is the item’s unit of measure (piece, weight measure, length measure, etc.)
											CASE WHEN PERQDSCN<>0 THEN CONVERT(DECIMAL(18, 2), ROUND(CMSHZB0MV,2)) ELSE CONVERT(DECIMAL(18, 2), ROUND(CMIMBSMV,2)) END AS 'I/@UPB',		-- MANDATORY: Unit price before Value added tax is applied
											--CONVERT(DECIMAL(18, 2), CMIMBS) AS 'I/@UPA',		-- MANDATORY: Unit price after Value added tax is applied
											CONVERT(DECIMAL(18, 2), ROUND(VLERABSMV/SASI,2)) AS 'I/@UPA',
								
											-- nuk duhet APLTVSH
											--CASE WHEN VLTVSH = 0 AND APLTVSHFIS = 'false' and @TIPFISKAL='VAT' THEN 'TYPE_1'
											--	 WHEN VLTVSH = 0 AND APLTVSHFIS = 'false' and @TIPFISKAL='FRE' THEN 'TAX_FREE'
											--     WHEN KLASETVSH='SEXP' THEN 'EXPORT_OF_GOODS' 
											CASE WHEN ISNULL(KLASETVSH,'')='SEXP' THEN 'EXPORT_OF_GOODS' 
											WHEN @TIPFISKAL='FRE' THEN 'TAX_FREE' 
											WHEN ISNULL(EXTVSHFIC,'') IN ('TYPE_1','TYPE_2','MARGIN_SCHEME') THEN ISNULL(EXTVSHFIC,'')
											WHEN ISNULL(EXTVSHFIC,'')='VAT' THEN NULL
											ELSE ISNULL(EXTVSHFIC,'') END AS 'I/@EX',			-- OPTIONAL: 
																																			-- Exempt from VAT.
																																			-- TYPE_1 Exempt type 1. Exempted on the basis of Article 51 of the VAT law 
																																			-- TYPE_2 Exempt type 2. Exempted on the basis of Articles 53 and 54 of the VAT law 
																																			-- TAX_FREE Tax free amount. Sales without VAT that is exempted based on VAT law other then articles 51, 53 and 54 of VAT law, and is not margin scheme nor export of goods 
																																			-- MARGIN_SCHEME Margin scheme (Travel agents VAT scheme, second hand goods VAT scheme, works of art VAT scheme, collectors’ items and antiques VAT scheme etc.). 
																																			-- EXPORT_OF_GOODS Export of goods. No VAT.
																					

											--CASE WHEN KLASETVSH='SEXP' THEN APLINVESTIM ELSE NULL END AS 'I/@IN',								-- If true, the item is investment for the buyer. Mandatory only for importation of goods.
											APLINVESTIM AS 'I/@IN',								-- If true, the item is investment for the buyer. Mandatory only for importation of goods.
											CASE WHEN (EXTVSHFIC<>'VAT' OR ISNULL(@TIPFISKAL,'')<>'VAT') 
											THEN NULL ELSE  CONVERT(DECIMAL(18, 2), ROUND(VLTVSHMV,2)) END  AS 'I/@VA',

											CASE WHEN (EXTVSHFIC<>'VAT' OR ISNULL(@TIPFISKAL,'')<>'VAT') 
											THEN NULL ELSE  CONVERT(DECIMAL(18, 2), PERQTVSH) END AS 'I/@VR',

											--CASE WHEN KLASETVSH='FANG' THEN CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2))
											--	 WHEN (VLTVSH = 0 AND APLTVSHFIS = 'false') OR  ISNULL(@TIPFISKAL,'')<>'VAT' OR PERQTVSH=0 THEN NULL 
											--	 ELSE CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2)) END  AS 'I/@VA',		-- MANDATORY: Amount of value added tax for goods and services. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true. Negative values allowed when CorrectiveInv or BadDebtInv exist.
											
											--CASE WHEN KLASETVSH='FANG' THEN CONVERT(DECIMAL(18, 2), PERQTVSH)
											--	 WHEN (VLTVSH = 0 AND APLTVSHFIS = 'false') OR  ISNULL(@TIPFISKAL,'')<>'VAT' OR PERQTVSH=0 THEN NULL 
											--	 ELSE CONVERT(DECIMAL(18, 2), PERQTVSH) END AS 'I/@VR',		-- MANDATORY: Rate of value added tax. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true.
								
								--			CASE WHEN VLTVSH = 0 AND APLTVSHFIS = 'false' THEN NULL ELSE CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2)) END  AS 'I/@VA',		-- MANDATORY: Amount of value added tax for goods and services. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true. Negative values allowed when CorrectiveInv or BadDebtInv exist.
								--			CASE WHEN VLTVSH = 0 AND APLTVSHFIS = 'false' THEN NULL ELSE CONVERT(DECIMAL(18, 2), PERQTVSH) END AS 'I/@VR',		-- MANDATORY: Rate of value added tax. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true.
								
								--			CASE WHEN @TIPFISKAL='FRE' THEN NULL ELSE CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2)) END  AS 'I/@VA',		-- MANDATORY: Amount of value added tax for goods and services. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true. Negative values allowed when CorrectiveInv or BadDebtInv exist.
								--			CASE WHEN @TIPFISKAL='FRE' THEN NULL ELSE CONVERT(DECIMAL(18, 2), PERQTVSH) END AS 'I/@VR',		-- MANDATORY: Rate of value added tax. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true.
								
											CASE WHEN EXISTS(SELECT 1 FROM FFSCR WHERE 1 = 2) THEN
											(													-- OPTIONAL: 
												SELECT (SELECT NULL AS 'VD/@D',					-- Expiration date of the voucher.
																NULL AS 'VD/@N'					-- Nominal voucher value.			
																									--> DUHET E GRUPUAR VETEM 1 ELEMENT
														FOR XML PATH(''), TYPE					-- XML element representing serial numbers of voucher sold.
														),	 
														(SELECT NULL AS 'V/@Num'				--Voucher serial number.
																									--> DUHET TE KTHEJE ARRAY ME ROOT VN
														FOR XML PATH(''), TYPE 					-- XML element representing serial numbers of voucher sold.
														) VN	 
												FOR XML PATH(''), TYPE
											) ELSE NULL END AS VS												-- XML element representing vouchers sold
								
									FROM #FFSCR C 					
									FOR XML PATH (''), TYPE
								) Items
								,																-- MANDATORY IF ISSUER IN VAT:
								(CASE WHEN ISNULL(KLASETVSH,'')<>'SEXP' THEN
								(	SELECT  CONVERT(VARCHAR(10), CONVERT(DECIMAL(18, 0), COUNT(1)))	  AS 'SameTax/@NumOfItems',
											CONVERT(DECIMAL(18, 2), ROUND(SUM(VLPATVSHMV),2))	  AS 'SameTax/@PriceBefVAT',
											CASE WHEN EXTVSHFIC NOT IN ('TYPE_1','TYPE_2') 
												 THEN CONVERT(DECIMAL(18, 2), PERQTVSH) ELSE NULL END AS 'SameTax/@VATRate',
											CASE WHEN EXTVSHFIC IN ('TYPE_1','TYPE_2') 
												 THEN EXTVSHFIC ELSE NULL END						  AS 'SameTax/@ExemptFromVAT',
											--APLTVSH													  AS 'SameTax/@ExemptFromVAT',		-- nuk duhet APLTVSH
																													-- Exempt from VAT.
																														-- TYPE_1 Exempt type 1. Exempted on the basis of Article 51 of the VAT law 
																														-- TYPE_2 Exempt type 2. Exempted on the basis of Articles 53 and 54 of the VAT law 
											CASE WHEN EXTVSHFIC NOT IN ('TYPE_1','TYPE_2')
											THEN CONVERT(DECIMAL(18, 2), ROUND(SUM(VLTVSHMV),2)) ELSE NULL END
											AS 'SameTax/@VATAmt'
									FROM #FFSCR
									--WHERE @TIPFISKAL='VAT' AND (PERQTVSH<>0 OR EXTVSHFIC IN ('TYPE_1','TYPE_2'))
									--WHERE @TIPFISKAL='VAT' AND ISNULL(EXTVSHFIC,'') <>('MARGIN_SCHEME')
									WHERE @TIPFISKAL='VAT' AND ISNULL(EXTVSHFIC,'') not in ('MARGIN_SCHEME','TAX_FREE')
									GROUP BY PERQTVSH,EXTVSHFIC
									FOR XML PATH (''), TYPE
								) 
								ELSE
								NULL
								END)SameTaxes,
																							-- OPTIONAL:
								(	--per tu interpretuar cfare jane?
									SELECT  1		 AS 'ConsTax/@NumOfItems',				-- Number of items under consumption tax.
											VLPATVSH AS 'ConsTax/@PriceBefConsTax',			-- Price before adding consumption tax.
											PERQTVSH AS 'ConsTax/@ConsTaxRate',				-- Rate of the consumption tax.
											VLTVSH   AS 'ConsTax/@ConsTaxAmt'				-- Amount of consumption tax.
									FROM #FFSCR C 
									WHERE 1 = 2 -- NQS NUK KA REKORDE HIQET VETE SI TAG						
									FOR XML PATH (''), TYPE
								) ConsTaxes													-- XML element representing one cons tax item.
								, (															-- OPTIONAL: FEES
									SELECT  NULL	 AS 'Fee/@Type',						-- Type of the fee.
																								-- PACK Packaging fee 
																								-- BOTTLE Fee for the return of glass bottles 
																								-- COMMISSION Commission for currency exchange activities 
																								-- OTHER Other fees that are not listed here.
											VLPATVSH AS 'Fee/@Amt'							-- Amount of the fee.
									FROM #FFSCR C 
									WHERE 1 = 2 -- NQS NUK KA REKORDE HIQET VETE SI TAG
									FOR XML PATH (''), TYPE
								) Fees														-- XML element representing list of fees.
					FROM #FF  S
					WHERE S.NRRENDOR = @NrRendor
					FOR XML PATH('Invoice'), TYPE
				)
				FOR XML PATH('RegisterInvoiceRequest'));

			--SELECT @XML
    
				--Gjenerimi i url per kontrollin e fiskalizimit te fatures
				SET @QrCodeLink = CASE WHEN @FiscUrL LIKE '%-TEST%' THEN 'https://efiskalizimi-app-test.tatime.gov.al/invoice-check/#/verify?'
																	ELSE REPLACE('https://efiskalizimi-app-test.tatime.gov.al/invoice-check/#/verify?', '-TEST', '')
																	END
								+ 'iic='	+ @Iic
								+ '&tin='	+ @NIPT
								+ '&crtd='	+ @Date
								+ '&ord='   + @Nr
								+ '&bu='    + @BusinessUnit				
								+ '&cr='    + @CashRegister
								+ '&sw='    + @SoftNum
								+ '&prc='   +  CONVERT(VARCHAR(50),CONVERT(DECIMAL(34, 2),ROUND(@VlerTot*@KURS2,2)));  
			  -- SELECT 	@QrCodeLink,@Iic,@NIPT,@Date,@Nr,@BusinessUnit,@CashRegister,@SoftNum,@VlerTot
	
				SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterInvoiceRequest>','<RegisterInvoiceRequest xmlns="' + @Schema +'" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3">') AS XML)

				SELECT @XmlString = CAST(@XML AS VARCHAR(MAX))  

				IF(@Fiscalize != 0)	
				BEGIN
					--BEGIN TRY
							
						EXEC _FiscalProcessRequest 
							@InputString		 = @XmlString,
							@CertBinary		     = @Certificate,
							@CertificatePath	 = @CertificatePath, 
							@Certificatepassword = @CertificatePwd, 
							@Url				 = @FiscUrL,
							@Schema				 = @Schema,
							@ReturnValue		 = 'FIC',
							@useSystemProxy		 = '',
							@SignedXml			 = @SignedXml	OUTPUT, 
							@Fic				 = @Fic			OUTPUT, 
							@Error				 = @FISLASTERRORFIC		OUTPUT, 
							@Errortext			 = @FISLASTERRORTEXTFIC	OUTPUT,
							@responseXml		 = @FISRESPONSEXMLFIC OUTPUT;
				END			
					
			
			SELECT  @FISFIC					=@FIC,
					--@FISLASTERRORFIC		=@Error,
					--@FISLASTERRORTEXTFIC	=@Errortext ,
					@FISQRCODELINK			=@QrCodeLink,
					@FISIIC					=@IIC,
					@FISIICSIG				=@IICSIGNATURE,
					--@FISRESPONSEXMLFIC		=@responseXml,
					@FISXMLSTRING			=@XmlString,	
					@FISXMLSIGNED			=@SignedXml

			IF(@Error != '0')
			BEGIN
				BEGIN TRY
					EXEC sp_xml_preparedocument @hDoc OUTPUT, @FISRESPONSEXMLFIC, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" />';

					SELECT @ErrorText = ISNULL(faultcode,'') + ' - ' + ISNULL(faultstring,'')
					FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/SOAP-ENV:Fault')
					WITH
					(
						[faultcode]		NVARCHAR(MAX)	'faultcode',
						[faultstring]	NVARCHAR(MAX)	'faultstring'
					)
					ORDER BY [faultcode];

					SET @FISLASTERRORTEXTFIC = @ErrorText

					UPDATE FF SET FISLASTERRORTEXTFIC = @ErrorText
					WHERE NRRENDOR = @NrRendor;

					EXEC sp_xml_removedocument @hDoc;
				END TRY
				BEGIN CATCH
					SET @Errortext = ISNULL(@Errortext, '') + '-> CAN NOT PARSE RESPONSE';

					SET @FISLASTERRORTEXTFIC = @ErrorText;

					UPDATE FF SET FISLASTERRORTEXTFIC = @ErrorText
					WHERE NRRENDOR = @NrRendor;
				END CATCH
			END;
			ELSE
			BEGIN
					UPDATE FF SET			  FisFic			= @FISFIC
											, FisIic			= @FISIic
											, FISQRCODELINK		= @QrCodeLink							   
					WHERE NRRENDOR = @NrRendor;

					--UPDATE #fj SET FisFic = @Fic, FisIic = @Iic;
			END


				UPDATE FF SET			  FISFIC			    = CASE WHEN @FISLASTERRORFIC = '0' THEN @FISFIC ELSE '' END ,
										  FISLASTERRORFIC		= @FISLASTERRORFIC,
										  FISLASTERRORTEXTFIC	= @FISLASTERRORTEXTFIC,
										  FISQRCODELINK			= @FISQRCODELINK,
										  FISIIC				= @FISIIC ,
										  FISIICSIG				= @FISIICSIG,
										  FISRESPONSEXMLFIC		= CONVERT(VARCHAR(MAX),@FISRESPONSEXMLFIC),
										  FISXMLSTRING			= @FISXMLSTRING,
										  FISXMLSIGNED			= @FISXMLSIGNED,
										  FISUUID				= @UniqueIdentif,
										 -- DATECREATE			= @DATECREATE,
										  FISSTATUS				= CASE WHEN @FISLASTERRORFIC = '0' THEN 'FISKALIZUAR' ELSE 'PA FISKALIZUAR' END,
										  FISEIC				= CASE WHEN @FISLASTERRORFIC = '0' THEN 'FISKALIZUAR' ELSE '' END ,
										  FISKALIZUAR			= CASE WHEN @FISLASTERRORFIC = '0' THEN 1 ELSE 0 END ,
										  NRSERIAL				= CASE WHEN @FISLASTERRORFIC = '0' THEN @FISFIC ELSE NRSERIAL END
							WHERE NRRENDOR = @NrRendor

					
				IF @FISLASTERRORFIC = '0'
					SET @OUTPUT1=@FISLASTERRORFIC
				ELSE
					SET @OUTPUT1=@FISLASTERRORTEXTFIC

		END;

GO



ALTER PROC [dbo].[Isd_FiscalSM]
	 @NrRendor	INT,
	 @IsInvoice bit,
	 @OUTPUT1	VARCHAR(MAX) OUTPUT  
AS
BEGIN	
		/*
		UPDATE CONFND SET FiscCertificate = (SELECT * FROM OPENROWSET( BULK 'C:\fiscal\isd.p12',  SINGLE_BLOB) AS a)
		*/
--BEGIN TRY
		DECLARE  @NIPT				VARCHAR(20)
				,@PerqZbr			FLOAT
				,@Date				VARCHAR(100)
				,@Nr				VARCHAR(10)
				,@VlerTot			VARCHAR(20)
				,@SoftNum			VARCHAR(1000)
				,@ManufacNum		VARCHAR(1000)
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
				,@SignedXml			VARCHAR(MAX)
				,@Error				VARCHAR(MAX)
				,@ErrorText			VARCHAR(MAX)
				,@XmlStringTemp		NVARCHAR(MAX)
				,@responseXml		XML
				,@hDOC				INT
				,@EIC				NVARCHAR(MAX)
				,@EICURL			NVARCHAR(MAX)
				,@FISUUID			VARCHAR(50)		
			    ,@BusinessUnit		VARCHAR(50)				-- element ne fature
			    ,@OperatorCode		VARCHAR(50)				-- element ne fature
			    ,@CashRegister		VARCHAR(50)
				,@TIPFISKAL			VARCHAR(50)
				,@KURS2				FLOAT
			    ,@FISMENPAGESEFIC	VARCHAR(50)
			    ,@FISMENPAGESEEIC	VARCHAR(50)
			    ,@MODEPAGESE		VARCHAR(50)
			    ,@KLASEPAGESE		VARCHAR(50)
			    ,@FISPROCES			VARCHAR(50)
			    ,@FISTIPDOK			VARCHAR(50)
				,@KODBANKE			VARCHAR(50)
				,@IBAN				VARCHAR(50)
				,@SWIFT				VARCHAR(50)
				,@BANPERSHKRIM		VARCHAR(50)
				,@XML				XML
				,@IsEinvoice		BIT
				,@SELF				VARCHAR(50)
				,@SENDDATETIME		VARCHAR(100)
				,@Fiscalize			BIT		= 1
				,@DATECREATE		DATETIME
				,@QrCodeLink		VARCHAR(1000)
				,@TIPPAGESE			VARCHAR(MAX)
				,@FISFIC			VARCHAR(MAX)
				,@FISLASTERRORFIC	VARCHAR(MAX)
				,@FISLASTERRORTEXTFIC VARCHAR(MAX)
				,@FISQRCODELINK		VARCHAR(MAX)
				,@FISIIC			VARCHAR(MAX)
				,@FISIICSIG			VARCHAR(MAX)
				,@FISRESPONSEXMLFIC	XML
				,@FISXMLSTRING		VARCHAR(MAX)
				,@FISXMLSIGNED		VARCHAR(MAX)
				,@TIPKLIENT			VARCHAR(MAX)
				,@RELATEDFIC		VARCHAR(MAX)
				,@RELATEDDATE		DATETIME
				,@RELATEDTYPE		VARCHAR(MAX)
				,@FISDATEPARE		DATETIME
				,@FISDATEFUND		DATETIME
				,@FISTVSHEFEKT		INT
				,@IIC_FAT			VARCHAR(1000);
		
   SET @SignedXml = '';
   SET @Fic = '';

  

   SELECT   @NIPT				= CONFND.NIPT
		    ,@BusinessUnit      = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCBUSINESSUNIT')
		    ,@SoftNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSOFTNUM')
		    ,@ManufacNum        = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCMANUFACNUM')
			,@schema			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSCHEMA')
		    ,@FiscUrL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCURL')
			,@EICURL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'EICURL')
		    ,@CertificatePath   = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPATH')
		    ,@CertificatePwd    = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPASS')		
			,@Certificate		= FiscCertificate
			,@TIPFISKAL			= CASE WHEN ISNULL(KODFISKAL,'')='' THEN 'VAT' ELSE KODFISKAL END 
	FROM CONFND; 


	SET @IsEinvoice=@IsInvoice
	SET @SENDDATETIME		= dbo.DATE_1601(getdate())

	
	SELECT    @DATECREATE		= SM.DATECREATE
			, @DATE				= dbo.DATE_1601(SM.DATECREATE)		--> kujdes data duhet edhe me pjesen e ORE-s
			, @Nr				= CONVERT(VARCHAR(10), CONVERT(BIGINT, ISNULL(NRFISKALIZIM,NRDOK)))
			, @VlerTot			= CONVERT(VARCHAR(20), (CONVERT(DECIMAL(18, 2), ROUND(VLERTOT,2))))
			, @PerqZbr			= ISNULL(PERQZBR, 0)
			, @IicBlank			= @NIPT
									+ '|' + dbo.DATE_1601(SM.DATECREATE) 
									+ '|' + CONVERT(VARCHAR(MAX), CONVERT(BIGINT, ISNULL(NRFISKALIZIM,NRDOK)))
									+ '|' + FISBUSINESSUNIT 
									+ '|' + tcr.KODTCR 
									+ '|' + @SoftNum 
									+ '|' + CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(18,2), ROUND(VLERTOT,2)))
			, @CashRegister		= tcr.KODTCR
			, @OperatorCode		= oper.KODFISCAL
			, @BusinessUnit		= FISBUSINESSUNIT
			, @FISMENPAGESEFIC	= pag.KODFIC
			, @FISMENPAGESEEIC	= pag.KODEIC
			, @MODEPAGESE		= CASE WHEN PAG.KLASEPAGESE = 'ARKE' THEN 'CASH' ELSE 'NONCASH' END
			, @KLASEPAGESE		= CASE WHEN PAG.KLASEPAGESE = 'ARKE' THEN 'CASH' ELSE 'NONCASH' END
			, @FISPROCES		= FISPROCES
			, @FISTIPDOK		= FISTIPDOK
			, @FISUUID			= FISUUID
			, @KURS2			= KURS2
			, @KODBANKE			= pag.SHENIM1
			, @IBAN				= (SELECT TOP 1 B.IBAN      FROM BANKAT B WHERE KOD = pag.SHENIM1)
			, @SWIFT			= (SELECT TOP 1 B.SWIFTCODE FROM BANKAT B WHERE KOD = pag.SHENIM1)
			, @BANPERSHKRIM		= (SELECT TOP 1 B.SHENIM2   FROM BANKAT B WHERE KOD = pag.SHENIM1)
			--, @SELF				= CASE WHEN FJ.NIPT=@NIPT AND ISNULL(FJ.KLASETVSH,'')<>'SANG' THEN  'SELF' 
			--						   WHEN FJ.KLASETVSH='SANG' THEN 'DOMESTIC' 
			--						   ELSE  NULL END
			
			,@SELF=(SELECT CASE WHEN ISNULL(SM.KLASETVSH,'') IN ('OTHER','AGREEMENT','SELF') THEN  SM.KLASETVSH
									   WHEN SM.KLASETVSH='SANG' THEN 'SELF' 
									   ELSE  NULL END )
			/*OPTIONAL:  [AGREEMENT - The previous agreement between the parties., 
						  DOMESTIC - Purchase from domestic farmers., 
						  ABROAD - Purchase of services from abroad., 
						  SELF - Self-consumption., 
						  OTHER - Other] 
			*/
			, @TIPPAGESE		= PAG.KLASEPAGESE
			, @TIPKLIENT		= (SELECT TIPNIPT FROM KLIENT WHERE KOD=SM.KODFKL)
			--, @RELATEDFIC		= ISNULL(SM.FISRELATEDFIC,'')
			, @RELATEDTYPE		= CASE WHEN SM.LLOJDOK IN ('FK','T') THEN 'CORRECTIVE' ELSE NULL END
			, @UniqueIdentif	= CASE WHEN ISNULL(FISUUID,'')='' 
											THEN NEWID()
										ELSE SM.FISUUID END

			--, @UniqueIdentif	= CASE WHEN @IsEinvoice=1 THEN NEWID() 
			--						   WHEN ISNULL(FISUUID,'')='' THEN NEWID()
			--						   ELSE FISUUID END
			,@FISDATEPARE		= ISNULL(FISDATEPARE,DTDSHOQ)
			,@FISDATEFUND		= ISNULL(FISDATEFUND,DTDSHOQ)		
			,@FISTVSHEFEKT		= ISNULL(FISTVSHEFEKT,35)
			,@IIC_FAT			= ISNULL(SM.FISIIC,'')		
	FROM SM 
	LEFT JOIN FisTCR tcr ON SM.FISTCR = tcr.KOD
	LEFT JOIN FisOperator oper ON SM.FISKODOPERATOR = oper.KOD
	LEFT JOIN FisMenPagese pag ON SM.FISMENPAGESE = pag.KOD
	WHERE SM.NRRENDOR = @NrRendor;

	SET NOCOUNT ON;
	--SET @UniqueIdentif = NEWID();
	
	
	SELECT TOP 1 @RELATEDDATE=DATEDOKCREATE , @RELATEDFIC=ISNULL(FISIIC,RIGHT('0000000000000000000000000000000000'+NRSERIAL,32)) 
	FROM SMStornimScr WHERE NRD=@NrRendor
	
	
	IF OBJECT_ID('tempdb..#SM') IS NOT NULL 
	DROP TABLE #SM;

	--SELECT * FROM SMPGSCR

	--IF OBJECT_ID('tempdb..#PAGESE') IS NOT NULL 
	--DROP TABLE #PAGESE;
	
	--    SELECT VLERA, TIP = KOD
	--	INTO #PAGESE
	--	FROM SMPGSCR WHERE NRD=@NrRendor
		--AND KOD<>'COMPANY'

	IF OBJECT_ID('tempdb..#fjscr') IS NOT NULL 
	DROP TABLE #SMSCR;
	
	SELECT TOP 1 * INTO #SM
	FROM SM 
	WHERE NRRENDOR=@NrRendor;

					--SELECT * INTO #FJSCR 
					--FROM FJSCR 
					--WHERE NRD=@NrRendor
	


	

	SELECT  NRD,KARTLLG,
			PERSHKRIM=S.PERSHKRIM,
			NJESI=CASE WHEN ISNULL(S.NJESI,'')='' THEN (SELECT TOP 1 KOD FROM NJESI) else S.NJESI END,
			SASI,
			CMIMBS=ROUND(CASE WHEN SASI=0 THEN 1 
						ELSE (CASE WHEN K.PERQINDJE=20 THEN ROUND(S.VLERABS/1.2,2)
						  WHEN K.PERQINDJE=10 THEN ROUND(S.VLERABS/1.1,2)
						  WHEN K.PERQINDJE=0 THEN ROUND(S.VLERABS,2)
						  WHEN K.PERQINDJE=6 THEN ROUND(S.VLERABS/1.06,2)
					 END)/SASI END,2),--ROUND(CMIMBS,2),
		    CMSHZB0MV=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND(CASE WHEN K.PERQINDJE=20 THEN ROUND(S.CMSHZB0/1.2,2)
						  WHEN K.PERQINDJE=10 THEN ROUND(S.CMSHZB0/1.1,2)
						  WHEN K.PERQINDJE=0 THEN ROUND(S.CMSHZB0,2)
						  WHEN K.PERQINDJE=6 THEN ROUND(S.CMSHZB0/1.06,2)
					 END,2) 
					  ELSE  
						ROUND(CASE WHEN SASI=0 THEN 1 
						ELSE (CASE WHEN K.PERQINDJE=20 THEN ROUND(S.VLERABS/1.2,2)
						  WHEN K.PERQINDJE=10 THEN ROUND(S.VLERABS/1.1,2)
						  WHEN K.PERQINDJE=0 THEN ROUND(S.VLERABS,2)
						  WHEN K.PERQINDJE=6 THEN ROUND(S.VLERABS/1.06,2)
					 END)/SASI END,2) 
						
						END,
			CMIMBSTVSH = ROUND((VLERABS / CASE WHEN SASI = 0 THEN 1 ELSE SASI END),2),
			PERQTVSH=K.PERQINDJE,
			VLPATVSH=CASE WHEN K.PERQINDJE=20 THEN ROUND(S.VLERABS/1.2,2)
						  WHEN K.PERQINDJE=10 THEN ROUND(S.VLERABS/1.1,2)
						  WHEN K.PERQINDJE=0 THEN ROUND(S.VLERABS,2)
						  WHEN K.PERQINDJE=6 THEN ROUND(S.VLERABS/1.06,2)
					 END,
			VLTVSH=ROUND(ROUND(VLERABS,2)-CASE WHEN K.PERQINDJE=20 THEN ROUND(S.VLERABS/1.2,2)
						  WHEN K.PERQINDJE=10 THEN ROUND(S.VLERABS/1.1,2)
						  WHEN K.PERQINDJE=0 THEN ROUND(S.VLERABS,2)
						  WHEN K.PERQINDJE=6 THEN ROUND(S.VLERABS/1.06,2)
					 END,2),
			VLERABS=ROUND(ROUND(VLERABS,2),2),
			APLTVSH=CASE WHEN K.PERQINDJE=0 THEN 0 ELSE 1 END,
			APLTVSHFIS=CASE WHEN K.PERQINDJE<>0 THEN 'true' ELSE 'false' END,
			APLINVESTIM=CASE WHEN K.PERQINDJE<>0 THEN 'true' ELSE 'false' END,
			VLPATVSHTAXFREEAMOUNT=CASE WHEN K.PERQINDJE=0 AND ISNULL(KLASETVSH,'')<>'SEXP'  AND KODTVSHFIC='TAX_FREE'
									THEN CASE WHEN K.PERQINDJE=20 THEN ROUND(S.VLERABS/1.2,2)
						  WHEN K.PERQINDJE=10 THEN ROUND(S.VLERABS/1.1,2)
						  WHEN K.PERQINDJE=0 THEN ROUND(S.VLERABS,2)
						  WHEN K.PERQINDJE=6 THEN ROUND(S.VLERABS/1.06,2)
					 END ELSE 0 END,
			PERQDSCN,--=0,
			VLERAZBR=0,--ROUND((SASI*CMSHZB0)-(SASI*CMIMBS),2),
			VLERAPAZBR=S.VLERABS,--ROUND(SASI*CMSHZB0,2),
			EXTVSHFIC=(SELECT TOP 1 KODTVSHFIC FROM KlasaTatim WHERE KlasaTatim.KOD=S.KODTVSH),
			EXTVSHEIC=(SELECT TOP 1 KODTVSHEIC FROM KlasaTatim WHERE KlasaTatim.KOD=S.KODTVSH)
		 
	INTO #SMSCR 
	FROM SM F
	INNER JOIN SMSCR S ON F.NRRENDOR = S.NRD
	INNER JOIN ARTIKUJ A ON S.KARTLLG=A.KOD
	INNER JOIN KlasaTatim K ON K.KOD=A.KODTVSH
	WHERE NRD = @NrRendor AND ISNULL(S.STATROW,'')='' AND SASI<>0

	UPDATE #SM SET	VLTVSH		=	(SELECT ROUND(SUM(round(VLERABS-VLPATVSH,2)),2) FROM #SMSCR),
					VLPATVSH	=	(SELECT ROUND(SUM(round(VLPATVSH,2)),2) FROM #SMSCR),
					VLERTOT		=	(SELECT ROUND(SUM(round(VLERABS,2)),2) FROM #SMSCR),
					KMON		=	CASE WHEN KMON = '' THEN 'ALL' ELSE KMON END;
	--SELECT * FROM #FJSCR


	IF OBJECT_ID('tempdb..#PAGESE') IS NOT NULL 
	DROP TABLE #PAGESE;
	
	    SELECT VLERA, TIP = KOD
		INTO #PAGESE
		FROM SMPGSCR WHERE NRD=@NrRendor
		
	DELETE from #PAGESE	 WHERE VLERA IS NULL





	DECLARE @SUMVLERAPAGESE AS FLOAT;
	DECLARE @SUMVLERASM AS FLOAT;

	SET @SUMVLERAPAGESE=(SELECT ROUND(SUM(VLERA),2) FROM #PAGESE)
	SET @SUMVLERASM=(SELECT ROUND(SUM(VLERABS),2) FROM #SMSCR)

	IF ABS(@SUMVLERASM-@SUMVLERAPAGESE)<>0
	BEGIN
		UPDATE #PAGESE SET VLERA=@SUMVLERASM
		WHERE TIP='BANKNOTE' AND (@SUMVLERASM-@SUMVLERAPAGESE)>0
		
		UPDATE #PAGESE SET VLERA=@SUMVLERASM
		WHERE TIP='BANKNOTE' AND (@SUMVLERASM-@SUMVLERAPAGESE)<0
		
	END


---------------------------------------------FISKALIZIMI
	/* TE HIQET
	IF @TIPPAGESE='BANKE' AND @TIPKLIENT='NUIS'
	SET @IsEinvoice='true'
	ELSE 
	SET @IsEinvoice='false'
	PRINT @IsEinvoice
	PRINT @IsInvoice	
	*/
	

	
	IF ISNULL(@IICBLANK,'')<>''
	EXEC _FiscalGenerateHash @IicBlank, @CertificatePath, @CertificatePwd, @Certificate, 
	@IIC OUTPUT, @IICSIGNATURE OUTPUT, @ERROR OUTPUT, @ERRORtext OUTPUT;
	
	--SELECT @IicBlank,@CertificatePath,@CertificatePwd,@Certificate,@Iic,@IicSignature,@Error,@ErrorText

	

	SET @XML  = (
					SELECT 
							CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 THEN @SENDDATETIME ELSE dbo.DATE_1601(@DATECREATE) END AS 'Header/@SendDateTime',  -- MANDATORY: 
							--CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 then 'NOINTERNET' else null end  AS 'Header/@SubseqDelivType',	
							CASE WHEN @IIC_FAT<>'' AND @IIC_FAT=@IIC THEN 'NOINTERNET' 
								 ELSE
										CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 
										then 'NOINTERNET' 
										else null end  
								END AS 'Header/@SubseqDelivType',
																						   -- MANDATORY:  Duhet shtuar ne fature [NOINTERNET, BOUNDBOOK, SERVICE, TECHNICALERROR]
																						   -- NOINTERNET When TCR operates in the area where there is no Internet available. 
																						   -- BOUNDBOOK When TCR is not working and message cannot be created with TCR. 
																						   -- SERVICE When there is an issue with the fiscalization service that blocks fiscalization. 
																						   -- TECHNICALERROR When there is a temporary technical error at TCR side that prevents successful fiscalization
							--DUHET SHTUAR SUBSEQUENTDELIVERYTYPE
							@UniqueIdentif AS 'Header/@UUID',			 -- MANDATORY: Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
				--SELECT * FROM FJ WHERE NRRENDOR=147156
				(
						SELECT 
								@KLASEPAGESE AS '@TypeOfInv' -- MANDATORY: 
								,@SELF AS '@TypeOfSelfIss'    
			/*OPTIONAL:  [AGREEMENT - The previous agreement between the parties., 
						  DOMESTIC - Purchase from domestic farmers., 
						  ABROAD - Purchase of services from abroad., 
						  SELF - Self-consumption., 
						  OTHER - Other] 
			*/
							   --,'false' AS '@IsSimplifiedInv'							-- MANDATORY:
							   ,CASE WHEN @TIPFISKAL='VAT' THEN 'false' else 'true' end AS '@IsSimplifiedInv'
							   ,dbo.DATE_1601(@DATECREATE) AS '@IssueDateTime'			-- MANDATORY: 
							   ,@Nr + '/' + CONVERT(VARCHAR(4), YEAR(@DATECREATE)) + CASE WHEN @KLASEPAGESE = 'CASH' THEN + '/' + @CashRegister ELSE '' END AS '@InvNum'	-- MANDATORY: NQS CASH PERNDRYSHE BEJE BOSH @CashRegister -- > NrRendor vjetor qe fillon nga 1 ne fillim vit
																														/*
																														A. NUMERIC ORDINAL NUMBER OF INVOICE
																															AND CALENDER YEAR
																															Can contain only numbers 0-9, without leading 0.
																															(also field “InvOrdNum”)
																														B. CALENDER YEAR (YYYY)
																											
																														C. ECD CODE (also field “TCRCode”)
																															Unique ECD CODE that is registered in CIS
																														*/		
							   ,@Nr	AS '@InvOrdNum'						
							   ,@CashRegister	AS '@TCRCode'							--Duhet shtuar ne magazina/fature -- nr i tcr
							   --,'true'			AS '@IsIssuerInVAT'						-- MANDATORY: 
							   ,CASE WHEN @TIPFISKAL='VAT' THEN 'true' else 'false' end	AS '@IsIssuerInVAT'
																						/*
																							Possible values:
																								1. Taxpayer is registered for VAT – 1
																								2. TAXPAYER is not registered for VAT – 2
																						*/
							   --,'0.00'			AS '@TaxFreeAmt'						-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged
							   --,CASE WHEN @TIPFISKAL='VAT' THEN CONVERT(DECIMAL(20, 2), 0) else CONVERT(DECIMAL(20, 2), S.VLERTOT) end			AS '@TaxFreeAmt'						-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged
							   ,(SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHTAXFREEAMOUNT),2)) FROM #SMSCR)	AS '@TaxFreeAmt'-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged							   							   
							   ,NULL			AS '@MarkUpAmt'							-- OPTIONAL: Amount related to special procedure for margin scheme
							   --,NULL			AS '@GoodsExAmt'						-- OPTIONAL: Amount of goods for export from the Republic of Albania. 
							   ,CASE WHEN KLASETVSH='SEXP' THEN  CONVERT(DECIMAL(18, 2), ROUND(VLERTOT*S.KURS2,2)) ELSE NULL END			AS '@GoodsExAmt'						-- OPTIONAL: Amount of goods for export from the Republic of Albania. 
							   ,CONVERT(DECIMAL(18, 2), ROUND(VLPATVSH*S.KURS2,2))	AS '@TotPriceWoVAT'	-- MANDATORY: Total price of the invoice excluding VAT.
							   --,CONVERT(DECIMAL(18, 2), VLERTOT)	AS '@TotPriceWoVAT'
							   ,CASE WHEN @TIPFISKAL='VAT' AND CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2))<>0 THEN CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2)) ELSE NULL end		AS '@TotVATAmt'		-- MANDATORY: Total VAT amount of the invoice. 
							   --,CONVERT(DECIMAL(18, 2), 0) AS '@TotVATAmt'
							   ,CONVERT(DECIMAL(18, 2), ROUND(VLERTOT*S.KURS2,2))	AS '@TotPrice'		-- MANDATORY: Total price of all items including taxes and discounts.
							   ,@OperatorCode	AS '@OperatorCode'						-- MANDATORY: Reference to the operator code, who is operating on TCR and issues invoices.
							   ,@BusinessUnit	AS '@BusinUnitCode'						-- MANDATORY: Business unit (premise) code. Duhet shtuar tek magazina, apo duhet shtuar ne fature? faturat vetem sherbim?				   
							   ,@SoftNum		AS '@SoftCode'							-- MANDATORY: Software code.
							   ,NULL			AS '@ImpCustDecNum'						-- OPTIONAL: Import customs declaration number. Only for internal usage. Must not be populated by a TCR.
							   ,@Iic			AS '@IIC'								-- MANDATORY: Duhet shtuar ne fature, Nr unik i cili behet me concat
							   ,@IicSignature	AS '@IICSignature'						-- MANDATORY: Shenjimi i iic
							   ,CASE WHEN KLASETVSH='SANG' THEN 'true' ELSE 'false'	END		AS '@IsReverseCharge'					-- MANDATORY: If true, the buyer is obliged to pay the VAT.	
							   ,NULL			AS '@PayDeadline'						-- OPTIONAL:  Last day for payment.		--> MANDATORY IF NON CASH
							   ,CASE WHEN @IsEinvoice='0' THEN 'false' ELSE 'true' END		AS '@IsEinvoice'
							   ,
								/*
								CASE WHEN EXISTS(SELECT 1 FROM FJ FREF WHERE ISNULL(FREF.FISIIC,'') = ISNULL(S.FISRELATEDFIC,'')) THEN
								(
									SELECT  ISNULL(FREF.FISIIC,'') AS '@IICRef',				-- IIC reference on the original invoice.
							 				ISNULL(DBO.DATE_1601(FREF.DATECREATE),DBO.DATE_1601(FREF.DATECREATE)) AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.
											CASE WHEN ISNULL(FREF.LLOJDOK,'') IN ('','01') 	THEN 'CORRECTIVE' ELSE 'DEBIT' END AS '@Type'				-- Type of the corrective invoice.
									FROM FJ FREF WHERE ISNULL(FREF.FISIIC,'') = ISNULL(S.FISRELATEDFIC,'')  
									AND ISNULL(S.FISRELATEDFIC,'')<>'' 
									--AND FREF.NRRENDOR=@NrRendor
									FOR XML PATH ('CorrectiveInv'), TYPE
								) ELSE NULL END						-- XML element groups data for an original invoice that will be corrected with current invoice.
							   ,
							  */
							  
								CASE WHEN (@RELATEDFIC<>'' AND @RELATEDTYPE='CORRECTIVE') THEN
										( 
										SELECT
											@RELATEDFIC		AS '@IICRef',				-- IIC reference on the original invoice.
											DBO.DATE_1601(@RELATEDDATE)	AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.
											@RELATEDTYPE	AS '@Type'
										 FOR XML PATH ('CorrectiveInv'), TYPE

										)
										ELSE NULL END
							  
							  ,
							  CASE WHEN EXISTS(SELECT 1 FROM SMSCR WHERE 1 = 2) THEN	-- OPTIONAL: 
								(
									SELECT NULL AS 'BadDebtInv/@IICRef',				--IIC reference on the original invoice.
											NULL AS 'BadDebtInv/@IssueDateTime'			--Date and time the original invoice is created and issued at TCR.
									FOR XML PATH (''), TYPE
								 ) 	ELSE NULL END AS BadDebtInv							--XML element groups data for an original invoice that will be declared bad debt invoice, as uncollectible.				   
							   , CASE WHEN EXISTS(SELECT 1 FROM SMSCR WHERE 1 = 2) THEN	-- MANDATORY case of Summary invoice:
								(														--XML element that contains one IIC reference, e.g. reference of the invoice that is part of the summary invoice.
									SELECT NULL AS 'SumInvIICRef/@IIC',					--IIC of the invoice that is referenced in the summary invoice.
										   NULL AS 'SumInvIICRef/@IssueDateTime'		--Date and time the invoice referenced by the summary invoice is created and issued at TCR.
									WHERE 1=2
									FOR XML PATH (''), TYPE	
								 ) ELSE NULL END AS SumInvIICRefs						--XML element that contains list of IIC-s to which this invoice referred to, e.g. if this is a summary invoice it 
																						--shall contain a reference to each individual invoice issued and fiscalized before and included in this summary invoice.
							   ,														-- OPTIONAL:  
								(
									SELECT	REPLACE(CONVERT(VARCHAR,CAST(@FISDATEPARE AS datetime), 111), '/', '-') AS '@Start',		--Start day of the supply.
											REPLACE(CONVERT(VARCHAR,CAST(@FISDATEFUND AS datetime), 111), '/', '-') AS '@End'	
											--REPLACE(CONVERT(VARCHAR,CAST(eomonth(dtdshoq) AS datetime), 111), '/', '-') AS '@End'			--End day of the supply.
									WHERE 1 = 1
									FOR XML PATH ('SupplyDateOrPeriod'), TYPE	
								  )										--XML element representing supply date or period of supply, if it is different from the date when the invoice was issued.
								,

								(														-- MANDATORY: 

									-- SELECT * FROM CONFIG..TIPDOK WHERE TIPDOK = 'S'
									--SELECT CONVERT(DECIMAL(18, 2), ROUND(S.VLERTOT*S.KURS2,2)) AS 'PayMethod/@Amt',
									--@FISMENPAGESEFIC AS 'PayMethod/@Type',
									 SELECT CONVERT(DECIMAL(18, 2), ROUND(VLERA,2)) AS 'PayMethod/@Amt',
									 TIP  AS 'PayMethod/@Type',
										  -- CASE WHEN MODPG = 'CA' THEN 'BANKNOTE'
												--WHEN MODPG = 'VO' THEN 'ACCOUNT'
												--WHEN MODPG = 'TT' THEN 'OTHER'
												--ELSE 'ACCOUNT' 
												--END AS 'PayMethod/@Type',			-- Type of the payment method.
									  (SELECT ISNULL(KOMENT,'') AS 'Voucher/@Num'
									   FROM SMPGSCR WHERE NRD=@NrRendor	AND ISNULL(KOMENT,'')<>'' AND KOD='COMPANY'	) AS 'PayMethod/@CompCard',				-- Amount payed by payment method in the ALL.
										   (
											SELECT ISNULL(KOMENT,'') AS 'Voucher/@Num'
											--right('111111111111'+ISNULL(KOMENT,''),7) +'-'+ convert(varchar,year(datedok)) +'-'+@NIPT AS 'Voucher/@Num'				--Voucher serial number
											FROM SMPGSCR WHERE NRD=@NrRendor	AND ISNULL(KOMENT,'')<>'' AND KOD='SVOUCHER'	
											FOR XML PATH (''), TYPE
										   ) 'PayMethod/Vouchers'	
									FROM #PAGESE-- XML element that contains list of voucher numbers if the payment method is voucher.
									FOR XML PATH (''), TYPE	
								 ) PayMethods	
								--(														-- MANDATORY: 

								--	-- SELECT * FROM CONFIG..TIPDOK WHERE TIPDOK = 'S'
								--	SELECT CONVERT(DECIMAL(18, 2), ROUND(S.VLERTOT*S.KURS2,2)) AS 'PayMethod/@Amt',
								--	@FISMENPAGESEFIC AS 'PayMethod/@Type',
								--		  -- CASE WHEN MODPG = 'CA' THEN 'BANKNOTE'
								--				--WHEN MODPG = 'VO' THEN 'ACCOUNT'
								--				--WHEN MODPG = 'TT' THEN 'OTHER'
								--				--ELSE 'ACCOUNT' 
								--				--END AS 'PayMethod/@Type',			-- Type of the payment method.
								--		   NULL AS 'PayMethod/@CompCard',				-- Amount payed by payment method in the ALL.
								--		   (
								--			SELECT NULL AS 'Voucher/@Num'				--Voucher serial number
								--			WHERE 1=2				
								--			FOR XML PATH (''), TYPE
								--		   ) Vouchers									-- XML element that contains list of voucher numbers if the payment method is voucher.
								--	FOR XML PATH (''), TYPE	
								-- ) PayMethods											--> MENYRA E PAGESES, PER CDO MENYRE PAGESE 
								--														-- [BANKNOTE, CARD, CHECK, SVOUCHER, COMPANY, ORDER   , ACCOUNT , FACTORING, COMPENSATION, TRANSFER, WAIVER  , KIND     , OTHER   ]
								--														-- [ CASH   , CASH, CASH ,  CASH   , CASH   , NON CASH, NON CASH, NON CASH ,     NON CASH, NON CASH, NON CASH, NON CASH , NON CASH]
								,
																						-- OPTIONAL:  
								(
									SELECT	KMON AS 'Currency/@Code',					--Currency code in which the amount on the invoice should be paid, if different from ALL.
											KURS2 AS 'Currency/@ExRate'
											--,				--Exchange rate applied to calculate the equivalent amount of foreign currency for the total amount expressed in ALL. Exchange rate express equivalent amount of ALL for 1 unit of foreign currency.
											--'0' AS 'Currency/@IsBuying'				--True if exchange transaction is buying of the foreign currency. False if exchange transaction is selling of the foreign currency.
									WHERE KMON NOT IN ('', 'ALL')						
									FOR XML PATH (''), TYPE	
								  )														--XML element representing currency in which the amount on the invoice should be paid, if different from ALL
							   ,(	--nga config -- SELECT * FROM CONFND
									SELECT PERSHKRIM AS 'Seller/@Name',					-- MANDATORY: 
										   @NIPT		 AS 'Seller/@IDNum',				-- MANDATORY:	
										   'NUIS'    AS 'Seller/@IDType',				 -- MANDATORY:	FIX
										   ISNULL(SHENIM1,'') AS 'Seller/@Address', -- MANDATORY FOR FOREIGNER:	FUSHA PER ADRESEN
										   ISNULL(SHENIM2,'Tirane')	 AS 'Seller/@Town',					 -- MANDATORY FOR FOREIGNER:    QYTETI
										   'ALB'     AS 'Seller/@Country'				 -- MANDATORY FOR FOREIGNER:    SHTETI
									FROM CONFND
									FOR XML PATH (''), TYPE
								) ,
								(	--nga klienti
									SELECT	REPLACE(PERSHKRIM, '"', '')  AS 'Buyer/@Name',		-- OPTIONAL| MANDATORY B2B: 
											NIPT						 AS 'Buyer/@IDNum',		-- OPTIONAL| MANDATORY B2B: 
																								/* This field is filled out if buyer is:
																										 a taxpayer of profit tax or a taxpayer of simplified profit tax for small businesses or a taxpayer who is subject to VAT in accordance with special regulations, or
																										 a legal entity to whom goods or services are provided in the territory of the Republic of Albania for the purpose of carrying out his economic activity; or
																										 if personal property of a single value is sold above 500,000 ALL;
																										 or in other cases when the buyer asks for this data to be entered into the invoice, but there is no control in that case. Also, this field is mandatory if the buyer issues the
																										invoice instead of the seller. If this field is entered, beside in the book of sales of the seller, this invoice will also appear in the book of purchase of the buyer if the buyer is a taxpayer.
																										If the buyer is an individual who requires invoice for recognition of the cost of the medication, no book of purchase will be created for him, but a special application will be created to register all the data on
																										all invoices where he has appeared as a buyer and that information will be exchanged with the CIS system. Also, data may be entered for a foreigner or diplomat who will request a VAT refund and this information will be exchanged with the CIS system as well.
																								*/
											ISNULL(C.TIPNIPT,'NUIS')	 AS 'Buyer/@IDType',	-- OPTIONAL| MANDATORY B2B: 
																								-- NQS ESHTE PERSON FIZIK DUHET SPECIFIKUAR --> NDARES PER PERSON FIZIK APO SUBJEKT -- [NUIS: NUIS-number | ID: Personal ID-number | PASS: Passport-number | VAT: VAT-number | TAX: TAX-number ]
																						
											ISNULL(ADRESA1, '')			 AS 'Buyer/@Address',	-- OPTIONAL| MANDATORY IF NAME IS FILLED: 
											ISNULL(ADRESA2, '')			 AS 'Buyer/@Town',		-- OPTIONAL| MANDATORY IF NAME IS FILLED: 
											ISNULL(LEFT(ADRESA3, 3), '') AS 'Buyer/@Country'	-- OPTIONAL| MANDATORY IF NAME IS FILLED: 	
									FROM KLIENT C 
									WHERE C.KOD = S.KODFKL
									AND ISNULL(C.NIPT, '') != ''
									FOR XML PATH (''), TYPE
								)
								,
									(	SELECT  KARTLLG AS 'I/@C',								-- OPTIONAL:  Code of the item from the barcode or similar representation
											LEFT(PERSHKRIM, 50) AS 'I/@N',						-- MANDATORY: Name of the item (goods or services).
											--CONVERT(DECIMAL(18, 2), VLPATVSH) AS 'I/@PA',		-- MANDATORY: Total price of goods after the tax and applying discounts Negative values allowed when CorrectiveInv or BadDebtInv exist.
											CONVERT(DECIMAL(18, 2), ROUND(VLERABS*S.KURS2,2)) AS 'I/@PA',		-- MANDATORY: Total price of goods after the tax and applying discounts Negative values allowed when CorrectiveInv or BadDebtInv exist.
											CONVERT(DECIMAL(18, 2), ROUND(VLPATVSH*S.KURS2,2)) AS 'I/@PB',		-- MANDATORY: Total price of goods and services before the tax Negative values allowed when CorrectiveInv or BadDebtInv exist.
											CONVERT(DECIMAL(18, 2), SASI) AS 'I/@Q',			-- MANDATORY: Amount or number (quantity) of items. Negative values allowed when CorrectiveInv or BadDebtInv exist.
											CONVERT(DECIMAL(18, 2), PERQDSCN) AS 'I/@R',					-- OPTIONAL:  Percentage of the rebate.	
											CASE WHEN PERQDSCN<>0 AND VLTVSH<>0 THEN 'true' ELSE 'false' end AS 'I/@RR',	-- OPTIONAL:  Is rebate reducing tax base amount?
											NJESI AS 'I/@U',									-- MANDATORY: What is the item’s unit of measure (piece, weight measure, length measure, etc.)
											--CONVERT(DECIMAL(18, 2), ROUND(CMIMBS*S.KURS2,2)) AS 'I/@UPB',		-- MANDATORY: Unit price before Value added tax is applied
											CASE WHEN PERQDSCN<>0  THEN CONVERT(DECIMAL(18, 2), ROUND(CMSHZB0MV,2)) ELSE CONVERT(DECIMAL(18, 2), ROUND(CMIMBS*S.KURS2,2)) END AS 'I/@UPB',		-- MANDATORY: Unit price before Value added tax is applied
											--CONVERT(DECIMAL(18, 2), CMIMBS) AS 'I/@UPA',		-- MANDATORY: Unit price after Value added tax is applied
											CONVERT(DECIMAL(18, 2), ROUND(VLERABS/SASI*S.KURS2,2)) AS 'I/@UPA',
								
											-- nuk duhet APLTVSH
											 CASE WHEN ISNULL(KLASETVSH,'')='SEXP' THEN 'EXPORT_OF_GOODS' 
											  WHEN @TIPFISKAL='FRE' THEN 'TAX_FREE' 
											  WHEN ISNULL(EXTVSHFIC,'') IN ('TYPE_1','TYPE_2','MARGIN_SCHEME') THEN ISNULL(EXTVSHFIC,'')
											  WHEN ISNULL(EXTVSHFIC,'')='VAT' THEN NULL
											  ELSE ISNULL(EXTVSHFIC,'') END AS 'I/@EX',			-- OPTIONAL: 
																																			-- Exempt from VAT.
																																			-- TYPE_1 Exempt type 1. Exempted on the basis of Article 51 of the VAT law 
																																			-- TYPE_2 Exempt type 2. Exempted on the basis of Articles 53 and 54 of the VAT law 
																																			-- TAX_FREE Tax free amount. Sales without VAT that is exempted based on VAT law other then articles 51, 53 and 54 of VAT law, and is not margin scheme nor export of goods 
																																			-- MARGIN_SCHEME Margin scheme (Travel agents VAT scheme, second hand goods VAT scheme, works of art VAT scheme, collectors’ items and antiques VAT scheme etc.). 
																																			-- EXPORT_OF_GOODS Export of goods. No VAT.
																					

											--CASE WHEN KLASETVSH='SEXP' THEN APLINVESTIM ELSE NULL END AS 'I/@IN',								-- If true, the item is investment for the buyer. Mandatory only for importation of goods.
											NULL AS 'I/@IN',								-- If true, the item is investment for the buyer. Mandatory only for importation of goods.
											--CASE WHEN VLTVSH = 0 AND APLTVSHFIS = 'false' THEN NULL ELSE CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2)) END  AS 'I/@VA',		-- MANDATORY: Amount of value added tax for goods and services. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true. Negative values allowed when CorrectiveInv or BadDebtInv exist.
											--CASE WHEN VLTVSH = 0 AND APLTVSHFIS = 'false' THEN NULL ELSE CONVERT(DECIMAL(18, 2), PERQTVSH) END AS 'I/@VR',		-- MANDATORY: Rate of value added tax. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true.
								CASE WHEN (EXTVSHFIC<>'VAT' OR ISNULL(@TIPFISKAL,'')<>'VAT') 
								THEN NULL ELSE  CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2)) END  AS 'I/@VA',

								CASE WHEN (EXTVSHFIC<>'VAT' OR ISNULL(@TIPFISKAL,'')<>'VAT') 
								THEN NULL ELSE  CONVERT(DECIMAL(18, 2), PERQTVSH) END AS 'I/@VR',
								--			CASE WHEN @TIPFISKAL='FRE' THEN NULL ELSE CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2)) END  AS 'I/@VA',		-- MANDATORY: Amount of value added tax for goods and services. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true. Negative values allowed when CorrectiveInv or BadDebtInv exist.
								--			CASE WHEN @TIPFISKAL='FRE' THEN NULL ELSE CONVERT(DECIMAL(18, 2), PERQTVSH) END AS 'I/@VR',		-- MANDATORY: Rate of value added tax. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true.
								
											CASE WHEN EXISTS(SELECT 1 FROM SMSCR WHERE 1 = 2) THEN
											(													-- OPTIONAL: 
												SELECT (SELECT NULL AS 'VD/@D',					-- Expiration date of the voucher.
																NULL AS 'VD/@N'					-- Nominal voucher value.			
																									--> DUHET E GRUPUAR VETEM 1 ELEMENT
														FOR XML PATH(''), TYPE					-- XML element representing serial numbers of voucher sold.
														),	 
														(SELECT NULL AS 'V/@Num'				--Voucher serial number.
																									--> DUHET TE KTHEJE ARRAY ME ROOT VN
														FOR XML PATH(''), TYPE 					-- XML element representing serial numbers of voucher sold.
														) VN	 
												FOR XML PATH(''), TYPE
											) ELSE NULL END AS VS												-- XML element representing vouchers sold
								
									FROM #SMSCR C 					
									FOR XML PATH (''), TYPE
								) Items
								,																-- MANDATORY IF ISSUER IN VAT:
								(CASE WHEN ISNULL(KLASETVSH,'')<>'SEXP' THEN
								(	SELECT  CONVERT(VARCHAR(10), CONVERT(DECIMAL(18, 0), COUNT(1)))	  AS 'SameTax/@NumOfItems',
											CONVERT(DECIMAL(18, 2), ROUND(SUM(VLPATVSH*@KURS2),2))					  AS 'SameTax/@PriceBefVAT',
											CASE WHEN EXTVSHFIC NOT IN ('TYPE_1','TYPE_2') 
												 THEN CONVERT(DECIMAL(18, 2), PERQTVSH) ELSE NULL END AS 'SameTax/@VATRate',
											CASE WHEN EXTVSHFIC IN ('TYPE_1','TYPE_2') 
												 THEN EXTVSHFIC ELSE NULL END						  AS 'SameTax/@ExemptFromVAT',
											--APLTVSH													  AS 'SameTax/@ExemptFromVAT',		-- nuk duhet APLTVSH
																													-- Exempt from VAT.
																														-- TYPE_1 Exempt type 1. Exempted on the basis of Article 51 of the VAT law 
																														-- TYPE_2 Exempt type 2. Exempted on the basis of Articles 53 and 54 of the VAT law 
											CASE WHEN EXTVSHFIC NOT IN ('TYPE_1','TYPE_2')
											THEN CONVERT(DECIMAL(18, 2), ROUND(SUM(VLTVSH*@KURS2),2)) ELSE NULL END
											AS 'SameTax/@VATAmt'
									FROM #SMSCR
									WHERE @TIPFISKAL='VAT' AND ISNULL(EXTVSHFIC,'') <>('MARGIN_SCHEME')
									GROUP BY PERQTVSH, APLTVSHFIS,EXTVSHFIC
									FOR XML PATH (''), TYPE
								) 
								ELSE
								NULL
								END)SameTaxes,
																							-- OPTIONAL:
								(	--per tu interpretuar cfare jane?
									SELECT  1		 AS 'ConsTax/@NumOfItems',				-- Number of items under consumption tax.
											VLPATVSH AS 'ConsTax/@PriceBefConsTax',			-- Price before adding consumption tax.
											PERQTVSH AS 'ConsTax/@ConsTaxRate',				-- Rate of the consumption tax.
											VLTVSH   AS 'ConsTax/@ConsTaxAmt'				-- Amount of consumption tax.
									FROM #SMSCR C 
									WHERE 1 = 2 -- NQS NUK KA REKORDE HIQET VETE SI TAG						
									FOR XML PATH (''), TYPE
								) ConsTaxes													-- XML element representing one cons tax item.
								, (															-- OPTIONAL: FEES
									SELECT  NULL	 AS 'Fee/@Type',						-- Type of the fee.
																								-- PACK Packaging fee 
																								-- BOTTLE Fee for the return of glass bottles 
																								-- COMMISSION Commission for currency exchange activities 
																								-- OTHER Other fees that are not listed here.
											VLPATVSH AS 'Fee/@Amt'							-- Amount of the fee.
									FROM #SMSCR C 
									WHERE 1 = 2 -- NQS NUK KA REKORDE HIQET VETE SI TAG
									FOR XML PATH (''), TYPE
								) Fees														-- XML element representing list of fees.
					FROM #SM  S
					WHERE S.NRRENDOR = @NrRendor
					FOR XML PATH('Invoice'), TYPE
				)
				FOR XML PATH('RegisterInvoiceRequest'));

			--SELECT @XML
    
				--Gjenerimi i url per kontrollin e fiskalizimit te fatures
				SET @QrCodeLink = CASE WHEN @FiscUrL LIKE '%-TEST%' THEN 'https://efiskalizimi-app-test.tatime.gov.al/invoice-check/#/verify?'
																	ELSE REPLACE('https://efiskalizimi-app-test.tatime.gov.al/invoice-check/#/verify?', '-TEST', '')
																	END
								+ 'iic='	+ @Iic
								+ '&tin='	+ @NIPT
								+ '&crtd='	+ @Date
								+ '&ord='   + @Nr
								+ '&bu='    + @BusinessUnit				
								+ '&cr='    + @CashRegister
								+ '&sw='    + @SoftNum
								+ '&prc='   + CONVERT(VARCHAR(50),CONVERT(DECIMAL(34, 2),ROUND(@VlerTot*@KURS2,2)));  
			  -- SELECT 	@QrCodeLink,@Iic,@NIPT,@Date,@Nr,@BusinessUnit,@CashRegister,@SoftNum,@VlerTot
	
				SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterInvoiceRequest>','<RegisterInvoiceRequest xmlns="' + @Schema +'" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3">') AS XML)

				SELECT @XmlString = CAST(@XML AS VARCHAR(MAX))  

				IF(@Fiscalize != 0)	
				BEGIN
					--BEGIN TRY
							
						EXEC _FiscalProcessRequest 
							@InputString		 = @XmlString,
							@CertBinary		     = @Certificate,
							@CertificatePath	 = @CertificatePath, 
							@Certificatepassword = @CertificatePwd, 
							@Url				 = @FiscUrL,
							@Schema				 = @Schema,
							@ReturnValue		 = 'FIC',
							@useSystemProxy		 = '',
							@SignedXml			 = @SignedXml	OUTPUT, 
							@Fic				 = @Fic			OUTPUT, 
							@Error				 = @FISLASTERRORFIC		OUTPUT, 
							@Errortext			 = @FISLASTERRORTEXTFIC	OUTPUT,
							@responseXml		 = @FISRESPONSEXMLFIC OUTPUT;
				END			
					
			
			SELECT  @FISFIC					=@FIC,
					--@FISLASTERRORFIC		=@Error,
					--@FISLASTERRORTEXTFIC	=@Errortext ,
					@FISQRCODELINK			=@QrCodeLink,
					@FISIIC					=@IIC,
					@FISIICSIG				=@IICSIGNATURE,
					--@FISRESPONSEXMLFIC		=@responseXml,
					@FISXMLSTRING			=@XmlString,	
					@FISXMLSIGNED			=@SignedXml

PRINT @FISIIC
PRINT @FISFIC

				
					
				--SELECT 	    @QrCodeLink
			 --  , @Xml			
			 --  , @Error			
			 --  , @ErrorText
			 --  , @responseXml,@Iic,@Fic,@SignedXml
					
				----	--END TRY
					--BEGIN CATCH
						
					--END CATCH
	
	


	--PRINT 'AA'
				
					UPDATE SM SET		  FISFIC			    = CASE WHEN @FISLASTERRORFIC = '0' THEN @FISFIC ELSE '' END ,
										  FISLASTERRORFIC		= @FISLASTERRORFIC,
										  FISLASTERRORTEXTFIC	= @FISLASTERRORTEXTFIC,
										  FISQRCODELINK			= @FISQRCODELINK,
										  FISIIC				= @FISIIC ,
										  FISIICSIG				= @FISIICSIG,
										  FISRESPONSEXMLFIC		= CONVERT(VARCHAR(MAX),@FISRESPONSEXMLFIC),
										  FISXMLSTRING			= @FISXMLSTRING,
										  FISXMLSIGNED			= @FISXMLSIGNED,
										  FISUUID				= @UniqueIdentif,
										  --DATECREATE			= @DATECREATE,
										  FISSTATUS				= CASE WHEN @FISLASTERRORFIC = '0' THEN 'FISKALIZUAR' ELSE 'PA FISKALIZUAR' END,
										  KASEPRINT				= CASE WHEN @FISLASTERRORFIC = '0' THEN 1 ELSE 0 END,
										  FISEIC				= CASE WHEN @FISLASTERRORFIC = '0' THEN 'FISKALIZUAR' ELSE '' END ,
										  FISKALIZUAR			= CASE WHEN @FISLASTERRORFIC = '0' THEN 1 ELSE 0 END ,
										  NRSERIAL				= CASE WHEN @FISLASTERRORFIC = '0' THEN @FISFIC ELSE '' END 
							WHERE NRRENDOR = @NrRendor

					
				IF ISNULL(@FISLASTERRORFIC,'1') = '0'
					SET @OUTPUT1=@FISLASTERRORFIC
				ELSE
					SET @OUTPUT1=@FISLASTERRORTEXTFIC--+@FISFIC

	

 END;

GO

ALTER   procedure [dbo].[Isd_FiscalTestFieldsDoc]
(
  @pNrRendor     Int,
  @pTableName    Varchar(20),    
  @pUser         Varchar(30)
)


AS

DECLARE @FisBusUnitT VARCHAR(30),
		@FisTcrT  VARCHAR(30),
		@FISTCR VARCHAR(50),
		@NrFiskalizim   Int,
		@TIPPAGESE2 VARCHAR(MAX),
		@FISFIC2 VARCHAR(100);


IF @pTableName='FJ'
BEGIN
		
SET @FISFIC2= (SELECT ISNULL(FISFIC,'') FROM FJ WHERE NRRENDOR=@pNrRendor)		

SET @TIPPAGESE2=(SELECT top 1 KLASEPAGESE FROM FJ A INNER JOIN FisMenPagese B ON  A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@PNrRendor)
SET @FISTCR=(SELECT top 1 KODTCR FROM FJ A INNER JOIN FisTCR B ON  A.FISTCR=B.KOD WHERE A.NRRENDOR=@PNrRendor)


  set @FisBusUnitT=(select FISBUSINESSUNIT from fj where NRRENDOR=@PNrRendor)
  set @FisTcrT=(select FisTCR from fj where NRRENDOR=@PNrRendor)

									

					DECLARE @NDRYSHONRDSHOQ VARCHAR(10)

					SET @NDRYSHONRDSHOQ=(SELECT TOP 1 VLERA FROM FISCONFIG WHERE FUSHA='NDRYSHONRDSHOQ')

					IF @NDRYSHONRDSHOQ='PO' AND @FISFIC2=''
					BEGIN
					 
										-- EXEC dbo.Isd_FisNrFiskalizim_2 'FJ',@PNrRendor,@NRFISKALIZIM OUTPUT
			  
			 							 IF @TIPPAGESE2='BANKE'
			 							 UPDATE FJ SET  NRDSHOQ=CONVERT(VARCHAR,NRFISKALIZIM)+'/'+CONVERT(VARCHAR,YEAR(DATEDOK))
			 							 WHERE NRRENDOR=@PNrRendor 

			 							 IF @TIPPAGESE2<>'BANKE'
												 UPDATE FJ SET  NRDSHOQ=CONVERT(VARCHAR,NRFISKALIZIM)+'/'+CONVERT(VARCHAR,YEAR(DATEDOK))+'/'+@FISTCR
												 WHERE NRRENDOR=@PNrRendor 

										  EXEC dbo.Isd_DocSaveFJ @PNrRendor,'M',1,'#12345678','ADMIN','1234567890'
					
					END
END


     DECLARE @NrRendor        Int,
             @Minutes         Int,
             @FisBusUnit      Varchar(30),
             @FisProces       Varchar(30),
             @FisTipDok       Varchar(30),
             @FisMenPagese    Varchar(30),
			 @FisTcrCode	  Varchar(30),
			 @FisOperator	  Varchar(30),
             @OkUnit          Int,
             @OkProc          Int,
             @OkTip           Int,
             @OkPag           Int,
			 @OkkodTVSH		  Int,
			 @OkperqTVSH	  Int,
			 @OkTcrCode		  Int,
			 @OkOperator	  Int,
             @sMsg            Varchar(500),
             @sMin            Varchar(30),
			 @sTableName      Varchar(20),
			 @kodTvsh		  Varchar(20),
			 @perqTVSH		  Varchar(20),
			 @FISFIC		  VARCHAR(60),
			 @TIPPAGESE		  VARCHAR(MAX),
			 @TIPKLIENT       VARCHAR(MAX),
			 @SELF		      VARCHAR(MAX),
			 @NIPT			  VARCHAR(MAX),
			 @MODEPAGESE      VARCHAR(MAX),
			 @KASEVL1FATTAT	  FLOAT,
			 @KASEVL2FATTAT	  FLOAT;

-------------------------------------------------------------------------------
		DECLARE  @PerqZbr			FLOAT
				,@Date				VARCHAR(100)
				,@Nr				VARCHAR(10)
				,@VlerTot			VARCHAR(20)
				,@SoftNum			VARCHAR(1000)
				,@ManufacNum		VARCHAR(1000)
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
				,@SignedXml			VARCHAR(MAX)
				,@Error				VARCHAR(MAX)
				,@ErrorText			VARCHAR(MAX)
				,@XmlStringTemp		NVARCHAR(MAX)
				,@responseXml		XML
				,@hDOC				INT
				,@EIC				NVARCHAR(MAX)
				,@EICURL			NVARCHAR(MAX)
				,@FISUUID			VARCHAR(50)		
			    ,@BusinessUnit		VARCHAR(50)				-- element ne fature
			    ,@OperatorCode		VARCHAR(50)				-- element ne fature
			    ,@CashRegister		VARCHAR(50)
				,@TIPFISKAL			VARCHAR(50)
				,@KURS2				FLOAT
			    ,@FISMENPAGESEFIC	VARCHAR(50)
			    ,@FISMENPAGESEEIC	VARCHAR(50)
			    
			    ,@KLASEPAGESE		VARCHAR(50)
			    
				,@KODBANKE			VARCHAR(50)
				,@IBAN				VARCHAR(50)
				,@SWIFT				VARCHAR(50)
				,@BANPERSHKRIM		VARCHAR(50)
				,@XML				XML
				,@IsEinvoice		BIT
				
				,@SENDDATETIME		VARCHAR(100)
				,@Fiscalize			BIT		= 1
				,@DATECREATE		DATETIME
				,@QrCodeLink		VARCHAR(1000)
				
				,@FISFISFJ			VARCHAR(MAX)
				,@FISLASTERRORFIC	VARCHAR(MAX)
				,@FISLASTERRORTEXTFIC VARCHAR(MAX)
				,@FISQRCODELINK		VARCHAR(MAX)
				,@FISIIC			VARCHAR(MAX)
				,@FISIICSIG			VARCHAR(MAX)
				,@FISRESPONSEXMLFIC	XML
				,@FISXMLSTRING		VARCHAR(MAX)
				,@FISXMLSIGNED		VARCHAR(MAX)
				
				,@RELATEDFIC		VARCHAR(MAX)
				,@RELATEDDATE		DATETIME
				,@RELATEDTYPE		VARCHAR(MAX)
				,@FISDATEPARE		DATETIME
				,@FISDATEFUND		DATETIME
				,@FISTVSHEFEKT		INT
				,@SHENIMEEIC		VARCHAR(200)
				,@MONEDHEBAZE       FLOAT
				,@KMON				VARCHAR(10)
				,@DATEDOK			DATETIME
				,@ARKA				INT
				,@FisMenPageseOrg	VARCHAR(30)

SET @MONEDHEBAZE=ISNULL(ROUND((SELECT KURS1/KURS2 FROM MONEDHA WHERE KOD='ALL'),6),1)
SET @ARKA=1
		
   SET @SignedXml = '';
   SET @Fic = ISNULL(@Fic,'');


   --UPDATE LOGARKA SET ERROR='0' 
   --from logarka WHERE NRRENDOR=1032

   

   SELECT    @NIPT				= CONFND.NIPT
		    ,@BusinessUnit      = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCBUSINESSUNIT')
		    ,@SoftNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSOFTNUM')
		    ,@ManufacNum        = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCMANUFACNUM')
			,@schema			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSCHEMA')
		    ,@FiscUrL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCURL')
			,@EICURL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'EICURL')
		    ,@CertificatePath   = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPATH')
		    ,@CertificatePwd    = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPASS')		
			,@Certificate		= FiscCertificate
			,@TIPFISKAL			= CASE WHEN ISNULL(KODFISKAL,'')='' THEN 'VAT' ELSE KODFISKAL END 
	FROM CONFND; 

	select  @KASEVL1FATTAT=KASEVL1FATTAT,
			@KASEVL2FATTAT=KASEVL2FATTAT
	from CONFIGMG
	
	SET @SENDDATETIME		= dbo.DATE_1601(getdate())

	--------modifikim per mon baze euro
	SELECT 	 @KURS2			= CASE WHEN @MONEDHEBAZE<>1 THEN 
																	CASE WHEN ISNULL(FJ.KMON,'')='' THEN @MONEDHEBAZE
																		 WHEN ISNULL(FJ.KMON,'')='ALL' THEN 1
																	ELSE  @MONEDHEBAZE*KURS2 END
								  ELSE KURS2 END
			, @KMON				= CASE WHEN @MONEDHEBAZE<>1 THEN 
																	CASE WHEN ISNULL(FJ.KMON,'')='' THEN 'EUR'
																		 WHEN ISNULL(FJ.KMON,'')='ALL' THEN ''
																	ELSE FJ.KMON END
								  ELSE KMON END
   FROM FJ WHERE NRRENDOR=@pNrRendor
   ----------

   
		IF OBJECT_ID('tempdb..#fj') IS NOT NULL 
		DROP TABLE #FJ;

		IF OBJECT_ID('tempdb..#FJSCRER') IS NOT NULL 
		DROP TABLE #FJSCRER;


		SELECT TOP 1 * INTO #FJ 
		FROM FJ 
		WHERE NRRENDOR=@pNrRendor;

						--SELECT * INTO #FJSCRER 
						--FROM FJSCR 
						--WHERE NRD=@NrRendor


		SELECT NRD,
				VLERABSMV=ROUND(ROUND(VLERABS,2)*@KURS2,2)
			  
		INTO #FJSCRER 
		FROM FJ F
		INNER JOIN FJSCR S ON F.NRRENDOR = S.NRD
		INNER JOIN KLASATATIM K ON S.KODTVSH=K.KOD
		WHERE NRD = @pNrRendor;

		CREATE INDEX FJSCR_Idx ON #FJSCRER(NRD)


	
-------------------------------------------------------------------------------

             
         SET @sTableName    = ISNULL(@pTableName,'');  
         SET @NrRendor      = ISNULL(@pNrRendor,0);
		 SET @sMsg          = '';
		 SET @FISFIC= (SELECT ISNULL(FISFIC,'') FROM FJ WHERE NRRENDOR=@pNrRendor)
		 SET @MODEPAGESE= (SELECT  CASE WHEN PAG.KLASEPAGESE = 'ARKE' THEN 'CASH' ELSE 'NONCASH' END FROM FJ INNER JOIN FisMenPagese PAG ON FJ.FISMENPAGESE=PAG.KOD WHERE FJ.NRRENDOR=@pNrRendor)
		 SET @TIPPAGESE=(SELECT top 1 KLASEPAGESE FROM FJ A INNER JOIN FisMenPagese B ON  A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@pNrRendor)
		 SET @TIPKLIENT=(SELECT top 1 ISNULL(A.TIPNIPT,B.TIPNIPT)  FROM FJ A INNER JOIN KLIENT B ON A.KODFKL=B.KOD WHERE A.NRRENDOR=@pNrRendor)
		 SET @SELF=(SELECT CASE WHEN ISNULL(A.KLASETVSH,'') IN ('SANG','SELF','SEXP','OTHER') THEN  A.KLASETVSH
							ELSE  NULL END FROM FJ A WHERE A.NRRENDOR=@pNrRendor)
	
		--SELECT @FISFIC
		IF @TIPPAGESE='BANKE' AND @TIPKLIENT='NUIS' AND @SELF IS NULL AND @FISFIC<>'' AND @sTableName='FJ'
		BEGIN
			 ------------------------------------------------------------------

			 --PRINT 'HYRI'
			 --PRINT @NIPT
			 --PRINT @SoftNum
			 --SELECT * FROM #FJSCRER
		 		SELECT   @IicBlank		= @NIPT
										+ '|' + dbo.DATE_1601(FJ.DATECREATE) 
										+ '|' + CONVERT(VARCHAR(MAX), CONVERT(BIGINT, NRFISKALIZIM))
										+ '|' + LOWER(FISBUSINESSUNIT) 
										+ '|' + LOWER(tcr.KODTCR) 
										+ '|' + @SoftNum 
										+ '|' + CONVERT(VARCHAR(MAX), (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLERABSMV),2)) FROM #FJSCRER))

				FROM FJ 
				LEFT JOIN FisTCR tcr ON FJ.FISTCR = tcr.KOD
				LEFT JOIN FisOperator oper ON FJ.FISKODOPERATOR = oper.KOD
				LEFT JOIN FisMenPagese pag ON FJ.FISMENPAGESE = pag.KOD
				WHERE fj.NRRENDOR = @pNrRendor;

			  --PRINT @IICBLANK

				IF ISNULL(@IICBLANK,'')<>''
				EXEC _FiscalGenerateHash @IicBlank, @CertificatePath, @CertificatePwd, @Certificate, 
				@IIC OUTPUT, @IICSIGNATURE OUTPUT, @ERROR OUTPUT, @ERRORtext OUTPUT;

				--SELECT @IicBlank,@CertificatePath,@CertificatePwd,@Certificate,@Iic,@IicSignature,@Error,@ErrorText

					DECLARE @tempOutput VARCHAR(MAX),
							@tempDateFat DATETIME,
							@tempDateFat2 DATETIME,
							@tempNr	VARCHAR(50),
							@tempVlera float,
							@tempEic VARCHAR(50);
							
					
					
					SELECT @tempNr = CONVERT(VARCHAR(10), CONVERT(BIGINT, NRFISKALIZIM)) + '/' + CONVERT(VARCHAR(4), YEAR(DATECREATE)) ,
						   @tempDateFat = CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, DATECREATE))),
						   @tempDateFat2= CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, DATECREATE+1))),
						   @tempVlera=Vlertot
					FROM FJ 
					WHERE NRRENDOR = @pNrRendor;

					EXEC __eInvoiceGetRequest '', 'SELLER', @tempDateFat, @tempDateFat2, 0, @tempOutput OUT

					IF OBJECT_ID(N'tempdb..##FisFjEicTemp') IS NOT NULL
					BEGIN
							
						set @tempEic=(select FISEIC = (SELECT TOP 1 EIC FROM ##FisFjEicTemp WHERE DocNumber = @tempNr AND ABS(AMOUNT-@tempVlera)<=1)
						from fj
						WHERE NRRENDOR = @pNrRendor);

					END
					ELSE
					BEGIN
					SET	@sMsg= @sMsg + 'Serveri i tatimeve ka probleme ose Fatura elektronike nuk gjendet'; 
					END
					--SELECT @tempNr,@tempVlera,@tempEic
					 
					--PRINT 'tempEic'+@tempEic

					IF ISNULL(@tempEic,'')<>'' 
					UPDATE FJ SET FISEIC = @tempEic,FISKALIZUAR=1,FISSTATUS = 'DELIVERED',NRSERIAL=FISFIC
					WHERE NRRENDOR = @pNrRendor;	
					
					IF ISNULL(@tempEic,'')='' 
					UPDATE FJ SET FISFIC ='',FISIIC='',FISIICSIG='',DATECREATE=GETDATE()
					WHERE NRRENDOR = @pNrRendor AND FISIIC<>@IIC	

		 END
-------------------------------------------------------------------

DECLARE @OkBuTcrFJ	INT,
		@OkBuTcrFF	INT,
		@OkBuTcrSM	INT,
		@kodTvshTip INT,
		@EINVOICE	BIT,
		@StatusTcr	BIT,
		@StatusOper	BIT,
		@StatusBu	BIT

DECLARE @DEKLAROCASH VARCHAR(10)

DECLARE @NIPTFJ VARCHAR(30)

SET @NIPTFJ=(SELECT TOP 1 NIPT FROM FJ WHERE NRRENDOR=@NrRendor)

SET @DEKLAROCASH=(SELECT TOP 1 VLERA FROM FISCONFIG WHERE FUSHA='DEKLAROCASH')

SET @EINVOICE=(SELECT TOP 1 EINVOICE FROM FJ WHERE NRRENDOR=@NrRendor)


		  SET @OkperqTVSH=1
		  DECLARE @NdermAdres varchar(max),
				  @NdermRreth varchar(max),
				  @NdermShtet varchar(max),
				  @NdermNipt  varchar(max), 
				  @BUYERNAME  VARCHAR(100),
				  @BuyerIDNum VARCHAR(100),
				  @BuyerIDType	VARCHAR(100),
				  @BuyerAddress	VARCHAR(100),
				  @BuyerTown	VARCHAR(100),
				  @BuyerCountry VARCHAR(100),
				  @TIPNIPT      VARCHAR(100);


		  SELECT @NdermAdres=ISNULL(SHENIM1,''),
				 @NdermRreth=ISNULL(SHENIM2,''),
				 @NdermShtet=ISNULL(SHENIM3,''),
				 @NdermNipt =ISNULL(NIPT,'')
		  FROM CONFND
		  IF @sTableName IN ('FJ','SM','FF')
		     BEGIN

               IF @sTableName='FJ'
			      BEGIN
			            IF @NrRendor<=0 OR (NOT EXISTS (SELECT * FROM FJ WHERE NRRENDOR=@NrRendor))
                           BEGIN
                             SELECT MsgError = 'Dokumenti fature shitje e panjohur ..!';
                             RETURN;
                           END;

                    SELECT @DATEDOK		  = DATEDOK,
						   @FisBusUnit    = ISNULL(FisBusinessUnit,''),
                           @FisProces     = ISNULL(FisProces,''),
                           @FisTipDok     = ISNULL(FisTipDok,''),
                           @FisMenPagese  = ISNULL(FisMenPagese,''),
                           @Minutes       = DATEDIFF(MINUTE,DateCreate,GetDate()),
						   @FisTcrCode	  = ISNULL(Fistcr,''),
						   @FisOperator	  = fj.FISKODOPERATOR ,
						   @VlerTot		  = ROUND(VLERTOT*KURS2,2),
						   @StatusTcr	  = (select top 1 NOTACTIV from FisTCR where kod=fj.Fistcr),
						   @StatusOper	  = (select top 1 NOTACTIV from FisOperator where kod=fj.FISKODOPERATOR),
						   @StatusBu	  = (select top 1 NOTACTIV from FisBusUnit where kod=fj.FisBusinessUnit)
                      FROM FJ 
                     WHERE NRRENDOR=@pNrRendor; 
					
					SET @FisMenPageseOrg=(SELECT TOP 1 KLASEPAGESE FROM FisMenPagese WHERE KOD=@FisMenPagese)
					SET @FISMENPAGESEFIC=(SELECT TOP 1 KODFIC FROM FisMenPagese WHERE KOD=@FisMenPagese)

					IF @FisMenPageseOrg='ARKE' AND @DEKLAROCASH='PO'
					SET @ARKA= (	SELECT COUNT('') FROM LOGARKA A INNER JOIN FISTCR B ON A.TCRCODE=B.KODTCR 
					WHERE B.KOD=@FisTcrCode AND A.DATEDOK=DBO.DATEVALUE(CONVERT(VARCHAR(50), GETDATE(), 104)) AND A.ERROR='0' )


					SET @kodTvsh=( SELECT COUNT('') FROM FJSCR 
					WHERE NRD=@pNrRendor AND NOT EXISTS (SELECT * FROM KlasaTatim B WHERE FJSCR.KODTVSH=B.KOD))

					IF @TIPFISKAL='FRE'
					SET @kodTvshTip=( SELECT COUNT('') FROM FJSCR A INNER JOIN KlasaTatim  B ON A.KODTVSH=B.KOD 
					WHERE A.NRD=@pNrRendor AND B.KODTVSHFIC NOT IN('TAX_FREE','TAX-FREE'))


					SET @perqTVSH= (SELECT COUNT('') FROM FJSCR WHERE PERQTVSH<>0 AND CMIMBS=0 AND NRD=@pNrRendor )
					SET @OkperqTVSH=CASE WHEN ISNULL(@perqTVSH,0)=0 THEN 1 ELSE 0 END 

					
					SELECT	@BUYERNAME			= CASE WHEN ISNULL(FJ.SHENIM1,'')<>'' THEN FJ.SHENIM1 ELSE KLIENT.PERSHKRIM END
							,@BuyerIDNum		= ISNULL(FJ.NIPT,'')
							,@BuyerIDType		= ISNULL(FJ.TIPNIPT,'')
							,@BuyerAddress		= CASE WHEN ISNULL(FJ.SHENIM2,'')<>'' THEN FJ.SHENIM2 ELSE KLIENT.ADRESA1 END
							,@BuyerTown		    = CASE WHEN ISNULL(FJ.RRETHI,'')<>'' THEN FJ.RRETHI ELSE KLIENT.ADRESA2 END
							,@BuyerCountry      = CASE WHEN ISNULL(VENDNDODHJE.KODCOUNTRY,'')<>'' 
																						THEN VENDNDODHJE.KODCOUNTRY ELSE KLIENT.ADRESA3 END 
					FROM FJ INNER JOIN KLIENT ON FJ.KODFKL=KLIENT.KOD
							LEFT JOIN VENDNDODHJE ON KLIENT.VENDNDODHJE=VENDNDODHJE.KOD
					WHERE FJ.NRRENDOR=@pNrRendor

					SET @OkBuTcrFJ=ISNULL((SELECT COUNT('') FROM FisBusUnit A INNER JOIN FisBusUnitScr B ON A.NRRENDOR=B.NRD
					WHERE KODAF=@FisTcrCode AND A.KOD=@FisBusUnit),0)
			
			IF @BUYERNAME=''
			   SET  @sMsg= @sMsg + 'Mungon Emri i Klientit';  
			IF @BuyerIDType='NUIS' AND @BuyerIDNum=''
			   SET  @sMsg= @sMsg + 'Mungon Nipti i Klientit ose Tip id nuk duhet NUIS';  
			IF @FisMenPageseOrg IN ('ELEKTRONIKE','OTHER') AND @TIPKLIENT='NUIS' AND ABS(@VlerTot)>=@KASEVL2FATTAT 
			   SET  @sMsg= @sMsg + 'Transaksion B2B, fature e Thjeshte. Fatura ka kaluar vleren limit:'+CONVERT(VARCHAR,@KASEVL2FATTAT) 
			   +' te lejuar. Vlera e fatures eshte: '+  CONVERT(VARCHAR,CONVERT(DECIMAL(20,2),ABS(@VlerTot)))+' Lek'+@FISMENPAGESEFIC;  
			
			IF @FisMenPageseOrg IN ('ELEKTRONIKE','OTHER') AND @TIPKLIENT='NUIS'AND @FISMENPAGESEFIC='ACCOUNT'
			   SET  @sMsg= @sMsg + 'Transaksion B2B, fature e Thjeshte. Kujdes menyren e pageses, nuk duhet te jete :'+@FISMENPAGESEFIC;  

			IF @BuyerAddress=''
			   SET  @sMsg= @sMsg + 'Mungon Adresa e Klientit';  
			IF @BuyerTown=''
			   SET  @sMsg= @sMsg + 'Mungon Qyteti i Klientit';   
			--IF @BuyerCountry=''
			--   SET  @sMsg= @sMsg + 'Mungon Shteti i Klientit'; 
			IF @BuyerIDType='' AND @BuyerIDNum<>''
			   SET	@sMsg= @sMsg + 'Mungon Tipi i Niptit per Klientin'; 

			IF @kodTvshTip=0 and isnull(@kodTvsh,0)=1 and @TIPFISKAL='FRE'
			   SET	@sMsg= @sMsg + 'Klasa e tvsh duhet te jete TAX_FREE'

			IF @NIPTFJ=@NIPT AND (@SELF IS NULL or @SELF='SEXP')
			SET	@sMsg= @sMsg + 'Kujdes!!!, nuk mund ti beni shitje brenda vendit ose eksport vetes tuaj.'
			--SELECT MsgError = @sMsg;
		
			IF ISNULL(@SELF,'')<>'SEXP' AND ( SELECT COUNT('') FROM FJSCR A INNER JOIN KlasaTatim B ON A.KODTVSH=B.KOD 
					WHERE A.NRD=@pNrRendor AND B.KODTVSHFIC='EXPORT_OF_GOODS')<>0
			SET	@sMsg= @sMsg + 'Kujdes!!!,Kontrolloni klasen e TVSH-se tek rreshtat e fatures ose klasen e TVSH se fatures. EXPORT_OF_GOODS' 

			--IF ISNULL(@SELF,'')='SEXP' AND ( SELECT COUNT('') FROM FJSCR A INNER JOIN KlasaTatim B ON A.KODTVSH=B.KOD 
			--		WHERE A.NRD=@pNrRendor AND B.KODTVSHFIC='EXPORT_OF_GOODS')=0
			--SET	@sMsg= @sMsg + 'Kujdes!!!,Kontrolloni klasen e TVSH-se tek rreshtat e fatures ose klasen e TVSH se fatures. EXPORT_OF_GOODS' 

			IF  ( SELECT COUNT('') FROM FJSCR WHERE VLTVSH=0 AND PERQTVSH<>0 AND NRD=@pNrRendor AND VLPATVSH<>0)<>0 AND ISNULL(@SELF,'')<>'SEXP' 
			SET	@sMsg= @sMsg + 'Kujdes!!!, Ka elemente ne fature ku Perqtvsh<>0 dhe VLTVSH=0 ' 
			
			IF  ( SELECT COUNT('') FROM FJSCR WHERE round(VLTVSH/VLPATVSH*100,0)<>PERQTVSH AND NRD=@pNrRendor AND VLPATVSH<>0)<>0 AND ISNULL(@SELF,'')<>'SEXP' 
			SET	@sMsg= @sMsg   + 'Kujdes!!!, Ka elemente ne fature ku Perqtvsh eshte ndryshe nga Vleratvsh/VlerapaTvsh' +char(13) +char(10) 

			IF  ( SELECT COUNT('') FROM FJSCR WHERE NRD=@pNrRendor and not exists (select * from KlasaTatim where KlasaTatim.PERQINDJE=fjscr.PERQTVSH))<>0
			SET	@sMsg= @sMsg   + 'Kujdes!!!, shkalle Tvsh e parregullt '+char(13) +char(10) 
		  
			IF @EINVOICE=1 AND @TIPPAGESE<>'BANKE' AND @TIPKLIENT='NUIS' AND @SELF IS NULL
			SET	@sMsg= @sMsg   + 'Kujdes!!!, Fatura e inicjuar si E-invoice. Nryshoni menyren e pageses ose krijoheni faturen nga e para! '+char(13) +char(10) 

			IF @StatusTcr=1 
			SET	@sMsg= @sMsg   + 'Kujdes!!!, Paisja fiskale '+ @FisTcrCode +' jo aktive '+char(13) +char(10) ;
			IF @StatusOper=1 
			SET	@sMsg= @sMsg   + 'Kujdes!!!, Operatori fiskal '+ @FisOperator +' jo aktiv '+char(13) +char(10); 
			IF @StatusBu=1 
			SET	@sMsg= @sMsg   + 'Kujdes!!!, Njesia e biznesit fiskal '+ @FisBusUnit +' jo aktiv '+char(13) +char(10);

		  
			--SELECT MsgError = @sMsg;

				  END;

				    IF @sTableName='FF'
			      BEGIN
			            IF @NrRendor<=0 OR (NOT EXISTS (SELECT * FROM FF WHERE NRRENDOR=@NrRendor))
                           BEGIN
                             SELECT MsgError = 'Dokumenti fature blerje e panjohur ..!';
                             RETURN;
                           END;

                    SELECT @FisBusUnit    = ISNULL(FisBusinessUnit,''),
                           @FisProces     = ISNULL(FisProces,''),
                           @FisTipDok     = ISNULL(FisTipDok,''),
                           @FisMenPagese  = ISNULL(FisMenPagese,''),
                           @Minutes       = DATEDIFF(MINUTE,DateCreate,GetDate()),
						   @FisTcrCode	  = ISNULL(Fistcr,''),
						   @FisOperator	  = ff.FISKODOPERATOR,
						   @StatusTcr	  = (select top 1 NOTACTIV from FisTCR where kod=FF.Fistcr),
						   @StatusOper	  = (select top 1 NOTACTIV from FisOperator where kod=FF.FISKODOPERATOR),
						   @StatusBu	  = (select top 1 NOTACTIV from FisBusUnit where kod=FF.FisBusinessUnit)
                      FROM FF 
                     WHERE NRRENDOR=@pNrRendor; 

					 SET @kodTvsh=( SELECT COUNT('') FROM FFSCR 
					WHERE NRD=@pNrRendor AND NOT EXISTS (SELECT * FROM KlasaTatim B WHERE FFSCR.KODTVSH=B.KOD))

					SELECT 
							 @BUYERNAME			= CASE WHEN ISNULL(FF.SHENIM1,'')<>'' THEN FF.SHENIM1 ELSE FURNITOR.PERSHKRIM END
							,@BuyerIDNum		= FF.NIPT
							,@BuyerIDType		= ISNULL(FF.TIPNIPT,'')
							,@BuyerAddress		= CASE WHEN ISNULL(FF.SHENIM2,'')<>'' THEN FF.SHENIM2 ELSE FURNITOR.ADRESA1 END
							,@BuyerTown		    = CASE WHEN ISNULL(FF.RRETHI,'')<>'' THEN FF.RRETHI ELSE FURNITOR.ADRESA2 END
							,@BuyerCountry      = CASE WHEN ISNULL(VENDNDODHJE.KODCOUNTRY,'')<>'' 
																						THEN VENDNDODHJE.KODCOUNTRY ELSE FURNITOR.ADRESA3 END 
					FROM FF INNER JOIN FURNITOR ON FF.KODFKL=FURNITOR.KOD
							LEFT JOIN VENDNDODHJE ON FURNITOR.VENDNDODHJE=VENDNDODHJE.KOD
					WHERE FF.NRRENDOR=@pNrRendor

					SET @OkBuTcrFF=ISNULL((SELECT COUNT('') FROM FisBusUnit A INNER JOIN FisBusUnitScr B ON A.NRRENDOR=B.NRD
					WHERE KODAF=@FisTcrCode AND A.KOD=@FisBusUnit),0)

					IF @BUYERNAME=''
					   SET  @sMsg= @sMsg + 'Mungon Emri i Furnitorit';  
					IF @BuyerIDNum=''
					   SET  @sMsg= @sMsg + 'Mungon kodi '+@BuyerIDType+' i Furnitorit ';  
					IF @BuyerAddress=''
					   SET  @sMsg= @sMsg + 'Mungon Adresa e Furnitorit ';  
					IF @BuyerTown=''
					   SET  @sMsg= @sMsg + 'Mungon Qyteti i Furnitorit ';   
					IF @BuyerCountry=''
					   SET  @sMsg= @sMsg + 'Mungon Shteti i Furnitorit '; 
		  			IF @BuyerIDType='' AND @BuyerIDNum<>''
					   SET	@sMsg= @sMsg + 'Mungon Tipi i Niptit per Furnitorin'; 
					IF  ( SELECT COUNT('') FROM FFSCR WHERE VLTVSH=0 AND PERQTVSH<>0 AND NRD=@pNrRendor)<>0
			         SET	@sMsg= @sMsg + 'Kujdes!!!, Ka elemente ne fature ku Perqtvsh<>0 dhe VLTVSH=0 ' 
					IF @StatusTcr=1 
					SET	@sMsg= @sMsg   + 'Kujdes!!!, Paisja fiskale '+ @FisTcrCode +' jo aktive '+char(13) +char(10) ;
					IF @StatusOper=1 
					SET	@sMsg= @sMsg   + 'Kujdes!!!, Operatori fiskal '+ @FisOperator +' jo aktiv '+char(13) +char(10); 
					IF @StatusBu=1 
					SET	@sMsg= @sMsg   + 'Kujdes!!!, Njesia e biznesit fiskal '+ @FisBusUnit +' jo aktiv '+char(13) +char(10);
					--SELECT MsgError = @sMsg;

				  END;
             

               IF @sTableName='SM'
			      BEGIN
			            IF @NrRendor<=0 OR (NOT EXISTS (SELECT * FROM SM WHERE NRRENDOR=@NrRendor))
                           BEGIN
                             SELECT MsgError = 'Dokumenti pike shitje i panjohur ..!';
                             RETURN;
                           END;

                    SELECT @FisBusUnit    = ISNULL(FisBusinessUnit,''),
                           @FisProces     = ISNULL(FisProces,''),
                           @FisTipDok     = ISNULL(FisTipDok,''),
                           @FisMenPagese  = ISNULL(FisMenPagese,''),
                           @Minutes       = DATEDIFF(MINUTE,DateCreate,GetDate()),
						   @FisTcrCode	  = ISNULL(Fistcr,''),
						   @FisOperator	  = SM.FISKODOPERATOR,
						   @StatusTcr	  = (select top 1 NOTACTIV from FisTCR where kod=SM.Fistcr),
						   @StatusOper	  = (select top 1 NOTACTIV from FisOperator where kod=SM.FISKODOPERATOR),
						   @StatusBu	  = (select top 1 NOTACTIV from FisBusUnit where kod=SM.FisBusinessUnit)
                      FROM SM 
                     WHERE NRRENDOR=@pNrRendor; 

					 SET @OkBuTcrSM=ISNULL((SELECT COUNT('') FROM FisBusUnit A INNER JOIN FisBusUnitScr B ON A.NRRENDOR=B.NRD
					WHERE KODAF=@FisTcrCode AND A.KOD=@FisBusUnit),0)

					IF @StatusTcr=1 
					SET	@sMsg= @sMsg   + 'Kujdes!!!, Paisja fiskale '+ @FisTcrCode +' jo aktive '+char(13) +char(10) ;
					IF @StatusOper=1 
					SET	@sMsg= @sMsg   + 'Kujdes!!!, Operatori fiskal '+ @FisOperator +' jo aktiv '+char(13) +char(10); 
					IF @StatusBu=1 
					SET	@sMsg= @sMsg   + 'Kujdes!!!, Njesia e biznesit fiskal '+ @FisBusUnit +' jo aktiv '+char(13) +char(10);

				  END;
	  	
			
			IF @NdermAdres=''
			   SET  @sMsg= @sMsg + 'Mungon Adresa e ndermarjes';  
			IF @NdermNipt=''
			   SET  @sMsg= @sMsg + 'Mungon Nipti i ndermarjes';  
			IF @NdermRreth=''
			   SET  @sMsg= @sMsg + 'Mungon Rrethi i ndermarjes';  
			IF @NdermShtet=''
			   SET  @sMsg= @sMsg + 'Mungon Shteti i ndermarjes';    
		  
	--	 SELECT MsgError = @sMsg;
           
--SELECT @sMsg
                  SET @Minutes       = ISNULL(@Minutes,0);
                  SET @FisBusUnit    = ISNULL(@FisBusUnit,'');
                  SET @FisProces     = ISNULL(@FisProces,'');
                  SET @FisTipDok     = ISNULL(@FisTipDok,'');
                  SET @FisMenPagese  = ISNULL(@FisMenPagese,'');     
                  --SET @sMsg          = '';    
                  SET @sMin          = CONVERT(Varchar(30),CAST(@Minutes AS BIGINT));
				  SET @FisTcrCode	 = ISNULL(@FISTCRCODE,'');
				  SET @FisOperator   = ISNULL(@FISOPERATOR,'');
	 			  
	-- PRINT @FisTcrCode
               SELECT @OkUnit		= CASE WHEN EXISTS (SELECT NRRENDOR FROM FISBUSUNIT    WHERE KOD=@FisBusUnit)   THEN 1 ELSE 0 END,
                      @OkProc		= CASE WHEN EXISTS (SELECT NRRENDOR FROM FISPROCES     WHERE KOD=@FisProces)    THEN 1 ELSE 0 END,
                      @OkTip		= CASE WHEN EXISTS (SELECT NRRENDOR FROM FISTIPDOKFT   WHERE KOD=@FisTipDok)    THEN 1 ELSE 0 END,
                      @OkPag		= CASE WHEN EXISTS (SELECT NRRENDOR FROM FISMENPAGESE  WHERE KOD=@FisMenPagese) THEN 1 ELSE 0 END,
					  @OkkodTVSH	= CASE WHEN isnull(@kodTvsh,0)=0 THEN 1 ELSE 0 END,
					  @OkTcrCode	= CASE WHEN EXISTS (SELECT NRRENDOR FROM FisTCR		   WHERE KOD=@FisTcrCode AND ISNULL(KODTCR,'')<>'')   THEN 1 ELSE 0 END,
					  @OkOperator	= CASE WHEN EXISTS (SELECT NRRENDOR FROM FisOperator   WHERE KOD=@FisOperator)   THEN 1 ELSE 0 END

                 --IF @Minutes>=60
                 --   SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Koha e e rregjistrimit te fatures me e madhe se 1 ore ['+@sMin+' min].'
                   IF @OkUnit = 0
                      SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Njesi biznesi panjohur ['+@FisBusUnit+'].';   
                   IF @OkProc = 0
                      SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Proces fiskalizim i pa njohur ['+@FisProces+'].';
                   IF @OkTip  = 0
                      SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Tip fiskalizim i panjohur ['+@FisTipDok+'].';     
                   IF @OkPag  = 0
                      SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Menyre pagese panjohur ['+@FisMenPagese+'].';   
				   IF @OkkodTVSH =0
					  SET @sMsg= @sMsg + CASE WHEN @kodTvsh<>'' THEN ' / ' ELSE '' END + 'Kod tvsh i panjohur .';
				   IF @OkTcrCode =0
					  SET @sMsg= @sMsg + CASE WHEN @FisTcrCode<>'' THEN ' / ' ELSE '' END + 'Kod TCR i panjohur .';
				   IF @OkOperator =0
					  SET @sMsg= @sMsg + CASE WHEN @FisOperator<>'' THEN ' / ' ELSE '' END + 'Kod Operatori i panjohur .';
				   --IF @OkperqTVSH =0
					  --SET @sMsg= @sMsg +'Relacion jo i sakte, nuk perputhet kodi i tvsh-se me vleren e tvsh-se';
				   IF @ARKA=0
					  SET @sMsg= @sMsg +'Beni ne fillim deklarimin e paisjes fiskale (CASH-in)';

				   IF (@OkBuTcrFJ=0 OR @OkBuTcrFF=0 OR @OkBuTcrSM=0 )
				      SET @sMsg= @sMsg + 'Kod i paisjes fiskale (TCR-se): '+@FisTcrCode+' nuk i perket njesise se biznesit(BU): '+@FisBusUnit;

	         END; 


            IF @sTableName='FD'
		     BEGIN

               IF @NrRendor<=0 OR (NOT EXISTS (SELECT * FROM FD WHERE NRRENDOR=@NrRendor)) -- Dok_JB=0 AND DST='?????'
                  BEGIN
                    SELECT MsgError = 'Dokumenti shoqerimit i panjohur ..!';
                    RETURN;
                  END;

				  DECLARE @FisTransport		AS VARCHAR(MAX),
						  @NrFiskal			AS INT,
						  @VehPlates		AS VARCHAR(50),
						  @VehOwnership		AS VARCHAR(50),
						  @STARTPOINT		AS VARCHAR(50),
						  @DESTINPOINT		AS VARCHAR(50),
						  @StartAddr		AS VARCHAR(MAX),
						  @StartCity		AS VARCHAR(MAX),
						  @DestinAddr		AS VARCHAR(MAX),
						  @DestinCity		AS VARCHAR(MAX),
						  @CarrierAddress	AS VARCHAR(MAX),
                          @CarrierIDNum		AS VARCHAR(MAX),
						  @IDType			AS VARCHAR(MAX),
                          @Carriername		AS VARCHAR(MAX),
                          @Carriertown		AS VARCHAR(MAX),
						  @KLADRESA1		AS VARCHAR(MAX),
						  @KLNIPT           AS VARCHAR(MAX),
						  @KLPERSHKRIM      AS VARCHAR(MAX),
					      @KLADRESA2        AS VARCHAR(MAX);

					SELECT  @FisBusUnit		= ISNULL(FisBusinessUnit,''),
							@FisProces		= ISNULL(FisProces,''),
							@FisTipDok		= ISNULL(FisTipDok,''),
							@FisTransport	= ISNULL(M.KOD,''),
							@Minutes		= DATEDIFF(MINUTE,A.DateCreate,GetDate()),
							@FisOperator	= A.FISKODOPERATOR,
							@NrFiskal		= A.NRFISKALIZIM,
							@VehPlates		= ISNULL(M.TARGE,''),
							@VehOwnership	= ISNULL(M.VehOwner,''),	
							@STARTPOINT		= ISNULL(M.STARTPOINT,''),
							@DESTINPOINT	= ISNULL(M.DESTINPOINT,''),	
							@StartAddr		= ISNULL(M.SHENIM1,''),
							@StartCity		= ISNULL(M.SHENIM3,''),
							@DestinAddr		= ISNULL(M.DESTINSHENIM1,''),
							@DestinCity		= ISNULL(M.DESTINSHENIM3,''),
							@CarrierAddress	= REPLACE(CarrierAdress, '"', ''),
							@CarrierIDNum	= ISNULL(CarrierIDNum,''),
							@IDType			= ISNULL(IDType,''),
							@Carriername	= ISNULL(Carriername,''),	
							@Carriertown	= ISNULL(Carriertown,''),
							@KLADRESA1		= ISNULL(KLADRESA1,''),
						    @KLNIPT			= ISNULL(KLNIPT,''),
						    @KLPERSHKRIM	= ISNULL(KLPERSHKRIM,''),
					        @KLADRESA2		= ISNULL(KLADRESA2,'') ,
						    @StatusOper	  = (select top 1 NOTACTIV from FisOperator where kod=A.FISKODOPERATOR),
						    @StatusBu	  = (select top 1 NOTACTIV from FisBusUnit where kod=A.FisBusinessUnit) 
                      FROM FD A LEFT JOIN MGSHOQERUES M ON A.NRRENDOR=M.NRD
                     WHERE A.NRRENDOR=@pNrRendor

				  IF @StatusOper=1 
				  SET	@sMsg= @sMsg   + 'Kujdes!!!, Operatori fiskal '+ @FisOperator +' jo aktiv '+char(13) +char(10); 
				  IF @StatusBu=1 
				  SET	@sMsg= @sMsg   + 'Kujdes!!!, Njesia e biznesit fiskal '+ @FisBusUnit +' jo aktiv '+char(13) +char(10);

			   
			      SET @Minutes       = ISNULL(@Minutes,0);
                  SET @FisBusUnit    = ISNULL(@FisBusUnit,'');
                  SET @FisProces     = ISNULL(@FisProces,'');
                  SET @FisTipDok     = ISNULL(@FisTipDok,'');
                  SET @FisTransport  = ISNULL(@FisTransport,'');     

                  SET @sMin          = CONVERT(Varchar(30),CAST(@Minutes AS BIGINT));
				  SET @FisTcrCode	 = ISNULL(@FISTCRCODE,'');
				  SET @FisOperator   = ISNULL(@FISOPERATOR,'');

		     SELECT @OkUnit		= CASE WHEN EXISTS (SELECT NRRENDOR FROM FISBUSUNIT    WHERE KOD=@FisBusUnit)   THEN 1 ELSE 0 END,
                    @OkOperator	= CASE WHEN EXISTS (SELECT NRRENDOR FROM FisOperator   WHERE KOD=@FisOperator)   THEN 1 ELSE 0 END
				   
                 --IF @Minutes>=60
                 --   SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Koha e e rregjistrimit te fatures me e madhe se 1 ore ['+@sMin+' min].'
                   IF @OkUnit = 0
                      SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Njesi biznesi panjohur ['+@FisBusUnit+'].';   
                   IF @FisProces = ''
                      SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Procedura WTN e pa njohur ['+@FisProces+'].';
                   IF @FisTipDok  = ''
                      SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Tip WTN i panjohur ['+@FisTipDok+'].';     
       --            IF @OkPag  = 0
       --               SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Menyre pagese panjohur ['+@FisMenPagese+'].';   
				   --IF @OkkodTVSH =0
					  --SET @sMsg= @sMsg + CASE WHEN @kodTvsh<>'' THEN ' / ' ELSE '' END + 'Kod tvsh i panjohur .';
				   -- IF @OkTcrCode =0
					  --SET @sMsg= @sMsg + CASE WHEN @FisTcrCode<>'' THEN ' / ' ELSE '' END + 'Kod TCR i panjohur .';
             IF @OkOperator =0
					  SET @sMsg= @sMsg + CASE WHEN @FisOperator<>'' THEN ' / ' ELSE '' END + 'Kod Operatori i panjohur .';
             IF @FisTransport=''
					  SET @sMsg= @sMsg + 'Mungon transportuesi';

IF ISNULL(@NrFiskal,0)=0
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Mungon nr i WTN-se';
IF ISNULL(@VehPlates,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Mungon Targa e mjetit';
IF ISNULL(@VehOwnership,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Pronesi mjeti i panjohur';
IF ISNULL(@STARTPOINT,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Mungon tipi i objektit te magazines burim';
IF ISNULL(@DESTINPOINT,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Mungon tipi i objektit te magazines destinacion';
IF ISNULL(@StartAddr,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Mungon adresa e magazines burim';
IF ISNULL(@StartCity,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Mungon qyteti i magazines burim';
IF ISNULL(@DestinAddr,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Mungon adresa e magazines destinacion';
IF ISNULL(@DestinCity,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Mungon qyteti i magazines destinacion';
IF ISNULL(@CarrierAddress,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Mungon adresa e transportuesit';
IF ISNULL(@CarrierIDNum,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Mungon ID/Nipt i transportuesit';
IF ISNULL(@IDType,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Mungon tipi i Id/Nipt tek transportuesi';
IF ISNULL(@Carriername,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Mungon emri i transportuesit';
IF ISNULL(@Carriertown,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Mungon qyteti i transportuesit';
IF @FisTipDok='TI' AND @FisProces NOT IN ('PROCESSING','REPAIR','EXAMINATION')
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Per faturen e transportit duhet nje nga keto procese : "PROCESSING","REPAIR","EXAMINATION" ';
IF @FisTipDok='TI' AND ISNULL(@KLADRESA1,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Per Faturen e transportit duhet Adresa e Klientit. Shiko tek elementet e transportit.';
IF @FisTipDok='TI' AND ISNULL(@KLNIPT,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Per Faturen e transportit duhet Nipti i Klientit. Shiko tek elementet e transportit.';
IF @FisTipDok='TI' AND ISNULL(@KLPERSHKRIM,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Per Faturen e transportit duhet Pershkrimi i Klientit. Shiko tek elementet e transportit.';
IF @FisTipDok='TI' AND ISNULL(@KLADRESA2,'')=''
SET @sMsg= @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Per Faturen e transportit duhet Qyteti i Klientit. Shiko tek elementet e transportit.';
	
			IF @NdermAdres=''
			   SET  @sMsg= @sMsg + 'Mungon Adresa e ndermarjes';  
			IF @NdermNipt=''
			   SET  @sMsg= @sMsg + 'Mungon Nipti i ndermarjes';  
			IF @NdermRreth=''
			   SET  @sMsg= @sMsg + 'Mungon Rrethi i ndermarjes';  
			IF @NdermShtet=''
			   SET  @sMsg= @sMsg + 'Mungon Shteti i ndermarjes';    
END;
               
 SELECT MsgError = @sMsg;
    

GO

DECLARE @NR INT,
		@NR1 INT,
		@NR2 INT

SET @NR=(SELECT COUNT('') FROM FISCONFIG WHERE FUSHA='DATESP')

IF @NR=0
INSERT INTO FISCONFIG (FUSHA,VLERA)
SELECT 'DATESP',+'ENTERPRISE NEW V.22.11.01/'+CONVERT(VARCHAR(25),GETDATE(),25)
ELSE
UPDATE FisConfig SET VLERA='ENTERPRISE NEW V.22.11.01/'+CONVERT(VARCHAR(25),GETDATE(),25) WHERE FUSHA='DATESP'

SET @NR1=(SELECT COUNT('') FROM FISCONFIG WHERE FUSHA='NDRYSHONRDSHOQ')
SET @NR2=(SELECT COUNT('') FROM FISCONFIG WHERE FUSHA='DEKLAROCASH')
IF @NR1=0
INSERT INTO FISCONFIG (FUSHA,VLERA)
SELECT 'NDRYSHONRDSHOQ','JO'

IF @NR2=0
INSERT INTO FISCONFIG (FUSHA,VLERA)
SELECT 'DEKLAROCASH','PO'

GO

SET NOEXEC OFF
GO










