SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[_FiscalReportSaleXmlPOS] 
	@Id					INT
AS
	
DECLARE     @VatRegistrationNo	VARCHAR(50)
			,@BusinessUnit		VARCHAR(50)
			,@SoftNum			VARCHAR(50)
			,@ManufacNum			VARCHAR(50)
			,@XML				 XML
			,@FIC				 VARCHAR(1000)
			,@SIGNEDXML			 VARCHAR(MAX)
			,@ERROR				 VARCHAR(1000)
			,@ERRORtext			 VARCHAR(1000)
			,@schema				 VARCHAR(MAX)
			,@Url				 VARCHAR(MAX)
			,@CertificatePath     VARCHAR(MAX)
			,@certificatepassword VARCHAR(MAX)
			,@XMLSTRING           VARCHAR(MAX)
			,@QRCODELINK           VARCHAR(MAX)

SELECT       @VatRegistrationNo = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCVATREGISTRATIONNO')
		    ,@BusinessUnit      = (SELECT TOP 1 fiscbusunitcode from kase A inner join sm B on a.kmag=b.kmag and a.kod = b.kase where b.nrrendor=@id)
		    ,@SoftNum           = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCSOFTNUM')
		    ,@ManufacNum        = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCMANUFACNUM')
			,@schema = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCSCHEMA')
		    ,@Url      = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'FISCURL')
		    ,@CertificatePath           = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'CERTPATH')
		    ,@certificatepassword        = (SELECT TOP 1 ISNULL(VLERA,'') FROM KONFIG WHERE FUSHA = 'CERTPASS')		
		
	-->id e fatures 
	-->merret xml dhe string per qrcode
	EXEC _FiscalCreateSalesXmlPos @ID
		, @VatRegistrationNo		= @VatRegistrationNo
		, @BusinessUnit				= @BusinessUnit
		, @SoftNum					= @SoftNum
		, @CertificatePath			= @CertificatePath
		, @CertificatePassword		= @CertificatePassword
		, @schema					= @schema
		, @QRCODELINK				= @QRCODELINK	OUTPUT-->QRCODE string i cili duhet te printohet ne fature
		, @XML						= @XML			OUTPUT;

	SET @XMLSTRING = CAST(@XML AS NVARCHAR(MAX));-->konverto xml ne string

	declare @fisccert as varbinary(max)
	
	select top 1 @fisccert = fisccertificate from CONFND

	DECLARE @responseXML AS XML


	EXEC _FiscalProcessRequest 
		@XMLSTRING,
		@certificatePath			= @certificatePath, 
		@certificatepassword		= @certificatepassword, 
		@certbinary				    = @fisccert,
		@url						= @Url,
		@schema						= @schema,
		@returnValue				= 'FIC',	
		@useSystemProxy				= '',				--> VLERA QE KERKON TE MARRESH NGA DERGIMI I KERKESES
		@SIGNEDXML					= @SIGNEDXML	OUTPUT, 
		@FIC						= @FIC			OUTPUT, 
		@ERROR						= @ERROR		OUTPUT, 
		@ERRORtext					= @ERRORtext	OUTPUT,
		@responseXML		 = @responseXML	OUTPUT	

		if @ERROR = 0 
		begin
		update sm set 
			fic = @fic
			where nrrendor = @id
		end
			update sm set 
			errorlast = @error,errortextlast = @ERRORtext,XMLSTRING=@XMLSTRING,SIGNEDXML=@SIGNEDXML,QRCODELINK=@QRCODELINK
			where nrrendor = @id

	update sm set RESPONSEXMLFIC = @responseXML
	where NRRENDOR = @ID
	set nocount on
	if (select count(1) from sm where isfj = 1 and iscash=0 and isnull(eic,'')='' and nrrendor = @Id)=1
	begin
		--create table #tmp(xmlReply varchar(max),strin1 varchar(max),strin2 varchar(max),strin3 varchar(max),strin4 varchar(max),xml2 xml)
	--insert into #tmp 	
				exec [dbo].[_EINVOICESM] @id
		
	end
	set nocount off
	SELECT @FIC, @ERROR, @ERRORtext, @XMLSTRING, @SIGNEDXML, @QRCODELINK



	--alter table sm add fic varchar(1000)null
	--alter table sm add errorlast varchar(1000)null
	--alter table sm add errortextlast varchar(5000)null
	--alter table sm add xmlstring varchar(5000)null
	--alter table sm add signedxml varchar(5000)null
	--alter table sm add qrcodelink varchar(5000)null


	--	alter table smbak add fic varchar(1000)null
	--alter table smbak add errorlast varchar(1000)null
	--alter table smbak add errortextlast varchar(5000)null
	--alter table smbak add xmlstring varchar(5000)null
	--alter table smbak add signedxml varchar(5000)null
	--alter table smbak add qrcodelink varchar(5000)null
GO
