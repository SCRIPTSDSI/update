SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[getprintforfiscal](@id as varchar(50))
as



SELECT sm.NRRENDOR
      ,sm.DATEDOK
      ,sm.KTH
      ,sm.NRDOK
      ,sm.NRFRAKS
      ,sm.KOD
      ,sm.KODFKL
      ,sm.KMON
      ,sm.KLASAKF
      ,sm.KASE
      ,sm.VENHUAJ
      ,NIPT = K.NIPT--sm.NIPT
      ,sm.NRSERIAL
      ,sm.KODFISKAL
      ,sm.RRETHI
      ,SHENIM1=K.PERSHKRIM  -- sm.SHENIM1
      ,sm.SHENIM2
      ,sm.SHENIM3
      ,SHENIM4=sm.iic
      ,sm.NRDSHOQ
      ,sm.DTDSHOQ
      ,sm.NRRENDDMG
      ,sm.TIPDMG
      ,sm.NRMAG
      ,sm.KMAG
      ,sm.NRDMAG
      ,sm.FRDMAG
      ,sm.DTDMAG
      ,sm.MODPG
      ,sm.DTAF
      ,sm.DTDS
      ,sm.PERQDS
      ,sm.KURS1
      ,sm.KURS2
      ,sm.VLPATVSH
      ,sm.VLTVSH
      ,sm.VLERZBR
      ,sm.VLERTOT
      ,sm.PARAPG
      ,sm.PERQTVSH
      ,sm.PERQZBR
      ,sm.LLOGTVSH
      ,sm.LLOGZBR
      ,sm.LLOGARK
      ,sm.NRDFK
      ,sm.NRDITAR
      ,sm.POSTIM
      ,sm.LETER
      ,sm.FIRSTDOK
      ,sm.ISDG
      ,sm.NRDOKDG
      ,sm.DTDOKDG
      ,sm.TAGNR
      ,sm.NRDITARSHL
      ,sm.NRRENDKF
      ,sm.NRFRAKSKF
      ,sm.NRDFTEXTRA
      ,sm.ISDOKSHOQ
      ,sm.NRRENDOROF
      ,sm.NRRENDOROR
      ,sm.TIMED
      ,sm.KLASIFIKIM
      ,sm.USI
      ,sm.USM
      ,sm.TAG
      ,sm.TROW
      ,sm.VLTAX
      ,sm.PGKLIENT
      ,sm.KLIENTID
      ,sm.KARTE
      ,PIKE=CASE WHEN ISCASH = 1 THEN SM.PIKE ELSE SM.VLERTOT END
      ,sm.LASTMODIF
      ,sm.NRDSKONTO
      ,sm.EMERKOMP
      ,sm.EXPORT
      ,sm.NEKASE
      ,sm.VOUCHER
      ,sm.PRINTKASE
      ,sm.KLASIFIKIM1
      ,sm.KLASETVSH
      ,sm.KODKART
      ,sm.PGFORM
      ,sm.PGLIKUJ
      ,sm.PGSHENIM1
      ,sm.PGSHENIM2
      ,sm.PAGESEARK
      ,sm.DATEARK
      ,sm.EXTIMPID
      ,EXTIMPKOMENT=sm.RELATEDFIC
      ,sm.EXTEXP
      ,sm.EXTEXPKOMENT
      ,sm.AGJENTSHITJELINK
      ,sm.KASEPRINT
      ,sm.KONFIRM
      ,sm.NRRENDORFJT
      ,sm.DATECREATE
      ,sm.DATEEDIT
      ,sm.TAGRND
      ,sm.CASH
      ,sm.fic
      ,sm.errorlast
      ,sm.errortextlast
      ,sm.xmlstring
      ,sm.signedxml
      ,sm.qrcodelink,
         smscr.NRRENDOR
      ,smscr.NRD
      ,smscr.KOD
      ,smscr.KODAF
      ,smscr.KARTLLG
      ,smscr.PERSHKRIM
      ,smscr.NRRENDKLLG
      ,smscr.LLOGARIPK
      ,smscr.NJESI
      ,smscr.CMSHZB0
      ,smscr.CMIMM
      ,smscr.SASI
      ,smscr.PERQDSCN
      ,smscr.CMIMBS
      ,smscr.VLERABS
      ,smscr.VLERAM
      ,vlpatvsh1 =smscr.VLPATVSH/((100+ convert(float, kt.PERQTVSH))/100) --smscr.VLPATVSH
      ,vltvsh1=(smscr.VLPATVSH-smscr.VLPATVSH/((100+ convert(float, kt.PERQTVSH))/100))-- smscr.VLTVSH
      ,smscr.PERQTVSH
      ,smscr.KOEFSHB
      ,smscr.NJESINV
      ,smscr.TIPKLL
      ,smscr.BC
      ,smscr.KLASIF
      ,smscr.KLASIF2
      ,smscr.KOMENT
      ,smscr.NOTMAG
      ,smscr.RIMBURSIM
      ,smscr.DTSKADENCE
      ,smscr.SERI
      ,smscr.KODKR
      ,smscr.TROW
      ,smscr.TAGNR
      ,smscr.VLTAX
      ,smscr.KODTVSH
      ,smscr.TIMED
      ,smscr.GARANCI
      ,smscr.CMRIMBURSIM
      ,smscr.VLRIMBURSIM
      ,smscr.PERQKMS
      ,smscr.VLERAKMS
      ,smscr.PESHANET
      ,smscr.PESHABRT
      ,smscr.APLTVSH
      ,smscr.APLINVESTIM
      ,smscr.PROMOC
      ,smscr.PROMOCTIP
      ,smscr.PROMOCKOD
      ,smscr.CMSHZB0MV
      ,smscr.CMIMBSTVSH
      ,smscr.CMSHREF
      ,smscr.CMIMKLASEREF
      ,smscr.VLKLASEREF
      ,smscr.CMIMREFERENCE
      ,smscr.CMSHREFAP
      ,smscr.CMSHREFAP2
      ,smscr.VLERASM
      ,smscr.SASIKONV
      ,smscr.NRSERIAL
      ,smscr.KONVERTART
      ,smscr.PROMPTPROD1
      ,smscr.KODAGJENT
      ,smscr.KODKLF
      ,smscr.KOEFICENTARTAGJ
      ,smscr.KOEFICENTARTKL
      ,smscr.ISNOTFIRO
      ,smscr.ISAMB
      ,smscr.TIMEI
      ,smscr.TIMEM
      ,smscr.STATROW
      ,smscr.ORDERSCR
      ,smscr.TAGRND
      ,smscr.CMKOSTMES
      ,smscr.CMKOSTMESMV
      ,smscr.VLKOSTMES
      ,smscr.MARZH
      ,smscr.KODOPER
      ,smscr.LASTMODIF
      ,smscr.NRRESHT
         ,ZBRITJERRESHT = (CMSHZB0-CMIMM)*SMSCR.SASI
         ,operatori = u.OPERATORCODE
         ,businessunit = (select vlera from konfig where fusha = 'FISCBUSINESSUNIT')
         ,TCRCODE = KA.FISCTCRNUM
         ,softnum = (select vlera from konfig where fusha = 'FISCSOFTNUM')
         ,iic = sm.iic
         ,iicsig = sm.iicsig,
		 PIKTOT=(SELECT SUM(P.PIKE) AS PIKETOT FROM karteantaresie.dbo.kartapike p where p.barcode=sm.klientid)


  FROM dbo.SM
  inner join smscr on smscr.nrd = sm.nrrendor 
  inner join artikuj a on a.kod = smscr.kartllg
  inner join KLASATVSH kt on kt.KOD = a.KODTVSH
  inner join klient k on k.KOD = sm.KODFKL
  INNER JOIN KASE KA ON KA.KOD = SM.KASE
  inner join drh..users u on u.drn = KA.KOD
  where smscr.nrd = @ID

GO
