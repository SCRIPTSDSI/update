SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[__FiscalCreateTcrXml]
	@KOD	VARCHAR(50)
AS
BEGIN
	DECLARE  @NIPT				VARCHAR(50)
			,@SoftNum			VARCHAR(50)
			,@ManufacNum		VARCHAR(50)
			,@Xml				XML
			,@XmlString			VARCHAR(MAX)
			,@Fic				VARCHAR(1000)
			,@SignedXml			VARCHAR(MAX)
			,@Error				VARCHAR(1000)
			,@Errortext			VARCHAR(1000)
			,@Schema			VARCHAR(MAX)
			,@Url				VARCHAR(MAX)
			,@CertificatePath   VARCHAR(MAX)
			,@CertificatePwd	VARCHAR(MAX);
																				-- Mbushja e parametrave
	SELECT TOP 1 @NIPT					= ISNULL(NIPT, '')						-- CONFND:	 NIPT i kompanise
				,@SoftNum				= ISNULL(FiscSoftNum, '')				-- CONFIGMG: SoftNum -- kodi i zgjidhjes software te merret ne nje tabele konfigurimi
				,@ManufacNum			= ISNULL(FiscManufacNum, '')			-- CONFIGMG: SoftNum -- kodi i mirembajtjes software te merret ne nje tabele konfigurimi
				,@Schema				= ISNULL(FiscSchema, '')				-- CONFIGMG: fiscSchema ka te beje me skemen e perdorur per krijimin e xml e cila eshte fikse, por mund te ndryshoje ne vijim
				,@Url					= ISNULL(FiscUrl, '')					-- CONFIGMG: URL ku dergohen request per fiskalizimin 
				,@CertificatePath       = ISNULL(FiscCertificatePath, '')		-- CONFIGMG: PATH ne te cilin ndohet certifikata ne server
				,@CertificatePwd	    = ISNULL(FiscCertificatePassword, '')	-- CONFIGMG: Fjalekalim per hapjen e certifikates
	FROM CONFIGMG 
	CROSS JOIN CONFND
	CROSS JOIN KASE 
	WHERE KASE.KOD = @KOD;

	SET @Xml  = (
	SELECT 
			dbo.DATE_1601(GETDATE()) AS 'Header/@SendDateTime',
			NEWID() AS 'Header/@UUID',										--Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
	(
		SELECT  @NIPT					AS '@IssuerNUIS'
			   ,ISNULL(FiscBusUnitCode, '')			AS '@BusinUnitCode'		--KASA:	 BusinesUnitCode - kodi i njesise se sherbimit per kete pike qe po krijohet
			   ,KOD									AS '@TCRIntID'			--Counter per TCR
			   ,@SoftNum							AS '@SoftCode'
			   ,'xi177lb183'							AS '@MaintainerCode'
			   ,LEFT(dbo.DATE_1601(GETDATE()), 10)	AS '@ValidFrom'
			   ,'REGULAR'							AS '@Type'
		FROM KASE U WHERE KOD = @KOD
		FOR XML PATH('TCR'), TYPE
	)
	FOR XML PATH('RegisterTCRRequest'));

	SET @Xml = CAST(REPLACE(CAST(@Xml AS NVARCHAR(MAX)),'<RegisterTCRRequest>','<RegisterTCRRequest xmlns="'+ @Schema +'" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3">') AS XML);
	SET @XmlString = CAST(@Xml AS NVARCHAR(MAX));		-->  konverto xml ne string

	declare @fisccert as varbinary(max)
	

	select top 1 @fisccert = fisccertificate from CONFND

	DECLARE @responseXML AS XML

	EXEC _FiscalProcessRequest 
		@XmlString,								
		@CertificatePath		= @CertificatePath,														
		@CertificatePassword	= @CertificatePwd,	
		@certbinary				= @fisccert,
		@Url					= @Url,
		@Schema					= @Schema,
		@ReturnValue			= 'TCRCode',					--> VLERA QE KERKON TE MARRESH NGA DERGIMI I KERKESES
		@SignedXml				= @SignedXml OUTPUT,			--> XML E PERGATITUR BASHKE ME SHENJIMIN 
		@Fic					= @Fic		 OUTPUT,			--> FIC PER VLEREN E FATURES, NR I SHENJIMIT
		@Error					= @Error	 OUTPUT,			--> 0 -> SKA GABIM 1-> KA GABIM
		@ErrorText				= @ErrorText OUTPUT,			--> MESAZHI I GABIMIT
		@responseXML			= @responseXML	OUTPUT,
		@useSystemProxy		 = ''

		
		IF @ERROR='0'
		BEGIN
			UPDATE KASE SET FiscTcrNum = @FIC WHERE KOD = @KOD;
		END;

        SELECT @Fic AS [ReturnValue], @Error AS [Error], @ErrorText AS [ErrorText], @SignedXml AS [SignedXml], @Xml AS [XML];
END;
GO
