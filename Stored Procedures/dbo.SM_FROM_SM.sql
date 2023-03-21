SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[SM_FROM_SM](@NRRENDOR AS INT,@NRRENDORNEW INT OUTPUT)
AS
BEGIN


INSERT INTO dbo.SM
           (DATEDOK           ,KTH           ,NRDOK           ,NRFRAKS
           ,KOD           ,KODFKL           ,KMON           ,KLASAKF
           ,KASE           ,VENHUAJ           ,NIPT           ,NRSERIAL
           ,KODFISKAL           ,RRETHI           ,SHENIM1           ,SHENIM2
           ,SHENIM3           ,SHENIM4           ,NRDSHOQ           ,DTDSHOQ
           ,NRRENDDMG           ,TIPDMG           ,NRMAG           ,KMAG
           ,NRDMAG           ,FRDMAG           ,DTDMAG           ,MODPG
           ,DTAF           ,DTDS           ,PERQDS           ,KURS1
           ,KURS2           ,VLPATVSH           ,VLTVSH           ,VLERZBR
           ,VLERTOT           ,PARAPG           ,PERQTVSH           ,PERQZBR
           ,LLOGTVSH           ,LLOGZBR           ,LLOGARK           ,NRDFK
           ,NRDITAR           ,POSTIM           ,LETER           ,FIRSTDOK
           ,ISDG           ,NRDOKDG           ,DTDOKDG           ,TAGNR
           ,NRDITARSHL           ,NRRENDKF           ,NRFRAKSKF           ,NRDFTEXTRA
           ,ISDOKSHOQ           ,NRRENDOROF           ,NRRENDOROR           ,TIMED
           ,KLASIFIKIM           ,USI            ,USM           ,TAG
           ,TROW           ,VLTAX           ,PGKLIENT           ,KLIENTID
           ,KARTE           ,PIKE           ,LASTMODIF           ,NRDSKONTO
           ,EMERKOMP           ,EXPORT           ,NEKASE           ,VOUCHER
           ,PRINTKASE           ,KLASIFIKIM1           ,KLASETVSH           ,KODKART
           ,PGFORM           ,PGLIKUJ           ,PGSHENIM1           ,PGSHENIM2
           ,PAGESEARK           ,DATEARK           ,EXTIMPID           ,EXTIMPKOMENT
           ,EXTEXP           ,EXTEXPKOMENT           ,AGJENTSHITJELINK           ,KASEPRINT
           ,KONFIRM           ,NRRENDORFJT           ,DATECREATE           ,DATEEDIT
           ,TAGRND           ,CASH           ,fic           ,errorlast
           ,errortextlast           ,xmlstring           ,signedxml           ,qrcodelink
           ,iic           ,iicsig,		RELATEDFIC,
		   ISFJ,relatedeic,proces,fiscmenpag,fisctipdok)
  SELECT    convert(datetime,floor(convert(float,getdate())))           ,KTH           ,NRDOK=case when ISNULL(FIC,'')='' then null else +1 end         ,NRFRAKS
           ,KOD           ,KODFKL           ,KMON           ,KLASAKF
           ,KASE           ,VENHUAJ           ,NIPT           ,NRSERIAL
           ,KODFISKAL           ,RRETHI           ,SHENIM1           ,SHENIM2
           ,SHENIM3           ,SHENIM4           ,NRDSHOQ           ,DTDSHOQ
           ,NRRENDDMG           ,TIPDMG           ,NRMAG           ,KMAG
           ,NRDMAG           ,FRDMAG           ,DTDMAG           ,MODPG
           ,DTAF           ,DTDS           ,PERQDS           ,KURS1
           ,KURS2           ,VLPATVSH=VLPATVSH*-1           ,VLTVSH=vltvsh*-1           ,VLERZBR
           ,VLERTOT=VLERTOT*-1           ,PARAPG =parapg*-1          ,PERQTVSH           ,PERQZBR
           ,LLOGTVSH           ,LLOGZBR           ,LLOGARK           ,NRDFK
           ,NRDITAR           ,POSTIM           ,LETER           ,FIRSTDOK
           ,ISDG           ,NRDOKDG           ,DTDOKDG           ,TAGNR
           ,NRDITARSHL           ,NRRENDKF           ,NRFRAKSKF           ,NRDFTEXTRA
           ,ISDOKSHOQ           ,NRRENDOROF           ,NRRENDOROR           ,TIMED
           ,KLASIFIKIM           ,USI           ,USM           ,TAG
           ,TROW           ,VLTAX           ,PGKLIENT           ,KLIENTID
           ,KARTE           ,PIKE           ,LASTMODIF           ,NRDSKONTO
           ,EMERKOMP           ,EXPORT           ,NEKASE           ,VOUCHER
           ,PRINTKASE           ,KLASIFIKIM1           ,KLASETVSH           ,KODKART
           ,PGFORM           ,PGLIKUJ           ,PGSHENIM1           ,PGSHENIM2
           ,PAGESEARK           ,DATEARK           ,EXTIMPID           ,EXTIMPKOMENT
           ,EXTEXP           ,EXTEXPKOMENT           ,AGJENTSHITJELINK           ,KASEPRINT
           ,KONFIRM           ,NRRENDORFJT           ,DATECREATE=getdate()           ,DATEEDIT=null
           ,TAGRND           ,CASH           ,fic=''           ,errorlast=''
           ,errortextlast=''           ,xmlstring=''           ,signedxml=''           ,qrcodelink=''
           ,iic=''           ,iicsig='' ,RELATEDFIC = IIC,
		   ISFJ,relatedeic=eic ,proces='P10',fiscmenpag,fisctipdok='384'
