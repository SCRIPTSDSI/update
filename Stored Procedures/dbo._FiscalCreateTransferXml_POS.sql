SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[_FiscalCreateTransferXml_POS]
       @Id INT

AS 
DECLARE     @VatRegistrationNo    VARCHAR(50)
                     ,@BusinessUnit             VARCHAR(50)
                     ,@SoftNum                  VARCHAR(50)
                     ,@ManufacNum         VARCHAR(50)
                     ,@XML                      XML
                     ,@FIC                      VARCHAR(1000)
                     ,@SIGNEDXML                VARCHAR(MAX)
                     ,@ERROR                           VARCHAR(1000)
                     ,@ERRORtext                VARCHAR(1000)
                     ,@schema                   VARCHAR(MAX)
                     ,@Url                      VARCHAR(MAX)
                     ,@CertificatePath     VARCHAR(MAX)
                     ,@certificatepassword VARCHAR(MAX)
                     ,@XMLSTRING         VARCHAR(MAX)
                     ,@QRCODELINK        VARCHAR(MAX)
                     ,@IIC                      varchar(max)
                     ,@IICSIGNATURE             varchar(max)
                     ,@operatorcode             varchar(50);

SELECT       @VatRegistrationNo          = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCVATREGISTRATIONNO')
                  ,@BusinessUnit                = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCBUSINESSUNIT')
                  ,@SoftNum                     = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCSOFTNUM')
                  ,@ManufacNum                  = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCMANUFACNUM')
                     ,@schema                          = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCSCHEMA')
                  ,@Url                                = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCURL')
                  ,@CertificatePath       = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'CERTPATH')
                  ,@certificatepassword   = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'CERTPASS');
                     
       DECLARE @IICBLANC AS VARCHAR(MAX)
       SELECT @IICBLANC = @VatRegistrationNo + '|' 
       + convert(varchar(max),nrdok)+ '|'
       + dbo.DATE_1601(DATECREATE) + '|' 
       + @BusinessUnit + '|'
       + @SoftNum 
       FROM FH WHERE NRRENDOR = @ID

       set @operatorcode = 'vh151ht889'
       --iicInput += "I12345678I"; // 
       --dateTimeCreated    iicInput += "|2019-06-12T17:05:43+02:00";       // 
       --invoiceNumber iicInput += "|9952"; // 
       --busiUnitCode iicInput += "|bb123bb123"; // 
       --tcrCode iicInput += "|cc123cc123"; // 
       --softCode iicInput += "|ss123ss123"; // 
       --totalPrice iicInput += "|99.01";


       EXEC _FiscalGenerateHash @IICBLANC, @CertificatePath, @CertificatePassword, @IIC OUTPUT, @IICSIGNATURE OUTPUT, @ERROR OUTPUT, @ERRORtext OUTPUT;

