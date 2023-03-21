SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[__FiscalCreateSalesXmlPOS99]
	 @NrRendor		INT
   , @BusinessUnit	VARCHAR(50)
   , @OperatorCode	VARCHAR(50)
   , @CashRegister	VARCHAR(50)
   , @Fiscalize		BIT			= 1
   , @QrCodeLink	VARCHAR(1000) OUTPUT 
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
			,@SignedXml			VARCHAR(MAX);		

	SET @UniqueIdentif = NEWID();
	
	UPDATE FJ SET FISCUUID = @UniqueIdentif
	WHERE NRRENDOR = @NrRendor;

	SELECT TOP 1 @NIPT					= ISNULL(NIPT, '')						-- CONFND:	 NIPT i kompanise
				,@SoftNum				= ISNULL(FiscSoftNum, '')				-- CONFIGMG: SoftNum -- kodi i zgjidhjes software te merret ne nje tabele konfigurimi
				,@Schema				= ISNULL(FiscSchema, '')				-- CONFIGMG: fiscSchema ka te beje me skemen e perdorur per krijimin e xml e cila eshte fikse, por mund te ndryshoje ne vijim
				,@FiscUrL				= ISNULL(FiscUrL, '')					-- CONFIGMG: url per web service
				,@CertificatePath       = ISNULL(FiscCertificatePath, '')		-- CONFIGMG: PATH ne te cilin ndohet certifikata ne server
				,@CertificatePwd	    = ISNULL(FiscCertificatePassword, '')	-- CONFIGMG: Fjalekalim per hapjen e certifikates
	FROM CONFIGMG 
	CROSS JOIN CONFND;

	SELECT @DATE		= dbo.DATE_1601(DATECREATE),		--> kujdes data duhet edhe me pjesen e ORE-s
		   @Nr			= CONVERT(VARCHAR(10), CONVERT(BIGINT, NRDOK)),
		   @VlerTot		= CONVERT(VARCHAR(20), (CONVERT(DECIMAL(18, 2), VLERTOT))),
		   @PerqZbr		= ISNULL(PERQZBR, 0),
		   @IicBlank	= (SELECT TOP 1 NIPT FROM CONFND) 
							+ '|' + dbo.DATE_1601(DATECREATE) 
							+ '|' + CONVERT(VARCHAR(MAX), CONVERT(BIGINT, NRDOK))
							+ '|' + @BusinessUnit 
							+ '|' + @CashRegister 
							+ '|' + @SoftNum 
							+ '|' + CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(10,2), VLERTOT))
	FROM SM
	WHERE NRRENDOR = @NrRendor;
	 
	EXEC _FiscalGenerateHash @IicBlank, @CertificatePath, @CertificatePwd, @IIC OUTPUT, @IICSIGNATURE OUTPUT, @ERROR OUTPUT, @ERRORtext OUTPUT;

	SELECT KARTLLG,
		   PERSHKRIM,
		   NJESI,
		   SASI,
		   CMIMBS,
		   CMIMBSTVSH = VLERABS / CASE WHEN SASI = 0 THEN 1 ELSE SASI END,
		   S.PERQTVSH,
		   S.VLPATVSH,
		   S.VLTVSH,
		   VLERABS,
		   CASE WHEN APLTVSH = 1 THEN 'true' ELSE 'false' END AS APLTVSH,
		   CASE WHEN APLINVESTIM = 1 THEN 'true' ELSE 'false' END AS APLINVESTIM
	INTO #FJSCR 
	FROM FJ F
	INNER JOIN FJSCR S ON F.NRRENDOR = S.NRD
	WHERE NRD = @NrRendor;

	SET @XML  = (
		SELECT 
				@DATE AS 'Header/@SendDateTime',  -- MANDATORY: 
				NULL  AS 'Header/@SubseqDelivType',	-- MANDATORY:  Duhet shtuar ne fature [NOINTERNET, BOUNDBOOK, SERVICE, TECHNICALERROR]
																			   -- NOINTERNET When TCR operates in the area where there is no Internet available. 
																			   -- BOUNDBOOK When TCR is not working and message cannot be created with TCR. 
																			   -- SERVICE When there is an issue with the fiscalization service that blocks fiscalization. 
																			   -- TECHNICALERROR When there is a temporary technical error at TCR side that prevents successful fiscalization
				--DUHET SHTUAR SUBSEQUENTDELIVERYTYPE
				NEWID() AS 'Header/@UUID',			 -- MANDATORY: Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
		(
			SELECT 
					CASE WHEN MODPG = 'CA' THEN 'CASH' ELSE 'NONCASH' END AS '@TypeOfInv' -- MANDATORY: 
					,NULL AS '@TypeOfSelfIss'									-- OPTIONAL:  [AGREEMENT - The previous agreement between the parties., DOMESTIC - Purchase from domestic farmers., ABROAD - Purchase of services from abroad., SELF - Self-consumption., OTHER - Other] 
				   ,'false' AS '@IsSimplifiedInv'							-- MANDATORY: 
				   ,dbo.DATE_1601(S.DATECREATE) AS '@IssueDateTime'			-- MANDATORY: 
				   ,@Nr + '/' + CONVERT(VARCHAR(4), YEAR(S.DATECREATE)) + CASE WHEN MODPG = 'CA' THEN + '/' + @CashRegister ELSE '' END AS '@InvNum'	-- MANDATORY: NQS CASH PERNDRYSHE BEJE BOSH @CashRegister -- > NrRendor vjetor qe fillon nga 1 ne fillim vit
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
				   ,'true'			AS '@IsIssuerInVAT'						-- MANDATORY: 
																			/*
																				Possible values:
																					1. Taxpayer is registered for VAT – 1
																					2. TAXPAYER is not registered for VAT – 2
																			*/
				   ,'0.00'			AS '@TaxFreeAmt'						-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged
				   ,NULL			AS '@MarkUpAmt'							-- OPTIONAL: Amount related to special procedure for margin scheme
				   ,NULL			AS '@GoodsExAmt'						-- OPTIONAL: Amount of goods for export from the Republic of Albania. 
				   ,CONVERT(DECIMAL(18, 2), VLPATVSH)	AS '@TotPriceWoVAT'	-- MANDATORY: Total price of the invoice excluding VAT.
				   ,CONVERT(DECIMAL(18, 2), VLTVSH)		AS '@TotVATAmt'		-- MANDATORY: Total VAT amount of the invoice. 
				   ,CONVERT(DECIMAL(18, 2), VLERTOT)	AS '@TotPrice'		-- MANDATORY: Total price of all items including taxes and discounts.
				   ,@OperatorCode	AS '@OperatorCode'						-- MANDATORY: Reference to the operator code, who is operating on TCR and issues invoices.
				   ,@BusinessUnit	AS '@BusinUnitCode'						-- MANDATORY: Business unit (premise) code. Duhet shtuar tek magazina, apo duhet shtuar ne fature? faturat vetem sherbim?				   
				   ,@SoftNum		AS '@SoftCode'							-- MANDATORY: Software code.
				   ,NULL			AS '@ImpCustDecNum'						-- OPTIONAL: Import customs declaration number. Only for internal usage. Must not be populated by a TCR.
				   ,@Iic			AS '@IIC'								-- MANDATORY: Duhet shtuar ne fature, Nr unik i cili behet me concat
				   ,@IicSignature	AS '@IICSignature'						-- MANDATORY: Shenjimi i iic
				   ,'false'			AS '@IsReverseCharge'					-- MANDATORY: If true, the buyer is obliged to pay the VAT.	
				   ,NULL			AS '@PayDeadline'						-- OPTIONAL:  Last day for payment.		--> MANDATORY IF NON CASH
				   ,
					CASE WHEN EXISTS(SELECT 1 FROM FJSCR WHERE 1 = 2) THEN
					(
						SELECT NULL AS 'CorrectiveInv/@IICRef',				-- IIC reference on the original invoice.
							 	NULL AS 'CorrectiveInv/@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.
								NULL AS 'CorrectiveInv/@Type'				-- Type of the corrective invoice.
						FOR XML PATH (''), TYPE
					) ELSE NULL END AS CorrectiveInv						-- XML element groups data for an original invoice that will be corrected with current invoice.
				   ,
				   CASE WHEN EXISTS(SELECT 1 FROM FJSCR WHERE 1 = 2) THEN	-- OPTIONAL: 
					(
						SELECT NULL AS 'BadDebtInv/@IICRef',				--IIC reference on the original invoice.
								NULL AS 'BadDebtInv/@IssueDateTime'			--Date and time the original invoice is created and issued at TCR.
						FOR XML PATH (''), TYPE
					 ) 	ELSE NULL END AS BadDebtInv							--XML element groups data for an original invoice that will be declared bad debt invoice, as uncollectible.				   
				   , CASE WHEN EXISTS(SELECT 1 FROM FJSCR WHERE 1 = 2) THEN	-- MANDATORY case of Summary invoice:
					(														--XML element that contains one IIC reference, e.g. reference of the invoice that is part of the summary invoice.
						SELECT NULL AS 'SumInvIICRef/@IIC',					--IIC of the invoice that is referenced in the summary invoice.
							   NULL AS 'SumInvIICRef/@IssueDateTime'		--Date and time the invoice referenced by the summary invoice is created and issued at TCR.
						WHERE 1=2
						FOR XML PATH (''), TYPE	
					 ) ELSE NULL END AS SumInvIICRefs						--XML element that contains list of IIC-s to which this invoice referred to, e.g. if this is a summary invoice it 
																			--shall contain a reference to each individual invoice issued and fiscalized before and included in this summary invoice.
				   ,														-- OPTIONAL:  
					(
						SELECT	NULL AS 'SupplyDateOrPeriod/@Start',		--Start day of the supply.
								NULL AS 'SupplyDateOrPeriod/@End'			--End day of the supply.
						WHERE 1 = 2
						FOR XML PATH (''), TYPE	
					  )	SupplyDateOrPeriod									--XML element representing supply date or period of supply, if it is different from the date when the invoice was issued.
					,
					(														-- MANDATORY: 

						-- SELECT * FROM CONFIG..TIPDOK WHERE TIPDOK = 'S'
						SELECT CONVERT(DECIMAL(18, 2), S.VLERTOT) AS 'PayMethod/@Amt',
							   CASE WHEN MODPG = 'CA' THEN 'BANKNOTE'
									WHEN MODPG = 'VO' THEN 'ACCOUNT'
									WHEN MODPG = 'TT' THEN 'OTHER'
									ELSE 'ACCOUNT' 
									END AS 'PayMethod/@Type',			-- Type of the payment method.
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
								KURS2 AS 'Currency/@ExRate',				--Exchange rate applied to calculate the equivalent amount of foreign currency for the total amount expressed in ALL. Exchange rate express equivalent amount of ALL for 1 unit of foreign currency.
								'FALSE' AS 'Currency/@IsBuying'				--True if exchange transaction is buying of the foreign currency. False if exchange transaction is selling of the foreign currency.
						WHERE KMON NOT IN ('', 'ALL')						
						FOR XML PATH (''), TYPE	
					  )														--XML element representing currency in which the amount on the invoice should be paid, if different from ALL
				   ,(	--nga config -- SELECT * FROM CONFND
						SELECT PERSHKRIM AS 'Seller/@Name',					-- MANDATORY: 
							   NIPT		 AS 'Seller/@IDNum',				-- MANDATORY:	
							   'NUIS'    AS 'Seller/@IDType',				 -- MANDATORY:	FIX
							   'Rruga Mustafa Matohiti'AS 'Seller/@Address', -- MANDATORY FOR FOREIGNER:	FUSHA PER ADRESEN
							   'Tirane'	 AS 'Seller/@Town',					 -- MANDATORY FOR FOREIGNER:    QYTETI
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
								'NUIS'						 AS 'Buyer/@IDType',	-- OPTIONAL| MANDATORY B2B: 
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
								CONVERT(DECIMAL(18, 2), VLPATVSH) AS 'I/@PA',		-- MANDATORY: Total price of goods after the tax and applying discounts Negative values allowed when CorrectiveInv or BadDebtInv exist.
								CONVERT(DECIMAL(18, 2), VLPATVSH) AS 'I/@PB',		-- MANDATORY: Total price of goods and services before the tax Negative values allowed when CorrectiveInv or BadDebtInv exist.
								CONVERT(DECIMAL(18, 2), SASI) AS 'I/@Q',			-- MANDATORY: Amount or number (quantity) of items. Negative values allowed when CorrectiveInv or BadDebtInv exist.
								CONVERT(DECIMAL(18, 2), 0) AS 'I/@R',				-- OPTIONAL:  Percentage of the rebate.	
								'true' AS 'I/@RR',									-- OPTIONAL:  Is rebate reducing tax base amount?
								NJESI AS 'I/@U',									-- MANDATORY: What is the item’s unit of measure (piece, weight measure, length measure, etc.)
								CONVERT(DECIMAL(18, 2), CMIMBS) AS 'I/@UPB',		-- MANDATORY: Unit price before Value added tax is applied
								CONVERT(DECIMAL(18, 2), CMIMBS) AS 'I/@UPA',		-- MANDATORY: Unit price after Value added tax is applied								
								
								-- nuk duhet APLTVSH
								CASE WHEN VLTVSH = 0 AND APLTVSH = 'false' THEN 'TYPE_1' ELSE NULL END AS 'I/@EX',			-- OPTIONAL: 
																																-- Exempt from VAT.
																																-- TYPE_1 Exempt type 1. Exempted on the basis of Article 51 of the VAT law 
																																-- TYPE_2 Exempt type 2. Exempted on the basis of Articles 53 and 54 of the VAT law 
																																-- TAX_FREE Tax free amount. Sales without VAT that is exempted based on VAT law other then articles 51, 53 and 54 of VAT law, and is not margin scheme nor export of goods 
																																-- MARGIN_SCHEME Margin scheme (Travel agents VAT scheme, second hand goods VAT scheme, works of art VAT scheme, collectors’ items and antiques VAT scheme etc.). 
																																-- EXPORT_OF_GOODS Export of goods. No VAT.
																					

								APLINVESTIM AS 'I/@IN',								-- If true, the item is investment for the buyer. Mandatory only for importation of goods.
								CONVERT(DECIMAL(18, 2), VLTVSH)  AS 'I/@VA',		-- MANDATORY: Amount of value added tax for goods and services. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true. Negative values allowed when CorrectiveInv or BadDebtInv exist.
								CONVERT(DECIMAL(18, 2), PERQTVSH) AS 'I/@VR',		-- MANDATORY: Rate of value added tax. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true.
								
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
						FOR XML PATH (''), TYPE
					) Items
					,																-- MANDATORY IF ISSUER IN VAT:
					(	SELECT  CONVERT(VARCHAR(10), CONVERT(DECIMAL(18, 0), COUNT(1)))	  AS 'SameTax/@NumOfItems',
								CONVERT(DECIMAL(18, 2), SUM(VLPATVSH))					  AS 'SameTax/@PriceBefVAT',
								CONVERT(DECIMAL(18, 2), PERQTVSH)					   	  AS 'SameTax/@VATRate',
								--APLTVSH													  AS 'SameTax/@ExemptFromVAT',		-- nuk duhet APLTVSH
																										-- Exempt from VAT.
																											-- TYPE_1 Exempt type 1. Exempted on the basis of Article 51 of the VAT law 
																											-- TYPE_2 Exempt type 2. Exempted on the basis of Articles 53 and 54 of the VAT law 
								CONVERT(DECIMAL(18, 2), SUM(VLTVSH))					  AS 'SameTax/@VATAmt'
						FROM #FJSCR
						GROUP BY PERQTVSH, APLTVSH
						FOR XML PATH (''), TYPE
					) SameTaxes,
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
						SELECT  NULL	 AS 'Fee/@Type',						-- Type of the fee.
																					-- PACK Packaging fee 
																					-- BOTTLE Fee for the return of glass bottles 
																					-- COMMISSION Commission for currency exchange activities 
																					-- OTHER Other fees that are not listed here.
								VLPATVSH AS 'Fee/@Amt'							-- Amount of the fee.
						FROM #FJSCR C 
						WHERE 1 = 2 -- NQS NUK KA REKORDE HIQET VETE SI TAG
						FOR XML PATH (''), TYPE
					) Fees														-- XML element representing list of fees.
		FROM FJ  S
		WHERE S.NRRENDOR = @NrRendor
		FOR XML PATH('Invoice'), TYPE
	)
	FOR XML PATH('RegisterInvoiceRequest'));
    
	--Gjenerimi i url per kontrollin e fiskalizimit te fatures
	SET @QrCodeLink = 'https://efiskalizimi-app-test.tatime.gov.al/invoice-check/#/verify?' 
					+ 'iic='	+ @Iic
					+ '&tin='	+ @NIPT
					+ '&crtd='	+ @Date
					+ '&ord='   + @Nr
					+ '&bu='    + @BusinessUnit				
					+ '&cr='    + @CashRegister
					+ '&sw='    + @SoftNum
					+ '&prc='   + @VlerTot;  
		
	SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterInvoiceRequest>','<RegisterInvoiceRequest xmlns="' + @Schema +'" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3">') AS XML)

	SELECT @XmlString = CAST(@XML AS VARCHAR(MAX))  

	IF(@Fiscalize != 0)	
	BEGIN
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
				@Errortext			 = @Errortext	OUTPUT;

		END TRY
		BEGIN CATCH
		END CATCH
	
		UPDATE FJ SET FISCFIC			= CASE WHEN @Error = '0' THEN @Fic ELSE '' END,
					  FISCLASTERROR		= @Error,
					  FISCLASTERRORTEXT	= @Errortext,
					  FISCQRCODELINK	= @QrCodeLink
					  --FISKALIZUAR		= 'SUKSES'
		WHERE NRRENDOR = @NrRendor;
	END