FROM SM WHERE NRRENDOR = @NRRENDOR

SET @NRRENDORNEW = (SELECT @@IDENTITY)

INSERT INTO dbo.SMSCR
           (NRD           ,KOD           ,KODAF           ,KARTLLG
           ,PERSHKRIM           ,NRRENDKLLG           ,LLOGARIPK           ,NJESI
           ,CMSHZB0           ,CMIMM           ,SASI           ,PERQDSCN
           ,CMIMBS           ,VLERABS           ,VLERAM           ,VLPATVSH
           ,VLTVSH           ,PERQTVSH           ,KOEFSHB           ,NJESINV
           ,TIPKLL           ,BC           ,KLASIF           ,KLASIF2
           ,KOMENT           ,NOTMAG           ,RIMBURSIM           ,DTSKADENCE
           ,SERI           ,KODKR           ,TROW           ,TAGNR
           ,VLTAX           ,KODTVSH           ,TIMED           ,GARANCI
           ,CMRIMBURSIM           ,VLRIMBURSIM           ,PERQKMS           ,VLERAKMS
           ,PESHANET           ,PESHABRT           ,APLTVSH           ,APLINVESTIM
           ,PROMOC           ,PROMOCTIP           ,PROMOCKOD           ,CMSHZB0MV
           ,CMIMBSTVSH           ,CMSHREF           ,CMIMKLASEREF           ,VLKLASEREF
           ,CMIMREFERENCE           ,CMSHREFAP           ,CMSHREFAP2           ,VLERASM
           ,SASIKONV           ,NRSERIAL           ,KONVERTART           ,PROMPTPROD1
           ,KODAGJENT           ,KODKLF           ,KOEFICENTARTAGJ           ,KOEFICENTARTKL
           ,ISNOTFIRO           ,ISAMB           ,TIMEI           ,TIMEM
           ,STATROW           ,ORDERSCR           ,TAGRND           ,CMKOSTMES
           ,CMKOSTMESMV           ,VLKOSTMES           ,MARZH           ,KODOPER
           ,LASTMODIF           ,NRRESHT)
  select    NRD = @NRRENDORNEW           ,KOD           ,KODAF           ,KARTLLG
           ,PERSHKRIM           ,NRRENDKLLG           ,LLOGARIPK           ,NJESI
           ,CMSHZB0           ,CMIMM           ,SASI=SASI*-1           ,PERQDSCN
           ,CMIMBS           ,VLERABS=VLERABS*-1           ,VLERAM=VLERAM * -1           ,VLPATVSH=VLPATVSH*-1
           ,VLTVSH=VLTVSH*-1           ,PERQTVSH           ,KOEFSHB           ,NJESINV
           ,TIPKLL           ,BC           ,KLASIF           ,KLASIF2
           ,KOMENT           ,NOTMAG           ,RIMBURSIM           ,DTSKADENCE
           ,SERI           ,KODKR           ,TROW           ,TAGNR
           ,VLTAX=VLTAX*-1           ,KODTVSH           ,TIMED           ,GARANCI
           ,CMRIMBURSIM           ,VLRIMBURSIM=VLRIMBURSIM*-1           ,PERQKMS           ,VLERAKMS=VLERAKMS*-1
           ,PESHANET           ,PESHABRT           ,APLTVSH           ,APLINVESTIM
           ,PROMOC           ,PROMOCTIP           ,PROMOCKOD           ,CMSHZB0MV
           ,CMIMBSTVSH           ,CMSHREF           ,CMIMKLASEREF           ,VLKLASEREF=VLKLASEREF*-1
           ,CMIMREFERENCE           ,CMSHREFAP           ,CMSHREFAP2           ,VLERASM=VLERASM*-1
           ,SASIKONV           ,NRSERIAL           ,KONVERTART           ,PROMPTPROD1
           ,KODAGJENT           ,KODKLF           ,KOEFICENTARTAGJ           ,KOEFICENTARTKL
           ,ISNOTFIRO           ,ISAMB           ,TIMEI           ,TIMEM
           ,STATROW           ,ORDERSCR           ,TAGRND           ,CMKOSTMES
           ,CMKOSTMESMV           ,VLKOSTMES=VLKOSTMES*-1           ,MARZH           ,KODOPER
           ,LASTMODIF           ,NRRESHT
from smscr where nrd = @NRRENDOR




END
GO
