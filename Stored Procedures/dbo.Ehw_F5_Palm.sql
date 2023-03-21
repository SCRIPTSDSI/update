SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







-- Exec Ehw_F5_Palm @PServer='F5Palm',
--                  @PPathAdress='C:\PalmProve\F5PalmIbd.mdb',
--                  @PKodArtKp= 'P',          @PKodArtKs= 'Pz',
--                  @PKodKliKp= 'K00050',     @PKodKliKs= 'K75z',
--                  @PKodMagKp= 'M01',        @PKodMagKs= 'M75z',
--                  @PKodAgjKp= 'A',          @PKodAgjKs= 'z',
--                  @PDeriDtKp= '04/08/2009', @PDeriDtKs= '04/08/2009',
--                  @PKodUsrKp= 'U',          @PKodUsrKs= 'Uz'

Create        procedure [dbo].[Ehw_F5_Palm]
  (
  @PServer As Varchar(100),
  @PPathAdress As Varchar(150),
  @PKodArtKp As Varchar(20),
  @PKodArtKs As Varchar(20),
  @PKodKliKp As Varchar(20),
  @PKodKliKs As Varchar(20),
  @PKodMagKp As Varchar(20),
  @PKodMagKs As Varchar(20),
  @PKodAgjKp As Varchar(20),
  @PKodAgjKs As Varchar(20),
  @PDeriDtKp As Varchar(20),
  @PDeriDtKs As Varchar(20),
  @PKodUsrKp As Varchar(20),
  @PKodUsrKs As Varchar(20)
  )
as

