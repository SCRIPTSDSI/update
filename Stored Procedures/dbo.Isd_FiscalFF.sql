SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[Isd_FiscalFF]
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
			, @KURS2			= KURS2
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
			, @RELATEDTYPE		= CASE WHEN FF.LLOJDOK IN ('FK','T') THEN 'CORRECTIVE' ELSE NULL END
			, @UniqueIdentif	= CASE WHEN ISNULL(FISUUID,'')='' 
											THEN NEWID()
										ELSE FF.FISUUID END

			--, @UniqueIdentif	= CASE WHEN @IsEinvoice=1 THEN NEWID() 
			--						   WHEN ISNULL(FISUUID,'')='' THEN NEWID()
			--						   ELSE FISUUID END
			,@FISDATEPARE		= ISNULL(FISDATEPARE,DTDSHOQ)
			,@FISDATEFUND		= ISNULL(FISDATEFUND,DTDSHOQ)		
			,@FISTVSHEFEKT		= ISNULL(FISTVSHEFEKT,35)		
	FROM FF 
	LEFT JOIN FisTCR tcr ON FF.FISTCR = tcr.KOD
	LEFT JOIN FisOperator oper ON FF.FISKODOPERATOR = oper.KOD
	LEFT JOIN FisMenPagese pag ON FF.FISMENPAGESE = pag.KOD
	WHERE FF.NRRENDOR = @NrRendor;
	--SELECT * FROM FisMenPagese
	SET NOCOUNT ON;
	--SET @UniqueIdentif = NEWID();
	
	SET @RELATEDDATE=(SELECT TOP 1 DATECREATE FROM FF WHERE FISIIC=@RELATEDFIC AND NRRENDOR<>@NrRendor)

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
			CMIMBSMV=ROUND(ROUND(CMIMBS,2)*F.KURS2,2),
			CMIMBSTVSH = ROUND((VLERABS / CASE WHEN SASI = 0 THEN 1 ELSE SASI END),2),
			PERQTVSH=CASE WHEN ROUND(S.VLTVSH,2)=0 THEN 0 ELSE ROUND(S.PERQTVSH,2) END,
			VLPATVSH=ROUND(S.VLPATVSH,2),
			VLPATVSHMV=ROUND(ROUND(S.VLPATVSH,2)*F.KURS2,2),
			VLTVSH=ROUND(VLERABS,2)-ROUND(S.VLPATVSH,2),--ROUND(S.VLTVSH,2),
			VLTVSHMV=ROUND((ROUND(VLERABS,2)-ROUND(S.VLPATVSH,2))*F.KURS2,2),
			VLERABS=ROUND(VLERABS,2),
			VLERABSMV=ROUND(ROUND(VLERABS,2)*F.KURS2,2),
			APLTVSH,
			CASE WHEN APLTVSH = 1 THEN 'true' ELSE 'false' END AS APLTVSHFIS,
			CASE WHEN APLINVESTIM = 1 THEN 'true' ELSE 'false' END AS APLINVESTIM,
		    VLPATVSHTAXFREEAMOUNT=ROUND((CASE WHEN S.VLTVSH=0 AND ISNULL(KLASETVSH,'')<>'SEXP' THEN S.VLPATVSH ELSE 0 END)*KURS2,2),
			MarkUpAmt= ROUND((CASE WHEN ISNULL(KLASETVSH,'')='SEXP' THEN 0
							WHEN KODTVSHFIC ='MARGIN_SCHEME' 
								THEN ROUND(S.VLPATVSH,2) 
							ELSE 0 
							END)*F.KURS2,2),
			PERQDSCN=CASE WHEN TIPKLL<>'L' THEN ROUND(PERQDSCN,2) ELSE 0 END,
			VLERAZBR=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND((SASI*CMSHZB0)-(SASI*CMIMBS),2) ELSE 0 END,
			VLERAPAZBR=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND(SASI*CMSHZB0,2) ELSE  ROUND(S.VLPATVSH,2) END,
			EXTVSHFIC=KODTVSHFIC,--(SELECT TOP 1 KODTVSHFIC FROM KlasaTatim WHERE KlasaTatim.KOD=S.KODTVSH),
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

	/*
	(SELECT CASE WHEN KODTVSHFIC NOT IN ('TYPE_1','TYPE_2') THEN (CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHTAXFREEAMOUNT),2)))
											ELSE 0 END 
											FROM #FFSCR 
											GROUP BY EXTVSHFIC )
	*/

	UPDATE #FF SET	VLTVSH		=	(SELECT ROUND(SUM(round(VLERABS-VLPATVSH,2)),2) FROM #FFSCR),
					VLPATVSH	=	(SELECT ROUND(SUM(round(VLPATVSH,2)),2) FROM #FFSCR),
					VLERTOT		=	(SELECT ROUND(SUM(round(VLERABS,2)),2) FROM #FFSCR),
					KMON		=	CASE WHEN KMON = '' THEN 'ALL' ELSE KMON END;
	

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
							CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 then 'NOINTERNET' else null end  AS 'Header/@SubseqDelivType',	-- MANDATORY:  Duhet shtuar ne fature [NOINTERNET, BOUNDBOOK, SERVICE, TECHNICALERROR]
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
							   ,CASE WHEN @TIPFISKAL='VAT' THEN NULL ELSE (SELECT (CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHTAXFREEAMOUNT),2))) FROM #FFSCR 
										 ) END AS  '@TaxFreeAmt'-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged							   							   
							   ,CASE WHEN (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(MarkUpAmt),2)) FROM #FFSCR)=0 THEN NULL
									 ELSE (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(MarkUpAmt),2)) FROM #FFSCR) END AS '@MarkUpAmt'							-- OPTIONAL: Amount related to special procedure for margin scheme
							   --,NULL			AS '@GoodsExAmt'						-- OPTIONAL: Amount of goods for export from the Republic of Albania. 
							   ,CASE WHEN KLASETVSH='SEXP' THEN  CONVERT(DECIMAL(18, 2), ROUND(VLERTOT*S.KURS2,2)) ELSE NULL END			AS '@GoodsExAmt'						-- OPTIONAL: Amount of goods for export from the Republic of Albania. 
							   ,(SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHMV),2)) FROM #FFSCR) AS '@TotPriceWoVAT'	-- MANDATORY: Total price of the invoice excluding VAT.
							   --,CONVERT(DECIMAL(18, 2), VLERTOT)	AS '@TotPriceWoVAT'
							   ,CASE WHEN @TIPFISKAL='VAT' THEN (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLTVSHMV),2)) FROM #FFSCR)  ELSE NULL end		AS '@TotVATAmt'		-- MANDATORY: Total VAT amount of the invoice. 
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
							   ,@IsEinvoice		AS '@IsEinvoice'
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
											KURS2 AS 'Currency/@ExRate'
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
									SELECT	REPLACE(C.PERSHKRIM, '"', '')  AS 'Seller/@Name',		-- OPTIONAL| MANDATORY B2B: 
											NIPT						 AS 'Seller/@IDNum',		-- OPTIONAL| MANDATORY B2B: 
																								/* This field is filled out if buyer is:
																										 a taxpayer of profit tax or a taxpayer of simplified profit tax for small businesses or a taxpayer who is subject to VAT in accordance with special regulations, or
																										 a legal entity to whom goods or services are provided in the territory of the Republic of Albania for the purpose of carrying out his economic activity; or
																										 if personal property of a single value is sold above 500,000 ALL;
																										 or in other cases when the buyer asks for this data to be entered into the invoice, but there is no control in that case. Also, this field is mandatory if the buyer issues the
																										invoice instead of the seller. If this field is entered, beside in the book of sales of the seller, this invoice will also appear in the book of purchase of the buyer if the buyer is a taxpayer.
																										If the buyer is an individual who requires invoice for recognition of the cost of the medication, no book of purchase will be created for him, but a special application will be created to register all the data on
																										all invoices where he has appeared as a buyer and that information will be exchanged with the CIS system. Also, data may be entered for a foreigner or diplomat who will request a VAT refund and this information will be exchanged with the CIS system as well.
																								*/
											ISNULL(C.TIPNIPT,'NUIS')	 AS 'Seller/@IDType',	-- OPTIONAL| MANDATORY B2B: 
																								-- NQS ESHTE PERSON FIZIK DUHET SPECIFIKUAR --> NDARES PER PERSON FIZIK APO SUBJEKT -- [NUIS: NUIS-number | ID: Personal ID-number | PASS: Passport-number | VAT: VAT-number | TAX: TAX-number ]
																						
											ISNULL(ADRESA1, '')			 AS 'Seller/@Address',	-- OPTIONAL| MANDATORY IF NAME IS FILLED: 
									--		ISNULL(ADRESA2, '')			 AS 'Seller/@Town',		-- OPTIONAL| MANDATORY IF NAME IS FILLED: 
									--		ISNULL(LEFT(ADRESA3, 3), '') AS 'Seller/@Country'	-- OPTIONAL| MANDATORY IF NAME IS FILLED: 	
									--FROM FURNITOR C 
									CASE WHEN V.KOD IS NULL THEN ISNULL(ADRESA2, '')
												 ELSE V.PERSHKRIM END AS 'Seller/@Town',		-- OPTIONAL| MANDATORY IF NAME IS FILLED: 
											CASE WHEN V.KOD IS NULL THEN ISNULL(ADRESA3, '')
												 WHEN ISNULL(V.KODCOUNTRY,'')='' THEN 'ALB'  
												 ELSE ISNULL(V.KODCOUNTRY,'ALB') END  AS 'Seller/@Country'	-- OPTIONAL| MANDATORY IF NAME IS FILLED: 	
									
									FROM FURNITOR C LEFT JOIN VENDNDODHJE V 
									ON C.VENDNDODHJE=V.KOD
									
									
									
									WHERE C.KOD = S.KODFKL
									AND ISNULL(C.NIPT, '') != ''
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
											CASE WHEN PERQDSCN<>0 THEN 'true' ELSE 'false' end AS 'I/@RR',	-- OPTIONAL:  Is rebate reducing tax base amount?
											NJESI AS 'I/@U',									-- MANDATORY: What is the item’s unit of measure (piece, weight measure, length measure, etc.)
											CONVERT(DECIMAL(18, 2), ROUND(CMIMBSMV,2)) AS 'I/@UPB',		-- MANDATORY: Unit price before Value added tax is applied
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
									WHERE @TIPFISKAL='VAT' AND ISNULL(EXTVSHFIC,'') <>('MARGIN_SCHEME')
									GROUP BY PERQTVSH, APLTVSHFIS, EXTVSHFIC
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