--SELECT @IIC, @IICSIGNATURE, @ERROR
SET @XML  = (
SELECT 
              dbo.DATE_1601(GETDATE()) AS 'Header/@SendDateTime',
              'false' AS 'Header/@IsSubseqDeliv',
              NEWID() AS 'Header/@UUID',                                                 --Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
(
       SELECT @BusinessUnit                     AS '@BusinUnitCode'        --Duhet shtuar tek magazina, apo duhet shtuar ne FD?
                 ,dbo.DATE_1601([DATEDOK])      AS '@IssueDateTime'
                 ,@IIC                                        AS '@WTNIC'                       --Duhet shtuar ne dokument
                 ,@IICSIGNATURE                        AS '@WTNICSignature' --Duhet shtuar ne dokument
                                                                                                              --kthim
                 ,'false'                                     AS '@IsAfterDel'           --Duhet shtuar ne dokument
                 ,'false'                                     AS '@IsGoodsFlammable'     --Duhet shtuar ne dokument
                 ,'false'                                     AS '@IsEscortRequired'     --Duhet shtuar ne dokument
                 ,@OperatorCode                        AS '@OperatorCode'         --Duhet shtuar ne user ->       
                 ,@SoftNum                             AS '@SoftCode'
                 ,'WTN'                                       AS '@Type'                        --warehouse transfer
                 ,'OTHER'                                     AS '@GroupOfGoods'
                 ,'TRANSFER'                                  AS '@Transaction'          --> TIPI I TRANSFERTES
                 , CONVERT(VARCHAR(4), ISNULL([NRDOK], 1)) +'/'+ CONVERT(VARCHAR(4), YEAR([DATEDOK]))                     AS '@WTNNum'                                    
                 , CONVERT(VARCHAR(4), ISNULL([NRDOK], 1)) AS '@WTNOrdNum'                                    
                 , ISNULL(M.TARGE, 'AA999XX')   AS '@VehPlates'                   --
                 ,'OWNER'                                     AS '@VehOwnership'         -- == THIRDPARTY DUHET SPECIFIKUAR CARRIER
                 ,'WAREHOUSE'                                 AS '@StartPoint'           --
                 ,'WAREHOUSE'                                 AS '@DestinPoint'          --
                 ,dbo.DATE_1601([DATEDOK])             AS '@StartDateTime'
                 ,dbo.DATE_1601([DATEDOK])             AS '@DestinDateTime'
                 ,'M Matohiti'                         AS '@StartAddr'                   --
                 ,'Tirane'                             AS '@StartCity'                   --
                 ,'M Matohiti'                         AS '@DestinAddr'           -- ADRESA MAG BURIM
                 ,'Tirane'                             AS '@DestinCity'           -- ADRESA MAG DESTINACION
          ,(  --nga config
                     SELECT  PERSHKRIM                 AS 'Issuer/@Name',                
                                  NIPT                       AS 'Issuer/@NUIS',
                                  ''                                AS 'Issuer/@Town',
                                  SHENIM1                           AS 'Issuer/@Address'
                     FROM CONFND
                     FOR XML PATH (''), TYPE
              ) ,
              (      --nga klienti
                     SELECT REPLACE(PERSHKRIM, '"', '') AS 'Buyer/@Name',
                                  NIPT                                            AS 'Buyer/@NUIS',
                                  ADRESA1                                                AS 'Buyer/@Address',
                                  VENDNDODHJE                                     AS 'Buyer/@Town',
                                  'AL'                                            AS 'Buyer/@Country'
                     FROM KLIENT C 
                     WHERE C.KOD = 'AAA' --->>
                     FOR XML PATH (''), TYPE
              ),
              (      SELECT C.KARTLLG AS 'I/@C',
                                  LEFT(C.PERSHKRIM, 50) AS 'I/@N',
                                  CONVERT(DECIMAL(18, 2), C.SASI) AS 'I/@Q',
                                  NJESI AS 'I/@U'                                 
                     FROM FHSCR C 
                     WHERE C.NRD = S.NRRENDOR
                     FOR XML PATH (''), TYPE
              ) Items
       FROM Fh S
       LEFT JOIN MGSHOQERUES M ON S.NRRENDOR = M.NRD
       WHERE S.NRRENDOR = @Id
       FOR XML PATH('WTN'), TYPE
)
FOR XML PATH('RegisterWTNRequest'));
SET @XML = CAST( REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterWTNRequest>',
'<RegisterWTNRequest xmlns="https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="2">') AS XML);

SET @XMLSTRING = CAST(@XML AS VARCHAR(MAX))

       EXEC _FiscalProcessRequest 
              @XMLSTRING,
              @certificatePath                  = @certificatePath, 
              @certificatepassword       = @certificatepassword, 
              @url                                     = @Url,
              @schema                                         = @schema,
              @returnValue                      = 'FWTNIC',                       --> VLERA QE KERKON TE MARRESH NGA DERGIMI I KERKESES
              @SIGNEDXML                               = @SIGNEDXML  OUTPUT, 
              @FIC                                     = @FIC               OUTPUT, 
              @ERROR                                   = @ERROR             OUTPUT, 
              @ERRORtext                               = @ERRORtext  OUTPUT
              
              declare @date as varchar(69),@OrderNumber as varchar(10),@total as varchar(50)
              SELECT @DATE         = dbo.DATE_1601(DATECREATE),
                 @OrderNumber = CONVERT(VARCHAR(10), nrdok),
                 @Total            = CONVERT(VARCHAR(20), (CONVERT(DECIMAL(18, 2), (select sum(sasi*cmimm) from fhscr where nrd = @id))))
       FROM fh
       WHERE NRRENDOR = @Id;

              SET @QrCodeLink = 'https://efiskalizimi-app-test.tatime.gov.al/invoice-check/#/verify?' 
                                  + 'FWTNIC='   + @Iic
                                  + '&tin='     + @VatRegistrationNo
                                  + '&crtd='    + @Date
                                  + '&ord='   + @OrderNumber
                                  + '&bu='    + @BusinessUnit                     
                                  + '&sw='    + @SoftNum
                                  + '&prc='   + @Total;

              if @ERROR = 0 
              begin
              update FH set 
                     fic = @fic
                     where nrrendor = @id
              end
                     update FH set 
                     errorlast = @error,errortextlast = @ERRORtext,XMLSTRING=@XMLSTRING,SIGNEDXML=@SIGNEDXML,QRCODELINK=@QRCODELINK
                     where nrrendor = @id
              
              SELECT @FIC, @ERROR, @ERRORtext, @XMLSTRING, @SIGNEDXML, @QRCODELINK
GO
