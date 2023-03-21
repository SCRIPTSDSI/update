SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[_FiscalCreateTcrXmlPos]
                @Id                                                                        varchar(50)
AS
DECLARE     @VatRegistrationNo               VARCHAR(50)
                                                ,@BusinessUnit                VARCHAR(50)
                                                ,@SoftNum                                        VARCHAR(50)
                                                ,@ManufacNum                                              VARCHAR(50)
                                                ,@XML                                                 XML
                                                ,@FIC                                                    VARCHAR(1000)
                                                ,@SIGNEDXML                                  VARCHAR(MAX)
                                                ,@ERROR                                                             VARCHAR(1000)
                                                ,@ERRORtext                                    VARCHAR(1000)
                                                ,@schema                                                           VARCHAR(MAX)
                                                ,@Url                                                    VARCHAR(MAX)
                                                ,@CertificatePath     VARCHAR(MAX)
                                                ,@certificatepassword VARCHAR(MAX)

SELECT       @VatRegistrationNo = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCVATREGISTRATIONNO')
                                    ,@BusinessUnit      = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCBUSINESSUNIT')
                                    ,@SoftNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCSOFTNUM')
                                    ,@ManufacNum        = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCMANUFACNUM')
                                                ,@schema = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCSCHEMA')
                                    ,@Url      = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCURL')
                                    ,@CertificatePath           = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'CERTPATH')
                                    ,@certificatepassword        = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'CERTPASS')
BEGIN
                SET @XML  = (
                SELECT 
                                                dbo.DATE_1601(GETDATE()) AS 'Header/@SendDateTime',
                                                NEWID() AS 'Header/@UUID',                                                                                                                    --Duhet shtuar ne fature, gjenerimi i saj per here te pare te ruhet ne fature dhe me pas te riperdoret
                (
                                SELECT TOP 1  K.FISCBUSUNITCODE                                                                                         AS '@BusinUnitCode'                                --Duhet shtuar tek magazina, apo duhet shtuar ne fature? faturat vetem sherbim?
                                                                                ,@VatRegistrationNo                                                                    AS '@IssuerNUIS'                                --Duhet shtuar ne magazina/fature 
                                                                                 ,@SoftNum                                                                                                       AS '@SoftCode'
                                                                                ,'xi177lb183'                                                                                                       AS '@MaintainerCode'
                                                                                ,K.PERSHKRIM                                                                                                                                  AS '@TCRIntID'                                  --Counter per TCR
                                                                                ,LEFT(dbo.DATE_1601(GETDATE()), 10) AS '@ValidFrom'
                                                   ,'REGULAR'                                                                                                      AS '@Type'
FROM KASE K 
--INNER JOIN DRH..USERS U ON U.DRN = K.KOD
WHERE kod = @ID
                                FOR XML PATH('TCR'), TYPE
                )
                FOR XML PATH('RegisterTCRRequest'));

                SET @XML = CAST( REPLACE(CAST(@xml AS NVARCHAR(MAX)),'<RegisterTCRRequest>'
                ,'<RegisterTCRRequest xmlns="https://eFiskalizimi.tatime.gov.al/FiscalizationService/schema" xmlns:ns2 = "http://www.w3.org/2000/09/xmldsig#" Id="Request" Version="3">') AS XML);
                declare @XMLSTRING as varchar(max)
                SET @XMLSTRING = CAST(@XML AS NVARCHAR(MAX))-->konverto xml ne string
                --SELECT @XMLSTRING
                declare @fisccert as varbinary(max)

                select top 1 @fisccert = fisccertificate from CONFND
                
                DECLARE @responseXML AS XML

                EXEC _FiscalProcessRequest 
                                @XMLSTRING,                                                                                                                  
                                @certificatePath                              = @certificatePath,                                                                                                                                                                                                                         
                                @certificatepassword    = @certificatepassword,               
                                @certbinary                                                       = @fisccert,
                                @url                                                                      = @url,
                                @schema                                                                            = @schema,
                                @returnValue                                   = 'TCRCode',                                                                       --> VLERA QE KERKON TE MARRESH NGA DERGIMI I KERKESES
                                @SIGNEDXML                                                   = @SIGNEDXML OUTPUT,                                            --> XML E PERGATITUR BASHKE ME SHENJIMIN 
                                @FIC                                                                     = @FIC OUTPUT,                                                                              --> FIC PER VLEREN E FATURES, NR I SHENJIMIT
                                @ERROR                                                                              = @ERROR OUTPUT,                                                       --> 0 -> SKA GABIM 1-> KA GABIM
                                @ERRORtext                                                      = @ERRORtext OUTPUT,                                                               --> MESAZHI I GABIMIT
                                @responseXML                    = @responseXML OUTPUT,
                                @useSystemProxy         =''
                                if @ERROR='0'
                                begin
                                                update kase set FISCTCRNUM= @FIC where kod=@id
                                end
        SELECT @FIC AS returnValue, @ERROR AS error, @ERRORtext AS errortext, @SIGNEDXML AS singedxml,@XML AS XML;
END;
GO
