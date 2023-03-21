SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE      PROCEDURE [dbo].[FF_INSERT_FH]
(
@PNrRendor INT --nrrendor i ff se nga do te gjenerohet FH-ja
)
AS

DECLARE @VNrRendorFH INT

DELETE FROM FH WHERE NRRENDOR=(SELECT NRRENDDMG FROM FF A WHERE A.NRRENDOR=@PNrRendor) 

IF (SELECT COUNT('') FROM FFSCR A WHERE A.TIPKLL='K' AND A.NRD=@PNrRendor)>0
BEGIN
INSERT INTO FH
      (NRMAG,
       TIP,
       KMAG,
       NRDOK,
       NRFRAKS,
       DATEDOK,
       SHENIM1,
       SHENIM2,
       SHENIM3,
       SHENIM4,
       NRDFK,
       DOK_JB,
       NRRENDORFAT,
       TIPFAT,
       KTH,
       DST,
       POSTIM,
       LETER,
       FIRSTDOK,
       KODLM,
       KLASIFIKIM,
       USI,
       USM,
       TAG,
       TROW,
       TAGNR,
       VLEXTRA,
       KALIMLMZGJ)

SELECT NRMAG=(SELECT NRRENDOR FROM MAGAZINA B WHERE B.KOD=A.KMAG),
       TIP        ='H',
       KMAG       =A.KMAG,
       NRDOK      =A.NRDMAG,
       NRFRAKS    =A.FRDMAG,
       DATEDOK    =A.DTDMAG,
       SHENIM1    =A.SHENIM1,
       SHENIM2    =A.SHENIM2,
       SHENIM3    ='',
       SHENIM4    ='',
       NRDFK      =0,
       DOK_JB     =1,
       NRRENDORFAT=@PNrRendor,
       TIPFAT     ='F',
       KTH        =0,
       DST        ='BL',
       POSTIM     =0,
       LETER      =0,
       FIRSTDOK   ='',
       KODLM      ='',
       KLASIFIKIM ='',
       USI        ='A',
       USM        ='A',
       TAG        =0,
       TROW       =0,
       TAGNR      =0,
       VLEXTRA    =0,
       KALIMLMZGJ =0
  FROM FF A 
 WHERE A.NRRENDOR=@PNrRendor

SET @VNrRendorFH=@@IDENTITY

UPDATE FF SET NRRENDDMG=@VNrRendorFH
  WHERE NRRENDOR=@PNrRendor

UPDATE FH SET FIRSTDOK='F'+CAST(CAST(@PNRRENDOR AS BIGINT) AS VARCHAR) WHERE NRRENDOR=@VNrRendorFH

INSERT INTO FHSCR
      (NRD,
       KOD,
       KODAF,
       KARTLLG,
       NRRENDKLLG,
       PERSHKRIM,
       NJESI,
       SASI,
       CMIMM,
       VLERAM,
       KMON,
       VLERAFT,
       CMIMBS,
       VLERABS,
       KOEFSHB,
       NJESINV,
       TIPKLL,
       BC,
       KOMENT,
       RIMBURSIM,
       DTSKADENCE,
       SERI,
       GJENROWAUT,
       CMIMOR,
       VLERAOR,
       TROW,
       TAGNR,
       TIPFR,
       SASIFR,
       VLERAFR,
       FPROFIL,
       KOEFICIENT)
SELECT NRD=@VNrRendorFH,
       KOD       =LEFT(A.KOD,LEN(A.KOD)-LEN(B.KMON)),
       KODAF     =A.KODAF,
       KARTLLG   =A.KARTLLG,
       NRRENDKLLG=A.NRRENDKLLG,
       PERSHKRIM =A.PERSHKRIM,
       NJESI     =A.NJESI,
       SASI      =A.SASI,
       CMIMM     =A.CMIMBS*B.KURS2/B.KURS1,
       VLERAM    =A.VLPATVSH*B.KURS2/B.KURS1,
       KMON      ='',
       VLERAFT   =A.VLPATVSH*B.KURS2/B.KURS1,
       CMIMBS    =A.CMIMBS*B.KURS2/B.KURS1,
       VLERABS   =A.VLPATVSH*B.KURS2/B.KURS1,
       KOEFSHB   =1,
       NJESINV   =A.NJESINV,
       TIPKLL    ='K',
       BC        =A.BC,
       KOMENT    =A.KOMENT,
       RIMBURSIM =A.RIMBURSIM,
       DTSKADENCE=A.DTSKADENCE,
       SERI      =A.SERI,
       GJENROWAUT=0,
       CMIMOR    =A.CMIMBS*B.KURS2/B.KURS1,
       VLERAOR   =A.VLPATVSH*B.KURS2/B.KURS1,
       TROW      =0,
       TAGNR     =0,
       TIPFR     =A.TIPFR,
       SASIFR    =A.SASIFR,
       VLERAFR   =A.VLPATVSH*B.KURS2/B.KURS1,
       FPROFIL   ='',
       KOEFICIENT=A.KOEFICIENT
  FROM FFSCR A INNER JOIN FF B ON B.NRRENDOR=A.NRD
 WHERE (A.NRD=@PNrRendor) AND (A.TIPKLL='K')



END





GO
