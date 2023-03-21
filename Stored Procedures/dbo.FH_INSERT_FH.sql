SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE       PROCEDURE [dbo].[FH_INSERT_FH]
(
@PKODUSER  AS VARCHAR(10),--kodi i userit te finances
@PDATEDOK  AS DATETIME   ,--data e fatures
@PKMAG     AS VARCHAR(3) ,--kod magazina
@PSHENIM1  AS VARCHAR(30),--Pershkrimi i FH-se
@PDST      AS VARCHAR(2) ,--destinacioni i FH-se

@PNRRENDOR AS INT OUTPUT  --kthen nrrendorin e fj te sapo krijuar
)
AS

DECLARE @VNRDOKMIN AS INTEGER
DECLARE @VNRDOK AS INTEGER

SET @VNRDOKMIN=1


SET @VNRDOK   =ISNULL((SELECT MAX(NRDOK) AS NRMAX FROM FH 
                WHERE (YEAR(DATEDOK)=YEAR(@PDATEDOK)) AND (KMAG=@PKMAG))+1,@VNRDOKMIN)


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
       KALIMLMZGJ,
       VLEXTRA) 

SELECT NRMAG=ISNULL((SELECT NRRENDOR FROM MAGAZINA WHERE MAGAZINA.KOD=@PKMAG),0),
       TIP='H',
       KMAG=@PKMAG,
       NRDOK=@VNRDOK,
       NRFRAKS=0,
       DATEDOK=@PDATEDOK,
       SHENIM1=@PSHENIM1,
       SHENIM2='',
       SHENIM3='',
       SHENIM4='',
       NRDFK=0,
       DOK_JB=0,
       NRRENDORFAT=0,
       TIPFAT=0,
       KTH=0,
       DST=@PDST,
       POSTIM=0,
       LETER=0,
       FIRSTDOK='',
       KODLM='658',
       KLASIFIKIM='',
       USI='A',
       USM='A',
       TAG=0,
       TROW=0,
       TAGNR=0,
       KALIMLMZGJ=0,
       VLEXTRA=0

SET @PNRRENDOR=@@IDENTITY

UPDATE FH SET FIRSTDOK='H'+CAST(CAST(@PNRRENDOR AS BIGINT) AS VARCHAR) WHERE NRRENDOR=@PNRRENDOR

RETURN











GO
