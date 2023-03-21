SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[__eInvoiceGetRequestStatusFf]
 	@Eic			  NVARCHAR(100)	=	 '',
	@PartyType		  VARCHAR(10)	=	 'BUYER', -- SELLER, BUYER
	--@RecDateTimeFrom  DATETIME		=	 '',
	--@RecDateTimeTo    DATETIME		=	 '',
	@RecDateTimeFrom  VARCHAR(20),
	@RecDateTimeTo    VARCHAR(20),
	@Nrrendor		  INT,
	@pTableTmp        VARCHAR(40),
	@pStatus          VARCHAR(100),      -- 'ACCEPTED,REFUSED,DELIVERED'
	@Output3          VARCHAR(MAX) OUTPUT

AS 
-- DECLARE @Output1 Varchar(MAX); EXEC dbo.__eInvoiceGetRequestStatusFF '','BUYER','09/06/2010','09/06/2021',0,'##TmpLogFisFF_64211481','DELIVERED',@Output1 Output; SELECT * FROM ##TmpLogFisFF_64211481 ORDER BY DATEDOK


BEGIN	
	     SET NOCOUNT ON;
BEGIN TRY

	DECLARE  @NIPT				VARCHAR(20)
			,@PerqZbr			FLOAT
			,@Date				VARCHAR(100)
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
			,@Xml				XML
			,@responseXml		XML
			,@SignedXml			VARCHAR(MAX)
			,@Error				NVARCHAR(MAX)
			,@ErrorText			NVARCHAR(MAX)
			,@hDoc				INT
			,@EICURL			VARCHAR(MAX)
			,@sTableTmp         VARCHAR(40)
			,@sStatus           VARCHAR(100)
			,@sWhereExt         VARCHAR(2000)
			,@sSql             nVARCHAR(MAX)
			,@DATEKP			   DATETIME
			,@DATEKS			   DATETIME ;

