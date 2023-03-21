SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 --declare @data as datetime
 --set @data = (select dbo.DATEVALUE('29/10/2016'))
 --exec importSmFromSmbak @data,@data
 
 CREATE procedure [dbo].[importSmFromSmbak](@dnga as datetime,@dderi as datetime)
 as
 
update sm set TAGNR = -1
update SMSCR set TAGNR = -1

INSERT INTO SM
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
           ,KLASIFIKIM           ,USI           ,USM           ,TAG
           ,TROW           ,VLTAX           ,PGKLIENT           ,KLIENTID
           ,KARTE           ,PIKE           ,LASTMODIF           ,NRDSKONTO
           ,EMERKOMP           ,EXPORT           ,NEKASE           ,VOUCHER)
 select     DATEDOK           ,KTH           ,NRDOK           ,NRFRAKS
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
           ,ISDG           ,NRDOKDG           ,DTDOKDG           ,tagnr = nrrendor
           ,NRDITARSHL           ,NRRENDKF           ,NRFRAKSKF           ,NRDFTEXTRA
           ,ISDOKSHOQ           ,NRRENDOROF           ,NRRENDOROR           ,TIMED
           ,KLASIFIKIM           ,USI           ,USM           ,TAG
           ,TROW           ,VLTAX           ,PGKLIENT           ,KLIENTID
           ,KARTE           ,PIKE           ,LASTMODIF           ,NRDSKONTO
           ,EMERKOMP           ,EXPORT           ,NEKASE           ,VOUCHER
from SMBAK where DATEDOK >=@dnga and DATEDOK <=@dderi

INSERT INTO SMSCR
           (NRD           ,KOD           ,KODAF           ,KARTLLG
           ,PERSHKRIM           ,NRRENDKLLG           ,LLOGARIPK           ,NJESI
           ,CMSHZB0           ,CMIMM           ,SASI           ,PERQDSCN
           ,CMIMBS           ,VLERABS           ,VLERAM           ,VLPATVSH
           ,VLTVSH           ,PERQTVSH           ,KOEFSHB           ,NJESINV
           ,TIPKLL           ,BC           ,KLASIF           ,KLASIF2
           ,KOMENT           ,NOTMAG           ,RIMBURSIM           ,DTSKADENCE
           ,SERI           ,KODKR           ,TROW           ,TAGNR
           ,VLTAX           ,KODTVSH                      ,NRRESHT
           ,DGAVOUCHER           ,DGASMARTCARD)
           select		
            sm.NRRENDOR		,a.KOD           ,a.KODAF           ,a.KARTLLG
           ,a.PERSHKRIM           ,a.NRRENDKLLG           ,a.LLOGARIPK           ,a.NJESI
           ,a.CMSHZB0           ,a.CMIMM           ,a.SASI           ,a.PERQDSCN
           ,a.CMIMBS           ,a.VLERABS           ,a.VLERAM           ,a.VLPATVSH
           ,a.VLTVSH           ,a.PERQTVSH           ,a.KOEFSHB           ,a.NJESINV
           ,a.TIPKLL           ,a.BC           ,a.KLASIF           ,a.KLASIF2
           ,a.KOMENT           ,a.NOTMAG           ,a.RIMBURSIM           ,a.DTSKADENCE
           ,a.SERI           ,a.KODKR           ,a.TROW           ,TAGNR=a.NRD
           ,a.VLTAX           ,a.KODTVSH                      ,a.NRRESHT
           ,a.DGAVOUCHER           ,a.DGASMARTCARD
           from SMBAKSCR a
           inner join SMBAK b on b.NRRENDOR = a.NRD
           inner join SM on sm.TAGNR = a.NRD 
           where b.DATEDOK >=@dnga and b.DATEDOK <=@dderi

--update a
--set a.nrd  = b.nrrendor
--from SMSCR a
--inner join SM b on b.TAGNR = a.TAGNR
--where a.TAGNR<>-1

GO
