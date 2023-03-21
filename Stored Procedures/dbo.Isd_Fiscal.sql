SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[Isd_Fiscal]
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
				,@SHENIMEEIC		VARCHAR(200)
		
   SET @SignedXml = '';
   SET @Fic = '';

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
			, @VlerTot			= CONVERT(VARCHAR(20), (CONVERT(DECIMAL(18, 2), ROUND(VLERTOT,2))))
			, @PerqZbr			= ISNULL(PERQZBR, 0)
			, @IicBlank			= @NIPT
									+ '|' + dbo.DATE_1601(FJ.DATECREATE) 
									+ '|' + CONVERT(VARCHAR(MAX), CONVERT(BIGINT, NRFISKALIZIM))
									+ '|' + LOWER(FISBUSINESSUNIT) 
									+ '|' + LOWER(tcr.KODTCR) 
									+ '|' + @SoftNum 
									+ '|' + CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(18,2), ROUND(VLERTOT*KURS2,2)))
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
			--, @SELF				= CASE WHEN FJ.NIPT=@NIPT AND ISNULL(FJ.KLASETVSH,'')<>'SANG' THEN  'SELF' 
			--						   WHEN FJ.KLASETVSH='SANG' THEN 'DOMESTIC' 
			--						   ELSE  NULL END
			
			,@SELF=(SELECT CASE WHEN ISNULL(FJ.KLASETVSH,'') ='SANG' THEN 'SELF'
								WHEN ISNULL(FJ.KLASETVSH,'') ='SELF' THEN 'SELF'
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
			, @RELATEDTYPE		= CASE WHEN FJ.LLOJDOK IN ('FK','T') THEN 'CORRECTIVE' ELSE NULL END
			, @UniqueIdentif	= CASE WHEN ISNULL(FISUUID,'') = '' 
									   THEN NEWID()
									   ELSE FJ.FISUUID END

									   --WHENCASE WHEN @IsEinvoice=1 THEN NEWID() 
									   --WHEN ISNULL(FISUUID,'')='' THEN NEWID()
									   --ELSE FISUUID END
			,@FISDATEPARE		= ISNULL(FISDATEPARE,DTDSHOQ)
			,@FISDATEFUND		= ISNULL(FISDATEFUND,DTDSHOQ)		
			,@FISTVSHEFEKT		= ISNULL(FISTVSHEFEKT,35)
			,@SHENIMEEIC		= FJ.SHENIME
	FROM FJ 
	LEFT JOIN FisTCR tcr ON FJ.FISTCR = tcr.KOD
	LEFT JOIN FisOperator oper ON FJ.FISKODOPERATOR = oper.KOD
	LEFT JOIN FisMenPagese pag ON FJ.FISMENPAGESE = pag.KOD
	WHERE fj.NRRENDOR = @NrRendor;
	
	SET NOCOUNT ON;
	--SET @UniqueIdentif = NEWID();
	
	SET @RELATEDDATE=(SELECT TOP 1 DATECREATE FROM FJ WHERE FISIIC=@RELATEDFIC AND NRRENDOR<>@NrRendor)

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

					--SELECT * INTO #FJSCR 
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
			VLERAPAZBR=CASE WHEN ROUND(PERQDSCN,2)<>0 THEN ROUND(SASI*CMSHZB0,2) ELSE  ROUND(S.VLPATVSH,2) END,
			EXTVSHFIC=(SELECT TOP 1 KODTVSHFIC FROM KlasaTatim WHERE KlasaTatim.KOD=S.KODTVSH),
			EXTVSHEIC=(SELECT TOP 1 KODTVSHEIC FROM KlasaTatim WHERE KlasaTatim.KOD=S.KODTVSH)

	--SELECT * FROM KLASATATIM WHERE NRD=1086		
		  
	INTO #FJSCR 
	FROM FJ F
	INNER JOIN FJSCR S ON F.NRRENDOR = S.NRD
	INNER JOIN KLASATATIM K ON S.KODTVSH=K.KOD
	WHERE NRD = @NrRendor;

	UPDATE #FJ SET	VLTVSH		=	(SELECT ROUND(SUM(round(VLERABS-VLPATVSH,2)),2) FROM #FJSCR),
					VLPATVSH	=	(SELECT ROUND(SUM(round(VLPATVSH,2)),2) FROM #FJSCR),
					VLERTOT		=	(SELECT ROUND(SUM(round(VLERABS,2)),2) FROM #FJSCR),
					KMON		=	CASE WHEN KMON = '' THEN 'ALL' ELSE KMON END;
	
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
	
	IF ISNULL(@IICBLANK,'')<>''
	EXEC _FiscalGenerateHash @IicBlank, @CertificatePath, @CertificatePwd, @Certificate, 
	@IIC OUTPUT, @IICSIGNATURE OUTPUT, @ERROR OUTPUT, @ERRORtext OUTPUT;
	
	--SELECT @IicBlank,@CertificatePath,@CertificatePwd,@Certificate,@Iic,@IicSignature,@Error,@ErrorText

	

	SET @XML  = (
					SELECT 
							CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 THEN @SENDDATETIME ELSE dbo.DATE_1601(@DATECREATE) END AS 'Header/@SendDateTime',  -- MANDATORY: 
						--	@SENDDATETIME AS 'Header/@SendDateTime',  -- MANDATORY: 
							CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 then 'NOINTERNET' else null end  AS 'Header/@SubseqDelivType',	-- MANDATORY:  Duhet shtuar ne fature NOINTERNET, BOUNDBOOK, SERVICE, TECHNICALERROR
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
							   ,CASE WHEN @TIPFISKAL='VAT' THEN NULL ELSE (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHTAXFREEAMOUNT),2)) FROM #FJSCR) END AS '@TaxFreeAmt'-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged							   							   
							   ,CASE WHEN (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(MarkUpAmt),2)) FROM #FJSCR)=0 THEN NULL
									 ELSE (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(MarkUpAmt),2)) FROM #FJSCR) END AS '@MarkUpAmt'						-- OPTIONAL: Amount related to special procedure for margin scheme
							   --,NULL			AS '@GoodsExAmt'						-- OPTIONAL: Amount of goods for export from the Republic of Albania. 
							   ,CASE WHEN KLASETVSH='SEXP' THEN  CONVERT(DECIMAL(18, 2), ROUND(VLERTOT*S.KURS2,2)) ELSE NULL END			AS '@GoodsExAmt'						-- OPTIONAL: Amount of goods for export from the Republic of Albania. 
							   --,CONVERT(DECIMAL(18, 2), ROUND(VLPATVSH*S.KURS2,2))	AS '@TotPriceWoVAT'	-- MANDATORY: Total price of the invoice excluding VAT.
							   ,(SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHMV),2)) FROM #FJSCR) AS '@TotPriceWoVAT'
							   --,CASE WHEN @TIPFISKAL='VAT' THEN CONVERT(DECIMAL(18, 2), ROUND(VLTVSH*S.KURS2,2)) ELSE NULL end		AS '@TotVATAmt'		-- MANDATORY: Total VAT amount of the invoice. 
							   ,CASE WHEN @TIPFISKAL='VAT' THEN (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLTVSHMV),2)) FROM #FJSCR)  ELSE NULL end		AS '@TotVATAmt'		-- MANDATORY: Total VAT amount of the invoice. 
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
											--RIGHT('0000000000000000000000000000000000012345678',32)		AS '@IICRef',				-- IIC reference on the original invoice.
											--DBO.DATE_1601(@RELATEDDATE)	AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.
											@RELATEDFIC		AS '@IICRef',				-- IIC reference on the original invoice.
											DBO.DATE_1601(@RELATEDDATE)	AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.

											@RELATEDTYPE	AS '@Type'
										 FOR XML PATH ('CorrectiveInv'), TYPE

										)
										ELSE NULL END
							  
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
											CONVERT(DECIMAL(18, 6), KURS2) AS 'Currency/@ExRate'	
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
									SELECT	REPLACE(C.PERSHKRIM, '"', '')  AS 'Buyer/@Name',		-- OPTIONAL| MANDATORY B2B: 
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
																								-- NQS ESHTE PERSON FIZIK DUHET SPECIFIKUAR --> NDARES PER PERSON FIZIK APO SUBJEKT -- NUIS: NUIS-number | ID: Personal ID-number | PASS: Passport-number | VAT: VAT-number | TAX: TAX-number 
																						
											ISNULL(ADRESA1, '')			 AS 'Buyer/@Address',	-- OPTIONAL| MANDATORY IF NAME IS FILLED: 
											CASE WHEN V.KOD IS NULL THEN ISNULL(ADRESA2, '')
												 ELSE V.PERSHKRIM END AS 'Buyer/@Town',		-- OPTIONAL| MANDATORY IF NAME IS FILLED: 
											CASE WHEN V.KOD IS NULL THEN ISNULL(ADRESA3, '')
												 WHEN ISNULL(V.KODCOUNTRY,'')='' THEN 'ALB'  
												 ELSE ISNULL(V.KODCOUNTRY,'ALB') END  AS 'Buyer/@Country'	-- OPTIONAL| MANDATORY IF NAME IS FILLED: 	
									
									FROM KLIENT C LEFT JOIN VENDNDODHJE V 
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
								CASE WHEN (EXTVSHFIC<>'VAT' OR ISNULL(@TIPFISKAL,'')<>'VAT') 
								THEN NULL ELSE  CONVERT(DECIMAL(18, 2), ROUND(VLTVSHMV,2)) END  AS 'I/@VA',

								CASE WHEN (EXTVSHFIC<>'VAT' OR ISNULL(@TIPFISKAL,'')<>'VAT') 
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
								+ '&prc='   + CONVERT(VARCHAR(50),CONVERT(DECIMAL(34, 2),ROUND(@VlerTot*@KURS2,2)));;  
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

