SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- Exec Ehw_F5_Palm_Exp 
--                      @PDBaseFinName = 'EHW09',
--                      @PServer       = 'F5Palm',
--                      @PPathAdress   = 'E:\MobSell\F5PalmIbd.mdb',
--                      @PKodArtKp     = 'P',          @PKodArtKs   = 'Pz',
--                      @PKodKliKp     = 'K00050',     @PKodKliKs   = 'K75z',
--                      @PKodMagKp     = 'M',          @PKodMagKs   = 'M75z',
--                      @PKodAgjKp     = 'A',          @PKodAgjKs   = 'z',
--                      @PDeriDtKp     = '22/09/2009', @PDeriDtKs   = '22/09/2009',
--                      @PKodMagGjKp   = 'M01',        @PKodMagGjKs = 'M75z',
--                      @PKodUsrKp     = 'U',          @PKodUsrKs   = 'Uz'


CREATE        procedure [dbo].[Ehw_F5_Palm_Exp]
  (
  @PDBaseFinName    As Varchar(20),
  @PServer          As Varchar(100),
  @PPathAdress      As Varchar(150),
  @PKodArtKp        As Varchar(20),
  @PKodArtKs        As Varchar(20),
  @PKodKliKp        As Varchar(20),
  @PKodKliKs        As Varchar(20),
  @PKodMagKp        As Varchar(20),
  @PKodMagKs        As Varchar(20),
  @PKodAgjKp        As Varchar(20),
  @PKodAgjKs        As Varchar(20),
  @PDeriDtKp        As Varchar(20),
  @PDeriDtKs        As Varchar(20),
  @PKodMagGjKp      As Varchar(20),
  @PKodMagGjKs      As Varchar(20),
  @PKodUsrKp        As Varchar(20),
  @PKodUsrKs        As Varchar(20)
  )
as

Declare @VDbFin        Varchar(30)

