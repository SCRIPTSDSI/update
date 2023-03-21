SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--SELECT * FROM FH
----[_FiscalCreateTransferXml] 1
CREATE PROC [dbo].[Isd_FiscalWTN]
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

				UPDATE FD SET DATECREATE=getdate() where NRRENDOR=@NrRendor;

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
				SET @VLERAFD=((SELECT SUM(SASI*B.CMSH) FROM FDSCR A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD WHERE NRD=@NrRendor))
				--SET @DATECREATE=(SELECT DATECREATE FROM FD WHERE NRRENDOR=@NrRendor)
				--SET @STARTPOINT=(SELECT CASE WHEN ISNULL(ISDOGANE,0)=0 THEN 'WAREHOUSE' ELSE 'WAREHOUSE' END FROM MAGAZINA A INNER JOIN FD B ON A.KOD=B.KMAG WHERE B.NRRENDOR=@NrRendor)
				--SET @DESTINPOINT=(SELECT CASE WHEN ISNULL(ISDOGANE,0)=0 THEN 'WAREHOUSE' ELSE 'WAREHOUSE' END FROM MAGAZINA A INNER JOIN FD B ON A.KOD=B.KMAGRF WHERE B.NRRENDOR=@NrRendor)
				--SET @StartAddr=(SELECT ISNULL(A.SHENIM1,'Adresa nga po niset malli') FROM MAGAZINA A INNER JOIN FD B ON A.KOD=B.KMAG WHERE B.NRRENDOR=@NrRendor)
				--SET @StartCity=(SELECT ISNULL(A.SHENIM2,'Qyteti nga po niset malli') FROM MAGAZINA A INNER JOIN FD B ON A.KOD=B.KMAG WHERE B.NRRENDOR=@NrRendor)
    --            SET @DestinAddr=(SELECT ISNULL(A.SHENIM1,'Adresa destinacion') FROM MAGAZINA A INNER JOIN FD B ON A.KOD=B.KMAGRF WHERE B.NRRENDOR=@NrRendor)
				--SET @DestinCity=(SELECT ISNULL(A.SHENIM2,'Qyteti destinacion') FROM MAGAZINA A INNER JOIN FD B ON A.KOD=B.KMAGRF WHERE B.NRRENDOR=@NrRendor)
                SELECT TOP 1 @DATECREATE=A.DATECREATE,
					   @STARTPOINT=ISNULL(B.STARTPOINT,'WAREHOUSE'),
					   @DESTINPOINT=ISNULL(B.DESTINPOINT,'WAREHOUSE'),
					   @StartAddr=ISNULL(B.SHENIM1,'Adresa nga po niset malli'),
					   @StartCity=ISNULL(B.SHENIM3,'Qyteti nga po niset malli'),
					   @DestinAddr=ISNULL(B.DESTINSHENIM1,'Adresa destinacion'),
					   @DestinCity=ISNULL(B.DESTINSHENIM3,'Qyteti destinacion'),
					   @IsGoodsFlammable=case when isnull(GoodsFlammable,0)=0 then 'false' else 'true' end,
					   @IsEscortRequired=case when isnull(EscortRequired,0)=0 then 'false' else 'true' end,
					   @ItemsNum=(select nr=count('') from (SELECT nr=COUNT('1') FROM FDSCR WHERE NRD=@NrRendor GROUP BY KARTLLG) as a),
					   @PackType=B.PackType,
					   @PackNum=B.PackNum,
					   @VehPlates=B.TARGE,
					   @VehOwnership=B.VehOwner,
					   @StartDateTime=dbo.DATE_1601(B.[DATE]+B.[TIME]),
					   @DestinDateTime=dbo.DATE_1601(B.DestinDate+B.DestinTime),
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
	   + CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(18,2), ROUND(@VLERAFD,2)))
       FROM FD WHERE NRRENDOR = @NrRendor

	   --PRINT @IICBLANC
      

	   EXEC _FiscalGenerateHash @IICBLANC, @CertificatePath, @CertificatePwd, @Certificate, @IIC OUTPUT, @IICSIGNATURE OUTPUT, @ERROR OUTPUT, @ERRORtext OUTPUT;
   