Set @PKodArtKp=QuoteName(@PKodArtKp,'''')
Set @PKodArtKs=QuoteName(@PKodArtKs,'''')
Set @PKodKliKp=QuoteName(@PKodKliKp,'''')
Set @PKodKliKs=QuoteName(@PKodKliKs,'''')
Set @PKodMagKp=QuoteName(@PKodMagKp,'''')
Set @PKodMagKs=QuoteName(@PKodMagKs,'''')
Set @PKodAgjKp=QuoteName(@PKodAgjKp,'''')
Set @PKodAgjKs=QuoteName(@PKodAgjKs,'''')
Set @PDeriDtKp=QuoteName(@PDeriDtKp,'''')
Set @PDeriDtKs=QuoteName(@PDeriDtKs,'''')
Set @PKodUsrKp=QuoteName(@PKodUsrKp,'''')
Set @PKodUsrKs=QuoteName(@PKodUsrKs,'''')

Declare @VPike     Varchar(5)
Declare @VString1  Varchar(30)
Declare @VString2  Varchar(30)
Set @VPike      =QuoteName('.','''')
Set @VString1   =QuoteName('D','''')
Set @VString2   =QuoteName('','''')

--Declare @PServer     Varchar(50)    -- Do vijne si parameter
--Declare @PPathAdress Varchar(150)
--Set @PServer     ='F5Palm'
--Set @PPathAdress ='C:\PalmProve\F5PalmIbd.mdb'

Declare @VCommand    Varchar(150)
Declare @VServer     Varchar(50)
Declare @QServer     Varchar(50)
Declare @VPathAdress Varchar(150)
Set @QServer     =@PServer
Set @VServer     =QuoteName(@QServer,'''')
Set @VPathAdress =QuoteName(@PPathAdress,'''')

Exec('SP_DROPSERVER '+@VServer+',"Droplogins"')
Exec('SP_ADDLINKEDSERVER '+@VServer+',"Access 2000","Microsoft.Jet.OLEDB.4.0",'+@VPathAdress)
Exec('SP_ADDLINKEDSRVLOGIN '+@VServer+',False,"sa","Admin",null')

Set @VServer  = Case When @QServer<>'' Then @QServer+'...' Else @QServer End
Set @VCommand = @VServer+'GjendjeKlient'

-- Export F5-Access
Exec('DELETE FROM '+@VServer+'MGExpF5')
--
Exec('DELETE FROM '+@VServer+'ListeArtikuj')
Exec('DELETE FROM '+@VServer+'ListeKlient')
Exec('DELETE FROM '+@VServer+'ListeAgjent')
Exec('DELETE FROM '+@VServer+'ListeMagazina')
--
Exec('DELETE FROM '+@VServer+'KlientGjendje')
--Exec('DELETE FROM '+@VServer+'KlientCmim')
--

--Exec('DELETE FROM '+@VServer+'TipDok')
Exec('DELETE FROM '+@VServer+'ListNrKufij')


-- Import F5-Access
Exec('DELETE FROM '+@VServer+'KlientPagesa')
Exec('DELETE FROM '+@VServer+'Porosi')
Exec('DELETE FROM '+@VServer+'FJIMPF5')
Exec('DELETE FROM '+@VServer+'MGIMPF5')


-- Export F5-Access Artikuj,Klient,Magazina,AgjentShitje

Exec('INSERT INTO '+@VServer+'ListeArtikuj (KOD,EMERTIM,EMERTIMSH, 
                                            CMSH1,CMSH2,CMSH3,CMSH4,CMSH5,CMSH6,CMSH7,CMSH8,CMSH9,CMSH10,CMSHPLM1,CMSHPLM2,
                                            KLASIF1,KLASIF2,KLASIF3,NJESI,BARKOD,NOTACTIV)
      SELECT KOD, PERSHKRIM,PERSHKRIMSH,
             CMSH, CMSH1,CMSH2,CMSH3,CMSH4,CMSH5,CMSH6,CMSH7,CMSH8,CMSH9,CMSHPLM1,CMSHPLM2,
             KLASIF,KLASIF2,KLASIF3,NJESI,BC,NOTACTIV
        FROM ARTIKUJ 
       WHERE (KOD >='+@PKodArtKp+') AND (KOD<='+@PKodArtKs+')')

Exec('INSERT INTO '+@VServer+'ListeKlient (KOD,PERSHKRIM, PERFAQESUES, NIPT,NIPTCERTIFIKATE,GRUP,VENDNDODHJE,AGJENTSHITJE, KMAG, NOTACTIV)
      SELECT KOD, PERSHKRIM, PERFAQESUES, NIPT,NIPTCERTIFIKATE,GRUP,VENDNDODHJE,AGJENTSHITJE, KMAG, ISNULL(NOTACTIV,0) 
        FROM KLIENT 
       WHERE (KOD >='+@PKodKliKp+') AND (KOD<='+@PKodKliKs+')')

Exec('INSERT INTO '+@VServer+'ListeMagazina (KOD,PERSHKRIM, PERGJ, NIPT,NIPTCERTIFIKATE,TIPI,ZONA, KODARKE)
      SELECT KOD, PERSHKRIM, PERGJ, NIPT, NIPTCERTIFIKATE, TIPI, ZONA, KOD 
        FROM MAGAZINA 
       WHERE (KOD >='+@PKodMagKp+') AND (KOD<='+@PKodMagKs+')')

Exec('INSERT INTO '+@VServer+'ListeAgjent (KOD,PERSHKRIM)
      SELECT KOD, PERSHKRIM 
        FROM AGJENTSHITJE 
    ORDER BY KOD')

Exec('INSERT INTO '+@VServer+'KlientCmim (KODKL,KOD,CMIM,ACTIV)
      SELECT KODKL, KOD, CMSH, ACTIV
        FROM KLIENTCM 
       WHERE (KODKL >='+@PKodKliKp+') AND (KODKL<='+@PKodKliKs+') AND
             (KOD   >='+@PKodArtKp+') AND (KOD  <='+@PKodArtKs+')')

Exec('INSERT INTO '+@VServer+'KlientGjendje (KOD,KMON,GJENDJE) 
      SELECT LEFT(KOD,CASE WHEN CHARINDEX('+@VPike+',KOD)>0 THEN CHARINDEX('+@VPike+',KOD)-1 ELSE LEN(KOD) END), 
             KMON,
             GJENDJE=ROUND(SUM(CASE WHEN TREGDK='+@VString1+' THEN VLEFTAMV ELSE 0-VLEFTAMV END),0) 
        FROM DKL 
       WHERE (KOD >= '+@PKodKliKp+') AND (KOD<='+@PKodKliKs+') AND DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+')
    GROUP BY KMON,KOD 
      HAVING ABS(ROUND(SUM(CASE WHEN TREGDK='+@VString1+' THEN VLEFTAMV ELSE 0-VLEFTAMV END),0))>=1 
    ORDER BY KOD ')
Exec('UPDATE A 
         SET A.PERSHKRIM=B.PERSHKRIM 
        FROM '+@VServer+'KlientGjendje A INNER JOIN '+@VServer+'ListeKlient B ON A.KOD=B.KOD ') 

Set @VString1=QuoteName('S','''')
Exec('INSERT INTO '+@VServer+'ListNrKufij (KOD,NRKUFIP,NRKUFIS,NRKUFIPJT,NRKUFISJT)
      SELECT KODUS, NRKUFIP, NRKUFIS, NRKUFIP, NRKUFIS
        FROM DRHUSER 
       WHERE (KODUS >= '+@PKodUsrKp+') AND (KODUS<='+@PKodUsrKs+') AND (MODUL='+@VString1+')
    ORDER BY KODUS ')

Set @VString1=QuoteName('Furnizim Ditor', '''')
Set @VString2=QuoteName('FU','''')

Exec('INSERT INTO '+@VServer+'MGExpF5 
            (KODKL,KMAG,NRDOK,DATEDOK,KOD,SASI,CMIM,DHURATE,SHENIM1,LLOJDOK) 
      SELECT KMAG,KMAG,NRDOK,DATEDOK,KARTLLG,SASI,ARTIKUJ.CMSH,0,'+@VString1+','+@VString2+'
        FROM FH INNER JOIN FHSCR ON FH.NRRENDOR=FHSCR.NRD 
                INNER JOIN ARTIKUJ ON FHSCR.KARTLLG=ARTIKUJ.KOD 
       WHERE (KMAG >= '+@PKodMagKp+') AND (KMAG<='+@PKodMagKs+') AND 
             (DATEDOK>=DBO.DATEVALUE('+@PDeriDtKp+') AND DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+')) AND
             (DST='+@VString2+')
    ORDER BY KMAG,NRDOK,DATEDOK,FhSCR.KOD')





GO
