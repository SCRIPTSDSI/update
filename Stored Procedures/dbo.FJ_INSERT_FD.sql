SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[FJ_INSERT_FD]
(
@PNrRendor INT --nrrendor i fj nga do te gjenerohet fd-ja
)
AS

DECLARE @VNrRendorFD INT

DELETE FROM FD WHERE NRRENDOR=(SELECT NRRENDDMG FROM FJ A WHERE A.NRRENDOR=@PNrRendor) 

IF (SELECT COUNT('') FROM FJSCR A WHERE A.TIPKLL='K' AND A.NRD=@PNrRendor)>0
BEGIN
INSERT INTO FD
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
       KALIMLMZGJ)

SELECT NRMAG=(SELECT NRRENDOR FROM MAGAZINA B WHERE B.KOD=A.KMAG),
       TIP        ='D',
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
       TIPFAT     ='S',
       KTH        =0,
       DST        ='SH',
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
       KALIMLMZGJ =0
  FROM FJ A 
 WHERE A.NRRENDOR=@PNrRendor

SET @VNrRendorFD=@@IDENTITY

UPDATE FJ SET NRRENDDMG=@VNrRendorFD
  WHERE NRRENDOR=@PNrRendor

UPDATE FD SET FIRSTDOK='S'+CAST(CAST(@PNRRENDOR AS BIGINT) AS VARCHAR) WHERE NRRENDOR=@VNrRendorFD

INSERT INTO FDSCR
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
       PROMOC,
       PROMOCTIP,
       RIMBURSIM,
       DTSKADENCE,
       SERI,
       GJENROWAUT,
       CMIMOR,
       VLERAOR,
       TROW,
       TAGNR,
       TIPKTH,
       TIPFR,
       SASIFR,
       VLERAFR,
       FBARS,
       FCOLOR,
       FLENGTH,
       FPROFIL)
SELECT NRD=@VNrRendorFD,
       KOD       =LEFT(A.KOD,LEN(A.KOD)-LEN(B.KMON)),
       KODAF     =A.KODAF,
       KARTLLG   =A.KARTLLG,
       NRRENDKLLG=A.NRRENDKLLG,
       PERSHKRIM =A.PERSHKRIM,
       NJESI     =A.NJESI,
       SASI      =A.SASI,
       CMIMM     =Art.KostMes,
       VLERAM    =Art.KostMes * A.Sasi,
       KMON      ='',
       VLERAFT   =Art.KostMes,
       CMIMBS    =Art.KostMes,
       VLERABS   =Art.KostMes * A.Sasi,
       KOEFSHB   =1,
       NJESINV   =A.NJESINV,
       TIPKLL    ='K',
       BC        =A.BC,
       KOMENT    =A.KOMENT,
       PROMOC    =A.PROMOC,
       PROMOCTIP =A.PROMOCTIP,
       RIMBURSIM =A.RIMBURSIM,
       DTSKADENCE=A.DTSKADENCE,
       SERI      =A.SERI,
       GJENROWAUT=0,
       CMIMOR    =Art.KostMes,
       VLERAOR   =Art.KostMes * A.Sasi,
       TROW      =0,
       TAGNR     =0,
       TIPKTH    =A.TIPKTH,
       TIPFR     =A.TIPFR,
       SASIFR    =0,
       VLERAFR   =0,
       FBARS     =A.FBARS,
       FCOLOR    =A.FCOLOR,
       FLENGTH   =A.FLENGTH,
       FPROFIL   =''
  FROM FJSCR A INNER JOIN FJ B ON B.NRRENDOR=A.NRD
  Inner Join Artikuj Art on A.Kartllg = Art.Kod
 WHERE (A.NRD=@PNrRendor) AND (A.TIPKLL='K')
 
 --FUNDI I PROCEDURES SER RREGULLT FILLIM I KARTELAVE ME RECEPTURE
 

--SHPERTHIMI I RECEPTURES SE PRODUKTEVE


INSERT INTO FDSCR
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
       PROMOC,
       PROMOCTIP,
       RIMBURSIM,
       DTSKADENCE,
       SERI,
       GJENROWAUT,
       CMIMOR,
       VLERAOR,
       TROW,
       TAGNR,
       TIPKTH,
       TIPFR,
       SASIFR,
       VLERAFR,
       FBARS,
       FCOLOR,
       FLENGTH,
       FPROFIL)