--SELECT @IIC, @IICSIGNATURE, @ERROR,@CertificatePath, @CertificatePwd, @Certificate
SET @XML  = (
SELECT 
              dbo.DATE_1601(@DATECREATE) AS 'Header/@SendDateTime',
              CASE WHEN abs(DATEDIFF(minute,getdate(),@DATECREATE))>1 then 'NOINTERNET' else null END AS 'Header/@SubseqDelivType',
              NEWID() AS 'Header/@UUID',                                                 --Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
(
       SELECT @BusinessUnit                     AS '@BusinUnitCode'        --Duhet shtuar tek magazina, apo duhet shtuar ne FD?
                 ,dbo.DATE_1601(GETDATE())      AS '@IssueDateTime'
                 ,@IIC                                        AS '@WTNIC'                       --Duhet shtuar ne dokument
                 ,@IICSIGNATURE                        AS '@WTNICSignature' --Duhet shtuar ne dokument
                                                                                                              --kthim
                 --,'false'                                     AS '@IsAfterDel'           --Duhet shtuar ne dokument
                 ,@IsGoodsFlammable                                     AS '@IsGoodsFlammable'     --Duhet shtuar ne dokument
                 ,@IsEscortRequired                                    AS '@IsEscortRequired'     --Duhet shtuar ne dokument
				 ,@ItemsNum				AS '@ItemsNum'
				 ,@PackType		AS '@PackType'
				 ,@PackNum				AS '@PackNum'
                 ,@OperatorCode                        AS '@OperatorCode'         --Duhet shtuar ne user ->       
                 ,@SoftNum                             AS '@SoftCode'
                 --,CASE WHEN ISNULL(DST,'')='FU' THEN 'SALE' ELSE 'WTN' END                                      AS '@Type'                        --warehouse transfer
				 ,@FISTIPDOK AS '@Type'                        --warehouse transfer
                 --,'OTHER'                                     AS '@GroupOfGoods'
				 --,CONVERT(DECIMAL(34,2),(select sum(vleram) from fDscr where nrd=s.NRRENDOR)) as '@ValueOfGoods'
				 ,CONVERT(DECIMAL(34,2),@VLERAFD) as '@ValueOfGoods'
                 --,CASE WHEN ISNULL(DST,'')='FU' THEN 'DOOR' ELSE 'TRANSFER' END      AS '@Transaction'          --> TIPI I TRANSFERTES
				 ,@FISPROCES      AS '@Transaction'          --> TIPI I TRANSFERTES
                 , CONVERT(VARCHAR(40), ISNULL(NRFISKALIZIM, 1)) +'/'+ CONVERT(VARCHAR(4), YEAR([DATEDOK]))                     AS '@WTNNum'                                    
                 , CONVERT(VARCHAR(40), ISNULL(NRFISKALIZIM, 1)) AS '@WTNOrdNum'                                    
                 ,@VehPlates   AS '@VehPlates'                   --
                 ,@VehOwnership AS '@VehOwnership'         -- == THIRDPARTY DUHET SPECIFIKUAR CARRIER
                 ,@STARTPOINT                                 AS '@StartPoint'           --
                 ,@DESTINPOINT                                AS '@DestinPoint'          --
                 ,isnull(@StartDateTime,dbo.DATE_1601(S.DATECREATE))             AS '@StartDateTime'
                 ,isnull(@DestinDateTime,dbo.DATE_1601(S.DATECREATE))             AS '@DestinDateTime'
                 ,@StartAddr                         AS '@StartAddr'                   --
                 ,@StartCity                          AS '@StartCity'                   --
                 ,@DestinAddr                        AS '@DestinAddr'           -- ADRESA MAG BURIM
                 ,@DestinCity                            AS '@DestinCity'           -- ADRESA MAG DESTINACION
          ,(  --nga config
                     SELECT		  PERSHKRIM                 AS 'Issuer/@Name',                
                                  NIPT                       AS 'Issuer/@NUIS',
                                  SHENIM2                               AS 'Issuer/@Town',
                                  SHENIM1                           AS 'Issuer/@Address'
                     FROM CONFND
                     FOR XML PATH (''), TYPE
              ) ,
              (      --nga klienti
                    SELECT  REPLACE(SHENIM1, '"', '') AS 'Carrier/@Address',
                                  NIPT                                            AS 'Carrier/@IDNum',
								  IDType										  AS 'Carrier/@IDType',
                                  TRANSPORTUES                                    AS 'Carrier/@Name',
                                  SHENIM2                                     AS 'Carrier/@Town'
                                 
                     FROM MGSHOQERUES WHERE MGSHOQERUES.NRD=@NrRendor
					-- and ISNULL(SHENIM3,'OWNER')='THIRDPARTY'
                     FOR XML PATH (''), TYPE
              ),
              (      SELECT C.KARTLLG AS 'I/@C',
                                  LEFT(C.PERSHKRIM, 50) AS 'I/@N',
                                  CONVERT(DECIMAL(18, 2), C.SASI) AS 'I/@Q',
                                  NJESI AS 'I/@U'                                 
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
