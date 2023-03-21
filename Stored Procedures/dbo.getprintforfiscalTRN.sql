SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--SELECT * FROM FH

 

--getprintforfiscalTRN 74226

 

CREATE proc [dbo].[getprintforfiscalTRN](@id as varchar(50))

as

SELECT sm.NRRENDOR

      ,sm.DATEDOK

      ,sm.KTH

      ,sm.NRDOK

      ,sm.NRFRAKS

      ,NIPT = ''--sm.NIPT

      ,sm.NRSERIAL

      ,SHENIM1= 'FATURE SHOQERUESE'

      ,sm.SHENIM2

      ,sm.SHENIM3

      ,sm.SHENIM4

      ,sm.NRMAG

      ,sm.KMAG

      ,sm.NRDFK

      ,sm.POSTIM

      ,sm.LETER

      ,sm.FIRSTDOK

      ,sm.TAGNR

      ,TIMED = SM.DATECREATE

      ,sm.KLASIFIKIM

      ,sm.USI

      ,sm.USM

      ,sm.TAG

      ,sm.TROW

      ,sm.EXPORT

      ,sm.KONFIRM

      ,sm.DATECREATE

      ,sm.DATEEDIT

      ,sm.TAGRND

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

      ,smscr.NJESI

      ,smscr.CMIMM

      ,smscr.SASI

      ,smscr.CMIMBS

      ,smscr.VLERABS

      ,smscr.VLERAM

      ,vlpatvsh1 = 0 --smscr.VLPATVSH/((100+ convert(float, kt.PERQTVSH))/100) --smscr.VLPATVSH

      ,vltvsh1=0--(smscr.VLPATVSH-smscr.VLPATVSH/((100+ convert(float, kt.PERQTVSH))/100))-- smscr.VLTVSH

      ,smscr.KOEFSHB

      ,smscr.NJESINV

      ,smscr.TIPKLL

      ,smscr.BC

      ,smscr.KOMENT

      ,smscr.RIMBURSIM

      ,smscr.DTSKADENCE

      ,smscr.SERI

      ,smscr.TROW

      ,smscr.TAGNR

      ,smscr.GARANCI

      ,smscr.CMRIMBURSIM

      ,smscr.VLRIMBURSIM

      ,smscr.PESHANET

      ,smscr.PESHABRT

      ,smscr.PROMOC

      ,smscr.PROMOCTIP

      ,smscr.PROMOCKOD

      ,smscr.SASIKONV

      ,smscr.NRSERIAL

      ,smscr.KONVERTART

      ,smscr.PROMPTPROD1

      ,smscr.KODKLF

      ,smscr.ISNOTFIRO

      ,smscr.ISAMB

      ,smscr.STATROW

      ,smscr.ORDERSCR

      ,smscr.TAGRND

         ,ZBRITJERRESHT = 0

         ,operatori = 'vh151ht889'

         ,businessunit = (select vlera from konfig where fusha = 'FISCBUSINESSUNIT')

         ,TCRCODE = ''

         ,softnum = (select vlera from konfig where fusha = 'FISCSOFTNUM')

  FROM dbo.FH SM

  inner join FHSCR SMSCR on smscr.nrd = sm.nrrendor

  inner join artikuj a on a.kod = smscr.kartllg

  inner join KLASATVSH kt on kt.KOD = a.KODTVSH

  where smscr.nrd = @id

 

 

-- SELECT * FROM KONFIG
GO
