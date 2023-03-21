SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
----(｡◕‿◕｡)

--BEGIN TRY
--ALTER TABLE KLASATVSH ADD KODTVSHFIC VARCHAR(100) NULL,KODTVSHEIC VARCHAR(100) NULL,RESPONSEXMLEIC VARCHAR(MAX)
--END TRY
--BEGIN CATCH
--END CATCH



--BEGIN TRY
--ALTER TABLE SMBAK ADD IIC VARCHAR(100) NULL,IICSIG VARCHAR(100) NULL,RESPONSEXMLEIC XML NULL,RESPONSEXMLEIC VARCHAR(MAX)
--END TRY
--BEGIN CATCH
--END CATCH


--insert into KLASATVSH(kod,pershkrim,KODTVSHFIC,KODTVSHEIC,PERQTVSH)
--values('3','LIBER 6%','VAT','S',6)

--UPDATE KLASATVSH SET KODTVSHFIC='TAX_FREE',KODTVSHEIC='E' WHERE perqtvsh = 0
--UPDATE KLASATVSH SET KODTVSHFIC='VAT',KODTVSHEIC='S' WHERE perqtvsh = 20
--UPDATE KLASATVSH SET KODTVSHFIC='VAT',KODTVSHEIC='S' WHERE perqtvsh = 10
--UPDATE KLASATVSH SET KODTVSHFIC='VAT',KODTVSHEIC='S' WHERE perqtvsh = 6


--alter table sm add fiscbusinunit varchar(1000)

--alter table smbak add fiscbusinunit varchar(1000)

--alter table sm add FISCTCR varchar(1000)

--alter table smbak add FISCTCR varchar(1000)

--alter table sm add relatedtimed datetime null

--alter table smbak add relatedtimed datetime null





CREATE PROC [dbo].[_FiscalCreateSalesXmlPOS]
	@Id						INT
   ,@VatRegistrationNo		VARCHAR(50)
   ,@BusinessUnit			VARCHAR(50)
   ,@SoftNum				VARCHAR(50)
   ,@CertificatePath		VARCHAR(1000)
   ,@CertificatePassword	VARCHAR(1000)
   ,@SCHEMA					VARCHAR(MAX)
   ,@QrCodeLink				VARCHAR(1000) OUTPUT 
   ,@Xml					XML OUTPUT
