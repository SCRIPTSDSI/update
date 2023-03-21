SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE   PROCEDURE [dbo].[FJ_INSERT_FJSCR]
(
@PNrRendor INT,        --Nrrendori i fj-se 
@PTipKLL   VARCHAR(1), --'K' ne rastin e artikullit,'L' ne rastin e llogarise,'R' n rastin e sherbimit  
@KODART    VARCHAR(30),--kod artikulli,llogarie ose sherbimi
@CMIM      FLOAT,      --cmimi pa tvsh
@SASI      FLOAT,      --sasia
@VPATVSH   FLOAT,      --vlera pa tvsh
@VTVSH     FLOAT,      --vlera e tvsh-se
@VTOT      FLOAT       --vlera totale e rreshtit
)
AS


INSERT INTO FJSCR
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
       PROMOC,
       PROMOCTIP,
       NOTMAG,
       RIMBURSIM,
       DTSKADENCE,
       TIPREF,
       DATEDOKREF,
       SERI,
       NRDOKREF,
       KODKR,
       TIPKTH,
       NRDITAR,
       TROW,
       TAGNR,
       TIPFR,
       SASIFR,
       VLERAFR,
       VLTAX,
       FBARS,
       FCOLOR,
       FLENGTH,
       FPROFIL,
       KOEFICIENT,
       --DTKONT1,
       --DTKONT2,
       APLTVSH)

SELECT NRD=@PNrRendor,
       KOD=CASE @PTipKLL WHEN 'K' THEN (SELECT KMAG FROM FJ A WHERE A.NRRENDOR=@PNrRendor)+'.'+@KODART+'...'+(SELECT KMON FROM FJ A WHERE A.NRRENDOR=@PNrRendor) 
                         WHEN 'L' THEN @KODART+'...'+(SELECT KMON FROM FJ A WHERE A.NRRENDOR=@PNrRendor)  
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
       KOMENT=(SELECT SHENIM2 FROM FJ A WHERE A.NRRENDOR=@PNrRendor),
       PROMOC=0,
       PROMOCTIP='',
       NOTMAG=0,
       RIMBURSIM=0,
       DTSKADENCE=NULL,
       TIPREF='',
       DATEDOKREF=NULL,
       SERI='',
       NRDOKREF=0,
       KODKR='',
       TIPKTH='',
       NRDITAR=0,
       TROW=0,
       TAGNR=0,
       TIPFR='',
       SASIFR=0,
       VLERAFR=0,
       VLTAX=0,
       FBARS=0,
       FCOLOR='',
       FLENGTH='',
       FPROFIL='',
       KOEFICIENT=0,
       --DTKONT1=(SELECT DTFATKP FROM FJ A WHERE A.NRRENDOR=@PNrRendor),
       --DTKONT2=(SELECT DTFATKS FROM FJ A WHERE A.NRRENDOR=@PNrRendor),
       APLTVSH=CASE WHEN ISNULL((SELECT TATIM FROM ARTIKUJ WHERE KOD=@KODART),0)=1 THEN 1 ELSE 0 END


UPDATE FJ SET
       VLPATVSH=(SELECT SUM(VLPATVSH) FROM FJSCR WHERE NRD=@PNrRendor),
       VLTVSH  =(SELECT SUM(VLTVSH)   FROM FJSCR WHERE NRD=@PNrRendor),
       VLERTOT =(SELECT SUM(VLERABS)  FROM FJSCR WHERE NRD=@PNrRendor)
  WHERE NRRENDOR=@PNrRendor


GO