--------------------------------------------FUND FISKALIZIMI			
	--SET @CashRegister = (SELECT TOP 1 KODTCR FROM FJ A INNER JOIN FisTCR B ON A.FISTCR=B.KOD WHERE A.NRRENDOR=@NrRendor)
	--SET @OperatorCode = (SELECT TOP 1 KODFISCAL FROM FJ A INNER JOIN FisOperator B ON A.FISKODOPERATOR=B.KOD WHERE A.NRRENDOR=@NrRendor)
	--SET @BusinessUnit = (SELECT TOP 1 FISBUSINESSUNIT FROM FJ A  WHERE A.NRRENDOR=@NrRendor)
	--SET @FISMENPAGESEFIC = (SELECT TOP 1 KODFIC FROM FJ A INNER JOIN dbo.FisMenPagese B ON A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@NrRendor)
	--SET @FISMENPAGESEEIC = (SELECT TOP 1 KODEIC FROM FJ A INNER JOIN dbo.FisMenPagese B ON A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@NrRendor)
	--SET @MODEPAGESE = CASE WHEN (SELECT TOP 1 KLASEPAGESE FROM FJ A INNER JOIN dbo.FisMenPagese B ON A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@NrRendor)='ARKE' THEN 'CASH' ELSE 'NONCASH' END
	--SET @KLASEPAGESE = (SELECT TOP 1 KLASEPAGESE FROM FJ A INNER JOIN dbo.FisMenPagese B ON A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@NrRendor)
	--SET @FISPROCES = (SELECT TOP 1 FISPROCES FROM FJ A  WHERE A.NRRENDOR=@NrRendor)
	--SET @FISTIPDOK = (SELECT TOP 1 FISTIPDOK FROM FJ A  WHERE A.NRRENDOR=@NrRendor)
	--SET @FISUUID = (SELECT TOP 1 FISUUID FROM FJ A  WHERE A.NRRENDOR=@NrRendor)
	--SET @KURS2=(SELECT TOP 1 KURS2 FROM FJ A  WHERE A.NRRENDOR=@NrRendor)
	
	-------------------------------------------------IBAN & SWIFT---------------------------------------------------------
	--SET @KODBANKE = (SELECT TOP 1 B.SHENIM1 FROM FJ A INNER JOIN dbo.FisMenPagese B ON A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@NrRendor)
	--SET @IBAN = (SELECT TOP 1 B.IBAN FROM BANKAT B WHERE KOD=@KODBANKE)
	--SET @SWIFT = (SELECT TOP 1 B.SWIFTCODE FROM BANKAT B WHERE KOD=@KODBANKE)
	--SET @BANPERSHKRIM = (SELECT TOP 1 B.SHENIM2 FROM BANKAT B WHERE KOD=@KODBANKE)
	

	--SELECT @DATE		= dbo.DATE_1601(DATECREATE),		--> kujdes data duhet edhe me pjesen e ORE-s
	--		@Nr			= CONVERT(VARCHAR(10), CONVERT(BIGINT, NRDSHOQ)),
	--		@VlerTot		= CONVERT(VARCHAR(20), (CONVERT(DECIMAL(18, 2), ROUND(VLERTOT,2)))),
	--		@PerqZbr		= ISNULL(PERQZBR, 0),
	--		@IicBlank	= (SELECT TOP 1 NIPT FROM CONFND) 
	--					+ '|' + dbo.DATE_1601(DATECREATE) 
	--					+ '|' + CONVERT(VARCHAR(MAX), CONVERT(BIGINT, NRDSHOQ))
	--					+ '|' + @BusinessUnit 
	--					+ '|' + @CashRegister 
	--					+ '|' + @SoftNum 
	--					+ '|' + CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(18,2), ROUND(VLERTOT,2)))
	--FROM FJ
	--WHERE NRRENDOR = @NrRendor;

	
	


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
						SELECT	'CurrencyExchangeRate=' + CONVERT(VARCHAR(10), KURS2) +'#AAI#' AS 'cbc:Note'
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
						SELECT	'CurrencyExchangeRate=' + CONVERT(VARCHAR(10),KURS2) +'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	'CurrencyIsBuying=false#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	'IsBadDebtInv=false#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT 'IIC=' + ISNULL(@FISIIC, '') +'#AAI#' AS 'cbc:Note' 
						UNION ALL
						SELECT	'IICSignature=' + ISNULL(@FISIICSIG, '')+'#AAI#' AS 'cbc:Note'
						UNION ALL
						SELECT	'FIC=' +ISNULL(@FISFIC, '')+'#AAI#' AS 'cbc:Note' --> DUHET FISCFIC
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
		
				(
						SELECT ISNULL(PERSHKRIM, '') AS 'cac:AdditionalDocumentReference/cbc:ID',
							   --ISNULL(PERSHKRIM, '') AS 'cac:AdditionalDocumentReference/cbc:DocumentType',
							   ISNULL(PERSHKRIM, 'Test')+'.' + REPLACE(PDFOBJEKTEXT, '.', '') AS 'cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@filename',
							   'application/' + REPLACE(PDFOBJEKTEXT, '.', '') AS 'cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@mimeCode',
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
									KLIENT.NIPT		    AS 'cac:AccountingCustomerParty/cac:Party/cbc:EndpointID',
									'9923:'+KLIENT.NIPT	AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID',
									KLIENT.PERSHKRIM	AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name',
									KLIENT.ADRESA1		AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName',
									V.PERSHKRIM		    AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName',
									'AL'			    AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode',
								--	KLIENT.ADRESA2	    AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName',
								--	'ALB'				AS 'cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity',
									'AL:'+KLIENT.NIPT    AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID',
									CASE WHEN ISNULL(KLIENT.KODFISKAL,'')='VAT' THEN 'VAT' else 'FRE'end  AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID',
									KLIENT.PERSHKRIM	AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName',
									KLIENT.NIPT		    AS 'cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID'

					FROM KLIENT
					LEFT JOIN VENDNDODHJE V ON KLIENT.VENDNDODHJE = V.KOD
					WHERE KLIENT.KOD = S.KODFKL
					FOR XML PATH(''), TYPE
				),
			 
				@FISMENPAGESEEIC	 AS 'cac:PaymentMeans/cbc:PaymentMeansCode',
				@FISMENPAGESEFIC	AS 'cac:PaymentMeans/cbc:InstructionNote',
				@IBAN AS 'cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:ID',
				@BANPERSHKRIM AS 'cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:Name',
				@SWIFT AS 'cac:PaymentMeans/cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID',
		
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
						  , CASE WHEN  PERQTVSH=0 and APLTVSH=0 THEN 'VATEX-EU-O' ELSE NULL END AS 'cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReasonCode'
						  , CASE WHEN  PERQTVSH=0 and APLTVSH=0 THEN 'Not subject to VAT' ELSE NULL END AS 'cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReason'
						 , 'VAT' AS 'cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:ID'
					FROM #FJSCR F 
					WHERE NRD = S.NRRENDOR 
					GROUP BY F.PERQTVSH,APLTVSH,EXTVSHEIC
					ORDER BY F.PERQTVSH,APLTVSH,EXTVSHEIC DESC			
					FOR XML PATH(''), TYPE
				)  AS 'cac:TaxTotal',
				CASE WHEN KMON='ALL' THEN null else (SELECT   
							'ALL' AS 'cbc:TaxAmount/@currencyID'
						  , CONVERT(DECIMAL(20, 2), ROUND(SUM(F.VLTVSH)*@KURS2,2)) AS 'cbc:TaxAmount'
				  
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
			SELECT @XmlString = REPLACE(CAST(@XML AS VARCHAR(MAX)), ' xmlns:cac="cac" xmlns:cbc="cbc"', '');
	
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

	
			--SELECT CAST(@XmlStringTemp AS XML) AS 'PARA'
	
	
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
	 
			--SELECT @XML AS 'PAS'
	
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

			SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterEinvoiceRequest>','<RegisterEinvoiceRequest xmlns="https://Einvoice.tatime.gov.al/EinvoiceService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="1">') AS XML)
			--SELECT @XML;

			SET @XmlString = CAST(@XML AS NVARCHAR(MAX));
	

			--SELECT @XmlString AS 'PAS2'
	
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

		--SELECT @Fic,@Error,@Errortext,@responseXml,@XmlString

			IF (@Error = '0')
				 BEGIN
					EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="https://Einvoice.tatime.gov.al/EinvoiceService/schema" />';

					SELECT @EIC = EIC
					FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:RegisterEinvoiceResponse')
					WITH
					(
						EIC VARCHAR (50) 'ns2:EIC'
					);
					EXEC sp_xml_removedocument @hDoc;

					UPDATE FJ SET		  FISFIC			    = @FISFIC,
										  FISLASTERRORFIC		= @FISLASTERRORFIC,
										  FISLASTERRORTEXTFIC	= @FISLASTERRORTEXTFIC,
										  FISQRCODELINK			= @FISQRCODELINK,
										  FISIIC				= CASE WHEN ISNULL(FISIIC,'')='' THEN @FISIIC ELSE FISIIC END,
										  FISIICSIG				= CASE WHEN ISNULL(FISIICSIG,'')='' THEN @FISIICSIG ELSE FISIICSIG END,
										  FISRESPONSEXMLFIC		= CONVERT(VARCHAR(MAX),@FISRESPONSEXMLFIC),
										  FISXMLSTRING			= @FISXMLSTRING,
										  FISXMLSIGNED			= @FISXMLSIGNED,
										  FISEIC				= @EIC,
										  FISRESPONSEXMLEIC		= CONVERT(VARCHAR(MAX),@responseXml),
										  FISLASTERROREIC		= @Error,
										  FISUUID				= @UniqueIdentif,
										--  DATECREATE			= @DATECREATE,
										  FISKALIZUAR			= CASE WHEN ISNULL(@EIC,'')<>'' THEN 1 ELSE 0 END,
										  FISSTATUS				= CASE WHEN ISNULL(@EIC,'')<>'' THEN 'DELIVERED' ELSE '' END,
										  NRSERIAL				= @FISFIC
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
									faultcode		NVARCHAR(MAX)	'faultcode',
									faultstring	NVARCHAR(MAX)	'faultstring'
								)
								ORDER BY faultcode;
						
								EXEC sp_xml_removedocument @hDoc;


								UPDATE FJ SET		  --FISFIC			    = @FISFIC,
										  FISLASTERRORFIC		= @FISLASTERRORFIC,
										  FISLASTERRORTEXTFIC	= @FISLASTERRORTEXTFIC,
										  FISQRCODELINK			= @FISQRCODELINK,
										  FISIIC				= CASE WHEN ISNULL(FISIIC,'')='' THEN @FISIIC ELSE FISIIC END,
										  FISIICSIG				= CASE WHEN ISNULL(FISIICSIG,'')='' THEN @FISIICSIG ELSE FISIICSIG END,
										  FISRESPONSEXMLFIC		= CONVERT(VARCHAR(MAX),@FISRESPONSEXMLFIC),
										  FISXMLSTRING			= @FISXMLSTRING,
										  FISXMLSIGNED			= @FISXMLSIGNED,
										  FISEIC				= @EIC,
										  FISRESPONSEXMLEIC		= CONVERT(VARCHAR(MAX),@responseXml),
										  FISLASTERROREIC		= @Error,
										  FISUUID				= @UniqueIdentif,
										  --DATECREATE			= @DATECREATE,
										  FISKALIZUAR			= CASE WHEN ISNULL(@EIC,'')<>'' THEN 1 ELSE 0 END,
										  FISSTATUS				= CASE WHEN ISNULL(@EIC,'')<>'' THEN 'DELIVERED' ELSE '' END,
										  NRSERIAL				= ''--@FISFIC
										  WHERE NRRENDOR		= @NrRendor AND FISKALIZUAR=0;

					
								