PRINT @FISIIC
PRINT @FISFIC

				
					
				--SELECT 	    @QrCodeLink
			 --  , @Xml			
			 --  , @Error			
			 --  , @ErrorText
			 --  , @responseXml,@Iic,@Fic,@SignedXml
					
				--	--END TRY
					--BEGIN CATCH
						
					--END CATCH
	/*
					UPDATE FJ SET FISFIC			= CASE WHEN @Error = '0' THEN @Fic ELSE '' END,
								  FISLASTERRORFIC		= @Error,
								  FISLASTERRORTEXTFIC	= @Errortext,
								  FISQRCODELINK			= @QrCodeLink,
								  FISIIC				= @IIC ,
								  FISIICSIG				= @IICSIGNATURE,
								  FISRESPONSEXMLFIC		= @responseXml,
								  FISXMLSTRING			= @XmlString,
								  FISXMLSIGNED			= @SignedXml
								  --FISSTATUS		= 'SUKSES'
					WHERE NRRENDOR = @NrRendor;

					
					UPDATE FJ SET FISUUID = @UniqueIdentif
					WHERE NRRENDOR = @NrRendor;

				--SELECT 	    @QrCodeLink
			 --  , @Xml			
			 --  , @Error			
			 --  , @ErrorText
			 --  , @responseXml
			END
*/



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