SET @DATEKP=CONVERT(DATETIME,@RecDateTimeFrom,104)
SET @DATEKS=CONVERT(DATETIME,@RecDateTimeTo,104)+1


	     SET @UniqueIdentif   = NEWID();
	     SET @sTableTmp       = @pTableTmp;
	     SET @sStatus         = LTRIM(RTRIM(ISNULL(@pStatus,'')));
		  IF @sStatus='*'
			 SET @sStatus='';



	  SELECT @NIPT	            = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCVATREGISTRATIONNO')
		    ,@SoftNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSOFTNUM')
			,@schema			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCSCHEMA')
		    ,@FiscUrL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'FISCURL')
			,@EICURL			= (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'EICURL')
		    ,@CertificatePath   = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPATH')
		    ,@CertificatePwd    = (SELECT TOP 1 ISNULL(VLERA,'') FROM FisConfig WHERE FUSHA = 'CERTPASS')		
			,@Certificate		= FiscCertificate
		FROM CONFND

	SET @XML  = (
	SELECT 
			dbo.DATE_1601(GETDATE()) AS 'Header/@SendDateTime',
			NEWID()				     AS 'Header/@UUID',							--Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
	(
		SELECT CASE WHEN @Eic = '' THEN NULL
					ELSE @Eic
					END	AS 'EIC'
			   , @PartyType						AS 'PartyType'		--Duhet shtuar ne magazina/fature
			   , CASE WHEN @Eic = '' THEN dbo.DATE_1601(@DATEKP)
									 ELSE NULL 
									 END AS 'RecDateTimeFrom'	
			   , CASE WHEN @Eic = '' THEN dbo.DATE_1601(@DATEKS)
									 ELSE NULL 
									 END AS 'RecDateTimeTo'
		FOR XML PATH(''), TYPE
	)
	FOR XML PATH('GetEinvoicesRequest'));

	SET @XML = CAST(REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<GetEinvoicesRequest>','<GetEinvoicesRequest xmlns="https://Einvoice.tatime.gov.al/EinvoiceService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="1">') AS XML)

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

	      IF OBJECT_ID('TEMPDB..#TMPGetReqFF') IS NOT NULL
	         DROP TABLE #TMPGetReqFF;

         SET @sSql = '
	      IF OBJECT_ID(''TEMPDB..'+@sTableTmp+''') IS NOT NULL
	         DROP TABLE '+@sTableTmp+';';

	   EXEC (@sSql);

	   

	IF(@Error = 0)
	BEGIN
		--RASTI KUR PO KERKON
		IF(@Eic = '')
		BEGIN

			EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="https://Einvoice.tatime.gov.al/EinvoiceService/schema" />';

			SELECT *
			INTO #TMPGetReqFF
			FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:GetEinvoicesResponse/ns2:Einvoices/ns2:Einvoice')
			WITH
			(
				[DocNumber]		NVARCHAR(50)	'@DocNumber',
				[Amount]		FLOAT			'@Amount',
				[DocType]		NVARCHAR(50)	'@DocType',
				[DueDateTime]	NVARCHAR(50)	'@DueDateTime',
				[EIC]		    NVARCHAR(50)	'@EIC',
				[PartyType]		NVARCHAR(50)	'@PartyType',
				[RecDateTime]	NVARCHAR(50)	'@RecDateTime',
				[Status]		NVARCHAR(50)	'@Status',
				[SellerTin]		NVARCHAR(50)	'@SellerTin'
			--  [BuyerTin]		NVARCHAR(50)	'@BuyerTin'
			);
			EXEC sp_xml_removedocument @hDoc;
			
		END		
		--ELSE 
		--BEGIN
		--	EXEC sp_xml_preparedocument @hDoc OUTPUT, @responseXML, '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="https://Einvoice.tatime.gov.al/EinvoiceService/schema" />';
			
		--	--DECLARE @pdf NVARCHAR(MAX);
		--	DECLARE @status NVARCHAR(MAX);

		--	--SELECT @pdf = Pdf
		--	--FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:GetEinvoicesResponse/ns2:Einvoices/ns2:Einvoice')
		--	--WITH
		--	--(
		--	--	Pdf NVARCHAR(MAX) 'ns2:Pdf'
		--	--);


		--	SELECT @status = Status
		--	FROM OPENXML(@hDoc, 'SOAP-ENV:Envelope/SOAP-ENV:Body/ns2:GetEinvoicesResponse/ns2:Einvoices/ns2:Einvoice')
		--	WITH
		--	(
		--		[Status]		NVARCHAR(50)	'@Status'
				
		--	);
			
		--	UPDATE FJ SET FISSTATUS=@status
		--	WHERE NRRENDOR = @Nrrendor;

		--	--SELECT LEN(@pdf), @pdf;

		--	--select @status

		--END
	END
	ELSE 
	SELECT @Error,@responseXml;
	--PRINT 'SELECT * INTO '+@sTableTmp+' FROM #TMPGetReqFF';
	

         SET @sWhereExt = '';
   


          IF OBJECT_ID('TempDB..#TMPGetReqFF') IS NOT NULL
	         BEGIN
			 
	           ALTER TABLE #TMPGetReqFF ADD TROW           BIT          NULL;
	           ALTER TABLE #TMPGetReqFF ADD NRRENDOR       INT          NULL;
	           ALTER TABLE #TMPGetReqFF ADD NRRENDORSTATUS INT          NULL;
	           ALTER TABLE #TMPGetReqFF ADD PERSHKRIM      VARCHAR(250) NULL;
	           ALTER TABLE #TMPGetReqFF ADD FISPDF         VARCHAR(MAX) NULL;

		       IF @sStatus<>'' 
		          BEGIN
			        SET @sStatus   = QuoteName(','+@sStatus+',','''');
		            SET @sWhereExt = ' WHERE CHARINDEX('',''+[Status]+'','','+@sStatus+')>0'
			      END;

               UPDATE A 
	              SET A.PERSHKRIM = B.PERSHKRIM
                 FROM #TMPGetReqFF A INNER JOIN FURNITOR B ON A.SellerTin=B.NIPT
	            WHERE ISNULL(B.NIPT,'')<>'';

               UPDATE A 
	              SET A.NRRENDORSTATUS = B.NRRENDOR,
				      A.FISPDF         = B.FISPDF
                 FROM #TMPGetReqFF A INNER JOIN FisStatusFF B ON A.EIC=B.FisEIC
	         -- WHERE ISNULL(B.NIPT,'')<>'';

	         END;
 
      /*  IF ISNULL((SELECT COUNT(1) FROM #TMPGetReqFF),0)=0 AND ISNULL(@Errortext,'''')<>''''    
		     BEGIN
			   INSERT INTO #TMPGetReqFF
			         ([DocNumber],[Amount],[DocType],[DueDateTime],[EIC],[PartyType],[RecDateTime],[Status],[SellerTin])     --  [BuyerTin]	NVARCHAR(50) '@BuyerTin'
			   SELECT NrDok     = '',
					  Vlera     = 0,			   
					  Tipi      = '',   
					  DateDok   = '',	
					  FisEIC    = '',-- QuoteName(@Errortext,''''),	 
					  PartyType = '',	
					  [RecDate] = '',
					  [Status]  = '',	   
					  SellerIn  = ''
	         END;*/

	     SET @sSql='
   -- SELECT *  INTO '+@sTableTmp+' FROM #TMPGetReqFF '+@sWhereExt+';
   	  
	  SELECT TRow            = CAST(0 AS BIT),
	         Nipt            = [SellerTin],
	         Pershkrim,
			 Status,
	         NrDok           = [DocNumber],
			 Vlera           = [Amount],
			 Tipi            = [DocType],
        	 DateDok         = [DueDateTime],
		     E_IC            = LEFT([EIC],200),
			 FisEIC          = [EIC],
			 PartyType,
			 DateReg         = RecDateTime,
		     TimeReg         = RecDateTime,
		--   DateDok         = Format(CONVERT(DATE,[DueDateTime]),''dd.MM.yyyy''),
		--   DateReg         = Format(CONVERT(DATE,[RecDateTime]),''dd.MM.yyyy''),
		--	 OreReg          = Format(CONVERT(DATETIME,[RecDateTime]),''hh:mm:ss''),
		--   MsgError,
			 NrRendor        = Row_Number() OVER(ORDER BY DueDateTime),
		     FieldsDisplMas  = ''Nipt,Pershkrim,Status,TRow,    NrDok,Vlera, Tip,    DateDok,E_IC,PartyType,DateReg,TimeReg'',
			 PromptsDisplMas = ''Nipt,Pershkrim,Status,Zgjedhur,NrDok,Vlefte,Tip dok,DateDok,E_IC,PartyType,DateReg,TimeReg'',
			 NrRendorStatus,
			 FisPDF
        INTO '+@sTableTmp+'
	    FROM #TMPGetReqFF
	   '      +@sWhereExt+'
	ORDER BY DueDateTime;
	' ;

/*
       --   IF ISNULL((SELECT COUNT(1) FROM #TMPGetReqFF),0)=0  AND  ISNULL(@Errortext,'''')<>''''
		  --   BEGIN
	      --     INSERT QuoteName(@Errortext,'''') 
	      --       INTO TMPGetReqFF
	      --           (EIC)
	      --     SELECT MsgError='+QUOTENAME(@Errortext,'''')+';
	      --   END;

*/

 --PRINT  @sSql;
    EXEC (@ssql);

	  SET @OUTPUT3=@Errortext

END TRY
BEGIN CATCH
	SET @OUTPUT3 = ERROR_MESSAGE()
END CATCH
END
GO
