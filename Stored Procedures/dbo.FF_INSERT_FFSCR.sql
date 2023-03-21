SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [dbo].[FF_INSERT_FFSCR]
(
@PNrRendor INT,        --nrrendor i ff-se
@PTipKLL   VARCHAR(1), --'K' ne rastin kur ka magazine,'L' ne rastin kur eshte llogari
@KODART    VARCHAR(30),--kod artikulli
@CMIM      FLOAT,      --cmim pa tvsh
@SASI      FLOAT,      --sasia
@VPATVSH   FLOAT,      --vlera pa TVSH
@VTVSH     FLOAT,      --vlera e TVSH-se
@VTOT      FLOAT       --vlera totale
)
AS


INSERT INTO FFSCR
      (NRD, 
       KOD,
       KODAF,
       KARTLLG,
       PERSHKRIM,
       NRRENDKLLG,
       LLOGARIPK,
       NJESI,
       CMSHZB0,
       CMIMM,
       SASI,
       PERQDSCN,
       CMIMBS,
       VLERABS,
       VLERAM,
       VLPATVSH,
       VLTVSH,
       PERQTVSH,
       KOEFSHB,
       NJESINV,
       TIPKLL,
       BC,
       KOMENT,
       NOTMAG,
       RIMBURSIM,
       DTSKADENCE,
       SERI,
       KODKR,
       TROW,
       TAGNR,
       TIPFR,
       SASIFR,
       VLERAFR,
       VLTAX,
       KOEFICIENT)

SELECT NRD=@PNrRendor,
       KOD=CASE @PTipKLL WHEN 'K' THEN (SELECT KMAG FROM FF A WHERE A.NRRENDOR=@PNrRendor)+'.'+@KODART+'...'+(SELECT KMON FROM FF A WHERE A.NRRENDOR=@PNrRendor) 
                         WHEN 'L' THEN @KODART+'...'+(SELECT KMON FROM FF A WHERE A.NRRENDOR=@PNrRendor)  
                         WHEN 'R' THEN @KODART END,
       KODAF=@KODART,
       KARTLLG=@KODART,
       PERSHKRIM= CASE @PTipKLL WHEN 'K' THEN (SELECT PERSHKRIM FROM ARTIKUJ A WHERE A.KOD=@KODART) 
                                WHEN 'L' THEN (SELECT PERSHKRIM FROM LLOGARI A WHERE A.KOD=@KODART)  
                                WHEN 'R' THEN (SELECT PERSHKRIM FROM SHERBIM A WHERE A.KOD=@KODART) END,
       NRRENDKLLG=CASE @PTipKLL WHEN 'K' THEN (SELECT NRRENDOR  FROM ARTIKUJ A WHERE A.KOD=@KODART) 
                                WHEN 'L' THEN (SELECT NRRENDOR  FROM LLOGARI A WHERE A.KOD=@KODART)  
                                WHEN 'R' THEN (SELECT NRRENDOR  FROM SHERBIM A WHERE A.KOD=@KODART) END,
       LLOGARIPK= CASE @PTipKLL WHEN 'K' THEN '' 
                                WHEN 'L' THEN @KODART  
                                WHEN 'R' THEN @KODART END,
       NJESI=     CASE @PTipKLL WHEN 'K' THEN (SELECT NJESI     FROM ARTIKUJ A WHERE A.KOD=@KODART) 
                                WHEN 'L' THEN ('')  
                                WHEN 'R' THEN (SELECT NJESI     FROM SHERBIM A WHERE A.KOD=@KODART) END,
       CMSHZB0 =@CMIM,
       CMIMM   =@CMIM,
       SASI    =@SASI,
       PERQDSCN=0,
       CMIMBS  =@CMIM,
       VLERABS =@VTOT,
       VLERAM  =@VPATVSH,
       VLPATVSH=@VPATVSH,
       VLTVSH  =@VTVSH,
       PERQTVSH=(SELECT PERQTATS FROM CONFIGLM),
       KOEFSHB=1,
       NJESINV=    CASE @PTipKLL WHEN 'K' THEN (SELECT NJESI     FROM ARTIKUJ A WHERE A.KOD=@KODART) 
                                 WHEN 'L' THEN ('')  
                                 WHEN 'R' THEN (SELECT NJESI     FROM SHERBIM A WHERE A.KOD=@KODART) END,
       TIPKLL=@PTipKLL,
       BC= CASE  @PTipKLL WHEN 'K' THEN ISNULL((SELECT BC FROM ARTIKUJ A WHERE A.KOD=@KODART),'') ELSE '' END,
       KOMENT=(SELECT SHENIM2 FROM FF A WHERE A.NRRENDOR=@PNrRendor),
       NOTMAG=0,
       RIMBURSIM=0,
       DTSKADENCE=NULL,
       SERI='',
       KODKR='',
       TROW=0,
       TAGNR=0,
       TIPFR='',
       SASIFR=0,
       VLERAFR=0,
       VLTAX=0,
       KOEFICIENT=0


UPDATE FF SET
       VLPATVSH=(SELECT SUM(VLPATVSH) FROM FFSCR WHERE NRD=@PNrRendor),
       VLTVSH  =(SELECT SUM(VLTVSH)   FROM FFSCR WHERE NRD=@PNrRendor),
       VLERTOT =(SELECT SUM(VLERABS)  FROM FFSCR WHERE NRD=@PNrRendor)
  WHERE NRRENDOR=@PNrRendor



GO
