SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Isd_GatiFiskalFF]
(
 @pNrRendor Integer
)
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @TEMPOUTPUT VARCHAR(MAX)

	DECLARE @OUTPUT1 VARCHAR(MAX)
	DECLARE @OUTPUT2 VARCHAR(MAX)
	DECLARE @OUTPUT3 VARCHAR(MAX)
	DECLARE @OUTMESSAGE VARCHAR(MAX)
	DECLARE @TIPPAGESE VARCHAR(MAX)
	DECLARE @TIPKLIENT VARCHAR(MAX)
	DECLARE @SELF VARCHAR(MAX)
	DECLARE @NIPT VARCHAR(MAX)

	SET @NIPT=(SELECT NIPT FROM CONFND)
	SET @TEMPOUTPUT=''

	SET @TIPPAGESE=(SELECT top 1 KLASEPAGESE FROM FF A INNER JOIN FisMenPagese B ON  A.FISMENPAGESE=B.KOD WHERE A.NRRENDOR=@pNrRendor)
	--SET @TIPKLIENT=(SELECT top 1 CASE WHEN ISNULL(TIPNIPT,'')='' THEN 'NUIS' ELSE TIPNIPT END FROM FJ A INNER JOIN KLIENT B ON A.KODFKL=B.KOD WHERE A.NRRENDOR=@pNrRendor)
	SET @TIPKLIENT=(SELECT top 1 TIPNIPT  FROM FF A INNER JOIN KLIENT B ON A.KODFKL=B.KOD WHERE A.NRRENDOR=@pNrRendor)
	SET @SELF=(SELECT CASE WHEN ISNULL(A.KLASETVSH,'') IN ('ABROAD','DOMESTIC','AGREEMENT','OTHER') THEN  A.KLASETVSH
										 WHEN ISNULL(A.KLASETVSH,'')='FANG' THEN 'ABROAD' 
									     ELSE  NULL END FROM FF A WHERE A.NRRENDOR=@pNrRendor)
	
	IF @SELF IN ('ABROAD','DOMESTIC','AGREEMENT','OTHER')
	BEGIN
					IF EXISTS(SELECT 1 FROM FF WHERE NRRENDOR = @pNrRendor 
						   AND FISLASTERRORFIC = '0'
						   AND (ISNULL(FISFIC, '') != '' AND FISKALIZUAR=1 AND ISNULL(FISRELATEDFIC,'')!=ISNULL(FISFIC, '') ) )	
					BEGIN
						SET @OUTPUT1='0'
						SET @OUTPUT2='0'
					END
					ELSE
						BEGIN
									EXEC Isd_FiscalFF @pNrRendor,0,@OUTPUT1 OUTPUT
								  --EXEC __FiscalCreateSalesXmlFJ2 @pNrRendor,@OUTPUT1 OUTPUT

									SET @OUTPUT2='0'
	
									IF ISNULL(@OUTPUT1,'') <> '0'
										SET @TEMPOUTPUT = ISNULL(@OUTPUT1,'') + char(10)+char(13)
						END
	END
	ELSE
	BEGIN
	SET @OUTPUT1='Fatura nuk mund te fiskalizohet. Kujdes klase e tvsh tek koka e dokumentit'
	SET @OUTPUT2='0'
	IF ISNULL(@OUTPUT1,'') <> '0'
										SET @TEMPOUTPUT = ISNULL(@OUTPUT1,'') + char(10)+char(13)
	END

	if  (ISNULL(@OUTPUT1,'0')='0' and ISNULL(@OUTPUT2,'0')='0')
	set @OUTMESSAGE=''
	ELSE
	set @OUTMESSAGE = 'Gabim gjate procesit te deklarimit tatime....'+char(10)+ char(13) + @TEMPOUTPUT


	select @OUTPUT1 AS KodError1,@OUTPUT2 AS KodError2,@OUTMESSAGE AS MsgError
	
END


GO
