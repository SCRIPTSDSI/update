SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[FJ_INSERT_FJ_AUTOSM]
(
--@NRDOK,@PKODUSER,@PDATEDOK,@PKODFKL,@PKMON,@PKMAG,
--@PKURS2,@VLERZBR,@KATEGORI,@PNRRENDOR=@PNRRENDOR OUTPUT
@PNRDOK	   AS INTEGER,
@PKODUSER  AS VARCHAR(10),--kodi i userit te finances
@PDATEDOK  AS DATETIME,   --data e fatures
@PKODFKL   AS VARCHAR(10),--kod klienti i f5 
@PKMON     AS VARCHAR(3), --kod i monedhes 
@PKMAG     AS VARCHAR(3), --kod magazina
@PKURS2    AS FLOAT,      --kursi (ne rast lek=1_
@VLERZBR   AS FLOAT,
@PKLASIFIKIM AS VARCHAR(60),
@PNRRENDOR AS INT OUTPUT  --kthen nrrendorin e fj te sapo krijuar
)
AS
DECLARE @VNRDOKMIN AS INTEGER
DECLARE @VNRDOKMAX AS INTEGER
DECLARE @VNRDOK AS INTEGER


SET @VNRDOKMIN=ISNULL((SELECT NRKUFIP FROM DRHUSER WHERE MODUL='S' AND KODUS=@PKODUSER),1)
SET @VNRDOKMAX=ISNULL((SELECT NRKUFIS FROM DRHUSER WHERE MODUL='S' AND KODUS=@PKODUSER),999999999)

SET @VNRDOK   =ISNULL((SELECT MAX(NRDOK) AS NRMAX FROM FJ 
                WHERE (YEAR(DATEDOK)=YEAR(@PDATEDOK)) AND (NRDOK BETWEEN @VNRDOKMIN AND @VNRDOKMAX))+1,@VNRDOKMIN)


INSERT INTO FJ 
      (DATEDOK,
       KTH,
       NRDOK,
       NRFRAKS,
       KOD,
       KODFKL,
       KMON,
       KLASAKF,
       VENHUAJ,
       NIPT, 
       NRSERIAL,
       KODFISKAL,
       RRETHI,
       SHENIM1,
       SHENIM2,
       SHENIM3,
       SHENIM4, 
       NRDSHOQ, 
       DTDSHOQ, 
       NRRENDDMG, 
       TIPDMG, 
       NRMAG, 
       KMAG, 
       NRDMAG, 
       FRDMAG, 
       DTDMAG, 
       MODPG, 
       DTAF, 
       KURS1, 
       KURS2,
       VLPATVSH, 
       VLTVSH, 
       VLERZBR, 
       VLERTOT, 
       PARAPG, 
       PERQTVSH, 
       PERQZBR, 
       LLOGTVSH, 
       LLOGZBR,  
       LLOGARK,  
       KODARK, 
       NRRENDORAR, 
       NRDFK, 
       NRDITAR, 
       POSTIM, 
       LETER, 
       FIRSTDOK, 
       ISDG, 
       NRDOKDG, 
       TAGNR,
       NRDITARSHL, 
       NRDITARPRMC, 
       NRDFTEXTRA, 
       ISDOKSHOQ, 
       NRRENDOROF, 
       NRRENDOROR, 
       --NRRENDORKO, 
       NRRENDORORGFJ, 
       GRUPIMFT, 
       TIPFT, 
       KLASIFIKIM, 
       KLASIFIKIM1, 
       VLTAX, 
       --DTFATKP, 
      -- DTFATKS, 
       USI, 
       USM, 
       TAG, 
       TROW) 
SELECT DATEDOK=@PDATEDOK, 
       KTH=0, 
       NRDOK=@VNRDOK, 
       NRFRAKS=0, 
       KOD=@PKODFKL+'.'+@PKMON, 
       KODFKL=@PKODFKL, 
       KMON=@PKMON, 
       KLASAKF=(SELECT GRUP FROM KLIENT WHERE KLIENT.KOD=@PKODFKL), 
       VENHUAJ=(SELECT VENDHUAJ FROM KLIENT WHERE KLIENT.KOD=@PKODFKL), 
       NIPT=(SELECT NIPT FROM KLIENT WHERE KLIENT.KOD=@PKODFKL), 
       NRSERIAL=@VNRDOK, 
       KODFISKAL=ISNULL((SELECT KODFISKAL FROM KLIENT WHERE KLIENT.KOD=@PKODFKL),''), 
       RRETHI=ISNULL((SELECT V.PERSHKRIM FROM VENDNDODHJE V INNER JOIN KLIENT K ON V.KOD=K.VENDNDODHJE WHERE K.KOD=@PKODFKL),''), 
       SHENIM1=(SELECT PERSHKRIM FROM KLIENT WHERE KLIENT.KOD=@PKODFKL), 
       SHENIM2='', 
       SHENIM3='', 
       SHENIM4='', 
       NRDSHOQ=@VNRDOK, 
       DTDSHOQ=@PDATEDOK, 
       NRRENDDMG=0, 
       TIPDMG='D', 
       NRMAG=ISNULL((SELECT NRRENDOR FROM MAGAZINA WHERE MAGAZINA.KOD=@PKMAG),0), 
       KMAG=@PKMAG, 
       NRDMAG=CASE WHEN @PKMAG<>'' THEN ISNULL((SELECT MAX(NRDOK) FROM FD A WHERE (A.KMAG=@PKMAG) AND YEAR(A.DATEDOK)=YEAR(@PDATEDOK)),0)+1   ELSE 0 END, 
       FRDMAG=0, 
       DTDMAG=CASE WHEN @PKMAG<>'' THEN @PDATEDOK ELSE 0 END, 
       MODPG='', 
       DTAF=0, 
       KURS1=1, 
       KURS2=@PKURS2,
       VLPATVSH=0, 
       VLTVSH=0, 
       VLERZBR=@VLERZBR, 
       VLERTOT=0, 
       PARAPG=0, 
       PERQTVSH=ISNULL((SELECT PERQTATS FROM CONFIGLM),0), 
       PERQZBR=0, 
       LLOGTVSH=ISNULL((SELECT LLOGTATS FROM CONFIGLM),''), 
       LLOGZBR=ISNULL((SELECT LLOGZBR FROM CONFIGLM),0),  
       LLOGARK=ISNULL((SELECT LLOGARK FROM CONFIGLM),0),  
       KODARK='', 
       NRRENDORAR=0, 
       NRDFK=0, 
       NRDITAR=0, 
       POSTIM=0, 
       LETER=0, 
       FIRSTDOK='', 
       ISDG=0, 
       NRDOKDG=0, 
       TAGNR=0,
       NRDITARSHL=0, 
       NRDITARPRMC=0, 
       NRDFTEXTRA=0, 
       ISDOKSHOQ=0, 
       NRRENDOROF=0, 
       NRRENDOROR=0, 
      -- NRRENDORKO=0, 
       NRRENDORORGFJ=0, 
       GRUPIMFT='', 
       TIPFT='02', 
       KLASIFIKIM='', 
       KLASIFIKIM1=@PKLASIFIKIM, 
       VLTAX=0, 
       --DTFATKP=@PDATEDOK, 
       --DTFATKS=@PDATEDOK, 
       USI='A', 
       USM='A', 
       TAG=0, 
       TROW=0 

SET @PNRRENDOR=@@IDENTITY

UPDATE FJ SET FIRSTDOK='S'+CAST(CAST(@PNRRENDOR AS BIGINT) AS VARCHAR) WHERE NRRENDOR=@PNRRENDOR

RETURN
GO