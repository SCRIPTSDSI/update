SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--SELECT * FROM FJ

--__FiscalCreateSalesXmlFJ2 147218
CREATE PROC [dbo].[__FiscalCreateSalesXmlFJ2]
	 @NrRendor		INT,
	 @OUTPUT1 VARCHAR(MAX) OUTPUT
   
AS
BEGIN


--SELECT FISQRCODELINK,* FROM FJ WHERE NRRENDOR=147164
IF EXISTS(SELECT 1 FROM FJ WHERE NRRENDOR = @NrRendor 
						   AND FISLASTERRORFIC = '0'
						   AND (ISNULL(FISFIC, '') != '' AND  ISNULL(FISRELATEDFIC,'')!=ISNULL(FISFIC, '') ) )
BEGIN
	SET @OUTPUT1='0'
END
ELSE
BEGIN

begin try
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
						,@TIPFISKAL		VARCHAR(50)

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

					
				DECLARE @FISMENPAGESE AS VARCHAR(50);
				DECLARE @KLASEPAGESE AS VARCHAR(50);
				DECLARE @KURSFAT AS VARCHAR(50);
				DECLARE @SELF AS VARCHAR(50);
				DECLARE @IsEinvoice AS BIT;

	

				SET @CashRegister = (SELECT TOP 1 KODTCR FROM FJ A INNER JOIN FisTCR B ON A.FISTCR=B.KOD WHERE A.NRRENDOR=@NrRendor)
				SET @OperatorCode = (SELECT TOP 1 KODFISCAL FROM FJ A INNER JOIN FisOperator B ON A.FISKODOPERATOR=B.KOD WHERE A.NRRENDOR=@NrRendor)
				SET @BusinessUnit = (SELECT TOP 1 FISBUSINESSUNIT FROM FJ A  WHERE A.NRRENDOR=@NrRendor)
				SET @FISMENPAGESE = (SELECT TOP 1 KODFIC FROM FJ A INNER JOIN [dbo].[FisMenPagese] B ON A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@NrRendor)
				SET @KLASEPAGESE = CASE WHEN (SELECT TOP 1 KLASEPAGESE FROM FJ A INNER JOIN [dbo].[FisMenPagese] B ON A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@NrRendor)='ARKE' THEN 'CASH' ELSE 'NONCASH' END;
				SET @KURSFAT = (SELECT TOP 1 KURS2 FROM FJ A  WHERE A.NRRENDOR=@NrRendor)
				DECLARE @TIPPAGESE VARCHAR(MAX)
				SET @TIPPAGESE=(SELECT top 1 KLASEPAGESE FROM FJ A INNER JOIN FisMenPagese B ON  A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@NrRendor)

				IF @TIPPAGESE='BANKE'
				SET @IsEinvoice='true'
				ELSE 
				SET @IsEinvoice='false'



				SET @SELF=(	SELECT CASE WHEN FJ.NIPT=@VatRegistrationNo THEN  'SELF' ELSE NULL END FROM FJ 
							WHERE NRRENDOR=@NrRendor)

				SET NOCOUNT ON;
			

				SET @UniqueIdentif = NEWID();

				UPDATE FJ SET FISUUID = @UniqueIdentif
				WHERE NRRENDOR = @NrRendor;

				SELECT 
		   
					   @DATECREATE	= DATECREATE,
					   @DATE		= dbo.DATE_1601(DATECREATE),		--> kujdes data duhet edhe me pjesen e ORE-s
					   @Nr			= CONVERT(VARCHAR(10), CONVERT(BIGINT, NRDSHOQ)),
					   @VlerTot		= CONVERT(VARCHAR(20), (CONVERT(DECIMAL(18, 2), ROUND(VLERTOT,2)))),
					   @PerqZbr		= ISNULL(PERQZBR, 0),
					   @IicBlank	= (SELECT TOP 1 NIPT FROM CONFND) 
										+ '|' + dbo.DATE_1601(DATECREATE) 
										+ '|' + CONVERT(VARCHAR(MAX), CONVERT(BIGINT, NRDSHOQ))
										+ '|' + @BusinessUnit 
										+ '|' + @CashRegister 
										+ '|' + @SoftNum 
										+ '|' + CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(18,2), ROUND(VLERTOT,2)))
				FROM FJ
				WHERE NRRENDOR = @NrRendor;

				--PRINT @IICBLANK
				EXEC _FiscalGenerateHash @IicBlank, @CertificatePath, @CertificatePwd, @Certificate, @IIC OUTPUT, @IICSIGNATURE OUTPUT, @ERROR OUTPUT, @ERRORtext OUTPUT;

				SELECT KARTLLG,
					   PERSHKRIM,
					   NJESI=CASE WHEN ISNULL(NJESI,'')='' THEN 'Cope' else NJESI END,
					   SASI,
					   CMIMBS=ROUND(CMIMBS,2),
					   CMIMBSTVSH = ROUND((VLERABS / CASE WHEN SASI = 0 THEN 1 ELSE SASI END),2),
					   PERQTVSH=ROUND(S.PERQTVSH,2),
					   VLPATVSH=ROUND(S.VLPATVSH,2),
					   VLTVSH=ROUND(S.VLTVSH,2),
					   VLERABS=ROUND(VLERABS,2),
					   CASE WHEN APLTVSH = 1 THEN 'true' ELSE 'false' END AS APLTVSH,
					   CASE WHEN APLINVESTIM = 1 THEN 'true' ELSE 'false' END AS APLINVESTIM
		  
				INTO #FJSCR 
				FROM FJ F
				INNER JOIN FJSCR S ON F.NRRENDOR = S.NRD
				WHERE NRD = @NrRendor;
			

				DECLARE @SENDDATETIME AS VARCHAR(100);


		IF OBJECT_ID('tempdb..#fj') IS NOT NULL 
		DROP TABLE #FJ;

		SELECT TOP 1 * INTO #FJ 
		FROM FJ 
		WHERE NRRENDOR=@NrRendor;

		UPDATE #FJ SET	VLTVSH	=	(SELECT ROUND(SUM(VLTVSH),2) FROM #FJSCR),
						VLPATVSH=	(SELECT ROUND(SUM(VLPATVSH),2) FROM #FJSCR),
						VLERTOT	=	(SELECT ROUND(SUM(VLERABS),2) FROM #FJSCR)
						
	
	
				SET @SENDDATETIME		= dbo.DATE_1601(getdate())
				--select DATEDIFF(minute,@DATE,getdate()),@SENDDATETIME

				SET @XML  = (
					SELECT 
							CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 THEN @SENDDATETIME ELSE dbo.DATE_1601(@DATECREATE) END AS 'Header/@SendDateTime',  -- MANDATORY: 
							CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 then 'NOINTERNET' else null end  AS 'Header/@SubseqDelivType',	-- MANDATORY:  Duhet shtuar ne fature [NOINTERNET, BOUNDBOOK, SERVICE, TECHNICALERROR]
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
								,@SELF AS '@TypeOfSelfIss'    -- OPTIONAL:  [AGREEMENT - The previous agreement between the parties., DOMESTIC - Purchase from domestic farmers., ABROAD - Purchase of services from abroad., SELF - Self-consumption., OTHER - Other] 
							   --,'false' AS '@IsSimplifiedInv'							-- MANDATORY:
							   ,CASE WHEN @TIPFISKAL='VAT' THEN 'false' else 'true' end AS '@IsSimplifiedInv'
							   ,dbo.DATE_1601(S.DATECREATE) AS '@IssueDateTime'			-- MANDATORY: 
							   ,@Nr + '/' + CONVERT(VARCHAR(4), YEAR(S.DATECREATE)) + CASE WHEN @KLASEPAGESE = 'CASH' THEN + '/' + @CashRegister ELSE '' END AS '@InvNum'	-- MANDATORY: NQS CASH PERNDRYSHE BEJE BOSH @CashRegister -- > NrRendor vjetor qe fillon nga 1 ne fillim vit
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
							   ,CASE WHEN @TIPFISKAL='VAT' THEN CONVERT(DECIMAL(20, 2), 0) else CONVERT(DECIMAL(20, 2), S.VLERTOT) end			AS '@TaxFreeAmt'						-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged
							   ,NULL			AS '@MarkUpAmt'							-- OPTIONAL: Amount related to special procedure for margin scheme
							   ,NULL			AS '@GoodsExAmt'						-- OPTIONAL: Amount of goods for export from the Republic of Albania. 
							   ,CONVERT(DECIMAL(18, 2), ROUND(VLPATVSH*S.KURS2,2))	AS '@TotPriceWoVAT'	-- MANDATORY: Total price of the invoice excluding VAT.
							   --,CONVERT(DECIMAL(18, 2), VLERTOT)	AS '@TotPriceWoVAT'
							   ,CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2))		AS '@TotVATAmt'		-- MANDATORY: Total VAT amount of the invoice. 
							   --,CONVERT(DECIMAL(18, 2), 0) AS '@TotVATAmt'
							   ,CONVERT(DECIMAL(18, 2), ROUND(VLERTOT*S.KURS2,2))	AS '@TotPrice'		-- MANDATORY: Total price of all items including taxes and discounts.
							   ,@OperatorCode	AS '@OperatorCode'						-- MANDATORY: Reference to the operator code, who is operating on TCR and issues invoices.
							   ,@BusinessUnit	AS '@BusinUnitCode'						-- MANDATORY: Business unit (premise) code. Duhet shtuar tek magazina, apo duhet shtuar ne fature? faturat vetem sherbim?				   
							   ,@SoftNum		AS '@SoftCode'							-- MANDATORY: Software code.
							   ,NULL			AS '@ImpCustDecNum'						-- OPTIONAL: Import customs declaration number. Only for internal usage. Must not be populated by a TCR.
							   ,@Iic			AS '@IIC'								-- MANDATORY: Duhet shtuar ne fature, Nr unik i cili behet me concat
							   ,@IicSignature	AS '@IICSignature'						-- MANDATORY: Shenjimi i iic
							   ,'false'			AS '@IsReverseCharge'					-- MANDATORY: If true, the buyer is obliged to pay the VAT.	
							   ,NULL			AS '@PayDeadline'						-- OPTIONAL:  Last day for payment.		--> MANDATORY IF NON CASH
							   ,@IsEinvoice		AS '@IsEinvoice'
							   ,
								CASE WHEN EXISTS(SELECT 1 FROM FJ FREF WHERE ISNULL(FREF.FISIIC,'') = ISNULL(S.FISRELATEDFIC,'')) THEN
								(
									SELECT  ISNULL(FREF.FISIIC,'') AS '@IICRef',				-- IIC reference on the original invoice.
							 				ISNULL(DBO.DATE_1601(FREF.FISRELATEDATE),DBO.DATE_1601(FREF.DATECREATE)) AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.
											CASE WHEN ISNULL(FREF.LLOJDOK,'') IN ('','01') THEN 'CORRECTIVE' ELSE 'DEBIT' END AS '@Type'				-- Type of the corrective invoice.
									FROM FJ FREF WHERE ISNULL(FREF.FISIIC,'') = ISNULL(S.FISRELATEDFIC,'')  
									AND ISNULL(S.FISRELATEDFIC,'')<>''
									FOR XML PATH ('CorrectiveInv'), TYPE
								) ELSE NULL END						-- XML element groups data for an original invoice that will be corrected with current invoice.
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
									SELECT	REPLACE(CONVERT(VARCHAR,CAST(DTDSHOQ AS datetime), 111), '/', '-') AS '@Start',		--Start day of the supply.
											REPLACE(CONVERT(VARCHAR,CAST(DTDSHOQ AS datetime), 111), '/', '-') AS '@End'	
											--REPLACE(CONVERT(VARCHAR,CAST(eomonth(dtdshoq) AS datetime), 111), '/', '-') AS '@End'			--End day of the supply.
									WHERE 1 = 1
									FOR XML PATH ('SupplyDateOrPeriod'), TYPE	
								  )										--XML element representing supply date or period of supply, if it is different from the date when the invoice was issued.
								,
								(														-- MANDATORY: 

									-- SELECT * FROM CONFIG..TIPDOK WHERE TIPDOK = 'S'
									SELECT CONVERT(DECIMAL(18, 2), ROUND(S.VLERTOT*S.KURS2,2)) AS 'PayMethod/@Amt',
									@FISMENPAGESE AS 'PayMethod/@Type',
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
											KURS2 AS 'Currency/@ExRate',				--Exchange rate applied to calculate the equivalent amount of foreign currency for the total amount expressed in ALL. Exchange rate express equivalent amount of ALL for 1 unit of foreign currency.
											'0' AS 'Currency/@IsBuying'				--True if exchange transaction is buying of the foreign currency. False if exchange transaction is selling of the foreign currency.
									WHERE KMON NOT IN ('', 'ALL')						
									FOR XML PATH (''), TYPE	
								  )														--XML element representing currency in which the amount on the invoice should be paid, if different from ALL
							   ,(	--nga config -- SELECT * FROM CONFND
									SELECT PERSHKRIM AS 'Seller/@Name',					-- MANDATORY: 
										   @VatRegistrationNo		 AS 'Seller/@IDNum',				-- MANDATORY:	
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
											CONVERT(DECIMAL(18, 2), 0) AS 'I/@R',				-- OPTIONAL:  Percentage of the rebate.	
											'true' AS 'I/@RR',									-- OPTIONAL:  Is rebate reducing tax base amount?
											NJESI AS 'I/@U',									-- MANDATORY: What is the item’s unit of measure (piece, weight measure, length measure, etc.)
											CONVERT(DECIMAL(18, 2), ROUND(CMIMBS*S.KURS2,2)) AS 'I/@UPB',		-- MANDATORY: Unit price before Value added tax is applied
											--CONVERT(DECIMAL(18, 2), CMIMBS) AS 'I/@UPA',		-- MANDATORY: Unit price after Value added tax is applied
											CONVERT(DECIMAL(18, 2), ROUND(VLERABS/SASI*S.KURS2,2)) AS 'I/@UPA',
								
											-- nuk duhet APLTVSH
											CASE WHEN VLTVSH = 0 AND APLTVSH = 'false' THEN 'TYPE_1' ELSE NULL END AS 'I/@EX',			-- OPTIONAL: 
																																			-- Exempt from VAT.
																																			-- TYPE_1 Exempt type 1. Exempted on the basis of Article 51 of the VAT law 
																																			-- TYPE_2 Exempt type 2. Exempted on the basis of Articles 53 and 54 of the VAT law 
																																			-- TAX_FREE Tax free amount. Sales without VAT that is exempted based on VAT law other then articles 51, 53 and 54 of VAT law, and is not margin scheme nor export of goods 
																																			-- MARGIN_SCHEME Margin scheme (Travel agents VAT scheme, second hand goods VAT scheme, works of art VAT scheme, collectors’ items and antiques VAT scheme etc.). 
																																			-- EXPORT_OF_GOODS Export of goods. No VAT.
																					

											APLINVESTIM AS 'I/@IN',								-- If true, the item is investment for the buyer. Mandatory only for importation of goods.
											CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2))  AS 'I/@VA',		-- MANDATORY: Amount of value added tax for goods and services. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true. Negative values allowed when CorrectiveInv or BadDebtInv exist.
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
											CONVERT(DECIMAL(18, 2), ROUND(SUM(VLPATVSH*@KURSFAT),2))					  AS 'SameTax/@PriceBefVAT',
											CONVERT(DECIMAL(18, 2), PERQTVSH)					   	  AS 'SameTax/@VATRate',
											CASE WHEN APLTVSH='false' AND SUM(VLTVSH)=0  THEN 'TYPE_1' ELSE NULL END	AS 'SameTax/@ExemptFromVAT',
											--APLTVSH													  AS 'SameTax/@ExemptFromVAT',		-- nuk duhet APLTVSH
																													-- Exempt from VAT.
																														-- TYPE_1 Exempt type 1. Exempted on the basis of Article 51 of the VAT law 
																														-- TYPE_2 Exempt type 2. Exempted on the basis of Articles 53 and 54 of the VAT law 
											CONVERT(DECIMAL(18, 2), ROUND(SUM(VLTVSH*@KURSFAT),2))					  AS 'SameTax/@VATAmt'
									FROM #FJSCR
									WHERE @TIPFISKAL='VAT'
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
					FROM #FJ  S
					WHERE S.NRRENDOR = @NrRendor
					FOR XML PATH('Invoice'), TYPE
				)
				FOR XML PATH('RegisterInvoiceRequest'));
    
				--Gjenerimi i url per kontrollin e fiskalizimit te fatures
				SET @QrCodeLink = 'https://efiskalizimi-app.tatime.gov.al/invoice-check/#/verify?' 
								+ 'iic='	+ @Iic
								+ '&tin='	+ @VatRegistrationNo
								+ '&crtd='	+ @Date
								+ '&ord='   + @Nr
								+ '&bu='    + @BusinessUnit				
								+ '&cr='    + @CashRegister
								+ '&sw='    + @SoftNum
								+ '&prc='   + @VlerTot;  
			  --SELECT 	@QrCodeLink,@Iic,@VatRegistrationNo,@Date,@Nr,@BusinessUnit,@CashRegister,@SoftNum,@VlerTot
	
				SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterInvoiceRequest>','<RegisterInvoiceRequest xmlns="' + @Schema +'" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3">') AS XML)

			SELECT @XmlString = CAST(@XML AS VARCHAR(MAX))  

				IF(@Fiscalize != 0)	
				BEGIN
					--BEGIN TRY
							
						EXEC _FiscalProcessRequest 
							@InputString		 = @XmlString,
							@CertBinary		 = @Certificate,
							@CertificatePath	 = @CertificatePath, 
							@Certificatepassword = @CertificatePwd, 
							@Url				 = @FiscUrL,
							@Schema				 = @Schema,
							@ReturnValue		 = 'FIC',
							@useSystemProxy		 = '',
							@SignedXml			 = @SignedXml	OUTPUT, 
							@Fic				 = @Fic			OUTPUT, 
							@Error				 = @Error		OUTPUT, 
							@Errortext			 = @Errortext	OUTPUT,
							@responseXml		 = @responseXml OUTPUT;
							
					--END TRY
					--BEGIN CATCH
						
					--END CATCH
	
					UPDATE FJ SET FISFIC			= CASE WHEN @Error = '0' THEN @Fic ELSE '' END,
								  FISLASTERRORFIC		= @Error,
								  FISLASTERRORTEXTFIC	= @Errortext,
								  FISQRCODELINK			= @QrCodeLink,
								  FISIIC				= @IIC ,
								  FISIICSIG				= @IICSIGNATURE,
								  FISRESPONSEXMLFIC		= CONVERT(VARCHAR(MAX),@responseXml),
								  FISXMLSTRING			= @XmlString,
								  FISXMLSIGNED			= @SignedXml
								  --FISSTATUS		= 'SUKSES'
					WHERE NRRENDOR = @NrRendor;
				--SELECT 	    @QrCodeLink
			 --  , @Xml			
			 --  , @Error			
			 --  , @ErrorText
			 --  , @responseXml
			END


			IF @Error = '0'
				SET @OUTPUT1=@Error
			ELSE
				SET @OUTPUT1=@Errortext

END TRY
BEGIN CATCH
	SET @OUTPUT1 = ERROR_MESSAGE()
END CATCH
END

--SELECT @OUTPUT1
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
