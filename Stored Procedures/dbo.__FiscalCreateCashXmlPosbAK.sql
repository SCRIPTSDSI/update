SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[__FiscalCreateCashXmlPosbAK]
	@NrRendor		INT 
   , @Operation		VARCHAR(50) -- BALANCE, CREDIT, DEPOSIT
   , @CashAmount	FLOAT
   , @TCRNumber		VARCHAR(50)
   , @Xml			XML			  OUTPUT
   , @Error			VARCHAR(1000) OUTPUT 
   , @ErrorText		VARCHAR(1000) OUTPUT 
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
			,@IicBlank			VARCHAR(MAX)
			,@Iic				VARCHAR(1000)
			,@Fic				VARCHAR(MAX)
			,@IicSignature		VARCHAR(1000)
			,@Schema			VARCHAR(1000)
			,@FiscUrL			VARCHAR(1000)
			,@UniqueIdentif		UNIQUEIDENTIFIER
			,@XmlString			VARCHAR(MAX)
			,@SignedXml			VARCHAR(MAX)		
			,@useSystemProxy VARCHAR(10)
	SET @UniqueIdentif = NEWID();
	
	UPDATE ARKA SET FISCUUID = @UniqueIdentif
	WHERE NRRENDOR = @NrRendor;

	SELECT TOP 1 @NIPT					= ISNULL(NIPT, '')						-- CONFND:	 NIPT i kompanise
				,@SoftNum				= ISNULL(FiscSoftNum, '')				-- CONFIGMG: SoftNum -- kodi i zgjidhjes software te merret ne nje tabele konfigurimi
				,@Schema				= ISNULL(FiscSchema, '')				-- CONFIGMG: fiscSchema ka te beje me skemen e perdorur per krijimin e xml e cila eshte fikse, por mund te ndryshoje ne vijim
				,@FiscUrL				= ISNULL(FiscUrL, '')					-- CONFIGMG: url per web service
				,@CertificatePath       = ISNULL(FiscCertificatePath, '')		-- CONFIGMG: PATH ne te cilin ndohet certifikata ne server
				,@CertificatePwd	    = ISNULL(FiscCertificatePassword, '')	-- CONFIGMG: Fjalekalim per hapjen e certifikates
	FROM CONFIGMG 
	CROSS JOIN CONFND;

	SET @XML  = (
	SELECT 
			dbo.DATE_1601(GETDATE()) AS 'Header/@SendDateTime',
			'false'					 AS 'Header/@IsSubseqDeliv',
			NEWID()				     AS 'Header/@UUID',							--Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
	(
		SELECT dbo.DATE_1601(GETDATE())					AS '@ChangeDateTime'
			   , @NIPT									AS '@IssuerNUIS'		--Duhet shtuar ne magazina/fature
			   , @Operation								AS '@Operation'	
			   , CONVERT(DECIMAL(18, 2), @CashAmount)	AS '@CashAmt'
			   , @TCRNumber								AS '@TCRCode'
		FOR XML PATH('CashDeposit'), TYPE
	)
	FOR XML PATH('RegisterCashDepositRequest'));

	SET @XML = CAST( REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterCashDepositRequest>','<RegisterCashDepositRequest xmlns="'+ @Schema +'" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3"> ') AS XML);

	SET @XMLSTRING = CAST(@xml AS VARCHAR(MAX));

	BEGIN TRY
			EXEC _FiscalProcessRequest 
				@InputString		 = @XmlString,
				@CertificatePath	 = @CertificatePath, 
				@Certificatepassword = @CertificatePwd, 
				@Url				 = @FiscUrL,
				@Schema				 = @Schema,
				@ReturnValue		 = 'FIC',
				@SignedXml			 = @SignedXml	OUTPUT, 
				@Fic				 = @Fic			OUTPUT, 
				@Error				 = @Error		OUTPUT, 
				@Errortext			 = @Errortext	OUTPUT,
				@useSystemProxy         =''
		END TRY
		BEGIN CATCH
		END CATCH
	
		UPDATE ARKA SET FISCLASTERROR		= @Error,
					    FISCLASTERRORTEXT	= @Errortext
					  --FISKALIZUAR		= 'SUKSES'
		WHERE NRRENDOR = @NrRendor;
END

GO