/*				IF(@Error = 50)
				BEGIN
				
					DECLARE @tempOutput VARCHAR(MAX),
							@tempDateFat DATETIME,
							@tempDateFat2 DATETIME,
							@tempNr	VARCHAR(50),
							@tempVlera float,
							@tempEic VARCHAR(50);
							
					
					
					SELECT @tempNr = CONVERT(VARCHAR(10), CONVERT(BIGINT, NRDOK)) + '/' + CONVERT(VARCHAR(4), YEAR(DATECREATE)) + CASE WHEN @MODEPAGESE = 'CASH' THEN + '/' + ISNULL(@CashRegister, 'ABCDEF') ELSE '' END,
						   @tempDateFat = CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, DATECREATE))),
						   @tempDateFat2= CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, DATECREATE+1))),
						   @tempVlera=Vlertot
					FROM FJ 
					WHERE NRRENDOR = @NrRendor;

					EXEC __eInvoiceGetRequest '', 'SELLER', @tempDateFat, @tempDateFat2, 0, @tempOutput OUT
					
					set @tempEic=(select FISEIC = (SELECT TOP 1 EIC FROM #TTT WHERE DocNumber = @tempNr AND AMOUNT=@tempVlera)
					from fj
					WHERE NRRENDOR = @NrRendor);

					IF ISNULL(@tempEic,'')<>'' 
					UPDATE FJ SET FISEIC = @tempEic,FISKALIZUAR=1
					WHERE NRRENDOR = @NrRendor;				

				END	
				*/
							END TRY
							BEGIN CATCH
								SET @OUTPUT1 = ISNULL(@Errortext, '') + '-> CAN NOT PARSE RESPONSE';
							END CATCH
							ELSE 
								SET @OUTPUT1 = ISNULL(@Errortext, '');
					
					IF @FISLASTERRORFIC = '0'
						SET @OUTPUT1=@FISLASTERRORFIC
				    ELSE
						SET @OUTPUT1=@FISLASTERRORTEXTFIC+@FISFIC

					UPDATE FJ SET  FISLASTERROREIC		= @Error
								 , FISLASTERRORTEXTEIC	= @ErrorText
					WHERE NRRENDOR=@NrRendor;

					SET @OUTPUT1=@OUTPUT1+@Errortext;
			END;
	END ----IF INVOICE=1
	ELSE
		BEGIN
			
				
					UPDATE FJ SET		  FISFIC			    = CASE WHEN @FISLASTERRORFIC = '0' THEN @FISFIC ELSE '' END ,
										  FISLASTERRORFIC		= @FISLASTERRORFIC,
										  FISLASTERRORTEXTFIC	= @FISLASTERRORTEXTFIC,
										  FISQRCODELINK			= @FISQRCODELINK,
										  FISIIC				= CASE WHEN ISNULL(FISIIC,'')='' THEN @FISIIC ELSE FISIIC END,
										  FISIICSIG				= CASE WHEN ISNULL(FISIICSIG,'')='' THEN @FISIICSIG ELSE FISIICSIG END,
										  FISRESPONSEXMLFIC		= CONVERT(VARCHAR(MAX),@FISRESPONSEXMLFIC),
										  FISXMLSTRING			= @FISXMLSTRING,
										  FISXMLSIGNED			= @FISXMLSIGNED,
										  FISUUID				= @UniqueIdentif,
										  --DATECREATE			=@DATECREATE,
										  FISSTATUS		= CASE WHEN @FISLASTERRORFIC = '0' THEN 'FISKALIZUAR' ELSE 'PA FISKALIZUAR' END,
										  FISEIC		= CASE WHEN @FISLASTERRORFIC = '0' THEN 'FISKALIZUAR' ELSE '' END ,
										  FISKALIZUAR	=CASE WHEN @FISLASTERRORFIC = '0' THEN 1 ELSE 0 END ,
										  NRSERIAL		=CASE WHEN @FISLASTERRORFIC = '0' THEN @FISFIC ELSE NRSERIAL END
							WHERE NRRENDOR = @NrRendor

					
				IF @FISLASTERRORFIC = '0'
					SET @OUTPUT1=@FISLASTERRORFIC
				ELSE
					SET @OUTPUT1=@FISLASTERRORTEXTFIC+@FISFIC
		

		END;


			UPDATE FJ SET		 
										  FISQRCODELINK			= @FISQRCODELINK,
										  FISIIC				= CASE WHEN ISNULL(FISIIC,'')='' THEN @FISIIC ELSE FISIIC END,
										  FISIICSIG				= CASE WHEN ISNULL(FISIICSIG,'')='' THEN @FISIICSIG ELSE FISIICSIG END,

										  FISUUID				= CASE WHEN ISNULL(FISUUID,'')='' THEN @UniqueIdentif ELSE FISUUID END
										  --DATECREATE			=@DATECREATE,
										  --  FISSTATUS		= CASE WHEN @FISLASTERRORFIC = '0' THEN 'FISKALIZUAR' ELSE 'PA FISKALIZUAR' END,
										 
										  --,
										  --FISKALIZUAR	=CASE WHEN @FISLASTERRORFIC = '0' THEN 1 ELSE 0 END 
										
							WHERE NRRENDOR = @NrRendor


 END;
GO
