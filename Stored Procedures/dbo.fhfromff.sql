SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[fhfromff](@nrff as int=0)
as

if @nrff<>0
begin
DECLARE @nrdok as int;
DECLARE @NRRENDORNEW AS INT;
set @nrdok = (select isnull(max(nrdok),1) from fh)+1;

INSERT INTO FH (NRMAG, TIP, KMAG, NRDOK, NRFRAKS, DATEDOK, SHENIM1, SHENIM2, SHENIM3, SHENIM4,
 NRDFK, DOK_JB, NRRENDORFAT, TIPFAT, KTH, DST, POSTIM, LETER, FIRSTDOK, KODLM, KLASIFIKIM, 
USI, USM, TAG, TROW, TAGNR, KALIMLMZGJ)
select nrmag,'H',kmag,@nrdok,0,datedok,shenim1,shenim2,shenim3,shenim4,
0,1,@nrff,'F',0,'BL',0,0,'',NULL,NULL,
'A','A',0,0,-1,NULL FROM FF WHERE NRRENDOR = @NRFF AND ISNULL(NRMAG,'')<>''

SET @NRRENDORNEW = (SELECT @@IDENTITY);

INSERT INTO FHSCR(NRD, KOD, KODAF, KARTLLG, NRRENDKLLG, PERSHKRIM, NJESI, SASI, CMIMM, VLERAM, 
KMON, VLERAFT, CMIMBS, VLERABS, KOEFSHB, NJESINV, TIPKLL, BC, KOMENT, PROMOC, PROMOCTIP, RIMBURSIM, 
DTSKADENCE, SERI, GJENROWAUT, CMIMOR, VLERAOR, TROW, TAGNR, TIPKTH, TIPFR, SASIFR, VLERAFR, FBARS, 
FCOLOR, FLENGTH, FPROFIL)
SELECT @NRRENDORNEW,KOD,KODAF,KARTLLG,NRRENDKLLG,PERSHKRIM,NJESI,SASI,CMIMM,VLERAM,
'',VLERAM,CMIMBS,VLERABS,1,NJESINV,TIPKLL,NULL,NULL,NULL,NULL,0,
NULL,NULL,0,CMIMM,VLERAM,0,-1,NULL,NULL,NULL,NULL,NULL,
NULL,NULL,NULL FROM FFSCR WHERE NRD = @NRFF AND ISNULL(NRRENDKLLG,'')<>''

UPDATE FF SET NRRENDDMG = @NRRENDORNEW WHERE NRRENDOR = @NRFF

end

GO