AS
BEGIN
	DECLARE @Iic			VARCHAR(1000),
			@IicSignature	VARCHAR(1000),
			@Error			VARCHAR(1000),
			@ErrorText		VARCHAR(1000),
			@Date			VARCHAR(100),
			@OrderNumber	VARCHAR(10),
			@Total			VARCHAR(20),
			@CashRegister	VARCHAR(20),		
			@OperatorCode	VARCHAR(20),
			@PERQZBR        FLOAT,
			@IicBlank	    VARCHAR(MAX),
			@DATECREATE     as datetime,
			@NRFISKALIZIM   AS varchar(1000)  --ALBAN

			


		

	SELECT  @PERQZBR =  PERQZBR FROM sm WHERE NRRENDOR = @ID
	--hard coded parameters
	SET @CashRegister = (SELECT TOP 1 U.FISCTCRNUM FROM kase U INNER JOIN sm P ON P.kase = U.kod WHERE P.NRRENDOR = @Id);
	SET @OperatorCode = (SELECT TOP 1 U.OPERATORCODE FROM DRH..USERS U 
	INNER JOIN kase K ON K.KOD = U.DRN 
	INNER JOIN sm P ON P.kase = K.kod 
	WHERE P.NRRENDOR = @Id);

	
	update sm set fisctcr = @CashRegister, fiscbusinunit=@BusinessUnit where nrrendor = @id


     SET @NRFISKALIZIM=(SELECT ISNULL(MAX(CONVERT(BIGINT,NrFiskalizim)),0)+1 
	 FROM
	 (
			 --FJ
			 SELECT max(Nrfiskalizim) AS nrfiskalizim FROM FJ  
			 inner join FisTCR t on t.kod = fj.FISTCR
				where isnull(FISCFIC,'')<>''
				  and (YEAR(DATEDOK)=YEAR(getdate())) 
				  and t.KODTCR = @CashRegister
				  AND fj.FISBUSINESSUNIT=@BusinessUnit
				  and Fj.NRRENDOR<>@ID
			  
			  UNION ALL
			  --FF
			  SELECT max(Nrfiskalizim) AS nrfiskalizim FROM FF  
			  inner join FisTCR t on t.kod = ff.FISTCR
				  where isnull(fisfic,'')<>''
					  and (YEAR(DATEDOK)=YEAR(getdate())) 
					  and t.KODTCR = @CashRegister
					  AND ff.FISBUSINESSUNIT=@BusinessUnit

			  UNION ALL 
			  --SM
			   SELECT max(Nrfiskalizim) AS nrfiskalizim FROM SM  
				where isnull(fic,'')<>''
					and (YEAR(DATEDOK)=YEAR(getdate())) 
					and sm.fisctcr = @cashregister 
					AND sm.fiscbusinunit=@BusinessUnit
					
			   UNION ALL 
			   --SMBAK
			   SELECT max(Nrfiskalizim) AS nrfiskalizim FROM SMBAK  
				where isnull(fic,'')<>''
					and (YEAR(DATEDOK)=YEAR(getdate())) 
					and SMBAK.fisctcr = @cashregister 
					AND SMBAK.fiscbusinunit=@BusinessUnit
		) AS A)

                     UPDATE SM SET NRFISKALIZIM=@NRFISKALIZIM WHERE NRRENDOR=@ID and NRFISKALIZIM is null
		
		
		set @NRFISKALIZIM = convert(varchar(1000),@NRFISKALIZIM)


           SELECT S.KARTLLG,
		   S.PERSHKRIM,
		   S.NJESI,
		   SASI = ROUND(SASI,3),
		   CMIMBS = CONVERT(DECIMAL(18, 2), ROUND((S.CMIMM)*(1-CONVERT(FLOAT,@PERQZBR)/100)/(1+CONVERT(FLOAT,KT.PERQTVSH)/100),2)) ,
		   CMIMBSTVSH = CONVERT(DECIMAL(18, 2), (S.CMIMM)),
		   KT.PERQTVSH,
		   VLPATVSH = CONVERT(DECIMAL(18, 2), ROUND(VLERABS * (1-CONVERT(FLOAT,@PERQZBR)/100)/(1+CONVERT(FLOAT,KT.PERQTVSH)/100),2)) ,
		   VLPATVSHMV = CONVERT(DECIMAL(18, 2), KURS2 * ROUND(VLERABS * (1-CONVERT(FLOAT,@PERQZBR)/100)/(1+CONVERT(FLOAT,KT.PERQTVSH)/100),2)) ,
		   VLTVSH=CONVERT(DECIMAL(18, 2), ROUND((VLERABS*(1-CONVERT(FLOAT,@PERQZBR)/100))-ROUND(VLERABS * (1-CONVERT(FLOAT,@PERQZBR)/100)/(1+CONVERT(FLOAT,KT.PERQTVSH)/100),2),2) ),
		   VLTVSHMV=CONVERT(DECIMAL(18, 2), KURS2 *ROUND((VLERABS*(1-CONVERT(FLOAT,@PERQZBR)/100))-ROUND(VLERABS * (1-CONVERT(FLOAT,@PERQZBR)/100)/(1+CONVERT(FLOAT,KT.PERQTVSH)/100),2),2)),
		   VLERABS=CONVERT(DECIMAL(18, 2), ROUND((VLERABS*(1-CONVERT(FLOAT,@PERQZBR)/100)),2)),
		   CASE WHEN isnull(S.APLTVSH,1) = 1 THEN 'true' ELSE 'false' END AS APLTVSH,
		   CASE WHEN S.APLINVESTIM = 1 THEN 'true' ELSE 'false' END AS APLINVESTIM,
		   VLPATVSHTAXFREEAMOUNT=ROUND((CASE WHEN S.VLTVSH=0 AND ISNULL(KLASETVSH,'')<>'SEXP' 
										  AND KODTVSHFIC in ('TAX_FREE','TAX-FREE')
										THEN CONVERT(DECIMAL(18, 2), ROUND(VLERABS * (1-CONVERT(FLOAT,@PERQZBR)/100)/(1+CONVERT(FLOAT,KT.PERQTVSH)/100),2)) ELSE 0 END)*KURS2,2),
		   kmon,
		   kurs2,
		   f.TIMED,
		   vlertot,
		   RELATEDFIC,
		   f.nrrendor,
		   F.kodfkl,
		   isfj,
		   PERQZBR,
		   NRDOK=@NRFISKALIZIM,
		   KARTE,
		   KODTVSHEIC,
		   KODTVSHFIC,
		   U.DKLCASH,
		   U.ARKASOT,
		   U.DTHAPJE

	INTO #FJSCR 
	FROM SM F
	INNER JOIN SMSCR S ON F.NRRENDOR = S.NRD
	INNER JOIN ARTIKUJ A ON A.KOD = S.KARTLLG
	INNER JOIN KLASATVSH KT ON KT.KOD = A.KODTVSH
	INNER JOIN DRH..USERS U ON U.DRN=F.KASE
	WHERE S.NRD = @Id;

	declare @tipnipt as varchar(50)
	select top 1 @tipnipt = tipnipt from SM WHERE nrrendor= @Id

	declare @kurs2 as float
	select @kurs2 = kurs2 from sm where nrrendor = @id

	--select KURS2 ,* from sm
	--select 	
	
	--FROM SM F
	--INNER JOIN DRH..USERS U ON U.DRN=F.KASE
	--WHERE S.NRD = @Id;


	DECLARE @dklcash int, @dailycashamt float,@dthapje as datetime,@IICBLANC AS VARCHAR(MAX)
	Declare @Nr as varchar(10)
		SELECT @DATE		= dbo.DATE_1601(MIN(TIMED)),		--> kujdes data duhet edhe me pjesen e ORE-s
		@DATECREATE = MIN(timed),
		   @Nr			= CONVERT(VARCHAR(10), CONVERT(BIGINT, MIN(@NRFISKALIZIM))),
		   @Total		= CONVERT(VARCHAR(20), (CONVERT(DECIMAL(18, 2), SUM((VLPATVSH+VLTVSH)*@kurs2)))),
		   @PerqZbr		= ISNULL(MIN(PERQZBR), 0),
		   @dklcash =		max( convert(int,DKLCASH)),
		   @dthapje =		max(dthapje),
		   @dailycashamt =	max(arkasot),
		   @IicBlank	=	@VatRegistrationNo+
							+ '|' + dbo.DATE_1601(MIN(TIMED)) 
							+ '|' + CONVERT(VARCHAR(MAX), CONVERT(BIGINT, MIN(@NRFISKALIZIM)))
							+ '|' + @BusinessUnit 
							+ '|' + @CashRegister 
							+ '|' + @SoftNum 
							+ '|' + CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(10,2), SUM((VLPATVSH+VLTVSH)*@kurs2))),
			@IicBlanC	=	@VatRegistrationNo
							+ '|' + dbo.DATE_1601(MIN(TIMED)) 
							+ '|' + CONVERT(VARCHAR(MAX), CONVERT(BIGINT, MIN(@NRFISKALIZIM)))
							+ '|' + @BusinessUnit 
							+ '|' + @CashRegister 
							+ '|' + @SoftNum 
							+ '|' + CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(10,2), SUM((VLPATVSH+VLTVSH)*@kurs2)))

	FROM #FJSCR
	WHERE NRRENDOR = @id;

	if isnull(@dklcash,0) = 0 and @dthapje>=convert(datetime,floor(convert(float,getdate())))
     begin
	---print convert(varchar(100),@dklcash
	
	--select 'hyri deklarim'
	create table #tmp(kol1 varchar(8000),kol2 varchar(8000),kol3 varchar(8000),kol4 xml,kol5 varchar(8000))

	insert into #tmp EXEC DBO._FiscalCreateCashXmlPos 'INITIAL',@dailycashamt,@CashRegister

end

	
	declare @fisccert as varbinary(max),@iscash as bit,@isfj as bit, @subseq bit, @UUID AS UNIQUEIDENTIFIER
	
	select top 1 @fisccert = fisccertificate from CONFND
	select @UUID = UUID, @iscash = isnull(iscash,1),@isfj= isnull(ISFJ,0) from sm where nrrendor = @id
	--eshte shtuar e re
	if(select top 1 isnull(iic,'') from sm where nrrendor = @Id)=''
	begin

		EXEC _FiscalGenerateHash @IICBLANK, @CertificatePath, @CertificatePassword,@fisccert, @IIC OUTPUT, @IICSIGNATURE OUTPUT, @ERROR OUTPUT, @ERRORtext OUTPUT;


		

	    
		update sm set	
					IIC= @Iic,
					iicsig       = @IicSignature ,
					UUID         = @UUID,
					NRFISKALIZIM = @NRFISKALIZIM ,--ALBAN
					@subseq      = 0 --eshte shtuar e re
		where nrrendor = @Id

	end
	else
	begin
		select	@Iic=iic,
				@IicSignature = iicsig,
				@UUID = uuid,
				@NRFISKALIZIM=NRFISKALIZIM,
				@subseq = 1
		from sm where NRRENDOR=@Id
	end
		--fund
	declare @SENDDATETIME varchar(100)
	SET @SENDDATETIME		= dbo.DATE_1601(getdate())
	declare @TIPFISKAL as varchar(50)

	

	select @TIPFISKAL = CASE WHEN  isnull(kodfiskal,'')='' THEN 'FRE'  ELSE  kodfiskal END from CONFND

		SET @XML  = (
					SELECT 
							CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 THEN @SENDDATETIME ELSE @DATE END AS 'Header/@SendDateTime',  -- MANDATORY: 
							
							--eshte shtuar e re
							CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>60 or @subseq=1 then 'NOINTERNET' else null end  AS 'Header/@SubseqDelivType',	-- MANDATORY:  Duhet shtuar ne fature [NOINTERNET, BOUNDBOOK, SERVICE, TECHNICALERROR]
																						   -- NOINTERNET When TCR operates in the area where there is no Internet available. 
																						   -- BOUNDBOOK When TCR is not working and message cannot be created with TCR. 
																						   -- SERVICE When there is an issue with the fiscalization service that blocks fiscalization. 
																						   -- TECHNICALERROR When there is a temporary technical error at TCR side that prevents successful fiscalization
							--DUHET SHTUAR SUBSEQUENTDELIVERYTYPE
							@UUID AS 'Header/@UUID',			 -- MANDATORY: Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
				
				(
						SELECT 
								CASE WHEN ISNULL(@iscash,1) = 1 THEN 'CASH' ELSE 'NONCASH' END AS '@TypeOfInv' -- MANDATORY: 
								,null AS '@TypeOfSelfIss'    -- OPTIONAL:  [AGREEMENT - The previous agreement between the parties., DOMESTIC - Purchase from domestic farmers., ABROAD - Purchase of services from abroad., SELF - Self-consumption., OTHER - Other] 
							   --,'false' AS '@IsSimplifiedInv'							-- MANDATORY:
							   ,CASE WHEN @TIPFISKAL='VAT' THEN 'false' else 'true' end AS '@IsSimplifiedInv'
							   ,@DATE AS '@IssueDateTime'			-- MANDATORY: 
			/*ALBAN*/		   ,CONVERT (VARCHAR(50),@NRFISKALIZIM) + '/' + CONVERT(VARCHAR(4), YEAR(@DATECREATE)) + CASE WHEN isnull(@iscash,1) = 1 THEN + '/' + @CashRegister ELSE '' END AS '@InvNum'	-- MANDATORY: NQS CASH PERNDRYSHE BEJE BOSH @CashRegister -- > NrRendor vjetor qe fillon nga 1 ne fillim vit
																														/*
																														A. NUMERIC ORDINAL NUMBER OF INVOICE
																															AND CALENDER YEAR
																															Can contain only numbers 0-9, without leading 0.
																															(also field “InvOrdNum”)
																														B. CALENDER YEAR (YYYY)
																											
																														C. ECD CODE (also field “TCRCode”)
																															Unique ECD CODE that is registered in CIS
																														*/		
				/*ALBAN*/	   ,@NRFISKALIZIM	AS '@InvOrdNum'						
							   ,@CashRegister	AS '@TCRCode'							--Duhet shtuar ne magazina/fature -- nr i tcr
							   --,'true'			AS '@IsIssuerInVAT'						-- MANDATORY: 
							   ,CASE WHEN @TIPFISKAL='VAT' THEN 'true' else 'false' end	AS '@IsIssuerInVAT'
																						/*
																							Possible values:
																								1. Taxpayer is registered for VAT – 1
																								2. TAXPAYER is not registered for VAT – 2
																						*/
							   --,'0.00'			AS '@TaxFreeAmt'						-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged
							  -- ,CASE WHEN @TIPFISKAL='VAT' THEN CONVERT(DECIMAL(20, 2), 0) else CONVERT(DECIMAL(20, 2), S.VLERTOT) end	AS '@TaxFreeAmt'		
							   ,CASE WHEN (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHTAXFREEAMOUNT),2)) FROM #FJSCR)=0 THEN null 
										 else (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLPATVSHTAXFREEAMOUNT),2)) FROM #FJSCR) end AS '@TaxFreeAmt'						-- OPTIONAL: The total amount of goods and services delivered when VAT is not charged
							   ,NULL			AS '@MarkUpAmt'							-- OPTIONAL: Amount related to special procedure for margin scheme
							   --,NULL			AS '@GoodsExAmt'						-- OPTIONAL: Amount of goods for export from the Republic of Albania. 
							   ,null			AS '@GoodsExAmt'						-- OPTIONAL: Amount of goods for export from the Republic of Albania. 


                                                            ,CONVERT(DECIMAL(18, 2), CASE WHEN (select sum(VLERABS) from #fjscr)=0 THEN 0 else (select CONVERT(DECIMAL(18, 2), ROUND(SUM(VLPATVSHMV),2))from #fjscr) end)  AS '@TotPriceWoVAT'
							  -- ,CONVERT(DECIMAL(18, 2), CASE WHEN (select sum(VLERABS) from #fjscr)=0 THEN 0 ELSE (select sum(vlpatvsh) from #fjscr)*@kurs2 END)	AS '@TotPriceWoVAT'	-- MANDATORY: Total price of the invoice excluding VAT.
							   --,CASE WHEN @TIPFISKAL='VAT' then CONVERT(DECIMAL(18, 2), CASE WHEN (select sum(VLERABS) from #fjscr)=0 THEN 0 ELSE (select sum(VLTVSH) from #fjscr)*@kurs2 END) else null end		AS '@TotVATAmt'		-- MANDATORY: Total VAT amount of the invoice. 
							    ,CASE WHEN KLASETVSH='SEXP' THEN NULL
										 WHEN @TIPFISKAL='VAT' AND (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLTVSHMV),2)) FROM #FJSCR)<>0 THEN (SELECT CONVERT(DECIMAL(20, 2),ROUND(SUM(VLTVSHMV),2)) FROM #FJSCR)  
										 ELSE NULL end		AS '@TotVATAmt'
							   ,CONVERT(DECIMAL(18, 2), (select sum(vlpatvsh+vltvsh)*@kurs2 from #fjscr))	AS '@TotPrice'		-- MANDATORY: Total price of all items including taxes and discounts.
							   ,@OperatorCode	AS '@OperatorCode'						-- MANDATORY: Reference to the operator code, who is operating on TCR and issues invoices.
							   ,@BusinessUnit	AS '@BusinUnitCode'						-- MANDATORY: Business unit (premise) code. Duhet shtuar tek magazina, apo duhet shtuar ne fature? faturat vetem sherbim?				   
							   ,@SoftNum		AS '@SoftCode'							-- MANDATORY: Software code.
							   ,NULL			AS '@ImpCustDecNum'						-- OPTIONAL: Import customs declaration number. Only for internal usage. Must not be populated by a TCR.
							   ,@Iic			AS '@IIC'								-- MANDATORY: Duhet shtuar ne fature, Nr unik i cili behet me concat
							   ,@IicSignature	AS '@IICSignature'						-- MANDATORY: Shenjimi i iic
							   ,'false'			AS '@IsReverseCharge'					-- MANDATORY: If true, the buyer is obliged to pay the VAT.	
							   ,NULL			AS '@PayDeadline'						-- OPTIONAL:  Last day for payment.		--> MANDATORY IF NON CASH
							   ,case when isnull(@iscash,1) = 0 AND @isfj = 1 and @tipnipt = 'NUIS' then 'true' else 'false' end		AS '@IsEinvoice'
							   ,
							  
								CASE WHEN EXISTS(SELECT 1 FROM SM WHERE ISNULL(RELATEDFIC,'')<>'' AND NRRENDOR = @Id ) THEN
								(
									SELECT TOP 1 N.RELATEDFIC AS  '@IICRef',				-- IIC reference on the original invoice.
							 				dbo.DATE_1601(N.RELATEDTIMED) AS '@IssueDateTime',		-- Date and time the original invoice is created and issued at TCR.
											'CREDIT' AS '@Type'				-- Type of the corrective invoice.
									FROM SM N WHERE N.RELATEDFIC = S.RELATEDFIC
									FOR XML PATH ('CorrectiveInv'), TYPE
								) ELSE NULL END
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
									SELECT CONVERT(DECIMAL(18, 2), ROUND(((SELECT SUM(VLPATVSH+VLTVSH) FROM #FJSCR)*@kurs2),2)) AS 'PayMethod/@Amt',
									case when isnull(@iscash,1)=1 then 'BANKNOTE' else 'ACCOUNT' end AS 'PayMethod/@Type',
										   NULL AS 'PayMethod/@CompCard',				-- Amount payed by payment method in the ALL.
										   (
											SELECT NULL AS 'Voucher/@Num'				--Voucher serial number
											WHERE 1=2				
											FOR XML PATH (''), TYPE
										   ) Vouchers									-- XML element that contains list of voucher numbers if the payment method is voucher.
									FOR XML PATH (''), TYPE	
								 ) PayMethods												--> MENYRA E PAGESES, PER CDO MENYRE PAGESE 
																						-- [BANKNOTE, CARD, CHECK, SVOUCHER, COMPANY, ORDER   , ACCOUNT , FACTORING, COMPENSATION, TRANSFER, WAIVER  , KIND     , OTHER   ]
																						-- [ CASH   , CASH, CASH ,  CASH   , CASH   , NON CASH, NON CASH, NON CASH ,     NON CASH, NON CASH, NON CASH, NON CASH , NON CASH]
								,
																						-- OPTIONAL:  
								(
									SELECT	KMON AS 'Currency/@Code',					--Currency code in which the amount on the invoice should be paid, if different from ALL.
											KURS2 AS 'Currency/@ExRate',				--Exchange rate applied to calculate the equivalent amount of foreign currency for the total amount expressed in ALL. Exchange rate express equivalent amount of ALL for 1 unit of foreign currency.
											NULL AS 'Currency/@IsBuying'				--True if exchange transaction is buying of the foreign currency. False if exchange transaction is selling of the foreign currency.
									WHERE KMON NOT IN ('', 'ALL')						
									FOR XML PATH (''), TYPE	
								  )														--XML element representing currency in which the amount on the invoice should be paid, if different from ALL
							   ,(	--nga config -- SELECT * FROM CONFND
									SELECT PERSHKRIM AS 'Seller/@Name',					-- MANDATORY: 
										   NIPT		 AS 'Seller/@IDNum',				-- MANDATORY:	
										   'NUIS'    AS 'Seller/@IDType',				 -- MANDATORY:	FIX
										   ISNULL(SHENIM1,'') AS 'Seller/@Address', -- MANDATORY FOR FOREIGNER:	FUSHA PER ADRESEN
										   ISNULL(SHENIM2,'Tirane')	 AS 'Seller/@Town',					 -- MANDATORY FOR FOREIGNER:    QYTETI
										   'ALB'     AS 'Seller/@Country'				 -- MANDATORY FOR FOREIGNER:    SHTETI
									FROM CONFND
									
									FOR XML PATH (''), TYPE
								) ,
								(	--nga klienti
									SELECT	REPLACE(s.SHENIM1, '"', '')  AS 'Buyer/@Name',		-- OPTIONAL| MANDATORY B2B: 
											s.NIPT						 AS 'Buyer/@IDNum',		-- OPTIONAL| MANDATORY B2B: 
																								/* This field is filled out if buyer is:
																										 a taxpayer of profit tax or a taxpayer of simplified profit tax for small businesses or a taxpayer who is subject to VAT in accordance with special regulations, or
																										 a legal entity to whom goods or services are provided in the territory of the Republic of Albania for the purpose of carrying out his economic activity; or
																										 if personal property of a single value is sold above 500,000 ALL;
																										 or in other cases when the buyer asks for this data to be entered into the invoice, but there is no control in that case. Also, this field is mandatory if the buyer issues the
																										invoice instead of the seller. If this field is entered, beside in the book of sales of the seller, this invoice will also appear in the book of purchase of the buyer if the buyer is a taxpayer.
																										If the buyer is an individual who requires invoice for recognition of the cost of the medication, no book of purchase will be created for him, but a special application will be created to register all the data on
																										all invoices where he has appeared as a buyer and that information will be exchanged with the CIS system. Also, data may be entered for a foreigner or diplomat who will request a VAT refund and this information will be exchanged with the CIS system as well.
																								*/
											TIPNIPT	 AS 'Buyer/@IDType',	-- OPTIONAL| MANDATORY B2B: 
																								-- NQS ESHTE PERSON FIZIK DUHET SPECIFIKUAR --> NDARES PER PERSON FIZIK APO SUBJEKT -- [NUIS: NUIS-number | ID: Personal ID-number | PASS: Passport-number | VAT: VAT-number | TAX: TAX-number ]
																						
											ISNULL(s.SHENIM2, c.ADRESA2)			 AS 'Buyer/@Address',	-- OPTIONAL| MANDATORY IF NAME IS FILLED: 
											ISNULL(s.SHENIM2, c.ADRESA2)			 AS 'Buyer/@Town',		-- OPTIONAL| MANDATORY IF NAME IS FILLED: 
											ISNULL(LEFT(S.COUNTRY, 3), 'ALB') AS 'Buyer/@Country'	-- OPTIONAL| MANDATORY IF NAME IS FILLED: 	
									FROM KLIENT C 
									WHERE C.KOD = S.KODFKL
									AND ISNULL(S.NIPT, '') != ''
									FOR XML PATH (''), TYPE
								)
								,
									(	SELECT  KARTLLG AS 'I/@C',								-- OPTIONAL:  Code of the item from the barcode or similar representation
											LEFT(PERSHKRIM, 50) AS 'I/@N',						-- MANDATORY: Name of the item (goods or services).
											--CONVERT(DECIMAL(18, 2), VLPATVSH) AS 'I/@PA',		-- MANDATORY: Total price of goods after the tax and applying discounts Negative values allowed when CorrectiveInv or BadDebtInv exist.
											CONVERT(DECIMAL(18, 2), ROUND(VLERABS*@kurs2,2)) AS 'I/@PA',		-- MANDATORY: Total price of goods after the tax and applying discounts Negative values allowed when CorrectiveInv or BadDebtInv exist.
											CONVERT(DECIMAL(18, 2), ROUND(VLPATVSH*@kurs2,2)) AS 'I/@PB',		-- MANDATORY: Total price of goods and services before the tax Negative values allowed when CorrectiveInv or BadDebtInv exist.
											CONVERT(DECIMAL(18, 3), SASI) AS 'I/@Q',			-- MANDATORY: Amount or number (quantity) of items. Negative values allowed when CorrectiveInv or BadDebtInv exist.
											CONVERT(DECIMAL(18, 2), 0) AS 'I/@R',				-- OPTIONAL:  Percentage of the rebate.	
											'true' AS 'I/@RR',									-- OPTIONAL:  Is rebate reducing tax base amount?
											NJESI AS 'I/@U',									-- MANDATORY: What is the item’s unit of measure (piece, weight measure, length measure, etc.)
											CONVERT(DECIMAL(18, 2), ROUND(CMIMBS*@kurs2,2)) AS 'I/@UPB',		-- MANDATORY: Unit price before Value added tax is applied
											--CONVERT(DECIMAL(18, 2), CMIMBS) AS 'I/@UPA',		-- MANDATORY: Unit price after Value added tax is applied
											CONVERT(DECIMAL(18, 2), ROUND(S.KURS2*VLERABS/SASI,2)) AS 'I/@UPA',
								
											-- nuk duhet APLTVSH
											--case when  KODTVSHFIC = 'VAT' THEN NULL ELSE KODTVSHFIC END  AS 'I/@EX',
											CASE WHEN ISNULL(KLASETVSH,'')='SEXP' THEN 'EXPORT_OF_GOODS' 
												  WHEN @TIPFISKAL='FRE' THEN 'TAX_FREE' 
												  WHEN ISNULL(KODTVSHFIC,'') IN ('TYPE_1','TYPE_2','MARGIN_SCHEME') THEN ISNULL(KODTVSHFIC,'')
												  WHEN ISNULL(KODTVSHFIC,'')='VAT' THEN NULL
												  ELSE ISNULL(KODTVSHFIC,'') END AS 'I/@EX',
																																			-- Exempt from VAT.
																																			-- TYPE_1 Exempt type 1. Exempted on the basis of Article 51 of the VAT law 
																																			-- TYPE_2 Exempt type 2. Exempted on the basis of Articles 53 and 54 of the VAT law 
																																			-- TAX_FREE Tax free amount. Sales without VAT that is exempted based on VAT law other then articles 51, 53 and 54 of VAT law, and is not margin scheme nor export of goods 
																																			-- MARGIN_SCHEME Margin scheme (Travel agents VAT scheme, second hand goods VAT scheme, works of art VAT scheme, collectors’ items and antiques VAT scheme etc.). 
																																			-- EXPORT_OF_GOODS Export of goods. No VAT.
																					

											--APLINVESTIM AS 'I/@IN',								-- If true, the item is investment for the buyer. Mandatory only for importation of goods.
											NULL AS 'I/@IN',
											--CASE WHEN @TIPFISKAL='FRE' THEN NULL ELSE CONVERT(DECIMAL(18, 2), C.VLTVSH*@kurs2) END AS 'I/@VA',		-- MANDATORY: Amount of value added tax for goods and services. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true. Negative values allowed when CorrectiveInv or BadDebtInv exist.
											--CASE WHEN @TIPFISKAL='FRE' THEN NULL ELSE CONVERT(DECIMAL(18, 2), PERQTVSH) END AS 'I/@VR',		-- MANDATORY: Rate of value added tax. Must not exists if IsIssuerInVAT equals false and is not reverse charge or self-invoice. Mandatory if IsReverseCharge equals true.

											CASE WHEN (KODTVSHFIC<>'VAT' OR ISNULL(@TIPFISKAL,'')<>'VAT' OR ISNULL(KLASETVSH,'')='SEXP') 
														THEN NULL ELSE  CONVERT(DECIMAL(18, 2), ROUND(VLTVSHMV,2)) END  AS 'I/@VA',

											CASE WHEN (KODTVSHFIC<>'VAT' OR ISNULL(@TIPFISKAL,'')<>'VAT' OR ISNULL(KLASETVSH,'')='SEXP') 
														THEN NULL ELSE  CONVERT(DECIMAL(18, 2), PERQTVSH) END AS 'I/@VR',
								
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
												CASE WHEN KODTVSHFIC NOT IN ('TYPE_1','TYPE_2') 
													 THEN CONVERT(DECIMAL(18, 2), PERQTVSH) ELSE NULL END AS 'SameTax/@VATRate',
												CASE WHEN KODTVSHFIC IN ('TYPE_1','TYPE_2') 
													 THEN KODTVSHFIC ELSE NULL END						  AS 'SameTax/@ExemptFromVAT',
												--APLTVSH												  AS 'SameTax/@ExemptFromVAT',		-- nuk duhet APLTVSH
																											-- Exempt from VAT.
																											-- TYPE_1 Exempt type 1. Exempted on the basis of Article 51 of the VAT law 
																											-- TYPE_2 Exempt type 2. Exempted on the basis of Articles 53 and 54 of the VAT law 
												CASE WHEN KODTVSHFIC NOT IN ('TYPE_1','TYPE_2')
												THEN CONVERT(DECIMAL(18, 2), ROUND(SUM(VLTVSHMV),2)) ELSE NULL END
												AS 'SameTax/@VATAmt'
										FROM #FJSCR
										--WHERE @TIPFISKAL='VAT' AND (PERQTVSH<>0 OR EXTVSHFIC IN ('TYPE_1','TYPE_2'))
										WHERE @TIPFISKAL='VAT' AND ISNULL(KODTVSHFIC,'') not in ('MARGIN_SCHEME','TAX_FREE')
										GROUP BY PERQTVSH, KODTVSHFIC
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
					FROM sm  S
					WHERE S.NRRENDOR = @Id
					FOR XML PATH('Invoice'), TYPE
				)
				FOR XML PATH('RegisterInvoiceRequest')); 

			--SELECT @XML
    
				--Gjenerimi i url per kontrollin e fiskalizimit te fatures



    
	--Gjenerimi i url per kontrollin e fiskalizimit te fatures
	SET @QrCodeLink = 'https://efiskalizimi-app.tatime.gov.al/invoice-check/#/verify?' 
					+ 'iic='	+ @Iic
					+ '&tin='	+ @VatRegistrationNo
					+ '&crtd='	+ @Date
					+ '&ord='   + CONVERT (VARCHAR(50),@NRFISKALIZIM) --+ '/' + CONVERT(VARCHAR(4), YEAR(@DATECREATE)) + CASE WHEN @iscash = 1 THEN + '/' + @CashRegister ELSE '' END --ALBAN
					+ '&bu='    + @BusinessUnit				
					+ '&cr='    + @CashRegister
					+ '&sw='    + @SoftNum
					+ '&prc='   + @Total;  
		
	SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterInvoiceRequest>','<RegisterInvoiceRequest xmlns="' + @Schema +'" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3">') AS XML)

	SELECT @XML = CAST(@XML AS VARCHAR(MAX))  

END




GO
