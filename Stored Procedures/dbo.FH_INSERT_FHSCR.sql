SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE    PROCEDURE [dbo].[FH_INSERT_FHSCR]
(
@PNrRendor INT,        --Nrrendori i FH-se 
@KODART    VARCHAR(30),--kod artikulli
@CMIM      FLOAT,      --cmimi
@SASI      FLOAT,      --sasia
@VLERA     FLOAT       --vlera
)
AS
DECLARE @VNrRendorScr INT


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
       FPROFIL,
       KOEFICIENT)

SELECT 
       NRD=@PNrRendor,
       KOD       =(SELECT KMAG FROM FH A WHERE A.NRRENDOR=@PNrRendor)+'.'+@KODART+'...',
       KODAF     =@KODART,
       KARTLLG   =@KODART,
       NRRENDKLLG=(SELECT NRRENDOR  FROM ARTIKUJ A WHERE A.KOD=@KODART),
       PERSHKRIM =(SELECT PERSHKRIM FROM ARTIKUJ A WHERE A.KOD=@KODART),
       NJESI     =(SELECT NJESI     FROM ARTIKUJ A WHERE A.KOD=@KODART),
       SASI      =@SASI,
       CMIMM     =@CMIM,
       VLERAM    =@VLERA,
       KMON      ='',
       VLERAFT   =@VLERA,
       CMIMBS    =@CMIM,
       VLERABS   =@VLERA,
       KOEFSHB   =1,
       NJESINV   =(SELECT NJESI     FROM ARTIKUJ A WHERE A.KOD=@KODART),
       TIPKLL    ='K',
       BC        =(SELECT BC        FROM ARTIKUJ A WHERE A.KOD=@KODART),
       KOMENT    =(SELECT SHENIM1   FROM FH A WHERE A.NRRENDOR=@PNrRendor),
       PROMOC    =0,
       PROMOCTIP ='',
       RIMBURSIM =0,
       DTSKADENCE=NULL,
       SERI      ='',
       GJENROWAUT=0,
       CMIMOR    =@CMIM,
       VLERAOR   =@VLERA,
       TROW      =0,
       TAGNR     =0,
       TIPKTH    ='',
       TIPFR     ='',
       SASIFR    =0,
       VLERAFR   =0,
       FBARS     =0,
       FCOLOR    ='',
       FLENGTH   ='',
       FPROFIL   ='',
       KOEFICIENT=0

SET @VNrRendorScr=@@IDENTITY

IF ISNULL((SELECT TOP 1 NRRENDOR FROM LMG A WHERE A.KOD=(SELECT KOD FROM FHSCR B WHERE B.NRRENDOR=@VNrRendorScr)),0)=0
  INSERT INTO LMG (KOD,PERSHKRIM,KMON,NRMAG,KMALL,SASI,VLERE,SASIM,VLEREM,SASITMP,VLERETMP,
                   SG1,SG2,SG3,SG4,SG5,SG6,SG7,SG8,SG9,SG10,TROW,TAGNR)
       SELECT      KOD=A.KOD,PERSHKRIM=A.PERSHKRIM,KMON='',NRMAG=0,KMALL='',SASI=0,VLERE=0,SASIM=0,VLEREM=0,SASITMP=0,VLERETMP=0,
                   SG1=(SELECT KMAG FROM FH B WHERE B.NRRENDOR=@PNrRendor),SG2=@KODART ,SG3='',SG4='',SG5='',SG6='',SG7='',SG8='',SG9='',SG10='',TROW=0,TAGNR=0
       FROM FHSCR A
      WHERE A.NRRENDOR=@VNrRendorScr




GO
