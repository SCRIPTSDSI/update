SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--select * from sm order by nrrendor desc
--SELECT * FROM SM ORDER BY NRRENDOR DESC
--exec [_EINVOICESM] 1771324

CREATE PROC [dbo].[_EINVOICESMBAK]
	 @NrRendor		INT
   
AS
BEGIN	


		DECLARE  @NIPT				VARCHAR(20)
				,@PerqZbr			FLOAT
				,@Date				DATETIME
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
				,@SignedXml			VARCHAR(MAX)
				,@Error				varchar(max)
				,@ErrorText			varchar(max)
				,@XmlStringTemp		NVARCHAR(MAX)

				
			   --,@NrRendor				INT			
			   ,@BusinessUnit			VARCHAR(50)				-- element ne fature
			   ,@OperatorCode			VARCHAR(50)				-- element ne fature
			   ,@CashRegister			VARCHAR(50)
			   ,@UUID					UNIQUEIDENTIFIER	
		
		SET @SignedXml = '';
		



		SELECT TOP 1 @BusinessUnit = K.FISCBUSUNITCODE,@OperatorCode = U.OPERATORCODE,@Fic=S.fic 
		FROM KASE K
		INNER JOIN DRH..USERS U ON U.DRN = K.KOD
		INNER JOIN SMBAK S ON S.KASE = K.KOD
		WHERE S.NRRENDOR = @NrRendor

		
		SELECT TOP 1 @NIPT				= (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCVATREGISTRATIONNO')					-- CONFND:	 NIPT i kompanise
				,@SoftNum				= (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCSOFTNUM')			-- CONFIGMG: SoftNum -- kodi i zgjidhjes software te merret ne nje tabele konfigurimi
				,@Schema				= (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCSCHEMA')				-- CONFIGMG: fiscSchema ka te beje me skemen e perdorur per krijimin e xml e cila eshte fikse, por mund te ndryshoje ne vijim
				,@FiscUrL				= (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCURL')					-- CONFIGMG: url per web service
				,@CertificatePath       = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'CERTPATH')		-- CONFIGMG: PATH ne te cilin ndohet certifikata ne server
				,@CertificatePwd	    = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'CERTPASS')-- CONFIGMG: Fjalekalim per hapjen e certifikates
				,@Certificate			= FiscCertificate						-- CONFIGMG: Binary per certifikaten
		FROM confnd 

		


		SELECT @DATE		= TIMED,		--> kujdes data duhet edhe me pjesen e ORE-s
			   @Nr			= CONVERT(VARCHAR(10), CONVERT(BIGINT, NRDOK)),
			   @VlerTot		= CONVERT(VARCHAR(20), (CONVERT(DECIMAL(18, 2), VLERTOT))),
			   @PerqZbr		= ISNULL(PERQZBR, 0),
			   @IicBlank	= (SELECT TOP 1 NIPT FROM CONFND) 
							+ '|' + dbo.DATE_1601(TIMED) 
							+ '|' + CONVERT(VARCHAR(MAX), CONVERT(BIGINT, NRDOK))
							+ '|' + @BusinessUnit 
							+ '|' + @CashRegister 
							+ '|' + @SoftNum 
							+ '|' + CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(10,2), VLERTOT)),
		       @iic= IIC,
			   @fic=FIC ,
			   @IicSignature=iicsig,
			   @UUID = UUID
		FROM SMBAK
		WHERE NRRENDOR = @NrRendor;

	

		IF OBJECT_ID('tempdb..#SM') IS NOT NULL 
		DROP TABLE #SM;
	
		SELECT TOP 1 * INTO #SM 
		FROM SMBAK 
		WHERE NRRENDOR=@NrRendor;

		UPDATE #SM SET KMON = CASE WHEN KMON = '' THEN 'ALL' ELSE KMON END;
	
	DECLARE @XML XML;

	 --SELECT TIMED,TIMED ,* FROM SM ORDER BY NRRENDOR DESC
	;WITH XMLNAMESPACES ('cbc' AS cbc, 'cac' AS cac)
	SELECT @XML = (
	SELECT TOP 1 
		'UBLExtensions' AS 'A',
		'urn:cen.eu:en16931:2017' AS 'cbc:CustomizationID',
		isnull(proces,'P1') AS 'cbc:ProfileID',
		CONVERT(VARCHAR(10), CONVERT(BIGINT, NRDOK)) + '/' + CONVERT(VARCHAR(4), YEAR(S.TIMED)) + CASE WHEN MODPG = 'CA' THEN + '/' + ISNULL(@CashRegister, 'ABCDEF') ELSE '' END AS 'cbc:ID',
		REPLACE(CONVERT(VARCHAR, S.TIMED, 111), '/', '-') AS 'cbc:IssueDate',		
		REPLACE(CONVERT(VARCHAR, DATEDOK + ISNULL(DTAF, 0), 111), '/', '-')  AS 'cbc:DueDate',
		isnull(fisctipdok,'380') AS 'cbc:InvoiceTypeCode',
		/*
			82 – Faturë për shërbimet e matura
			325 – Parafatura
			326 – Faturë e pjesshme
			380 – Faturë tregtare
			381 - Miratim
			383 - Debit
			384 – Faturë korrigjuese
			386 – Faturë pagese paraprake
			394 – Faturë Lizingu
		*/
		(	
			SELECT * FROM 
			(
				SELECT 'IIC=' + ISNULL(@Iic, '') +'#AAI#' AS 'cbc:Note' 
				UNION ALL
				SELECT	'IICSignature=' + ISNULL(@IicSignature, '')+'#AAI#' AS 'cbc:Note'
				UNION ALL
				SELECT	'FIC=' +ISNULL(@Fic, '')+'#AAI#' AS 'cbc:Note' --> DUHET FISCFIC
				UNION ALL
				SELECT	'IssueDateTime=' + ISNULL(dbo.DATE_1601(TIMED), '') +'#AAI#'  AS 'cbc:Note'
				UNION ALL
				SELECT	'OperatorCode='+ ISNULL(@OperatorCode, '')+'#AAI#' AS 'cbc:Note' --> duhet kodi i operatorit
				UNION ALL
				SELECT	'BusinessUnitCode='+ ISNULL(@BusinessUnit, '')+'#AAI#' AS 'cbc:Note'
				UNION ALL
				SELECT	'SoftwareCode='+ ISNULL(@SoftNum, '')+'#AAI#' AS 'cbc:Note'
				UNION ALL
				SELECT	'IsBadDebtInv=false#AAI#' AS 'cbc:Note'
				UNION ALL
				SELECT	KMON  +'#AAI#' AS 'cbc:Note'
				UNION ALL
				SELECT @SoftNum +'#AAI#' AS 'cbc:Note'
			) A
			FOR XML PATH(''), TYPE
		),
		
		KMON AS 'cbc:DocumentCurrencyCode',
		KMON AS 'cbc:TaxCurrencyCode',

		(
			SELECT TOP 1  
							'9923'              AS 'cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID',
							NIPT		        AS 'cac:AccountingSupplierParty/cac:Party/cbc:EndpointID',
							'9923:'+NIPT		AS 'cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID',
							PERSHKRIM	        AS 'cac:AccountingSupplierParty/cac:Party/cac:PartyName/cbc:Name',
							SHENIM1  AS 'cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName',
							SHENIM2		    AS 'cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName',
							'AL'			    AS 'cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode',
						--  'RRUGA SALES'		AS 'cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName',
						--	'ALB'			    AS 'cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity',
							'AL'+NIPT		    AS 'cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID',
							'VAT'		        AS 'cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID',
							PERSHKRIM	        AS 'cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName',
							NIPT		        AS 'cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID'
			FROM CONFND
			FOR XML PATH(''), TYPE
		),
		(
			SELECT TOP 1	'9923'				AS 'cac:AccountingCustomerParty/cac:Party/cbc:EndpointID/@schemeID',
							isnull(s.nipt,KLIENT.NIPT)		    AS 'cac:AccountingCustomerParty/cac:Party/cbc:EndpointID',
							'9923:'+isnull(s.nipt,KLIENT.NIPT)	AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID',
							isnull(s.shenim1,KLIENT.PERSHKRIM)	AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name',
							isnull(s.shenim2,KLIENT.ADRESA1)		AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName',
							V.PERSHKRIM		    AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName',
							'AL'			    AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode',
						--	KLIENT.ADRESA2	    AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName',
						--	'ALB'				AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity',
							'AL'+isnull(s.nipt,KLIENT.NIPT)   AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID',
							'VAT'		        AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID',
							isnull(s.shenim1,KLIENT.PERSHKRIM)	AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName',
							isnull(s.nipt,KLIENT.NIPT)		    AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID'

			FROM KLIENT
			LEFT JOIN VENDNDODHJE V ON KLIENT.VENDNDODHJE = V.KOD
			WHERE KLIENT.KOD = S.KODFKL
			FOR XML PATH(''), TYPE
		),
		--CASE WHEN ISNULL(MODPG, '') = 'CA' THEN '10'
		--	 WHEN ISNULL(MODPG, '') IN ('', 'VO') THEN '20'
		--	 ELSE NULL END AS 'cac:PaymentMeans/cbc:PaymentMeansCode',
			isnull(fiscmenpag,'380') AS 'cac:PaymentMeans/cbc:PaymentMeansCode',
		/*
			10 – Para në dorë
			30 – Transfertë kreditesh
			48 – Kartë banke
			49 – Kartë debiti
		*/
		--SELECT TOP 10 * FROM SM ORDER BY NRRENDOR DESC

		CASE WHEN ISNULL(MODPG,'') = 'CA' THEN 'BANKNOTE'
			WHEN ISNULL(MODPG,'') = 'VO' THEN 'ACCOUNT'
			WHEN ISNULL(MODPG,'') = 'TT' THEN 'OTHER'
			ELSE 'ACCOUNT' 
			END AS 'cac:PaymentMeans/cbc:InstructionNote',
		CASE WHEN MODPG = 'VO' THEN 'AL25566565656' ELSE NULL END AS 'cac:PaymentMeans/cac:PaymentID',
		/*(
			SELECT TOP 1 REPLACE(CONVERT(VARCHAR, DATEDOK, 111), '/', '-') AS 'cac:InvoicePeriod/cbc:StartDate',
						 REPLACE(CONVERT(VARCHAR, DATEDOK + ISNULL(DTAF, 0), 111), '/', '-') AS 'cac:InvoicePeriod/cbc:EndDate'
			FROM #FJ 			
			FOR XML PATH(''), TYPE
		),
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
		(SELECT   
		            KMON AS 'cbc:TaxAmount/@currencyID'
				  , CONVERT(DECIMAL(20, 2), SUM(convert(decimal(20,2),SMBAKSCR.VLPATVSH))) -  CONVERT(DECIMAL(20, 2), SUM(convert(decimal(20,2),SMBAKSCR.VLPATVSH/(cONVERT(FLOAT,(PERQTVSH+100)/100))))) AS 'cbc:TaxAmount'
				  
			FROM SMBAKSCR 
			WHERE NRD = S.NRRENDOR 
			FOR XML PATH(''), TYPE
		)  AS 'cac:TaxTotal',

	
		(SELECT   
		         --   KMON AS 'cbc:TaxAmount/@currencyID'
				--  , CONVERT(DECIMAL(20, 2), (SELECT SUM(FJSCR.VLTVSH) FROM FJSCR WHERE NRD=S.NRRENDOR )) AS 'cbc:TaxAmount'
				 -- , 
				  KMON AS 'cac:TaxSubtotal/cbc:TaxableAmount/@currencyID'
				  , CONVERT(DECIMAL(20, 2), SUM(convert(decimal(20,2),SMBAKSCR.VLPATVSH/(cONVERT(FLOAT,(KT.PERQTVSH+100)/100))))) AS 'cac:TaxSubtotal/cbc:TaxableAmount'
				  , KMON AS 'cac:TaxSubtotal/cbc:TaxAmount/@currencyID'
				 -- , CONVERT(DECIMAL(20, 2), SUM(convert(decimal(20,2),SMBAKSCR.VLPATVSH - SMBAKSCR.VLPATVSH/(cONVERT(FLOAT,(KT.PERQTVSH+100)/100))))) AS 'cac:TaxSubtotal/cbc:TaxAmount'
                                    ,CONVERT(DECIMAL(20, 2), SUM(convert(decimal(20,2),SMBAKSCR.VLPATVSH))) -  CONVERT(DECIMAL(20, 2), SUM(convert(decimal(20,2),SMBAKSCR.VLPATVSH/(cONVERT(FLOAT,(KT.PERQTVSH+100)/100)))))  AS 'cac:TaxSubtotal/cbc:TaxAmount'
				  , KT.KODTVSHEIC AS 'cac:TaxSubtotal/cac:TaxCategory/cbc:ID' 
                  , CONVERT(DECIMAL(20, 2), KT.PERQTVSH) AS 'cac:TaxSubtotal/cac:TaxCategory/cbc:Percent'
				  --, CASE WHEN  KT.PERQTVSH>=0 THEN NULL ELSE 'AAM' END AS 'cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReasonCode'
				  --, CASE WHEN  KT.PERQTVSH>=0 THEN NULL ELSE 'Arsyeja per tvsh 0' END AS 'cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReason'
				  , CASE WHEN  KT.PERQTVSH=0 and ISNULL(KT.KODTVSHEIC,'')<>'Z' THEN 'VATEX-EU-O' ELSE NULL END AS 'cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReasonCode'
				  , CASE WHEN  KT.PERQTVSH=0 and ISNULL(KT.KODTVSHEIC,'')<>'Z' THEN 'Not subject to VAT' ELSE NULL END AS 'cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReason'
						  
				  , 'VAT' AS 'cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:ID'
			FROM SMBAKSCR 
			INNER JOIN ARTIKUJ A ON A.KOD = SMBAKSCR.KARTLLG
			INNER JOIN KLASATVSH KT ON KT.KOD = A.KODTVSH
			WHERE NRD = S.NRRENDOR 
			GROUP BY KT.PERQTVSH,KT.KODTVSHEIC
			ORDER BY KT.PERQTVSH DESC
			FOR XML PATH(''), TYPE
		)  AS 'cac:TaxTotal',


		--SELECT   CONVERT(DECIMAL(20, 2), SUM(SMSCR.VLPATVSH - SMSCR.VLPATVSH/(cONVERT(FLOAT,(PERQTVSH+100)/100)))) FROM SMSCR WHERE NRD=2350699
		--SELECT TOP 10 * FROM SM ORDER BY NRRENDOR DESC
		--TOTALS
		KMON AS 'cac:LegalMonetaryTotal/cbc:LineExtensionAmount/@currencyID',
		CONVERT(DECIMAL(20, 2), (SELECT SUM(CONVERT(DECIMAL(20, 2),SMBAKSCR.VLPATVSH/(cONVERT(FLOAT,(PERQTVSH+100)/100)))) FROM SMBAKSCR WHERE SMBAKSCR.NRD = S.NRRENDOR)) AS 'cac:LegalMonetaryTotal/cbc:LineExtensionAmount', -- Totali i të gjitha shumave neto për artikujt në një Faturë
		KMON AS 'cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount/@currencyID',		
		CONVERT(DECIMAL(20, 2), (SELECT SUM(CONVERT(DECIMAL(20, 2),SMBAKSCR.VLPATVSH/(cONVERT(FLOAT,(PERQTVSH+100)/100)))) FROM SMBAKSCR WHERE SMBAKSCR.NRD = S.NRRENDOR)) AS 'cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount',  -- Shuma totale e faturës pa TVSH
		KMON AS 'cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount/@currencyID',		
		CONVERT(DECIMAL(20, 2), S.VLERTOT) AS 'cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount',   -- Shuma totale e faturës me TVSH
		KMON AS 'cac:LegalMonetaryTotal/cbc:PrepaidAmount/@currencyID',
		CONVERT(DECIMAL(20, 2), 0) AS 'cac:LegalMonetaryTotal/cbc:PrepaidAmount',				 -- Totali i shumave të parapaguara.
		KMON AS 'cac:LegalMonetaryTotal/cbc:PayableRoundingAmount/@currencyID',
		CONVERT(DECIMAL(20, 2), 0) AS 'cac:LegalMonetaryTotal/cbc:PayableRoundingAmount',		 -- Shuma e cila duhet të shtohet në total për të rrumbullakosur shumën e pagesës.
		KMON AS 'cac:LegalMonetaryTotal/cbc:PayableAmount/@currencyID',
		CONVERT(DECIMAL(20, 2), S.VLERTOT) AS 'cac:LegalMonetaryTotal/cbc:PayableAmount',				 -- Mbetja e shumës së pagesës
		
		(SELECT   KARTLLG AS 'cac:InvoiceLine/cbc:ID',
				  'H87'AS 'cac:InvoiceLine/cbc:InvoicedQuantity/@unitCode',
				  CONVERT(DECIMAL(20, 2), SASI) AS 'cac:InvoiceLine/cbc:InvoicedQuantity',
				  KMON AS 'cac:InvoiceLine/cbc:LineExtensionAmount/@currencyID',
				  CONVERT(DECIMAL(20, 2), (SMBAKSCR.VLPATVSH/(cONVERT(FLOAT,(KT.PERQTVSH+100)/100)))) AS 'cac:InvoiceLine/cbc:LineExtensionAmount',
				  SMBAKSCR.PERSHKRIM AS 'cac:InvoiceLine/cac:Item/cbc:Name',
				  KT.KODTVSHEIC AS 'cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory/cbc:ID',
				  CONVERT(DECIMAL(20, 2), KT.PERQTVSH) AS 'cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent',
				 'VAT' AS 'cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory/cac:TaxScheme/cbc:ID',
				  KMON AS 'cac:InvoiceLine/cac:Price/cbc:PriceAmount/@currencyID',
				  CONVERT(DECIMAL(20, 2),  (SMBAKSCR.VLPATVSH/(cONVERT(FLOAT,(KT.PERQTVSH+100)/100)))/SASI) AS'cac:InvoiceLine/cac:Price/cbc:PriceAmount',		 
				  CONVERT(DECIMAL(20, 2), 1) AS 'cac:InvoiceLine/cac:Price/cbc:BaseQuantity'				 
			FROM SMBAKSCR
			INNER JOIN ARTIKUJ A ON A.KOD = SMBAKSCR.KARTLLG
			INNER JOIN KLASATVSH KT ON KT.KOD = A.KODTVSH

			WHERE NRD = S.NRRENDOR
		
			FOR XML PATH(''), TYPE
		)   	
	FROM #SM S 
	FOR XML PATH('Invoice') )

	SELECT @XmlString = REPLACE(CAST(@XML AS VARCHAR(MAX)), ' xmlns:cac="cac" xmlns:cbc="cbc"', '')
	
	SELECT @XmlString = REPLACE(@XmlString, '<Invoice>', '<Invoice xmlns:csc="urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2"
											 xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
											 xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
											 xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
											 xmlns:sac="urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2"
											 xmlns:sbc="urn:oasis:names:specification:ubl:schema:xsd:SignatureBasicComponents-2"
											 xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">');

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

	--SELECT CAST(@XmlStringTemp AS XML) AS 'PARA'
	
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
	
	SET @XML = CAST(@XmlString AS XML);
	 
	--SELECT @XML AS 'PAS'

	
	--SET @XmlString = (SELECT CAST(@XmlString AS VARBINARY(MAX)) FOR XML PATH(''), BINARY BASE64)
	EXEC _Base64Encode @XmlString, @XmlString OUT;
	
	DECLARE @SENDDATETIME VARCHAR(100)

	SET @SENDDATETIME		= dbo.DATE_1601(getdate())

	SET @XML  = (
		SELECT 
				--@DATE AS 'Header/@SendDateTime',  -- MANDATORY: 
				CASE WHEN abs(DATEDIFF(minute,getdate(),@DATE))>60 THEN @SENDDATETIME ELSE dbo.DATE_1601(@DATE) END AS 'Header/@SendDateTime',  -- MANDATORY: 
				@UUID AS 'Header/@UUID',			 -- MANDATORY: Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
		(
			SELECT @XmlString AS 'EinvoiceEnvelope/UblInvoice'									-- OPTIONAL:  [AGREEMENT - The previous agreement between the parties., DOMESTIC - Purchase from domestic farmers., ABROAD - Purchase of services from abroad., SELF - Self-consumption., OTHER - Other] 
			FOR XML PATH (''), TYPE
		)
	FOR XML PATH('RegisterEinvoiceRequest'));	

	SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterEinvoiceRequest>','<RegisterEinvoiceRequest xmlns="https://Einvoice.tatime.gov.al/EinvoiceService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="1">') AS XML)
	--SELECT @XML;
	SET @XmlString = CAST(@XML AS NVARCHAR(MAX));

	DECLARE @responseXML AS XML

	EXEC _FiscalProcessRequest 
			@InputString		 = @XmlString,
			@CertificatePath	 = @CertificatePath, 
			@Certificatepassword = @CertificatePwd,
			@CertBinary			 = @Certificate,
			@Url				 = 'https://einvoice.tatime.gov.al/EinvoiceService-v1/EinvoiceService.wsdl',
			@Schema				 = @Schema,
			@ReturnValue		 = '',
			@USESYSTEMPROXY      ='',
			@SignedXml			 = @SignedXml	OUTPUT, 
			@Fic				 = @Fic			OUTPUT, 
			@Error				 = @Error		OUTPUT, 
			@Errortext			 = @Errortext	OUTPUT,
			@responseXML		 = @responseXML	OUTPUT	

declare @hDoc int;
set @hDoc = 1
 
 SET @XML = CAST(@SignedXml  AS XML)
 SELECT @Fic, @Error, @ErrorText,@XmlString, @SignedXml,  @XML;
 declare @eic as varchar(max)
 IF (@Error = 0)
		 BEGIN
			EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="https://Einvoice.tatime.gov.al/EinvoiceService/schema" />';
			--SELECT @responseXML
			SELECT @EIC = EIC
			FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:RegisterEinvoiceResponse')
			WITH
			(
				EIC [varchar] (50) 'ns2:EIC'
			);
			EXEC sp_xml_removedocument @hDoc;
			UPDATE smBAK SET eic = @EIC
						  , RESPONSEXMLEIC	= convert(varchar(max),@responseXml)
			WHERE NRRENDOR = @NrRendor;
		 END
else
begin
		declare @gabim as varchar(max)
		set @gabim = 'Fatura nuk u dergua dot ne E-Fatura!' + @Errortext
	    RAISERROR (@gabim, -- Message text.  
               16, -- Severity.  
               1 -- State.  
               );  
end

 END;


 
/****** Object:  StoredProcedure [dbo].[_EINVOICESMbak]    Script Date: 19/04/2022 10:59:37 AM ******/
SET ANSI_NULLS ON
GO