Set @PKodArtKp       = QuoteName(@PKodArtKp,'''')
Set @PKodArtKs       = QuoteName(@PKodArtKs,'''')
Set @PKodKliKp       = QuoteName(@PKodKliKp,'''')
Set @PKodKliKs       = QuoteName(@PKodKliKs,'''')
Set @PKodMagKp       = QuoteName(@PKodMagKp,'''')
Set @PKodMagKs       = QuoteName(@PKodMagKs,'''')
Set @PKodAgjKp       = QuoteName(@PKodAgjKp,'''')
Set @PKodAgjKs       = QuoteName(@PKodAgjKs,'''')
Set @PDeriDtKp       = QuoteName(@PDeriDtKp,'''')
Set @PDeriDtKs       = QuoteName(@PDeriDtKs,'''')
Set @PKodMagGjKp     = QuoteName(@PKodMagGjKp,'''')
Set @PKodMagGjKs     = QuoteName(@PKodMagGjKs,'''')
Set @PKodUsrKp       = QuoteName(@PKodUsrKp,'''')
Set @PKodUsrKs       = QuoteName(@PKodUsrKs,'''')
Set @VDbFin          = @PDBaseFinName+'..' --'EHW09..'

Declare @VThonjez      Varchar(2)
Set @VThonjez        = QuoteName('','''') 


--									L I N K   S E R V E R   M E   F I L E   A C C E S S
Declare @VServer       Varchar(50)
Declare @QServer       Varchar(50)
Declare @VPathAdress   Varchar(150)
Set @QServer         = @PServer
Set @VServer         = QuoteName(@QServer,'''')
Set @VPathAdress     = QuoteName(@PPathAdress,'''')

Exec('SP_DROPSERVER '+@VServer+',"Droplogins"')
Exec('SP_ADDLINKEDSERVER '+@VServer+',"Access 2000","Microsoft.Jet.OLEDB.4.0",'+@VPathAdress)
Exec('SP_ADDLINKEDSRVLOGIN '+@VServer+',False,"sa","Admin",null')

Set @VServer  = Case When @QServer<>'' Then @QServer+'...' Else @QServer End
--									F U N D  L I N K   S E R V E R


--									P E R G A T I T J E   T E   S T R U K T U R A V E
Declare @VTbName       Varchar(30)
Declare @VTbNameO      Varchar(30)

-- Export F5-Access
Exec('DELETE FROM ' +  @VServer+'MGExpF5')
--
Exec('DELETE FROM ' +  @VServer+'ListeArtikuj')
Exec('DELETE FROM ' +  @VServer+'ListeKlient')
Exec('DELETE FROM ' +  @VServer+'ListeAgjent')
Exec('DELETE FROM ' +  @VServer+'ListeMagazina')
Exec('DELETE FROM ' +  @VServer+'MGGjendjeF5')

--
Exec('DELETE FROM ' +  @VServer+'KlientGjendje')
--Exec('DELETE FROM '+@VServer+'KlientCmim')

--Exec('DELETE FROM '+@VServer+'TipDok')
Exec('DELETE FROM ' +  @VServer+'ListNrKufij')

--Exec('DELETE FROM ' +  @VServer+'KlientPagesa')
--Exec('DELETE FROM ' +  @VServer+'Porosi')
--Exec('DELETE FROM ' +  @VServer+'FJIMPF5')
--Exec('DELETE FROM ' +  @VServer+'MGIMPF5')

--							F U N D I  I  P E R G A T I T J E   T E   S T R U K T U R A V E


--							Export nga F5 ne File-Access te Artikuj,Klient,Magazina,AgjentShitje etj.
Set @VTbName         = 'ARTIKUJ'
Set @VTbNameO        = @VDbFin+@VTbName
Exec('INSERT INTO '+@VServer+'ListeArtikuj (KOD,EMERTIM,EMERTIMSH, 
                                            CMSH1,CMSH2,CMSH3,CMSH4,CMSH5,CMSH6,CMSH7,CMSH8,CMSH9,CMSH10,CMSHPLM1,CMSHPLM2,
                                            KLASIF1,KLASIF2,KLASIF3,NJESI,BARKOD,NOTACTIV)
      SELECT KOD, 
             Replace(Replace(Replace(LEFT(PERSHKRIM,90),'','','' ''),''"'','' ''),'''+@VThonjez+''','' ''),
             Replace(Replace(Replace(PERSHKRIMSH,       '','','' ''),''"'','' ''),'''+@VThonjez+''','' ''),
             CMSH, CMSH1,CMSH2,CMSH3,CMSH4,CMSH5,CMSH6,CMSH7,CMSH8,CMSH9,CMSHPLM1,CMSHPLM2,
             KLASIF,KLASIF2,KLASIF3,NJESI,BC,NOTACTIV
        FROM '+@VTbNameO+' 
       WHERE (LEFT(KOD,1) IN (''P'',''S''))')
--     WHERE (LEFT(KOD,1) IN (''A'',''P'',''S'')) AND (KOD >='+@PKodArtKp+') AND (KOD<='+@PKodArtKs+')' 

Exec('UPDATE '+@VServer+'ListeArtikuj
         SET EMERTIM  =Replace(Replace(Replace(Replace(EMERTIM,  ''ë'',''e''),''ç'',''c''),''Ç'',''C''),''Ë'',''E''),
             EMERTIMSH=Replace(Replace(Replace(Replace(EMERTIMSH,''ë'',''e''),''ç'',''c''),''Ç'',''C''),''Ë'',''E'') ')

Set @VTbName         = 'KLIENT'
Set @VTbNameO        = @VDbFin+@VTbName
Exec('INSERT INTO '+@VServer+'ListeKlient (KOD,PERSHKRIM, PERFAQESUES, ADRESA1,ADRESA2,ADRESA3, 
             NIPT,NIPTCERTIFIKATE,GRUP,VENDNDODHJE,AGJENTSHITJE, KMAG, NOTACTIV)
      SELECT A.KOD,
             Replace(Replace(Replace(A.PERSHKRIM,   '','','' ''),''"'','' ''),'''+@VThonjez+''','' ''),
             Replace(Replace(Replace(A.PERFAQESUES, '','','' ''),''"'','' ''),'''+@VThonjez+''','' ''),
             Replace(Replace(Replace(A.ADRESA1,     '','','' ''),''"'','' ''),'''+@VThonjez+''','' ''),
             Replace(Replace(Replace(B.PERSHKRIM,   '','','' ''),''"'','' ''),'''+@VThonjez+''','' ''),             
             Replace(Replace(Replace(A.ADRESA3,     '','','' ''),''"'','' ''),'''+@VThonjez+''','' ''),
             A.NIPT,A.NIPTCERTIFIKATE,A.GRUP,A.VENDNDODHJE,A.AGJENTSHITJE, A.KMAG, ISNULL(A.NOTACTIV,0) 
        FROM '+@VTbNameO+' A LEFT JOIN '+@VDbFin+'VENDNDODHJE B ON A.VENDNDODHJE=B.KOD
       WHERE (A.KOD >='+@PKodKliKp+') AND (A.KOD<='+@PKodKliKs+')')

Exec('UPDATE '+@VServer+'ListeKlient 
         SET PERSHKRIM   =Replace(Replace(Replace(Replace(PERSHKRIM,   ''ë'',''e''),''ç'',''c''),''Ç'',''C''),''Ë'',''E''), 
             PERFAQESUES =Replace(Replace(Replace(Replace(PERFAQESUES, ''ë'',''e''),''ç'',''c''),''Ç'',''C''),''Ë'',''E''), 
             ADRESA1     =Replace(Replace(Replace(Replace(ADRESA1,     ''ë'',''e''),''ç'',''c''),''Ç'',''C''),''Ë'',''E''), 
             ADRESA2     =Replace(Replace(Replace(Replace(ADRESA2,     ''ë'',''e''),''ç'',''c''),''Ç'',''C''),''Ë'',''E''),
             ADRESA3     =Replace(Replace(Replace(Replace(ADRESA3,     ''ë'',''e''),''ç'',''c''),''Ç'',''C''),''Ë'',''E'') ')

Set @VTbName         = 'MAGAZINA'
Set @VTbNameO        = @VDbFin+@VTbName
Exec('INSERT INTO '+@VServer+'ListeMagazina (KOD,PERSHKRIM, PERGJ, NIPT,NIPTCERTIFIKATE,TIPI,ZONA, KODARKE)
      SELECT KOD, PERSHKRIM, PERGJ, NIPT, NIPTCERTIFIKATE, TIPI, ZONA, KOD 
        FROM '+@VTbNameO+' 
       WHERE (KOD >='+@PKodMagKp+') AND (KOD<='+@PKodMagKs+')')

Set @VTbName         = 'AGJENTSHITJE'
Set @VTbNameO        = @VDbFin+@VTbName
Exec('INSERT INTO '+@VServer+'ListeAgjent (KOD,PERSHKRIM)
      SELECT KOD, PERSHKRIM 
        FROM '+@VTbNameO+' 
    ORDER BY KOD')

Set @VTbName         = 'KLIENTCM'
Set @VTbNameO        = @VDbFin+@VTbName
Exec('INSERT INTO '+@VServer+'KlientCmim (KODKL,KOD,CMIM,ACTIV)
      SELECT KODKL, KOD, CMSH, ACTIV
        FROM '+@VTbNameO+' 
       WHERE (KODKL >='+@PKodKliKp+') AND (KODKL<='+@PKodKliKs+') AND
             (KOD   >='+@PKodArtKp+') AND (KOD  <='+@PKodArtKs+')')

Set @VTbName         = 'DKL'
Set @VTbNameO        = @VDbFin+@VTbName
Exec('INSERT INTO '+@VServer+'KlientGjendje (KOD,KMON,GJENDJE) 
      SELECT LEFT(KOD,CASE WHEN CHARINDEX(''.'',KOD)>0 THEN CHARINDEX(''.'',KOD)-1 ELSE LEN(KOD) END), 
             KMON,
             GJENDJE=ROUND(SUM(CASE WHEN TREGDK=''D'' THEN VLEFTAMV ELSE 0-VLEFTAMV END),0) 
        FROM '+@VTbNameO+' 
       WHERE (KOD >= '+@PKodKliKp+') AND (KOD<='+@PKodKliKs+') AND DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+')
    GROUP BY KMON,KOD 
      HAVING ABS(ROUND(SUM(CASE WHEN TREGDK=''D'' THEN VLEFTAMV ELSE 0-VLEFTAMV END),0))>=1 
    ORDER BY KOD ')
Exec('UPDATE A 
         SET A.PERSHKRIM=B.PERSHKRIM 
        FROM '+@VServer+'KlientGjendje A INNER JOIN '+@VServer+'ListeKlient B ON A.KOD=B.KOD ') 

Set @VTbName         = 'DRHUSER'
Set @VTbNameO        = @VDbFin+@VTbName
Exec('INSERT INTO '+@VServer+'ListNrKufij (KOD,NRKUFIP,NRKUFIS,NRKUFIPJT,NRKUFISJT)
      SELECT KODUS    =SUBSTRING(LEFT(A.KODUS,4),2,30),
             NRKUFIP  =MAX(CASE WHEN RIGHT(A.KODUS,1)=''A'' THEN NRKUFIP ELSE 0 END),
             NRKUFIS  =MAX(CASE WHEN RIGHT(A.KODUS,1)=''A'' THEN NRKUFIS ELSE 0 END),
             NRKUFIPJT=MAX(CASE WHEN RIGHT(A.KODUS,1)=''B'' THEN NRKUFIP ELSE 0 END),
             NRKUFISJT=MAX(CASE WHEN RIGHT(A.KODUS,1)=''B'' THEN NRKUFIS ELSE 0 END)
        FROM '+@VTbNameO+' A 
       WHERE (KODUS >= '+@PKodUsrKp+') AND (KODUS<='+@PKodUsrKs+') AND (MODUL=''S'')
    GROUP BY LEFT(A.KODUS,4)
    ORDER BY LEFT(A.KODUS,4)')
--Print @PKodUsrKp
--Print @PKodUsrKs
Set @VTbName         = 'FJ'
Set @VTbNameO        = @VDbFin+@VTbName
Exec('UPDATE A 
         SET NRKUFIP   = ISNULL((SELECT MAX(NRDOK) FROM '+@VTbNameO+' B WHERE B.NRDOK>=A.NRKUFIP   AND B.NRDOK<=A.NRKUFIS),  A.NRKUFIP)  +1,
             NRKUFIPJT = ISNULL((SELECT MAX(NRDOK) FROM '+@VTbNameO+' B WHERE B.NRDOK>=A.NRKUFIPJT AND B.NRDOK<=A.NRKUFISJT),A.NRKUFIPJT)+1 
        FROM '+@VServer+'ListNrKufij A ')

Set @VTbName         = 'FH'
Set @VTbNameO        = @VDbFin+@VTbName
Exec('INSERT INTO '+@VServer+'MGExpF5   
            (KODKL,KMAG,NRDOK,DATEDOK,KOD,SASI,CMIM,DHURATE,SHENIM1,LLOJDOK,NRRENDORF5) 
      SELECT A.KMAG,A.KMAG,NRDOK,DATEDOK,KARTLLG,SASI,C.CMSH,0,''Furnizim Ditor'',''FU'',B.NRRENDOR
        FROM '+@VTbNameO+' A INNER JOIN '+@VTbNameO+'SCR B ON A.NRRENDOR=B.NRD 
                INNER JOIN '+@VDbFin+'ARTIKUJ C ON B.KARTLLG=C.KOD 
       WHERE (A.KMAG >= '+@PKodMagKp+') AND (A.KMAG<='+@PKodMagKs+') AND 
             (DATEDOK>=DBO.DATEVALUE('+@PDeriDtKp+') AND DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+')) AND
             (DST=''FU'') AND 
             (NOT ((A.KMAG=''M07'') OR (A.KMAG=''M08'')))
    ORDER BY A.KMAG,A.NRDOK,A.DATEDOK,B.KOD')

-- Per dy magazina M07 dhe M08 meret Gjendje e Tyre. Me vone do hiqet kur Pronet te sjelle Programin e Ri

Set @VTbName         = 'LEVIZJEHD'
Set @VTbNameO        = @VDbFin+@VTbName
Exec('INSERT INTO '+@VServer+'MGExpF5   
            (KODKL,KMAG,NRDOK,DATEDOK,KOD,SASI,CMIM,DHURATE,SHENIM1,LLOJDOK,NRRENDORF5) 
      SELECT A.KMAG,A.KMAG,0,DBO.DATEVALUE('+@PDeriDtKs+'),KARTLLG,ROUND(SUM(A.SASIH-SASID),3),
             MAX(ISNULL(C.CMSH,0)),0,''Furnizim Ditor'',''FU'',0
        FROM '+@VTbNameO+' A INNER JOIN '+@VDbFin+'ARTIKUJ C ON A.KARTLLG=C.KOD 
       WHERE (A.KMAG >= '+@PKodMagKp+') AND (A.KMAG<='+@PKodMagKs+') AND 
             ((A.KMAG=''M07'') OR (A.KMAG=''M08''))
    GROUP BY A.KMAG,A.KARTLLG
    ORDER BY A.KMAG,A.KARTLLG')

--Shtim i Artikujve qe mungojne..
Exec('INSERT INTO '+@VServer+'MGExpF5   
            (KODKL,KMAG,NRDOK,DATEDOK,KOD,SASI,CMIM,DHURATE,SHENIM1,LLOJDOK,NRRENDORF5) 
      SELECT B.KOD,B.KOD,0,DBO.DATEVALUE('+@PDeriDtKp+'),A.KOD,0,A.CMSH1,0,''Furnizim Ditor'',''FU'',0 
        FROM '+@VServer+'ListeArtikuj A,'+@VServer+'ListeMagazina B
       WHERE NOT EXISTS(SELECT NRRENDOR 
                          FROM '+@VServer+'MGExpF5 C 
                         WHERE (A.KOD=C.KOD) AND (B.KOD=C.KMAG))')

-- I Vjeter
--Exec('INSERT INTO '+@VServer+'MGExpF5 
--            (KODKL,KMAG,NRDOK,DATEDOK,KOD,SASI,CMIM,DHURATE,SHENIM1,LLOJDOK,NRRENDORF5) 
--       SELECT KMAG,KMAG,MAX(NRDOK),MAX(DATEDOK),KARTLLG,SUM(SASI),MAX(ARTIKUJ.CMSH),0,''Furnizim Ditor'',''FU'',MIN(B.NRRENDOR)
--      FROM '+@VTbNameO+' A INNER JOIN '+@VTbNameO+'SCR B ON A.NRRENDOR=B.NRD 
--                INNER JOIN '+@VTbNameO+'ARTIKUJ C ON B.KARTLLG=C.KOD 
--       WHERE (KMAG >= '+@PKodMagKp+') AND (KMAG<='+@PKodMagKs+') AND 
--             (DATEDOK>=DBO.DATEVALUE('+@PDeriDtKp+') AND DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+')) AND
--             (DST=''FU'')
--    GROUP BY KMAG,B.KARTLLG
--    ORDER BY KMAG,B.KARTLLG')

Set @VTbName         = 'LEVIZJEHD'
Set @VTbNameO        = @VDbFin+@VTbName
Exec('INSERT INTO '+@VServer+'MGGjendjeF5 (KMAG,KOD,DATEDOK,SHENIM1,SASI,NJESI,CMIM)
      SELECT A.KMAG,A.KARTLLG,DBO.DATEVALUE('+@PDeriDtKs+'),MAX(A.PERSHKRIM), ROUND(SUM(A.SASIH-SASID),3),MAX(A.NJESI),ROUND(MAX(B.CMSH),3)
        FROM '+@VTbNameO+' A LEFT JOIN '+@VDbFin+'ARTIKUJ B ON A.KARTLLG=B.KOD
       WHERE (A.KMAG >='+@PKodMagGjKp+') AND (A.KMAG <= '+@PKodMagGjKs+') AND 
             (A.DATEDOK <= DBO.DATEVALUE('+@PDeriDtKs+')) 
    GROUP BY A.KMAG,A.KARTLLG
   HAVING ABS(SUM(A.SASIH-SASID))>=0.01')


GO