SELECT NRD=@VNrRendorFD,
       KOD       =B.KMAG+'.'+ART2.KOD+'...',--LEFT(A.KOD,LEN(A.KOD)-LEN(B.KMON)),
       KODAF     =ART2.KOD,
       KARTLLG   =ART2.KOD,
       NRRENDKLLG=ART2.NRRENDOR,
       PERSHKRIM =ART2.PERSHKRIM,
       NJESI     =ASCR.NJESI,
       SASI      =A.SASI*ASCR.KOEFICIENT,
       CMIMM     =ART2.KostMes,
       VLERAM    =ASCR.KOEFICIENT*ART2.KostMes,
       KMON      ='',
       VLERAFT   =ASCR.KOEFICIENT*ART2.KostMes,
       CMIMBS    =ASCR.KOEFICIENT*ART2.KostMes,
       VLERABS   =ASCR.KOEFICIENT*ART2.KostMes,
       KOEFSHB   =1,
       NJESINV   =ASCR.NJESI,
       TIPKLL    ='K',
       BC        =ART2.BC,
       KOMENT    =A.KOMENT,
       PROMOC    =A.PROMOC,
       PROMOCTIP =A.PROMOCTIP,
       RIMBURSIM =A.RIMBURSIM,
       DTSKADENCE=A.DTSKADENCE,
       SERI      =A.SERI,
       GJENROWAUT=0,
       CMIMOR    =ASCR.KOEFICIENT*ART2.KostMes,
       VLERAOR   =ASCR.KOEFICIENT*ART2.KostMes,
       TROW      =0,
       TAGNR     =0,
       TIPKTH    =A.TIPKTH,
       TIPFR     =A.TIPFR,
       SASIFR    =A.SASIFR,
       VLERAFR   =ASCR.KOEFICIENT*ART2.KostMes,
       FBARS     =A.FBARS,
       FCOLOR    =A.FCOLOR,
       FLENGTH   =A.FLENGTH,
       FPROFIL   =''
  FROM ARTIKUJSCR AS ASCR
  INNER JOIN ARTIKUJ AS ART ON ART.NRRENDOR = ASCR.NRD
  INNER JOIN FJSCR A ON A.NRRENDKLLG = ASCR.NRD
  INNER JOIN FJ B ON B.NRRENDOR=A.NRD
  INNER JOIN ARTIKUJ AS ART2 ON ART2.KOD =ASCR.KOD
 WHERE (A.NRD =@PNrRendor) AND (A.TIPKLL='K') AND ART.TIP ='P'




 --STORNIMI I PRODUKTEVE
 INSERT INTO FDSCR
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
       PROMOC,
       PROMOCTIP,
       RIMBURSIM,
       DTSKADENCE,
       SERI,
       GJENROWAUT,
       CMIMOR,
       VLERAOR,
       TROW,
       TAGNR,
       TIPKTH,
       TIPFR,
       SASIFR,
       VLERAFR,
       FBARS,
       FCOLOR,
       FLENGTH,
       FPROFIL)
SELECT NRD=@VNrRendorFD,
       KOD       =LEFT(A.KOD,LEN(A.KOD)-LEN(B.KMON)),
       KODAF     =A.KODAF,
       KARTLLG   =A.KARTLLG,
       NRRENDKLLG=A.NRRENDKLLG,
       PERSHKRIM =A.PERSHKRIM,
       NJESI     =A.NJESI,
       SASI      =(-1)*A.SASI,
       CMIMM     =ART.KostMes,
       VLERAM    =(-1)*ART.KostMes * A.Sasi,
       KMON      ='',
       VLERAFT   =(-1)*ART.KostMes * A.Sasi,
       CMIMBS    =ART.KostMes,
       VLERABS   =(-1)*ART.KostMes * A.Sasi,
       KOEFSHB   =1,
       NJESINV   =A.NJESINV,
       TIPKLL    ='K',
       BC        =A.BC,
       KOMENT    =A.KOMENT,
       PROMOC    =A.PROMOC,
       PROMOCTIP =A.PROMOCTIP,
       RIMBURSIM =A.RIMBURSIM,
       DTSKADENCE=A.DTSKADENCE,
       SERI      =A.SERI,
       GJENROWAUT=0,
       CMIMOR    =ART.KostMes,
       VLERAOR   =(-1)*ART.KostMes * A.Sasi,
       TROW      =0,
       TAGNR     =0,
       TIPKTH    =A.TIPKTH,
       TIPFR     =A.TIPFR,
       SASIFR    =0,--A.SASIFR,
       VLERAFR   =0,--(-1)* ART.KostMes * A.Sasi,
       FBARS     =A.FBARS,
       FCOLOR    =A.FCOLOR,
       FLENGTH   =A.FLENGTH,
       FPROFIL   =''
  FROM FJSCR A INNER JOIN FJ B ON B.NRRENDOR=A.NRD
  INNER JOIN ARTIKUJ ART ON ART.KOD = A.KARTLLG
 WHERE (A.NRD=@PNrRendor) AND (A.TIPKLL='K') AND ART.TIP ='P'

END




GO
