SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE     PROCEDURE [dbo].[SM_INSERT_SM]
(
@PKODUSER  AS VARCHAR(10),--kod useri i f5
@PDATEDOK  AS DATETIME,   --date fature
@PKODFKL   AS VARCHAR(10),--kod klienti
@PKMON     AS VARCHAR(3), --kod monedhe
@PKMAG     AS VARCHAR(3), --kod magazine
@PKURS2    AS FLOAT,      --kursi 1 ne rastin e monedhes baze
@PNRDOK    AS INT,        --nr i dokumentit
@PPGKLIENT AS FLOAT,      --pagesa e klientit
@PKLIENTID AS VARCHAR(20),--kod i kartes se klientit
@PKODKASE  AS VARCHAR(10),--kod kase f50

@PNRRENDOR AS INT OUTPUT  --kthen Nrrendor per SM e sapo shtuar
)
AS



INSERT INTO SM 
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
       NRDFK, 
       NRDITAR, 
       POSTIM, 
       LETER, 
       FIRSTDOK, 
       ISDG, 
       NRDOKDG, 
       TAGNR,
       NRDITARSHL, 
       NRDFTEXTRA, 
       ISDOKSHOQ, 
       NRRENDOROF, 
       NRRENDOROR, 
       KLASIFIKIM, 
       VLTAX,
       PGKLIENT,
       KLIENTID,
       KASE, 
       USI, 
       USM, 
       TAG, 
       TROW) 
SELECT DATEDOK=@PDATEDOK, 
       KTH=0, 
       NRDOK=@PNRDOK, 
       NRFRAKS=0, 
       KOD=@PKODFKL+'.'+@PKMON, 
       KODFKL=@PKODFKL, 
       KMON=@PKMON, 
       KLASAKF=(SELECT GRUP FROM KLIENT WHERE KLIENT.KOD=@PKODFKL), 
       VENHUAJ=(SELECT VENDHUAJ FROM KLIENT WHERE KLIENT.KOD=@PKODFKL), 
       NIPT=(SELECT NIPT FROM KLIENT WHERE KLIENT.KOD=@PKODFKL), 
       NRSERIAL=@PNRDOK, 
       KODFISKAL=ISNULL((SELECT KODFISKAL FROM KLIENT WHERE KLIENT.KOD=@PKODFKL),''), 
       RRETHI=ISNULL((SELECT V.PERSHKRIM FROM VENDNDODHJE V INNER JOIN KLIENT K ON V.KOD=K.VENDNDODHJE WHERE K.KOD=@PKODFKL),''), 
       SHENIM1=(SELECT PERSHKRIM FROM KLIENT WHERE KLIENT.KOD=@PKODFKL), 
       SHENIM2=(SELECT ADRESA1   FROM KLIENT WHERE KLIENT.KOD=@PKODFKL), 
       SHENIM3='', 
       SHENIM4='', 
       NRDSHOQ=@PNRDOK, 
       DTDSHOQ=@PDATEDOK, 
       NRRENDDMG=0, 
       TIPDMG='D', 
       NRMAG=0, 
       KMAG=@PKMAG, 
       NRDMAG=0, 
       FRDMAG=0, 
       DTDMAG=CASE WHEN @PKMAG<>'' THEN @PDATEDOK ELSE 0 END, 
       MODPG='', 
       DTAF=0, 
       KURS1=1, 
       KURS2=@PKURS2,
       VLPATVSH=0, 
       VLTVSH=0, 
       VLERZBR=0, 
       VLERTOT=0, 
       PARAPG=0, 
       PERQTVSH=ISNULL((SELECT PERQTATS FROM CONFIGLM),0), 
       PERQZBR=0, 
       LLOGTVSH=ISNULL((SELECT LLOGTATS FROM CONFIGLM),''), 
       LLOGZBR=ISNULL((SELECT LLOGZBR FROM CONFIGLM),0),  
       LLOGARK=ISNULL((SELECT LLOGARK FROM CONFIGLM),0),  
       NRDFK=0, 
       NRDITAR=0, 
       POSTIM=0, 
       LETER=0, 
       FIRSTDOK='', 
       ISDG=0, 
       NRDOKDG=0, 
       TAGNR=0,
       NRDITARSHL=0, 
       NRDFTEXTRA=0, 
       ISDOKSHOQ=0, 
       NRRENDOROF=0, 
       NRRENDOROR=0, 
       KLASIFIKIM='', 
       VLTAX=0,
       PGKLIENT=@PPGKLIENT,
       KLIENTID=@PKLIENTID, 
       KASE    =@PKODKASE,
       USI='A', 
       USM='A', 
       TAG=0, 
       TROW=0 

SET @PNRRENDOR=@@IDENTITY

UPDATE SM SET FIRSTDOK='S'+CAST(CAST(@PNRRENDOR AS BIGINT) AS VARCHAR)

RETURN





GO
