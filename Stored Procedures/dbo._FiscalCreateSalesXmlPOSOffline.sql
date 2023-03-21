SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[_FiscalCreateSalesXmlPOSOffline]
       @Id                                      INT
AS
BEGIN
DECLARE     @VatRegistrationNo    VARCHAR(50)
                     ,@BusinessUnit             VARCHAR(50)
                     ,@SoftNum                  VARCHAR(50)
                     ,@ManufacNum               VARCHAR(50)
                     ,@XML                      XML
                     ,@FIC                      VARCHAR(1000)
                     ,@SIGNEDXML                VARCHAR(MAX)
                     ,@ERROR                           VARCHAR(1000)
                     ,@ERRORtext                VARCHAR(1000)
                     ,@schema                          VARCHAR(MAX)
                     ,@Url                      VARCHAR(MAX)
                     ,@CertificatePath     VARCHAR(MAX)
                     ,@certificatepassword VARCHAR(MAX)
                     ,@XMLSTRING           VARCHAR(MAX)
                     ,@QRCODELINK           VARCHAR(MAX)

SELECT       @VatRegistrationNo = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCVATREGISTRATIONNO')
                  ,@BusinessUnit      = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCBUSINESSUNIT')
                  ,@SoftNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCSOFTNUM')
                  ,@ManufacNum        = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCMANUFACNUM')
                     ,@schema = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCSCHEMA')
                  ,@Url      = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCURL')
                  ,@CertificatePath           = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'CERTPATH')
                  ,@certificatepassword        = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'CERTPASS')        

       DECLARE @Iic               VARCHAR(1000),
                     @IicSignature VARCHAR(1000),
                     @Date                VARCHAR(100),
                     @OrderNumber  VARCHAR(10),
                     @Total               VARCHAR(20),
                     @CashRegister VARCHAR(20),         
                     @OperatorCode VARCHAR(20),
                     @PERQZBR        FLOAT;
       SELECT  @PERQZBR =  PERQZBR FROM sm WHERE NRRENDOR = @ID
       --hard coded parameters
       SET @CashRegister = (SELECT TOP 1 U.FISCTCRNUM FROM kase U INNER JOIN sm P ON P.kase = U.kod WHERE P.NRRENDOR = @Id);
       SET @OperatorCode = (SELECT TOP 1 U.OPERATORCODE FROM DRH..USERS U 
       INNER JOIN kase K ON K.KOD = U.DRN 
       INNER JOIN sm P ON P.kase = K.kod WHERE P.NRRENDOR = @Id);


       SELECT @DATE         = dbo.DATE_1601(TIMED),
                 @OrderNumber = CONVERT(VARCHAR(10), nrdok),
                 @Total            = CONVERT(VARCHAR(20), (CONVERT(DECIMAL(18, 2), vlertot)))
       FROM sm
       WHERE NRRENDOR = @Id;

       DECLARE @IICBLANC AS VARCHAR(MAX)
       SELECT @IICBLANC = @VatRegistrationNo + '|' 
       + dbo.DATE_1601(timed) + '|' 
       + convert(varchar(max),nrdok)+ '|'
       + @BusinessUnit + '|'
       + @CashRegister + '|'
       + @SoftNum + '|'
       + CONVERT(VARCHAR(MAX),CONVERT(DECIMAL(10,2),vlertot))
       FROM sm WHERE NRRENDOR = @ID

       --iicInput += "I12345678I"; // 
       --dateTimeCreated    iicInput += "|2019-06-12T17:05:43+02:00";       // 
       --invoiceNumber iicInput += "|9952"; // 
       --busiUnitCode iicInput += "|bb123bb123"; // 
       --tcrCode iicInput += "|cc123cc123"; // 
       --softCode iicInput += "|ss123ss123"; // 
       --totalPrice iicInput += "|99.01";


       EXEC _FiscalGenerateHash @IICBLANC, @CertificatePath, @CertificatePassword, @IIC OUTPUT, @IICSIGNATURE OUTPUT, @ERROR OUTPUT, @ERRORtext OUTPUT;

       SET @XML  = (
              SELECT 
                           dbo.DATE_1601(GETDATE()) AS 'Header/@SendDateTime',
                           'false'                    AS 'Header/@IsSubseqDeliv', --Duhet shtuar ne fature
                           NEWID() AS 'Header/@UUID',                             --Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
              (
                     SELECT 'false'                    AS '@IsBadDebt'                   --Duhet shtuar ne fature
                              ,dbo.DATE_1601(MAX(S.timed)) AS '@IssueDateTime'    
                              ,@BusinessUnit    AS '@BusinUnitCode'        --Duhet shtuar tek magazina, apo duhet shtuar ne fature? faturat vetem sherbim?
                              ,@CashRegister    AS '@TCRCode'              --Duhet shtuar ne magazina/fature -- nr i tcr
                              ,@OperatorCode    AS '@OperatorCode'         --Duhet shtuar ne user ->        
                              ,@SoftNum         AS '@SoftCode'
                              ,@IIC                   AS '@IIC'                         --Duhet shtuar ne fature
                              ,@IICSIGNATURE    AS '@IICSignature'         --Duhet shtuar ne fature
                              --,''                          AS '@IICReference'   --?kthim
                              ,@OrderNumber     AS '@InvOrdNum'                                        
                              , CONVERT(VARCHAR(10), MIN(nrdok))       + '/'
                               + CONVERT(VARCHAR(4), YEAR(MAX(S.TIMED))) + '/'
                                  + @CashRegister            -- > NQS CASH PERNDRYSHE BEJE BOSH @CashRegister
                                  AS '@InvNum'               --NrRendor vjetor qe fillon nga 1 ne fillim vit
                              ,CONVERT(DECIMAL(18, 2), MIN(vlertot)) AS '@TotPrice'             --vlera totale
                              ,CONVERT(DECIMAL(18, 2), SUM( (SASI*PS.CMIMM)*(1-CONVERT(FLOAT,@PERQZBR)/100)/(1+CONVERT(FLOAT,KT.PERQTVSH)/100)))          AS '@TotPriceWoVAT'  --vlera totale pa tvsh
                              ,CONVERT(DECIMAL(18, 2),SUM( (SASI*PS.CMIMM)*(1-CONVERT(FLOAT,@PERQZBR)/100)) - SUM( (SASI*PS.CMIMM)*(1-CONVERT(FLOAT,@PERQZBR)/100)/(1+CONVERT(FLOAT,KT.PERQTVSH)/100)))                 AS '@TotVATAmt'              --vlera tvsh
                              ,'CASH'                 AS '@TypeOfInv'
                              ,'false'                AS '@IsReverseCharge'             --??
                              ,'true'                 AS '@IsIssuerInVAT'        --??                              
                              ,'0.00'                 AS '@TaxFreeAmt'
                              ,'false'                AS '@IsSimplifiedInv'

                        , (
                                  SELECT CONVERT(DECIMAL(18, 2), MIN(S.vlertot)) AS 'PayMethod/@Amt',
                                            'BANKNOTE'    AS 'PayMethod/@Type'
                                  FOR XML PATH (''), TYPE
                           ) PayMethods
                        ,(  --nga config
                                  SELECT 'Financa5'                               AS 'Seller/@Name',                     
                                                @VatRegistrationNo                AS 'Seller/@IDNum',           
                                                'NUIS'                                   AS 'Seller/@IDType',
                                                'Rruga Mustafa Matohiti'   AS 'Seller/@Address',
                                                'Tirane'                                 AS 'Seller/@Town',
                                                'ALB'                                    AS 'Seller/@Country'
                                  FOR XML PATH (''), TYPE
                           ) ,
                           (      --nga klienti
                                  SELECT case when nipt is null then  null else REPLACE(PERSHKRIM, '"', '') end  AS 'Buyer/@Name',
                                                Nipt                       AS 'Buyer/@IDNum',          
                                                CASE WHEN NIPT IS NULL THEN NULL ELSE 'NUIS' END                                                AS 'Buyer/@IDType',
                                                case when nipt is null then  null else ADRESA1 end                                                AS 'Buyer/@Address',
                                                case when nipt is null then  null else ADRESA2 END                                                AS 'Buyer/@Town',
                                                case when nipt is null then  null else LEFT(ADRESA3, 3) END                            AS 'Buyer/@Country'
                                  FROM KLIENT C 
                                  WHERE C.KOD = MIN(S.KODFKL)
                                  FOR XML PATH (''), TYPE
                           ),
                           (      SELECT C.kod AS 'I/@C',
                                                LEFT(C.pershkrim, 50) AS 'I/@N',
                                                CONVERT(DECIMAL(18, 2), C.SASI * C.cmimM) AS 'I/@PA',
                                                CONVERT(DECIMAL(18, 2), (C.SASI*C.CMIMM)*(1-CONVERT(FLOAT,@PERQZBR)/100)/(1+CONVERT(FLOAT,KT.PERQTVSH)/100)) AS 'I/@PB',
                                                CONVERT(DECIMAL(18, 2),  C.Sasi) AS 'I/@Q',
                                                CONVERT(DECIMAL(18, 2), 0) AS 'I/@R',
                                                'true' AS 'I/@RR',
                                                A.NJESI AS 'I/@U',
                                                CONVERT(DECIMAL(18, 2), (C.CMIMM)*(1-CONVERT(FLOAT,@PERQZBR)/100)/(1+CONVERT(FLOAT,KT.PERQTVSH)/100)) AS 'I/@UPB',
                                                CONVERT(DECIMAL(18, 2), C.CmiMm) AS 'I/@UPA',
                                                CONVERT(DECIMAL(18, 2), (C.SASI * C.CmiMm*(1-CONVERT(FLOAT,@PERQZBR)/100))-(C.SASI * C.CmiMm*(1-CONVERT(FLOAT,@PERQZBR)/100) / (1+Convert(float,Kt.Perqtvsh)/100)) ) AS 'I/@VA',
                                                CONVERT(DECIMAL(18, 2), Kt.Perqtvsh) AS 'I/@VR'
                                  FROM SMSCR C 
                                  INNER JOIN ARTIKUJ A ON A.KOD = C.KARTLLG
                                  INNER JOIN KLASATVSH KT ON KT.KOD = A.KODTVSH
                                  WHERE C.NRD = MIN(S.nrrendor)
                                  FOR XML PATH (''), TYPE
                           ) Items,
                           (      --grupim sipas tvsh
                                  SELECT --CONVERT(DECIMAL(18, 0), COUNT(1)) 
                                                CONVERT(DECIMAL(18, 0), COUNT(1)) AS 'SameTax/@NumOfItems',
                                                CONVERT(DECIMAL(18, 2), SUM((SASI*C.CMIMM)*(1-CONVERT(FLOAT,@PERQZBR)/100)/(1+CONVERT(FLOAT,K.PERQTVSH)/100))) AS 'SameTax/@PriceBefVAT',
                                                CONVERT(DECIMAL(18, 2), K.PERQTVSH) AS 'SameTax/@VATRate',
                                                CONVERT(DECIMAL(18, 2), SUM( (SASI*C.CMIMM)*(1-CONVERT(FLOAT,@PERQZBR)/100)) - SUM((SASI*C.CMIMM)*(1-CONVERT(FLOAT,@PERQZBR)/100)/(1+CONVERT(FLOAT,K.PERQTVSH)/100))) AS 'SameTax/@VATAmt'
                                  FROM SMSCR C 
                                  INNER JOIN ARTIKUJ A ON A.KOD = C.KARTLLG
                                  INNER JOIN KLASATVSH K ON K.KOD = A.KODTVSH
                                  WHERE C.NRD = MIN(S.NRRENDOR)
                                  GROUP BY K.PERQTVSH
                                  FOR XML PATH (''), TYPE
                           ) SameTaxes,
                           (      --per tu interpretuar cfare jane?
                                  SELECT COUNT(1) AS 'Item/@NumOfItems',
                                                SUM((SASI*C.CMIMM)*(1-CONVERT(FLOAT,@PERQZBR)/100)/(1+CONVERT(FLOAT,KT.PERQTVSH)/100)) AS 'Item/@PriceBefConsTax',
                                                KT.PERQTVSH AS 'Item/@ConsTaxRate',
                                                SUM( (SASI*C.CMIMM)*(1-CONVERT(FLOAT,@PERQZBR)/100)) - SUM( (SASI*C.CMIMM)*(1-CONVERT(FLOAT,@PERQZBR)/100)/(1+CONVERT(FLOAT,KT.PERQTVSH)/100))  AS 'Item/@ConsTaxAmt'
                                  FROM SMSCR C 
                                  INNER JOIN ARTIKUJ A ON A.KOD = C.KARTLLG
                                  INNER JOIN KLASATVSH KT ON KT.KOD =A.KODTVSH
                                  WHERE C.NRD = S.NRRENDOR
                                  AND 1 = 2 -- NQS NUK KA REKORDE HIQET VETE SI TAG
                                  GROUP BY KT.PERQTVSH
                                  FOR XML PATH (''), TYPE
                           ) ConsTaxItems
              FROM SM  S
              INNER JOIN SMSCR PS ON PS.NRD = S.NRRENDOR
              INNER JOIN ARTIKUJ A ON A.KOD = PS.KARTLLG
              INNER JOIN KLASATVSH KT ON KT.KOD = A.kodtvsh
              WHERE s.NRRENDOR = @Id
              GROUP BY S.NRRENDOR
              FOR XML PATH('Invoice'), TYPE
       )
       FOR XML PATH('RegisterInvoiceRequest'));
       declare @datedokreturn as datetime
       set @datedokreturn = (select top 1 timed from sm where nrrendor = @id)
    
       SET @QrCodeLink = 'https://efiskalizimi-app-test.tatime.gov.al/invoice-check/#/verify?' 
                                  + 'iic='      + @Iic
                                  + '&tin='     + @VatRegistrationNo
                                  + '&crtd='    + @Date
                                  + '&ord='   + @OrderNumber
                                  + '&bu='    + @BusinessUnit                     
                                  + '&cr='    + @CashRegister
                                  + '&sw='    + @SoftNum
                                  + '&prc='   + @Total;  

       SET @XML = CAST( REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterInvoiceRequest>','<RegisterInvoiceRequest xmlns="https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="2">') AS XML)
       select @xml,@Iic,@VatRegistrationNo,@datedokreturn
END

GO