END;


	-- NUIS ID type				      Invoice.TypeOfSelfIss exists and Inovice.Buyer.IDType is not NUIS. Invoice.TypeOfSelfIss does not exists and Inovice.Seller.IDType is not NUIS.	--> 54
	-- Taxpayer does not exist        Taxpayer does not exist in RTP. 52 Taxpayer status invalid Taxpayer is not active in the RTP. 55 Issuer VAT status invalid Invoice.IsIssuerInVAT  --> 44 
	--							      status is different from the real issuer VAT status.																								
	
	-- Invoice VAT status invalid     Invoice.IsIssuerInVAT is false and Invoice.TotVATAmt attribute exist.																				--> 11
	--								  Invoice.IsIssuerInVAT is false and Invoice.SameTaxes element exist. 
	--								  Invoice.IsReverseCharge is true and Invoice.TotVATAmt attribute does not exist. 
	--								  Invoice.IsReverseCharge is true and Invoice.SameTaxes element does not exist. 
	--Cash invoice limit			  Invoice.TypeOfInv is CASH, Invoice Buyer IDType is NUIS, Invoice Seller IDType is NUIS and Invoice.TotPrice is more than allowed amount.			--> 40 

	-- Issue datetime invalid		  Invoice.IssueDateTime is in the future.																											--> 11
	--								  Invoice.IssueDateTime is not equal to the Header.SendDateTime and Header.SubseqDelivType does not exist.	
	--								  Invoice.IssueDateTime more than 2 days in the past from now and Header.SubseqDelivType equals to SERVICE or TECHNICALERROR. 
	--								  Invoice.IssueDateTime more than 11 days in the past from now and Header.SubseqDelivType equals BOUNDBOOK. 
	--								  Invoice.IssueDateTime is not in the current or previous month or is in the previous month but the send date is not less or equal to 10th 
	--								  of the current month and Header.SubseqDelivType equals NOINTERNET. 

	-- Negative values invalid		  Invoice.CorrectiveInv or Invoice.BadDebtInv does not exist and negative values found in following fields:
	--										 Invoice.TaxFreeAmt	
	--										 Invoice.MarkUpAmt 
	--										 Invoice.GoodsExAmt 
	--										 Invoice.TotPriceWoVAT 
	--										 Invoice.TotVATAmt 
	--										 Invoice.TotPrice 
	--										Invoice.SameTaxs.SameTax.VATAmt 
	--										 Invoice.ConsTaxes.ConsTax.ConsTaxAmt 
	--										 Fees.Fee.Amt 
	
	-- TCRCode invalid				  Invoice.TCRCode does not exist and Invoice.TypeOfInv equals to CASH. 
	
	-- Supply date or period invalid Invoice.SupplyDateOrPeriod.Start date is before Invoice.SupplyDateOrPeriod.End date. 
	--							 	 Invoice.SupplyDateOrPeriod.Start month is different from Invoice.SupplyDateOrPeriod.End month. 
	
	-- Payment method invalid		 Invoice.PayMethods.PayMethod.Type is COMPANY and Invoice.PayMethods.PayMethod.CompCard does not exist. 
	--								 Invoice.PayMethods.PayMethod.Type is SVOUCHER and Invoice.PayMethods.PayMethod.Vouchers does not exist Sum of values of Invoice.
	--								 PayMethods.PayMethod.Amt is not equal to Invoice.TotPrice value. 
	
	--Seller fields missing			Seller.IDType is NUIS or ID and Seller.Address, Seller.Town and Seller.Country does not exist. 

	--Buyer fields missing			Invoice.Buyer does not exist and Invoice.TypeOfSelfIss exists or Invoice.GoodsExAmt exists or Invoice.IsReverseCharge equals true. 
	--								Invoice.Buyer.IDType and Invoice.Buyer.IDNum does not exist and Invoice.TypeOfSelfIss exists or Invoice.GoodsExAmt exists or Invoice.IsReverseCharge equals true. 
	--								Invoice.Buyer.IDType and Invoice.Buyer.IDNum exists and Invoice.Buyer.Name, Invoice.Buyer.Address, Invoice.Buyer.Town and Invoice.Buyer.Country does not exist.
GO
